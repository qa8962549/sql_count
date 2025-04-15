--拼团效果分析
--拼团表： tt_order_group_buy
--拼团详情表： tt_order_group_buy_detail
select *
from ods_orde.ods_orde_tt_order_group_buy_d 

--发起拼团人数
select 
gb.spu_id ,
toDate(g.create_time)  t,
concat(toString(gb.spu_id),toString(toDate(g.create_time)))x,
count(distinct case when g.is_leader=1 then g.member_id else null end) `发起拼团人数（汇总）`,
count(distinct case when g.is_leader=1 and m.is_vehicle=1 then g.member_id else null end) `发起拼团人数（车主）`,
count(distinct case when g.is_leader=1 and m.is_vehicle=0 then g.member_id else null end) `发起拼团人数（粉丝）`,
count(distinct g.member_id ) `参与拼团人数（汇总）`,
count(distinct case when m.is_vehicle=1 then g.member_id else null end) `参与拼团人数（车主）`,
count(distinct case when m.is_vehicle=0 then g.member_id else null end) `参与拼团人数（粉丝）`,
count(distinct case when gb.group_status=3 then g.member_id else null end) `拼团成功人数（汇总）`,
count(distinct case when gb.group_status=3 and m.is_vehicle=1 then g.member_id else null end) `拼团成功人数（车主）`,
count(distinct case when gb.group_status=3 and m.is_vehicle=0 then g.member_id else null end) `拼团成功人数（粉丝）`
from ods_orde.ods_orde_tt_order_group_buy_detail_d g  
left join ods_orde.ods_orde_tt_order_group_buy_d gb on g.group_id =gb.id and gb.is_deleted =0
left join ods_memb.ods_memb_tc_member_info_cur m on g.member_id::String =m.id::String 
where 1=1
--and g.is_leader=1 -- 团长
and g.is_deleted =0
and g.create_time >='2024-11-25'
and g.create_time <'2024-12-26'
group by 1,2,3 with rollup
order by 1,2,3
--settings join_use_nulls=1


-- 优惠券核销情况1
		with base as (
select 
distinct 
	tci.coupon_name 卡券名称
	,if(dt.vin is not null ,'是','否') 是否下发过
	,dt.跟进状态 跟进状态
	,tcd.coupon_id 卡券id
	,tci.coupon_value/100 卡券面额
	,tci.coupon_code 券号
	,tcd.member_id 会员id
	,tcd.one_id cust_id
	,tmi.member_name 会员昵称
	,tmi.real_name 姓名
--	,tmi.member_phone 沃世界注册手机号
--	,top.associate_vin 购买关联vin
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
left join organization.tm_company declear_list on declear_list.company_name_cn = top.associate_dealer and declear_list.IS_DELETED = 0 and COMPANY_TYPE = 15061003 
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
left join(
		SELECT
		    a.vin,
		    a.tel,
		    b.code_cn_desc AS 跟进状态,
		    a.item_name,
		    (string_to_array(a.item_name, '-'))[1] AS part1, -- 拆分后的第一部分
		    (string_to_array(a.item_name, '-'))[2] AS part2 -- 拆分后的第二部分
		FROM dms_manage.tt_invite_vehicle_record a
		LEFT JOIN dictionary.tc_code b ON a.follow_status = b.code_id
		WHERE a.created_at >= '2024-11-01'
		    AND a.invite_type = 82381011  --厂端自建
		    AND a.advise_in_date = '2024-12-31 00:00:00' -- 业务手动录入，对应秋冬服
		    ) dt on dt.vin =top.associate_vin and tci.coupon_name  like concat('%',part1,'%')
	where 1=1
	and date(tcd.get_date) >= '2024-11-25' 
	and date(tcd.get_date) < '2024-12-26' 
	and tcd.is_deleted=0 
--	and tci.coupon_code in ('KQ202411190003',
--'KQ202411190004',
--'KQ202411210001',
--'KQ202411190002',
--'KQ202411190001'
--)
	and tcd.coupon_id in ('8157',
'8158',
'8172',
'8156',
'8155'
)
)
select
--	券号
	卡券id
	,count(case when 卡券状态<>'已作废' then 卡券id end) as 发放数有效
	,count(case when 卡券状态='已核销 ' then 卡券id end) as 核销数
	,count(case when 卡券状态='已核销 ' then 卡券id end)/count(1) `核销率`
--	,sum(是否退款)/count(1) `退款率`
--	,sum(是否退款) 退款数
--	,sum(总金额) `销售金额（含退款）`
--	,sum(case when 是否退款=0 then 总金额 else 0 end)`销售金额（不含退款）`
from base
GROUP BY 1
order by 1 


