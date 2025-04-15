-- 
1、 沃世界活跃度：（点赞、留言、评论）

2、 沃世界重大活动的站内参与情况：签到、会员日、3周年、商城618（是否、浏览）、推荐购（是否）

3、 沃世界最近登录时间：（日期）

4、 沃尔沃App的下载注册情况：（是否）

-- 用户点赞数量	
select 
tmi.MEMBER_PHONE,
a.'点赞量',
b.'留言评论数量',
c.'签到活动是否参与',
c.'会员日是否参与',
c.'3周年是否参与',
c.'商城618是否参与',
c.'推荐购是否参与',
d.'最新登入时间',
e.CUST_ID
from `member`.tc_member_info tmi 
left join 
(
select 
m.member_phone,
sum(case when o.type='SUPPORT' then 1 else 0 end) '点赞量'
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
			select mm.id,mm.user_id,mm.is_vehicle,m.member_phone
			from (
			select m.user_id,max(m.id) mid,m.member_phone
			from member.tc_member_info m 
			where m.is_deleted=0 and m.member_status<>60341003
			GROUP BY 1  ) m
			LEFT JOIN member.tc_member_info mm on mm.id=m.mid
	)m on m.user_id=o.user_id
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	and date_create >='2022-01-01'
	and date_create <'2022-09-20'
group by 1)a on a.member_phone=tmi.MEMBER_PHONE 
left join 
(
-- 活动评论数据
select
tmi.MEMBER_PHONE,
count(teh.id) 留言评论数量
from comment.tt_evaluation_history teh
left join comment.tc_evaluation_picture tep on tep.evaluation_id = teh.id 
left join `member`.tc_member_info tmi on teh.mobile = tmi.MEMBER_PHONE 
where  teh.create_time >= '2022-01-01'
and teh.create_time < '2022-09-20'
group by 1)b on b.member_phone=tmi.MEMBER_PHONE 
left join 
-- 沃世界重大活动的站内参与情况
(select tmi.MEMBER_PHONE,
if(a.活跃>=1,'是','否')签到活动是否参与,
if(b.活跃>=1,'是','否')会员日是否参与,
if(c.活跃>=1,'是','否')3周年是否参与,
if(d.活跃>=1,'是','否')商城618是否参与,
if(e.活跃>=1,'是','否')推荐购是否参与
from `member`.tc_member_info tmi 
left join 
	(select tmi.MEMBER_PHONE,count(t.usertag) 活跃
	from track.track t 
	left join `member`.tc_member_info tmi on cast(tmi.USER_ID as VARBINARY )=t.usertag 
	where json_extract(t.data,'$.embeddedpoint')='QIANDAO_SHOUYE_ONLOAD' 
	and t.date>='2022-01-01'
	group by 1)a on a.MEMBER_PHONE=tmi.MEMBER_PHONE
left join 
	(select tmi.MEMBER_PHONE,count(t.usertag) 活跃
	from track.track t 
	left join `member`.tc_member_info tmi on cast(tmi.USER_ID as VARBINARY )=t.usertag 
	where json_extract(t.data,'$.embeddedpoint') in 
	('三周年_进行页_ONLOAD', '三周年_预热页_ONLOAD','三周年_发酵页_ONLOAD')
	and t.date>='2022-01-01'
	group by 1)b on b.MEMBER_PHONE=tmi.MEMBER_PHONE
left join 
	(select tmi.MEMBER_PHONE,count(t.usertag) 活跃
	from track.track t 
	left join `member`.tc_member_info tmi on cast(tmi.USER_ID as VARBINARY )=t.usertag 
	where json_extract(t.data,'$.embeddedpoint') in 
	('memberDay8_home_onload','memberDay7_home_onload',
	'memberDay6_home_onload','memberDay5_home_onload',
	'memberDay4_home_onload','memberDay3_home_onload',
	'memberDay2_home_onload','memberDay_home_onload')
	and t.date>='2022-01-01'
	group by 1)c on c.MEMBER_PHONE=tmi.MEMBER_PHONE
left join 
	(select tmi.MEMBER_PHONE,count(t.usertag) 活跃
	from track.track t 
	left join `member`.tc_member_info tmi on cast(tmi.USER_ID as VARBINARY )=t.usertag 
	where json_extract(t.data,'$.embeddedpoint')='618商城首页_onload'
	and t.date>='2022-01-01'
	group by 1)d on d.MEMBER_PHONE=tmi.MEMBER_PHONE
left join 
	(select tmi.MEMBER_PHONE,count(t.usertag) 活跃
	from track.track t 
	left join `member`.tc_member_info tmi on cast(tmi.USER_ID as VARBINARY )=t.usertag 
	where t.typeid in('XWSJXCX_OLD_NEW_ONLOAD_C','XWSJXCX_OLD_NEW_LZONLOAD_C','XWSJXCX_TJG_FCZ_V')
	and t.date>='2022-01-01'
	group by 1)e on e.MEMBER_PHONE=tmi.MEMBER_PHONE
group by 1
)c on c.member_phone=tmi.MEMBER_PHONE 
left join 
(
-- 用户最新登入时间
select
DISTINCT tmi.MEMBER_PHONE,
a.max_date 最新登入时间
from `member`.tc_member_info tmi 
join 
(select t.usertag,max(t.`date`) max_date
	from track.track t
	group by 1) a on a.usertag = cast(tmi.USER_ID as varchar) 
group by 1
order by 2 desc
)d on d.member_phone=tmi.MEMBER_PHONE 
left join 
(
-- 沃尔沃App的下载注册情况：（是否）
select tmi.MEMBER_PHONE,tmi.CUST_ID
from `member`.tc_member_info tmi 
group by 1
)e on e.member_phone=tmi.MEMBER_PHONE 
where tmi.member_phone in ('18616603771',
'13909261740',
'13305516187',
'13901818079',
'13757552020',
'13806176228',
'13394731717',-- 2
'13009591626',--
'13655001117',
'13705478419',
'18033419990',
'18621322503',
'15560632222',
'13889188368',
'13708575666',
'18660036322',
'15105138700',
'18940183555',
'13914222598',
'13901779682',
'13840036883',
'13292569425',
'18116196657',
'19121613221',-- 2
'13761737426',--
'13850070916',
'13817247847',
'18909690615',
'13862246473',
'13885161593',
'18085033768',
'13925200251',
'15696630738',
'13556784645',
'15312601518',
'18842065588',
'15840530736',
'18980240593',
'13560415908',
'13350094040',
'17737096662',
'13778102000',
'13816043265',
'13899866320',
'13975109528',
'13225601508',
'18362544330',
'13853780327',
'18327575757',
'13321128358',
'13918757666',
'13003458597',
'13542574882',
'15622192016',
'13821105339',
'13945694697',
'13871546364',
'15088584655',
'15692150681',
'13519121918',
'18627128919',
'18953343666',
'15189196888',
'13360000051',
'13311829288',
'18505516107',
'13817093409',
'13922767899',
'18056571086'
)