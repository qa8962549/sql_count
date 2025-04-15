数据背景：2022车主品牌大使开官活动在8月10日在沃世界小程序上线，进行成都站车主品牌大使线上招募以及slogan征集结果公示

数据用途：追踪长图文上线后活动效果，便于数据分析

活动时间：2022年8月10日-2022年8月18日

数据交付周期类型：8.19活动结束拉取1次，数据截止到8.18 24点

数据报告字段&对应tcode详见附件。

-- 1、埋点
select * from track.track t where t.usertag = '5537985' order by t.`date` desc

-- 2、活动入口PV UV
select 
case when t.data like '%8A8E3AAEE7CB4C2B8510D1F72B5E0F32%' then '首页 置顶banner UV'
    when t.data like '%5ADA59DC646B4DFCBB977BA695E6DD6C%' then '首页 活动banner UV'
    when t.data like '%C77C6FFD11284623A306F39B95D04BF1%' then '弹窗 UV'
    when t.data like '%927D261E6B434D6DA28B3426963D31D9%' then '太阳码扫码UV'
    when t.data like '%927D261E6B434D6DA28B3426963D31D9%' then '推文引流UV（8/15露出）'
    when t.data like '%622FEF3C8AA64CA68871038E423F9218%' then '月历订阅消息UV'
	else null end '分类',
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t 
left join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
where t.`date` >= '2022-08-18'
and t.`date` <= '2022-08-18 23:59:59'
group by 1
order by 1
UNION ALL
select 
case when t.data like '%8A8E3AAEE7CB4C2B8510D1F72B5E0F32%' then '首页 置顶banner PV'
    when t.data like '%5ADA59DC646B4DFCBB977BA695E6DD6C%' then '首页 活动banner PV'
    when t.data like '%C77C6FFD11284623A306F39B95D04BF1%' then '弹窗 PV'
    when t.data like '%927D261E6B434D6DA28B3426963D31D9%' then '太阳码扫码PV'
    when t.data like '%927D261E6B434D6DA28B3426963D31D9%' then '推文引流PV（8/15露出）'
    when t.data like '%622FEF3C8AA64CA68871038E423F9218%' then '月历订阅消息PV'
	else null end '分类',
count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV
from track.track t 
left join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
where t.`date` >= '2022-08-18'
and t.`date` <= '2022-08-18 23:59:59'
group by 1
order by 1
UNION ALL 
-- 4、点赞、收藏、转发
select
case when col.`type` = 'SUPPORT' then '点赞'
	when col.`type` = 'COLLECTION' then '收藏'
	when col.`type` = 'SHARE' then '转发'
	end 点击动作,
count(distinct case when tmi.IS_VEHICLE = 1 then col.user_id end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then col.user_id end) 粉丝UV
from `cms-center`.cms_operate_log col
join `member`.tc_member_info tmi on col.user_id = CAST(tmi.USER_ID AS VARCHAR)
where col.ref_id = 'HzKy4p5waD'    -- 车联网活动page_id
and col.`type` in ('SUPPORT','COLLECTION','SHARE')    -- 筛选点赞和收藏
and col.date_create >= '2022-08-18'
and col.date_create <= '2022-08-18 23:59:59'
and col.deleted = 0
group by 1
order by 1
union all 
-- 6、活动拉新人数、排除车主   
select 
-- DATE_FORMAT(t.date,'%Y-%m-%d'),
'拉新',
0,
count(DISTINCT m.id)拉新人数
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.is_vehicle = 0  -- 排除车主
where t.date >= '2022-08-10' and t.date <= '2022-08-18 23:59:59' 
and json_extract(t.`data`,'$.pageId')='HzKy4p5waD'
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
group by 1 
-- order by 1 
union all 
-- 3、主页面PV UV
select
'活动主页面 PV',
count(case when tmi.IS_VEHICLE = 1 then col.user_id end) 车主PV,
count(case when tmi.IS_VEHICLE = 0 then col.user_id end) 粉丝PV
from `cms-center`.cms_operate_log col
join `member`.tc_member_info tmi on col.user_id = tmi.USER_ID and tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
where col.date_create >= '2022-08-18'
and col.date_create <= '2022-08-18 23:59:59'
and col.ref_id = 'HzKy4p5waD'    -- 车联网活动page_id
and col.`type` = 'VIEW'    -- 筛选浏览数据
and col.deleted = 0
union all 
select
'活动主页面 UV',
count(distinct case when tmi.IS_VEHICLE = 1 then col.user_id end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then col.user_id end) 粉丝UV
from `cms-center`.cms_operate_log col
join `member`.tc_member_info tmi on col.user_id = tmi.USER_ID and tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
where col.date_create >= '2022-08-18'
and col.date_create <= '2022-08-18 23:59:59'
and col.ref_id = 'HzKy4p5waD'    -- 车联网活动page_id
and col.`type` = 'VIEW'    -- 筛选浏览数据
and col.deleted = 0
union all 
-- 5、评论数
select
'评论',
COUNT(case when tmi.IS_VEHICLE =1 then teh.content else null end)车主评论,
COUNT(case when tmi.IS_VEHICLE =0 then teh.content else null end)粉丝评论 
from comment.tt_evaluation_history teh
left join `member`.tc_member_info tmi on teh.user_id=tmi.USER_ID and tmi.IS_DELETED =0 and tmi.MEMBER_STATUS <> 60341003
where teh.object_id = 'HzKy4p5waD'   -- 车联网活动page_id
and teh.create_time >= '2022-08-18'
and teh.create_time <= '2022-08-18 23:59:59'
and teh.is_deleted = 0
union all 
-- 7、僵尸粉-track表计算
select
-- DATE_FORMAT(a.tt,'%Y-%m-%d'),
'激活沉默用户数（1个月未进小程序）',
count(distinct case when a.IS_VEHICLE = 1 then a.usertag else null end ) 激活车主数量,
count(distinct case when a.IS_VEHICLE = 0 then a.usertag else null end ) 激活粉丝数量
from(
	 -- 获取访问文章活动10分钟之前的最晚访问时间
	 select t.usertag,b.mdate,b.is_vehicle,max(t.date) tdate,b.tt
	 from track.track t
	 join (
	  -- 获取访问文章活动的最早时间
	  select m.is_vehicle,t.usertag,min(t.date) mdate ,t.date tt
	  from track.track t 
	  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
	  where json_extract(t.`data`,'$.pageId')='HzKy4p5waD'
	  and t.date >= '2022-08-10' and t.date <= '2022-08-18 23:59:59'
	  GROUP BY 1,2
	 ) b on b.usertag=t.usertag
	 where t.date< DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
	 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1
order by 1 desc