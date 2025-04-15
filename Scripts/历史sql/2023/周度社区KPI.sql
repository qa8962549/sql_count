-- 总 by话题
select 
concat(date_format(now()-7,'%m/%d'),'-',date_format(now()-1,'%m/%d')) t,
x.topic_name,
x5.话题id,
x5.话题创建时间,
x5.第一篇帖子发帖时间,
ifnull(x1."总发帖人数（去重）",0) "总发帖人数（去重）",
ifnull(x1."总发帖量",0) "总发帖量",
ifnull(x2.num,0) "优质（100个字3张图）篇数",
ifnull(x4.num,0) "话题合集页及对应帖子 UV",
ifnull(x3.num,0) "互动（转评赞收藏）去重人数",
ifnull(x.num,0) "话题的活跃人数（发帖、浏览、互动）"
from 
	(
	-- 话题的活跃人数（发帖、浏览、互动）
	select 
	x.topic_name,
	count(distinct x.member_id) num 
	from 
	(
	-- 帖子的参与人数
		select 
		distinct 
		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id
		from community.tr_topic_post_link l 
		left join community.tm_post a on a.post_id = l.post_id and l.is_deleted = 0 
		left join community.tm_topic tt on l.topic_id=tt.topic_id
		where 1=1
		and a.create_time>='2024-04-01'
		and a.create_time<'2024-04-24'
		and a.is_deleted =0
		union 
	-- 话题的浏览
		select 
		distinct 
		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id
		from community.tt_view_post a
		join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0 
		left join community.tm_topic tt on l.topic_id=tt.topic_id
		where 1=1
		and a.create_time>='2024-04-01'
		and a.create_time<'2024-04-24'
		and a.is_deleted =0
		union 
	-- 点赞收藏
		select 
		distinct 
		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id
		from community.tr_topic_post_link bb
		left join community.tm_post a on a.post_id =bb.post_id 
		left join community.tm_topic tt on bb.topic_id =tt.topic_id 
		left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
		left join community.tt_like_post c on a.post_id =c.post_id 
		where a.is_deleted =0
		and a.create_time>='2024-04-01'
		and a.create_time<'2024-04-24'
		and bb.topic_id is not null 
		union 
	-- 评论
		select 
		distinct 
		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id 
		from community.tm_comment a
		left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0
		left join community.tm_topic tt on l.topic_id =tt.topic_id 
		where a.is_deleted <>1
		and a.create_time>='2024-04-01'
		and a.create_time<'2024-04-24'
		and l.topic_id is not null 
	)x
	group by 1
	order by 1
	)x 
left join 
		(-- 此刻发帖 2023年总发帖人数（去重），2023年总发帖量
	select 
	--bb.topic_id,
	tt.topic_name,
--	date_format(a.create_time,'%Y-%m') t,
	count(distinct a.member_id) "总发帖人数（去重）",
	count(a.post_id) "总发帖量",
	x.num 
	from community.tm_post a
	left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
	left join community.tm_topic tt on bb.topic_id =tt.topic_id 
	left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
	full outer join (-- 优质（100个字3张图）篇数
		select 
			bb.topic_id,
			tt.topic_name,
			date_format(a.create_time,'%Y-%m') t,
			count(a.post_id) num
		from community.tm_post a
		left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
		left join community.tm_topic tt on bb.topic_id =tt.topic_id 
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
		where a.is_deleted =0
		and a.create_time>='2024-04-01'
		and a.create_time<'2024-04-24'
		and char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))>=100 --帖子字数不少于100字
		and pm.发帖图片数量>=3 -- 配图不少于3张的文章及动态
		group by 1,2,3
		order by 1,2,3)x on x.topic_id=bb.topic_id and x.t=date_format(a.create_time,'%Y-%m')
	where a.is_deleted =0
	and a.create_time>='2024-04-01'
	and a.create_time<'2024-04-24'
	and bb.topic_id is not null and bb.topic_id<>''
	group by 1
	order by 1
	)x1 on x1.topic_name=x.topic_name 
left join (-- 优质（100个字3张图）篇数
	select 
	--	bb.topic_id,
		tt.topic_name,
--		date_format(a.create_time,'%Y-%m') t,
		count(a.post_id) num
	from community.tm_post a
	left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
	left join community.tm_topic tt on bb.topic_id =tt.topic_id 
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
	where a.is_deleted =0
	and a.create_time>='2024-04-01'
	and a.create_time<'2024-04-24'
	and char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))>=100 --帖子字数不少于100字
	and pm.发帖图片数量>=3 -- 配图不少于3张的文章及动态
	group by 1
	order by 1)x2 on x2.topic_name=x.topic_name 
