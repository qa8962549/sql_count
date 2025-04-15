-- 参与预约试驾人群(沃世界提交留资，根据完成预约试驾的时间降序排，2022年取前10W)；选择经销商位置：天津市、河北省  8-6-5
--- 8-6-5
select x.客户电话 手机号
from 
(select 
--     a.clue_id 线索编号,
--     cast(a.business_id as varchar) 商机id,
--     a.dealer_code 经销商代码,
--     h.COMPANY_NAME_CN 经销商名称,
--     h.GROUP_COMPANY_NAME 集团,
--     h.ORG_NAME_big 大区,
--     h.ORG_NAME_small 小区,
--     a.name 客户姓名,
   DISTINCT a.mobile 客户电话,
--     i.CODE_CN_DESC 客户性别,
--     a.campaign_id 活动代码id,
--     c.active_code 市场活动代码,
--     c.active_name 市场活动名称,
--     d.CLUE_NAME 来源渠道,
--     f.model_name 意向车型,
--     b.SHOP_NUMBER 到店次数,
--     if(b.SHOP_NUMBER>0,'Y','N') 是否到店,
    g.FIRST_DRIVE_TIME 首次试驾时间
--     b.TEST_DRIVE_TIME 试驾次数,
--     if(b.TEST_DRIVE_TIME>0,'Y','N') 是否试驾,
--     a.allot_time 线索下发时间,
--     b.FATE_AFFIRM_TIME 首次跟进时间,
--     b.NEW_ACTION_TIME 最后跟进时间,
--     a.handle_time 采集时间,
--     b.created_at 商机创建时间,
--     a.create_time 线索创建时间
--     e.CODE_CN_DESC 线索状态,
--     a.smmclueid 线索id_SMM,
--     if(a.smmclueid is null,'NEWBIE','SMM') 来源系统,
--     a.smmcustid 潜客id_SMM,
--     g.FIRST_ORDER_TIME 首次下单时间,
--     g.DEFEAT_DATE 战败时间,
--     g.MIN_WORK_CALL_TIME 最早工作号外呼时间,
--     g.MAX_WORK_CALL_TIME 最新工作号外呼时间,
--     g.TOTAL_CALL_NUM newbie外呼次数,
--     g.WORK_CALL_NUM 工作号通话次数,
--     g.WORK_CONNECT_NUM 工作号接通次数,
--     g.WORK_CONNECT_TIMES 工作号累计通话时长
from customer.tt_clue_clean a 
left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
left join activity.cms_active c on a.campaign_id = c.uid
left join customer_business.tm_clue_source d on d.ID = c.active_channel
left join dictionary.tc_code e on a.clue_status = e.CODE_ID
left join basic_data.tm_model f on a.model_id = f.id
left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
left join organization.tm_company tc on tc.COMPANY_CODE =a.dealer_code 
left join (
    select 
        tm.id 经销商表ID,
        tm.ORG_ID 经销商组织ID,
        tm.COMPANY_CODE ,	
        tL2.ID 大区组织ID,
        tL2.ORG_NAME ORG_NAME_big,
        tg1.ID 小区组织ID,
        tg1.ORG_NAME ORG_NAME_small,
        tm.COMPANY_NAME_CN,
        tm.GROUP_COMPANY_NAME
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	) h on h.COMPANY_CODE = a.dealer_code
 left join dictionary.tc_code i on i.code_id = a.gender
where a.create_time between '2022-01-01' and '2022-7-28 23:59:59'
-- and (d.CLUE_NAME = ('总部车展') or (d.CLUE_NAME = ('总部CRM') and  c.active_name like ('%基盘挖掘%') ))
-- and tc.CITY_NAME in ('北京市')
and if(b.TEST_DRIVE_TIME>0,'Y','N')='Y'
and (tc.CITY_NAME in ('天津市') or tc.PROVINCE_NAME ='河北省')
and LENGTH(a.mobile)=11 
and LEFT(a.mobile,1)='1'
order by g.FIRST_DRIVE_TIME desc 
)x 
limit 120000