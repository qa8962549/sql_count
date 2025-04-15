-- PVUV  BNcZFsegGZ  活动起止时间：2022/6/22—2022/7/14   
-- 1）每周五  下午16点前 活动效果（只需提供：活动PV、UV、拉新、激活、预约试驾留资数量）
-- 2）2022/7/15日  下午3点前 结案数据（维度见附件模板）
-- 埋点测试(这里填写自己的user_id，user_id在会员表中查找)
select * from track.track t where t.usertag = '6039075' order by t.`date` desc

-- 文章明细	   BNcZFsegGZ
select o.ref_id,c.title-- ,c.上线时间
				,sum(case when o.type='VIEW' then 1 else 0 end)  PV
				,count(distinct case when o.type='VIEW' then o.user_id else null end) UV
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=1 then o.user_id else null end) 车主数
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=0 then o.user_id else null end) 粉丝数
				,count(DISTINCT case when o.type='VIEW' and m.id is null then o.user_id else null end) 游客数
				,sum(case when o.type='SUPPORT' then 1 else 0 end) '点赞量'
				,SUM(CASE when o.type='SHARE' then 1 else 0 end) '转发量'
				,SUM(CASE when o.type='COLLECTION' then 1 else 0 end) '收藏量'
	from 'cms-center'.cms_operate_log o
	left join (
				#查询文章pageid
			select c.page_id
			,c.title 
			,c.publish_date 上线时间
			from `cms-center`.cms_content c 
			where c.deleted=0 
			union all 
			#查询活动pageid
			select a.page_id,a.active_name title,a.date_create 上线时间
			from activity.cms_active a 
			where a.is_deleted=0
			-- and a.modifier like '%Wedo%' 
			and a.page_id is not null and a.page_id<>''
	) c on o.ref_id=c.page_id
	left join (
			select mm.id,mm.user_id,mm.is_vehicle
			from (
			select m.user_id,max(m.id) mid
			from member.tc_member_info m 
			where m.is_deleted=0 and m.member_status<>60341003
			GROUP BY 1  ) m
			LEFT JOIN member.tc_member_info mm on mm.id=m.mid
	)m on m.user_id=o.user_id
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	-- and date_create BETWEEN '2022-03-24' and '2021-12-23 23:59:59' 
	and date_create <='2022-07-14 23:59:59' and date_create >='2022-06-22 00:00:00'
	and o.ref_id='BNcZFsegGZ'  
	GROUP BY 1,2;


-- 拉新
select count(DISTINCT m.id)
from 'cms-center'.cms_operate_log l
join member.tc_member_info m on l.user_id=m.user_id and m.is_vehicle=0
where l.date_create >='2022-06-22 00:00:00' and l.date_create <= '2022-07-14 23:59:59' 
and l.ref_id='BNcZFsegGZ' and l.type ='VIEW' 
and m.create_time<date_add(l.date_create,INTERVAL 10 minute) and m.create_time>=DATE_sub(l.date_create,INTERVAL 10 MINUTE) ;

-- 激活
select '04激活沉睡用户数' 类目
,count(DISTINCT a.usertag ) 总数
from(
		-- 获取访问文章活动10分钟之前的最晚访问时间
		select t.usertag,b.ldate,b.is_vehicle,max(t.date) tdate
		from track.track t
		join (
			-- 获取访问文章活动的最早时间
			select m.is_vehicle,cast(l.user_id as varchar) user_id,min(date_create) ldate 
			from 'cms-center'.cms_operate_log l
			join member.tc_member_info m on l.user_id=m.user_id
			-- where l.date_create BETWEEN '2022-02-21' and '2022-03-20 23:59:59'  
			where l.date_create >='2022-06-22 00:00:00' and l.date_create <= '2022-07-14 23:59:59' 
			and l.ref_id='BNcZFsegGZ' 
			and l.type ='VIEW' 
			GROUP BY 1,2
		) b on b.user_id=t.usertag
		where t.date< DATE_SUB(b.ldate,INTERVAL 10  MINUTE)
		GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.ldate,INTERVAL 30 DAY) ; 

