-- 单篇内容浏览人数
-- 单篇内容人均浏览次数
SELECT a.post_id,
count(DISTINCT a.create_by) 单篇内容浏览人数,
ROUND(count(a.create_by)/count(DISTINCT a.create_by),2) 单篇内容人均浏览次数,
ROUND(b.次数/count(DISTINCT a.create_by),2) 单篇内容人均评论次数,
ROUND(c.次数/count(DISTINCT a.create_by),2) 单篇内容人均点赞次数,
ROUND(b.次数/count(DISTINCT a.create_by),2) 单篇内容人均收藏次数,
e.recommend 是否推荐
from community.tt_view_post a
left join 
	(
	#单篇评论
	select a.post_id,
	count(a.comment_content) 次数
	from community.tm_comment a 
	where a.is_deleted =0
	group by 1 
	order by 2 desc )b on b.post_id=a.post_id 
left join 
	(
	#单篇点赞
	select a.post_id,
	count(a.id) 次数
	from community.tt_like_post a
	where a.is_deleted =0
	and a.like_type='0' -- 点赞
	group by 1
	order by 2 desc )c on c.post_id=a.post_id 
left join 
	(
	#单篇收藏
	select a.post_id,
	count(a.id) 次数
	from community.tt_like_post a
	where a.is_deleted =0
	and a.like_type='1' -- 收藏
	group by 1
	order by 2 desc )d on d.post_id=a.post_id 	
left join 
	(
	#是否推荐
	select a.post_id,
	a.recommend
	from community.tm_post a
	where a.is_deleted =0
	group by 1
	order by 2 desc )e on e.post_id=a.post_id 
where a.is_deleted =0
group by 1
order by 2 desc 

-- 单篇内容人均评论次数
select a.post_id,
count(a.comment_content)
from community.tm_comment a 
where a.is_deleted =0
group by 1 
order by 2 desc 

-- 单篇内容入口-点赞转化率
select a.post_id ,
count(a.id)
from community.tt_like_post a
where a.is_deleted =0
group by 1
order by 2 desc 

-- 单篇内容入口-评论转化率

-- 单篇内容入口-收藏转化率

-- 单篇内容详情页-分享转化率

-- 是否推荐

-- 是否加精