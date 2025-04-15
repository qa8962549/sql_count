-- 伙伴计划日报 ##推荐购数据明细表
select
DISTINCT 
r.create_time 推荐日期,
r.invite_member_id 推荐人会员ID,
v.VIN 推荐人VIN,
m.MEMBER_NAME 推荐人姓名,
case when a.active_code = 'IBDMSEPWSJTJGLZS2022VCCN' then '沃世界小程序'
	when a.active_code = 'IBDMSEPWEWHBLSZS2022VCCN' then 'APP'
	else null end 推荐渠道,
-- '沃世界小程序' 推荐渠道,
x.成功人数 年累计推荐成功试驾人数,
case when x.成功人数>='100' then '是'
	else '否' end 是否达到推荐试驾成功奖励上限,
x1.推荐人当前季度成功推荐台数,
m2.MEMBER_NAME 被推荐人姓名,
r.be_invite_mobile 被推荐人留资手机号,
-- x2.预约日期,
r.reserve_time 预约试驾日期,
r.drive_time 到店试驾日期,
x2.经销商代码 试驾经销商代码,
x2.车型 试驾车型,
x2.姓名 实际试驾人姓名,
-- r.payment_time 'XC40 R/C40R 大定时间',
xx.订单创建时间 'XC40 R/C40R 大定时间',
r.blue_invoice_time 开票日期,
d.开票人姓名 开票抬头,
d.车型 开票车型,
d.车架号 开票Vin码,
d.销售经销商代码 开票经销商代码,
'是' 是否30天内首次留资,
case when x3.试驾状态 is null and r.drive_time is not null then '是'
	when x3.试驾状态 is not null then '否' 
	end '是否首次到店试驾',
x2.预约手机号 试驾人手机号,
DATE_FORMAT(tir.create_time,'%Y-%m-%d')月度推荐试驾奖励发放日期,
d.开票人电话 开票人手机号,
tir2.create_time 月度推荐购车奖励发放日期,
tir3.create_time 季度推荐购车奖发放日期
from invite.tm_invite_record r -- 邀约留资表
left join invite.tm_invite_reward tir on tir.member_id = r.be_invite_member_id and tir.reward_num =1000 and tir.is_deleted =0 -- 月度试驾
left join invite.tm_invite_reward tir2 on tir2.member_id = r.be_invite_member_id and tir2.reward_num =3000 and tir2.is_deleted =0 -- 月度购车奖励时间
left join invite.tm_invite_reward tir3 on tir3.member_id = r.be_invite_member_id and tir3.reward_num =1500 and tir3.is_deleted =0 -- 季度购车奖励时间
left join `member`.tc_member_info m on r.invite_member_id = m.ID and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
left join `member`.tc_member_info m2 on r.be_invite_member_id =m2.id and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
left join
(
	# 匹配被推荐人留资相关信息
	select 
	    a.dealer_code 经销商代码,
	    h.COMPANY_NAME_CN 经销商名称,
	    a.name 客户姓名,
	    a.mobile,
	    f.MODEL_NAME 意向车型,
	    a.allot_time 线索下发时间,
	    a.handle_time 采集时间,
	    a.create_time 线索创建时间,
	    e.CODE_CN_DESC 线索状态,
	    c.active_code
	from customer.tt_clue_clean a 
	left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
	left join activity.cms_active c on a.campaign_id = c.uid
	left join customer_business.tm_clue_source d on d.ID = c.active_channel
	left join dictionary.tc_code e on a.clue_status = e.CODE_ID
	left join basic_data.tm_model f on a.model_id = f.ID 
	left join `member`.tc_member_info tmi on tmi.MEMBER_PHONE = a.mobile and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
	left join 
	(
	    select 
	    tm.COMPANY_CODE,	
		tm.COMPANY_NAME_CN
	    from organization.tm_company tm
	    where tm.IS_DELETED = 0
	    and tm.COMPANY_TYPE = 15061003
	) h on h.COMPANY_CODE = a.dealer_code
	where 
	a.create_time >= '2022-10-01'
	and a.create_time <CURDATE() 
	and c.active_code in ('IBDMSEPWSJTJGLZS2022VCCN','IBDMSEPWEWHBLSZS2022VCCN')    -- 小程序＆APP 市场活动代码
-- 	and a.mobile='18888295525'
	group by a.mobile
) a on r.be_invite_mobile = a.mobile
left join 
		(# 被邀请人是否首次APP/小程序预约试驾
	 select
	 r.be_invite_mobile,
	 ta.*
	 from invite.tm_invite_record r
	 left join
	 (
	  SELECT
	  DISTINCT ta.APPOINTMENT_ID 预约ID,
	  ta.customer_phone 手机号,
	  CASE tad.status
	   WHEN 70711001 THEN '待试驾'
	      WHEN 70711002 THEN '已试驾' 
	      WHEN 70711003 THEN '已取消'
	      END 试驾状态,
	  tad.drive_s_at 试驾开始时间,
	  tad.drive_e_at 试驾结束时间
	  FROM cyx_appointment.tt_appointment ta
	  LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	  LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
	  WHERE ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	  AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
-- 	  and ca.active_code not in ('IBDMSEPWSJTJGLZS2022VCCN','IBDMSEPWEWHBLSZS2022VCCN')    -- 小程序、APP市场活动代码
-- 	  and tad.STATUS = '70711002'  -- 已完成试驾
-- 	  and ta.customer_phone = '18307006595'
	 ) ta on r.be_invite_mobile = ta.手机号
	 where r.is_deleted = 0
	 and r.create_time >= '2022-10-01'
	 and r.create_time < CURDATE()
	 -- and be_invite_mobile = '18307006595'
	 ) x3 on x3.be_invite_mobile=r.be_invite_mobile  
