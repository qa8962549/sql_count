-- 整体数据
-- 525活动PV UV  
select
date_format(t.date,'%Y-%m-%d'),
case when json_extract_path_text(cast(data as json)::json,'tcode')='8A0765D212E24AA4B3C5135B7D376FC4' then '小程序-置顶Banner' 
when json_extract_path_text(data::json,'tcode')='3F9D3159D19142AEBFBAF1320C561E86' then '小程序-商城banner' 
when json_extract_path_text(data::json,'tcode')='BAB9DA6818364949A822DC4C35B65555' then '小程序-弹窗' 
else null end 分类,
count(t.usertag) PV,
count(distinct t.usertag) UV,
--count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
--count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2023-05-05'   -- 每天修改起始时间
and t.`date` <curdate()  -- 每天修改截止时间
group by 1,2
order by 1 desc ,2



-- 525PV UV  总
select
case when json_extract_path_text(data::json,'tcode')='8A0765D212E24AA4B3C5135B7D376FC4' then '小程序-置顶Banner' 
when json_extract_path_text(data::json,'tcode')='3F9D3159D19142AEBFBAF1320C561E86' then '小程序-商城banner' 
when json_extract_path_text(data::json,'tcode')='BAB9DA6818364949A822DC4C35B65555' then '小程序-弹窗' 
else null end 分类,
count(t.usertag) PV,
count(distinct t.usertag) UV,
--count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
--count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2023-05-05'   -- 每天修改起始时间
and t.`date` <'2023-05-25' -- 每天修改截止时间
group by 1
order by 1

-- 卡券领用核销明细 商城精品-优惠券
select 
x.coupon_id,
x.卡券状态,
count(case when x.IS_VEHICLE=1 then x.id else null end) 车主,
count(case when x.IS_VEHICLE=0 then x.id else null end) 粉丝,
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
	a.vin 购买VIN,
	a.get_date 获得时间,
	a.activate_date 激活时间,
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
	and a.coupon_id in ('4643','4645','4646')
	-- and b.coupon_code='KQ202108310002'
	and a.get_date >= '2023-05-25'
	and a.get_date < '2023-05-26'
	and a.is_deleted=0 
	order by a.get_date desc 
)x 
where x.卡券状态='已领用' or x.卡券状态='已核销'
group by 1,2
order by 1,2 desc 

-- 卡券领用核销明细 商城精品-优惠券 总
select 
x.coupon_id,
x.卡券状态,
count(case when x.IS_VEHICLE=1 then x.id else null end) 车主,
count(case when x.IS_VEHICLE=0 then x.id else null end) 粉丝,
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
	a.vin 购买VIN,
	a.get_date 获得时间,
	a.activate_date 激活时间,
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
	and a.coupon_id in ('4643','4645','4646')
	-- and b.coupon_code='KQ202108310002'
	and a.get_date >= '2023-05-05'
	and a.get_date < curdate() 
	and a.is_deleted=0 
	order by a.get_date desc 
)x 
where x.卡券状态='已领用' or x.卡券状态='已核销'
group by 1,2
order by 1,2 desc 

-- 卡券领用核销明细 渠道说明
select 
-- x.IS_VEHICLE,
x.coupon_id,
x.卡券状态,
count(case when x.IS_VEHICLE=1 then x.id else null end) 车主,
count(case when x.IS_VEHICLE=0 then x.id else null end) 粉丝,
count(x.id)
from 
	(
	SELECT 
	a.id,
	a.one_id,
	a.coupon_id ,
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
	and a.coupon_id in ('4648','4649')
	-- and b.coupon_code='KQ202108310002'
	and a.get_date >= '2023-05-25'
	and a.get_date < '2023-05-26'
	and a.is_deleted=0 
	order by a.get_date desc 
)x 
where x.卡券状态='已领用' or x.卡券状态='已核销'
group by 1,2
order by 1,2 desc 

-- 卡券领用核销明细 渠道说明 总
select  
-- x.IS_VEHICLE,
x.coupon_id,
x.卡券状态,
count(case when x.IS_VEHICLE=1 then x.id else null end) 车主,
count(case when x.IS_VEHICLE=0 then x.id else null end) 粉丝,
count(x.id)
from 
	(
	SELECT 
	a.id,
	a.one_id,
	a.coupon_id ,
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
	left join "order".tt_order_product c on a.order_code = c.order_code and c.is_deleted <> 1 -- 订单商品表
	left join 
	(select tmi.*
	,row_number ()over(partition by tmi.cust_id order by tmi.create_time desc ) rk
	from `member`.tc_member_info tmi 
	where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
	)tmi on a.one_id = tmi.CUST_ID and tmi.member_phone <>'*' and tmi.rk=1
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
	and a.coupon_id in ('4648','4649')
	-- and b.coupon_code='KQ202108310002'
	and a.get_date >= '2023-05-05'
	and a.get_date < curdate() 
	and a.is_deleted=0 
	order by a.get_date desc 
)x 
where x.卡券状态='已领用' or x.卡券状态='已核销'
group by 1,2
order by 1,2 desc 

-- 卡券领用核销明细 售后卡券
select 
x.coupon_id,
x.卡券状态,
concat(x.coupon_id,x.卡券状态),
count(case when x.IS_VEHICLE=1 then x.id else null end) 车主,
count(case when x.IS_VEHICLE=0 then x.id else null end) 粉丝,
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
	tc.company_code 经销商code,
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
	left join organization.tm_company tc on c.associate_dealer =tc.company_short_name_cn and tc.is_deleted <>1 --经销商表
--	left join "order".tt_order c on a.order_code=c.order_code 
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
	and a.coupon_id in ('4657','4658','4659','4660','4661','4662','4663','4664','4665')
	-- and b.coupon_code='KQ202108310002'
	and a.get_date >= '2023-05-25'
	and a.get_date < '2023-05-26'
	and a.is_deleted=0 
	order by a.get_date desc 
)x 
where x.卡券状态='已领用' or x.卡券状态='已核销'
group by 1,2
order by 1,2 desc 

-- 卡券领用核销明细 售后卡券 总
select 
x.coupon_id,
x.卡券状态,
concat(x.coupon_id,x.卡券状态),
-- count(case when x.IS_VEHICLE=1 then x.id else null end) 车主,
-- count(case when x.IS_VEHICLE=0 then x.id else null end) 粉丝,
count(x.id)
from 
	(
	SELECT 
	distinct 
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
	tc.company_code 经销商code,
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
	left join organization.tm_company tc on c.associate_dealer =tc.company_short_name_cn and tc.is_deleted <>1 --经销商表
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
	and a.coupon_id in ('4657','4658','4659','4660','4661','4662','4663','4664','4665')
--	and a.coupon_id ='4659'
	and a.get_date >= '2023-05-05'
	and a.get_date < curdate() 
	and a.is_deleted=0 
	order by a.get_date desc 
)x 
where x.卡券状态='已领用' or x.卡券状态='已核销'
group by 1,2
order by 1,2 desc 

-- 售后卡券明细 1874
select distinct x.one_id
from 
(
	SELECT 
	distinct 
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
	ifnull(c.associate_vin,a.vin) vin,
	ifnull(c.associate_dealer,sao.dealer_name) 经销商,
	ifnull(tc.company_code,sao.dealer_code) 经销商code,
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
	left join "order".tt_order_product c on a.order_code = c.order_code and c.is_deleted <> 1 -- 订单商品表
	left join 
	(select tmi.*
	,row_number ()over(partition by tmi.cust_id order by tmi.create_time desc ) rk
	from `member`.tc_member_info tmi 
	where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
	)tmi on a.one_id = tmi.CUST_ID and tmi.member_phone <>'*' and tmi.rk=1
	left join organization.tm_company tc on c.associate_dealer =tc.company_short_name_cn and tc.is_deleted <>1 --经销商表
	left join volvo_online_activity.season_activity_order sao on sao.vin =a.vin and sao.coupon_id ='4657'
	and sao.create_date =a.create_time 
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
--	and a.coupon_id in ('4657')
	and a.coupon_id in ('4657','4658','4659','4660','4661','4662','4663','4664','4665')
	-- and b.coupon_code='KQ202108310002'
	and a.get_date >= '2023-05-05'
	and a.get_date <curdate() 
	and a.is_deleted=0 
--	and sao.delete_flag <>'1'
	order by a.get_date desc 
)x
	


