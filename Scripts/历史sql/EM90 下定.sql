-- 总订单数量（含退款）
select
count(distinct a.so_no)
FROM cyxdms_retail.tt_sales_orders  a
left join cyxdms_retail.tt_sales_order_vin  b on a.`so_no`  = b.`vi_no` 
left join cyxdms_retail.tt_sales_order_detail c on c.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
WHERE b.`sale_type` = 20131010
and a.`so_status` in (14041001,14041002,14041003,14041008,14041030)
and a.`is_deposit` in (10421009,10041001,10041002,70961001,70961002)
and c.second_id = '1111'    -- basic_data里面的id，对应EM90
and a.created_at >= '2023-11-12'   
-- and a.created_at < '2023-11-17'    
and a.created_at < '2023-11-21'
and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
and a.`is_deleted` ='0'
and b.`is_deleted` ='0';