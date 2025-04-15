select  *
from ods_cdp.ods_cdp_dws_vehicle_relation_d
where 1=1 
and cvr_type in('绑车会员','投保人','售后车主','二手车新车主','开票车主','亲友授权会员')

select *
from ods_cdp.ods_cdp_value_tag_vehicle_profilebase_18c43af612d_d  --零售购车车龄（年份）
 
select *,round(mb_decrypt/5,0)
from ods_oper_crm.ods_oper_crm_cdp_mobile_decrypt_d_si -- 加密手机号表

SELECT
    CASE
        WHEN x1.value >= 0 AND x1.value < 1 THEN '0 - 1'
        WHEN x1.value >= 1 AND x1.value < 2 THEN '1 - 2'
        WHEN x1.value >= 2 AND x1.value < 3 THEN '2 - 3'
        WHEN x1.value >= 3 AND x1.value < 4 THEN '3 - 4'
        WHEN x1.value >= 4 AND x1.value < 5 THEN '4 - 5'
        WHEN x1.value >= 5 AND x1.value < 6 THEN '5 - 6'
        WHEN x1.value >= 6 AND x1.value < 7 THEN '6 - 7'
        WHEN x1.value >= 7 AND x1.value < 8 THEN '7 - 8'
        WHEN x1.value >= 8 AND x1.value < 9 THEN '8 - 9'
        WHEN x1.value >= 9 AND x1.value < 10 THEN '9 - 10'
        WHEN x1.value >= 10 THEN '9.10及以上'  -- 处理大于等于10的情况
        ELSE '其他'  -- 处理不符合前面区间条件的数据（比如车龄为负数等异常情况）
    END AS `车龄区间`,
    count(distinct x.vehicle_oneid)
FROM ods_cdp.ods_cdp_dws_vehicle_relation_d x
left join ods_cdp.ods_cdp_value_tag_vehicle_profilebase_18c43af612d_d x1 on x.vehicle_oneid =x1.oneid   --零售购车车龄（年份）
left join (
 -- 获取手机号
	select *,round(mb_decrypt/5,0)::String mobile
	from ods_oper_crm.ods_oper_crm_cdp_mobile_decrypt_d_si -- 加密手机号表)
) x2 on x.mobile = x2.mb_crypto 
where 1=1 
    AND cvr_type IN ('绑车会员', '投保人', '售后车主', '二手车新车主', '开票车主', '亲友授权会员')
GROUP BY 1
ORDER BY 1
settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0


-- 全渠道\总部CRM 线索总量（NB）
SELECT
    CASE
        WHEN x1.value >= 0 AND x1.value < 1 THEN '0 - 1'
        WHEN x1.value >= 1 AND x1.value < 2 THEN '1 - 2'
        WHEN x1.value >= 2 AND x1.value < 3 THEN '2 - 3'
        WHEN x1.value >= 3 AND x1.value < 4 THEN '3 - 4'
        WHEN x1.value >= 4 AND x1.value < 5 THEN '4 - 5'
        WHEN x1.value >= 5 AND x1.value < 6 THEN '5 - 6'
        WHEN x1.value >= 6 AND x1.value < 7 THEN '6 - 7'
        WHEN x1.value >= 7 AND x1.value < 8 THEN '7 - 8'
        WHEN x1.value >= 8 AND x1.value < 9 THEN '8 - 9'
        WHEN x1.value >= 9 AND x1.value < 10 THEN '9 - 10'
        WHEN x1.value >= 10 THEN '9.10及以上'  -- 处理大于等于10的情况
        ELSE '其他'  -- 处理不符合前面区间条件的数据（比如车龄为负数等异常情况）
    END AS `车龄区间`,
    count(distinct x3.clue_id) AS `全渠道线索总量`
FROM ods_cdp.ods_cdp_dws_vehicle_relation_d x
left join ods_cdp.ods_cdp_value_tag_vehicle_profilebase_18c43af612d_d x1 on x.vehicle_oneid =x1.oneid   --零售购车车龄（年份）
left join (
 -- 获取手机号
	select *,round(mb_decrypt/5,0)::String mobile
	from ods_oper_crm.ods_oper_crm_cdp_mobile_decrypt_d_si -- 加密手机号表)
) x2 on x.mobile = x2.mb_crypto 
left join ods_cust.ods_cust_tt_clue_clean_cur x3 on x2.mobile=x3.mobile and x3.is_deleted=0  -- 线索表 获取全渠道线索总量（NB）
LEFT JOIN ods_actv.ods_actv_cms_active_d ca on x3.campaign_id = ca.uid
LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel -- 线索渠道表
where 1=1 
    AND cvr_type IN ('绑车会员', '投保人', '售后车主', '二手车新车主', '开票车主', '亲友授权会员')
	and x3.create_time>= '2024-01-01'
	and x3.create_time< '2024-12-01'
--	and tcs.CLUE_NAME='总部CRM' -- 全渠道时需要注释
GROUP BY 1
ORDER BY 1
settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0


-- 不同车型订单
SELECT
    CASE
        WHEN x1.value >= 0 AND x1.value < 1 THEN '0 - 1'
        WHEN x1.value >= 1 AND x1.value < 2 THEN '1 - 2'
        WHEN x1.value >= 2 AND x1.value < 3 THEN '2 - 3'
        WHEN x1.value >= 3 AND x1.value < 4 THEN '3 - 4'
        WHEN x1.value >= 4 AND x1.value < 5 THEN '4 - 5'
        WHEN x1.value >= 5 AND x1.value < 6 THEN '5 - 6'
        WHEN x1.value >= 6 AND x1.value < 7 THEN '6 - 7'
        WHEN x1.value >= 7 AND x1.value < 8 THEN '7 - 8'
        WHEN x1.value >= 8 AND x1.value < 9 THEN '8 - 9'
        WHEN x1.value >= 9 AND x1.value < 10 THEN '9 - 10'
        WHEN x1.value >= 10 THEN '9.10及以上'  -- 处理大于等于10的情况
        ELSE '其他'  -- 处理不符合前面区间条件的数据（比如车龄为负数等异常情况）
    END AS `车龄区间`,
    count(distinct x4.so_no)`所有车型订单`, 
    count(distinct x4.so_no)
    	-count(distinct case when tc2.CONFIG_NAME like '%T8%' then x4.so_no else null end)  
    	-count(distinct case when tm.model_name in (  -- BEV 
		 'C40 RECHARGE',
		 'XC40 RECHARGE',
		 'XC60 RECHARGE',
		 'XC90 RECHARGE',
		 'S60 RECHARGE',
		 'S90 RECHARGE',
		 'EM90','EX30','EX90')then x4.so_no else null end)`油车订单1`, 
    count(distinct case when tc2.CONFIG_NAME like '%T8%' then x4.so_no else null end) `T8订单` ,
    count(distinct case when tm.model_name in (  -- BEV 
		 'C40 RECHARGE',
		 'XC40 RECHARGE',
		 'XC60 RECHARGE',
		 'XC90 RECHARGE',
		 'S60 RECHARGE',
		 'S90 RECHARGE',
		 'EM90','EX30','EX90')then x4.so_no else null end) `电车订单` 
FROM ods_cdp.ods_cdp_dws_vehicle_relation_d x
left join ods_cdp.ods_cdp_value_tag_vehicle_profilebase_18c43af612d_d x1 on x.vehicle_oneid =x1.oneid 
left join (
	select *,round(mb_decrypt/5,0)::String mobile
	from ods_oper_crm.ods_oper_crm_cdp_mobile_decrypt_d_si -- 加密手机号表)
) x2 on x.mobile = x2.mb_crypto 
left join ods_cust.ods_cust_tt_clue_clean_cur x3 on x2.mobile=x3.mobile and x3.is_deleted=0 -- 线索表
LEFT JOIN ods_actv.ods_actv_cms_active_d ca on x3.campaign_id = ca.uid 
LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel-- 线索渠道表
left join (
	select
	distinct o.mobile,
	so_no,
	toDateTime(o.t) t,
	sales_vin vin
	from
	(
		select
		o.customer_tel mobile,
		o.so_no,
		o.created_at t,
		b.sales_vin
		from  ods_cydr.ods_cydr_tt_sales_orders_cur o 
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur  b on o.so_no = b.vi_no and b.is_deleted=0
		where o.business_type <> 14031002
		and o.so_status in ('14041003', '14041008', '14041001', '14041002')   -- 由于订单状态是动态变化的，所以这个未提交，因为不确定用户是否是继续提交订单，还是取消订单，所以一般我们就认为这条订单就是有效订单
		and o.is_deleted = 0
		and o.created_at >= '2024-01-01'
		and o.created_at < '2024-12-01'
		and o.customer_tel is not null
		union all   
		select
		o.customer_tel mobile,
		o.so_no,
		o.created_at t,
		b.sales_vin
		from ods_cydr.ods_cydr_tt_sales_orders_cur o 
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur  b on o.so_no = b.vi_no and b.is_deleted=0
		where o.business_type <> 14031002
		and o.so_status in ('14041003', '14041008', '14041001', '14041002')
		and o.is_deleted = 0
		and o.created_at >= '2024-01-01'
		and o.created_at < '2024-12-01'
		and o.drawer_tel is not null
		union all
		select
		o.customer_tel mobile,
		o.so_no,
		o.created_at t,
		b.sales_vin
		from ods_cydr.ods_cydr_tt_sales_orders_cur o 
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur  b on o.so_no = b.vi_no and b.is_deleted=0
		where o.business_type <> 14031002
		and o.so_status in ('14041003', '14041008', '14041001', '14041002')
		and o.is_deleted = 0
		and o.created_at >= '2024-01-01'
		and o.created_at < '2024-12-01'
		and o.purchase_phone is not null
	) o
	 where 1=1
	 and length(o.mobile) = '11'
	 and left(o.mobile,1) = '1' 
	 order by 2	
)x4 on x4.mobile=x2.mobile 
 left join ods_vehi.ods_vehi_tm_vehicle_d tv on x4.vin = tv.VIN and tv.IS_DELETED = 0
 left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur d on x4.vin = d.vin and d.is_deleted = 0
 left join ods_bada.ods_bada_tm_model_cur tm on ifnull(d.model_id,tv.MODEL_ID) = tm.id and tm.is_deleted = 0
 left join ods_bada.ods_bada_tm_config_d tc2 on ifnull(d.config_code,tv.CONFIG_CODE) =tc2.CONFIG_CODE and ifnull(d.config_id,tv.CONFIG_ID) =tc2.ID
where 1=1 
    AND cvr_type IN ('绑车会员', '投保人', '售后车主', '二手车新车主', '开票车主', '亲友授权会员')
	and x3.create_time>= '2024-01-01'
	and x3.create_time< '2024-12-01'
	and toDateTime(left(CAST(x3.create_time AS String),19))<toDateTime(x4.t) -- 订单时间大于线索时间
--	and tcs.CLUE_NAME='总部CRM'
GROUP BY 1
ORDER BY 1
settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0

