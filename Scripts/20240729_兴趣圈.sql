--兴趣圈活动数据
	select 
--	o.coterie_id ,
	ca.content `兴趣圈名称`,
	o.join_count `兴趣圈总人数`,
	c.campaign_name`活动名称`,
	c.campaign_start_time`活动开始日期`,
	c.sign_count`活动报名人数`,
	ifnull(x2.num,0) `活动签到人数`
	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id  
	left join ods_camp.ods_camp_tm_campaign_d c on c.club_id=o.coterie_id
	left join  
		(
	--	活动签到报名人数  
		select campaign_code,
		count(distinct oc.member_id)num 
		from ods_camp.ods_camp_tr_campaign_sign_up_d oc 
		where oc.is_deleted=0
		and sign_up_status=2 -- 签到报名人数
		and oc.create_time>='2024-09-01'
		and oc.create_time<'2024-10-01'
		group by 1
		order by 1
		)x2 on x2.campaign_code=c.campaign_code
	where 1=1
	and c.campaign_start_time>='2024-09-01'
	and c.campaign_start_time<'2024-10-01'
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	and c.is_deleted=0 
	order by 2 desc 

--兴趣圈用户内容数据
	select 
--	o.coterie_id ,
	ca.content `兴趣圈名称`,
	o.join_count `兴趣圈总人数`,
	p.member_id `发布者ID`,
	p.post_id `内容ID`,
	p.post_title `内容标题`,
	pm.`发帖内容`,
	pm.`发帖字数`,
	pm.`发帖图片链接`,
	pm.`发帖图片数量`,
	oct.topic_name ,
	p.create_time `发布时间`
	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
	left join ods_cmnt.ods_cmnt_tm_post_cur p on toString(p.club_id)=toString(o.coterie_id)
	left join ods_cmnt.ods_cmnt_tr_topic_post_link_cur oc on p.post_id =oc.post_id and oc.is_deleted = 0 
	left join ods_cmnt.ods_cmnt_tm_topic_d oct on oc.topic_id =oct.topic_id 
	left join
		(-- 发帖内容、图片
			select
				t.post_id,
				REPLACE(replaceRegexpAll(replaceRegexpAll(arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'text' THEN t.`内容` ELSE NULL END), ';'), '<.*?>', ''),'#(.*?)#', ''),' ','') `发帖内容`,
				lengthUTF8(REPLACE(replaceRegexpAll(replaceRegexpAll(arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'text' THEN t.`内容` ELSE NULL END), ';'), '<.*?>', ''),'#(.*?)#', ''),' ','')) `发帖字数`,
				arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'image' THEN t.`内容` ELSE NULL END), ';') AS `发帖图片链接`,
				count(case when t.`类型`='image' then t.`内容` else null end) as `发帖图片数量`
			from(
				select 
					tpm.post_id
					,tpm.create_time
					,visitParamExtractString(tpm.node_content, 'nodeType') `类型`
					,visitParamExtractString(tpm.node_content, 'nodeContent') `内容`
				from (
				select
					tpm.post_id
					,tpm.create_time
					,arrayJoin(splitByString('},{',cast(tpm.node_content as String)) ) as node_content
				from ods_cmnt.ods_cmnt_tt_post_material_cur tpm
				where 1=1
--				and tpm.create_time between '2024-07-19 15:00:00' and '2024-07-28 23:59:59'
				and tpm.is_deleted = 0) tpm 
			) as t
			group by t.post_id
		) pm on p.post_id = pm.post_id
	where 1=1
	and p.create_time>='2024-10-29'
	and p.create_time<'2024-11-05'
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	and p.is_deleted =0 
	and oc.topic_id ='TJw1ii3nGw'
	order by 2 desc 

	
	
	--兴趣圈用户内容数据
	select 
