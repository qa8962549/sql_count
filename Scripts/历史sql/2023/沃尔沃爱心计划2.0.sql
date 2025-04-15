-- 活动每周给一次
-- 埋点测试
select * from track.track t where t.usertag = '5537985' order by t.`date` desc


-- 沃尔沃爱心计划专区总PV UV
select
COUNT(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
COUNT(case when tmi.IS_VEHICLE <> 1 then t.usertag end) 粉丝PV,
COUNT(DISTINCT case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
COUNT(DISTINCT case when tmi.IS_VEHICLE <> 1 then t.usertag end) 粉丝UV
from track.track t
left join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR)
where t.`date` >= '2022-06-16'
and t.`date` <= '2022-06-30 23:59:59'
and (json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_onload' or json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_click_弹窗规则' or json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_click_去第一期'
or json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_click_视频' or t.data like '%A69EDADEB15A40A3BAC25296D44BB0D5%' or json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_地图页面_onload'
or json_extract(t.`data`,'$.embeddedpoint')='先心儿童_home_ONLOAD' or json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_专题页_onload_守护非遗瑰宝'
or json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_专题页_onload_守护教育公平' or json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_专题页_onload_守护空巢老人'
or json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_专题页_onload_守护盲人心灯' or json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_新增活动_click_提交按钮'
or t.`data` like '%8BF8D35AEB46476E940077A2DB9C8B78%' or json_extract(t.`data`,'$.pageId')='BCAlc8VGtX' or json_extract(t.`data`,'$.pageId')='4xOK78u7nR' or json_extract(t.`data`,'$.pageId')='H3g1ABFEmI'
or json_extract(t.`data`,'$.pageId')='KeaWK9K3Ya' or json_extract(t.`data`,'$.pageId')='OKeWFE2GQs' or json_extract(t.`data`,'$.pageId')='Qf4wrd7onC')


-- 活动PV UV
select
case when t.typeid = 'XWSJXCX_START' then '01 启动小程序'
	when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_onload' then '02 爱心计划首页'
	when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_click_弹窗规则' then '03 爱心计划-Banner-弹窗规则'
	when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_click_去第一期' then '04 爱心计划-Banner-点亮公益地图'
	when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_click_视频' then '05 爱心计划-Banner-轮播视频'
	when t.data like '%A69EDADEB15A40A3BAC25296D44BB0D5%' then '06 爱心活动发起Btn'
	when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_地图页面_onload' then '07点亮公益地图'
	when json_extract(t.`data`,'$.embeddedpoint')='先心儿童_home_ONLOAD' then '08 守护先心儿童'
	when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_专题页_onload_守护非遗瑰宝' then '09 守护非遗瑰宝'
	when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_专题页_onload_守护教育公平' then '10 守护教育公平'
	when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_专题页_onload_守护空巢老人' then '11 守护空巢老人'
	when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_专题页_onload_守护盲人心灯' then '12 守护盲人心灯'	
	when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_新增活动_click_提交按钮' then '13 活动报名提交按钮'
	when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页/专题页_click_活动发起按钮' then '14 活动发起按钮'
	when t.`data` like '%8BF8D35AEB46476E940077A2DB9C8B78%' then '15 文章打卡'
else null end '分类',
COUNT(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
COUNT(case when tmi.IS_VEHICLE <> 1 then t.usertag end) 粉丝PV,
COUNT(DISTINCT case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
COUNT(DISTINCT case when tmi.IS_VEHICLE <> 1 then t.usertag end) 粉丝UV
from track.track t
left join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR)
where t.`date` >= '2022-06-16'
and t.`date` <= '2022-06-30 23:59:59'	
group by 1
order by 1;



珠宝
活动一
"pageId":"BCAlc8VGtX"

教育
活动一
"pageId":"4xOK78u7nR"

活动二
"pageId":"H3g1ABFEmI"

老人
"pageId":"KeaWK9K3Ya"

盲人
"pageId":"OKeWFE2GQs"

抗疫英雄
"pageId":"Qf4wrd7onC"


select
case when json_extract(t.`data`,'$.pageId')='BCAlc8VGtX' then '01 珠宝活动一'
	when json_extract(t.`data`,'$.pageId')='4xOK78u7nR' then '02 教育活动一'
	when json_extract(t.`data`,'$.pageId')='H3g1ABFEmI' then '03 教育活动二'
	when json_extract(t.`data`,'$.pageId')='KeaWK9K3Ya' then '04 老人活动一'
	when json_extract(t.`data`,'$.pageId')='OKeWFE2GQs' then '05 盲人活动一'
	when json_extract(t.`data`,'$.pageId')='Qf4wrd7onC' then '06 抗疫英雄'
else null end '分类',
COUNT(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
COUNT(case when tmi.IS_VEHICLE <> 1 then t.usertag end) 粉丝PV,
COUNT(DISTINCT case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
COUNT(DISTINCT case when tmi.IS_VEHICLE <> 1 then t.usertag end) 粉丝UV
from track.track t
left join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR)
where t.`date` >= '2022-06-16'
and t.`date` <= '2022-06-30 23:59:59'	
group by 1
order by 1;


-- 5、点赞、收藏、转发、查看量
select
case when col.`type` = 'VIEW' then '01 查看'
	when col.`type` = 'COLLECTION' then '02 收藏'
	when col.`type` = 'SUPPORT' then '03 点赞'
	when col.`type` = 'SHARE' then '04 分享'
	end 点击动作,
count(case when tmi.IS_VEHICLE = 1 then col.user_id end)车主人数,
count(case when tmi.IS_VEHICLE <> 1 then col.user_id end)粉丝人数
from `cms-center`.cms_operate_log col
left join `member`.tc_member_info tmi on col.user_id = CAST(tmi.USER_ID AS VARCHAR)
where col.ref_id = 'H3g1ABFEmI'      -- 修改活动id即可
and col.date_create >= '2022-06-05'
and col.date_create <= '2022-06-30 23:59:59'
and col.deleted = 0
group by 1
order by 1



select * from
-- 爱心计划
(select
distinct t.usertag
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR)
where t.`date` >= '2022-05-20'
and t.`date` <= '2022-05-31 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_onload')a
left join
-- 音乐课堂
(select
distinct col.user_id
from `cms-center`.cms_operate_log col
where col.ref_id in ('H3g1ABFEmI','ktgB0ySwBb')      -- 远山里的音乐课堂
and col.date_create >= '2022-05-20'
and col.date_create <= '2022-05-31 23:59:59'
and col.`type` = 'VIEW'
and col.deleted = 0)b
on a.usertag = b.user_id


-- 点赞、收藏、转发、查看量
select
case when col.`type` = 'VIEW' then '01 查看'
	when col.`type` = 'COLLECTION' then '02 收藏'
	when col.`type` = 'SUPPORT' then '03 点赞'
	when col.`type` = 'SHARE' then '04 分享'
	end 点击动作,
count(col.user_id)人数
from `cms-center`.cms_operate_log col
left join `member`.tc_member_info tmi on col.user_id = CAST(tmi.USER_ID AS VARCHAR)
where col.ref_id in ('H3g1ABFEmI','ktgB0ySwBb')      -- 修改活动id即可
and col.date_create >= '2022-05-20'
and col.date_create <= '2022-05-31 23:59:59'
and col.deleted = 0
group by 1
order by 1


-- 留言
select
COUNT(teh.content)留言量 
from comment.tt_evaluation_history teh
where teh.object_id in ('H3g1ABFEmI','ktgB0ySwBb')
and teh.create_time >= '2022-05-20'
and teh.create_time <= '2022-05-31 23:59:59'
and teh.is_deleted = 0


-- 激活僵尸粉
select
a.is_vehicle 是否车主,
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
  where (json_extract(t.`data`,'$.pageId') = 'ktgB0ySwBb' or json_extract(t.`data`,'$.pageId') = 'H3g1ABFEmI' or json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_onload')
  and t.date >= '2022-05-20' and t.date <= '2022-05-31 23:59:59'
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date < DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1
ORDER BY 1 DESC

-- 活跃车主人数
select
COUNT(distinct t.usertag)活跃车主人数
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE = 1
where t.`date` >= '2022-05-20' and t.`date` <= '2022-05-31 23:59:59'
and (json_extract(t.`data`,'$.pageId') = 'ktgB0ySwBb' or json_extract(t.`data`,'$.pageId') = 'H3g1ABFEmI' or json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_onload')
and t.`date` > tmi.MEMBER_TIME    -- 访问时间大于注册时间，算活跃






-- 瓦罐联盟 长图文
"pageId":"ktgB0ySwBb"
-- PV UV
select
col.ref_id,
count(col.user_id)PV,
count(distinct col.user_id)UV
from `cms-center`.cms_operate_log col
where col.ref_id = 'ktgB0ySwBb'      -- 远山里的音乐课堂
and col.date_create >= '2022-05-20'
and col.date_create <= '2022-05-31 23:59:59'
and col.`type` = 'VIEW'
and col.deleted = 0

-- 激活僵尸粉
select
a.is_vehicle 是否车主,
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
  where json_extract(t.`data`,'$.pageId') = 'ktgB0ySwBb'
  and t.date >= '2022-05-20' and t.date <= '2022-05-31 23:59:59'
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date < DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1
ORDER BY 1 DESC

-- 活跃车主人数
select
COUNT(distinct t.usertag)活跃车主人数
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE = 1
where t.`date` >= '2022-05-20' and t.`date` <= '2022-05-31 23:59:59'
and json_extract(t.`data`,'$.pageId') = 'ktgB0ySwBb'
and t.`date` > tmi.MEMBER_TIME    -- 访问时间大于注册时间，算活跃

-- 点赞、收藏、转发、查看量
select
case when col.`type` = 'VIEW' then '01 查看'
	when col.`type` = 'COLLECTION' then '02 收藏'
	when col.`type` = 'SUPPORT' then '03 点赞'
	when col.`type` = 'SHARE' then '04 分享'
	end 点击动作,
count(col.user_id)人数
from `cms-center`.cms_operate_log col
left join `member`.tc_member_info tmi on col.user_id = CAST(tmi.USER_ID AS VARCHAR)
where col.ref_id = 'ktgB0ySwBb'      -- 修改活动id即可
and col.date_create >= '2022-05-20'
and col.date_create <= '2022-05-31 23:59:59'
and col.deleted = 0
group by 1
order by 1


-- 留言
select
COUNT(teh.content)留言量 
from comment.tt_evaluation_history teh
where teh.evaluation_source = '瓦罐青年 就是要上天！'
and teh.create_time >= '2022-05-20'
and teh.create_time <= '2022-05-31 23:59:59'
and teh.is_deleted = 0







-- 爱心计划专区主页
select
case when json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_onload' then '02 爱心计划首页'
else null end '分类',
COUNT(t.usertag)PV,
COUNT(DISTINCT t.usertag)UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR)
where t.`date` >= '2022-05-20'
and t.`date` <= '2022-05-31 23:59:59'	
group by 1
order by 1;

-- 激活僵尸粉
select
a.is_vehicle 是否车主,
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
  where json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_onload'
  and t.date >= '2022-05-20' and t.date <= '2022-05-31 23:59:59'
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date < DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1
ORDER BY 1 DESC

-- 活跃车主人数
select
COUNT(distinct t.usertag)活跃车主人数
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE = 1
where t.`date` >= '2022-05-20' and t.`date` <= '2022-05-31 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_首页_onload'
and t.`date` > tmi.MEMBER_TIME    -- 访问时间大于注册时间，算活跃



-- 远山里的音乐课堂    "pageId":"H3g1ABFEmI"
select * from track.track t where t.usertag = '5537985' order by t.`date` desc

-- PV UV
select
col.ref_id,
count(col.user_id)PV,
count(distinct col.user_id)UV
from `cms-center`.cms_operate_log col
where col.ref_id = 'H3g1ABFEmI'      -- 远山里的音乐课堂
and col.date_create >= '2022-05-20'
and col.date_create <= '2022-05-31 23:59:59'
and col.`type` = 'VIEW'
and col.deleted = 0

-- 激活僵尸粉
select
a.is_vehicle 是否车主,
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
  where json_extract(t.`data`,'$.pageId') = 'H3g1ABFEmI'
  and t.date >= '2022-05-20' and t.date <= '2022-05-31 23:59:59'
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date < DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1
ORDER BY 1 DESC

-- 活跃车主人数
select
COUNT(distinct t.usertag)活跃车主人数
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE = 1
where t.`date` >= '2022-05-20' and t.`date` <= '2022-05-31 23:59:59'
and json_extract(t.`data`,'$.pageId') = 'H3g1ABFEmI'
and t.`date` > tmi.MEMBER_TIME    -- 访问时间大于注册时间，算活跃

-- 点赞、收藏、转发、查看量
select
case when col.`type` = 'VIEW' then '01 查看'
	when col.`type` = 'COLLECTION' then '02 收藏'
	when col.`type` = 'SUPPORT' then '03 点赞'
	when col.`type` = 'SHARE' then '04 分享'
	end 点击动作,
count(col.user_id)人数
from `cms-center`.cms_operate_log col
left join `member`.tc_member_info tmi on col.user_id = CAST(tmi.USER_ID AS VARCHAR)
where col.ref_id = 'H3g1ABFEmI'      -- 修改活动id即可
and col.date_create >= '2022-05-20'
and col.date_create <= '2022-05-31 23:59:59'
and col.deleted = 0
group by 1
order by 1