left join (-- 话题数据汇总 --互动（转评赞收藏）去重人数
	select 
	x.topic_name,
--	t,
	count(distinct x.member_id) num
	from 
	(
	-- 点赞收藏
		select 
		distinct 
		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id
		from community.tr_topic_post_link bb
		left join community.tm_post a on a.post_id =bb.post_id 
		left join community.tm_topic tt on bb.topic_id =tt.topic_id 
		left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
		left join community.tt_like_post c on a.post_id =c.post_id 
		where a.is_deleted =0
		and a.create_time>='2024-04-01'
		and a.create_time<'2024-04-24'
		and bb.topic_id is not null 
		union 
	-- 评论
		select 
		distinct 
		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id 
		from community.tm_comment a
		left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0
		left join community.tm_topic tt on l.topic_id =tt.topic_id 
		where a.is_deleted <>1
		and a.create_time>='2024-04-01'
		and a.create_time<'2024-04-24'
		and l.topic_id is not null 
	)x
	group by 1
	order by 1)x3 on x3.topic_name=x.topic_name 
left join 
	(
--	话题合集页及对应帖子 UV
	select 
--	date_format(t.create_time,'%Y-%m') t,
	tt.topic_name ,
	count(distinct t.member_id) num 
	from community.tr_topic_post_link c 
	left join community.tm_topic tt on c.topic_id=tt.topic_id
	left join community.tt_view_post t on c.post_id =t.post_id -- 话题对应浏览明细
	where t.create_time>='2024-04-01'
	and t.create_time<'2024-04-24'
	group by 1
	order by 1)x4 on x4.topic_name=x.topic_name 
left join (-- 发帖明细
		select 
		distinct 
		tt.topic_name 话题名称,
		tt.topic_id 话题id,
		tt.create_time 话题创建时间,
		x.第一篇帖子发帖时间
		from community.tm_topic tt 
		left join 
			(
		--	第一篇帖子发帖时间
			select 
			tt.topic_name,
			bb.topic_id 话题id,
			min(a.create_time) 第一篇帖子发帖时间
			from community.tm_post a
			left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
			left join community.tm_topic tt on bb.topic_id =tt.topic_id 
			left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
			where a.is_deleted =0
			group by 1
		)x on x.topic_name=tt.topic_name
		where tt.is_deleted =0)x5 on x5.话题名称=x.topic_name
order by 2,1


-- 总 
select 
x.t 时间,
ifnull(x1."总发帖人数（去重）",0) "总发帖人数（去重）",
ifnull(x1."总发帖量",0) "总发帖量",
ifnull(x2.num,0) "优质（100个字3张图）篇数",
ifnull(x4.num,0) "话题合集页及对应帖子 UV",
ifnull(x3.num,0) "互动（转评赞收藏）去重人数",
ifnull(x.num,0) "话题的活跃人数（发帖、浏览、互动）"
from 
	(
	-- 话题的活跃人数（发帖、浏览、互动）
	select 
	concat(date_format(now()-7,'%m/%d'),'-',date_format(now()-1,'%m/%d')) t,
	count(distinct x.member_id) num 
	from 
	(
	-- 帖子的参与人数
		select 
		distinct 
--		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id
		from community.tr_topic_post_link l 
		left join community.tm_post a on a.post_id = l.post_id and l.is_deleted = 0 
		left join community.tm_topic tt on l.topic_id=tt.topic_id
		where 1=1
		and a.create_time>='2024-04-29'
		and a.create_time<'2024-05-06'
		and a.is_deleted =0
		union 
	-- 话题的浏览
		select 
		distinct 
--		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id
		from community.tt_view_post a
		join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0 
		left join community.tm_topic tt on l.topic_id=tt.topic_id
		where 1=1
		and a.create_time>='2024-04-29'
		and a.create_time<'2024-05-06'
		and a.is_deleted =0
		union 
	-- 点赞收藏
		select 
		distinct 
--		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id
		from community.tr_topic_post_link bb
		left join community.tm_post a on a.post_id =bb.post_id 
		left join community.tm_topic tt on bb.topic_id =tt.topic_id 
		left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
		left join community.tt_like_post c on a.post_id =c.post_id 
		where a.is_deleted =0
		and a.create_time>='2024-04-29'
		and a.create_time<'2024-05-06'
		and bb.topic_id is not null 
		union 
	-- 评论
		select 
		distinct 
--		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id 
		from community.tm_comment a
		left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0
		left join community.tm_topic tt on l.topic_id =tt.topic_id 
		where a.is_deleted <>1
		and a.create_time>='2024-04-29'
		and a.create_time<'2024-05-06'
		and l.topic_id is not null 
	)x
	)x 