-- 销售概览
select 
m.平台,
SUM(case when m.商品类型2='保养类卡券' then m.总金额 else null end) "售后（元）",
SUM(case when m.商品类型2='充电产品' then m.总金额 else null end) "充电（元）",
SUM(case when m.商品类型2='精品' then m.总金额 else null end) "精品（元）",
SUM(case when m.商品类型2='第三方卡券' then m.总金额 else null end) "第三方卡券（元）",
SUM(m.支付V值) V值消耗,
-- sum(m.总金额) 商城销售额,
-- 	count(distinct m.订单编号) 商城订单数,
count(distinct m.会员ID)下单用户数,
round((sum(m.总金额)/count(distinct m.会员ID)),1)/round((sum(m.兑换数量)/count(distinct m.会员ID)),1) "客单价/客单件数"
-- sum(m.现金支付金额) 现金,
-- sum(m.兑换数量) 总件数
from 
(select a.order_code 订单编号
,b.product_id 商城兑换id
,a.user_id 会员id
,a.user_name 会员姓名
,b.spu_name 兑换商品
,b.spu_id
,b.sku_id
,b.spu_bus_id
,b.sku_code
,b.sku_real_point 商品单价
,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
 WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台
,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券' 
	WHEN 51121003 THEN '保养类卡券' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
,CASE  
	WHEN b.spu_type=51121001 THEN '精品' 
	WHEN b.spu_type=51121002 THEN '第三方卡券' 
	WHEN b.spu_type=51121003 and f.name not like '%充电%' THEN '保养类卡券' 
	WHEN f.name like '%充电%' THEN '充电产品' 
	WHEN b.spu_type=51121004 THEN '精品'
	WHEN b.spu_type=51121006 THEN '一件代发'
	WHEN b.spu_type=51121007 THEN '经销商端产品' ELSE null end 商品类型2
,b.fee/100 总金额
,b.coupon_fee/100 优惠券抵扣金额
,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,a.create_time 兑换时间
,case when b.pay_fee=0 then '纯V值支付' when b.point_amount=0 then '纯现金支付' else '混合支付' end 支付方式
,f.name 分类
,CASE b.spu_type 
	WHEN 51121001 THEN 'VOLVO仓商品' 
	WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
	WHEN 51121003 THEN '虚拟服务卡券' 
	WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
,CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
END AS 商品状态
,CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
END AS 订单状态
,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 关闭原因
,e.`退货状态`
,e.`退货数量`
,e.退回V值
,e.退回时间
from "order".tt_order a  -- 订单主表
left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
left join(
--	#V值退款成功记录
	select so.order_code,sp.product_id
	,CASE so.status 
		WHEN 51171001 THEN '待审核' 
		WHEN 51171002 THEN '待退货入库' 
		WHEN 51171003 THEN '待退款' 
		WHEN 51171004 THEN '退款成功' 
		WHEN 51171005 THEN '退款失败' 
		WHEN 51171006 THEN '作废退货单' END AS 退货状态
	,sum(sp.sales_return_num) 退货数量
	,sum(so.refund_point) 退回V值
	,max(so.create_time) 退回时间
	from `order`.tt_sales_return_order so
	left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
	where so.is_deleted = 0 
	and so.status=51171004 -- 退款成功
	GROUP BY 1,2,3
) e on a.order_code = e.order_code and b.product_id =e.product_id 
--and e.退货状态='退款成功' 
where a.create_time >= '2023-05-05' and a.create_time <= '2023-05-25 23:59:59'   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
order by a.create_time) m
--group by 1 
--order by 1 

-- GMV
select b.订单来源,SUM(b.总金额) 月均销售额 from
(
	select
	DATE_FORMAT(a.兑换时间,'%Y-%m') 年月,
	a.订单来源,
	SUM(a.总金额) 总金额
	from
	(
		select a.order_code 订单编号
		,ifnull(a.parent_order_code,a.order_code) 母单号
		,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
			WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
			else null end 订单来源
		,a.user_id 会员表中id
		,a.user_name 会员姓名
		,a.user_phone 会员手机号
		,a.receiver_name 收货姓名
		,a.receiver_phone 收货手机号
		,concat (
				ifnull ( a.receiver_province_name, '' ),
				ifnull ( a.receiver_city_name, '' ),
				ifnull ( a.receiver_district_name, '' ),
				ifnull ( a.receiver_address, '' ) 
		) AS 收货地址
		,b.sku_code 商品货号
		,b.spu_name 兑换商品
		,b.sku_id
		,b.sku_real_point 商品单价
		,sk.cls12 DN价
		,j.front_category_id
		,f.`name` 前台分类
		,CASE b.spu_type 
			WHEN 51121001 THEN '精品' 
			WHEN 51121002 THEN '第三方卡券' 
			WHEN 51121003 THEN '保养类卡券' 
			WHEN 51121004 THEN '精品'
			WHEN 51121006 THEN '一件代发'
			WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
		,b.fee/100 总金额
		,b.sku_total_fee/ 100 商品金额
		,b.express_fee/ 100 运费金额
		,b.coupon_fee/100 优惠券抵扣金额
		,b.pay_fee/100 现金支付金额
		,b.point_amount 支付V值
		,b.sku_num 兑换数量
		,CASE b.spu_type 
			WHEN 51121001 THEN 'VOLVO仓商品' 
			WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
			WHEN 51121003 THEN '虚拟服务卡券' 
			WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
		,CASE a.status
				WHEN 51031002 THEN '待付款' 
				WHEN 51031003 THEN '待发货' 
				WHEN 51031004 THEN '待收货' 
				WHEN 51031005 THEN '已完成'
				WHEN 51031006 THEN '已关闭'  
		END AS 订单状态
		,CASE b.status
				WHEN 51301001 THEN '待付款' 
				WHEN 51301002 THEN '待发货' 
				WHEN 51301003 THEN '待收货' 
				WHEN 51301004 THEN '收货确认'
				WHEN 51301005 THEN '退货中'
				WHEN 51301006 THEN '交易关闭'  
		END AS 订单商品状态
		,a.create_time 兑换时间
		,a.pay_time 支付时间
		,b.product_id 商城兑换id
		,e.`退货状态`
		,e.退回时间
		,e.退回V值
		,e.`退货数量`
		,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 退货原因
		,e.refund_express_code 退货物流单号
		,e.eclp_rtw_no 京东退货单号
		,d.delivery_status,d.express_company 快递公司,d.express_code 快递单号
		from "order".tt_order a  -- 订单主表
		left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		-- LEFT JOIN ORDER.tt_order_delivery d ON a.order_code = d.order_code AND d.is_deleted <> 1
		left join (
			select d.* 
			from (
			select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
			,row_number() over(partition by d.order_code order by d.create_time desc) rk
			from `order`.tt_order_delivery d 
			where d.is_deleted=0
			) d where d.rk=1
		) d ON a.order_code = d.order_code
		left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
		left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
		left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
		LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
		left join goods.spu p on b.spu_bus_id=p.bus_id
		left join goods.exchange_type ty on p.exchange_type_id=ty.exchange_type_id
		left join(
			SELECT a.*,b.refund_express_code,b.eclp_rtw_no
			from (
			select so.refund_order_code,so.order_code,sp.product_id
			,CASE so.status 
				WHEN 51171001 THEN '待审核' 
				WHEN 51171002 THEN '待退货入库' 
				WHEN 51171003 THEN '待退款' 
				WHEN 51171004 THEN '退款成功' 
				WHEN 51171005 THEN '退款失败' 
				WHEN 51171006 THEN '作废退货单' END AS 退货状态
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4) a
			left join `order`.tt_sales_return_order b on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		where a.create_time >= '2023-04-05' and a.create_time <= '2023-04-25 23:59:59'
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		-- and e.order_code is null  -- 剔除退款订单
		order by a.create_time
	) a 
	group by 1,2
	order by 1
) b
group by 1


-- 2023 525车主节活动数据

select * from track.track t where t.usertag = '5537985' and t.date >= '2023-05-11' order by t."date" desc

-- 7、【售后】养修预约，取4.5 ~ 4.25全量数据 + 5.5 ~ 5.25每日数据，活动结束后取5.5 ~ 5.25全量数据

-- 最终逻辑： 点击过btn的人，在养修预约中只要存在，就认为这个人参加过525车主节活动。
1、小程序端：525车主节活动-回厂养护-一键养修btn
2、APP端：525车主节活动-售后聚惠-一键养修btn
3、APP端：525车主节活动-回厂养护-一键养修btn

select
CAST(tam.MAINTAIN_ID as VARCHAR) 养修预约ID,
ta.APPOINTMENT_ID 预约ID,
ta.OWNER_CODE 经销商代码,
tc2.COMPANY_NAME_CN 经销商名称,
ta.ONE_ID 车主oneid,
ta.CUSTOMER_NAME 联系人姓名,
ta.CUSTOMER_PHONE 联系人手机号,
tam.CAR_MODEL 预约车型,
tam.CAR_STYLE 预约车款,
tam.VIN 车架号,
case when tam.IS_TAKE_CAR = 10041001 then '是'
	when tam.IS_TAKE_CAR = 10041002 then '否' 
	end  是否取车,
case when tam.IS_GIVE_CAR = 10041001 then '是'
	when tam.IS_GIVE_CAR = 10041002 then '否'
    end 是否送车,
tc.CODE_CN_DESC 养修状态,
tam.CREATED_AT 创建时间,
tam.UPDATED_AT 修改时间,
ta.CREATED_AT 预约时间,
tam.WORK_ORDER_NUMBER 工单号
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
where ta.CREATED_AT >= '2022-05-23'   -- 时间
and ta.CREATED_AT < '2022-06-01'
and ta.DATA_SOURCE = 'C'
and ta.APPOINTMENT_TYPE = '70691005'   -- 养修预约
-- and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')    -- 筛选预约状态为：有效，即实际到店


-- 8、【预约试驾】，取4.5 ~ 4.25地球日全量数据 + 5.5 ~ 5.25每日数据，活动结束后取5.5 ~ 5.25全量数据

-- 地球日活动数据
select a.预约车型,COUNT(1)预约数 from
(
	SELECT
	DISTINCT ta.APPOINTMENT_ID 预约ID,
	ta.CREATED_AT 预约时间,
	ta.ARRIVAL_DATE 实际到店日期,
	ca.active_name 活动名称,
	ta.one_id 客户ID,
	ta.customer_name 姓名,
	ta.customer_phone 手机号,
	tm2.MODEL_NAME 预约车型,
	h.大区,
	h.小区,
	ta.OWNER_CODE 经销商,
	CASE tad.status
		WHEN 70711001 THEN '待试驾'
	    WHEN 70711002 THEN '已试驾' 
	    WHEN 70711003 THEN '已取消'
	    END 试驾状态,
	tad.drive_s_at 试驾开始时间,
	tad.drive_e_at 试驾结束时间
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
	LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	LEFT JOIN cyxdms_retail.tt_sales_orders tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID
	LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
	LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS
	LEFT JOIN (
	    select 
	        DISTINCT
	        tm.COMPANY_CODE,
	        tg2.ORG_NAME 大区,
	        tg1.ORG_NAME 小区
	    from organization.tm_company tm
	    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
	    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
	    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	    ORDER BY tm.COMPANY_CODE ASC) h on h.COMPANY_CODE = ta.owner_code
	left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID and tm2.IS_DELETED = 0
	WHERE ta.CREATED_AT >= '2023-04-05'
	AND ta.CREATED_AT <= '2023-04-25 23:59:59'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ca.active_code = 'IBDMMARXC4C40XCX2023VCCN'   -- 地球日市场活动代码
	order by ta.CREATED_AT
) a
group by 1
order by 2 desc


-- 地球日活动下单情况
select b.车型,COUNT(1)订单数 from
(
	select 
	    a.SO_NO_ID 销售订单ID,
	    a.SO_NO 销售订单号,
	    a.COMPANY_CODE 公司代码,
	    a.OWNER_CODE 经销商代码,
	    a.CREATED_AT 订单日期,
	    a.SHEET_CREATE_DATE 开单日期,
	    cast(a.CUSTOMER_BUSINESS_ID as varchar) 商机id ,
	    a.CUSTOMER_NAME 客户姓名,
	    a.DRAWER_NAME 开票人姓名,
	    a.CONTACT_NAME 联系人姓名,
	    a.CUSTOMER_TEL 潜客电话,
	    a.DRAWER_TEL 开票人电话,
	    a.PURCHASE_PHONE 下单人手机号,
	    g.CODE_CN_DESC 订单状态,
	    case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
	    a.CUSTOMER_ACTIVITY_ID 活动代码id,
	    c.CLUE_NAME 来源渠道,
	    b.active_code 市场活动代码,
	    b.active_name 市场活动名称,
	    d.SALES_VIN 车架号,
	    f.model_name 车型
	from cyxdms_retail.tt_sales_orders a 
	left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
	left join customer_business.tm_clue_source c on c.ID = b.active_channel
	left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
	left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
	left join basic_data.tm_model f on f.id = e.SECOND_ID
	left join dictionary.tc_code g on g.code_id = a.SO_STATUS
	left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
	left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
	left join dictionary.tc_code k on k.code_id = a.GENDER
	left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
	left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
	left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
	where a.BUSINESS_TYPE<>14031002
	and a.IS_DELETED = 0
	and a.CREATED_AT BETWEEN '2023-04-05' AND '2023-04-25 23:59:59'
	and b.active_code = 'IBDMMARXC4C40XCX2023VCCN'   -- 地球日活动下单情况
	order by a.CREATED_AT
) b
group by 1



-- 525车主节预约试驾明细,记得根据车型分类。
APP端，使用APP预约试驾全量数据和525车主节预约试驾btn的人进行关联，取APPP端525车主节预约试驾的人数和预约试驾明细

SELECT
DISTINCT ta.APPOINTMENT_ID 预约ID,
case when ca.active_code = 'IBDMAPR525YYSAPP2023VCCN' then 'APP'
	when ca.active_code = 'IBDMAPR525YYSXCX2023VCCN' then '小程序'
	else null end 来源渠道,
tm2.MODEL_NAME 预约车型,
ta.CREATED_AT 预约时间,
ta.ARRIVAL_DATE 实际到店日期,
ca.active_code 市场活动Code,
ca.active_name 活动名称,
ta.one_id 客户One_ID,
ta.customer_name 姓名,
ta.customer_phone 手机号,
h.大区,
h.小区,
ta.OWNER_CODE 经销商,
h.经销商名称,
CASE tad.status
	WHEN 70711001 THEN '待试驾'
    WHEN 70711002 THEN '已试驾' 
    WHEN 70711003 THEN '已取消'
    END 试驾状态,
tad.drive_s_at 试驾开始时间,
tad.drive_e_at 试驾结束时间
FROM cyx_appointment.tt_appointment ta
LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
LEFT JOIN cyxdms_retail.tt_sales_orders tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID
LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS
LEFT JOIN (
    select 
        DISTINCT
        tm.COMPANY_CODE,
        tm.COMPANY_NAME_CN 经销商名称,
        tg2.ORG_NAME 大区,
        tg1.ORG_NAME 小区
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
    ORDER BY tm.COMPANY_CODE ASC) h on h.COMPANY_CODE = ta.owner_code
left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID and tm2.IS_DELETED = 0
WHERE ta.CREATED_AT >= '2023-05-05'
AND ta.CREATED_AT < curdate()
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
-- and ca.active_code in ('IBDMAPR525YYSAPP2023VCCN','IBDMAPR525YYSXCX2023VCCN')   -- 525车主节APP/小程序市场活动代码
order by ta.CREATED_AT



-- 525车主节活动下单情况,分别用潜客手机号、下单手机号、开票手机号匹配一下用户的手机号，看看有多少人是匹配上订单的。
select 
a.SO_NO_ID 销售订单ID,
a.SO_NO 销售订单号,
a.COMPANY_CODE 公司代码,
a.OWNER_CODE 经销商代码,
a.CREATED_AT 订单日期,
a.SHEET_CREATE_DATE 开单日期,
cast(a.CUSTOMER_BUSINESS_ID as varchar) 商机id ,
a.CUSTOMER_NAME 客户姓名,
a.DRAWER_NAME 开票人姓名,
a.CONTACT_NAME 联系人姓名,
a.CUSTOMER_TEL 潜客电话,
a.DRAWER_TEL 开票人电话,
a.PURCHASE_PHONE 下单人手机号,
g.CODE_CN_DESC 订单状态,
case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
    a.CUSTOMER_ACTIVITY_ID 活动代码id,
    c.CLUE_NAME 来源渠道,
    b.active_code 市场活动代码,
    b.active_name 市场活动名称,
    d.SALES_VIN 车架号,
    f.model_name 车型
from cyxdms_retail.tt_sales_orders a 
left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
left join customer_business.tm_clue_source c on c.ID = b.active_channel
left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
left join basic_data.tm_model f on f.id = e.SECOND_ID
left join dictionary.tc_code g on g.code_id = a.SO_STATUS
left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
left join dictionary.tc_code k on k.code_id = a.GENDER
left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
where a.BUSINESS_TYPE<>14031002
and a.IS_DELETED = 0
and a.CREATED_AT BETWEEN '2023-05-05' AND curdate() 
and b.active_code in ('IBDMAPR525YYSAPP2023VCCN','IBDMAPR525YYSXCX2023VCCN')   -- 525车主节APP/小程序市场活动代码
order by a.CREATED_AT




-- 9-1、【App】口碑发帖，5.5 ~ 5.25每日数据

-- 话题ID
select
l.topic_id 话题ID,
l.post_id 文章ID
from community.tr_topic_post_link l
where l.is_deleted = 0



-- 口碑发帖明细
select
l.topic_id 话题ID,
a.post_id 内容ID,
a.member_id 会员ID,
tmi.MEMBER_NAME 昵称,
a.create_time 发帖日期,
a.post_digest 发帖内容,
(length(a.post_digest)-CHAR_LENGTH(a.post_digest))/2 发帖字数,
case when a.cover_images is not null then '有图片'
	when a.cover_images is null then '无图片'
	else null end 是否有图片,
case when tmi.member_sex = '10021001' then '先生' when tmi.member_sex = '10021002' then '女士' else '未知' end 性别,
tmi.REAL_NAME 姓名,
tmi.MEMBER_PHONE 沃世界注册手机号码,
case when tmi.IS_VEHICLE = '1' then '车主' when tmi.IS_VEHICLE = '0' then '粉丝' end 是否车主,
a.read_count 浏览量,
a.like_count 点赞数,
b.tt 评论数,
a.collect_count 收藏量
from community.tm_post a
left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join 
(
	select b.post_id,
	count(1) tt
	from community.tm_comment b 
	where b.is_deleted =0
	and b.create_time >='2023-05-05'
	and b.create_time < curdate() 
	group by 1
) b on b.post_id =a.post_id
where a.is_deleted =0
and l.topic_id in ('SQ8AUSctqT','3zO2Ml2xBJ','f5uejeof7L')    -- 沃的用车笔记、一日车评人、ENJOY VOLVO LIFE
and a.create_time >='2023-05-05'
and a.create_time < curdate() 
order by a.create_time


-- 9-2【App】UGC发帖
-- 发帖明细
select
l.topic_id 话题ID,
a.post_id 内容ID,
a.member_id 会员ID,
tmi.MEMBER_NAME 昵称,
a.create_time 发帖日期,
a.post_digest 发帖内容,
(length(a.post_digest)-CHAR_LENGTH(a.post_digest))/2 发帖字数,
case when a.cover_images is not null then '有图片'
	when a.cover_images is null then '无图片'
	else null end 是否有图片,
case when tmi.member_sex = '10021001' then '先生' when tmi.member_sex = '10021002' then '女士' else '未知' end 性别,
tmi.REAL_NAME 姓名,
tmi.MEMBER_PHONE 沃世界注册手机号码,
case when tmi.IS_VEHICLE = '1' then '车主' when tmi.IS_VEHICLE = '0' then '粉丝' end 是否车主,
a.read_count 浏览量,
a.like_count 点赞数,
b.tt 评论数,
a.collect_count 收藏量
from community.tm_post a
left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join 
(
	select b.post_id,
	count(1) tt
	from community.tm_comment b 
	where b.is_deleted =0
	and b.create_time >='2023-05-05'
	and b.create_time < curdate() 
	group by 1
) b on b.post_id =a.post_id
where a.is_deleted =0
--and a.post_type = '1007'   -- UGC发帖
and a.post_type = '1001'   -- UGC动态
and l.topic_id = 'zvKCCcX2Yi'  -- 525车主节 聚在一起
and a.create_time >='2023-05-05'
and a.create_time < curdate() 


