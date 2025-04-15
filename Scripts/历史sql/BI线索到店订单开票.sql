-- 线索
select 
--pmonth,
count(1) `线索`
from ads_bi.ads_sales_leads_detail_detail_d a
where pmonth <'202412'
and dealer_code not in ('VVD','VVB')
--GROUP BY pmonth order by pmonth desc
 
-- 到店
SELECT pmonth,count(1) `到店`
FROM ads_bi.ads_sales_arrival_detail_detail_d a
WHERE pmonth <'202412'
and is_first_arrival='100100001'
GROUP BY pmonth order by pmonth desc

-- 订单
select pmonth, count(1) `订单`
from ads_bi.ads_sales_order_detail_detail_d t1
where t1.pmonth <'202412' 
and ((t1.dealer_code<>'VVD' and t1.order_status<>'14041009') or (t1.dealer_code='VVD' and t1.is_direct_sales_order='100100001'))
GROUP BY pmonth order by pmonth desc
 
-- 开票
select pmonth,sum(invc_num) `开票`
from ads_bi.ads_sales_invc_detail_his_detail_d a
where pmonth  <'202412'
GROUP BY pmonth order by pmonth desc


删掉channelid=3

ads_sales_leads_detail_detail_d 与 
ods_cust_tt_clue_clean_cur 相匹配 
更新到十一月底