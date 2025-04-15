-- 统计app和小程序新增人数使用
select 
distinct date_trunc('month',date)
,x.distinct_id
from 
  (
  select 
    distinct_id as distinct_id, 
    date
  from 
  	(select date
  	,distinct_id
    ,row_number() over(partition by user_id order by time) t_rank 
       from ods_rawd_events_cur 
       WHERE event in ('$AppStart', '$AppInstall','$AppViewScreen','$MPViewScreen')
       and ($lib in ('iOS','Android') or channel='App')
       and length(distinct_id) < 9 -- 会员
       and date< '2023-08-01'
  		and date>= '2022-01-01'
  		-- and $is_first_day =1
      ) a
  where a.t_rank=1
)x 
order by 1