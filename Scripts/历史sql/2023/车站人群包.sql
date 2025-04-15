--- 8-6-1 8-6-2
select 
--     a.clue_id 线索编号,
--     cast(a.business_id as varchar) 商机id,
--     a.dealer_code 经销商代码,
--     h.COMPANY_NAME_CN 经销商名称,
--     h.GROUP_COMPANY_NAME 集团,
--     h.ORG_NAME_big 大区,
--     h.ORG_NAME_small 小区,
--     a.name 客户姓名,
   DISTINCT a.mobile 客户电话
--     i.CODE_CN_DESC 客户性别,
--     a.campaign_id 活动代码id,
--     c.active_code 市场活动代码,
--     c.active_name 市场活动名称,
--     d.CLUE_NAME 来源渠道,
--     f.model_name 意向车型,
--     b.SHOP_NUMBER 到店次数,
--     if(b.SHOP_NUMBER>0,'Y','N') 是否到店,
--     g.FIRST_DRIVE_TIME 首次试驾时间,
--     b.TEST_DRIVE_TIME 试驾次数,
--     if(b.TEST_DRIVE_TIME>0,'Y','N') 是否试驾,
--     a.allot_time 线索下发时间,
--     b.FATE_AFFIRM_TIME 首次跟进时间,
--     b.NEW_ACTION_TIME 最后跟进时间,
--     a.handle_time 采集时间,
--     b.created_at 商机创建时间,
--     a.create_time 线索创建时间,
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
where a.create_time between '2021-01-01' and '2021-12-31 23:59:59'
and (d.CLUE_NAME = ('总部车展') or (d.CLUE_NAME = ('总部CRM') and  c.active_name like ('%基盘挖掘%') ))
and tc.CITY_NAME in ('北京市')
-- and (tc.CITY_NAME in ('天津市') or tc.PROVINCE_NAME ='河北省')
and LENGTH(a.mobile)=11 
and LEFT(a.mobile,1)='1'

-- 8-9-1
select x.客户电话 手机号
from 
	(
	select 
	DISTINCT a.mobile 客户电话,
	a.create_time
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
	where a.create_time between '2021-01-01' and '2022-07-28 23:59:59'
	and c.active_code not in ("IBAUTOAPRTSDCPDS2021VCCN",
	"IBAUTOSEPTIJAJXS2022VCCN",
	"IBAUTOAPRTSDJXS2021VCCN",
	"IBAUTOSEPCSJXCHD2021VCCN",
	"IBAUTOAPRTJBCPDS2021VCCN",
	"IBCRMAPRTJBJPWJ2021VCCN",
	"IBAUTOSEPSJZCCPD2021VCCN",
	"IBAUTOAPRTJBXCHD2021VCCN",
	"IBAUTOSEPSJZCJXS2021VCCN",
	"IBCRMSEPATJCJPWJ2021VCCN",
	"IBAUTOSEPATJCPDS2021VCCN",
	"IBAUTOAPRTJBJXS2021VCCN",
	"IBAUTOAPRTSDXCHD2021VCCN",
	"IBAUTOSEPATJXCHD2021VCCN",
	"IBAUTOAPRTJBZQH52021VCCN",
	"IBAUTOSEPATJZQH52021VCCN"
	)
	and LENGTH(a.mobile)=11 
	and LEFT(a.mobile,1)='1'
	order by a.create_time desc 
)x
limit 90000


-- 5-9-1 参与过沃世界大活动的用户（沃窝森林、宝华韦健、英超、西甲、欧洲杯、温网、四季服、十二服、推荐购、万圣节、双旦、嘟嘟贺岁、C40预售、春服），注意整体合并后除重
-- 沃窝森林、宝华韦健、英超、西甲、欧洲杯、温网、四季服、十二服、推荐购、万圣节、双旦   已有
-- 十二服、推荐购、嘟嘟贺岁、C40、春服、525车主节、沃世界三周年                     新增
-- 埋点测试
select * from track.track t where t.usertag = '5537985' order by t.`date` desc

-- 推荐购推荐人页面
select t.typeid,t.usertag,t.`data`,t.date
from track.track t 
where date(t.date)='2022-04-07'
and t.typeid='XWSJXCX_OLD_NEW_ONLOAD_C'
order by t.date desc;
-- 推荐购被推荐人页面
select t.typeid,t.usertag,t.`data`,t.date
from track.track t 
where date(t.date)='2022-04-07'
and t.typeid='XWSJXCX_OLD_NEW_LZONLOAD_C'
order by t.date desc;
-- 非车主进入活动
select t.typeid,t.usertag,t.`data`,t.date
from track.track t 
where date(t.date)='2022-04-07'
and t.typeid='XWSJXCX_TJG_FCZ_V'
order by t.date desc;

