--车型销售排行
select 
x.model_name,
date_format(x.t,'%Y-%m'),
count(1)
from 
	(
	select 
	distinct 
--	a.*,
	a.CREATED_AT t,
	b.SALES_VIN,
	b.created_at ,
	a.customer_tel,
	f.model_name,
	tc2.config_name
	from cyxdms_retail.tt_sales_orders a
	left join cyxdms_retail.tt_sales_order_vin b  on a.so_no  = b.vi_no
	left join vehicle.tt_invoice_statistics_dms kp on b.SALES_VIN  = kp.vin 
	left join organization.tm_company tc on tc.COMPANY_CODE = b.delivery_owner_code
	left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
	left join basic_data.tm_model f on f.id = e.SECOND_ID
	left join basic_data.tm_config tc2 on kp.config_code =tc2.config_code  and kp.config_id =tc2.id
	where kp.is_deleted  = 0
	and a.is_deleted  = 0
	AND a.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
--	and a.CREATED_AT>='2024-01-01'
--	and a.CREATED_AT<'2024-01-01'
	and f.model_name in ('EX30','EM90')
	order by 1
)x 
group by rollup(1,2)
order by 1,2 

-- 每月销量
select 
date_format(x.CREATED_AT,'%Y-%m'),
count(1)
from 
	(
	select 
	distinct 
	a.CREATED_AT,
	b.SALES_VIN,
--	b.created_at ,
	a.customer_tel,
	f.model_name,
	tc2.config_name
	from cyxdms_retail.tt_sales_orders a
	left join cyxdms_retail.tt_sales_order_vin b  on a.so_no  = b.vi_no
	left join vehicle.tt_invoice_statistics_dms kp on b.SALES_VIN  = kp.vin 
	left join organization.tm_company tc on tc.COMPANY_CODE = b.delivery_owner_code
	left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
	left join basic_data.tm_model f on f.id = e.SECOND_ID
	left join basic_data.tm_config tc2 on kp.config_code =tc2.config_code  and kp.config_id =tc2.id
	where kp.is_deleted  = 0
	and a.is_deleted  = 0
	AND a.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
	and a.CREATED_AT>='2023-01-01'
--	and a.CREATED_AT<'2024-01-01'
	and (f.model_name in ('C40','XC40 RECHARGE','EM90') or tc2.config_name like '%T8%' or f.model_name like '%V%')
	order by 1
)x
group by rollup(1)
order by 1

--购买过直售车型
select 
count(distinct x.customer_tel)
from 
	(
	select 
	distinct 
	a.CREATED_AT,
	b.SALES_VIN,
	b.created_at ,
	a.customer_tel,
	f.model_name,
	tc2.config_name
	from cyxdms_retail.tt_sales_orders a
	left join cyxdms_retail.tt_sales_order_vin b  on a.so_no  = b.vi_no
	left join vehicle.tt_invoice_statistics_dms kp on b.SALES_VIN  = kp.vin 
	left join organization.tm_company tc on tc.COMPANY_CODE = b.delivery_owner_code
	left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
	left join basic_data.tm_model f on f.id = e.SECOND_ID
	left join basic_data.tm_config tc2 on kp.config_code =tc2.config_code  and kp.config_id =tc2.id
	where kp.is_deleted  = 0
	and a.is_deleted  = 0
	AND a.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
	and a.CREATED_AT>='2023-01-01'
--	and (f.model_name in ('C40','XC40 RECHARGE','EM90') or tc2.config_name like '%T8%' or f.model_name like '%V%')
	order by 1
)x

