-- PV UV
select case when t.`data` like '%3B41800B37B841809161BFA4EC0AF178%' then '01'
else null end 分类,
-- tmi.IS_VEHICLE 是否车主,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-06-25 12:00:00' and t.`date` <= '2022-09-27 12:00:00'
group by 1
order by 1

-- 点击时间
select 
t.usertag,
tmi.CUST_ID,
t.date
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-06-25 12:00:00' and t.`date` <= '2022-09-27 12:00:00'
and t.`data` like '%3B41800B37B841809161BFA4EC0AF178%'
order by 2

-- 拉新人数
select 
-- m.IS_VEHICLE,
	case when t.`data` like '%3B41800B37B841809161BFA4EC0AF178%' then 'F470DBC3E44E400A87AE987EA702526B'
	end '入口',
	count(distinct case when m.IS_VEHICLE = 0 then m.id end) 粉丝
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.IS_VEHICLE = 0
where t.`date` >= '2022-06-25 12:00:00' and t.`date` <= '2022-09-27 12:00:00'
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
		case when t.`data` like '%3B41800B37B841809161BFA4EC0AF178%' then 'F470DBC3E44E400A87AE987EA702526B'
			else null end 'channel',
			t.usertag,
			t.`date` 
		from track.track t 
		where t.`date` >= '2022-06-25 12:00:00' and t.`date` <= '2022-09-27 12:00:00') a 
	where a.channel is not null
	group by 1,2) b) c on t.usertag = c.usertag
  where 
  t.`date` >= '2022-06-25 12:00:00' and t.`date` <= '2022-09-27 12:00:00'
  GROUP BY 1,2,3
 ) b on b.usertag=t.usertag
 where t.date< DATE_SUB(b.mdate,INTERVAL 10 MINUTE)
 GROUP BY 1,2,3,4
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1


-- 预约并成功到店试驾数量
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
WHERE ta.CREATED_AT >= '2022-06-25 12:00:00'
AND ta.CREATED_AT <= '2022-09-27 12:00:00'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
and ta.one_id in (select 
tmi.CUST_ID
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-06-25 12:00:00' and t.`date` <= '2022-09-27 12:00:00'
and t.`data` like '%3B41800B37B841809161BFA4EC0AF178%')
-- and tad.status= 70711002 -- 已试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT

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
	where a.create_time >= '2022-06-25 12:00:00'
	and a.create_time <='2022-09-27 12:00:00'
	and a.one_id in (select 
	tmi.CUST_ID
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` >= '2022-06-25 12:00:00' and t.`date` <= '2022-09-27 12:00:00'
	and t.`data` like '%3B41800B37B841809161BFA4EC0AF178%')
-- 	and c.active_code='IBDMAUGPWWCDYYSJ2022VCCN'   -- 销售六服
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
	and a.CREATED_AT  >= '2022-06-25 12:00:00'
	and a.CREATED_AT  <='2022-09-27 12:00:00'
	and g.code_cn_desc in ('提交待审批','审批通过','已交车','退车中')
	GROUP BY 1 
	) b on a.`商机id`=b.`商机id`
