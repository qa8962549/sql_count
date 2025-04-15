--近一年售后回厂的送修人数，其中注册会员数量，这些会员目前的平均V值数量
	select
	count(distinct o.DELIVERER_MOBILE)`送修人数`,
	count(distinct m.member_phone) `注册会员数量`
	from ods_cyre.ods_cyre_tt_repair_order_d o
	left join ods_memb.ods_memb_tc_member_info_cur m on o.DELIVERER_MOBILE = m.member_phone and m.member_status <> '60341003' and m.is_deleted = '0'
	where 1=1
	and o.IS_DELETED = 0
	and o.REPAIR_TYPE_CODE <> 'P'
	and o.RO_STATUS = '80491003'    -- 已结算工单
	and o.RO_CREATE_DATE >= today() - interval '1 year' -- 近一年
	and o.RO_CREATE_DATE < today()
	
--近一年售后回厂的 平均V值数量
	select
	sum(m.member_v_num)/count(m.member_phone) `会员目前的平均V值数量`
	from ods_memb.ods_memb_tc_member_info_cur m
	join (	
--	近一年售后回厂的送修人手机号
		select
		distinct o.DELIVERER_MOBILE
		from ods_cyre.ods_cyre_tt_repair_order_d o
		where 1=1
		and o.IS_DELETED = 0
		and o.REPAIR_TYPE_CODE <> 'P'
		and o.RO_STATUS = '80491003'    -- 已结算工单
		and o.RO_CREATE_DATE >= today() - interval '1 year' -- 近一年
		and o.RO_CREATE_DATE < today()
		) o on o.DELIVERER_MOBILE = m.member_phone 
	where 1=1
	and m.member_status <> '60341003' 
	and m.is_deleted = '0'

