select m.id,
case when m.is_vehicle =1 then '车主' else '粉丝' end `用户属性（车主/粉丝)`,
x.`拥车车型`,
m.level_id `会员等级`,
case when x3.member_id is not null then '是' else '否' end `益起学急救活动是否参与`,
case when x4.member_id<>0 then '是' else '否' end `益起学急救活动是否获得电子证书`,
x2.num `活动报名数`
from ods_memb.ods_memb_tc_member_info_cur m
left join (	
	select a.*
		from 
		(
		select 
		m.id id
		,a.vin_code
		,a.series_code
		,a.bind_date
		,b.model_name `拥车车型`
		,m.cust_id 
		,row_number()over(partition by a.member_id order by a.bind_date) rk 
		from ods_vocm.ods_vocm_vehicle_bind_relation_cur a
		left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id=cast(m.id as varchar)
		left join ods_bada.ods_bada_tm_model_cur b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
--		and m.id ='3063707'
		Settings allow_experimental_window_functions = 1
		)a 
	where a.rk=1
	)x on x.id=m.id
left join 
	(
	--	活动签到报名人数  
		select oc.member_id,
		count(1) num 
		from ods_camp.ods_camp_tr_campaign_sign_up_d oc 
		where oc.is_deleted=0
		and sign_up_status=2 -- 签到报名人数
--		and oc.create_time>='2024-08-01'
		and oc.create_time<date(now())
		group by 1 
		order by 2 desc 
		)x2 on x2.member_id::String=m.id::String
left join (	
	-- 帖子的PVUV
	select DISTINCT a.member_id member_id
	from ods_cmnt.ods_cmnt_tt_view_post_cur a
	where 1=1
--	and a.create_time >='2023-09-21'
--	and a.create_time <'2023-10-31'
	and a.is_deleted =0
	and post_id='liMlz5xwOa'
)x3 on x3.member_id::String=m.id::String
left join (	
	-- 益起学急救活动是否获得电子证书
	select a.member_id member_id
	from ods_dmoa.ods_dmoa_tr_certificate_record_d a
	where 1=1
--	and a.create_time >='2023-09-21'
--	and a.create_time <'2023-10-31'
	and a.is_deleted =0
	and a.activity_code='aedvideo-2024'
)x4 on x4.member_id::String=m.id::String
where m.is_deleted =0
--and m.id in ()


-- 每日任务 累计获得人数 成功捐步累计≥9天
select distinct 
a.num `累计成功捐步天数`,
a.member_id,
m.real_name,
m.member_name,
case when m.member_sex = '10021001' then '先生'
	when m.member_sex = '10021002' then '女士'
	else '未知' end `性别`,
m.member_phone,
--`是否获得”益起学急救“电子证书`,
x.`发布时间`,
x.`发帖字数`,
x.`发帖图片数量`,
x.`动态点赞数`,
x.`发帖内容`,
x.`发帖话题（该内容下所有引用tag）`,
x.`发帖图片链接`
from 
	(
--	2024年10月10日-10月20日期间曾经参与“益起走”活动且累计成功捐步≥6天
	select 
	 x.member_id member_id,max(x.rk) num 
	from 
			(
			-- 每位用户每个任务累计完成任务次数
			select 
			a.date as "date",
			a.member_id,
			b.is_vehicle,
			row_number() over(partition by a.member_id order by a.date ) rk
			FROM 
				( select lc.member_id,lc.lovestep_id,toDate( lc.create_time ) date,lc.is_deleted ,lc.create_time,lc.step_type,lc.love_num,
				    row_number() over(partition by lc.member_id,toDate( lc.create_time ) order by toDate( lc.create_time ) desc, lc.member_id desc) rk
				from ods_dmoa.ods_dmoa_tm_lovestep_log_d lc 
				where lc.is_deleted = 0
				and lc.create_time >='2024-10-10' 
				and lc.create_time <'2024-10-21' 
				and lc.step_type = 2 --捐赠过并捐赠成功
			)a 
		left join ods_memb.ods_memb_tc_member_info_cur b 
		on a.member_id =b.id 
		where 1=1
		and b.is_deleted =0
		and b.member_status <> '60341003'
		and a.rk=1
			)x
	where 1=1
--	and x.rk>=6
	group by 1 
)a
join 
(--兴趣圈用户内容数据
	select 
	distinct 
	p.create_time `发布时间`,
	pm.`发帖字数` `发帖字数`,
	pm.`发帖图片数量` `发帖图片数量`,
	p.like_count `动态点赞数`,
	pm.`发帖内容` `发帖内容`,
	l2.topic `发帖话题（该内容下所有引用tag）`,
	pm.`发帖图片链接` `发帖图片链接`,
	p.member_id `发布者ID`
--	p.post_id `内容ID`,
--	p.post_title `内容标题`,
	from ods_cmnt.ods_cmnt_tm_post_cur p 
	left join ods_cmnt.ods_cmnt_tr_topic_post_link_cur l on p.post_id = l.post_id
	left join 
		(select post_id,arrayStringConcat(arrayCompact(groupArray(l.topic_id)), ',') topic
		from ods_cmnt.ods_cmnt_tm_post_cur p 
		left join ods_cmnt.ods_cmnt_tr_topic_post_link_cur l on p.post_id = l.post_id
		where 1=1
		and l.topic_id in ('ItqesqL6hY','KEe2ppZMxt')
		group by 1 
		)l2 on p.post_id = l2.post_id
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
	and p.create_time>='2024-10-10'
	and p.create_time<'2024-10-21'
	and l.topic_id in ('ItqesqL6hY','KEe2ppZMxt')
--	and l2.topic in ('KEe2ppZMxt,ItqesqL6hY','ItqesqL6hY,KEe2ppZMxt')
	and pm.`发帖字数`>=15
	and pm.`发帖图片数量`>=1
	order by 2 desc 
	)x on x.`发布者ID`=a.member_id
