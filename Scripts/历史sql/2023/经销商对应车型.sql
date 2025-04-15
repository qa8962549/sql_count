分别拉 V60、全新纯电C40、XC40 Recharge、零售（除去前面三种车型以外的所有车型）四个车型分别对应的经销商信息

select 
DISTINCT a.COMPANY_CODE 经销商简码,
h.大区,
h.小区 城市,
h.COMPANY_NAME_CN 经销商名称,
tm.MODEL_NAME 
from organization.tm_company_vehicle a
left join basic_data.tm_model tm on a.MODEL_CODE =tm.MODEL_CODE
LEFT JOIN (
    select 
        DISTINCT
        tm.COMPANY_CODE,
        tg2.ORG_NAME 大区,
        tg1.ORG_NAME 小区,
        tm.COMPANY_NAME_CN
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
    ORDER BY tm.COMPANY_CODE ASC) h on h.COMPANY_CODE = a.COMPANY_CODE
where tm.MODEL_NAME not in ('XC40 RECHARGE','V60','全新纯电C40')
and a.TEST_DRIVE ='10041001'
and a.IS_DELETED =0



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
WHERE ta.CREATED_AT >= '2022-09-01'
AND ta.CREATED_AT <= '2022-09-15 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMAUGPWWCDYYSJ2022VCCN'  
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT