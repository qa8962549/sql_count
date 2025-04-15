
-- 优惠券核销情况
	with base as (
select 
	tci.coupon_name 卡券名称
	,tcd.coupon_id 卡券id
	,tci.coupon_value/100 卡券面额
	,tci.coupon_code 券号
	,tcd.member_id 会员id
	,tcd.one_id cust_id
	,tmi.member_name 会员昵称
	,tmi.real_name 姓名
	,tmi.member_phone 沃世界注册手机号
	,top.associate_vin 购买关联vin
	,top.fee/100 总金额
	,top.create_time 下单时间
	,top.pay_fee/100 现金支付金额
	,top.point_amount 支付v值
	,declear_list.company_code 购买关联经销商code
	,top.associate_dealer 购买关联经销商
	,tcd.get_date 获得时间
	,tcd.activate_date 激活时间
	,tcd.expiration_date 卡券失效日期
	,tcd.exchange_code 核销码
	,tc.code_cn_desc 卡券状态
	,tcd.id 卡券领取id
	,tcv.核销用户名
	,tcv.核销手机号
	,tcv.核销金额
	,tcv.核销经销商
	,tcv.核销vin
	,tcv.核销时间
	,tcv.核销工单号
	,tcv.核销车牌
	,top.spu_id
	,tcd.is_refunded 是否退款
	,h.退回时间
from coupon.tt_coupon_detail tcd 
left join coupon.tt_coupon_info tci on tci.id =tcd.coupon_id and tci.is_deleted =0
left join "member".tc_member_info tmi on tmi.id =tcd.member_id and tmi.is_deleted =0
left join "order".tt_order_rt_coupon torc on torc.coupon_id =tcd.id and torc.is_deleted =0
left join "order".tt_order_product top on top.order_code =torc.order_code and top.product_id = torc.product_id and top.is_deleted =0
left join "order".tt_order to2 on to2.order_code =top.order_code 
left join
(
	-- 退单明细
	select
	so.refund_order_code,
	so.order_code,
	sp.product_id,
	case when so.status = '51171001' then  '待审核' 
		when so.status = '51171002' then  '待退货入库' 
		when so.status = '51171003' then  '待退款' 
		when so.status = '51171004' then  '退款成功' 
		when so.status = '51171005' then  '退款失败' 
		when so.status = '51171006' then  '作废退货单'
		else null end 退货状态,
	sum(sp.sales_return_num) 退货数量,
	sum(so.refund_point) `退回V值`,
	max(so.create_time) 退回时间
	from "order".tt_sales_return_order so
	left join "order".tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code
	where 1=1
	and so.status = '51171004'     -- 退款成功
	and so.is_deleted = 0
	and sp.is_deleted = 0
	GROUP BY 1,2,3,4
) h on to2.order_code = h.order_code and top.product_id = h.product_id
left join (--获取关联经销商名称
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
) declear_list on declear_list.code_name = top.associate_dealer and declear_list.bz='1'
left join "dictionary".tc_code tc on tc.code_id =tcd.ticket_state and tc.is_deleted ='N'
left join (
	select v.coupon_detail_id
	,string_agg(v.customer_name,';' order by id) 核销用户名
	,string_agg(v.customer_mobile,';' order by id) 核销手机号
	,string_agg(round(v.verify_amount/100,2),';' order by id) 核销金额
	,string_agg(v.dealer_code,';' order by id) 核销经销商
	,string_agg(v.vin,';' order by id) 核销VIN
	,string_agg(v.operate_date,';' order by id) 核销时间
	,string_agg(v.order_no,';' order by id) 核销工单号
	,string_agg(v.PLATE_NUMBER,';' order by id) 核销车牌
	from coupon.tt_coupon_verify v  -- 卡券核销信息表
	where  v.is_deleted=0
	group by v.coupon_detail_id
) tcv on tcv.coupon_detail_id =tcd.id
where 1=1
and date(to2.create_time) >= '2024-07-26' 
and date(to2.create_time) < date(now())
and tcd.is_deleted=0 
--and tcd.coupon_source ='83241003'
--and top.associate_vin in ('LYVXEAED7NL753885','YV1LF06F5P1968410','LYVXEAED3NL680496','LVYZBK9D5NP171367')
and tcd.coupon_id in (
'7020',
'7124',
'7125',
'7126',
'7127',
'7128',
'7129',
'7130',
'7131',
'7133',
'7139',
'7023',
'7024',
'7025',
'7026',
'7063',
'7064',
'7065',
'7066',
'7067',
'7068',
'7069',
'7070',
'7071',
'7072',
'7073',
'7074',
'7075',
'7076',
'7077',
'7078',
'7079',
'7081',
'7083',
'7084',
'7085',
'7086',
'7087',
'7088',
'7089',
'7090',
'7091',
'7092',
'7252',
'7277',
'7278',
'7284'
)
)
select
	卡券id
	,count(1) AS 发放数
