-- 点击【即刻预约，乐享“驾”日】btn PVUV
	select 
	count(user_id) PV,
	count(distinct user_id) UV
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and event='Button_click'
	and btn_name ='即刻预约，乐享“驾”日'
	and date>='2023-09-01'
	and date<'2023-10-31'

--基础数据
	select 
	count(user_id) PV,
	count(distinct user_id) UV,
	count(distinct case when is_bind=1 then user_id else null end ) "车主UV",
	count(distinct case when is_bind=0 and length(distinct_id)<9 then user_id else null end ) "粉丝UV",
	count(distinct case when length(distinct_id)>=9 then user_id else null end ) "游客UV",
	count(distinct case when `$is_first_day` =1 then user_id  else null end) "拉新"
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and event='$MPViewScreen'
	and $url like '%Dg82cQK2sq%'
	and date>='2023-09-01'
	and date<'2023-10-31'

-- 首页弹窗
select 
'1' a,
count(user_id) "PV",
count(distinct user_id) "UV",
count(distinct case when `$is_first_day` =1 then user_id  else null end) "拉新"
from ods_rawd.ods_rawd_events_d_di
where 1=1
and event='$MPViewScreen'
and $url like '%miniprogram%'
and $url like '%volvo_world%'
and $url like '%homepagepopup%'
and $url like'%202309_10_testdrive_activity%'
and $url like '%Dg82cQK2sq%'
and date>='2023-09-01'
and date<'2023-10-31'

-- 沃的活动banner
select 
'1' a,
count(user_id) "PV",
count(distinct user_id) "UV",
count(distinct case when `$is_first_day` =1 then user_id  else null end) "拉新"
from ods_rawd.ods_rawd_events_d_di
where 1=1
and event='$MPViewScreen'
and $url like '%miniprogram%'
and $url like '%volvo_world%'
and $url like '%banner%'
and $url like'%202309_10_testdrive_activity%'
and $url like '%Dg82cQK2sq%'
and date>='2023-09-01'
and date<'2023-10-31'

-- 点击【即刻预约，乐享“驾”日】
select 
'1' a,
count(user_id) "PV",
count(distinct user_id) "UV",
count(distinct case when `$is_first_day` =1 then user_id  else null end) "拉新"
from ods_rawd.ods_rawd_events_d_di
where 1=1
and event='$MPViewScreen'
and $url like '%miniprogram%'
and $url like '%volvo_world%'
and $url like '%test_drive%'
and $url like'%202309_10_testdrive_activity%'
and $url like '%Dg82cQK2sq%'
and date>='2023-09-01'
and date<'2023-10-31'

-- APP激活
select 
distinct a.user_id as id,
a.distinct_id
from (
	select 
	  user_id,
	  date,
	  distinct_id,
--	  is_bind,
	  min(time) as mintime
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and event='$MPViewScreen'
	and $url like '%miniprogram%'
	and $url like '%volvo_world%'
	and $url like '%homepagepopup%'
	and $url like'%202309_10_testdrive_activity%'
	and $url like '%Dg82cQK2sq%'
	and date>='2023-09-01'
	and date<'2023-10-31'
	and length(distinct_id)<9 
	group by user_id,date,distinct_id
	) a 
left join 
    (
  --往前推30天每天用户访问情况
  select user_id,distinct_id 
  from ods_rawd.ods_rawd_events_d_di
  	where event='$MPViewScreen'
	and length(distinct_id)<9 
  	and date >= '2023-08-01' 
  	and date< '2023-09-01'
  group by user_id,distinct_id 
) b on a.user_id=b.user_id
where b.user_id is null