--	o.coterie_id ,
	ca.content `兴趣圈名称`,
	o.join_count `兴趣圈总人数`,
	p.post_id `内容ID`,
	p.post_title `内容标题`,
	pm.`发帖内容`,
	pm.`发帖图片链接`,
	pm.`发帖图片数量`,
	p.create_time `发布时间`
	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
	left join ods_cmnt.ods_cmnt_tm_post_cur p on toString(p.club_id)=toString(o.coterie_id)
	left join
		(-- 发帖内容、图片
			select
				t.post_id,
				REPLACE(replaceRegexpAll(replaceRegexpAll(arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'text' THEN t.`内容` ELSE NULL END), ';'), '<.*?>', ''),'#(.*?)#', ''),' ','') `发帖内容`,
				lengthUTF8(REPLACE(replaceRegexpAll(replaceRegexpAll(arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'text' THEN t.`内容` ELSE NULL END), ';'), '<.*?>', ''),'#(.*?)#', ''),' ','')) `发帖字数`,
				arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'image' THEN t.`内容` ELSE NULL END), ';') AS `发帖图片链接`,
				count(case when t.`类型`='image' then t.`内容` else null end) as `发帖图片数量`
			from(
				select 
					tpm.post_id
					,tpm.create_time
					,visitParamExtractString(tpm.node_content, 'nodeType') `类型`
					,visitParamExtractString(tpm.node_content, 'nodeContent') `内容`
				from (
				select
					tpm.post_id
					,tpm.create_time
					,arrayJoin(splitByString('},{',cast(tpm.node_content as String)) ) as node_content
				from ods_cmnt.ods_cmnt_tt_post_material_cur tpm
				where 1=1
--				and tpm.create_time between '2024-07-19 15:00:00' and '2024-07-28 23:59:59'
				and tpm.is_deleted = 0) tpm 
			) as t
			group by t.post_id
		) pm on p.post_id = pm.post_id
	where 1=1
	and p.create_time>='2024-09-01'
	and p.create_time<'2024-10-01'
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	order by 2 desc 
	
--兴趣圈用户内容数据
	select 
--	o.coterie_id ,
	ca.content `兴趣圈名称`,
	o.join_count `兴趣圈总人数`,
	count(distinct p.member_id) `兴趣圈发帖人数`
	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
	left join ods_cmnt.ods_cmnt_tm_post_cur p on toString(p.club_id)=toString(o.coterie_id)
	where 1=1
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	and p.create_time>='2024-09-01'
	and p.create_time<'2024-10-01'
	group by 1,2
	order by 2 desc 

--兴趣圈拉新数据
	select 
--	o.coterie_id ,
	ca.content `兴趣圈名称`,
	o.applicant_name `兴趣圈圈主名称`,
	o.member_id `圈主ID`,
--	o.join_count `兴趣圈总人数`,
	x2.`上月初兴趣圈总人数`,
	x2. `上月底兴趣圈总人数`, 
	x.num `新进圈用户数`,
	x.cznum `新进圈车主数`
	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
	left join 
		(
		select 
		a.coterie_id,
		count(distinct a.member_id) num ,
		count(distinct case when m.is_vehicle=1 then  a.member_id else null end) cznum 
		from ods_cocl.ods_cocl_tr_coterie_friends_d a 
		left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id::String=m.id::String
		where 1=1
		and a.create_time>='2024-12-01'
		and a.create_time<'2025-01-01'
		and a.audit_status=1
		group by 1 
		order by 1 
		)x on x.coterie_id = o.coterie_id
	left join 
		(
		select 
		a.coterie_id,
		count(distinct case when a.create_time<='2024-12-01' then a.member_id else null end) `上月初兴趣圈总人数`,
		count(distinct case when a.create_time<'2025-01-01' then  a.member_id else null end)  `上月底兴趣圈总人数`
		from ods_cocl.ods_cocl_tr_coterie_friends_d a 
		left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id::String=m.id::String
		where 1=1
		and a.audit_status=1
		group by 1 
		order by 1 
		)x2 on x2.coterie_id = o.coterie_id
	where 1=1
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	order by 2 desc 
		