--	,count(case when 卡券状态='已核销 ' then 卡券id end) as 核销数
--	,count(case when 卡券状态='已核销 ' then 卡券id end)/count(1) `核销率`
--	,sum(是否退款)/count(1) `退款率`
	,sum(是否退款) 退款数
	,sum(总金额) `销售金额（含退款）`
	,sum(case when 是否退款=0 then 总金额 else 0 end)`销售金额（不含退款）`
from base
GROUP BY 1
order by 1 desc 


-----------------------------------------------------------分割线----------------------------------------------------

	select 
	x.卡券名称 卡券名称,
	x.coupon_id,
	x.卡券状态,
	concat(x.coupon_id,x.卡券状态) 状态合计,
	count(case when x.IS_VEHICLE=1 then x.id else null end) 车主,
	count(case when x.IS_VEHICLE=0 then x.id else null end) 粉丝,
	count(x.id) 合计,
	sum(x.实付金额) 核销订单金额,
	sum(x.优惠券抵扣金额) 卡券抵扣金额,
	sum(x.总金额) `核销订单金额（券前）`,
	sum(x.实付金额)  `核销订单金额（券后）`
	from (
	SELECT 
		a.id,
	 	a.coupon_source,
	    b.coupon_name 卡券名称,
	    b.id coupon_id,
	    a.left_value/100 面额,
	    b.coupon_code 券号,
	    coalesce(a.member_id,tmi1.id) 沃世界会员ID,
	    coalesce(tmi.MEMBER_NAME,tmi1.MEMBER_NAME) 会员昵称,
	    coalesce(tmi.real_name,tmi1.real_name) 姓名,
	    coalesce(tmi.MEMBER_PHONE,tmi1.MEMBER_PHONE) 沃世界绑定手机号,
	    coalesce(tmi.is_vehicle,tmi1.is_vehicle) is_vehicle,
	    t.associate_vin 购买关联VIN,
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
		a.is_refunded 是否退款,
		v.*
	FROM coupon.tt_coupon_detail a  -- 卡券信息表
	JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
	left join `member`.tc_member_info tmi on a.member_id = tmi.id and tmi.is_deleted=0-- 会员表
	left join (
		select tmi.*
			,row_number ()over(partition by tmi.cust_id order by tmi.create_time desc ) rk
		from `member`.tc_member_info tmi 
		where tmi.is_deleted = 0
		) tmi1 on tmi1.cust_id=a.one_id and tmi1.rk=1
	left join (
		select	t.*,sk.coupon_id
		from `order`.tt_order_product t
		inner join goods.item_sku sk
		on t.sku_id =sk.id and sk.is_deleted =0 and sk.sku_status =1
	) t 
	on a.order_code = t.order_code and a.coupon_id= t.coupon_id -- 商品购买关联经销商，Vin
	left join (--获取关联经销商名称
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
	LEFT JOIN (--获取卡券核销信息
		select 
		distinct 
			v.coupon_detail_id
			,v.customer_name 核销用户名
			,v.customer_mobile 核销手机号
			,v.verify_amount 
			,v.dealer_code 核销经销商
			,v.vin 核销VIN
			,v.operate_date 核销时间
			,v.order_no 订单号
			,v.PLATE_NUMBER
			,b.fee/100 总金额
			,b.coupon_fee/100 优惠券抵扣金额
			,round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) 不含税的总金额
			,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
			,b.pay_fee/100 现金支付金额
		from coupon.tt_coupon_verify v  -- 卡券核销信息表
		left join "order".tt_order_product b on v.order_no =b.order_code and v.is_deleted <>1
		left join "order".tt_order a on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表 -- 订单主表 
		where  v.is_deleted=0
--		and b.fee/100 is not null 
		order by v.create_time 
	) v ON v.coupon_detail_id = a.id
	where 1=1
--	and date(a.get_date)>= '2024-01-01'
--	and date(a.get_date)< '2024-07-01'
--	and v.核销时间>= '2024-01-01'
--	and v.核销时间<'2024-07-01'
	and a.is_deleted=0 
	and a.coupon_id in ( '3866', 
 '3915', 
 '3862', 
 '3863', 
 '3861', 
 '3875', 
 '3864', 
 '3859')
	order by 12
	) x
	where 1=1
