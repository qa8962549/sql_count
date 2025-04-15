-- 卡券核销代码
SELECT 
        b.coupon_name 卡券名称,
        b.id coupon_id卡券ID,
        a.left_value/100 面额,
        b.coupon_code 券号,
        tmi.ID 沃世界会员ID,
        tmi.cust_id,
        tmi.MEMBER_NAME 会员昵称,
        tmi.real_name 姓名,
        tmi.MEMBER_PHONE 沃世界绑定手机号,
        t.associate_vin 购买关联VIN,
        t.fee/100 总金额,
        t.create_time 下单时间,
        t.pay_fee/100 现金支付金额,
		t.point_amount 支付V值,
        declear_list.company_code 经销商code,
        t.associate_dealer 购买关联经销商,
        a.get_date 获得时间,
        a.activate_date 激活时间,
        a.expiration_date 卡券失效日期,
        CAST(a.exchange_code as varchar) 核销码,
        CASE a.ticket_state
            WHEN 31061001 THEN '已领用'
            WHEN 31061002 THEN '已锁定'
            WHEN 31061003 THEN '已核销' 
            WHEN 31061004 THEN '已失效'
            WHEN 31061005 THEN '已作废'
        END AS 卡券状态,
      	v.*
        FROM coupon.tt_coupon_detail a  -- 卡券信息表
        JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
        left join `member`.tc_member_info tmi on a.member_id  = tmi.id  -- 会员表
        left join `order`.tt_order_product t on a.order_code = t.order_code  -- 商品购买关联经销商，Vin
        left join (
                select company_code,code_name,row_number() over(partition by code_name order by bz) as bz
                from (
                    (select company_code ,company_short_name_cn as code_name,'1' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and company_short_name_cn is not null )
                    union all 
                    select company_code,official_dealer_name as code_name,'2' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and official_dealer_name is not null and official_dealer_name<>''
                    )
        ) declear_list
        on declear_list.code_name = t.associate_dealer and declear_list.bz='1'
        LEFT JOIN (
        select v.coupon_detail_id
        ,v.customer_name 核销用户名
        ,v.customer_mobile 核销手机号
        ,v.verify_amount 核销金额
        ,v.dealer_code 核销经销商
        ,v.vin 核销VIN
        ,v.operate_date 核销时间
        ,v.order_no 订单号
        ,v.PLATE_NUMBER
        from coupon.tt_coupon_verify v  -- 卡券核销信息表
        where  v.is_deleted=0
        order by v.create_time 
        ) v ON v.coupon_detail_id = a.id
        where 1=1
--        and m.member_status <> '60341003'
        and a.get_date >= '2023-11-25' 
        and a.get_date <'2023-11-27'
		 and b.id in ('5695',
		'5694',
		'5693',
		'5689',
		'5690',
		'5692',
		'5691')
        and a.is_deleted=0 
        and a.coupon_source = 83241003
--        and a.exchange_code='6206063831798698'
        order by 12;
       
       
 select x.卡券名称,
 count(case when x.卡券状态<>'已作废' then 1 end) 当前订单量,
 count(case when x.卡券状态='已作废' then 1 end) 当前退款量,
 count(1)
 from 
 (SELECT 
        b.coupon_name 卡券名称,
        b.id coupon_id卡券ID,
        a.left_value/100 面额,
        b.coupon_code 券号,
        tmi.ID 沃世界会员ID,
        tmi.cust_id,
        tmi.MEMBER_NAME 会员昵称,
        tmi.real_name 姓名,
        tmi.MEMBER_PHONE 沃世界绑定手机号,
        t.associate_vin 购买关联VIN,
        t.fee/100 总金额,
        t.create_time 下单时间,
        t.pay_fee/100 现金支付金额,
		t.point_amount 支付V值,
        declear_list.company_code 经销商code,
        t.associate_dealer 购买关联经销商,
        a.get_date 获得时间,
        a.activate_date 激活时间,
        a.expiration_date 卡券失效日期,
        CAST(a.exchange_code as varchar) 核销码,
        CASE a.ticket_state
            WHEN 31061001 THEN '已领用'
            WHEN 31061002 THEN '已锁定'
            WHEN 31061003 THEN '已核销' 
            WHEN 31061004 THEN '已失效'
            WHEN 31061005 THEN '已作废'
        END AS 卡券状态,
      	v.*
        FROM coupon.tt_coupon_detail a  -- 卡券信息表
        JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
        left join `member`.tc_member_info tmi on a.one_id = tmi.CUST_ID  -- 会员表
        left join `order`.tt_order_product t on a.order_code = t.order_code  -- 商品购买关联经销商，Vin
        left join (
                select company_code,code_name,row_number() over(partition by code_name order by bz) as bz
                from (
                    (select company_code ,company_short_name_cn as code_name,'1' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and company_short_name_cn is not null )
                    union all 
                    select company_code,official_dealer_name as code_name,'2' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and official_dealer_name is not null and official_dealer_name<>''
                    )
        ) declear_list
        on declear_list.code_name = t.associate_dealer and declear_list.bz='1'
        LEFT JOIN (
        select v.coupon_detail_id
        ,v.customer_name 核销用户名
        ,v.customer_mobile 核销手机号
        ,v.verify_amount 核销金额
        ,v.dealer_code 核销经销商
        ,v.vin 核销VIN
        ,v.operate_date 核销时间
        ,v.order_no 订单号
        ,v.PLATE_NUMBER
        from coupon.tt_coupon_verify v  -- 卡券核销信息表
        where  v.is_deleted=0
        order by v.create_time 
        ) v ON v.coupon_detail_id = a.id
        where 1=1
        and a.get_date >= '2023-11-25' 
        and a.get_date <'2023-11-27'
		 and b.id in ('5695',
		'5694',
		'5693',
		'5689',
		'5690',
		'5692',
		'5691')
        and a.is_deleted=0 
        and a.coupon_source = 83241003
        order by 12)x group by 1 
        order by 1