left join 
	(
	-- 预约试驾
	select
	DISTINCT ta.APPOINTMENT_ID 预约ID,
	ta.CREATED_AT 预约日期,
	ta.OWNER_CODE 经销商代码,
	ca.active_code,
	-- tc2.COMPANY_NAME_CN "经销商名称",
	tad.user_name 姓名,
	tad.phone 预约手机号,
	tmi.ID 会员ID,
	tmi.MEMBER_PHONE 沃世界绑定手机号,
	tm.MODEL_NAME 车型,
-- 	ta.INVITATIONS_DATE 预约试驾日期,
	tad.drive_s_at 试驾开始时间,
	case when tc.code_id = '70711001' then '预约待试驾'
		when tc.code_id = '70711002' then '预约已试驾'
		when tc.code_id = '70711003' then '预约已取消'
		end '预约试驾状态'
	from cyx_appointment.tt_appointment ta
	left join cyx_appointment.tt_appointment_drive tad on ta.APPOINTMENT_ID = tad.APPOINTMENT_ID
	left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
	left join basic_data.tm_model tm on tad.SECOND_ID = tm.SERIES_ID
	left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.MODEL_NAME 
	left join dictionary.tc_code tc on tad.STATUS = tc.CODE_ID 
	-- left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
	LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
	where ta.IS_DELETED = 0 
	and ta.CREATED_AT>='2022-10-01'
	and ta.CREATED_AT < CURDATE() 
-- 	and ca.active_code in ('IBDMSEPWSJTJGLZS2022VCCN','IBDMSEPWEWHBLSZS2022VCCN')
-- 	and tc.code_id <> '70711003'
-- 	and tad.phone='13801959504'
-- 	and tmi.MEMBER_PHONE ='13810959504'
	group by tmi.MEMBER_PHONE
) x2 on x2.沃世界绑定手机号=r.be_invite_mobile 
left join 	
(
	SELECT a.invite_member_id,
	COUNT(a.be_invite_member_id) 成功人数
	from invite.tm_invite_record a
	where a.drive_status =1 -- 成功试驾
	and a.is_deleted =0
-- 	and month(a.create_time)=10 -- 邀请时间10月
-- 	and month(a.drive_time)=10 -- 试驾时间10月（当月试驾）
	group by 1
 )x on x.invite_member_id = m.id
 left join