left join ods_memb.ods_memb_tc_member_info_cur m on m.id=a.member_id
where m.is_vehicle =1



-- 益起学急救活动是否获得电子证书
select a.member_id member_id,
m.real_name,
m.member_name,
case when m.member_sex = '10021001' then '先生'
	when m.member_sex = '10021002' then '女士'
	else '未知' end `性别`,
m.member_phone
from ods_dmoa.ods_dmoa_tr_certificate_record_d a
left join ods_memb.ods_memb_tc_member_info_cur m on m.id=a.member_id
where 1=1
and a.create_time >='2024-10-10'
and a.create_time <'2024-10-21'
and a.is_deleted =0
and a.activity_code='aedvideo-2024'
and m.is_vehicle =1





-- 每日任务 累计获得人数 成功捐步累计≥16天  9.14-9.29 全勤打卡用户数
select 
count(distinct x.member_id) "总人数",
COUNT(distinct case when x.is_vehicle = '1' then x.member_id else null end) "车主",
COUNT(distinct case when x.is_vehicle = '0' then x.member_id else null end) "粉丝"
from 
	(
	-- 每位用户每个任务累计完成任务次数
	select 
	a.date as "date",
	a.member_id,
	b.is_vehicle,
	row_number() over(partition by a.member_id order by a.date ) rk
	FROM 
( select lc.member_id,lc.lovestep_id,toDate( lc.create_time ) date,lc.is_deleted ,lc.create_time,lc.step_type,lc.love_num,
    row_number() over(partition by lc.member_id,toDate( lc.create_time ) order by toDate( lc.create_time ) desc, lc.member_id desc) rk
from ods_dmoa.ods_dmoa_tm_lovestep_log_d lc 
where lc.is_deleted = 0
and lc.create_time >='2024-09-14' 
and lc.create_time <'2024-09-30' 
and lc.step_type = 2 --捐赠过并捐赠成功
)a 
left join ods_memb.ods_memb_tc_member_info_cur b 
on a.member_id =b.id 
where 1=1
and b.is_deleted =0
and b.member_status <> '60341003'
and a.rk=1
	)x
where 1=1
and x.rk>=16




-- 话题发帖量
select 
l.topic_id,
count(a.id) `发帖量`,
count(distinct a.member_id) `参与人数`,
COUNT(distinct case when tmi.is_vehicle = '1' then a.member_id else null end) "车主UV",
COUNT(distinct case when tmi.is_vehicle = '0' then a.member_id else null end) "粉丝UV"
from ods_cmnt.ods_cmnt_tr_topic_post_link_cur l  
left join ods_cmnt.ods_cmnt_tm_post_cur a on a.post_id = l.post_id and l.is_deleted = 0 
left join ods_memb.ods_memb_tc_member_info_cur  tmi on a.member_id  =tmi.id and tmi.is_deleted =0 and  tmi.member_status <> '60341003' 
where 1=1
and a.create_time >= '2024-09-14' 
and a.create_time < '2024-09-30' 
and a.is_deleted =0
and l.topic_id ='FnQ7uGkUQw'
group by l.topic_id
order by l.topic_id desc
--FnQ7uGkUQw	506	313	259	54



