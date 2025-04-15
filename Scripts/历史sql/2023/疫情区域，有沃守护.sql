-- 埋点测试(这里填写自己的user_id，user_id在会员表中查找)
select * from track.track t where t.usertag = '6039075' order by t.`date` desc

-- PVUV pageid=m3qgzmak8j
select
case 
when t.data like '%EADD18C9BD1A422FAEAAF27D87A38EE0%' then '01首页banner'
when t.data like '%3879D0EEA93F47B7A847229FCE17AC6D%' then '02首页-活动'
when t.data like '%8D6DA49A891A40D591176FFA97EA44D1%' then '03弹窗'
when t.data like '%0593CF37E59C447DB64B0DB130E0709C%' then '04养修预约点击'
when t.data like '%CECD3C3B9750497DACE6E1BD76FC8850%' then '05推文'
when t.data like '%E3FC47D9E00B444A8194A0825E4F53AE%' then '06传播海报'
else null end '分类',
count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 
where t.`date` >= '2022-06-17 00:00:00'   -- 每天修改起始时间
and t.`date` <= '2022-06-23 23:59:59'		-- 每天修改截止时间
and tmi.IS_DELETED = 0
group by 1
order by 1

-- 空气消杀主页面 PV UV 
select
tmi.IS_VEHICLE,
COUNT(col.user_id)PV,
COUNT(distinct col.user_id)UV 
from `cms-center`.cms_operate_log col 
join `member`.tc_member_info tmi on col.user_id = tmi.USER_ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where col.ref_id = 'm3qgzmak8j'
and col.date_create >= '2022-06-17 00:00:00' and col.date_create <=  '2022-06-23 23:59:59'
and col.`type` = 'VIEW'
and col.deleted = 0
group by 1
order by 1 desc

-- 浏览点赞转发收藏
select
tmi.IS_VEHICLE,
case col.type
when 'SUPPORT' then '01点赞'
when 'COLLECTION' then '02收藏'
when 'SHARE' then '03转发'
when 'VIEW' then '04查看' end 事件动作,
COUNT(col.user_id)人数
from `cms-center`.cms_operate_log col 
left join `member`.tc_member_info tmi on col.user_id =tmi.USER_ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where col.ref_id = 'm3qgzmak8j'
and col.date_create >= '2022-06-17 00:00:00' and col.date_create <= '2022-06-23 23:59:59'
and col.deleted = 0
group by 1,2
order by 1,2


-- 评论条数
select
tmi.IS_VEHICLE,
COUNT(teh.content)留言条数
from comment.tt_evaluation_history teh 
left join `member`.tc_member_info tmi on teh.mobile = tmi.MEMBER_PHONE and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where teh.object_id = 'm3qgzmak8j'
and teh.create_time >= '2022-06-17 00:00:00' and teh.create_time <='2022-06-23 23:59:59'
and teh.is_deleted = 0
group by 1


-- 活动拉新人数、排除车主
select count(DISTINCT m.id)拉新人数
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.is_vehicle = 0  -- 排除车主
where t.`date` >= '2022-06-17 00:00:00' 
and t.`date` <= '2022-06-23 23:59:59'
and json_extract(t.`data`,'$.pageId')='m3qgzmak8j'
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)


-- 僵尸粉-track表计算
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
  where json_extract(t.`data`,'$.pageId')='m3qgzmak8j'
	and t.`date` >= '2022-06-17 00:00:00'
	and t.`date` <= '2022-06-23 23:59:59'
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date< DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1;


-- 成功提交养修预约人数
select 
COUNT(b.车主oneid)成功提交养修预约人数 
from
(select
distinct tmi.ID 会员ID
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-06-17 00:00:00'and t.`date` <= '2022-06-23 23:59:59'
and t.`data` like '%0593CF37E59C447DB64B0DB130E0709C%')a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.COMPANY_NAME_CN "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.ID "会员ID",
       tmi.MEMBER_PHONE "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = "10041001" then "是" 
    when tam.IS_TAKE_CAR = "10041002" then "否" 
     end  "是否取车",
       case when tam.IS_GIVE_CAR = "10041001" then "是"
         when tam.IS_GIVE_CAR = "10041002" then "否"
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta.CREATED_AT "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >= '2022-06-17 00:00:00'
and ta.CREATED_AT < '2022-06-23 23:59:59'
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID



-- 成功提交养修预约并进厂人数
select COUNT(b.养修预约ID)成功提交养修预约并进厂人数 from
(select
distinct tmi.ID 会员ID
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-06-17 00:00:00'and t.`date` <= '2022-06-23 23:59:59'
and t.`data` like '%0593CF37E59C447DB64B0DB130E0709C%')a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.COMPANY_NAME_CN "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.ID "会员ID",
       tmi.MEMBER_PHONE "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = "10041001" then "是" 
    when tam.IS_TAKE_CAR = "10041002" then "否" 
     end  "是否取车",
       case when tam.IS_GIVE_CAR = "10041001" then "是"
         when tam.IS_GIVE_CAR = "10041002" then "否"
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta.CREATED_AT "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >= '2022-06-17 00:00:00'
and ta.CREATED_AT < '2022-06-23 23:59:59'
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID
where b.养修状态 in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')