12服   "embeddedpoint":"十二大服务_afterService12/index_onload"
万圣节
-- 双旦 embeddedpoint:'shuangDan_home_ONLOAD'
嘟嘟贺岁 embeddedpoint:'春节不打烊_onload活动首页_ONLOAD'
C40预售 json_extract(t.`data`,'$.embeddedpoint')='C40YUSHOU_C40DINGYUE_ONLOAD' then '01 预热页'     
json_extract(t.`data`,'$.embeddedpoint')='C40YUSHOU_C40ZHONGCHOU_ONLOAD' then '02 预售页'
春服 json_extract(t.`data`,'$.embeddedpoint') = 'CHUNFU2022_SHOUYE_ONLOAD' then '01 春服主页面'
525 collectionPage_home_正式_click
三周年 三周年_预热页_ONLOAD 三周年_进行页_ONLOAD  三周年_发酵页_ONLOAD


-- 8-6-3 北京
#粉丝
select 
distinct tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
join track.track t on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join `member`.tc_member_address tma on tma.MEMBER_ID =tmi.id and tma.IS_DEFAULT =1 and tma.IS_DELETED =0
where t.date>'2022-01-01' 
and (json_extract(t.`data`,'$.embeddedpoint') = '十二大服务_afterService12/index_onload'
or json_extract(t.`data`,'$.embeddedpoint') = '春节不打烊_onload活动首页_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'C40YUSHOU_C40DINGYUE_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'C40YUSHOU_C40ZHONGCHOU_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'collectionPage_home_正式_click'
or json_extract(t.`data`,'$.embeddedpoint') in ('三周年_预热页_ONLOAD','三周年_进行页_ONLOAD','三周年_发酵页_ONLOAD')
or t.typeid in ('XWSJXCX_OLD_NEW_LZONLOAD_C','XWSJXCX_TJG_FCZ_V','XWSJXCX_OLD_NEW_LZONLOAD_C'))
and (tma.ADDRESS_CITY in (110100,110000) or tmi.MEMBER_ADDRESS in (110100,110000) )-- 默认收货地址在北京市
and tmi.IS_VEHICLE =0 -- 粉丝
and LENGTH(tmi.MEMBER_PHONE)=11 
and LEFT(tmi.MEMBER_PHONE,1)='1'
union
#车主
select 
distinct tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
join track.track t on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join `member`.tc_member_address tma on tma.MEMBER_ID =tmi.id and tma.IS_DEFAULT =1 and tma.IS_DELETED =0
left join
	(
	# 车系
	 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
		 from (
		 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
		 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
		 from member.tc_member_vehicle v 
		 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
		 where v.IS_DELETED=0 
		 ) v 
	 left join vehicle.tm_vehicle t on v.vin=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	 where v.rk=1
) a on tmi.id=a.member_id
left join vehicle.tt_invoice_statistics_dms tisd on a.vin=tisd.vin and tisd.IS_DELETED =0  -- 与发票表关联
where t.date>'2022-01-01'
and (json_extract(t.`data`,'$.embeddedpoint') = '十二大服务_afterService12/index_onload'
or json_extract(t.`data`,'$.embeddedpoint') = '春节不打烊_onload活动首页_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'C40YUSHOU_C40DINGYUE_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'C40YUSHOU_C40ZHONGCHOU_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'collectionPage_home_正式_click'
or json_extract(t.`data`,'$.embeddedpoint') in ('三周年_预热页_ONLOAD','三周年_进行页_ONLOAD','三周年_发酵页_ONLOAD')
or t.typeid in ('XWSJXCX_OLD_NEW_LZONLOAD_C','XWSJXCX_TJG_FCZ_V','XWSJXCX_OLD_NEW_LZONLOAD_C'))
and (tma.ADDRESS_CITY in (110100,110000) or tmi.MEMBER_ADDRESS in (110100,110000) )-- 默认收货地址在北京市
and tmi.IS_VEHICLE =1 -- 车主
and tisd.invoice_date <= DATE_SUB('2022-07-28 23:59:59',interval 3 YEAR)  -- 车龄距今大于三年
and LENGTH(tmi.MEMBER_PHONE)=11 
and LEFT(tmi.MEMBER_PHONE,1)='1'


