select x.*
from 
(
select 
b.SALES_VIN,
b.delivery_owner_code 订车门店 ,
b.created_at ,
kp.invoice_date 开票时间,
tc.province_name 门店省份,
tc.CITY_NAME 门店城市,
row_number() over(partition by b.sales_vin order by b.created_at desc ) rk
from cyxdms_retail.tt_sales_orders a
left join cyxdms_retail.tt_sales_order_vin b  on a.so_no  = b.vi_no
left join  vehicle.tt_invoice_statistics_dms kp on b.SALES_VIN  = kp.vin 
left join organization.tm_company tc on tc.COMPANY_CODE = b.delivery_owner_code
where kp.is_deleted  = 0
and a.is_deleted  = 0
and b.sales_vin ='LYVXJEFE8PL041723')x where x.rk=1


select x.*
from 
(
select 
b.SALES_VIN,
b.delivery_owner_code 订车门店 ,
b.created_at ,
kp.invoice_date 开票时间,
tc.province_name 门店省份,
tc.CITY_NAME 门店城市,
row_number() over(partition by b.sales_vin order by b.created_at desc ) rk
from cyxdms_retail.tt_sales_orders a
left join cyxdms_retail.tt_sales_order_vin b  on a.so_no  = b.vi_no
left join  vehicle.tt_invoice_statistics_dms kp on b.SALES_VIN  = kp.vin 
left join organization.tm_company tc on tc.COMPANY_CODE = kp.dealer_code 
where kp.is_deleted  = 0
and a.is_deleted  = 0)x where x.rk=1
--and b.sales_vin ='LYVXJEFE8PL041723'


select *
from cyxdms_retail.tt_sales_order_vin
where sales_vin ='LYVXJEFE8PL041723'