-- PV UV
select case when t.`data` like '%65A08327E85D47CE8DF3A8B02E6F6C48%' then '01弹窗'
	when t.`data` like '%7CCB0D357525409CB3390C04A91050BD%' then '04 朋友圈海报'
	when t.`data` like '%E233F7E6853D4A8E87D9CF7830E0604E%' then '02 首页banner'
	when t.`data` like '%3AE9009AF91F406180A8FBBE2B18BBEF%' then '03 首页活动banner'	
	when t.`data` like '%747C5C943B694A8CA1C10A31368DD060%' then '05 短信1'
	when t.`data` like '%DE6146C5802B4FCD94785652A9BBA502%' then '06 短信2'
	when t.`data` like '%444F6953999A494DACBF688EA302B3C8%' then '07 短信3'
	when t.`data` like '%BFEF8751CFFA42698B9E540A401E426E%' then '08 公众号推文'
    when json_extract(t.`data`,'$.path')='/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Flovecar-package%2Fappointment%2Fappointment%3Fchid%3DHMV892AUPX%26chcode%3DIBDMJUNXS6FSJSXY2022VCCN%26chtype%3D1' then '09 前往预约试驾'		
    else null end 分类,
-- tmi.IS_VEHICLE 是否车主,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-06-22 00:00:00' and t.`date` <= '2022-07-14 23:59:59'
group by 1
order by 1

-- PV UV
select case when t.`data` like '%B4705448D9074DCBAF81DFE1CD003233%' then '01 12大服务'
	when t.`data` like '%58D8D6C765764D9B904E350EDD2E888A%' then '02 车型销售政策引流'
	when t.`data` like '%F94F4233E11A45F386808516DB5E2B98%' then '03 加满一箱油活动引流'	
    else null end 分类,
-- tmi.IS_VEHICLE 是否车主,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-06-22 00:00:00' and t.`date` <= '2022-07-14 23:59:59'
group by 1
order by 1

select * 
from track.track t
where t.data like '%747C5C943B694A8CA1C10A31368DD060%'

select * 
from track.track t
where t.usertag =6400190

-- 拉新人数
select case when t.`data` like '%65A08327E85D47CE8DF3A8B02E6F6C48%' then '01弹窗'
	when t.`data` like '%7CCB0D357525409CB3390C04A91050BD%' then '04 朋友圈海报'
	when t.`data` like '%E233F7E6853D4A8E87D9CF7830E0604E%' then '02 首页banner'
	when t.`data` like '%3AE9009AF91F406180A8FBBE2B18BBEF%' then '03 首页活动banner'	
	when t.`data` like '%747C5C943B694A8CA1C10A31368DD060%' then '05 短信1'
	when t.`data` like '%DE6146C5802B4FCD94785652A9BBA502%' then '06 短信2'
	when t.`data` like '%444F6953999A494DACBF688EA302B3C8%' then '07 短信3'
	when t.`data` like '%BFEF8751CFFA42698B9E540A401E426E%' then '08 公众号推文'		
    else null end 分类,
	count(distinct m.id) 粉丝
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.IS_VEHICLE = 0
where t.`date` >= '2022-06-22 00:00:00'
and t.`date` <='2022-07-14 23:59:59'
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
group by 1
order by 1


-- 激活僵尸粉数
select 
a.is_vehicle,
a.channel,
-- a.usertag
count(distinct a.usertag)
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
						(select case when t.`data` like '%65A08327E85D47CE8DF3A8B02E6F6C48%' then '01弹窗'
							when t.`data` like '%7CCB0D357525409CB3390C04A91050BD%' then '04 朋友圈海报'
							when t.`data` like '%E233F7E6853D4A8E87D9CF7830E0604E%' then '02 首页banner'
							when t.`data` like '%3AE9009AF91F406180A8FBBE2B18BBEF%' then '03 首页活动banner'	
							when t.`data` like '%747C5C943B694A8CA1C10A31368DD060%' then '05 短信1'
							when t.`data` like '%DE6146C5802B4FCD94785652A9BBA502%' then '06 短信2'
							when t.`data` like '%444F6953999A494DACBF688EA302B3C8%' then '07 短信3'
							when t.`data` like '%BFEF8751CFFA42698B9E540A401E426E%' then '08 公众号推文'	
					    else null end 'channel',
								t.usertag,
								t.`date` 
							from track.track t 
							where t.`date` >= '2022-06-22 00:00:00'
							and t.`date` <= '2022-07-14 23:59:59') a 
					where a.channel is not null
					group by 1,2) b
				) c on t.usertag = c.usertag
		  where 
		  t.date >= '2022-06-22 00:00:00'
		  and t.date <='2022-07-14 23:59:59'
		  GROUP BY 1,2,3
		 ) b on b.usertag=t.usertag
	 where t.date< DATE_SUB(b.mdate,INTERVAL 10 MINUTE)
	 GROUP BY 1,2,3,4
	) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1,2
