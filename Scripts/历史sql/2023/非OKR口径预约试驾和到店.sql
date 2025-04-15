select
ifnull(a.沃世界来源渠道,'[空]') 沃世界来源渠道,
b.上月预约试驾数,
b.上月到店试驾数,
c.本月预约试驾数,
c.本月到店试驾数
from
(
-- 23年所有沃世界来源渠道
	SELECT DISTINCT
    ifnull(ca.active_name,'[空]') 沃世界来源渠道
    FROM cyx_appointment.tt_appointment ta
    LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID
    WHERE ta.CREATED_AT >= '2023-01-01'
    AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
    AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
    -- and ca.active_code = 'IBDMJANQXWSJSJZQ2022VCCN'
    and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891','16601707464')   -- 剔除测试信息
    order by 1
)a
left join
(-- 上月
select 
ifnull(a.沃世界来源渠道,'[空]') 沃世界来源渠道,
count(distinct a.预约ID ) 上月预约试驾数
,count(distinct case when a.试驾开始时间 is not null and a.试驾开始时间>a.预约时间 then a.预约ID end) 上月到店试驾数
from (
-- 4、预约试驾明细
	SELECT
    DISTINCT 
    ta.APPOINTMENT_ID 预约ID,
    ta.CREATED_AT 预约时间,
--     ta.ARRIVAL_DATE 实际到店日期,
    f.到店时间,
    ca.active_name 沃世界来源渠道,
    ta.one_id 客户ID,
    ta.customer_name 姓名,
    tmi.member_phone 注册手机号,
    ta.customer_phone 手机号,
    tm2.model_name 留资车型,
    h.大区,
    h.小区,
    ta.OWNER_CODE 经销商,
    tc2.COMPANY_NAME_CN 经销商名称,
    CASE tad.status
    	WHEN 70711001 THEN '待试驾'
        WHEN 70711002 THEN '已试驾' 
        WHEN 70711003 THEN '已取消'
        END 试驾状态,
    case when e.试驾开始时间 > ta.CREATED_AT then e.试驾开始时间 else tad.drive_s_at end 试驾开始时间,
    case when e.试驾结束时间 > ta.CREATED_AT then e.试驾结束时间 else tad.drive_e_at end 试驾结束时间
    FROM cyx_appointment.tt_appointment ta
    left join `member`.tc_member_info tmi on ta.one_id =tmi.CUST_ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
    LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
    LEFT JOIN 
    (
    select
    tc2.COMPANY_CODE , tc2.COMPANY_NAME_CN
    from
    (
    select 
    tc2.COMPANY_CODE, tc2.COMPANY_NAME_CN
    ,row_number() over(partition by tc2.COMPANY_CODE  order by tc2.create_time desc) rk
    from
    organization.tm_company tc2)tc2
    where rk=1
    )tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
    LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
    LEFT JOIN basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID 
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
    LEFT JOIN 
	(
		--  历史试驾数据(存在一个商机ID对应多条试驾信息)
		select 
		p.CUSTOMER_BUSINESS_ID
-- 		p.MOBILE 试驾手机号
		,p.DRIVE_S_AT 试驾开始时间
		,p.DRIVE_E_AT 试驾结束时间
		from drive_service.tt_testdrive_plan p      -- 试驾工单表（只要数据存在，那么就算这个人试驾了。）
		where DATE_FORMAT(p.DRIVE_S_AT ,'%Y-%m-%d') >= to_date((to_char(( now() + interval '-1 month'),'YYYY-MM-01')),'YYYY-MM-DD')
		and p.IS_DELETED = 0
	) e on ta.CUSTOMER_BUSINESS_ID = e.CUSTOMER_BUSINESS_ID
	LEFT JOIN 
	( -- 存在一个商机ID对应多条到店信息
		select
		q.CUSTOMER_BUSINESS_ID 
		,q.ARRIVE_DATE 到店时间
		from
		cyx_passenger_flow.tt_passenger_flow_info q
		where q.IS_DELETED =0
		and DATE_FORMAT(q.ARRIVE_DATE ,'%Y-%m-%d') >= to_date((to_char(( now() + interval '-1 month'),'YYYY-MM-01')),'YYYY-MM-DD')
		and q.CUSTOMER_BUSINESS_ID is not null
	) f on ta.CUSTOMER_BUSINESS_ID = f.CUSTOMER_BUSINESS_ID
    WHERE ta.CREATED_AT >= to_date((to_char(( now() + interval '-1 month'),'YYYY-MM-01')),'YYYY-MM-DD')
    AND ta.CREATED_AT < '2023-08-01'
    AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
    AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
    -- and ca.active_code = 'IBDMJANQXWSJSJZQ2022VCCN'
    and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891','16601707464')   -- 剔除测试信息
    order by ta.CREATED_AT
) a
GROUP BY 1
)b on a.沃世界来源渠道 =b.沃世界来源渠道
left join
(-- 本月
select 
--ifnull(a.沃世界来源渠道,'[空]') 沃世界来源渠道,
count(distinct a.预约ID ) 本月预约试驾数
,count(distinct case when a.到店时间 is not null and a.到店时间>a.预约时间 then a.预约ID end) 本月到店数
,count(distinct case when a.试驾开始时间 is not null and a.试驾开始时间>a.预约时间 then a.预约ID end) 本月到店试驾数
from (
-- 4、预约试驾明细
	SELECT
    DISTINCT 
    ta.APPOINTMENT_ID 预约ID,
    ta.CREATED_AT 预约时间,
--     ta.ARRIVAL_DATE 实际到店日期,
    f.到店时间,
    ca.active_name 沃世界来源渠道,
    ta.one_id 客户ID,
    ta.customer_name 姓名,
    tmi.member_phone 注册手机号,
    ta.customer_phone 手机号,
    tm2.model_name 留资车型,
    h.大区,
    h.小区,
    ta.OWNER_CODE 经销商,
    tc2.COMPANY_NAME_CN 经销商名称,
    CASE tad.status
    	WHEN 70711001 THEN '待试驾'
        WHEN 70711002 THEN '已试驾' 
        WHEN 70711003 THEN '已取消'
        END 试驾状态,
    case when e.试驾开始时间 > ta.CREATED_AT then e.试驾开始时间 else tad.drive_s_at end 试驾开始时间,
    case when e.试驾结束时间 > ta.CREATED_AT then e.试驾结束时间 else tad.drive_e_at end 试驾结束时间
    FROM cyx_appointment.tt_appointment ta
    left join `member`.tc_member_info tmi on ta.one_id =tmi.CUST_ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
    LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
    LEFT JOIN 
    (
    select
    tc2.COMPANY_CODE , tc2.COMPANY_NAME_CN
    from
    (
    select 
    tc2.COMPANY_CODE, tc2.COMPANY_NAME_CN
    ,row_number() over(partition by tc2.COMPANY_CODE  order by tc2.create_time desc) rk
    from
    organization.tm_company tc2)tc2
    where rk=1
    )tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
    LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
    LEFT JOIN basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID 
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
    LEFT JOIN 
	(
		--  历史试驾数据(存在一个商机ID对应多条试驾信息)
		select 
		p.CUSTOMER_BUSINESS_ID
-- 		p.MOBILE 试驾手机号
		,p.DRIVE_S_AT 试驾开始时间
		,p.DRIVE_E_AT 试驾结束时间
		from drive_service.tt_testdrive_plan p      -- 试驾工单表（只要数据存在，那么就算这个人试驾了。）
		where DATE_FORMAT(p.DRIVE_S_AT ,'%Y-%m-%d') >= '2023-08-01'
		and p.IS_DELETED = 0
	) e on ta.CUSTOMER_BUSINESS_ID = e.CUSTOMER_BUSINESS_ID
	LEFT JOIN 
	( -- 存在一个商机ID对应多条到店信息
		select
		q.CUSTOMER_BUSINESS_ID 
		,q.ARRIVE_DATE 到店时间
		from
		cyx_passenger_flow.tt_passenger_flow_info q
		where q.IS_DELETED =0
		and DATE_FORMAT(q.ARRIVE_DATE ,'%Y-%m-%d') >= '2023-08-01'
		and q.CUSTOMER_BUSINESS_ID is not null
	) f on ta.CUSTOMER_BUSINESS_ID = f.CUSTOMER_BUSINESS_ID
    WHERE ta.CREATED_AT >= '2023-08-01'
    AND ta.CREATED_AT <'2023-09-01'
    AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
    AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
    -- and ca.active_code = 'IBDMJANQXWSJSJZQ2022VCCN'
    and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891','16601707464')   -- 剔除测试信息
    order by ta.CREATED_AT
) a
--GROUP BY 1
)c on a.沃世界来源渠道 =c.沃世界来源渠道
order by a.沃世界来源渠道