select a.*,
if(x4.ft_num>0,'是','否') `12月是否在兴趣圈内发帖过`,
if(x3.pl_num>0,'是','否') `12月是否在兴趣圈内评论过`,
if(x2.dz_num>0,'是','否') `12月是否在兴趣圈内点赞过`
from 
	(
	select 
	distinct 
	a.member_id member_id,
	m.member_name,
--	a.coterie_id,
	ca.content `兴趣圈名称`
	from ods_cocl.ods_cocl_tr_coterie_friends_d a 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on a.coterie_id =ca.coterie_id and ca.attr_type = 10010 and ca.is_deleted =0 
	left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id::String=m.id::String
	where 1=1
--	and a.create_time>='2024-01-01'
	and a.create_time<'2025-01-01'
	and a.audit_status=1
	order by 1 
)a
left join (
	-- 兴趣圈 0点赞
	select
	a.member_id member_id,
	count(1) dz_num
	from ods_cmnt.ods_cmnt_tt_like_post_cur a
	join ods_cmnt.ods_cmnt_tm_post_cur a1 on a1.post_id=a.post_id
	join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on toString(a1.club_id)=toString(ca.coterie_id)
	where a.is_deleted <>1
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and ca.is_deleted =0 
	and a.create_time >='2024-12-01'
	and a.create_time <'2025-01-01'
	and a.like_type=0
	group by 1 
	order by 1 
	)x2 on x2.member_id::String =a.member_id::String
left join (
-- 兴趣圈评论
	select a.member_id member_id,
	count(1) pl_num
	from ods_cmnt.ods_cmnt_tm_comment_cur a
	join ods_cmnt.ods_cmnt_tm_post_cur a1 on a1.post_id=a.post_id
	join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on toString(a1.club_id)=toString(ca.coterie_id)
	where a.is_deleted <>1
	and a.create_time >='2024-12-01'
	and a.create_time <'2025-01-01'
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and ca.is_deleted =0 
	group by 1
	)x3 on x3.member_id::String =a.member_id::String
left join (
-- 兴趣圈发帖 
	select 
 	a.member_id::String member_id,
 	count(1) ft_num
	from ods_cmnt.ods_cmnt_tm_post_cur a
	join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on toString(a.club_id)=toString(ca.coterie_id)
	where a.is_deleted =0
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and ca.is_deleted =0 
	and a.create_time >='2024-12-01'
	and a.create_time <'2025-01-01'
	and a.member_id is not null
	group by 1 
	order by 1 
	)x4 on x4.member_id::String =a.member_id::String

		
select 
count(a.member_id)
from ods_cocl.ods_cocl_tr_coterie_friends_d a 
where 1=1
and a.create_time>='2024-01-01'
and a.create_time<'2025-01-01'	
and a.audit_status=1
	
-----------------------------------------------------------------------------
	
	
-- 发帖明细
select 
distinct 
a.member_id 会员ID,
a.post_id 文章ID,
tmi.REAL_NAME 用户姓名,
tmi.MEMBER_NAME 用户昵称,
case when tmi.IS_VEHICLE = '1' then '车主' when tmi.IS_VEHICLE = '0' then '粉丝' end 用户类型,
case when tmi.member_level = 1 then '银卡'
     when tmi.member_level = 2 then '金卡'
     when tmi.member_level = 3 then '白金卡' 
     when tmi.member_level = 4 or   tmi.member_level = 5 then '黑卡' end 会员等级,