order by 1,2


-- 车主节试驾预约人数  =有意向用户数= 经销商跟进数=下发数量=实际留资人数
select 
-- DATE_FORMAT(m.预约时间,'%Y-%m-%d')日期,
-- m.车型,
COUNT(distinct m.客户ID)预约试驾人数 from
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
WHERE ta.CREATED_AT >= '2022-06-22'
AND ta.CREATED_AT <= '2022-07-14 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMJUNXS6FSJSXY2022VCCN'   -- 试驾随心约
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT)m
order by 1

-- 预约并成功到店试驾数量
select count(DISTINCT x.客户ID)
from 
(
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
tm2.model_name 车型,
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
left join basic_data.tm_model tm on tad.SECOND_ID = tm.SERIES_ID
left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.MODEL_NAME 
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
WHERE ta.CREATED_AT >= '2022-06-22'
AND ta.CREATED_AT <= '2022-07-14 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
and tad.status= 70711002 -- 已试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMJUNXS6FSJSXY2022VCCN'   -- 试驾随心约
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT
)x 

-- order 订单转化数
select 
a.车型名称,
COUNT( DISTINCT a.`商机id`)
from
	(
	select a.business_id 商机id,min(a.create_time) 最早线索创建时间,f.MODEL_NAME 车型名称
	from customer.tt_clue_clean a 
	left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
	left join activity.cms_active c on a.campaign_id = c.uid
	left join customer_business.tm_clue_source d on d.ID = c.active_channel
	left join dictionary.tc_code e on a.clue_status = e.CODE_ID
	left join basic_data.tm_model f on a.model_id = f.id
	left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
	 left join dictionary.tc_code i on i.code_id = a.gender
	where a.create_time >= '2022-06-22'
	and a.create_time <='2022-07-14 23:59:59'
	and c.active_code='IBDMJUNXS6FSJSXY2022VCCN'   -- 试驾随心约
	and a.customer_type='15231001'  -- 个人
	and e.CODE_CN_DESC not in ('待清洗','待分配','无效')
	GROUP BY 1 
	) a 
join 
	(
	select a.CUSTOMER_BUSINESS_ID 商机id ,min(a.CREATED_AT) 订单时间
	from cyxdms_retail.tt_sales_orders a 
	left join dictionary.tc_code g on g.code_id = a.SO_STATUS
	where a.BUSINESS_TYPE<>14031002
	and a.IS_DELETED = 0
	-- and a.CREATED_AT  BETWEEN '2021-10-01' and '2021-10-07 23:59:59'
	and g.code_cn_desc in ('提交待审批','审批通过','已交车','退车中')
	GROUP BY 1 
	) b on a.`商机id`=b.`商机id`
	group by 1

-- 车型明细
select x.车型,count(预约ID)
from 
(
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
tm.MODEL_NAME 车型,
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
left join basic_data.tm_model tm on tad.SECOND_ID = tm.SERIES_ID
left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.MODEL_NAME 
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
WHERE ta.CREATED_AT >= '2022-06-22'
AND ta.CREATED_AT <= '2022-07-14 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMJUNXS6FSJSXY2022VCCN'   -- 试驾随心约
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT )x
group by 1


-- 预约并成功到店试驾明细
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
WHERE ta.CREATED_AT >= '2022-06-22'
AND ta.CREATED_AT <= '2022-07-14 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
and tad.status= 70711002 -- 已试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMJUNXS6FSJSXY2022VCC'   -- 试驾随心约
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT
