1） 2022/9/7      下午16:00前
2） 2022/9/16    下午15:00前（具体维度见附件模板）

-- 文章明细	
select o.ref_id,c.title-- ,c.上线时间
				,sum(case when o.type='VIEW' then 1 else 0 end)  PV
				,count(distinct case when o.type='VIEW' then o.user_id else null end) UV
				,sum(case when o.type='SUPPORT' then 1 else 0 end) '点赞量'
				,SUM(CASE when o.type='SHARE' then 1 else 0 end) '转发量'
				,SUM(CASE when o.type='COLLECTION' then 1 else 0 end) '收藏量'
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=1 then o.user_id else null end) 车主数
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=0 then o.user_id else null end) 粉丝数
				,count(DISTINCT case when o.type='VIEW' and m.id is null then o.user_id else null end) 游客数
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
	and date_create <='2022-09-15 23:59:59' and date_create >='2022-09-01'
	and o.ref_id='uue0gTcB6C'  
	GROUP BY 1,2

-- PV UV
select case when t.`data` like '%2E606EA8033649ED89579BA6E79918B7%' then '01 点击引流12服专区【立即前往】按钮'
	when t.`data` like '%1A23A5812A7B4E88B7E8D67B45956C0A%' then '02 交车官方礼活动引流'
	when t.`data` like '%EDD2205806784A41A6BF96CD222A1AA3%' then '03 点击【热门车型销售政策，一键获悉】banner'
	when t.`data` like '%E51EEE2C720949EEA4014781599D867D%' then '04 首页活动banner'	
    when json_extract(t.`data`,'$.path')='/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Flovecar-package%2Fappointment%2Fappointment%3Fchid%3DL629FOK71V%26chcode%3DIBDMAUGPWWCDYYSJ2022VCCN%26chtype%3D1' then '00 前往预约试驾'
    else null end 分类,
-- tmi.IS_VEHICLE 是否车主,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-09-01' and t.`date` <= '2022-09-15 23:59:59'
group by 1
order by 1

-- PV UV
select case when t.`data` like '%F470DBC3E44E400A87AE987EA702526B%' then 'F470DBC3E44E400A87AE987EA702526B'
	when t.`data` like '%98A8ABFBB69245B292B4C73D77FD3DC3%' then '98A8ABFBB69245B292B4C73D77FD3DC3'
	when t.`data` like '%5DDA620854C44EBEA7C6CDDFD69EB0B8%' then '5DDA620854C44EBEA7C6CDDFD69EB0B8'
	when t.`data` like '%867D6CBF4C724D3D86001ED79A0F5E42%' then '867D6CBF4C724D3D86001ED79A0F5E42'	
	when t.`data` like '%4A45FFAF657F47B4B9AD5835A52460D4%' then '4A45FFAF657F47B4B9AD5835A52460D4'
	when t.`data` like '%16C594829FC94A9F8AACA25AC0BE226B%' then '16C594829FC94A9F8AACA25AC0BE226B'
	when t.`data` like '%AD207779834840DBAFA3E22FA8ACF7CC%' then 'AD207779834840DBAFA3E22FA8ACF7CC'
	when t.`data` like '%D455E165C2A044FF881C3576FEDDC599%' then 'D455E165C2A044FF881C3576FEDDC599'
	else null end 分类,
-- tmi.IS_VEHICLE 是否车主,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-09-01' and t.`date` <= '2022-09-15 23:59:59'
group by 1
order by 1