--	and x.卡券状态='已领用' or x.卡券状态='已核销'
	group by 1,2,3
	order by 1,2,3 desc 
	

	


select *
from 
"order".tt_order_product torc

-- 养修预约明细
select distinct
tam.MAINTAIN_ID as  `养修预约ID`,
ta.APPOINTMENT_ID as  `预约ID`,
ta.OWNER_CODE as  `经销商代码`,
tc2.company_name_cn   as `经销商名称`,
ta.ONE_ID as `车主oneid`,
ta.user_member_id as `会员ID`,
--'' "APP/小程序",
case when tam.CAR_MODEL in ('XC40 RECHARGE','全新纯电C40','EM90','EX30') then '电车'
	else '油车' end as `电车/油车`,
ta.CUSTOMER_NAME as `联系人姓名`,
ta.CUSTOMER_PHONE as  `联系人手机号`,
tam.CAR_MODEL as  `预约车型`,
tam.CAR_STYLE as  `预约车款`,
tam.VIN as  `车架号`,
case when tam.IS_TAKE_CAR = 10041001 then '是'
	when tam.IS_TAKE_CAR = 10041002 then '否' 
	end  as  `是否取车`,
case when tam.IS_GIVE_CAR = 10041001 then '是'
	when tam.IS_GIVE_CAR = 10041002 then '否'
    end as  `是否送车`,
tc.CODE_CN_DESC as  `养修状态`,
tam.CREATED_AT as  `创建时间`,
tam.UPDATED_AT as  `修改时间`,
ta.CREATED_AT as  `预约时间`,
tam.WORK_ORDER_NUMBER as  `工单号`
from 
(-- 浏览过活动页-夏服
	select distinct a.`user` as distinct_id--,toDateTime(a.client_time ) as `time`
	from ods_gio.ods_gio_event_d a
	where length(a.`user`)<9 
	and date(a.event_time) >= date('2024-07-26')-INTERVAL 1 MONTH  and date(a.event_time) < date('2024-07-29')+INTERVAL 1 MONTH
	and a.client_time >= '2024-07-26'  and a.client_time < '2024-07-29'
	and a.event_key in ('Page_entry','Page_view')
	and a.var_page_title ='夏服活动'
	and a.var_activity_name ='2024年夏服活动'
	and ((a.`$platform` in('iOS','Android','HarmonyOS') and left(a.`$client_version`,1)='5') or a.var_channel ='App') -- App
)a
inner join  ods_cyap.ods_cyap_tt_appointment_d ta on toString(ta.`ONE_ID`)  = a.`distinct_id` 
left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
left join ods_cyap.ods_cyap_tt_appointment_maintain_d  tam  on tam.`APPOINTMENT_ID` =ta.`APPOINTMENT_ID` and tam.IS_DELETED  =0
left JOIN ods_dict.ods_dict_tc_code_d   tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
where ta.CREATED_AT >= '2024-07-26' and ta.CREATED_AT < '2024-07-29'-- 养修预约时间
and ta.DATA_SOURCE = 'C'
and ta.IS_DELETED =0 -- 逻辑删除
and ta.APPOINTMENT_TYPE = '70691005'   -- 养修预约
order by ta.CREATED_AT 