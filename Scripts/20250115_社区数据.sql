-- 话题的活跃人数（发帖、浏览、互动）  近30天每天社区用户发帖＋发文章＋评论的总数量
select 
x.t `日期`,
x.num `用户发帖（动态）＋文章`,
x1.num `评论`,
x.num+x1.num `用户发帖＋文章＋评论`
from 
(
-- 用户发帖+发文章
	select 
	date_format(a.create_time,'%Y-%m-%d') t,
	count(a.member_id) num
	from community.tm_post a 
	where 1=1
	and a.create_time>=curdate() - interval'30'day
	and a.create_time<curdate()
	and a.is_deleted =0
	and a.post_type in ('1002','1001')
	group by 1 
	order by 1 
)x
left join 
(
	-- 评论
		select 
		date_format(a.create_time,'%Y-%m-%d') t,
		count(a.member_id) num
		from community.tm_comment a
		where a.is_deleted =0
		and a.create_time>=curdate() - interval'30'day
		and a.create_time<curdate()
		group by 1 
		order by 1 
)x1 on x1.t=x.t
order by 1 

	