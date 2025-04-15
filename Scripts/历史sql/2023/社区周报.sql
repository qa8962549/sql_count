-- 动态详情PV（NB)
select 
--to_char(a.create_time, 'IYYY-IW'),
sum(a.read_count) PV
--count(distinct a.member_id) UV
from community.tm_post a
where 1=1
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
and a.is_deleted <>1
and a.post_type =1001 -- 动态详情
--group by 1
--order by 1 desc 
union all 
-- 动态详情UV（NB)
SELECT 
--to_char(a.create_time, 'IYYY-IW') week
-- ,count(a.member_id)PV
count(DISTINCT a.member_id) UV
from community.tt_view_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1001 -- 动态详情
and b.is_deleted <>1
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
--group by 1
--order by 1 desc
union all 
-- 官方文章详情PVUV 用这个
SELECT 
--to_char(a.create_time, 'IYYY-IW') week
count(a.member_id)PV
--,count(DISTINCT a.member_id) UV
from community.tt_view_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1002 -- 官方文章详情
and b.is_deleted <>1
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >='2022-12-05'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
--group by 1
--order by 1 desc
union all 
SELECT 
--to_char(a.create_time, 'IYYY-IW') week
--,count(a.member_id)PV
count(DISTINCT a.member_id) UV
from community.tt_view_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1002 -- 官方文章详情
and b.is_deleted <>1
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >='2022-12-05'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
--group by 1
--order by 1 desc
union all 
-- 用户文章PV（NB)
select 
-- to_char(a.create_time, 'IYYY-IW') week,
sum(a.read_count) PV
-- count(distinct a.member_id) UV
from community.tm_post a
where 1=1
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >='2022-12-05'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
and a.is_deleted <>1
and a.post_type =1007 -- 用户发帖ugc
--group by 1
--order by 1 desc
union all 
-- 用户文章UV（NB)
SELECT 
--to_char(a.create_time, 'IYYY-IW') week
-- ,count(a.member_id)PV
count(DISTINCT a.member_id) UV
from community.tt_view_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1007 -- 用户发帖ugc
and b.is_deleted <>1
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >='2022-12-05'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
--group by 1
--order by 1 desc 

-- 发布动态人数(NB)
SELECT 
--to_char(a.create_time, 'IYYY-IW') week
count(DISTINCT a.member_id)发布动态人数
from community.tm_post a
where a.is_deleted <>1
and a.post_type =1001 -- 发帖（动态）
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
SELECT 
count(DISTINCT a.id) 发布动态篇数
from community.tm_post a
where a.is_deleted <>1
and a.post_type =1001 -- 发帖（动态）
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
-- 社区发帖人数 以nb为准 0308
SELECT 
--to_char(a.create_time, 'IYYY-IW') week,
count(DISTINCT a.member_id) 人数
from community.tm_post a
where 1=1
and a.is_deleted <>1
and a.post_type =1007 -- 发帖（动态）
-- and a.post_state =1 -- 筛选上架
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
SELECT 
--to_char(a.create_time, 'IYYY-IW') week,
count(a.member_id) 篇数
from community.tm_post a
where 1=1
and a.is_deleted <>1
and a.post_type =1007 -- 发帖（动态）
-- and a.post_state =1 -- 筛选上架
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
-- UGC文章点赞收藏
select count(case when a.like_type =0 then a.id end) 文章总点赞数
-- ,count(DISTINCT case when a.like_type =0 then a.member_id  end) 文章总点赞人数
-- ,count(DISTINCT case when a.like_type =1 then a.member_id  end) 文章总收藏人数
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1007 -- 文章
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
-- UGC文章评论人数
select 
count(a.comment_id) 文章总评论数
-- ,count(distinct a.member_id) 文章总评论人数
from community.tm_comment a
left join community.tm_post b on a.post_id =b.post_id 
where 1=1
and a.is_deleted =0
and b.post_type =1007 -- 文章
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
select 
--count(case when a.like_type =0 then a.id end) 文章总点赞数
-- ,count(DISTINCT case when a.like_type =0 then a.member_id  end) 文章总点赞人数
count(case when a.like_type =1 then a.id end) 文章总收藏数
-- ,count(DISTINCT case when a.like_type =1 then a.member_id  end) 文章总收藏人数
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1007 -- 文章
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()