left join 
		(-- 此刻发帖 2023年总发帖人数（去重），2023年总发帖量
	select 
	concat(date_format(now()-7,'%m/%d'),'-',date_format(now()-1,'%m/%d')) t,
--	date_format(a.create_time,'%Y-%m') t,
	count(distinct a.member_id) "总发帖人数（去重）",
	count(a.post_id) "总发帖量",
	x.num 
	from community.tm_post a
	left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
	left join community.tm_topic tt on bb.topic_id =tt.topic_id 
	left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
	full outer join (-- 优质（100个字3张图）篇数
		select 
			bb.topic_id,
			tt.topic_name,
			date_format(a.create_time,'%Y-%m') t,
			count(a.post_id) num
		from community.tm_post a
		left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
		left join community.tm_topic tt on bb.topic_id =tt.topic_id 
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
		where a.is_deleted =0
		and a.create_time>='2024-04-29'
		and a.create_time<'2024-05-06'
		and char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))>=100 --帖子字数不少于100字
		and pm.发帖图片数量>=3 -- 配图不少于3张的文章及动态
		group by 1,2,3
		order by 1,2,3)x on x.topic_id=bb.topic_id and x.t=date_format(a.create_time,'%Y-%m')
	where a.is_deleted =0
	and a.create_time>='2024-04-29'
	and a.create_time<'2024-05-06'
	and bb.topic_id is not null and bb.topic_id<>''
	)x1 on x1.t=x.t
left join (-- 优质（100个字3张图）篇数
	select 
		concat(date_format(now()-7,'%m/%d'),'-',date_format(now()-1,'%m/%d')) t,
		count(a.post_id) num
	from community.tm_post a
	left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
	left join community.tm_topic tt on bb.topic_id =tt.topic_id 
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
	where a.is_deleted =0
	and a.create_time>='2024-04-29'
	and a.create_time<'2024-05-06'
	and char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))>=100 --帖子字数不少于100字
	and pm.发帖图片数量>=3 -- 配图不少于3张的文章及动态
)x2 on x2.t=x.t
left join (-- 话题数据汇总 --互动（转评赞收藏）去重人数
	select 
	concat(date_format(now()-7,'%m/%d'),'-',date_format(now()-1,'%m/%d')) t,
	count(distinct x.member_id) num
	from 
	(
	-- 点赞收藏
		select 
		distinct 
		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id
		from community.tr_topic_post_link bb
		left join community.tm_post a on a.post_id =bb.post_id 
		left join community.tm_topic tt on bb.topic_id =tt.topic_id 
		left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
		left join community.tt_like_post c on a.post_id =c.post_id 
		where a.is_deleted =0
		and a.create_time>='2024-04-29'
		and a.create_time<'2024-05-06'
		and bb.topic_id is not null 
		union 
	-- 评论
		select 
		distinct 
		date_format(a.create_time,'%Y-%m') t,
		tt.topic_name,
		a.member_id 
		from community.tm_comment a
		left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0
		left join community.tm_topic tt on l.topic_id =tt.topic_id 
		where a.is_deleted <>1
		and a.create_time>='2024-04-29'
		and a.create_time<'2024-05-06'
		and l.topic_id is not null 
	)x
)x3 on x3.t=x.t
left join 
	(
--	话题合集页及对应帖子 UV
	select 
	concat(date_format(now()-7,'%m/%d'),'-',date_format(now()-1,'%m/%d')) t,
	count(distinct t.member_id) num 
	from community.tr_topic_post_link c 
	left join community.tm_topic tt on c.topic_id=tt.topic_id
	left join community.tt_view_post t on c.post_id =t.post_id -- 话题对应浏览明细
	where t.create_time>='2024-04-29'
	and t.create_time<'2024-05-06')x4 on x4.t=x.t
order by 1