-- 8-6-4  130000 河北   120000 120100 天津
#粉丝
select 
distinct tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
join track.track t on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join `member`.tc_member_address tma on tma.MEMBER_ID =tmi.id and tma.IS_DEFAULT =1 and tma.IS_DELETED =0
where t.date>'2022-01-01' 
and (json_extract(t.`data`,'$.embeddedpoint') = '十二大服务_afterService12/index_onload'
or json_extract(t.`data`,'$.embeddedpoint') = '春节不打烊_onload活动首页_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'C40YUSHOU_C40DINGYUE_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'C40YUSHOU_C40ZHONGCHOU_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'collectionPage_home_正式_click'
or json_extract(t.`data`,'$.embeddedpoint') in ('三周年_预热页_ONLOAD','三周年_进行页_ONLOAD','三周年_发酵页_ONLOAD')
or t.typeid in ('XWSJXCX_OLD_NEW_LZONLOAD_C','XWSJXCX_TJG_FCZ_V','XWSJXCX_OLD_NEW_LZONLOAD_C'))
and (tma.ADDRESS_CITY in (130000,120000,120100) or tmi.MEMBER_ADDRESS in (130000,120000,120100) )-- 默认收货地址和沃世界地址在北京市
and tmi.IS_VEHICLE =0 -- 粉丝
and LENGTH(tmi.MEMBER_PHONE)=11 
and LEFT(tmi.MEMBER_PHONE,1)='1'
union
#车主
select 
distinct tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
join track.track t on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join `member`.tc_member_address tma on tma.MEMBER_ID =tmi.id and tma.IS_DEFAULT =1 and tma.IS_DELETED =0
left join
	(
	# 车系
	 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
		 from (
		 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
		 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
		 from member.tc_member_vehicle v 
		 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
		 where v.IS_DELETED=0 
		 ) v 
	 left join vehicle.tm_vehicle t on v.vin=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	 where v.rk=1
) a on tmi.id=a.member_id
left join vehicle.tt_invoice_statistics_dms tisd on a.vin=tisd.vin and tisd.IS_DELETED =0  -- 与发票表关联
where t.date>'2022-01-01'
and (json_extract(t.`data`,'$.embeddedpoint') = '十二大服务_afterService12/index_onload'
or json_extract(t.`data`,'$.embeddedpoint') = '春节不打烊_onload活动首页_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'C40YUSHOU_C40DINGYUE_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'C40YUSHOU_C40ZHONGCHOU_ONLOAD'
or json_extract(t.`data`,'$.embeddedpoint') = 'collectionPage_home_正式_click'
or json_extract(t.`data`,'$.embeddedpoint') in ('三周年_预热页_ONLOAD','三周年_进行页_ONLOAD','三周年_发酵页_ONLOAD')
or t.typeid in ('XWSJXCX_OLD_NEW_LZONLOAD_C','XWSJXCX_TJG_FCZ_V','XWSJXCX_OLD_NEW_LZONLOAD_C'))
and (tma.ADDRESS_CITY in (130000,120000,120100) or tmi.MEMBER_ADDRESS in (130000,120000,120100) )-- 默认收货地址和沃世界地址在河北和天津市
and tmi.IS_VEHICLE =1 -- 车主
and tisd.invoice_date <= DATE_SUB('2022-07-28 23:59:59',interval 3 YEAR)  -- 车龄距今大于三年
and LENGTH(tmi.MEMBER_PHONE)=11 
and LEFT(tmi.MEMBER_PHONE,1)='1'

-- 全量8-6-3
select 
distinct tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
join track.track t on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join `member`.tc_member_address tma on tma.MEMBER_ID =tmi.id and tma.IS_DEFAULT =1 and tma.IS_DELETED =0
where (tma.ADDRESS_CITY in (110100,110000) or tmi.MEMBER_ADDRESS in (110100,110000) )-- 默认收货地址在北京市
and tmi.IS_VEHICLE =0 -- 粉丝
and LENGTH(tmi.MEMBER_PHONE)=11 
and LEFT(tmi.MEMBER_PHONE,1)='1'
union
#车主
select 
distinct tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
join track.track t on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join `member`.tc_member_address tma on tma.MEMBER_ID =tmi.id and tma.IS_DEFAULT =1 and tma.IS_DELETED =0
left join
	(
	# 车系
	 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
		 from (
		 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
		 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
		 from member.tc_member_vehicle v 
		 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
		 where v.IS_DELETED=0 
		 ) v 
	 left join vehicle.tm_vehicle t on v.vin=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	 where v.rk=1
) a on tmi.id=a.member_id
left join vehicle.tt_invoice_statistics_dms tisd on a.vin=tisd.vin and tisd.IS_DELETED =0  -- 与发票表关联
where (tma.ADDRESS_CITY in (110100,110000) or tmi.MEMBER_ADDRESS in (110100,110000) )-- 默认收货地址在北京市
and tmi.IS_VEHICLE =1 -- 车主
and tisd.invoice_date <= DATE_SUB('2022-07-28 23:59:59',interval 3 YEAR)  -- 车龄距今大于三年
and LENGTH(tmi.MEMBER_PHONE)=11 
and LEFT(tmi.MEMBER_PHONE,1)='1'

-- 8-6-4  全量
#粉丝
select 
distinct tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
join track.track t on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join `member`.tc_member_address tma on tma.MEMBER_ID =tmi.id and tma.IS_DEFAULT =1 and tma.IS_DELETED =0
where (tma.ADDRESS_CITY in (130000,120000,120100) or tmi.MEMBER_ADDRESS in (130000,120000,120100) )-- 默认收货地址和沃世界地址在北京市
and tmi.IS_VEHICLE =0 -- 粉丝
and LENGTH(tmi.MEMBER_PHONE)=11 
and LEFT(tmi.MEMBER_PHONE,1)='1'
union
#车主
select 
distinct tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
join track.track t on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join `member`.tc_member_address tma on tma.MEMBER_ID =tmi.id and tma.IS_DEFAULT =1 and tma.IS_DELETED =0
left join
	(
	# 车系
	 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
		 from (
		 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
		 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
		 from member.tc_member_vehicle v 
		 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
		 where v.IS_DELETED=0 
		 ) v 
	 left join vehicle.tm_vehicle t on v.vin=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	 where v.rk=1
) a on tmi.id=a.member_id
left join vehicle.tt_invoice_statistics_dms tisd on a.vin=tisd.vin and tisd.IS_DELETED =0  -- 与发票表关联
where (tma.ADDRESS_CITY in (130000,120000,120100) or tmi.MEMBER_ADDRESS in (130000,120000,120100) )-- 默认收货地址和沃世界地址在河北和天津市
and tmi.IS_VEHICLE =1 -- 车主
and tisd.invoice_date <= DATE_SUB('2022-07-28 23:59:59',interval 3 YEAR)  -- 车龄距今大于三年
and LENGTH(tmi.MEMBER_PHONE)=11 
and LEFT(tmi.MEMBER_PHONE,1)='1'

-- 参与预约试驾人群(沃世界提交留资，根据完成预约试驾的时间降序排，2022年取前10W)；选择经销商位置：天津市、河北省  8-6-5
-- 8-6-5
select DISTINCT x.客户电话 手机号
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
--     g.FIRST_DRIVE_TIME 首次试驾时间
--     b.TEST_DRIVE_TIME 试驾次数,
--     if(b.TEST_DRIVE_TIME>0,'Y','N') 是否试驾,
--     a.allot_time 线索下发时间,
--     b.FATE_AFFIRM_TIME 首次跟进时间,
--     b.NEW_ACTION_TIME 最后跟进时间,
--     a.handle_time 采集时间,
--     b.created_at 商机创建时间,
    a.create_time 线索创建时间
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
-- and if(b.TEST_DRIVE_TIME>0,'Y','N')='Y'
and (tc.CITY_NAME in ('天津市') or tc.PROVINCE_NAME ='河北省')
and LENGTH(a.mobile)=11 
and LEFT(a.mobile,1)='1'
order by a.create_time desc 
)x 
limit 120000


