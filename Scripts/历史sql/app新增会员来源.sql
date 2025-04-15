--超过30天未活跃，最后一次活跃为车主身份
select distinct_id
,time
from 
	(
	select distinct_id
	  ,is_bind
	  ,time
	  ,row_number() over(partition by distinct_id order by time desc) rk
	  from ods_rawd_events_d_di 
	  where 1=1
	  and event in ('$AppViewScreen','$MPViewScreen')
	  and length(distinct_id)<9 
	  Settings allow_experimental_window_functions = 1
	)x 
where x.rk=1 
and x.is_bind=1
and x.time<date_sub(now(),interval 30 day)

select *
from ods_rawd_events_d_di o
where distinct_id ='20714191'
order by time
limit 10

-- 用户访问活动的最早时间，以及访问活动最早时间的十分钟以前的最近一次登录APP时间,这两个时间差超过30天的用户。满足这个条件的用户算该活动激活沉睡用户
-- 激活沉睡用户APP
select 
--x.user_id as id,
--x.distinct_id,
--case when datediff('day',x.mat,x.mit)>=30 then '是' -- 时间差大于30天
--else '否' end value,
count(distinct case when datediff('day',x.mat,x.mit)>=30 then x.distinct_id end)
from
   (-- 获取访问文章活动10分钟之前的最晚访问时间
   select a.user_id,
   a.distinct_id,
   x.mit,
   MAX(a.time) mat
   from ods_rawd_events_d_di a
     global join(
     --获取访问活动的最早时间
     select a.user_id,
     a.distinct_id,
     MIN(a.time) mit
     from ods_rawd_events_d_di a
     where 1=1
     and event='Page_entry'
     and page_title='3月会员日'
     and time between '2023-03-25' 
     and '2023-03-25 23:59:59'
     and length(distinct_id)<9 
     -- and page_title='525车主节'
     -- and activity_name='2023年5月车主节活动'
     group by a.user_id,a.distinct_id
     )x on x.distinct_id=a.distinct_id
   where a.time < date_sub(x.mit,interval 10 minute)
   and event='$AppViewScreen'
   group by a.user_id,a.distinct_id,x.mit
   )x
--   group by value

-- APP激活 口径2
select 
-- count(1)
a.user_id,
a.distinct_id,
a.date,
a.mintime
from (
  --3月会员日活动页面浏览所有用户的最早访问时间
  select 
  user_id,
  date,
  distinct_id,
  min(time) as mintime
  from ods_rawd_events_d_di 
  where  event='Page_entry'
  and length(distinct_id)<9 
  and page_title='3月会员日'
  and date='2023-03-25'
  group by user_id,date,distinct_id
    ) a 
left join 
    (
  --往前推30天每天用户访问情况
  select 
  user_id,distinct_id 
  from ods_rawd_events_d_di 
  where 1=1
  and event='$AppViewScreen'
--  and event='$AppStart'
  and length(distinct_id)<9 
  and date >=date_sub(cast('2023-03-25' as date),interval 30 day) and date < '2023-03-25'
  group by user_id,distinct_id 
) b on a.user_id=b.user_id
where b.user_id is null

-- 是否拉新
select 
distinct a.user_id as id,
a.distinct_id,
case when (DATEDIFF('minute',a.time,b.time)<=10) and (DATEDIFF('minute',b.time,a.time)>=-10)then '是' -- 时间差少于十分钟
else '否' end value
from 
  (
  -- 访问525活动的时间
    select 
    user_id,
    distinct_id,
    time,
    row_number() over(partition by user_id order by time) t_rank 
    from ods_rawd_events_d_di
    where 1=1
    and page_title='525车主节'
    and activity_name='2023年5月车主节活动'
    Settings allow_experimental_window_functions = 1
    )a
join 
  (
  select a.*
  from (
  -- 第一次访问app时间
  select 
    distinct a.user_id,
    a.distinct_id as distinct_id, 
    a.time,
    a.date,
    row_number() over(partition by user_id order by time) t_rank 
  from ods_rawd_events_d_di a
  where $is_first_day=1
  and length(distinct_id)<9 
  Settings allow_experimental_window_functions = 1
  )a where a.t_rank =1
  	)b on a.user_id=b.user_id
  -- group by id
  
 select time
 ,toDate(`time`)
 , `date` 
 ,toDate(`date`)
 ,DATE_TRUNC('month',time) 
from ods_rawd.ods_rawd_events_d_di 
where distinct_id='20714191' 
limit 10; 	




    	
    	