-- 拉新人数
select 
-- m.IS_VEHICLE,
	case when t.`data` like '%F470DBC3E44E400A87AE987EA702526B%' then 'F470DBC3E44E400A87AE987EA702526B'
	when t.`data` like '%98A8ABFBB69245B292B4C73D77FD3DC3%' then '98A8ABFBB69245B292B4C73D77FD3DC3'
	when t.`data` like '%5DDA620854C44EBEA7C6CDDFD69EB0B8%' then '5DDA620854C44EBEA7C6CDDFD69EB0B8'
	when t.`data` like '%867D6CBF4C724D3D86001ED79A0F5E42%' then '867D6CBF4C724D3D86001ED79A0F5E42'	
	when t.`data` like '%4A45FFAF657F47B4B9AD5835A52460D4%' then '4A45FFAF657F47B4B9AD5835A52460D4'
	when t.`data` like '%16C594829FC94A9F8AACA25AC0BE226B%' then '16C594829FC94A9F8AACA25AC0BE226B'
	when t.`data` like '%AD207779834840DBAFA3E22FA8ACF7CC%' then 'AD207779834840DBAFA3E22FA8ACF7CC'
	when t.`data` like '%D455E165C2A044FF881C3576FEDDC599%' then 'D455E165C2A044FF881C3576FEDDC599'
	end '入口',
	count(distinct case when m.IS_VEHICLE = 0 then m.id end) 粉丝
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.IS_VEHICLE = 0
where t.`date` >= '2022-09-01' and t.`date` <= '2022-09-15 23:59:59'
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
		case when t.`data` like '%F470DBC3E44E400A87AE987EA702526B%' then 'F470DBC3E44E400A87AE987EA702526B'
	when t.`data` like '%98A8ABFBB69245B292B4C73D77FD3DC3%' then '98A8ABFBB69245B292B4C73D77FD3DC3'
	when t.`data` like '%5DDA620854C44EBEA7C6CDDFD69EB0B8%' then '5DDA620854C44EBEA7C6CDDFD69EB0B8'
	when t.`data` like '%867D6CBF4C724D3D86001ED79A0F5E42%' then '867D6CBF4C724D3D86001ED79A0F5E42'	
	when t.`data` like '%4A45FFAF657F47B4B9AD5835A52460D4%' then '4A45FFAF657F47B4B9AD5835A52460D4'
	when t.`data` like '%16C594829FC94A9F8AACA25AC0BE226B%' then '16C594829FC94A9F8AACA25AC0BE226B'
	when t.`data` like '%AD207779834840DBAFA3E22FA8ACF7CC%' then 'AD207779834840DBAFA3E22FA8ACF7CC'
	when t.`data` like '%D455E165C2A044FF881C3576FEDDC599%' then 'D455E165C2A044FF881C3576FEDDC599'
			else null end 'channel',
			t.usertag,
			t.`date` 
		from track.track t 
		where t.`date` >= '2022-09-01' and t.`date` <= '2022-09-15 23:59:59') a 
	where a.channel is not null
	group by 1,2) b) c on t.usertag = c.usertag
  where 
  t.`date` >= '2022-09-01' and t.`date` <= '2022-09-15 23:59:59'
  GROUP BY 1,2,3
 ) b on b.usertag=t.usertag
 where t.date< DATE_SUB(b.mdate,INTERVAL 10 MINUTE)
 GROUP BY 1,2,3,4
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1

-- 拉新
select count(DISTINCT m.id)
from 'cms-center'.cms_operate_log l
join member.tc_member_info m on l.user_id=m.user_id and m.is_vehicle=0
where l.date_create <='2022-09-15 23:59:59' and l.date_create >='2022-09-01' 
and l.ref_id='uue0gTcB6C' and l.type ='VIEW' 
and m.create_time<date_add(l.date_create,INTERVAL 10 minute) and m.create_time>=DATE_sub(l.date_create,INTERVAL 10 MINUTE) ;

-- 激活
select '04激活沉睡用户数' 类目
,count(DISTINCT case when a.IS_VEHICLE=1 then a.usertag else null end) 车主
,count(DISTINCT case when IFNULL(a.IS_VEHICLE,0)=0 then a.usertag else null end) 粉丝
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
			where l.date_create <='2022-09-15 23:59:59' and l.date_create >='2022-09-01'
			and l.ref_id='uue0gTcB6C' 
			and l.type ='VIEW' 
			GROUP BY 1,2
		) b on b.user_id=t.usertag
		where t.date< DATE_SUB(b.ldate,INTERVAL 10  MINUTE)
		GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.ldate,INTERVAL 30 DAY) ; 