-- 优惠券核销情况2
		with base as (
select 
distinct 
	tci.coupon_name 卡券名称
	,if(dt.vin is not null ,'是','否') 是否下发过
	,dt.跟进状态 跟进状态
	,tcd.coupon_id 卡券id
	,tci.coupon_value/100 卡券面额
	,tci.coupon_code 券号
	,tcd.member_id 会员id
	,tcd.one_id cust_id
	,tmi.member_name 会员昵称
	,tmi.real_name 姓名
--	,tmi.member_phone 沃世界注册手机号
--	,top.associate_vin 购买关联vin
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
left join organization.tm_company declear_list on declear_list.company_name_cn = top.associate_dealer and declear_list.IS_DELETED = 0 and COMPANY_TYPE = 15061003 
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
left join(
		SELECT
		    a.vin,
		    a.tel,
		    b.code_cn_desc AS 跟进状态,
		    a.item_name,
		    (string_to_array(a.item_name, '-'))[1] AS part1, -- 拆分后的第一部分
		    (string_to_array(a.item_name, '-'))[2] AS part2 -- 拆分后的第二部分
		FROM dms_manage.tt_invite_vehicle_record a
		LEFT JOIN dictionary.tc_code b ON a.follow_status = b.code_id
		WHERE a.created_at >= '2024-11-01'
		    AND a.invite_type = 82381011  --厂端自建
		    AND a.advise_in_date = '2024-12-31 00:00:00' -- 业务手动录入，对应秋冬服
		    ) dt on dt.vin =top.associate_vin and tci.coupon_name  like concat('%',part1,'%')
	where 1=1
--	and date(to2.create_time) >= '2024-11-25' 
--	and date(to2.create_time) < '2024-12-02' 
	and date(tcd.get_date) >= '2024-11-25' 
	and date(tcd.get_date) < '2024-12-26' 
	and tcd.is_deleted=0 
	and tci.coupon_code in ('KQ202410210010',
'KQ202410210011',
'KQ202410240001',
'KQ202410240002',
'KQ202410240004',
'KQ202410240005',
'KQ202410240010',
'KQ202410240007',
'KQ202410240009',
'KQ202410240012',
'KQ202410240006',
'KQ202410240008',
'KQ202410240011',
'KQ202410240003',
'KQ202410240013',
'KQ202410240020',
'KQ202410240014',
'KQ202410240015',
'KQ202410240016',
'KQ202410240017',
'KQ202410240018',
'KQ202410240019',
'KQ202410240021',
'KQ202410240024',
'KQ202410240023',
'KQ202410240022',
'KQ202410240025',
'KQ202410240026',
'KQ202410240029',
'KQ202405240026'
)
)
select
	券号
	,count(case when 卡券状态<>'已作废' then 卡券id end) as 发放数有效
	,count(case when 卡券状态='已核销 ' then 卡券id end) as 核销数
	,count(case when 卡券状态='已核销 ' then 卡券id end)/count(case when 卡券状态<>'已作废' then 卡券id end) `核销率`
--	,sum(是否退款)/count(1) `退款率`
--	,sum(是否退款) 退款数
--	,sum(总金额) `销售金额（含退款）`
--	,sum(case when 是否退款=0 then 总金额 else 0 end)`销售金额（不含退款）`
from base
GROUP BY 1
order by 1 desc 


-- 卡券明细
-- 卡券明细
select 
distinct 
	tci.coupon_name 卡券名称
	,if(dt.vin is not null ,'是','否') 是否下发过
	,dt.跟进状态 跟进状态
	,tcd.coupon_id 卡券id
	,tci.coupon_value/100 卡券面额
	,tci.coupon_code 券号
	,tcd.member_id 会员id
	,tcd.one_id cust_id
	,tmi.member_name 会员昵称
	,tmi.real_name 姓名
--	,tmi.member_phone 沃世界注册手机号
--	,top.associate_vin 购买关联vin
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
left join organization.tm_company declear_list on declear_list.company_name_cn = top.associate_dealer and declear_list.IS_DELETED = 0 and COMPANY_TYPE = 15061003 
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
left join(
		SELECT
		    a.vin,
		    a.tel,
		    b.code_cn_desc AS 跟进状态,
		    a.item_name,
		    (string_to_array(a.item_name, '-'))[1] AS part1, -- 拆分后的第一部分
		    (string_to_array(a.item_name, '-'))[2] AS part2 -- 拆分后的第二部分
		FROM dms_manage.tt_invite_vehicle_record a
		LEFT JOIN dictionary.tc_code b ON a.follow_status = b.code_id
		WHERE a.created_at >= '2024-11-01'
		    AND a.invite_type = 82381011  --厂端自建
		    AND a.advise_in_date = '2024-12-31 00:00:00' -- 业务手动录入，对应秋冬服
		    ) dt on dt.vin =top.associate_vin and tci.coupon_name  like concat('%',part1,'%')
	where 1=1
	and date(to2.create_time) >= '2024-11-25' 
	and date(to2.create_time) < '2024-12-02' 
	and tcd.is_deleted=0 
	and top.spu_id in ( '4048', 
 '4055', 
 '4055', 
 '4007', 
 '4042', 
 '3930', 
 '3873', 
 '3874', 
 '4041', 
 '4047', 
 '4046', 
 '4045', 
 '4044', 
 '4043', 
 '4037')
	



