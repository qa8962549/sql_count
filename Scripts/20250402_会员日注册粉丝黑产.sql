DROP table ods_oper_crm.20250402_heichan


-- 会员日黑产
select x1.id,
x1.create_time ,
x2.mt `当月首次访问会员日页面时间`,
ifnull(x3.hy_num,1) `活跃天数`,
--x4.registration_platform `注册平台`,
x1.zhuce `注册平台`,
if(x5.id is null ,'否','是') `用户目前状态（是否注销）`,
x6.device_model_concat `机型`,
x6.city_concat `城市`,
x1.member_c_num,
x1.member_v_num,
x7.`支付V值` ,
x7.`现金支付金额(元)` ,
x6.ip_concat `IP地址`,
x6_1.ip_num `IP相同情况`
from 
	(
	select a.id,
	create_time,
	m.member_c_num ,
	m.member_v_num,
	case when m.member_source ='60511001' then 'mini'
		when m.member_source ='60511003' then 'app '
		else null end zhuce
	from ods_oper_crm.`20250402` a
	left join ods_memb.ods_memb_tc_member_info_cur m on a.id=m.id  
	where a.`所属sheet`='2月25日注册用户'
)x1
left join 
	(
	-- 当月首次访问会员日页面时间
	select a.var_memberId id,
	max(client_time) mt
	from ods_gio.ods_gio_event_d a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id)=toString(a.var_memberId) -- 2024年以后得数据可以用mmeberid关联
	where ((`$platform` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App')
	and event_time>='2025-02-25'
	and toDate(client_time) = '2025-02-25' -- App开始使用
	and event_key ='Page_entry'
	and var_page_title ='2月会员日'
	and var_activity_name='2025年2月会员日'
--	and var_memberId='9369140'
	group by 1 
)x2 on x1.id=x2.id
left join 
	(--当月app活跃天数
	select memberid id,
	count(distinct dt) hy_num
	from ods_oper_crm.ods_oper_crm_active_gio_d_si 
	where platform ='App'
	and month(dt)= 2
	and year(dt)=2025
	and memberid is not null 
	group by 1 
	order by 2 desc
)x3 on x3.id=x1.id::String
--left join 
--(
---- 注册渠道（小程序/app）
--SELECT 
--     a.memberid id,
--    -- 计算最早注册时间
--    least(
--        coalesce(min_mini, min_app), 
--        coalesce(min_app, min_mini)
--    ) AS registration_time,
--    -- 判断最早注册时间对应的平台
--    CASE 
--        WHEN least(
--            coalesce(min_mini, min_app), 
--            coalesce(min_app, min_mini)
--        ) = min_mini THEN 'mini'
--        WHEN least(
--            coalesce(min_mini, min_app), 
--            coalesce(min_app, min_mini)
--        ) = min_app THEN 'app'
--        ELSE NULL
--    END AS registration_platform
--FROM 
--    ods_oper_crm.ods_oper_crm_usr_gio_d_si a
--)x4 on x1.id::String=x4.id
left join 
	(--用户目前状态（是否注销）
	select a.id,
	create_time
	from ods_oper_crm.`20250402` a
	left join ods_memb.ods_memb_tc_member_info_cur m on a.id=m.id  
	where a.`所属sheet`='2月25日注册用户'
	and m.member_phone ='*'
)x5 on x1.id=x5.id
left join 
(
--   机型 城市（如有）
SELECT 
    a.var_memberId id, 
    -- 使用 groupUniqArray 去重后再用 arrayStringConcat 连接 $device_model
    arrayStringConcat(groupUniqArray($device_model), ',') AS device_model_concat,
    -- 使用 groupUniqArray 去重后再用 arrayStringConcat 连接 $city
    arrayStringConcat(groupUniqArray($city), ',') AS city_concat,
    -- 使用 groupUniqArray 去重后再用 arrayStringConcat 连接 $ip
    arrayStringConcat(groupUniqArray($ip), ',') AS ip_concat
FROM 
    ods_gio.ods_gio_event_d a 
WHERE 
    1 = 1
    AND event_time >= '2025-02-25'
    AND toDate(client_time) = '2025-02-25'
GROUP BY 
    a.var_memberId
)x6 on x1.id=x6.id
left join 
	(
	--IP相同情况（相同IP数量）
	select ip_concat,
	count(distinct id) ip_num
	from 
		(
		SELECT 
		    a.var_memberId id, 
		    -- 使用 groupUniqArray 去重后再用 arrayStringConcat 连接 $ip
		    arrayStringConcat(groupUniqArray($ip), ',') AS ip_concat
		FROM 
		    ods_gio.ods_gio_event_d a 
		WHERE 
		    1 = 1
		    AND event_time >= '2025-02-25'
		    AND toDate(client_time) = '2025-02-25'
		GROUP BY 
		    a.var_memberId
		 )
	 group by 1 
)x6_1 on x6.ip_concat=x6_1.ip_concat
left join 
(
--商城兑换情况（使用V值）
--商城兑换情况（使用现金）
select 
        a.user_id as id
--        ,sum(b.fee/100) `总金额`
        ,sum(b.pay_fee/100) `现金支付金额(元)`
        ,sum(b.point_amount) `支付V值`
        from ods_orde.ods_orde_tt_order_d a  -- 订单主表
        left join ods_orde.ods_orde_tt_order_product_d  b on a.order_code = b.order_code  -- 订单商品表
        left join(
        --  #V值退款成功记录
            select so.order_code
            ,sp.product_id
            ,CASE 
                WHEN so.status ='51171001' THEN '待审核'
                WHEN so.status ='51171002' THEN '待退货入库'
                WHEN so.status ='51171003' THEN '待退款'
                WHEN so.status ='51171004' THEN '退款成功'
                WHEN so.status ='51171005' THEN '退款失败'
                WHEN so.status ='51171006' THEN '作废退货单' END as `退货状态`
            ,sum(sp.sales_return_num) `退货数量`
            ,sum(so.refund_point) `退回V值`
            ,max(so.create_time) `退回时间`
            from ods_orde.ods_orde_tt_sales_return_order_d so
            left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code=sp.refund_order_code 
            where so.is_deleted = 0 
            and so.status='51171004' -- 退款成功
            and sp.is_deleted=0
            GROUP BY order_code,product_id,`退货状态`
        ) e on a.order_code = e.order_code and b.product_id =e.product_id 
        where 1=1
--        and toDate(a.create_time) >= '2024-01-01' 
        and a.is_deleted <> 1  -- 剔除逻辑删除订单
        and b.is_deleted <> 1
    --  and j.front_category_id is not null
        and a.type = 31011003  -- 筛选沃世界商城订单
        and a.separate_status = 10041002 -- 选择拆单状态否
        and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
        AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
        and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
        and e.order_code is null  -- 剔除退款订单
        group by 1 
)x7 on x1.id::String=x7.id
order by 1 
settings join_use_nulls=1 

 