-- 车主节试驾预约人数  =有意向用户数= 经销商跟进数=下发数量=实际留资人数
select 
-- DATE_FORMAT(m.预约时间,'%Y-%m-%d')日期,
m.车型,
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
WHERE ta.CREATED_AT >= '2022-09-01'
AND ta.CREATED_AT <= '2022-09-15 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMAUGPWWCDYYSJ2022VCCN'  
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT)m
group by 1
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
WHERE ta.CREATED_AT >= '2022-09-01'
AND ta.CREATED_AT <= '2022-09-15 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
and tad.status= 70711002 -- 已试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
-- and ca.active_code = 'IBDMAUGPWWCDYYSJ2022VCCN'   -- 销售六服
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT
)x 

-- order 订单转化数
select 
a.商机id,
a.车型名称,
a.最早线索创建时间,
b.订单时间
-- COUNT( DISTINCT a.`商机id`)
from
	(
	select a.business_id 商机id,
	min(a.create_time) 最早线索创建时间,
	f.MODEL_NAME 车型名称
	from customer.tt_clue_clean a 
	left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
	left join activity.cms_active c on a.campaign_id = c.uid
	left join customer_business.tm_clue_source d on d.ID = c.active_channel
	left join dictionary.tc_code e on a.clue_status = e.CODE_ID
	left join basic_data.tm_model f on a.model_id = f.id
	left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
	 left join dictionary.tc_code i on i.code_id = a.gender
	where a.create_time >= '2022-09-01'
	and a.create_time <='2022-09-15 23:59:59'
	and c.active_code='IBDMAUGPWWCDYYSJ2022VCCN'   -- 销售六服
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
	and a.CREATED_AT  >= '2022-09-01'
	and a.CREATED_AT  <='2022-09-15 23:59:59'
	and g.code_cn_desc in ('提交待审批','审批通过','已交车','退车中')
	GROUP BY 1 
	) b on a.`商机id`=b.`商机id`
-- group by 1
	
select * from cyxdms_retail.tt_sales_orders tso where tso.CUSTOMER_BUSINESS_ID =1440496722966372354

select * from customer.tt_clue_clean a where a.business_id =1440496722966372354

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
WHERE ta.CREATED_AT >= '2022-09-01'
AND ta.CREATED_AT <= '2022-09-15 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMAUGPWWCDYYSJ2022VCCN'   -- 销售六服
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT )x
group by 1


-- 预约成功明细
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
tad.drive_e_at 试驾结束时间,
x.收货人姓名,
x.收货人手机号 收货人电话,
x.收货地址 收货人地址
FROM cyx_appointment.tt_appointment ta
LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
LEFT JOIN organization.tm_company tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
LEFT JOIN cyxdms_retail.tt_sales_orders tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID
LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS
left join `member`.tc_member_info tmi on tmi.CUST_ID =ta.ONE_ID 
left join (
	select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
		(
		select 
		tma.MEMBER_ID,
		tma.CONSIGNEE_NAME 收货人姓名,
		tma.CONSIGNEE_PHONE 收货人手机号,
		CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址,
		row_number() over(partition by tma.member_address order by tma.create_time desc) rk
		from `member`.tc_member_address tma
		left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
		left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
		left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
		where tma.IS_DELETED = 0
		and tma.IS_DEFAULT = 1   -- 默认收货地址
		)c 
	where c.rk = 1)x on tmi.ID =x.member_id
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
-- and tad.status= 70711002 -- 已试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMAUGPWWCDYYSJ2022VCCN'   -- 销售六服
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT


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
and a.CREATED_AT BETWEEN '2022-09-01' AND '2022-09-15 23:59:59'
and b.active_code='IBDMAUGPWWCDYYSJ2022VCCN'
order by a.CREATED_AT DESC 