--目前V值余额前30%的人，平均V值数量，车主分布（is_owner）,绑车数量分布（is_owner）,最近一年工单数量分布，近一年App活跃天数分布
--平均V值数量
SELECT 
avg(member_v_num)
FROM (
    SELECT id, 
    	member_v_num,
        ntile(10) OVER (ORDER BY member_v_num DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS percentile
	FROM ods_memb.ods_memb_tc_member_info_cur m
	where 1=1 
	and m.member_status <> '60341003' 
	and m.is_deleted = '0'
	and toDate(m.create_time) < today()
	) x
WHERE percentile <= 3 -- V值余额前30%

-- 车主分布（is_owner）
with a as (
	SELECT 
	id, 
	member_v_num
		FROM (
	    SELECT id, 
	    	member_v_num,
	        ntile(10) OVER (ORDER BY member_v_num DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS percentile
		FROM ods_memb.ods_memb_tc_member_info_cur m
		where 1=1 
		and m.member_status <> '60341003' 
		and m.is_deleted = '0'
		and toDate(m.create_time) < today()
		) x
	WHERE percentile <= 3 -- V值余额前30%
),
b as (
--		 车主
		 select
		 r.member_id member_id
		 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.is_owner=1  -- 车主
		 and r.member_id is not null 
		 and r.member_id <>''
		 and toDate(r.date_create) < today()
		)
select if(b.member_id is not null ,'车主','粉丝') sf,
count(DISTINCT a.id) num 
from a 
left join b on b.member_id=a.id::String
group by 1
settings join_use_nulls=1

--		 车主is_bind = 0
		 select *
		 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
		 where r.deleted = 0
		 and r.is_bind = 0  
		 and r.is_owner=1  -- 车主
		 and r.member_id is not null 
		 and r.member_id <>''
		 and toDate(r.date_create) < today()


-- 分段统计
-- 绑车数量分布（is_owner）
with a as (
	SELECT 
	id, 
	member_v_num
	FROM (
	    SELECT id, 
	    	member_v_num,
	        ntile(10) OVER (ORDER BY member_v_num DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS percentile
		FROM ods_memb.ods_memb_tc_member_info_cur m
		where 1=1 
		and m.member_status <> '60341003' 
		and m.is_deleted = '0'
		and toDate(m.create_time) < today()
		) x
	WHERE percentile <= 3 -- V值余额前30%
),
b as (
--		 车主绑车数量
		 select
		 r.member_id member_id,
		 count(distinct r.vin_code) bc_num
		 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
		 where r.deleted = 0
		 and r.is_bind = 1   -- 当前绑车状态
		 and r.is_owner=1  -- 车主
		 and r.member_id is not null 
		 and r.member_id <>''
		 and toDate(r.date_create) < today()
		 group by 1 
		 order by 2 desc 
)
select 
b.bc_num,
count(distinct a.id)
from a 
left join b on b.member_id=a.id::String
group by 1
order by 1  
--settings join_use_nulls=1


-- 最近一年工单数量分布
with a as (
	SELECT 
	id, 
	member_v_num
	FROM (
	    SELECT id, 
	    	member_v_num,
	        ntile(10) OVER (ORDER BY member_v_num DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS percentile
		FROM ods_memb.ods_memb_tc_member_info_cur m
		where 1=1 
		and m.member_status <> '60341003' 
		and m.is_deleted = '0'
		and toDate(m.create_time) < today()
		) x
	WHERE percentile <= 3 -- V值余额前30%
),
b as (
--最近一年工单
	select
	 m.id member_id,
--	 count(distinct o.RO_NO) gd_num2, -- 子工单
	 count(distinct concat(o.RELATION_RO_NO,OWNER_CODE))gd_num -- 母工单+经销商code
	from ods_cyre.ods_cyre_tt_repair_order_d o
	left join ods_memb.ods_memb_tc_member_info_cur m on o.DELIVERER_MOBILE = m.member_phone and m.member_status <> '60341003' and m.is_deleted = '0'
	where 1=1
	and o.IS_DELETED = 0
	and o.REPAIR_TYPE_CODE <> 'P'
	and o.RO_STATUS = '80491003'    -- 已结算工单
	and o.RO_CREATE_DATE >= today() - interval '1 year' -- 近一年
	and o.RO_CREATE_DATE < today()
	and m.id is not null 
	group by 1 
	order by 2 desc  
)
select 
b.gd_num,
count(distinct a.id)
from a 
left join b on b.member_id::String=a.id::String
group by 1 
order by 1 
--settings join_use_nulls=1

--最近一年工单 测试
	select
	o.RO_NO,
	o.RELATION_RO_NO,
	OWNER_CODE,
	o.DELIVERER_MOBILE,
	m.member_phone,
	 m.id member_id
	from ods_cyre.ods_cyre_tt_repair_order_d o
	left join ods_memb.ods_memb_tc_member_info_cur m on o.DELIVERER_MOBILE = m.member_phone and m.member_status <> '60341003' and m.is_deleted = '0'
	where 1=1
	and o.IS_DELETED = 0
	and o.REPAIR_TYPE_CODE <> 'P'
	and o.RO_STATUS = '80491003'    -- 已结算工单
	and o.RO_CREATE_DATE >= today() - interval '1 year' -- 近一年
	and o.RO_CREATE_DATE < today()

-- 近一年App活跃天数分布
with a as (
	SELECT 
	id, 
	member_v_num
	FROM (
	    SELECT id, 
	    	member_v_num,
	        ntile(10) OVER (ORDER BY member_v_num DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS percentile
		FROM ods_memb.ods_memb_tc_member_info_cur m
		where 1=1 
		and m.member_status <> '60341003' 
		and m.is_deleted = '0'
		and toDate(m.create_time) < today()
		) x
	WHERE percentile <= 3 -- V值余额前30%
),
b as (
	--APP日活
	select memberid,
	count(distinct dt) hy_num
	from ods_oper_crm.ods_oper_crm_active_gio_d_si 
	where platform ='App'
	and date(dt)>= today() - interval '1 year'
	and date(dt)< today()
	and memberid is not null 
	group by 1 
	order by 2 desc
)
SELECT 
    hy_num,
    count(distinct id) AS id_count
FROM (
    SELECT 
        a.id,
        b.hy_num
    FROM a 
    LEFT JOIN b ON b.memberid::String = a.id::String
) AS subquery
GROUP BY 1
ORDER BY 1

