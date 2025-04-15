-- 卡券领用核销明细 售后卡券
select x.*
from 
	(
	select 
	x.coupon_id,
	x.卡券状态,
	concat(x.coupon_id,x.卡券状态),
	--count(case when x.IS_VEHICLE=1 then x.id else null end) 车主,
	--count(case when x.IS_VEHICLE=0 then x.id else null end) 粉丝,
	count(x.id)
	from 
		(
		SELECT 
		a.id,
		a.one_id,
		a.coupon_id,
		tmi.IS_VEHICLE,
		b.id coupon_id卡券ID,
		b.coupon_name 卡券名称,
		a.left_value/100 面额,
		b.coupon_code 券号,
		tmi.ID 沃世界会员ID,
		tmi.MEMBER_NAME 会员昵称,
		tmi.REAL_NAME 姓名,
		tmi.MEMBER_PHONE 沃世界绑定手机号,
	--	a.vin 购买VIN,
		a.get_date 获得时间,
		a.activate_date 激活时间,
		c.associate_vin vin,
		c.associate_dealer 经销商,
		declear_list.company_code 经销商code,
		a.expiration_date 卡券失效日期,
		CAST(a.exchange_code as varchar) 核销码,
	-- 	case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
	--  	WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台类型,
		CASE a.coupon_source 
		  WHEN 83241001 THEN 'VCDC发券'
		  WHEN 83241002 THEN '沃世界领券'
		  WHEN 83241003 THEN '商城购买'
		END AS 卡券来源,
		CASE a.ticket_state
		  WHEN 31061001 THEN '已领用'
		  WHEN 31061002 THEN '已锁定'
		  WHEN 31061003 THEN '已核销' 
		  WHEN 31061004 THEN '已失效'
		  WHEN 31061005 THEN '已作废'
		END AS 卡券状态,
		a.is_refunded 是否退款,
		v.*
		FROM coupon.tt_coupon_detail a 
		JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
		left join 
		(select tmi.*
		,row_number ()over(partition by tmi.cust_id order by tmi.create_time desc ) rk
		from `member`.tc_member_info tmi 
		where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
		)tmi on a.one_id = tmi.CUST_ID and tmi.member_phone <>'*' and tmi.rk=1
		left join "order".tt_order_product c on a.order_code = c.order_code and c.is_deleted <> 1 -- 订单商品表
		left join (
                select company_code,code_name,row_number() over(partition by code_name order by bz) as bz
                from (
                    (select company_code ,company_short_name_cn as code_name,'1' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and STATUS in ('16031002','16031005')and company_short_name_cn is not null )
                    union all 
                    select company_code,official_dealer_name as code_name,'2' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and STATUS in ('16031002','16031005') and official_dealer_name is not null and official_dealer_name<>''
                    )
        ) declear_list
        on declear_list.code_name = c.associate_dealer and declear_list.bz='1'
		LEFT JOIN (
		select v.coupon_detail_id
		,v.customer_name 核销用户名
		,v.customer_mobile 核销手机号
		,v.verify_amount 
		,v.dealer_code 核销经销商
		,v.vin 核销VIN
		,v.operate_date 核销时间
		,v.order_no 订单号
		,v.PLATE_NUMBER
		from coupon.tt_coupon_verify v 
		where  v.is_deleted=0
		order by v.create_time 
		) v ON v.coupon_detail_id = a.id
		WHERE 1=1
		-- b.coupon_name not like '%FIKA%'
		and a.coupon_id in ('4952',
	'5063',
	'4954',
	'4955',
	'4956',
	'4957',
	'4958',
	'4960',
	'4965',
	'4970',
	'4978',
	'4972',
	'4973',
	'4975',
	'4221')
		-- and b.coupon_code='KQ202108310002'
		and a.get_date >= '2023-08-24'
		and a.get_date < '2023-08-25'
		and a.is_deleted=0 
--		and a.id='31437119'
		order by a.get_date desc 
	)x 
	where x.卡券状态='已领用' or x.卡券状态='已核销'or x.卡券状态='已作废'
	group by 1,2
	order by 1,2 desc )x
union all 
--核销率
select x.*
from 
(
select 
x.coupon_id,
x.卡券状态,
concat(x.coupon_id,'核销率'),
count(case when x.卡券状态='已核销'then x.id else null end)/count(x.id) 核销率
--count(case when x.卡券状态='已作废'then x.id else null end)/count(x.id) 退款率
from 
	(
	SELECT 
	a.id,
	a.one_id,
	a.coupon_id,
	tmi.IS_VEHICLE,
	b.id coupon_id卡券ID,
	b.coupon_name 卡券名称,
	a.left_value/100 面额,
	b.coupon_code 券号,
	tmi.ID 沃世界会员ID,
	tmi.MEMBER_NAME 会员昵称,
	tmi.REAL_NAME 姓名,
	tmi.MEMBER_PHONE 沃世界绑定手机号,
--	a.vin 购买VIN,
	a.get_date 获得时间,
	a.activate_date 激活时间,
	c.associate_vin vin,
	c.associate_dealer 经销商,
	declear_list.code_name 经销商code,
	a.expiration_date 卡券失效日期,
	CAST(a.exchange_code as varchar) 核销码,
-- 	case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
--  	WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台类型,
	CASE a.coupon_source 
	  WHEN 83241001 THEN 'VCDC发券'
	  WHEN 83241002 THEN '沃世界领券'
	  WHEN 83241003 THEN '商城购买'
	END AS 卡券来源,
	CASE a.ticket_state
	  WHEN 31061001 THEN '已领用'
	  WHEN 31061002 THEN '已锁定'
	  WHEN 31061003 THEN '已核销' 
	  WHEN 31061004 THEN '已失效'
	  WHEN 31061005 THEN '已作废'
	END AS 卡券状态,
	v.*
	FROM coupon.tt_coupon_detail a 
	JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
	left join 
	(select tmi.*
	,row_number ()over(partition by tmi.cust_id order by tmi.create_time desc ) rk
	from `member`.tc_member_info tmi 
	where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
	)tmi on a.one_id = tmi.CUST_ID and tmi.member_phone <>'*' and tmi.rk=1
	left join "order".tt_order_product c on a.order_code = c.order_code and c.is_deleted <> 1 -- 订单商品表
--	left join organization.tm_company tc on c.associate_dealer =tc.company_short_name_cn and tc.is_deleted <>1 --经销商表
	left join (
                select company_code,code_name,row_number() over(partition by code_name order by bz) as bz
                from (
                    (select company_code ,company_short_name_cn as code_name,'1' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and STATUS in ('16031002','16031005')and company_short_name_cn is not null )
                    union all 
                    select company_code,official_dealer_name as code_name,'2' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and STATUS in ('16031002','16031005') and official_dealer_name is not null and official_dealer_name<>''
                    )
        ) declear_list
        on declear_list.code_name = c.associate_dealer and declear_list.bz='1'
	LEFT JOIN (
	select v.coupon_detail_id
	,v.customer_name 核销用户名
	,v.customer_mobile 核销手机号
	,v.verify_amount 
	,v.dealer_code 核销经销商
	,v.vin 核销VIN
	,v.operate_date 核销时间
	,v.order_no 订单号
	,v.PLATE_NUMBER
	from coupon.tt_coupon_verify v 
	where  v.is_deleted=0
	order by v.create_time 
	) v ON v.coupon_detail_id = a.id
	WHERE 1=1
	-- b.coupon_name not like '%FIKA%'
	and a.coupon_id in ('4952',
'5063',
'4954',
'4955',
'4956',
'4957',
'4958',
'4960',
'4965',
'4970',
'4978',
'4972',
'4973',
'4975',
'4221')
	-- and b.coupon_code='KQ202108310002'
	and a.get_date >= '2023-08-24'
	and a.get_date < '2023-08-25'
	and a.is_deleted=0 
	order by a.get_date desc 
)x 
where x.卡券状态='已领用' or x.卡券状态='已核销'or x.卡券状态='已作废'
group by 1
order by 1)x
union all 
--核销率
select 
x.coupon_id,
x.卡券状态,
concat(x.coupon_id,'退款率'),
--count(case when x.卡券状态='已核销'then x.id else null end)/count(x.id) 核销率,
count(case when x.卡券状态='已作废'then x.id else null end)/count(x.id) 退款率
from 
	(
	SELECT 
	a.id,
	a.one_id,
	a.coupon_id,
	tmi.IS_VEHICLE,
	b.id coupon_id卡券ID,
	b.coupon_name 卡券名称,
	a.left_value/100 面额,
	b.coupon_code 券号,
	tmi.ID 沃世界会员ID,
	tmi.MEMBER_NAME 会员昵称,
	tmi.REAL_NAME 姓名,
	tmi.MEMBER_PHONE 沃世界绑定手机号,
--	a.vin 购买VIN,
	a.get_date 获得时间,
	a.activate_date 激活时间,
	c.associate_vin vin,
	c.associate_dealer 经销商,
	declear_list.code_name 经销商code,
	a.expiration_date 卡券失效日期,
	CAST(a.exchange_code as varchar) 核销码,
-- 	case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
--  	WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台类型,
	CASE a.coupon_source 
	  WHEN 83241001 THEN 'VCDC发券'
	  WHEN 83241002 THEN '沃世界领券'
	  WHEN 83241003 THEN '商城购买'
	END AS 卡券来源,
	CASE a.ticket_state
	  WHEN 31061001 THEN '已领用'
	  WHEN 31061002 THEN '已锁定'
	  WHEN 31061003 THEN '已核销' 
	  WHEN 31061004 THEN '已失效'
	  WHEN 31061005 THEN '已作废'
	END AS 卡券状态,
	v.*
	FROM coupon.tt_coupon_detail a 
	JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
	left join 
	(select tmi.*
	,row_number ()over(partition by tmi.cust_id order by tmi.create_time desc ) rk
	from `member`.tc_member_info tmi 
	where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
	)tmi on a.one_id = tmi.CUST_ID and tmi.member_phone <>'*' and tmi.rk=1
	left join "order".tt_order_product c on a.order_code = c.order_code and c.is_deleted <> 1 -- 订单商品表
--	left join organization.tm_company tc on c.associate_dealer =tc.company_short_name_cn and tc.is_deleted <>1 --经销商表
	left join (
                select company_code,code_name,row_number() over(partition by code_name order by bz) as bz
                from (
                    (select company_code ,company_short_name_cn as code_name,'1' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and STATUS in ('16031002','16031005')and company_short_name_cn is not null )
                    union all 
                    select company_code,official_dealer_name as code_name,'2' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and STATUS in ('16031002','16031005') and official_dealer_name is not null and official_dealer_name<>''
                    )
        ) declear_list
        on declear_list.code_name = c.associate_dealer and declear_list.bz='1'
	LEFT JOIN (
	select v.coupon_detail_id
	,v.customer_name 核销用户名
	,v.customer_mobile 核销手机号
	,v.verify_amount 
	,v.dealer_code 核销经销商
	,v.vin 核销VIN
	,v.operate_date 核销时间
	,v.order_no 订单号
	,v.PLATE_NUMBER
	from coupon.tt_coupon_verify v 
	where  v.is_deleted=0
	order by v.create_time 
	) v ON v.coupon_detail_id = a.id
	WHERE 1=1
	-- b.coupon_name not like '%FIKA%'
	and a.coupon_id in ('4952',
'5063',
'4954',
'4955',
'4956',
'4957',
'4958',
'4960',
'4965',
'4970',
'4978',
'4972',
'4973',
'4975',
'4221')
	-- and b.coupon_code='KQ202108310002'
	and a.get_date >= '2023-08-24'
	and a.get_date < '2023-08-25'
	and a.is_deleted=0 
	order by a.get_date desc 
)x 
where x.卡券状态='已领用' or x.卡券状态='已核销'or x.卡券状态='已作废'
group by 1
order by 1

-- 明细
	SELECT 
	distinct 
	a.id,
--	a.order_code ,
	a.one_id,
	a.coupon_id,
	tmi.IS_VEHICLE,
	b.id coupon_id卡券ID,
	b.coupon_name 卡券名称,
	a.left_value/100 面额,
	b.coupon_code 券号,
	tmi.ID 沃世界会员ID,
	tmi.MEMBER_NAME 会员昵称,
	tmi.REAL_NAME 姓名,
	tmi.MEMBER_PHONE 沃世界绑定手机号,
--	a.vin 购买VIN,
	a.get_date 获得时间,
	a.activate_date 激活时间,
	c.associate_vin vin,
	c.associate_dealer 经销商,
	declear_list.company_code 经销商code,
	a.expiration_date 卡券失效日期,
	CAST(a.exchange_code as varchar) 核销码,
-- 	case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
--  	WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台类型,
	CASE a.coupon_source 
	  WHEN 83241001 THEN 'VCDC发券'
	  WHEN 83241002 THEN '沃世界领券'
	  WHEN 83241003 THEN '商城购买'
	END AS 卡券来源,
	CASE a.ticket_state
	  WHEN 31061001 THEN '已领用'
	  WHEN 31061002 THEN '已锁定'
	  WHEN 31061003 THEN '已核销' 
	  WHEN 31061004 THEN '已失效'
	  WHEN 31061005 THEN '已作废'
	END AS 卡券状态,
	v.*
	FROM coupon.tt_coupon_detail a 
	JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
	left join 
		(select tmi.*
		,row_number ()over(partition by tmi.cust_id order by tmi.create_time desc ) rk
		from `member`.tc_member_info tmi 
		where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
		)tmi on a.one_id = tmi.CUST_ID and tmi.member_phone <>'*' and tmi.rk=1
	left join "order".tt_order_product c on a.order_code = c.order_code and c.is_deleted <> 1 -- 订单商品表
	left join (
                select company_code,code_name,row_number() over(partition by code_name order by bz) as bz
                from (
                    (select company_code ,company_short_name_cn as code_name,'1' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and STATUS in ('16031002','16031005')and company_short_name_cn is not null )
                    union all 
                    select company_code,official_dealer_name as code_name,'2' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and STATUS in ('16031002','16031005') and official_dealer_name is not null and official_dealer_name<>''
                    )x 
        ) declear_list on declear_list.code_name = c.associate_dealer and declear_list.bz=1
	LEFT JOIN (
	select v.coupon_detail_id
	,v.customer_name 核销用户名
	,v.customer_mobile 核销手机号
	,v.verify_amount 
	,v.dealer_code 核销经销商
	,v.vin 核销VIN
	,v.operate_date 核销时间
	,v.order_no 订单号
	,v.PLATE_NUMBER
	from coupon.tt_coupon_verify v 
	where  v.is_deleted=0
	order by v.create_time 
	) v ON v.coupon_detail_id = a.id
	WHERE 1=1
	and a.coupon_id in ('4952',
	'5063',
	'4954',
	'4955',
	'4956',
	'4957',
	'4958',
	'4960',
	'4965',
	'4970',
	'4978',
	'4972',
	'4973',
	'4975',
	'4221')
	-- and b.coupon_code='KQ202108310002'
	and a.get_date >= '2023-07-25'
	and a.get_date < '2023-08-25'
	and a.is_deleted=0 
--	and a.id='314352'
	order by a.get_date desc 

