-- 导出和app文章分享去重_11月
SELECT DISTINCT x.cust_id
from 
(
#APP活动评论人数
select DISTINCT a.member_id ,
m.CUST_ID 
from community.tm_comment a
left join `member`.tc_member_info m on m.ID=a.member_id 
where a.create_time >= '2022-11-01'
and a.create_time < '2022-12-01'
and a.post_id in ('ORMdt4j1yY',
'gzqs3Bg0yz',
'7msPUjZ777',
'yuwHtb8sX4',
'UqgVGCs44O',
'hq61VlwqQ4',
'tPOAmc3jKj',
'c2Oub55ytD')
and a.member_id <>0
and a.is_deleted =0
union
#APP活动点赞人数
select DISTINCT a.member_id ,
m.CUST_ID 
from community.tt_like_post a
left join `member`.tc_member_info m on m.ID=a.member_id 
where a.create_time >= '2022-11-01'
and a.create_time < '2022-12-01'
and a.post_id in ('ORMdt4j1yY',
'gzqs3Bg0yz',
'7msPUjZ777',
'yuwHtb8sX4',
'UqgVGCs44O',
'hq61VlwqQ4',
'tPOAmc3jKj',
'c2Oub55ytD')
and a.member_id <>0
and a.is_deleted =0
)x where x.cust_id is not null

-- 导出和app文章分享去重_10月
SELECT DISTINCT x.cust_id
from 
(
#APP活动评论人数
select DISTINCT a.member_id ,
m.CUST_ID 
from community.tm_comment a
left join `member`.tc_member_info m on m.ID=a.member_id 
where a.create_time >= '2022-10-01'
and a.create_time < '2022-11-01'
and a.post_id in ('NasP2nOxwt',
'kMstHfi0UH',
'nCgLH5cdUV',
'JUqq6BS5dz',
'JAMf6yFNmi')
and a.member_id <>0
and a.is_deleted =0
union
#APP活动点赞人数
select DISTINCT a.member_id ,
m.CUST_ID 
from community.tt_like_post a
left join `member`.tc_member_info m on m.ID=a.member_id 
where a.create_time >= '2022-10-01'
and a.create_time < '2022-11-01'
and a.post_id in ('NasP2nOxwt',
'kMstHfi0UH',
'nCgLH5cdUV',
'JUqq6BS5dz',
'JAMf6yFNmi')
and a.member_id <>0
and a.is_deleted =0
)x where x.cust_id is not null

-- 导出和app文章分享去重_12月
SELECT DISTINCT x.cust_id
from 
(
-- 小程序活动点赞收藏转发人数
-- select distinct m.ID ,
-- m.CUST_ID 
-- from `cms-center`.cms_operate_log o
-- left join `member`.tc_member_info m on m.USER_ID =o.user_id 
-- where o.type in ('SUPPORT','SHARE','COLLECTION') 
-- and date_create <'2023-01-01' 
-- and date_create >='2022-12-01'
-- and o.ref_id in ('bCQ38UGN2C',
-- 'ChQFyy2X0C',
-- 'lZ4mG0sn9d',
-- 'mXam4QBrel',
-- 'A8wJgV6W4p',
-- 'MSaQXkRXr1')
-- union 
-- 小程序活动评论人数
-- select
-- DISTINCT tmi.ID 会员ID,
-- tmi.CUST_ID 
-- from comment.tt_evaluation_history teh
-- left join `member`.tc_member_info tmi on teh.mobile = tmi.MEMBER_PHONE 
-- where teh.object_id in ('bCQ38UGN2C',
-- 'ChQFyy2X0C',
-- 'lZ4mG0sn9d',
-- 'mXam4QBrel',
-- 'A8wJgV6W4p',
-- 'MSaQXkRXr1')
-- and teh.create_time >= '2022-12-01'
-- and teh.create_time < '2023-01-01'
-- and teh.is_deleted = 0
-- union 
#APP活动评论人数
select DISTINCT a.member_id ,
m.CUST_ID 
from community.tm_comment a
left join `member`.tc_member_info m on m.ID=a.member_id 
where a.create_time >= '2022-12-01'
and a.create_time < '2023-01-01'
and a.post_id in ('ORMdt4j1yY',
'6RcHYU8DPT',
'Us44fnu8J1',
'U0wPpRYcbz',
'uQAdcfCjV8',
'KdMdvI0d3T',
'Z2qcrRL4yT',
'IEK0hdPXNx',
'qw6TCKcuXx',
'5jqEzEUqOM')
and a.member_id <>0
and a.is_deleted =0
union
#APP活动点赞人数
select DISTINCT a.member_id ,
m.CUST_ID 
from community.tt_like_post a
left join `member`.tc_member_info m on m.ID=a.member_id 
where a.create_time >= '2022-12-01'
and a.create_time < '2023-01-01'
and a.post_id in ('ORMdt4j1yY',
'6RcHYU8DPT',
'Us44fnu8J1',
'U0wPpRYcbz',
'uQAdcfCjV8',
'KdMdvI0d3T',
'Z2qcrRL4yT',
'IEK0hdPXNx',
'qw6TCKcuXx',
'5jqEzEUqOM')
and a.member_id <>0
and a.is_deleted =0
union 
select DISTINCT a.member_id,m.CUST_ID 
from community.tm_comment a
left join `member`.tc_member_info m on m.ID=a.member_id 
where a.post_id in 
	(
	select 
	a.post_id 
	from community.tm_post a
	where a.create_time >='2022-12-01' and a.create_time <'2023-01-01'
	and a.member_id <>0
	and a.is_deleted =0
	and a.post_digest like '%#一张封神#%'
OR a.post_digest like '%#一张封神沃时光影#%'
OR a.post_digest like '%#别赶路 去感受路#%'
OR a.post_digest like '%#俱在一起WOW#%'
OR a.post_digest like '%#俱乐部#%'
OR a.post_digest like '%#认证俱乐部#%'
)
union
select DISTINCT b.member_id,m.CUST_ID 
from community.tt_like_post b
left join `member`.tc_member_info m on m.ID=b.member_id 
where b.post_id in
	(
	select 
	a.post_id 
	from community.tm_post a
	where a.create_time >='2022-12-01' and a.create_time <'2023-01-01'
	and a.member_id <>0
	and a.is_deleted =0
	and a.post_digest like '%#一张封神#%'
OR a.post_digest like '%#一张封神沃时光影#%'
OR a.post_digest like '%#别赶路 去感受路#%'
OR a.post_digest like '%#俱在一起WOW#%'
OR a.post_digest like '%#俱乐部#%'
OR a.post_digest like '%#认证俱乐部#%'
)
)x where x.cust_id is not null

