
-- 2、PV UV数据拉取 C40
select 
case when t.data like '%8A9102E2921046AB840C4A839BD85ADE%' then '04 弹窗'
	when t.data like '%CEDBF487EC35450FA2198C5CF2F52243%' then '05 C40众筹活动页-首页banner'
	when t.data like '%D97DFCE561ED40C589172538112836A3%' then '06 活动banner'
	when t.data like '%4E5C99FF2F1F485E8465690589DDC867%' then '07 C40众筹活动页-朋友圈海报'
	when t.data like '%FC02FA0A41464C33B354B097D7D8B77A%' then '08 服务号推文渠道'
	when t.data like '%23C77BD20A8E48A0B592797FA3D4A330%' then '09 朋友圈广告'
	when t.data like '%E4B81C94DD244CB3A08C44B2400A86A2%' then '10 短信-1-直售'
	when t.data like '%3B68F2EBA47D4C80AEAA0FDE3C5FE49E%' then '11 短信-2'
	when t.data like '%AE1BB5FA97004CE6AA6901D669F0F27A%' then '12 短信-3'
	when t.data like '%CE72F9E04920485784533BA557A05A09%' then '13 线下物料'
	when t.data like '%EB448D95D35B44FBAF079525DB373900%' then '14 活动月历'
	when t.data like '%4511AF3C8FC34D05A710AF56E751EF66%' then '15 朋友圈海报-经销商'
	when t.data like '%DE88683CA8A444FDAC800D520CBEA909%' then '16 预热页服务通知'
	when t.data like '%39780F0EDC4B49008F45C8E2AE4124B9%' then '17 social推文渠道'
	when t.data like '%E2021DBB5A554D63952954556B27785D%' then '18 MKT推广KV'
	when t.data like '%34D9986B4AB74ADEB491F9F8DDC046EB%' then '19 微信官方小程序'
	when t.data like '%CF4DE43FE38A4EBC8823E026165FBC87%' then '20 预售倒计时海报'
	when t.data like '%33A3958132684EF78EA2D4F640B0F5EA%' then '21 大定开启海报-重叠期'
	when t.data like '%7E1A4913963C46F798CA3D1AA47F1AE1%' then '22 MKT推广-14号'
	when t.data like '%IBDMAPRWSJC40RYS2022VCCN%' then '23 留资leads订单'
else null end '分类',
COUNT(usertag) as 'PV',
COUNT(distinct usertag) as 'UV'
from track.track t
where t.`date` >= '2022-02-14'
and t.`date` <= '2022-06-26 23:59:59'
group by 1
order by 1;


-- 拉新人数
select 
-- m.IS_VEHICLE,
	case when t.`data` like '%8A9102E2921046AB840C4A839BD85ADE%' then '8A9102E2921046AB840C4A839BD85ADE'
		when t.`data` like '%CEDBF487EC35450FA2198C5CF2F52243%' then 'CEDBF487EC35450FA2198C5CF2F52243'
		when t.`data` like '%D97DFCE561ED40C589172538112836A3%' then 'D97DFCE561ED40C589172538112836A3'
		when t.`data` like '%4E5C99FF2F1F485E8465690589DDC867%' then '4E5C99FF2F1F485E8465690589DDC867'
		when t.`data` like '%FC02FA0A41464C33B354B097D7D8B77A%' then 'FC02FA0A41464C33B354B097D7D8B77A'
		when t.`data` like '%23C77BD20A8E48A0B592797FA3D4A330%' then '23C77BD20A8E48A0B592797FA3D4A330'
		when t.`data` like '%E4B81C94DD244CB3A08C44B2400A86A2%' then 'E4B81C94DD244CB3A08C44B2400A86A2'
		when t.`data` like '%3B68F2EBA47D4C80AEAA0FDE3C5FE49E%' then '3B68F2EBA47D4C80AEAA0FDE3C5FE49E'
		when t.`data` like '%CE72F9E04920485784533BA557A05A09%' then 'CE72F9E04920485784533BA557A05A09'
		when t.`data` like '%EB448D95D35B44FBAF079525DB373900%' then 'EB448D95D35B44FBAF079525DB373900'
		when t.`data` like '%4511AF3C8FC34D05A710AF56E751EF66%' then '4511AF3C8FC34D05A710AF56E751EF66'
		when t.`data` like '%DE88683CA8A444FDAC800D520CBEA909%' then 'DE88683CA8A444FDAC800D520CBEA909'
		when t.`data` like '%39780F0EDC4B49008F45C8E2AE4124B9%' then '39780F0EDC4B49008F45C8E2AE4124B9'
		when t.`data` like '%E2021DBB5A554D63952954556B27785D%' then 'E2021DBB5A554D63952954556B27785D'
		when t.`data` like '%34D9986B4AB74ADEB491F9F8DDC046EB%' then '34D9986B4AB74ADEB491F9F8DDC046EB'	
		when t.`data` like '%CF4DE43FE38A4EBC8823E026165FBC87%' then 'CF4DE43FE38A4EBC8823E026165FBC87'
		when t.`data` like '%33A3958132684EF78EA2D4F640B0F5EA%' then '33A3958132684EF78EA2D4F640B0F5EA'
		when t.`data` like '%7E1A4913963C46F798CA3D1AA47F1AE1%' then '7E1A4913963C46F798CA3D1AA47F1AE1'
	end '入口',
	count(distinct case when m.IS_VEHICLE = 0 then m.id end) 粉丝
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.IS_VEHICLE = 0
where t.`date` >= '2022-02-14' 
and t.`date` <='2022-06-26 23:59:59' 
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
group by 1;