tmi.MEMBER_PHONE 沃世界注册手机号码,
a.create_time 发帖时间,
l.topic_id 话题id,
replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ','')  "发帖内容",
char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))  "发帖字数",
pm.发帖图片数量,
a.like_count 动态点赞数,
pm.发帖图片链接  发帖图片链接
--a.post_type "帖子类型(动态1001/文章1002/活动1006/UGC文章1007)",
--a.post_state "帖子状态:1上架,2下架,4审核中,5审核不通过"
--tisd.invoice_date 最后购车开票时间
--datediff(a.create_time,tisd.invoice_date)
from community.tm_post a
left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join
(
		-- 发帖内容、图片
	select
	t.post_id,
	replace(string_agg(case when t.类型='text' then t.内容 else null end ,';'),' ','') as 发帖内容,
	string_agg(case when t.类型='image' then t.内容 else null end ,';') as 发帖图片链接,
	count(case when t.类型='image' then t.内容 else null end) as 发帖图片数量
	from
	(
		select
		tpm.post_id,
		tpm.create_time,
		replace(tpm.node_content,E'\\u0000','') 发帖内容,
		json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeType' 类型,
		json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeContent' 内容
		from community.tt_post_material tpm
		where 1=1
--		and tpm.create_time >= '2023-11-06' and tpm.create_time < '2023-11-13'
		and tpm.is_deleted = 0
	) as t
	group by t.post_id
) pm on a.post_id = pm.post_id
left join(
		select a.member_id
		,a.vin_code
		,a.bind_date
		,b.model_name 拥车车型
		,row_number()over(partition by a.member_id order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
		)x on x.member_id=a.member_id and x.rk=1
left join vehicle.tt_invoice_statistics_dms tisd on x.vin_code=tisd.vin   -- 与发票表关联
where a.is_deleted =0
and a.create_time >='2024-04-02'
and a.create_time <'2024-05-07'
and l.topic_id ='Iispdyk4vi' 
--and tmi.IS_VEHICLE = '1'-- 车主
and char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))>=300 --帖子字数不少于300字
and pm.发帖图片数量>=6 -- 配图不少于6张的文章及动态
--and datediff(a.create_time,tisd.invoice_date)<=365 -- 最后开票时间距发帖时间在一年以内
--and a.member_id ='6873815'
order by a.create_time
	
	
-- 兴趣圈发现圈子页面浏览
select date(client_time) ,count(distinct b.usr_merged_gio_id,client_time) pv,count(distinct b.usr_merged_gio_id) uv
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on a.gio_id=b.gio_id
where 1=1 
and event_time >= '2024-07-22'
and date(client_time) between '2024-07-22' and '2024-07-28'
and length(user)<9
and event_key='$page'
and $path in ('/ActivityPageView' ,'/Volvo_Cars.DiscoverCircleViewController')
group by 1

select count(distinct b.usr_merged_gio_id,client_time) pv,count(distinct b.usr_merged_gio_id) uv
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on a.gio_id=b.gio_id
where 1=1 
and event_time >= '2024-07-22'
and date(client_time) between '2024-07-22' and  '2024-07-28'
and length(user)<9
and event_key='$page'
and $path in ('/ActivityPageView' ,'/Volvo_Cars.DiscoverCircleViewController')


-- 兴趣圈详情页面浏览
select date(client_time) ,count(distinct b.usr_merged_gio_id,client_time) pv,count(distinct b.usr_merged_gio_id) uv
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on a.gio_id=b.gio_id
where 1=1 
and event_time >=  '2024-07-22'
and date(client_time) between  '2024-07-22' and  '2024-07-28'
and length(user)<9
and event_key='$page'
and $path like '%mweb/circle/detail%'
group by 1


select count(distinct b.usr_merged_gio_id,client_time) pv,count(distinct b.usr_merged_gio_id) uv
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on a.gio_id=b.gio_id
where 1=1 
and event_time >= '2024-07-22'
and date(client_time) between '2024-07-22' and  '2024-07-28'
and length(user)<9
and event_key='$page'
and $path like '%mweb/circle/detail%'



-- 发帖
select date(create_time) ,count(distinct member_id) `发帖人数` ,count(1) `发帖数`
from ods_cmnt.ods_cmnt_tm_post_cur p
join
(--圈子名称表
	select distinct coterie_id 
	from ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d
	where attr_type = 10010 
	and is_deleted =0
)q on p.club_id = q.coterie_id
where date(create_time) between '2024-07-22' and  '2024-07-28'
group by 1




