-- PV UV 23预热页 ，24-30正式页 6E5767DD3B724D5C815F2E11255247EA
select 
COUNT(t.usertag) PV,
COUNT(distinct t.usertag) UV
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-05-23'
and t.`date` <= '2022-05-30 23:59:59'
and (json_extract(t.`data`,'$.embeddedpoint') = 'collectionPage_home_预热_click' or json_extract(t.`data`,'$.embeddedpoint') = 'collectionPage_home_正式_click')

-- 养修预约btn点击量
select 
COUNT(t.usertag) PV,
COUNT(distinct t.usertag) UV
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-05-24'
and t.`date` <= '2022-05-30 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint') = 'collectionPage_homePage_repairing_click' 

-- 成功提交养修预约并进厂人数
select COUNT(b.养修预约ID)成功提交养修预约并进厂人数 from
(select
distinct tmi.ID 会员ID
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-05-24' and t.`date` <='2022-05-30 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint') = 'collectionPage_homePage_repairing_click' )a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.COMPANY_NAME_CN "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.ID "会员ID",
       tmi.MEMBER_PHONE "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = "10041001" then "是" 
    when tam.IS_TAKE_CAR = "10041002" then "否" 
     end  "是否取车",
       case when tam.IS_GIVE_CAR = "10041001" then "是"
         when tam.IS_GIVE_CAR = "10041002" then "否"
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta.CREATED_AT "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >= '2022-05-24'
and ta.CREATED_AT < '2022-05-30 23:59:59'
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID
where b.养修状态 in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')

-- 5.23-5.30，小程序新增注册用户数
select count(tmi.id)
from `member`.tc_member_info tmi 
where tmi.CREATE_TIME >='2022-05-23'
and tmi.CREATE_TIME <='2022-05-30 23:59:59'
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0

-- 4.23-4.30，小程序新增注册用户数
select count(tmi.id)
from `member`.tc_member_info tmi 
where tmi.CREATE_TIME >='2022-04-23'
and tmi.CREATE_TIME <='2022-04-30 23:59:59'
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0

-- 5.23-5.30，小程序活跃用户数
select count(x.会员ID)
from 
(
select 
DISTINCT m.id 会员ID,
m.create_time 注册时间,
a.max_date 最近活跃时间,
m.MEMBER_PHONE 手机号
from track.track t 
join 
(select t.usertag,max(t.`date`) max_date
	from track.track t
	group by 1) a on a.usertag = t.usertag
left join member.tc_member_info m on t.usertag = cast(m.USER_ID as varchar)
where m.is_deleted = 0 
and m.member_status <> '60341003'
and (a.max_date >= '2022-5-23 00:00:00' or a.max_date is null) 
and (a.max_date<'2022-5-30 23:59:59'or a.max_date is null)
and (a.max_date > m.MEMBER_TIME or a.max_date is null)
) x

--- Newbie 线索表
select count(DISTINCT x.线索编号)
from 
(select 
    a.clue_id 线索编号,
    cast(a.business_id as varchar) 商机id,
    a.dealer_cod 经销商代码,
    h.COMPANY_NAME_CN 经销商名称,
    h.GROUP_COMPANY_NAME 集团,
    h.ORG_NAME_big 大区,
    h.ORG_NAME_small 小区,
    a.name 客户姓名,
    a.mobile 客户电话,
    i.CODE_CN_DESC 客户性别,
    a.campaign_id 活动代码id,
    c.active_code 市场活动代码,
    c.active_name 市场活动名称,
    d.CLUE_NAME 来源渠道,
    f.model_name 意向车型,
    b.SHOP_NUMBER 到店次数,
    if(b.SHOP_NUMBER>0,'Y','N') 是否到店,
    g.FIRST_DRIVE_TIME 首次试驾时间,
    b.TEST_DRIVE_TIME 试驾次数,
    if(b.TEST_DRIVE_TIME>0,'Y','N') 是否试驾,
    a.allot_time 线索下发时间,
    b.FATE_AFFIRM_TIME 首次跟进时间,
    b.NEW_ACTION_TIME 最后跟进时间,
    a.handle_time 采集时间,
    b.created_at 商机创建时间,
    a.create_time 线索创建时间,
    e.CODE_CN_DESC 线索状态,
    a.smmclueid 线索id_SMM,
    if(a.smmclueid is null,'NEWBIE','SMM') 来源系统,
    a.smmcustid 潜客id_SMM,
    g.FIRST_ORDER_TIME 首次下单时间,
    g.DEFEAT_DATE 战败时间,
    g.MIN_WORK_CALL_TIME 最早工作号外呼时间,
    g.MAX_WORK_CALL_TIME 最新工作号外呼时间,
    g.TOTAL_CALL_NUM newbie外呼次数,
    g.WORK_CALL_NUM 工作号通话次数,
    g.WORK_CONNECT_NUM 工作号接通次数,
    g.WORK_CONNECT_TIMES 工作号累计通话时长
from customer.tt_clue_clean a 
left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
left join activity.cms_active c on a.campaign_id = c.uid
left join customer_business.tm_clue_source d on d.ID = c.active_channel
left join dictionary.tc_code e on a.clue_status = e.CODE_ID
left join basic_data.tm_model f on a.model_id = f.id
left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
left join (
    select 
        tm.id 经销商表ID,
        tm.ORG_ID 经销商组织ID,
        tm.COMPANY_CODE ,	
        tL2.ID 大区组织ID,
        tL2.ORG_NAME ORG_NAME_big,
        tg1.ID 小区组织ID,
        tg1.ORG_NAME ORG_NAME_small,
        tm.COMPANY_NAME_CN ,
        tm.GROUP_COMPANY_NAME
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	) h on h.COMPANY_CODE = a.dealer_code
 left join dictionary.tc_code i on i.code_id = a.gender
where a.create_time between '2022-05-24' and '2022-05-30 23:59:59' 
and c.active_code in('IBDMMARWSJTJGLZS2022VCCN')
)x
-- AND d.CLUE_NAME in ('eVolvo(总部)','eVolvo(经销商)')


a.source_name --线索表自带的来源渠道有缺失,
a.campaign_code --线索表自带的活动code有缺失,
a.campaign_name --线索表自带的活动名称有缺失,

-- 试驾预约量  
select count(DISTINCT x.预约ID)
from 
(SELECT
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
tad.drive_s_at 试驾开始时间,
tad.drive_e_at 试驾结束时间
FROM cyx_appointment.tt_appointment ta
LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
LEFT JOIN organization.tm_company tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
LEFT JOIN cyxdms_retail.tt_sales_orders tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID
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
WHERE ta.CREATED_AT >= '2022-05-24'
AND ta.CREATED_AT <= '2022-05-30 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMMAY525CZJYYS2022VCCN'
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT) x

-- 沃世界试驾明细
select count(x.预约ID)
from 
(SELECT
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
tad.drive_s_at 试驾开始时间,
tad.drive_e_at 试驾结束时间
FROM cyx_appointment.tt_appointment ta
LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
LEFT JOIN organization.tm_company tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
LEFT JOIN cyxdms_retail.tt_sales_orders tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID
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
WHERE ta.CREATED_AT >= '2022-05-24'
AND ta.CREATED_AT < '2022-05-30 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMMAY525CZJYYS2022VCCN'
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT)x
where x.试驾状态='已试驾'


---Newbie 潜客表数据
select count(x.商机id)
from
(
select 
    	cast(b.CUSTOMER_BUSINESS_ID as varchar) 商机id,
    	a.dealer_code 经销商代码,
    	h.COMPANY_NAME_CN 经销商名称,
     h.GROUP_COMPANY_NAME 集团,   
    	h.ORG_NAME_big 大区,
     h.ORG_NAME_small 小区,
     b.created_at 商机创建时间,
    	a.create_time 用户创建时间,
    a.smmid 潜客id_SMM,
    if(a.smmid is null,'NEWBIE','SMM') 来源系统,
	a.name 潜客姓名,
	a.mobile 潜客电话,
    d.CLUE_NAME 来源渠道,
	c.active_code 市场活动代码,
	c.active_name 市场活动名称,
    b.clue_status 潜客状态代码,
    e.CODE_CN_DESC 潜客状态,
    g.model_name 意向车型,
    i.ARCHIVES_TIME 建档时间,	
    i.FIRST_PASSENGER_TIME 首次到店时间,
    b.SHOP_NUMBER 到店次数,
    if(b.SHOP_NUMBER>0,'Y','N') 是否到店,	
    i.FIRST_DRIVE_TIME 首次试驾时间,
    b.TEST_DRIVE_TIME 试驾次数,
    if(b.TEST_DRIVE_TIME>0,'Y','N') 是否试驾,
    i.FIRST_ORDER_TIME 首次下单时间,
    i.DEFEAT_DATE 战败时间,
    i.MIN_WORK_CALL_TIME 最早工作号外呼时间,
    i.MAX_WORK_CALL_TIME 最新工作号外呼时间,
    i.TOTAL_CALL_NUM newbie外呼次数,
    i.WORK_CALL_NUM 工作号通话次数,
    i.WORK_CONNECT_NUM 工作号接通次数,
    i.WORK_CONNECT_TIMES 工作号累计通话时长,
    a.is_deleted
from customer.tt_pontential_customer a
left join customer_business.tt_customer_business b on b.POTENTIAL_CUSTOMERS_ID = a.id and b.IS_DELETED = 0
left join activity.cms_active c on b.MARKET_ACTIVITY = c.uid
left join customer_business.tm_clue_source d on d.ID = c.active_channel
left join dictionary.tc_code e on b.clue_status = e.CODE_ID
left join customer_business.tt_clue_intent f on f.CUSTOMER_BUSINESS_ID = b.CUSTOMER_BUSINESS_ID and f.IS_MAIN_INTENT = 10041001
left join basic_data.tm_model g on f.SECOND_ID = g.id
left join (
    select 
        tm.id 经销商表ID,
        tm.ORG_ID 经销商组织ID,
        tm.COMPANY_CODE ,
        tL2.ID 大区组织ID,
        tL2.ORG_NAME ORG_NAME_big,
        tg1.ID 小区组织ID,
        tg1.ORG_NAME ORG_NAME_small,
        tm.COMPANY_NAME_CN ,
        tm.GROUP_COMPANY_NAME
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
    ORDER BY tm.COMPANY_CODE ASC
) h on h.COMPANY_CODE = a.dealer_code
left join (
    select
        CUSTOMER_BUSINESS_ID,
        ARCHIVES_TIME,
        FIRST_PASSENGER_TIME,
        FIRST_DRIVE_TIME,
        FIRST_ORDER_TIME,
        DEFEAT_DATE,
        MIN_WORK_CALL_TIME,
        MAX_WORK_CALL_TIME,
        TOTAL_CALL_NUM,
        WORK_CALL_NUM,
        WORK_CONNECT_NUM,
        WORK_CONNECT_TIMES
    from
    customer_business.tt_business_statistics
) i on i.CUSTOMER_BUSINESS_ID = b.CUSTOMER_BUSINESS_ID
where b.created_at between '2022-05-24' and '2022-05-30 23:59:59'
    and a.is_deleted = 0
    and c.active_code in('IBDMMARWSJTJGLZS2022VCCN')
order by b.created_at)x 
where x.是否到店='Y'


---Newbie的订单表
select COUNT(DISTINCT x.销售订单ID) 
from 
(
select 
    a.SO_NO_ID 销售订单ID,
    a.SO_NO 销售订单号,
    a.COMPANY_CODE 公司代码,
    h.COMPANY_NAME_CN 经销商名称,
    h.GROUP_COMPANY_NAME 集团,
    h.ORG_NAME_big 大区,
    h.ORG_NAME_small 小区,
    a.OWNER_CODE 经销商代码,
    a.CREATED_AT 订单日期,
    a.SHEET_CREATE_DATE 开单日期,
    cast(a.CUSTOMER_BUSINESS_ID as varchar) 商机id ,
    a.CUSTOMER_NAME 客户姓名,
    a.DRAWER_NAME 开票人姓名,
    a.CONTACT_NAME 联系人姓名,
    a.CUSTOMER_TEL 潜客电话,
    a.DRAWER_TEL 开票人电话,
    a.PURCHASE_PHONE 下单人手机号,
    g.CODE_CN_DESC 订单状态,
    case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
    i.CODE_CN_DESC BUSINESS_TYPE,
    a.smmOrderId 订单id_smm,
    a.smmCustId 潜客id_smm,
    a.CUSTOMER_ID ,
    a.CUSTOMER_NO ,
    a.CUSTOMER_ACTIVITY_ID 活动代码id,
    c.CLUE_NAME 来源渠道,
    b.active_code 市场活动代码,
    b.active_name 市场活动名称,
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
    a.IS_DELETED
from cyxdms_retail.tt_sales_orders a 
left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
left join customer_business.tm_clue_source c on c.ID = b.active_channel
left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
left join basic_data.tm_model f on f.id = e.SECOND_ID
left join dictionary.tc_code g on g.code_id = a.SO_STATUS
left join (
    select 
        tm.id 经销商表ID,
        tm.ORG_ID 经销商组织ID,
        tm.COMPANY_CODE ,
        tL2.ID 大区组织ID,
        tL2.ORG_NAME ORG_NAME_big,
        tg1.ID 小区组织ID,
        tg1.ORG_NAME ORG_NAME_small,
        tm.COMPANY_NAME_CN ,
        tm.GROUP_COMPANY_NAME
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	) h on h.COMPANY_CODE = a.COMPANY_CODE
 left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
 left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
 left join dictionary.tc_code k on k.code_id = a.GENDER
 left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
 left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
where a.BUSINESS_TYPE<>14031002
and a.IS_DELETED = 0
and a.CREATED_AT BETWEEN '2022-05-24' AND '2022-05-30 23:59:59'
and b.active_code in('IBDMMAY525CZJYYS2022VCCN','IBDMMARWSJTJGLZS2022VCCN')
order by a.CREATED_AT DESC  )x
