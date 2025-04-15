select 
distinct 
event_key,
user,
var_page_title,
var_product_id,
var_dealer_code,
var_sales_id
from ods_gio.ods_gio_event_d_memberid a
where 1=1
and event_time>='2025-04-08'
and client_time>='2025-04-08'
and user='21168359'
and event_key='Page_entry'
and var_page_title='商品详情页'
--order by client_time desc
order by 1 