-- 激活僵尸粉数
select 
-- 	a.is_vehicle,
	a.channel,
	-- a.usertag
	count(distinct case when a.IS_VEHICLE = 1 then a.usertag end) 车主,
	count(distinct case when a.IS_VEHICLE = 0 then a.usertag end) 粉丝
from(
 -- 获取访问文章活动10分钟之前的最晚访问时间
 select t.usertag,b.mdate,b.is_vehicle,b.channel,max(t.date) tdate
 from track.track t
 join (
  -- 获取访问文章活动的最早时间
  select m.is_vehicle,t.usertag,c.channel,min(t.date) mdate 
  from track.track t 
  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
  join 
  (select b.channel,b.usertag,b.min_date,
	ROW_NUMBER() over(partition by b.usertag order by b.min_date) as rk
	from 
	(select a.channel ,a.usertag,min(a.date) as min_date
	from 
	(select 
		case when t.`data` like '%8A9102E2921046AB840C4A839BD85ADE%' then '8A9102E2921046AB840C4A839BD85ADE'
			when t.`data` like '%CEDBF487EC35450FA2198C5CF2F52243%' then 'CEDBF487EC35450FA2198C5CF2F52243'
			when t.`data` like '%D97DFCE561ED40C589172538112836A3%' then 'D97DFCE561ED40C589172538112836A3'
			when t.`data` like '%4E5C99FF2F1F485E8465690589DDC867%' then '4E5C99FF2F1F485E8465690589DDC867'
			when t.`data` like '%FC02FA0A41464C33B354B097D7D8B77A%' then 'FC02FA0A41464C33B354B097D7D8B77A'
			when t.`data` like '%23C77BD20A8E48A0B592797FA3D4A330%' then '23C77BD20A8E48A0B592797FA3D4A330'
			when t.`data` like '%E4B81C94DD244CB3A08C44B2400A86A2%' then 'E4B81C94DD244CB3A08C44B2400A86A2'
			when t.`data` like '%3B68F2EBA47D4C80AEAA0FDE3C5FE49E%' then '3B68F2EBA47D4C80AEAA0FDE3C5FE49E'
			when t.`data` like '%CE72F9E04920485784533BA557A05A09%' then 'CE72F9E04920485784533BA557A05A09'
			when t.`data` like '%EB448D95D35B44FBAF079525DB373900%' then 'EB448D95D35B44FBAF079525DB373900'
			when t.`data` like '%4511AF3C8FC34D05A710AF56E751EF66%' then '4511AF3C8FC34D05A710AF56E751EF66'
			when t.`data` like '%DE88683CA8A444FDAC800D520CBEA909%' then 'DE88683CA8A444FDAC800D520CBEA909'
			when t.`data` like '%39780F0EDC4B49008F45C8E2AE4124B9%' then '39780F0EDC4B49008F45C8E2AE4124B9'
			when t.`data` like '%E2021DBB5A554D63952954556B27785D%' then 'E2021DBB5A554D63952954556B27785D'
			when t.`data` like '%34D9986B4AB74ADEB491F9F8DDC046EB%' then '34D9986B4AB74ADEB491F9F8DDC046EB'	
			when t.`data` like '%CF4DE43FE38A4EBC8823E026165FBC87%' then 'CF4DE43FE38A4EBC8823E026165FBC87'
			when t.`data` like '%33A3958132684EF78EA2D4F640B0F5EA%' then '33A3958132684EF78EA2D4F640B0F5EA'
			when t.`data` like '%7E1A4913963C46F798CA3D1AA47F1AE1%' then '7E1A4913963C46F798CA3D1AA47F1AE1'
			else null end 'channel',
			t.usertag,
			t.`date` 
		from track.track t 
		where t.`date` >= '2022-02-14'
		and t.`date` <= '2022-06-26 23:59:59') a 
	where a.channel is not null
	group by 1,2) b) c on t.usertag = c.usertag
  where 
  t.date >= '2022-02-14'
  and t.date <='2022-06-26 23:59:59'
  GROUP BY 1,2,3
 ) b on b.usertag=t.usertag
 where t.date< DATE_SUB(b.mdate,INTERVAL 10 MINUTE)
 GROUP BY 1,2,3,4
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1

-- 活动拉新人数、排除车主
select 
DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
count(DISTINCT m.id)拉新人数
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.is_vehicle = 0  -- 排除车主
where t.`date` >= '2022-06-24'
and t.`date` <= '2022-06-30 23:59:59' 
and json_extract(t.`data`,'$.embeddedpoint')='C40YUSHOU_C40ZHONGCHOU_ONLOAD'
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
group by 1
order by 1


-- 僵尸粉-track表计算
select
a.is_vehicle 是否车主,
DATE_FORMAT(a.mdate,'%Y-%m-%d')日期,
count(distinct a.usertag) 激活数量
from(
 -- 获取访问文章活动10分钟之前的最晚访问时间
 select t.usertag,b.mdate,b.is_vehicle,max(t.date) tdate
 from track.track t
 join (
  -- 获取访问文章活动的最早时间
  select m.is_vehicle,t.usertag,min(t.date) mdate 
  from track.track t 
  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
  where json_extract(t.`data`,'$.embeddedpoint')='C40YUSHOU_C40ZHONGCHOU_ONLOAD'
  and t.`date` >= '2022-06-24'
  and t.`date` <= '2022-06-30 23:59:59' 
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date< DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1,2
order by 1,2 

-- PVUV
select 
DAY(t.`date`),
case when json_extract(t.`data`,'$.embeddedpoint')='C40YUSHOU_C40ZHONGCHOU_ONLOAD' then '01 众筹活动页'
	when json_extract(t.`data`,'$.embeddedpoint')='C40YUSHOU_C40ZHONGCHOUGUIZE_CLICK' then '02 活动规则btn点击'
	when json_extract(t.`data`,'$.embeddedpoint')='C40YUSHOU_C40ZHONGCHOULIJIXIADING_CLICK' then '03 点击立即下订btn点击'
else null end '分类',
COUNT(usertag) as 'PV',
COUNT(distinct usertag) as 'UV'
from track.track t
where t.`date` >= '2022-06-01'
and t.`date` <= '2022-06-07 23:59:59' 
group by 2,1
order by 2,1;



--- Newbie 线索表
select 
    a.clue_id 线索编号,
    cast(a.business_id as varchar) 商机id,
    a.dealer_code 经销商代码,
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
where a.create_time >= '2022-04-14'
and a.create_time <= '2022-6-30 23:59:59' 
and c.active_code ='IBDMAPRWSJC40RYS2022VCCN'
-- AND d.CLUE_NAME in ('eVolvo(总部)','eVolvo(经销商)')

