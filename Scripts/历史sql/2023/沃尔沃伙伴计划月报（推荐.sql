表名称：tm_invite_code		描述:邀约code表						
表名称：tm_invite_fail		描述:邀约失败记录表						
表名称：tm_invite_record		描述:邀约记录表						
表名称：tm_invite_reward		描述:邀约奖励表						

-- 当月成功邀请试驾留资-推荐者人数分布
select 
case when x.成功人数='0' then '邀请0人'
	when x.成功人数>='1' and x.成功人数<='3' then '邀请1-3人'
	when x.成功人数>='4' and x.成功人数<='6' then '邀请4-6人'
	when x.成功人数>='7' and x.成功人数<='10' then '邀请7-10人'
	when x.成功人数>='10' then '邀请10人以上'
	end as '当月成功邀请试驾留资-推荐者人数分布',
count(1)
from 
	(
	SELECT a.invite_member_id,
	COUNT(a.be_invite_member_id) 成功人数
	from invite.tm_invite_record a
	where a.is_deleted =0
	and month(a.create_time)=10 -- 10月数据
	group by 1
    )x
group by 1 
order by 1

-- 当月成功到店试驾-推荐者人数分布
select 
case when x.成功人数='0' then '邀请0人'
	when x.成功人数>='1' and x.成功人数<='3' then '邀请1-3人'
	when x.成功人数>='4' and x.成功人数<='6' then '邀请4-6人'
	when x.成功人数>='7' and x.成功人数<='10' then '邀请7-10人'
	when x.成功人数>='10' then '邀请10人以上'
	end as '当月成功邀请试驾留资-推荐者人数分布',
count(1)
from 
	(
	SELECT a.invite_member_id,
	COUNT(a.be_invite_member_id) 成功人数
	from invite.tm_invite_record a
	where a.drive_status =1 -- 成功试驾
	and a.is_deleted =0
	and month(a.create_time)=10 -- 邀请时间10月
	and month(a.drive_time)=10 -- 试驾时间10月（当月试驾）
	group by 1
    )x
group by 1 
order by 1

-- 当月成功推荐购车-推荐者人数分布
select 
case when x.成功人数='0' then '邀请0人'
	when x.成功人数='1' then '邀请1人'
	when x.成功人数='2' then '邀请2人'
	when x.成功人数='3' then '邀请3人'
	when x.成功人数='4' then '邀请4人'
	when x.成功人数='5' then '邀请5人'
	when x.成功人数='6' then '邀请6人'
	end as '当月成功邀请试驾留资-推荐者人数分布',
count(1)
from 
	(
	SELECT a.invite_member_id,
	COUNT(a.be_invite_member_id) 成功人数
	from invite.tm_invite_record a
	where a.buy_status =1 -- 成功购车
	and a.is_deleted =0
	and month(a.create_time)=10 -- 邀请时间10月
	and month(a.buy_time)=10 -- 购车时间10月（当月购车）
	group by 1
    )x
group by 1
order by 1


-- 经销商渗透率分布
select x.销售经销商代码,
count(x.下单人手机号) 经销商推荐购开票数
from 
	(
		# 订单表
		select 
		    a.SO_NO 销售订单号,
		    a.OWNER_CODE 销售经销商代码,
		    a.CREATED_AT 订单日期,
		    a.SHEET_CREATE_DATE 开单日期,
		    a.CUSTOMER_NAME 客户姓名,
		    a.DRAWER_NAME 开票人姓名,
		    a.DRAWER_TEL 开票人电话,
		    a.CONTACT_NAME 联系人姓名,
		    a.CUSTOMER_TEL 潜客电话,
		    a.PURCHASE_PHONE 下单人手机号,
		    g.CODE_CN_DESC 订单状态,
		    case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
		    b.active_code 市场活动代码,
		    d.SALES_VIN 车架号,
		    f.model_name 车型,
		    j.CODE_CN_DESC 线索客户类型,
		    k.CODE_CN_DESC 客户性别,
		    l.CODE_CN_DESC 交车状态,
		    n.CODE_CN_DESC 订单购买类型,
		    a.VEHICLE_RETURN_DATE 退车完成日期,
		    m.CODE_CN_DESC 退车状态,
		    a.RETURN_REASON 退单原因,
		    a.RETURN_REMARK 退单备注,
		    r.invite_mobile 邀请人手机号
		from cyxdms_retail.tt_sales_orders a 
		left join invite.tm_invite_record r on r.be_invite_mobile=a.PURCHASE_PHONE
		left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
		left join customer_business.tm_clue_source c on c.ID = b.active_channel
		left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
		left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
		left join basic_data.tm_model f on f.id = e.SECOND_ID
		left join dictionary.tc_code g on g.code_id = a.SO_STATUS
		left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
		left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
		left join dictionary.tc_code k on k.code_id = a.GENDER
		left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
		left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
		left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
		where a.BUSINESS_TYPE <> 14031002
		and a.IS_DELETED = 0
		and a.CREATED_AT >= '2022-10-01'
		and a.CREATED_AT < curdate()
		and b.active_code in ('IBDMSEPWSJTJGLZS2022VCCN','IBDMSEPWEWHBLSZS2022VCCN')
		order by a.CREATED_AT)x where x.'订单是否有效'='Y' group by 1

-- 预约车型明细
SELECT 
c.MODEL_NAME,
count(a.id) 预约数,
count(case when a.drive_status =1 then 1 else null end) 到店试驾数,
count(case when a.buy_status =1 then 1 else null end ) 订单转化数
from invite.tm_invite_record a
left join cyx_appointment.tt_appointment_drive b on a.be_invite_mobile =b.PHONE 
left join basic_data.tm_model c on b.SECOND_ID =c.SERIES_ID 
where a.is_deleted =0
-- and month(a.drive_time)=10 -- 试驾时间10月（当月试驾）
and MONTH(a.create_time)=10 -- 邀请时间10月 
group by 1
order by 1

-- 勋章发放人数
select
COUNT(a.medal_id)勋章数量 
from mine.madal_detail a 
join invite.tm_invite_record b on a.user_id =b.invite_member_id
where a.create_time <= NOW() 
and a.status = 1  -- 正常
and a.deleted = 1  -- 有效
and a.medal_id =6 -- 人气推荐官
and month(a.create_time)=10
