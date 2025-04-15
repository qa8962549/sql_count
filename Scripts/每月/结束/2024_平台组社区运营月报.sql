UGC是1007 用户发文章 ；OGC是1002，官方发文章
OGC应该是指文章类型为1002的 1002就是官方发文章
--互动是指官号本身的评论回复数量（剔除咨询回复）；互动率=互动/贴内总评论
--咨询定义：由官号评论回复用户的问题，评论内容以“亲爱的沃友”开头
--官方评论数:官方账号下发的帖子里的官号评论数量

--APP-官号  平台组数据需求
select 
distinct 
tmi.member_name as `官号昵称`,
a.member_id as `账号ID`,
ifnull(f.ftl,0)  as `发帖量`,
ifnull(pl2.num,0) 评论数,
ifnull(gf.官方评论,0)  as `官方评论数`,
ifnull(zx.咨询,0) 咨询,
ifnull(hd.互动,0) 互动,
concat(ifnull(hd.互动,0)/ifnull(pl2.num,0)*100,'%'),
count(distinct fs.fans_member_id) `粉丝数`
from community.tm_post a
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join mine.tt_fans_relationship fs on a.member_id =fs.member_id 
left join (-- 发帖量 
	select 
	a.member_id,
	count(a.id) as `ftl`
	from community.tm_post a 
	where  to_date(a.create_time) >= '2024-06-01' 
	and  to_date(a.create_time) <'2024-07-01'
	and a.is_deleted =0
	group by a.member_id
	order by a.member_id
) f on f.member_id=a.member_id 
left join 
	(-- 所发文章总评论数
	select tp.member_id,
	ifnull(sum(a.文章总评论数),0) num 
	from community.tm_post tp
	left join 
		(
		select 
		a.post_id,
		count(a.member_id) `文章总评论数`
		from  community.tm_comment a 
		where a.is_deleted =0
		and a.create_time >='2024-06-01'
		and a.create_time <'2024-07-01'
		group by a.post_id )a on a.post_id=tp.post_id
	where tp.is_deleted=0
	group by 1
	order by 2 desc 
	) pl2 on pl2.member_id=a.member_id
left join
	(--官方评论
	select 
	a.member_id,
	count(a.member_id) `官方评论`
	from community.tm_comment a
	where a.is_deleted =0
	and a.create_time >='2024-06-01'
	and a.create_time <'2024-07-01'
	group by a.member_id  )gf on gf.member_id = a.member_id
left join 
	(-- 咨询
	select 
	a.member_id,
	count(a.member_id) `咨询`
	from community.tm_comment a
	where a.is_deleted =0
	and a.create_time >='2024-06-01'
	and a.create_time <'2024-07-01'
	and a.comment_content like '%亲爱的沃友%'
	group by a.member_id )zx on zx.member_id = a.member_id
left join 
	(-- 互动
	select 
	--a.post_id,
	a.member_id,
	count(a.member_id) `互动`
	from community.tm_comment a
	where a.is_deleted =0
	and a.create_time >='2024-06-01'
	and a.create_time <'2024-07-01'
	and a.comment_content not like '%亲爱的沃友%'
	group by a.member_id
)hd on 
--a.post_id=hd.post_id 
hd.member_id = a.member_id
where a.is_deleted ='0'
and a.member_id  in 
(
'5973084',
'5637978',
'6043917',
'6024362',
'6024280',
'4652871',
'6046213',
'4771537',
'3684426',
'5762987',
'6119457',
'6633371',
'3755093',
'6148145',
'6093234',
'6100806',
'3792864',
'5993333',
'6164265',
'3696738',
'6228927'
)
and a.post_type ='1002'
and  a.create_time >='2024-06-01'
and a.create_time <'2024-07-01' 
group by a.member_id ,tmi.member_name


--统计12月官号发布的帖子明细 明细字段（账号id、帖子id、首次发布时间、是否上推荐、帖子uv）
select a.member_id `账号ID`,
a.post_id `帖子ID` ,
a.create_time `首次发布时间`,
case when a.recommend = 1 then '是' else '否' end 是否上推荐,
c.UV
from community.tm_post a
left join
	(-- 帖子的PVUV
	select 
	a.post_id,
	count(a.member_id) PV,
	count(DISTINCT a.member_id) UV
	from community.tt_view_post a
	where a.is_deleted =0
	and a.create_time >='2024-06-01'
	and a.create_time <'2024-07-01' 
	group by a.post_id )c on c.post_id = a.post_id
where a.create_time >='2024-06-01'
and a.create_time <'2024-07-01' 
and a.is_deleted ='0'
and a.member_id  in 
(
'5973084',
'5637978',
'6043917',
'6024362',
'6024280',
'4652871',
'6046213',
'4771537',
'3684426',
'5762987',
'6119457',
'6633371',
'3755093',
'6148145',
'6093234',
'6100806',
'3792864',
'5993333',
'6164265',
'3696738',
'6228927'
)
and a.post_type ='1002'
order by 5 desc 

--当月所有话题的发帖量
select
--a.topic_id  话题id,
a.topic_name 话题名称
,ifnull(f.发帖量,0)
,ifnull(f.参与人数,0)
from community.tm_topic a
left join (-- 帖子的参与人数
	select 
	l.topic_id,
	count(distinct a.member_id) 参与人数, -- 参与人数
	count(a.id) 发帖量
	from community.tr_topic_post_link l 
	left join community.tm_post a on a.post_id = l.post_id and l.is_deleted = 0 
	where 1=1
	and to_date(a.create_time) >= '2024-06-01' 
	and to_date(a.create_time) <'2024-07-01'
	and a.is_deleted =0
	group by l.topic_id
	order by l.topic_id desc) f on f.topic_id=a.topic_id
where a.create_time >='2024-06-01'
and a.create_time <'2024-07-01' 
group by a.topic_name
order by a.topic_name desc 