-- 官方文章评论人数
select count(a.id) 文章总评论数
--,count(distinct a.member_id) 文章总评论人数
from community.tm_comment a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1002 -- 文章
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
select count(distinct a.member_id) 文章总评论人数
from community.tm_comment a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1002 -- 文章
--and a.create_time >='2022-12-05'
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
 union all 
-- 官方文章点赞收藏
select 
count(case when a.like_type =0 then a.id end) 文章总点赞数
--count(DISTINCT case when a.like_type =0 then a.member_id  end) 文章总点赞人数,
--count(case when a.like_type =1 then a.id end) 文章总收藏数,
--count(DISTINCT case when a.like_type =1 then a.member_id  end) 文章总收藏人数
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1002 -- 文章
--and a.create_time >='2022-12-05'
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
select 
--count(case when a.like_type =0 then a.id end) 文章总点赞数,
count(DISTINCT case when a.like_type =0 then a.member_id  end) 文章总点赞人数
--count(case when a.like_type =1 then a.id end) 文章总收藏数,
--count(DISTINCT case when a.like_type =1 then a.member_id  end) 文章总收藏人数
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1002 -- 文章
--and a.create_time >='2022-12-05'
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
select 
--count(case when a.like_type =0 then a.id end) 文章总点赞数,
--count(DISTINCT case when a.like_type =0 then a.member_id  end) 文章总点赞人数,
count(case when a.like_type =1 then a.id end) 文章总收藏数
--count(DISTINCT case when a.like_type =1 then a.member_id  end) 文章总收藏人数
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1002 -- 文章
--and a.create_time >='2022-12-05'
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
select 
--count(case when a.like_type =0 then a.id end) 文章总点赞数,
--count(DISTINCT case when a.like_type =0 then a.member_id  end) 文章总点赞人数,
--count(case when a.like_type =1 then a.id end) 文章总收藏数,
count(DISTINCT case when a.like_type =1 then a.member_id  end) 文章总收藏人数
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1002 -- 文章
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >='2022-12-05'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()


-- 发帖（动态）评论人数
select 
count(a.id) 总评论数
--count(distinct a.member_id) 总评论人数
from community.tm_comment a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1001 -- 发帖（动态
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >='2022-12-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
select 
--count(a.id) 总评论数,
count(distinct a.member_id) 总评论人数
from community.tm_comment a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1001 -- 发帖（动态
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >='2022-12-01'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
-- 动态点赞收藏
select 
count(case when a.like_type =0 then a.id end) 发帖总点赞数
--count(DISTINCT case when a.like_type =0 then a.member_id  end) 发帖总点赞人数,
--count(case when a.like_type =1 then a.id end) 发帖总收藏数,
--count(DISTINCT case when a.like_type =1 then a.member_id  end) 发帖总收藏人数
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1001 -- 发帖（动态）
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >='2022-12-05'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
select 
--count(case when a.like_type =0 then a.id end) 发帖总点赞数,
count(DISTINCT case when a.like_type =0 then a.member_id  end) 发帖总点赞人数
--count(case when a.like_type =1 then a.id end) 发帖总收藏数,
--count(DISTINCT case when a.like_type =1 then a.member_id  end) 发帖总收藏人数
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1001 -- 发帖（动态）
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >='2022-12-05'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
select 
--count(case when a.like_type =0 then a.id end) 发帖总点赞数,
--count(DISTINCT case when a.like_type =0 then a.member_id  end) 发帖总点赞人数,
count(case when a.like_type =1 then a.id end) 发帖总收藏数
--count(DISTINCT case when a.like_type =1 then a.member_id  end) 发帖总收藏人数
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1001 -- 发帖（动态）
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >='2022-12-05'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()
union all 
select 
--count(case when a.like_type =0 then a.id end) 发帖总点赞数,
--count(DISTINCT case when a.like_type =0 then a.member_id  end) 发帖总点赞人数,
--count(case when a.like_type =1 then a.id end) 发帖总收藏数,
count(DISTINCT case when a.like_type =1 then a.member_id  end) 发帖总收藏人数
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and b.post_type =1001 -- 发帖（动态）
and a.create_time >='2023-12-25'
and a.create_time <'2024-01-01'
--and a.create_time >='2022-12-05'
--and a.create_time >=DATE_SUB(CURDATE(),INTERVAL '7' DAY) 
--and a.create_time <CURDATE()



