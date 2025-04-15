--合伙人福利社内容合集页，页面链接：
--https://mweb.digitalvolvo.com/mweb/article/detail/3vueh5f5sP?pageIndex=1&pageSize=10&targetType=1010
--
--此地：事件=Page_view   页面标题名称=此地   业务类型=社区
--社区：事件=Page_view   页面标题名称=推荐   业务类型=社区
--

-- 文章数据需求sheet
select a.点赞,a.收藏,b.文章总评论数,c.PV,c.UV
from
(-- 0点赞 1收藏
select
'互动' 类型,
--case when a.like_type = 0 then '点赞' else '收藏' end 类型,
count(case when a.like_type = 0 then a.member_id else null end) 点赞,
count(case when a.like_type <> 0 then a.member_id else null end) 收藏
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted =0
and a.post_id ='WPOMikERA4'
and a.create_time >='2023-07-31'
and a.create_time <='2023-08-06 23:59:59'
order by 1 asc
)a
left join
(-- 评论
select 
'互动' 类型,
count(a.member_id) 文章总评论数
from community.tm_comment a
where a.is_deleted =0
and a.post_id ='WPOMikERA4'
and a.create_time >='2023-07-31'
and a.create_time <='2023-08-06 23:59:59'
)b on a.类型=b.类型
left join
(-- 帖子的PVUV
select 
'互动' 类型,
count(a.member_id) PV,
count(DISTINCT a.member_id) UV
from community.tt_view_post a
where a.post_id ='WPOMikERA4'
and a.create_time >='2023-07-31'
and a.create_time <='2023-08-06 23:59:59'
and a.is_deleted =0
)c  on a.类型=c.类型




-- 数据不同的原因是可能有一个人在一个话题下面发多条帖子的的情况，同时阅读、点赞、收藏这个数据是实时更新的
select
a.topic_id 话题ID,
count(distinct b.member_id) 参与人数,
count(b.post_id) 发帖量,
sum(b.read_count) 阅读量,
sum(c.评论量) 评论量,
sum(b.like_count) 点赞量,
sum(b.collect_count) 收藏量
from community.tr_topic_post_link a
left join
(
	-- 发帖阅读、点赞、收赃量
	select
	b.post_id,
	b.member_id,
	b.read_count,
	b.like_count,
	b.collect_count
	from community.tm_post b
	where -- b.create_time >= '2023-06-12'
--	and b.create_time <= '2023-05-07 23:59:59'
	b.is_deleted = 0
) b on a.post_id = b.post_id
left join 
(
	-- 发帖评论表
	select
	c.post_id,
	count(c.comment_id) 评论量
	from community.tm_comment c
	where --c.create_time >= '2023-06-12'
--	and c.create_time <= '2023-05-07 23:59:59'
	c.is_deleted = 0
	group by 1
) c on a.post_id = c.post_id
where a.is_deleted = 0 
and a.create_time >= '2023-07-24'
and a.create_time <= '2023-07-30 23:59:59'
-- 话题ID
and a.topic_id in(
'GicHAf1k4y',
'f5uejeof7L',
'tMQL1R7ekb',
'CpeCHHwXSk',
'Mvch10elnq')  
group by 1
order by 1