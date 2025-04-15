select * from member.tc_member_info tmi where tmi.member_phone = '18721762520'


-- 埋点测试(这里填写自己的user_id，user_id在会员表中查找)
select * from track.track t where t.usertag = '6039075' order by t.`date` desc

-- 活动PV UV  pcode=61160099&yepageid=675 C3uwSMsuKQ
select
case 
when t.data like '%7EFA56C8396D4D0FA04699BAC5E754EB%' then '1首页banner'
when t.data like '%1A393B5E3EB847C9B18B1CF5F0BF86FE%' then '2沃的活动'
when t.data like '%752DBCD6B61F4B008E96E6EE1ED50FC0%' then '3俱乐部专区banner'
when json_extract(t.`data`,'$.embeddedpoint')= 'CHEZHUGUSHI_HOME_ONLOAD' then '0车主故事专区主页面'
when json_extract(t.`data`,'$.embeddedpoint')= 'CHEZHUGUSHI_DANGYUEZHIXING_ONLOAD' then '4当月之星'
 end '分类',
count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-04-15 00:00:00'   -- 每天修改起始时间
and t.`date` <= '2022-07-04 23:59:59'		-- 每天修改截止时间
group by 1
order by 1

-- 车主故事数量和PV
select 
case when os.story_code ='work' then '1 职场笔记'
	 when os.story_code ='love' then '2 爱的记忆'
	 when os.story_code ='travel' then '3 旅途手帐'
	 when os.story_code ='sport' then '4 运动图鉴'
	 end '分类', 
count(case when tmi.IS_VEHICLE = 1 then os.id end) 车主帖子数量,
count(case when tmi.IS_VEHICLE = 0 then os.id end) 粉丝帖子数量,
sum(case when tmi.IS_VEHICLE = 1 then os.read_count end) 车主PV,
sum(case when tmi.IS_VEHICLE = 0 then os.read_count end) 粉丝PV
from volvo_online_activity.owner_story os 
left join `member`.tc_member_info tmi on os.member_id =tmi.id
WHERE 
os.create_date >='2022-4-15 00:00:00' and os.create_date <='2022-07-04 23:59:59'
and os.is_deleted =0
-- and os.check_status =1
group by 1
order by 1

-- 精选推荐 - 帖子总pv
select 
-- os.story_code,
tmi.IS_VEHICLE 是否车主,
sum(os.read_count) as PV
from volvo_online_activity.owner_story os 
left join `member`.tc_member_info tmi on os.member_id =tmi.id
WHERE 
os.create_date >='2022-4-15 00:00:00' and os.create_date <='2022-07-04 23:59:59'
and os.is_selected =1 -- 1为精选帖子
and os.is_deleted =0
and os.check_status =1
group by 1

-- 故事上传数和总PV
select 
-- os.story_code,
tmi.IS_VEHICLE 是否车主,
sum(os.read_count) as PV,
count(os.id)
from volvo_online_activity.owner_story os 
left join `member`.tc_member_info tmi on os.member_id =tmi.id
WHERE 
os.create_date >='2022-4-15 00:00:00' and os.create_date <='2022-07-04 23:59:59'
and os.is_deleted =0
group by 1

-- 车主故事发帖明细
select
os.id '帖子ID',
os.member_id '会员ID',
tmi.REAL_NAME  '姓名',
tmi.MEMBER_PHONE  '电话',
a.addr '地区',
tmi.VEHICLE_SYSTEM  '车系',
os.title '标题',
os.content '正文内容',
os.outside_article '站外链接',
ost.tag_name '标签',
case os.check_status when -1 then '审核失败'
when 0 then '审核中'
when 1 then '审核成功' end '审核状态',
case os.is_selected when 1 then '是' else '否' end '是否精选',
ifnull(osr.PV,0) '浏览数',
ifnull(osr.Support,0) '点赞数',
ifnull(osr.Shar,0) '转发数',
os.create_date '发布时间'
from volvo_online_activity.owner_story os 
left join `member`.tc_member_info tmi on os.member_id =tmi.id
-- left join `member`.tc_member_address tma on os.member_id =tma.MEMBER_ID 
left join 
(select tma.MEMBER_ID,GROUP_CONCAT(tr.REGION_NAME,tr2.REGION_NAME,tr3.REGION_NAME) as addr
    from `member`.tc_member_address tma 
    left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE 
    left join dictionary.tc_region tr2 on tma.ADDRESS_city = tr2.REGION_CODE 
    left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
    group by tma.MEMBER_ID) a on a.member_id = os.member_id 
left join 
(select story_id,GROUP_CONCAT(tag_name) as tag_name 
    from volvo_online_activity.owner_story_tag 
    group by story_id) ost on ost.story_id = os.id 
left join 
(select story_id,
    count(case `type` when 1 then member_id end) as PV,
    count(case `type` when 2 then member_id end) as Support,
    count(case `type` when 3 then member_id end) as Shar
    from volvo_online_activity.owner_story_record 
    group by 1) osr on os.id = osr.story_id
where os.is_deleted = 0
and os.create_date >='2022-4-15 00:00:00' and os.create_date <='2022-07-04 23:59:59'
order by os.create_date desc;