(
select x.邀请人手机号,
count(x.下单人手机号) 推荐人当前季度成功推荐台数
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
		left join invite.tm_invite_record r on r.be_invite_mobile=a.PURCHASE_PHONE and r.is_deleted =0
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
-- 		and b.active_code in ('IBDMSEPWSJTJGLZS2022VCCN','IBDMSEPWEWHBLSZS2022VCCN')
-- 		and a.PURCHASE_PHONE=18600310677
-- 		and r.invite_mobile=13581933003
		order by a.CREATED_AT
	)x where x.'订单是否有效'='Y' 
	group by 1
) x1 on r.invite_mobile = x1.邀请人手机号
left join
(
	# 取推荐人最新绑定的VIN
	select v.MEMBER_ID,v.VIN from
	(
		select
		v.MEMBER_ID,
		v.VIN,
		row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
		from member.tc_member_vehicle v
		left join `member`.tc_member_info m on v.MEMBER_ID = m.ID and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
		where v.is_deleted = 0
		and v.MEMBER_ID is not null
-- 		and v.MEMBER_ID=3039225
	) v
	where v.rk = 1 
-- 	and v.MEMBER_ID=3039225
) v on r.invite_member_id = v.MEMBER_ID
left join
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
		    a.RETURN_REMARK 退单备注
		from cyxdms_retail.tt_sales_orders a 
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
	 	and a.CREATED_AT <curdate()
-- 		and b.active_code in ('IBDMSEPWSJTJGLZS2022VCCN','IBDMSEPWEWHBLSZS2022VCCN')
		order by a.CREATED_AT
	) d on r.be_invite_mobile = d.下单人手机号 and d.'订单是否有效'='Y' 
left join (-- 付大定的车主
 select
 tso.CUSTOMER_TEL 下单人手机号,
 tso.drawer_tel 开票人手机号,
 tsov.sales_vin 新车车架号,
 tso.so_no 销售订单号,
 tso.created_at 订单创建时间,
 tsov.cancel_time 订单取消时间,
 case when tsod.second_id = '1041' then 'XC40 RECHARGE'
  when tsod.second_id = '1051' then '全新纯电C40'
  end 车型,
 tc.CODE_CN_DESC 是否交定金
 from cyxdms_retail.tt_sales_orders tso
 left join dictionary.tc_code tc on tso.IS_DEPOSIT = tc.CODE_ID
 inner join cyxdms_retail.tt_sales_order_detail tsod on tso.so_no_id = tsod.so_no_id
 inner join cyxdms_retail.tt_sales_order_vin tsov on tso.so_no = tsov.vi_no
 and tsod.second_id in (1041,1051)    -- 筛选车型
 and tso.is_deposit = '10041001'    -- 是否交定金 1 是  2 否 都算付定的
 and tso.CREATED_AT >= '2022-10-01'
 and tso.CREATED_AT <curdate()
 and tso.IS_DELETED = 0
 and tso.owner_code = 'VVD'   -- 筛选直售订单
 and tso.CUSTOMER_TEL in
 (
  select distinct r.be_invite_mobile from invite.tm_invite_record r where r.is_deleted = 0
  and r.create_time >= '2022-10-01' and r.create_time <= CURDATE() 
 )
 -- and tso.customer_tel = '18050959362'
) xx on xx.下单人手机号=r.be_invite_mobile 
where r.create_time >= '2022-10-01'   -- 被邀请人留资时间
and r.create_time <CURDATE() 
and r.is_deleted='0'
-- and r.be_invite_mobile=18050959362
group by r.relation_id 
order by 1

