--话题榜单数据
select 
a.会员id,
a.昵称,
a.用户姓名,
a.手机号码,
a.评论内容,
a.评论日期,
a.评论图片,
a.层级,
(sum(IF(a.`点赞数` is null,0,a.`点赞数`))+sum(IF(b.`评论数` is null,0,b.`评论数`))) 互动数,
a.点赞数
from
(
	SELECT
	tc.comment_id id,
	tc.create_by 会员id,
	tmi.MEMBER_NAME 昵称,
	tmi.REAL_NAME 用户姓名,
	tmi.MEMBER_PHONE 手机号码,
	tc.comment_content 评论内容,
	tc.create_time 评论日期,
	tc.images 评论图片,
	case when tc.parent_id='0' then 1
	else  2 end 层级,
	tc.like_count 点赞数
	FROM community.tm_comment tc 
	left join `member`.tc_member_info tmi on tmi.id = tc.member_id 
	where tc.post_id in ('J7M9S5C0xU')
	-- 	and parent_id ='0'
	and tc.create_time BETWEEN '2024-02-06 00:00:00' and '2024-02-09 23:59:59'
	ORDER by tc.create_time
) a 
left join
(
	SELECT
	tc.parent_id ,
	count(*) 评论数
	FROM community.tm_comment tc 
	left join `member`.tc_member_info tmi on tmi.id = tc.member_id 
	where tc.post_id in ('J7M9S5C0xU')
	and parent_id <>'0'
	and tc.create_time BETWEEN '2024-02-06 00:00:00' and '2024-02-09 23:59:59'
	group by 1
) b on a.id = b.parent_id
group by a.会员id,a.昵称,a.用户姓名,a.手机号码,a.评论内容,a.评论日期,a.评论图片,a.层级,a.点赞数
order by a.点赞数 desc

--1月社区文章标签统计
select 
	tp.post_id "PostID"
	,tmi.member_name "用户昵称"
	,tp.create_time "创建时间"
	,case when tp.post_state = 1 then '上架' end "状态"
	,tp.post_title "文章标题"
	,case when tpl.parent_id = '1729707902485364738' then tpl.parent_id else '' end "标签ID"
	,case when tpl.parent_id = '1729707902485364738' then '私域渠道' else '' end "一级标签"
	,case when tpl.parent_id = '1729707902485364738' then tpl.label_id
		when tpl.parent_id <> '1729707902485364738' then tpl.parent_id end "二级标签"
	,case when tpl.parent_id <> '1729707902485364738' then tpl.label_id else '' end "三级标签"
--	,tpl.label_id ,tpl.parent_id 
from ods_cmnt.ods_cmnt_tm_post_cur tp -- 发帖主表
left join ods_memb.ods_memb_tc_member_info_cur tmi -- 会员信息表
	on tmi.id = tp.member_id 
left join ods_cmnt.ods_cmnt_tt_post_label_cms_d tpl -- 标签表
	on tpl.post_id = tp.post_id 
where 1=1
	and tp.is_deleted = 0
	and tp.post_type = 1002 -- 官方文章
	and tp.post_state = 1 -- 上架状态
	and date(tp.create_time) >= '2024-01-01' and date(tp.create_time) < '2024-02-01' 
	and tmi.is_deleted = 0
	and tpl.is_deleted = 0
--	and tp.post_id = 'jReiPoAdsk'
order by tp.create_time asc

	

select a.post_id,a.post_title,a.post_type,a.member_id,a.create_time 
from ods_cmnt.ods_cmnt_tm_post_cur  a
--left join ods_cmnt.ods_cmnt_tt_post_label_cms_d b on a.post_id=b.post_id
where 1=1
order by a.create_time desc 
--and b.post_id = ''
--and a.post_type='1002'



--历史社区文章标签统计
select 
	tp.post_id "PostID"
	,tmi.member_name "用户昵称"
	,tp.create_time "创建时间"
	,case when tp.post_state = 2 then '下架' end "状态"
	,tp.post_title "文章标题"
from ods_cmnt.ods_cmnt_tm_post_cur tp -- 发帖主表
left join ods_memb.ods_memb_tc_member_info_cur tmi -- 会员信息表
	on tmi.id = tp.member_id 
left join ods_cmnt.ods_cmnt_tt_post_label_cms_d tpl -- 标签表
	on tpl.post_id = tp.post_id 
where 1=1
	and tp.is_deleted = 0
	and tp.post_type = 1002 -- 官方文章
	and tp.post_state = 2 -- 下架状态
	and date(tp.create_time) < '2024-02-01' 
	and tmi.is_deleted = 0
	and tpl.is_deleted = 0
	and tpl.post_id = ''
--	and tp.post_id = 'jReiPoAdsk'
order by tp.create_time desc