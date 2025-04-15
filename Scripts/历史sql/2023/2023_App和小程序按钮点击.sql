-- 小程序按钮点击
select 
  page_title
  ,btn_name
  ,count(a.user_id) PV
  ,count(distinct a.user_id) UV
from ods_rawd_events_d_di a
where 1=1
and a.event in ('Button_click',
'MP_Button_click',
'Mall_buy_now_click',
'Mall_search_result_click',
'Mall_add_to_shopping_cart_click',
'Mall_search_request_result',
'Mall_pay_order_click',
'Mall_search_button_click',
'Mall_category_list_view',
'Mall_pay_order_result',
'Mall_product_detail_view')
and ($lib='MiniProgram' or channel='Mini') -- Mini
and a.`date` >= '2023-10-01' 
and a.`date` <'2023-11-01'
and btn_name is not null 
group by a.page_title,a.btn_name
order by a.page_title,a.btn_name

-- APP按钮点击
select 
  page_title
  ,btn_name
  ,count(a.user_id) PV
  ,count(distinct a.user_id) UV
from ods_rawd_events_d_di a
where 1=1
and (a.`$lib` in ('iOS','Android') or channel ='App')
and a.`date` >= '2023-10-01' 
and a.`date` <'2023-11-01'
and (a.event='Button_click' or (a.event like '%Mall%' and a.event not like '%detail_click%'))
and btn_name is not null 
group by a.page_title,a.btn_name
order by a.page_title,a.btn_name