--9.14-9.29 全勤打卡用户数  9.14-9.29 带话题#益起打卡，助力AED救援行动#用户数

select
count(bb.id) `发帖量`,
count(distinct aa.member_id) "总人数",
COUNT(distinct case when aa.is_vehicle = '1' then aa.member_id else null end) "车主",
COUNT(distinct case when aa.is_vehicle = '0' then aa.member_id else null end) "粉丝"
from 
(
-- 每日任务 累计获得人数 成功捐步累计≥16天 9.14-9.29 全勤打卡用户数
select 
x.member_id `member_id`,
x.is_vehicle `is_vehicle` 
from 
	(
	-- 每位用户每个任务累计完成任务次数
	select 
	a.date as "date",
	a.member_id,
	b.is_vehicle,
	row_number() over(partition by a.member_id order by a.date ) rk
	FROM 
( select lc.member_id,lc.lovestep_id,toDate( lc.create_time ) date,lc.is_deleted ,lc.create_time,lc.step_type,lc.love_num,
    row_number() over(partition by lc.member_id,toDate( lc.create_time ) order by toDate( lc.create_time ) desc, lc.member_id desc) rk
from ods_dmoa.ods_dmoa_tm_lovestep_log_d lc 
where lc.is_deleted = 0
and lc.create_time >='2024-09-14' 
and lc.create_time <'2024-09-30' 
and lc.step_type = 2 --捐赠过并捐赠成功
)a 
left join ods_memb.ods_memb_tc_member_info_cur b 
on a.member_id =b.id 
where 1=1
and b.is_deleted =0
and b.member_status <> '60341003'
and a.rk=1
	)x
where 1=1
and x.rk>=16
)aa
inner join 
(
-- 话题发帖量
select 
a.id `id`,a.member_id `member_id`
from ods_cmnt.ods_cmnt_tr_topic_post_link_cur l  
left join ods_cmnt.ods_cmnt_tm_post_cur a on a.post_id = l.post_id and l.is_deleted = 0 
left join ods_memb.ods_memb_tc_member_info_cur  tmi on a.member_id  =tmi.id and tmi.is_deleted =0 and  tmi.member_status <> '60341003' 
where 1=1
and a.create_time >= '2024-09-14' 
and a.create_time < '2024-09-30' 
and a.is_deleted =0
and l.topic_id ='FnQ7uGkUQw'
--group by l.topic_id
--order by l.topic_id desc
)bb on aa.`member_id`=bb.`member_id`
--233	139	106	33

