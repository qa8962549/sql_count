--2024年活跃天数车主转化
select case when x.num =1 then '08_1天车主'
	when x.num>=2 and x.num <=4 then '07_2-4天车主'
	when x.num>=5 and x.num <=9 then '06_5-9天车主'
	when x.num>=10 and x.num <=19 then '05_10-19天车主'
	when x.num>=20 and x.num <=29 then '04_20-29天车主'
	when x.num>=30 and x.num <=59 then '03_30天-59天车主'
	when x.num>=60 and x.num <=89 then '02_60天-89天车主'
	when x.num>=90 then '01_90天以上车主' else null end `分组`,
count(x.memberid),
--count(x11.`会员id`)  `有过留资线索+发起过推荐线索的人数（去重）`,
--count(x12.`会员id`)  `有过留资线索的人数`,
--count(x13.`会员id`)  `发起过推荐购的人数`,
--count(x14.`会员id`)  `参与过推荐购的人数`,
sum(x6.`不含税的总金额`)  `GMV（售后+精品）`,
sum(x7.`线索（试驾+一键留资+非标线索）`)  `线索（试驾+一键留资+非标线索）`,
sum(x8.`推荐购线索`)  `推荐购线索`,
sum(x9.`推荐购订单`)  `推荐购订单`,
--count(x10.`member_id`)  `推荐大于等于2次人数`,
sum(x2.`预约养修次数`)  `预约养修次数`,
sum(x2.`预约养修回厂次数`)  `预约养修回厂次数`,
sum(x2.`预约养修回厂订单数`)  `预约养修回厂订单数`,
sum(x2.`预约养修回厂金额`)  `预约养修回厂金额`,
sum(x3.`全量回厂金额`)  `全量回厂金额`,
sum(x4.`发帖次数`)  `发帖次数`,
sum(x5.`优质内容`)  `优质内容`
from 
(
	--用户累计活跃天数
	select o.memberid,count(distinct date(o.dt))num
	from ods_oper_crm.ods_oper_crm_active_gio_d_si o
	left join ods_memb.ods_memb_tc_member_info_cur m on m.id::String=o.memberid::String 
	where 1=1
	and o.platform ='App'
	and date(o.dt)>= '2024-01-01'
	and date(o.dt)< '2025-04-01'
	and m.is_vehicle ='1' -- chezhu
	and o.memberid is not null 
	group by 1 
	order by 2 desc
)x
left join 
	(
	-- 养修预约 预约养修回厂次数 回厂金额
	select 
	tmi.id::String id,
--	ta.ONE_ID ,
	count(tam.APPOINTMENT_ID) `预约养修次数`,
	count(case when tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') then tam.APPOINTMENT_ID else null end) `预约养修回厂次数`,
	count(tam.WORK_ORDER_NUMBER) `预约养修回厂订单数`,
	sum(d.RMB)`预约养修回厂金额`
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join (
			-- 2、售后工单总金额、人数、工单数
			select
--			ifnull(o.OWNER_ONE_ID,oc.ONE_ID) OWNER_ONE_ID,
			o.RO_NO,
			o.OWNER_CODE ,
			sum(o.BALANCE_AMOUNT) RMB
			from ods_cyre.ods_cyre_tt_repair_order_d o
			left join ods_cyre.ods_cyre_tm_owner_d oc on o.OWNER_NO =oc.OWNER_NO and o.OWNER_CODE =oc.OWNER_CODE 
			where o.IS_DELETED = 0
			and o.REPAIR_TYPE_CODE <> 'P'
			and o.RO_STATUS = '80491003'    -- 已结算工单
			and o.RO_CREATE_DATE >= '2024-01-01'
			and o.RO_CREATE_DATE < '2025-04-01'
			and OWNER_ONE_ID is not null 
			group by 1,2
			order by 1 
			)d on d.RO_NO = tam.WORK_ORDER_NUMBER and ta.OWNER_CODE =d.OWNER_CODE 
	left join 
		(select tmi.id
		,tmi.cust_id
		,row_number()over(partition by tmi.cust_id order by tmi.create_time desc) rk 
		from ods_memb.ods_memb_tc_member_info_cur tmi
		where tmi.is_deleted =0
		Settings allow_experimental_window_functions = 1
		)tmi on ta.ONE_ID = tmi.cust_id and tmi.rk =1
	where 1=1
	and tam.IS_DELETED <>1
	and date(ta.CREATED_AT)>= '2024-01-01'
	and date(ta.CREATED_AT)< '2025-04-01'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005 
	and tmi.id is not null 
--	and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') -- 进厂
	group by 1
	order by 3 desc  
	)x2 on x2.id=x.memberid
left join 
	(
	-- 全量回厂金额
		select
		tmi.id::String id,
		sum(o.BALANCE_AMOUNT) `全量回厂金额`
		from ods_cyre.ods_cyre_tt_repair_order_d o
		left join ods_cyre.ods_cyre_tm_owner_d oc on o.OWNER_NO =oc.OWNER_NO and o.OWNER_CODE =oc.OWNER_CODE 
		left join 
			(select tmi.id
			,tmi.cust_id
			,row_number()over(partition by tmi.cust_id order by tmi.create_time desc) rk 
			from ods_memb.ods_memb_tc_member_info_cur tmi
			where tmi.is_deleted =0
			Settings allow_experimental_window_functions = 1
			)tmi on ifnull(o.OWNER_ONE_ID,oc.ONE_ID) = tmi.cust_id and tmi.rk =1
		where o.IS_DELETED = 0
--			and o.REPAIR_TYPE_CODE <> 'P'
		and o.RO_STATUS = '80491003'    -- 已结算工单
		and o.RO_CREATE_DATE >= '2024-01-01'
		and o.RO_CREATE_DATE < '2025-04-01'
		and tmi.id is not null 
		group by 1 
		order by 1 
	)x3 on x3.id=x.memberid
left join 
	(
	-- 发帖次数
	select 
	x.member_id::String member_id,
	count(1) `发帖次数`
	from 
		(
		select a.id,a.member_id,a.create_time
		from ods_cmnt.ods_cmnt_tm_post_cur a
		where 1=1
		and a.is_deleted =0
		and a.create_time >='2024-01-01'
		and a.create_time <'2025-04-01'
		and a.member_id is not null 
		)x 
		group by 1
		order by 1
	)x4 on x4.member_id=x.memberid
left join 
	(--优质内容（加精、上推荐）
		select a.member_id::String member_id ,
		count(1) `优质内容`
		from ods_cmnt.ods_cmnt_tm_post_cur a
		left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id=m.id
		where 1=1
		and a.is_deleted =0
		and a.create_time >='2024-01-01'
		and a.create_time <'2025-04-01'
		and (a.recommend=1 -- 上推荐
		or a.selected_time <>0) --加精
		and a.member_id is not null 
		group by 1 
	)x5 on x5.member_id=x.memberid
left join 
	(-- GMV（售后+精品） 去除第三方卡券
	select 
	--	a.order_code `订单编号`
	--	,ifnull(a.parent_order_code,a.order_code) `母单号`
		h.id::String member_id
		,round(sum(((b.fee/100) - (b.coupon_fee/100))/1.13),2) `不含税的总金额`
	--	,a.create_time `时间`
	from ods_orde.ods_orde_tt_order_d a
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code and b.is_deleted = 0
	left join ods_memb.ods_memb_tc_member_info_cur h on a.user_id::varchar = h.id::varchar and h.is_deleted = 0
	where 1=1
	and a.is_deleted = 0  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and b.spu_type <> '51121002' -- 第三方卡券
	and a.create_time >= '2024-01-01'
	and a.create_time < '2025-04-01'
	and h.id is not null 
	group by 1 
	order by 1
	)x6 on x6.member_id=x.memberid
left join 
		(-- 线索（试驾+一键留资+非标线索） liteCRM
	select x.member_id member_id,
	count(1)`线索（试驾+一键留资+非标线索）`
	from 
	(
	select 
	m.id::String member_id
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on m.member_phone = ta.CUSTOMER_PHONE and m.is_deleted = 0
	where 1=1
	and ta.IS_DELETED = 0
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') -- 预约试乘试驾
	and ta.CREATED_AT >= '2024-01-01'
	and ta.CREATED_AT < '2025-04-01'
	and m.id is not null 
	union all
	select m.id::String
	from ods_vced.ods_vced_tm_leads_collection_pool_d tlcp 
	left join ods_memb.ods_memb_tc_member_info_cur m on m.member_phone = tlcp.customer_mobile and m.is_deleted = 0
	where 1=1
	and tlcp.campaign_code in
		(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-14'
		)
	and tlcp.create_time >= '2024-01-01'
	and tlcp.create_time < '2025-04-01'
	and m.id is not null 
	union all 
	select m.id::String 
	from ods_vced.ods_vced_tm_leads_collection_pool_d tlcp 
	left join ods_memb.ods_memb_tc_member_info_cur m on m.member_phone = tlcp.customer_mobile and m.is_deleted = 0
	where 1=1
	and tlcp.campaign_code = 'IBCRMMAYALL000732024VCCN' -- 非标
	and tlcp.create_time >= '2024-01-01'
	and tlcp.create_time < '2025-04-01'
	and m.id is not null 
	)x
--	where x.member_id is not null 
	group by 1 
	)x7 on x7.member_id=x.memberid
left join 
		(-- 推荐购线索
	select tir.be_invite_member_id::String member_id
	,count(1) `推荐购线索`
	from ods_invi.ods_invi_tm_invite_record_d tir 
	where tir.is_deleted = 0
	and tir.create_time >= '2024-01-01'
	and tir.create_time < '2025-04-01'
	and tir.be_invite_member_id is not null 
	group by 1)x8 on x8.member_id=x.memberid
left join 
		(
		-- 推荐购订单
	select be_invite_member_id::String member_id
	,count(distinct order_no) `推荐购订单`
	from ods_invi.ods_invi_tm_invite_record_d tir
	where 1=1 
	and tir.is_deleted = 0
	and tir.order_status in ('14041008','14041003') -- 有效订单
	and tir.order_no is not null -- 筛选订单号不为空
	and tir.cancel_large_setorder_time = '1970-01-01 08:00:00' -- 排除取消订单的情况
	and tir.red_invoice_time = '1970-01-01 08:00:00' -- 红冲发票为空
	and tir.invoice_no is not null
	and tir.be_invite_member_id is not null 
	and tir.create_time >= '2024-01-01'
	and tir.create_time < '2025-04-01'
	group by 1
		)x9 on x9.member_id=x.memberid
left join 
		(-- 推荐大于等于2次人数
	select tir.invite_member_id::String member_id
--	,count(1) `推荐大于等于2次人数`
	from ods_invi.ods_invi_tm_invite_record_d tir 
	where tir.is_deleted = 0
	and tir.create_time >= '2024-01-01'
	and tir.create_time < '2025-04-01'
	and tir.be_invite_member_id is not null 
	group by 1
	having count(1)>=2
	)x10 on x10.member_id=x.memberid
left join 
	(
	--  有过留资线索+发起过推荐线索的人数（去重）
	select distinct x.`会员id`::String `会员id`
	from 
	(	-- 试驾
		select distinct m.id `会员id` ,'留资线索' `渠道`
		from ods_cyap.ods_cyap_tt_appointment_d ta
		left join ods_memb.ods_memb_tc_member_info_cur m on m.member_phone = ta.CUSTOMER_PHONE and m.is_deleted = 0
		where 1=1
		and ta.IS_DELETED = 0
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'  
	 	and ta.CREATED_AT < '2025-04-01'
		union all
		-- 一键留资
		select distinct m.id `会员id` ,'留资线索' `渠道`
		from ods_vced.ods_vced_tm_leads_collection_pool_d tlcp 
		left join ods_memb.ods_memb_tc_member_info_cur m on m.member_phone = tlcp.customer_mobile and m.is_deleted = 0
		where 1=1
		and tlcp.campaign_code in
			(
				select distinct trim(hd.code) code
				from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
				where trim(hd.channel) = '一键留资'
				and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-14'
			)
		and tlcp.create_time >= '2024-01-01'  
	 	and tlcp.create_time < '2025-04-01'
		union all
		-- 发起过推荐购的人
		select distinct tir.invite_member_id `会员id` ,'发起过推荐购' `渠道`
		from ods_invi.ods_invi_tm_invite_record_d tir 
		where tir.is_deleted = 0
		and date(tir.create_time) < '2025-04-01'
		and be_invite_member_id is not null
		)x where x.`会员id` is not null 
	)x11 on x11.`会员id`=x.memberid
left join 
	(
	--  有过留资线索的人数
	select distinct x.`会员id`::String `会员id`
	from 
	(	-- 试驾
		select distinct m.id `会员id` ,'留资线索' `渠道`
		from ods_cyap.ods_cyap_tt_appointment_d ta
		left join ods_memb.ods_memb_tc_member_info_cur m on m.member_phone = ta.CUSTOMER_PHONE and m.is_deleted = 0
		where 1=1
		and ta.IS_DELETED = 0
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'  
	 	and ta.CREATED_AT < '2025-04-01'
		union all
		-- 一键留资
		select distinct m.id `会员id` ,'留资线索' `渠道`
		from ods_vced.ods_vced_tm_leads_collection_pool_d tlcp 
		left join ods_memb.ods_memb_tc_member_info_cur m on m.member_phone = tlcp.customer_mobile and m.is_deleted = 0
		where 1=1
		and tlcp.campaign_code in
			(
				select distinct trim(hd.code) code
				from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
				where trim(hd.channel) = '一键留资'
				and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-14'
			)
		and tlcp.create_time >= '2024-01-01'  
	 	and tlcp.create_time < '2025-04-01'
	 	)x where x.`会员id` is not null 
	 )x12 on x12.`会员id`=x.memberid
left join 
	(
	-- 	发起过推荐购的人数
	 --  有过留资线索的人数
	select distinct x.`会员id`::String `会员id`
	from 
	(	-- 发起过推荐购的人
		select distinct tir.invite_member_id `会员id` ,'发起过推荐购' `渠道`
		from ods_invi.ods_invi_tm_invite_record_d tir 
		where tir.is_deleted = 0
		and date(tir.create_time) < '2025-04-01'
		and date(tir.create_time)  >= '2024-01-01'  
	--	and be_invite_member_id is not null
		)x where x.`会员id` is not null 	)x13 on x13.`会员id`=x.memberid
left join 
	(--  参与过推荐购
	select distinct x.`参与过推荐购id`::String `会员id`
	from 
	(
	select
	distinct r.invite_member_id  `参与过推荐购id`
	from ods_invi.ods_invi_tm_invite_record_d r
	where r.is_deleted = 0
	and date(r.create_time) >= '2024-01-01' 
	and date(r.create_time) < '2025-04-01' -- 季度初
	union all 
	select distinct be_invite_member_id  `参与过推荐购id`
	from ods_invi.ods_invi_tm_invite_record_d r
	where r.is_deleted = 0
	and date(r.create_time) >= '2024-01-01' 
	and date(r.create_time) < '2025-04-01' -- 季度初
	)x where x.`参与过推荐购id`  is not null
	)x14 on x14.`会员id`=x.memberid
group by 1 
order by 1 
--settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0

--注册小程序但未注册APP车主总数
select 
--a.id,a.create_time,a.is_vehicle ,b.user,b.min_app,b.min_mini,b.is_vehicle
count(distinct id)
from ods_memb.ods_memb_tc_member_info_cur a
left join ods_oper_crm.ods_oper_crm_usr_gio_d_si b on toString(a.id)=b.memberid 
where 1=1
and min_app is null   -- 剔除未注册APP, 剩余的就是小程序注册
and a.is_vehicle='1'
settings join_use_nulls=1

--过去360天内登录过小程序 过去180天内登录过小程序 过去90天内登录过小程序
select 
count(distinct id)
from ods_memb.ods_memb_tc_member_info_cur a
left join ods_oper_crm.ods_oper_crm_usr_gio_d_si b on toString(a.id)=b.memberid 
where 1=1
and min_app is null   -- 剔除未注册APP, 剩余的就是小程序注册
and a.is_vehicle='1'
--and max_mini>=toDate('2025-04-01') - INTERVAL'360 day' -- 过去360天内登录过小程序
and max_mini>=toDate('2025-04-01') - INTERVAL'180 day' -- 过去180天内登录过小程序
--and max_mini>=toDate('2025-04-01') - INTERVAL'90 day' -- 过去90天内登录过小程序
and max_mini<'2025-04-01'
settings join_use_nulls=1


--25-36个月内回厂记录 13-24个月内有回厂记录 0-12个月内有回厂记录
select count(distinct a.id)
from ods_memb.ods_memb_tc_member_info_cur a
left join ods_oper_crm.ods_oper_crm_usr_gio_d_si b on toString(a.id)=b.memberid 
join 
(
--25-36个月内回厂记录
		select
		distinct tmi.id id
		from ods_cyre.ods_cyre_tt_repair_order_d o
		left join ods_cyre.ods_cyre_tm_owner_d oc on o.OWNER_NO =oc.OWNER_NO and o.OWNER_CODE =oc.OWNER_CODE 
		left join 
			(select tmi.id
			,tmi.cust_id
			,row_number()over(partition by tmi.cust_id order by tmi.create_time desc) rk 
			from ods_memb.ods_memb_tc_member_info_cur tmi
			where tmi.is_deleted =0
			Settings allow_experimental_window_functions = 1
			)tmi on ifnull(o.OWNER_ONE_ID,oc.ONE_ID) = tmi.cust_id and tmi.rk =1
		where o.IS_DELETED = 0
--			and o.REPAIR_TYPE_CODE <> 'P'
		and o.RO_STATUS = '80491003'    -- 已结算工单
--		and o.RO_CREATE_DATE >= toDate('2025-04-01') - INTERVAL'1 year' -- 0-12个月内有回厂记录
--		and o.RO_CREATE_DATE < toDate('2025-04-01') 
--		and o.RO_CREATE_DATE >= toDate('2025-04-01') - INTERVAL'2 year' -- 13-24个月内有回厂记录
--		and o.RO_CREATE_DATE < toDate('2025-04-01') - INTERVAL'1 year'
		and o.RO_CREATE_DATE >= toDate('2025-04-01') - INTERVAL'3 year' -- 25-36个月内回厂记录
		and o.RO_CREATE_DATE < toDate('2025-04-01') - INTERVAL'2 year'
		and tmi.id is not null 
)x on x.id::String = a.id::String 
where 1=1
and min_app is null   -- 剔除未注册APP, 剩余的就是小程序注册
and a.is_vehicle='1'
settings join_use_nulls=1

	-- 全量回厂
		select
		distinct tmi.id id
		from ods_cyre.ods_cyre_tt_repair_order_d o
		left join ods_cyre.ods_cyre_tm_owner_d oc on o.OWNER_NO =oc.OWNER_NO and o.OWNER_CODE =oc.OWNER_CODE 
		left join 
			(select tmi.id
			,tmi.cust_id
			,row_number()over(partition by tmi.cust_id order by tmi.create_time desc) rk 
			from ods_memb.ods_memb_tc_member_info_cur tmi
			where tmi.is_deleted =0
			Settings allow_experimental_window_functions = 1
			)tmi on ifnull(o.OWNER_ONE_ID,oc.ONE_ID) = tmi.cust_id and tmi.rk =1
		where o.IS_DELETED = 0
--			and o.REPAIR_TYPE_CODE <> 'P'
		and o.RO_STATUS = '80491003'    -- 已结算工单
		and o.RO_CREATE_DATE >= '2024-01-01'
		and o.RO_CREATE_DATE < '2025-04-01'
		and tmi.id is not null 

	

--22年（4月-12月汇总）活跃车主  小程序迁移车主数
SELECT count(distinct x.id)
FROM 
	(
	-- mini最早登录时间
	SELECT 
	m.id,
	min(m.date) mdate
	from 
		(
		select m.id::String id,date(t.date) date
		from ods_trac.ods_trac_track_cur t 
		join 
			(-- 清洗cust_id 取其对应的最新信息
			select m.user_id,m.id,m.cust_id,m.is_vehicle 
			from
				(-- 按创建时间取最新,当创建时间相同时,按会员ID取最新
				select m.cust_id,m.id,m.create_time,m.level_id,m.user_id,m.is_vehicle 
				,row_number() over(partition by m.cust_id order by m.create_time desc,m.id desc) rk
				from ods_memb.ods_memb_tc_member_info_cur m
				where m.user_id is not null
				and m.cust_id is not null -- oneid不能空：因基层是全量的oneid
				)m
			where m.rk=1
		)m on t.usertag =m.user_id::varchar
		where date(t.date)>='2016-01-01'
		and date(t.date)<'2023-04-01'
		and m.is_vehicle =1
	--	and t.typeid='XWSJXCX_HOME_V'
		union all 
		select o.memberid::String,date(o.dt)
		from ods_oper_crm.ods_oper_crm_active_gio_d_si o
		join ods_memb.ods_memb_tc_member_info_cur m on m.id::String=o.memberid::String 
		where 1=1
		and o.platform ='Mini'
		and date(o.dt)>= '2022-04-01'
		and date(o.dt)< '2025-04-01'
		and m.is_vehicle ='1' -- chezhu
		and o.memberid is not null 
	)m
	group by 1
	order by 1 
)x 
LEFT JOIN 
	(
	select o.memberid::String memberid,min(date(o.dt)) mdate
	from ods_oper_crm.ods_oper_crm_active_gio_d_si o
	join ods_memb.ods_memb_tc_member_info_cur m on m.id::String=o.memberid::String 
	where 1=1
	and o.platform ='App'
	and date(o.dt)>= '2022-04-01'
	and date(o.dt)< '2025-04-01'
--	and date(o.dt)>= '2023-01-01'
--	and date(o.dt)< '2024-01-01'
	and m.is_vehicle ='1' -- chezhu
	and o.memberid is not null 
	group by 1 
	having min(date(o.dt))>= '2024-01-01'and min(date(o.dt))< '2025-04-01'
	order by 1
)x2 on x.id=x2.memberid
where x.mdate<=x2.mdate


	--推荐人等级变化
	select
	ifnull(x.NEW_LEVEL_ID,tmi.level_id),
	count(distinct r.invite_member_id) 推荐人会员ID
	from invite.tm_invite_record r
	left join 
		(select  x.MEMBER_ID,
		x.NEW_LEVEL_ID
		from 
				(
				select MEMBER_ID 
				,c.OLD_LEVEL_ID 
				,c.NEW_LEVEL_ID 
				,c.EVENT_DESC
				,c.CREATE_TIME 
				,row_number ()over(partition by MEMBER_ID order by c.CREATE_TIME desc) rk 
				from "member".tt_member_level_change c
				where 1=1
				and c.LEVEL_TYPE is not null 
				and c.STATUS =1
				and c.IS_DELETED =0
				--and MEMBER_ID='3301769'
				and c.EVENT_DESC in ('等级降级','等级升级')
				--and c.CREATE_TIME>='2023-07-06'
				and c.CREATE_TIME<'{i}' -- 截至日期
				order by 1 
				)x where x.rk=1
			)x on x.MEMBER_ID=r.invite_member_id
	left join "member".tc_member_info tmi on tmi.id=r.invite_member_id
	where r.is_deleted = 0
	and date(r.create_time) >= '2024-01-01' 
	and date(r.create_time) < '{i}' -- 截至日期
	group by 1 
	order by 1 

 	