-- 参与预约试驾人群(沃世界提交留资，根据完成预约试驾的时间降序排，2022年取前10W)；选择经销商位置：北京市 8-7-1
select DISTINCT x.客户电话 手机号
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
--     g.FIRST_DRIVE_TIME 首次试驾时间
--     b.TEST_DRIVE_TIME 试驾次数,
--     if(b.TEST_DRIVE_TIME>0,'Y','N') 是否试驾,
--     a.allot_time 线索下发时间,
--     b.FATE_AFFIRM_TIME 首次跟进时间,
--     b.NEW_ACTION_TIME 最后跟进时间,
--     a.handle_time 采集时间,
--     b.created_at 商机创建时间,
    a.create_time 线索创建时间
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
where a.create_time between '2022-01-01' and '2022-8-4 23:59:59'
-- and (d.CLUE_NAME = ('总部车展') or (d.CLUE_NAME = ('总部CRM') and  c.active_name like ('%基盘挖掘%') ))
and tc.CITY_NAME in ('北京市')
-- and if(b.TEST_DRIVE_TIME>0,'Y','N')='Y'
-- and (tc.CITY_NAME in ('天津市') or tc.PROVINCE_NAME ='河北省')
and LENGTH(a.mobile)=11 
and LEFT(a.mobile,1)='1'
order by a.create_time desc 
)x 
limit 120000

-- 8-7-2 2022年参加过签到的人群（截止当前所有的签到人群，注意除重）；用户个人资料 所在地：北京市、天津市、河北省
	
select
c3.MEMBER_PHONE 手机号
from 
	(
	select 
	si.member_id,
	max(si.create_time) mtime
	from mine.sign_info si
	where si.is_delete =0
	and si.create_time>='2022-01-01' and si.create_time<'2022-08-05'
	group by 1
	) si
left join (
	 #收货地址城市
	 select m.id,cc.REGION_NAME,m.member_phone
	 from member.tc_member_info m 
	 left join member.tc_member_address a on m.id=a.member_id and a.IS_DEFAULT=1 and a.status=0
	 left join dictionary.tc_region cc on a.ADDRESS_CITY=cc.REGION_ID
	 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	) c3 on c3.id= si.member_id
where LENGTH(c3.MEMBER_PHONE) = 11 and left(c3.MEMBER_PHONE,1) = '1' -- 排除无效手机号
and c3.REGION_NAME in ('北京市','天津市','河北省')
limit 100000

-- 在商城有过购买记录且收货地址在北京的车主&粉丝 8-7-3
select 
distinct m.手机号
from (
select a.order_code 订单编号
,b.product_id 商城兑换id
,a.user_id 会员id
,a.user_name 会员姓名
,h.MEMBER_PHONE 手机号
,b.spu_name 兑换商品
,b.spu_id
,b.sku_id
,b.sku_code
,b.sku_real_point 商品单价
,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券' 
	WHEN 51121003 THEN '保养类卡券' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
,b.fee/100 总金额
,b.coupon_fee/100 优惠券抵扣金额
,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,a.create_time 兑换时间
,case when b.pay_fee=0 then '纯V值支付' when b.point_amount=0 then '纯现金支付' else '混合支付' end 支付方式
,f.name 分类
,CASE b.spu_type 
	WHEN 51121001 THEN 'VOLVO仓商品' 
	WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
	WHEN 51121003 THEN '虚拟服务卡券' 
	WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
,CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
END AS 商品状态
,CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
END AS 订单状态
,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 关闭原因
,e.`退货状态`
,e.`退货数量`
,e.退回V值
,e.退回时间
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join (
	 #收货地址城市
	 select m.id,cc.REGION_NAME,m.member_phone
	 from member.tc_member_info m 
	 left join member.tc_member_address a on m.id=a.member_id and a.IS_DEFAULT=1 and a.status=0
	 left join dictionary.tc_region cc on a.ADDRESS_CITY=cc.REGION_ID
	 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	) c3 on c3.id= h.ID 
left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
left join(
	#V值退款成功记录
	select so.order_code,sp.product_id
	,CASE so.status 
		WHEN 51171001 THEN '待审核' 
		WHEN 51171002 THEN '待退货入库' 
		WHEN 51171003 THEN '待退款' 
		WHEN 51171004 THEN '退款成功' 
		WHEN 51171005 THEN '退款失败' 
		WHEN 51171006 THEN '作废退货单' END AS 退货状态
	,sum(sp.sales_return_num) 退货数量
	,sum(so.refund_point) 退回V值
	,max(so.create_time) 退回时间
	from `order`.tt_sales_return_order so
	left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
	where so.is_deleted = 0 
	and so.status=51171004 -- 退款成功
	GROUP BY 1,2,3
) e on a.order_code = e.order_code and b.product_id =e.product_id 
where 
-- a.create_time >= '2022-01-01' and a.create_time <='2022-05-26 23:59:59'       -- 订单时间
a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
and c3.REGION_NAME in ('北京市')
order by a.create_time desc)m
where LENGTH(m.手机号) = 11 and left(m.手机号,1) = '1' -- 排除无效手机号
limit 150000