-- 购买其他车型用户数量
select count(distinct ifnull(ifnull(x.customer_tel,x.drawer_tel),x.PURCHASE_PHONE))
from 
(
	select 
	distinct 
	a.CREATED_AT,
	b.SALES_VIN,
	b.delivery_owner_code 购车门店 ,
	b.created_at ,
	a.customer_tel as customer_tel1,
	x1.customer_tel,
	x2.drawer_tel,
	x3.PURCHASE_PHONE,
	f.model_name,
	tc2.config_name
	from cyxdms_retail.tt_sales_orders a
	left join cyxdms_retail.tt_sales_order_vin b  on a.so_no  = b.vi_no
	left join vehicle.tt_invoice_statistics_dms kp on b.SALES_VIN  = kp.vin 
	left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
	left join basic_data.tm_model f on f.id = e.SECOND_ID
	left join basic_data.tm_config tc2 on kp.config_code =tc2.config_code  and kp.config_id =tc2.id
	left join (	
	--	购买了其他零售车型_潜客手机号
		select 
		distinct a.customer_tel,
		a.drawer_tel,
		a.PURCHASE_PHONE
--		f.model_name,
--		tc2.config_name
		from cyxdms_retail.tt_sales_orders a
		left join cyxdms_retail.tt_sales_order_vin b  on a.so_no  = b.vi_no
		left join vehicle.tt_invoice_statistics_dms kp on b.SALES_VIN  = kp.vin 
		left join organization.tm_company tc on tc.COMPANY_CODE = b.delivery_owner_code
		left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
		left join basic_data.tm_model f on f.id = e.SECOND_ID
		left join basic_data.tm_config tc2 on kp.config_code =tc2.config_code  and kp.config_id =tc2.id
		where kp.is_deleted  = 0
		and a.is_deleted  = 0
		AND a.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
	--	and a.CREATED_AT>='2023-01-01'
		and f.model_name not in ('C40','XC40 RECHARGE','EM90') 
		and tc2.config_name not like '%T8%'
		and f.model_name not like '%V%'
		order by 1
		)x1 on x1.customer_tel=a.customer_tel
	left join (	
	--	购买了其他零售车型_下单手机号
		select 
		distinct a.customer_tel,
		a.drawer_tel,
		a.PURCHASE_PHONE
--		f.model_name,
--		tc2.config_name
		from cyxdms_retail.tt_sales_orders a
		left join cyxdms_retail.tt_sales_order_vin b  on a.so_no  = b.vi_no
		left join vehicle.tt_invoice_statistics_dms kp on b.SALES_VIN  = kp.vin 
		left join organization.tm_company tc on tc.COMPANY_CODE = b.delivery_owner_code
		left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
		left join basic_data.tm_model f on f.id = e.SECOND_ID
		left join basic_data.tm_config tc2 on kp.config_code =tc2.config_code  and kp.config_id =tc2.id
		where kp.is_deleted  = 0
		and a.is_deleted  = 0
		AND a.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
	--	and a.CREATED_AT>='2023-01-01'
		and f.model_name not in ('C40','XC40 RECHARGE','EM90') 
		and tc2.config_name not like '%T8%'
		and f.model_name not like '%V%'
		order by 1
		)x2 on x2.drawer_tel=a.drawer_tel
	left join (	
	--	购买了其他零售车型_购买手机号
		select 
		distinct a.customer_tel,
		a.drawer_tel,
		a.PURCHASE_PHONE
--		f.model_name,
--		tc2.config_name
		from cyxdms_retail.tt_sales_orders a
		left join cyxdms_retail.tt_sales_order_vin b  on a.so_no  = b.vi_no
		left join vehicle.tt_invoice_statistics_dms kp on b.SALES_VIN  = kp.vin 
		left join organization.tm_company tc on tc.COMPANY_CODE = b.delivery_owner_code
		left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
		left join basic_data.tm_model f on f.id = e.SECOND_ID
		left join basic_data.tm_config tc2 on kp.config_code =tc2.config_code  and kp.config_id =tc2.id
		where kp.is_deleted  = 0
		and a.is_deleted  = 0
		AND a.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
	--	and a.CREATED_AT>='2023-01-01'
		and f.model_name not in ('C40','XC40 RECHARGE','EM90') 
		and tc2.config_name not like '%T8%'
		and f.model_name not like '%V%'
		order by 1
		)x3 on x3.PURCHASE_PHONE=a.PURCHASE_PHONE
	where kp.is_deleted  = 0
	and a.is_deleted  = 0
	AND a.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
	and a.CREATED_AT>='2023-01-01'
	and (f.model_name in ('C40','XC40 RECHARGE','EM90') or tc2.config_name like '%T8%' or f.model_name like '%V%')
)x
	
	
-- 有效订单数据—彪
select
distinct o.手机号,
o.订单日期
from
(
	select
	o.CUSTOMER_TEL 手机号,
	o.CREATED_AT 订单日期
	FROM cyxdms_retail.tt_sales_orders o
	WHERE o.BUSINESS_TYPE <> 14031002
	AND o.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')   -- 由于订单状态是动态变化的，所以这个未提交，因为不确定用户是否是继续提交订单，还是取消订单，所以一般我们就认为这条订单就是有效订单
	AND o.IS_DELETED = 0
	AND o.CREATED_AT >= '2023-07-17 9:00:00'
	AND o.CREATED_AT <= '2023-07-23 23:59:59'
	AND o.CUSTOMER_TEL IS NOT NULL
	UNION ALL   
	select
	o.DRAWER_TEL 手机号,
	o.CREATED_AT 订单日期
	FROM cyxdms_retail.tt_sales_orders o
	WHERE o.BUSINESS_TYPE <> 14031002
	AND o.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
	AND o.IS_DELETED = 0
	AND o.CREATED_AT >= '2023-07-17 9:00:00'
	AND o.CREATED_AT <= '2023-07-23 23:59:59'
	AND o.DRAWER_TEL IS NOT NULL
	UNION ALL
	select
	o.PURCHASE_PHONE 手机号,
	o.CREATED_AT 订单日期
	FROM cyxdms_retail.tt_sales_orders o
	WHERE o.BUSINESS_TYPE <> 14031002
	AND o.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
	AND o.IS_DELETED = 0
	AND o.CREATED_AT >= '2023-07-17 9:00:00'
	AND o.CREATED_AT <= '2023-07-23 23:59:59'
	AND o.PURCHASE_PHONE IS NOT null
) o
where length(o.手机号) = '11'
and left(o.手机号,1) = '1' order by o.订单日期	
