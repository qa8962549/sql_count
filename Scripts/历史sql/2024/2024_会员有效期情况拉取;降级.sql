-- 会员有效期情况拉取;降级
select tmi.id `会员ID`
,tmi.member_phone `用户手机号`
,tmi.is_vehicle `是否车主`
,tmi.last_levtime `上次会员等级变更日期`
,tmi.`会员等级有效期` `会员等级有效期` 
,tmi.level_id `当前等级`
,ifnull(t1.total_c_num,0) `当前有效成长值`
,ifnull(t4.mth_c_num,0) `未来1个月过期成长值`
,ifnull(t2.mth_c_num,0) `近一个月获取成长值`
,case when t3.distinct_id is not null then 1 else 0 end `是否注册APP`
from (
	select
		aa.*
		,last_levtime
		,case when last_levtime < '2023-08-04' then last_levtime + interval '6 month'
			else last_levtime + interval'12 MONTH' end as `会员等级有效期`
	from (
		select 
		tmi.*
		,toDateTime(greatest(ifnull(tmi.member_uplevtime,'1970-01-01'), ifnull(tmi.member_downlevtime,'1970-01-01')) ) last_levtime
		from ods_memb.ods_memb_tc_member_info_cur tmi
		where level_id >= 2
		and tmi.is_deleted = 0 
		and tmi.member_status <> '60341003'
		) aa 
	) tmi
left join (
--当前有效成长值
	select r.member_id
	, sum(r.add_c_num) as total_c_num
	from ods_memb.ods_memb_tt_member_score_record_cur r
	where r.status = 1  -- 状态：1 有效 0 无效
	and r.is_deleted = 0 
	and r.add_c_num > 0
	and is_back = 0 
	and toDate(r.create_time) >today() + interval '-12 month'
--	and r.r.member_id ='5798431'
	group by member_id
	) t1
on toString(tmi.id)  = toString(t1.member_id ) 
left join (
--近一个月获取成长值
	select r.member_id
	, sum(r.add_c_num) as mth_c_num
	from ods_memb.ods_memb_tt_member_score_record_cur r
	where r.status = 1  -- 状态：1 有效 0 无效
	and r.is_deleted = 0 
	and r.add_c_num > 0
	and is_back = 0 
	and toDate(r.create_time) >today() + interval '-1 month'
--	and r.r.member_id ='5798431'
	group by member_id
	) t2
on toString(tmi.id)  = toString(t2.member_id ) 
left join (
-- 未来1个月过期成长值
	select r.member_id
	, sum(r.add_c_num) as mth_c_num
	from ods_memb.ods_memb_tt_member_score_record_cur r
	where r.status = 1  -- 状态：1 有效 0 无效
	and r.is_deleted = 0 
	and r.add_c_num > 0
	and is_back = 0 
	and toDate(r.create_time)>=today() + interval '-12 month'
	and toDate(r.create_time)<=today() + interval '-11 month'
--	and r.r.member_id ='5798431'
	group by member_id
	) t4
on toString(tmi.id)  = toString(t4.member_id ) 
left join (
	-- CK取数
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where length(distinct_id)<9
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	group by distinct_id
	) t3 
on toString(tmi.cust_id)  = toString(t3.distinct_id) 
where level_id >= 2
and tmi.is_deleted = 0
and tmi.member_status <> '60341003'
and tmi.last_levtime >= '2022-08-04' 
and tmi.last_levtime < '2023-01-01' 
--and tmi.`会员等级有效期` >= '2024-02-01' 
--and tmi.`会员等级有效期` < '2024-07-01'

select now(),today(),today() + interval '-6 month'

select tmi.id `会员ID`
, tmi.member_phone `用户手机号`
, is_vehicle `是否车主`
, tmi.会员等级有效期
,tmi.level_id `当前等级`
, t1.total_c_num `当前有效成长值`
, t2.mth_c_num `近一个月获取成长值`
--,case when t3.distinct_id is not null then 1 else 0 end `是否注册APP`
from (
	select aa.*
		,case when last_levtime < '2023-08-04' then last_levtime + '6 MONTH' 
			else last_levtime + '12 MONTH' end as `会员等级有效期`
	from (
		select 
		tmi.*
--			,greatest(ifnull(tmi.member_uplevtime,0), ifnull(tmi.member_downlevtime,0))
			,coalesce(greatest(tmi.member_uplevtime, tmi.member_downlevtime), tmi.member_uplevtime, tmi.member_downlevtime) last_levtime
		from `member`.tc_member_info tmi 
		where level_id >= 2
		and tmi.is_deleted = 0 
		and tmi.member_status <> 60341003
		) aa 
	) tmi
left join (
	select r.member_id, sum(r.add_c_num) as total_c_num
	from `member`.tt_member_score_record r
	where r.status = 1  -- 状态：1 有效 0 无效
	and r.is_deleted = 0 and r.add_c_num > 0
	and is_back = 0 and r.create_time > '2022-12-29'
	group by 1
	) t1
on tmi.id = t1.member_id 
left join (
	select r.member_id, sum(r.add_c_num) as mth_c_num
	from `member`.tt_member_score_record r
	where r.status = 1  -- 状态：1 有效 0 无效
	and r.is_deleted = 0 and r.add_c_num > 0
	and is_back = 0 and r.create_time > '2023-11-29'
	group by 1
	) t2
on tmi.id = t2.member_id 
--left join (
--	-- CK取数
--	select distinct_id
--	from ods_rawd.ods_rawd_events_d_di
--	where length(distinct_id)<9
--	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--	group by distinct_id
--	) t3 
--on tmi.cust_id = t3.distinct_id
where level_id >= 2
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
and tmi.会员等级有效期 >= '2024-02-01' and tmi.会员等级有效期 < '2024-07-01'
;