-- 2023年截至目前“线上预约试驾—到店—购车”的数据及转化率
select 
-- a.沃世界来源渠道,
count(distinct a.预约ID) 预约试驾订单数量,
count(distinct case when a.到店时间 is not null and a.到店时间 > a.预约时间 then a.预约ID end) 到店量,
round(count(distinct case when a.到店时间 is not null and a.到店时间 > a.预约时间 then a.预约ID end)/count(distinct a.预约ID),4)到店率
from (
-- 4、预约试驾明细
	SELECT
    DISTINCT 
    ta.APPOINTMENT_ID 预约ID,
    ta.CREATED_AT 预约时间,
--     ta.ARRIVAL_DATE 实际到店日期,
    f.到店时间,
    ca.active_name 沃世界来源渠道,
    ta.one_id 客户ID,
    ta.customer_name 姓名,
    tmi.member_phone 注册手机号,
    ta.customer_phone 手机号,
    tm2.model_name 留资车型,
    h.大区,
    h.小区,
    ta.OWNER_CODE 经销商,
    tc2.COMPANY_NAME_CN 经销商名称,
    CASE tad.status
    	WHEN 70711001 THEN '待试驾'
        WHEN 70711002 THEN '已试驾' 
        WHEN 70711003 THEN '已取消'
        END 试驾状态,
    case when e.试驾开始时间 > ta.CREATED_AT then e.试驾开始时间 else tad.drive_s_at end 试驾开始时间,
    case when e.试驾结束时间 > ta.CREATED_AT then e.试驾结束时间 else tad.drive_e_at end 试驾结束时间
    FROM cyx_appointment.tt_appointment ta
    left join `member`.tc_member_info tmi on ta.one_id =tmi.CUST_ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
    LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
    LEFT JOIN 
    (
    select
    tc2.COMPANY_CODE , tc2.COMPANY_NAME_CN
    from
    (
    select 
    tc2.COMPANY_CODE, tc2.COMPANY_NAME_CN
    ,row_number() over(partition by tc2.COMPANY_CODE  order by tc2.create_time desc) rk
    from
    organization.tm_company tc2)tc2
    where rk=1
    )tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
    LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
    LEFT JOIN basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID 
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
    LEFT JOIN 
	(
		--  历史试驾数据(存在一个商机ID对应多条试驾信息)
		select 
		p.CUSTOMER_BUSINESS_ID
-- 		p.MOBILE 试驾手机号
		,p.DRIVE_S_AT 试驾开始时间
		,p.DRIVE_E_AT 试驾结束时间
		from drive_service.tt_testdrive_plan p      -- 试驾工单表（只要数据存在，那么就算这个人试驾了。）
		where DATE_FORMAT(p.DRIVE_S_AT ,'%Y-%m-%d') >= '2023-01-01' 
		and p.IS_DELETED = 0
	) e on ta.CUSTOMER_BUSINESS_ID = e.CUSTOMER_BUSINESS_ID
	LEFT JOIN 
	( -- 存在一个商机ID对应多条到店信息
		select
		q.CUSTOMER_BUSINESS_ID 
		,q.ARRIVE_DATE 到店时间
		from
		cyx_passenger_flow.tt_passenger_flow_info q
		where q.IS_DELETED =0
		and DATE_FORMAT(q.ARRIVE_DATE ,'%Y-%m-%d') >= '2023-08-01'
		and q.CUSTOMER_BUSINESS_ID is not null
	) f on ta.CUSTOMER_BUSINESS_ID = f.CUSTOMER_BUSINESS_ID
    WHERE ta.CREATED_AT >= '2023-08-01'
    AND ta.CREATED_AT <= '2023-08-31 23:59:59'
    AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
    AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
    -- and ca.active_code = 'IBDMJANQXWSJSJZQ2022VCCN'
    and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891','16601707464')   -- 剔除测试信息
    order by ta.CREATED_AT
) a;