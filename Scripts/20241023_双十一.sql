--拼团效果分析
--拼团表： tt_order_group_buy
--拼团详情表： tt_order_group_buy_detail
select *
from ods_orde.ods_orde_tt_order_group_buy_d 

--发起拼团人数
select 
gb.spu_id ,
toDate(g.create_time)  t,
count(distinct case when g.is_leader=1 then g.member_id else null end) `发起拼团人数（汇总）`,
count(distinct case when g.is_leader=1 and m.is_vehicle=1 then g.member_id else null end) `发起拼团人数（车主）`,
count(distinct case when g.is_leader=1 and m.is_vehicle=0 then g.member_id else null end) `发起拼团人数（粉丝）`,
count(distinct g.member_id ) `参与拼团人数（汇总）`,
count(distinct case when m.is_vehicle=1 then g.member_id else null end) `参与拼团人数（车主）`,
count(distinct case when m.is_vehicle=0 then g.member_id else null end) `参与拼团人数（粉丝）`,
count(distinct case when gb.group_status=3 then g.member_id else null end) `拼团成功人数（汇总）`,
count(distinct case when gb.group_status=3 and m.is_vehicle=1 then g.member_id else null end) `拼团成功人数（车主）`,
count(distinct case when gb.group_status=3 and m.is_vehicle=0 then g.member_id else null end) `拼团成功人数（粉丝）`
-- g.member_id,
-- m.is_vehicle ,
-- gb.id ,
-- gb.spu_id 
from ods_orde.ods_orde_tt_order_group_buy_detail_d g  
left join ods_orde.ods_orde_tt_order_group_buy_d gb on g.group_id =gb.id and gb.is_deleted =0
left join ods_memb.ods_memb_tc_member_info_cur m on g.member_id::String =m.id ::String 
where 1=1
--and g.is_leader=1 -- 团长
and g.is_deleted =0
and g.create_time >='2024-11-01'
and g.create_time <'2024-11-12'
group by 1,2 with rollup
order by 1,2 



--test
select 
toDate(g.create_time)  t,
count(distinct case when g.is_leader=1 then g.member_id else null end) `发起拼团人数（汇总）`,
count(distinct case when g.is_leader=1 and m.is_vehicle=1 then g.member_id else null end) `发起拼团人数（车主）`,
count(distinct case when g.is_leader=1 and m.is_vehicle=0 then g.member_id else null end) `发起拼团人数（粉丝）`,
count(distinct g.member_id ) `参与拼团人数（汇总）`,
count(distinct case when m.is_vehicle=1 then g.member_id else null end) `参与拼团人数（车主）`,
count(distinct case when m.is_vehicle=0 then g.member_id else null end) `参与拼团人数（粉丝）`,
count(distinct case when gb.group_status=3 then g.member_id else null end) `拼团成功人数（汇总）`,
count(distinct case when gb.group_status=3 and m.is_vehicle=1 then g.member_id else null end) `拼团成功人数（车主）`,
count(distinct case when gb.group_status=3 and m.is_vehicle=0 then g.member_id else null end) `拼团成功人数（粉丝）`
-- g.member_id,
-- m.is_vehicle ,
-- gb.id ,
-- gb.spu_id 
from ods_orde.ods_orde_tt_order_group_buy_detail_d g  
left join ods_orde.ods_orde_tt_order_group_buy_d gb on g.group_id =gb.id and gb.is_deleted =0
left join ods_memb.ods_memb_tc_member_info_cur m on g.member_id::String =m.id ::String 
where 1=1
--and g.is_leader=1 -- 团长
and g.is_deleted =0
and g.create_time >='2024-11-01'
and g.create_time <'2024-11-12'
and g.group_id =36
group by 1 
order by 1 

参与拼团人数
拼团成功人数





-- 卡券明细
-- 卡券明细
select 
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
left join organization.tm_company declear_list on declear_list.company_name_cn = top.associate_dealer and declear_list.IS_DELETED = 0
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
	select
	a.vin
	,a.tel
	,b.code_cn_desc 跟进状态
	,a.item_name
	from dms_manage.tt_invite_vehicle_record a
	left join dictionary.tc_code b on a.follow_status=b.code_id
	where a.created_at>='2024-10-31'
	and a.invite_type = 82381011  --厂端自建
	and a.advise_in_date = '2024-11-24 00:00:00'
	) dt on dt.vin =top.associate_vin and tci.coupon_name  like concat('%',dt.item_name,'%')
	where 1=1
	and date(to2.create_time) >= '2024-10-25' 
	and date(to2.create_time) < '2024-11-12' 
	and tcd.is_deleted=0 
	and top.spu_id in ( '3996', 
 '3989', 
 '3990', 
 '3983', 
 '3991', 
 '3993', 
 '3992', 
 '3997', 
 '3978', 
 '3982', 
 '3980', 
 '3979', 
 '3973', 
 '3972', 
 '3971', 
 '3970', 
 '3995', 
 '3969', 
 '3977', 
 '3975', 
 '3974', 
 '3981')
	
 
 
  select
a.vin
,a.tel
,b.code_cn_desc 跟进状态
,a.item_name 邀约名称
from dms_manage.tt_invite_vehicle_record a
left join dictionary.tc_code b on a.follow_status=b.code_id
where a.created_at>='2024-10-31'
and a.invite_type = 82381011  --厂端自建
and a.advise_in_date = '2024-11-24 00:00:00'
--and a.vin ='LYVUEL1D1PB349624'