##渠道有效性分析
SELECT CASE
		when t.`data` like '%9CC1368AE9A5497B9CF9483802A0DDD0%' then '首页弹窗' 
		when t.`data` like '%C96DCE5418A04C1999202DD4258A750F%' then '置顶banner' 
		when t.`data` like '%AAE79B254264415EA66A1FC95A1B6E11%' then '沃的活动banner' 
		when t.`data` like '%C7FBA150D1A14174BAA35A0211C2DC3F%' then '朋友圈海报太阳码' 
		when t.`data` like '%A211C055580447E78FBC721501F65955%' then '月历订阅服务通知' 
		when t.`data` like '%6BD913525F3D4B06BFD4B6F5E12F605F%' then '推文引流' 
		when t.`data` like '%A417E468587E4D4AA83CDF9B5F537E24%' then '推荐购长图文' 
		when t.`data` like '%2F8205E592BB429C96EDA1EF99B10403%' then '沃尔沃汽车小程序banner' 
		when t.`data` like '%F997750D3D8D4654A8887A74DE07874F%' then '签到banner' 
		when t.`data` like '%AF27CA8FD72C45FBACAC1C37A3615BEC%' then '新关注欢迎语' 
		when t.`data` like '%C81E633060C54184A83D562D0F18B9AC%' then '菜单栏引导' 
		when t.`data` like '%9C05CF5232394D56B6F60A10C27C578D%' then '活动list Banner' 
		when t.`data` like '%AE21A451B55E4E1B9CA41EC386DE44BF%' then '一店一码banner' 
		when t.`data` like '%1AE26BE4FD5D47C390515852B6F7F687%' then '易拉宝/台卡线下物料' 
		when t.`data` like '%54C2E285D5B849AF896023E0EEA6CB0F%' then '12服专区-快捷服务' 
		when t.`data` like '%6986F0B3542248F7AAC81B5ADDE010B7%' then '沃世界-探索模块' 
		when json_extract(t.`data`,'$.embeddedpoint')='试驾专区_点击活动速递' then '沃世界-试驾享好礼-活动速递' 
		when t.`data` like '%EA524A22F6874074B96E8CB9BC231F9B%' then '经销商海报太阳码' 
		when t.`data` like '%43D379330439445CBFC004415AC6C9C9%' then '勋章跳转'
		when t.`data` like '%D0C743BE27854A2B93AD685400DC154D%' then '我的页面跳转' 
		when t.`data` like '%DB21C934ED1649E1A81F1E01AD5B4DA7%' then '最新绑定的新车主' 
		when t.`data` like '%6F9EB6932EBA4111A182CC3B387DD486%' then '预约养修人群' 
		when t.`data` like '%9220980B773D46A9B5C48D06717A5B4F%' then '30天以上90天内未登陆沃世界车主'
		when t.`data` like '%B056F900EEA345BEA35CF11666E85C37%' then '90天以上180天内未登录的车主'
		end 分类,
-- 		t.usertag,
-- 		b.'客户ID',
-- 		b.'姓名'
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV,
count(DISTINCT b.'客户ID') 预约试驾，
COUNT(DISTINCT c.CUSTOMER_ID) 成功购车
from track.track t
left join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join (
SELECT
DISTINCT ta.APPOINTMENT_ID 预约ID,
ta.CREATED_AT 预约时间,
ta.ARRIVAL_DATE 实际到店日期,
ca.active_name 活动名称,
ta.one_id 客户ID,
ta.customer_name 姓名,
ta.customer_phone 手机号,
h.大区,
h.小区,
ta.OWNER_CODE 经销商,
tc2.COMPANY_NAME_CN 经销商名称,
CASE tad.status
	WHEN 70711001 THEN '待试驾'
    WHEN 70711002 THEN '已试驾' 
    WHEN 70711003 THEN '已取消'
    END 试驾状态,
tm.model_name 车型,
tad.drive_s_at 试驾开始时间,
tad.drive_e_at 试驾结束时间
FROM cyx_appointment.tt_appointment ta
LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
LEFT JOIN organization.tm_company tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
LEFT JOIN cyxdms_retail.tt_sales_orders tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID
left join basic_data.tm_model tm on tad.SECOND_ID = tm.SERIES_ID
left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.MODEL_NAME 
LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS
LEFT JOIN (
    select 
        DISTINCT
        tm.COMPANY_CODE,
        tg2.ORG_NAME 大区,
        tg1.ORG_NAME 小区
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
    ORDER BY tm.COMPANY_CODE ASC) h on h.COMPANY_CODE = ta.owner_code
WHERE ta.CREATED_AT >= '2022-10-01'
AND ta.CREATED_AT < curdate()
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code in ('IBDMSEPWSJTJGLZS2022VCCN','IBDMSEPWEWHBLSZS2022VCCN')   -- 销售六服 “福”务到位-告别你的油滤
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT) b on tmi.CUST_ID = b.'客户ID'
left join (
select DISTINCT 
   a.CUSTOMER_TEL 潜客电话,
   a.CUSTOMER_ID
from cyxdms_retail.tt_sales_orders a 
left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
where a.BUSINESS_TYPE<>14031002
and a.IS_DELETED = 0
and a.CREATED_AT >= '2022-10-01' AND a.CREATED_AT <curdate()
and b.active_code in ('IBDMSEPWSJTJGLZS2022VCCN','IBDMSEPWEWHBLSZS2022VCCN')) c on b.'手机号' = c.'潜客电话'
where t.`date` >= '2022-10-01' and t.`date` < curdate()
group by 1
order by 1