select
bb.*
from 
(
-- 每日任务 累计获得人数 成功捐步累计≥16天 9.14-9.29 全勤打卡用户数
select 
x.member_id `member_id`,
x.is_vehicle `is_vehicle` 
from 
	(
	-- 每位用户每个任务累计完成任务次数
	select 
	a.date as "date",
	a.member_id,
	b.is_vehicle,
	row_number() over(partition by a.member_id order by a.date ) rk
	FROM 
( select lc.member_id,lc.lovestep_id,toDate( lc.create_time ) date,lc.is_deleted ,lc.create_time,lc.step_type,lc.love_num,
    row_number() over(partition by lc.member_id,toDate( lc.create_time ) order by toDate( lc.create_time ) desc, lc.member_id desc) rk
from ods_dmoa.ods_dmoa_tm_lovestep_log_d lc 
where lc.is_deleted = 0
and lc.create_time >='2024-09-14' 
and lc.create_time <'2024-09-30' 
and lc.step_type = 2 --捐赠过并捐赠成功
)a 
left join ods_memb.ods_memb_tc_member_info_cur b 
on a.member_id =b.id 
where 1=1
and b.is_deleted =0
and b.member_status <> '60341003'
and a.rk=1
	)x
where 1=1
and x.rk>=16
)aa
inner join 
(
select
p.member_id `会员ID`,
p.post_id `内容ID`,
case when m.is_vehicle = 1 then '车主'when m.is_vehicle = 0 then '粉丝'else null end `会员身份`,
m.real_name `姓名`,
m.member_name `用户昵称`,
case when m.member_sex = '10021001' then '男' when m.member_sex = '10021002' then '女' else '未知' end `性别`,
m.member_phone `沃世界注册手机号`,
p.create_time `发帖时间`,
pm.`发帖字数`,
pm.`发帖图片数量`,
p.like_count `点赞数`,
pm.`发帖内容`,
--ll.topic_id  `话题`, 
ll.topic_name `发帖tag`,
--pm.`发帖图片链接`,
ifnull(x1.`中奖次数`,0) `中奖次数`,
x1.`奖品明细`
--r.`收货人姓名`,
--r.`收货人手机号`,
--r.`收货地址`
from ods_cmnt.ods_cmnt_tm_post_cur p
left join(
	select *
	from ods_memb.ods_memb_tc_member_info_cur tmi
	where tmi.is_deleted  = 0
	and tmi.member_status  <> '60341003' 
)m on p.member_id = m.id
left join (
select 
l.post_id,arrayStringConcat(groupArray(l.topic_id),',')   `topic_id` ,arrayStringConcat(groupArray(td.topic_name),',')   `topic_name` 
from ods_cmnt.ods_cmnt_tr_topic_post_link_cur l
left join ods_cmnt.ods_cmnt_tm_topic_d td on  l.topic_id =td.topic_id
where l.is_deleted = 0
--and l.post_id='mcaUPT9J9o'
group by 1
)ll on p.post_id = ll.post_id
left join (select * from ods_cmnt.ods_cmnt_tr_topic_post_link_cur l where l.is_deleted = 0)l on p.post_id = l.post_id
left join(-- 发帖内容、图片
	select
		t.post_id,
		REPLACE(replaceRegexpAll(replaceRegexpAll(arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'text' THEN t.`内容` ELSE NULL END), ';'), '<.*?>', ''),'#(.*?)#', ''),' ','') `发帖内容`,
		lengthUTF8(REPLACE(replaceRegexpAll(replaceRegexpAll(arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'text' THEN t.`内容` ELSE NULL END), ';'), '<.*?>', ''),'#(.*?)#', ''),' ','')) `发帖字数`,
		arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'image' THEN t.`内容` ELSE NULL END), ';') AS `发帖图片链接`,
		count(case when t.`类型`='image' then t.`内容` else null end) as `发帖图片数量`
	from(
		select
			tpm.post_id,
			tpm.create_time,
			replace(tpm.node_content,' ','') `发帖内容`,
			visitParamExtractString(tpm.node_content, 'nodeType') `类型`,
			visitParamExtractString(tpm.node_content, 'nodeContent') `内容`
		from ods_cmnt.ods_cmnt_tt_post_material_cur tpm
		where tpm.create_time >= '2024-09-14'   and tpm.create_time <  '2024-09-30' 
		and tpm.is_deleted = 0
	) as t
	group by t.post_id
) pm on p.post_id = pm.post_id
left join (
	select c.MEMBER_ID,`收货人姓名`,`收货人手机号`,`收货地址` 
	from(
		select 
			tma.MEMBER_ID MEMBER_ID,
			tma.CONSIGNEE_NAME `收货人姓名`,
			tma.CONSIGNEE_PHONE `收货人手机号`,
			CONCAT(ifnull(tr.REGION_NAME,''),ifnull(tr2.REGION_NAME,''),ifnull(tr3.REGION_NAME,''),ifnull(tma.MEMBER_ADDRESS,'')) `收货地址`,
			row_number() over(partition by tma.MEMBER_ADDRESS  order by tma.CREATE_TIME desc) rk
		from ods_memb.ods_memb_tc_member_address_d tma
		left join ods_dict.ods_dict_tc_region_d tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
		left join ods_dict.ods_dict_tc_region_d tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
		left join ods_dict.ods_dict_tc_region_d tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
		where tma.IS_DELETED = 0
		and tma.IS_DEFAULT = 1   -- 默认收货地址
	)c where c.rk = 1
)r on r.MEMBER_ID=p.member_id 
left join 
	( 	
	--历史获奖详情
	select
	a.member_id `member_id`,
	count(1) `中奖次数`,
	arrayStringConcat(groupArray(b.prize_name),',')  `奖品明细`
	from ods_voam.ods_voam_lottery_draw_log_d  a
	left join  ods_voam.ods_voam_lottery_play_pool_l   b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	left join ods_memb.ods_memb_tc_member_info_cur  d on toString(a.member_id)  =toString(d.id)
	where a.have_win = 1   -- 中奖
--	and a.create_time>='2024-01-17'
--	and a.create_time <='{end_time}'
	group by 1
	) x1 on toString(x1.member_id)=toString(p.member_id )
where p.is_deleted = 0
and p.create_time >=  '2024-09-14' 
and p.create_time < '2024-09-30' 
and l.topic_id in ('FnQ7uGkUQw')  
order by p.create_time
)bb on aa.`member_id`=bb.`会员ID`



