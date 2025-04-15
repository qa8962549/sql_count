--- 活动评论数据
select
teh.object_id 活动ID,
teh.content 评价内容,
case when teh.is_top = '10041001' then '是'
	else '否' end '是否置顶',
teh.create_time 评论时间,
teh.evaluation_source 评论来源,
teh.user_id 评论用户ID,
teh.name 评论姓名,
teh.mobile 评论用户手机号,
tmi.ID 会员ID,
tmi.MEMBER_PHONE 沃世界绑定手机号,
teh.liked_count 点赞数,
tep.picture_url 
from comment.tt_evaluation_history teh
left join comment.tc_evaluation_picture tep on tep.evaluation_id = teh.id 
left join `member`.tc_member_info tmi on teh.mobile = tmi.MEMBER_PHONE 
where teh.object_id = 'WtKKGse2dm'
and teh.create_time >= '2022-05-15 00:00:00'
and teh.create_time <= '2022-05-31 23:59:59'
and teh.is_deleted = 0
order by teh.create_time desc