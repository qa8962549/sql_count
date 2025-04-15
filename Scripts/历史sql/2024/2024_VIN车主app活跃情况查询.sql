--App绑车会员月活数
select a.vin_code
,a.cust_id
,x.num `近一年活跃情况`
,x1.num `近一个月活跃情况`
,x2.num `近一周活跃情况`
from (
	select a.member_id member_id,
	a.cust_id cust_id,
	a.vin_code vin_code
	from 
		(
		--车主
		 select
		 r.member_id,
		 m.cust_id,
		 r.vin_code,
		 row_number() over(partition by r.vin_code order by r.bind_date desc) rk
		 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
		 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.is_owner=1  -- 车主
		 and m.is_vehicle =1
		 Settings allow_experimental_window_functions = 1
		 )a where a.rk=1
	)a 
left join (
	-- 近一年活跃情况APP 活跃天数，单次活跃时间达到30s以上
	select 
	distinct distinct_id,
	count(distinct date(time)) num 
	from ods_rawd.ods_rawd_events_d_di a
	where (($lib in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and a.`date` >= '2023-03-01'
	and a.`date` < '2024-03-01'
	and event ='$AppEnd'
	and `$event_duration`>30 -- 单次活跃时间达到30s以上
	and length(distinct_id)<9
	group by distinct_id
	order by num desc 
	)x on toString(x.distinct_id)=toString(a.cust_id)
left join 
(
	-- 近一个月活跃情况APP 活跃天数，单次活跃时间达到30s以上
	select 
	distinct distinct_id,
	count(distinct date(time)) num 
	from ods_rawd.ods_rawd_events_d_di a
	where (($lib in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and a.`date` >= '2024-02-01'
	and a.`date` < '2024-03-01'
	and event ='$AppEnd'
	and `$event_duration`>30 -- 单次活跃时间达到30s以上
	and length(distinct_id)<9
	group by distinct_id
	order by num desc 
	)x1 on toString(x1.distinct_id)=toString(a.cust_id) 
left join 
(
	-- 近一周活跃情况APP 活跃天数，单次活跃时间达到30s以上
	select 
	distinct distinct_id,
	count(distinct date(time)) num 
	from ods_rawd.ods_rawd_events_d_di a
	where (($lib in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and a.`date` >= '2024-02-26'
	and a.`date` < '2024-03-04'
	and event ='$AppEnd'
	and `$event_duration`>30 -- 单次活跃时间达到30s以上
	and length(distinct_id)<9
	group by distinct_id
	order by num desc 
	)x2 on toString(x2.distinct_id)=toString(a.cust_id);

--App车主亲友月活数
select a.vin_code
,a.cust_id
,x.num `近一年活跃情况`
,x1.num `近一个月活跃情况`
,x2.num `近一周活跃情况`
	from (
	select a.member_id member_id,
	a.cust_id cust_id,
	a.vin_code vin_code
	from 
		(
		--亲友
		 select
		 r.member_id,
		 m.cust_id,
		 r.vin_code,
		 row_number() over(partition by r.vin_code order by r.bind_date desc) rk
		 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
		 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.relative_type not in (1,0)
		 Settings allow_experimental_window_functions = 1
		 )a where a.rk=1
	)a 
left join (
	-- 近一年活跃情况APP 活跃天数，单次活跃时间达到30s以上
	select 
	distinct distinct_id,
	count(distinct date(time)) num 
	from ods_rawd.ods_rawd_events_d_di a
	where (($lib in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and a.`date` >= '2023-03-01'
	and a.`date` < '2024-03-01'
	and event ='$AppEnd'
	and `$event_duration`>30 -- 单次活跃时间达到30s以上
	and length(distinct_id)<9
	group by distinct_id
	order by num desc 
	)x on toString(x.distinct_id)=toString(a.cust_id)
left join 
(
	-- 近一个月活跃情况APP 活跃天数，单次活跃时间达到30s以上
	select 
	distinct distinct_id,
	count(distinct date(time)) num 
	from ods_rawd.ods_rawd_events_d_di a
	where (($lib in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and a.`date` >= '2024-02-01'
	and a.`date` < '2024-03-01'
	and event ='$AppEnd'
	and `$event_duration`>30 -- 单次活跃时间达到30s以上
	and length(distinct_id)<9
	group by distinct_id
	order by num desc 
	)x1 on toString(x1.distinct_id)=toString(a.cust_id) 
left join 
(
	-- 近一周活跃情况APP 活跃天数，单次活跃时间达到30s以上
	select 
	distinct distinct_id,
	count(distinct date(time)) num 
	from ods_rawd.ods_rawd_events_d_di a
	where (($lib in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and a.`date` >= '2024-02-26'
	and a.`date` < '2024-03-04'
	and event ='$AppEnd'
	and `$event_duration`>30 -- 单次活跃时间达到30s以上
	and length(distinct_id)<9
	group by distinct_id
	order by num desc 
	)x2 on toString(x2.distinct_id)=toString(a.cust_id);

-- 车主亲友授权 
select count(distinct v.member_id)
from volvo_cms.vehicle_bind_relation v
where v.relative_type not in (1,0) -- 