-- 兴趣圈圈友数据
select 
m.create_time,
a.member_id,
--a.coterie_id,
m.member_name ,
m.level_id,
m.is_vehicle,
--x.ip,
x2.mt`最近一次点赞时间`,
x3.mt`最近一次评论时间`,
x4.mt`最近一次发帖时间`,
x5.ft
from ods_cocl.ods_cocl_tr_coterie_friends_d a 
left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id::String=m.id::String
--left join (
--		-- 最近一次登录的IP地址
--		select a.memberid,
--		a.ip,
--		a.time 
--		from (
--		-- 取出用户最近一次登录时间
--			select 
--			a.memberid,
--			a.$ip ip,
--			time,
--			ROW_NUMBER()over(PARTITION by a.memberid order by time desc)rk
--			from dwd_23.dwd_23_gio_tracking a
--			join ods_cocl.ods_cocl_tr_coterie_friends_d b on a.memberid =b.member_id
--			where 1=1
--			and event_time >='2024-10-09' 
--			and `date` >='2024-10-09' 
--			and `date` <'2025-01-01' 
--			and event='$AppStart'
--			and coterie_id ='COTERIE_jcADP6mpT5' --动漫达人圈
--			and audit_status=1 -- 审核通过
--		)a where a.rk=1
--	)x on a.member_id::String =x.memberid::String
left join (
	-- 0点赞
	select
	a.member_id,
	max(a.create_time) mt
	from ods_cmnt.ods_cmnt_tt_like_post_cur a
	where a.is_deleted <>1
	and a.create_time >='2023-09-25'
--	and a.create_time <'2024-09-01'
	and a.like_type=0
	group by 1 
	order by 1 
	)x2 on x2.member_id::String =a.member_id::String
left join (-- 评论
	select a.member_id,
	max(a.create_time) mt
	from ods_cmnt.ods_cmnt_tm_comment_cur a
	where a.is_deleted <>1
	and a.create_time >='2023-09-25'
--	and a.create_time <'2023-10-31'
	group by 1
	)x3 on x3.member_id::String =a.member_id::String
left join (
-- 发帖 
	select 
 	a.member_id::String member_id,
 	max(a.create_time) mt
	from ods_cmnt.ods_cmnt_tm_post_cur a
	where a.is_deleted =0
	and a.create_time>='2023-09-25'
--	and a.create_time<'2024-04-01'
	and a.member_id is not null
	group by 1 
	order by 1 
	)x4 on x4.member_id::String =a.member_id::String
left join (
-- 发帖 
	select 
 	a.member_id,
 	count(a.post_id) ft
	from ods_cmnt.ods_cmnt_tm_post_cur a
	where a.is_deleted =0
	and a.create_time>='2024-06-01'
--	and a.create_time<'2025-01-01'
	and a.member_id is not null
	group by 1 
	order by 1 
	)x5 on x5.member_id::String =a.member_id::String
where 1=1
and a.create_time>='2024-12-01'
and a.create_time<today()
and a.is_deleted=0
and a.coterie_id ='COTERIE_jcADP6mpT5' --动漫达人圈
and a.audit_status=1 -- 审核通过
order by 1 
--settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0

		


		-- 最近一次登录的IP地址
		select a.memberid,
		a.ip,
		a.time 
		from (
		-- 取出用户最近一次登录时间
			select 
			a.memberid,
			a.$ip ip,
			time,
			ROW_NUMBER()over(PARTITION by a.memberid order by time desc)rk
			from dwd_23.dwd_23_gio_tracking a
			join ods_cocl.ods_cocl_tr_coterie_friends_d b on a.memberid =b.member_id
			where 1=1
			and event_time >='2024-10-09' 
			and `date` >='2024-10-09' 
			and `date` <'2025-01-01' 
			and event='$AppStart'
			and coterie_id ='COTERIE_jcADP6mpT5' --动漫达人圈
			and audit_status=1 -- 审核通过
			and a.memberid='7695635'
		)a where a.rk=1

