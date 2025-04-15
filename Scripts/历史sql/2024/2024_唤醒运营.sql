
-- 唤醒运营(2023年每个月的月活中，有多少人是过去12个月没活跃过的)
select 
count(distinct a.distinct_id)
from
	(-- 当月访问用户
	select distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and length(distinct_id)<9 
	and date>='2023-01-01'
	and date<'2023-02-01'
)a
left join
	(-- 注册会员
	select distinct m.cust_id
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time >= '2023-01-01'
	and m.create_time <'2023-02-01'
)b on toString(a.distinct_id) =toString(b.cust_id)
left join
	(-- 当月访问前12月内活跃过
		select distinct a.distinct_id
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and length(distinct_id)<9 
		and date>='2022-01-01'
		and date<'2023-01-01'
)c on toString(a.distinct_id) =toString(c.distinct_id) 
where 1=1
and b.cust_id is null -- 剔除新用户
and c.distinct_id is null   -- 剔除访问前12个月内活跃过的用户

select distinct a.distinct_id
from
	(-- 访问过app用户
	select distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and length(distinct_id)<9 
	and date>='2023-01-01'
	and date<'2023-02-01'
)a
left join
	(-- 注册会员
	select distinct m.cust_id
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time >= '2023-01-01'
	and m.create_time <'2023-02-01'
)b on toString(a.distinct_id) =toString(b.cust_id)
left join
	(-- 访问过12 month内活跃过
		select distinct a.distinct_id
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and length(distinct_id)<9 
		and date>='2022-01-01'
		and date<'2023-01-01'
)c on toString(a.distinct_id) =toString(c.distinct_id) 
where 1=1
and b.cust_id is null -- 剔除新用户
and c.distinct_id is null   -- 剔除访问活动前30天内活跃过的车主会员


select distinct distinct_id ,date
from ods_rawd.ods_rawd_events_d_di a
where a.distinct_id ='5062181'

-- 注册会员
	select distinct m.cust_id,create_time 
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.cust_id ='5062181'

