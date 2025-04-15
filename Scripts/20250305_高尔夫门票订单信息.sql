mid	order	tr_real_name_auth_order	订单商品认证信息表	
mid	order	tt_order_product	订单商品表	
mid	goods	item_sku  前台商品sku表	


select 
distinct x.order_code,
x.user_name,
x.user_phone
from 
(
SELECT 
distinct 
--tnao.id,
    tnao.order_code,
--    jt.id,
--    iku.coupon_name ,
    tnao.user_name,
    tnao.user_phone,
    tnao.create_time,
--    iku.spec,
--    tnao.card_type,
    CASE tnao.card_type
        WHEN '15081001' THEN '身份证'
        WHEN '15081002' THEN '护照'
        WHEN '15081011' THEN '往来港澳通行证'
        WHEN '15081012' THEN '往来台湾通行证'
        WHEN '15081013' THEN '外国人永久居留身份证'
        WHEN '15081014' THEN '港澳台居民居住证'
        ELSE '未知证件类型'
    END AS card_type_name,
    tnao.card_no,
    -- 提取多个 propertyValue 值
    (iku.spec -> 0 ->> 'propertyValue') AS spec1,
    (iku.spec -> 1 ->> 'propertyValue') AS spec2,
    (iku.spec -> 2 ->> 'propertyValue') AS spec3,
    tto.status
FROM 
    "order".tr_real_name_auth_order tnao
LEFT JOIN 
    "order".tt_order_product top ON tnao.product_id = top.product_id
LEFT JOIN 
    goods.item_sku iku ON iku.id = top.sku_id
left JOIN
    "order".tt_order tto ON tnao.order_code = tto.order_code
LEFT JOIN (
    SELECT 
        id, 
        iku.spec -> jt.n AS item
    FROM 
        goods.item_sku iku,
        (VALUES (0), (1), (2), (3), (4)) AS jt(n)
    WHERE 
        -- 将 json 类型的数据转换为 jsonb 类型再使用 jsonb_typeof 函数
        jsonb_typeof((iku.spec -> jt.n)::jsonb) != 'null'
) AS jt ON iku.id = jt.id
where 1=1
--and tnao.create_time >='2025-03-04'
--and tnao.create_time <'2025-03-20'
--and tnao.create_time <curdate()
--and tto.status = 51031005
and (iku.spec -> 0 ->> 'propertyValue') like '%周日%'
and (iku.spec -> 2 ->> 'propertyValue') ='单人'
and tnao.user_phone='18862332224'
order by 1 
)x



-- VCO明细
SELECT 
distinct 
--tnao.id,
--    tnao.order_code,
--    jt.id,
--    iku.coupon_name ,
    tnao.user_name,
    tnao.user_phone,
--    tnao.create_time,
--    iku.spec,
--    tnao.card_type,
     tnao.create_time,
    CASE tnao.card_type
        WHEN '15081001' THEN '身份证'
        WHEN '15081002' THEN '护照'
        WHEN '15081011' THEN '往来港澳通行证'
        WHEN '15081012' THEN '往来台湾通行证'
        WHEN '15081013' THEN '外国人永久居留身份证'
        WHEN '15081014' THEN '港澳台居民居住证'
        ELSE '未知证件类型'
    END AS card_type_name,
    tnao.card_no,
    -- 提取多个 propertyValue 值
    (iku.spec -> 0 ->> 'propertyValue') AS spec1,
    (iku.spec -> 1 ->> 'propertyValue') AS spec2,
    (iku.spec -> 2 ->> 'propertyValue') AS spec3
FROM 
    "order".tr_real_name_auth_order tnao
LEFT JOIN 
    "order".tt_order_product top ON tnao.product_id = top.product_id
LEFT JOIN 
    goods.item_sku iku ON iku.id = top.sku_id
left JOIN
    "order".tt_order tto ON tnao.order_code = tto.order_code
LEFT JOIN (
    SELECT 
        id, 
        iku.spec -> jt.n AS item
    FROM 
        goods.item_sku iku,
        (VALUES (0), (1), (2), (3), (4)) AS jt(n)
    WHERE 
        -- 将 json 类型的数据转换为 jsonb 类型再使用 jsonb_typeof 函数
        jsonb_typeof((iku.spec -> jt.n)::jsonb) != 'null'
) AS jt ON iku.id = jt.id
where 1=1
--and tnao.create_time >='2025-03-04'
and tnao.create_time <curdate()
and tto.status = 51031005
--and tnao.order_code ='648281703842'
order by 1 
