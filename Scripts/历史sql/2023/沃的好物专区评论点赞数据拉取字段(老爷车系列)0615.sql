
-- 沃的好物评论数据
select
teh.user_id 会员ID,
tmi.ID 会员表会员ID,
teh.mobile 手机号,
tmi.MEMBER_PHONE 沃世界注册手机号,
teh.content 评论内容,
teh.create_time 评论时间,
teh.liked_count 点赞数
from comment.tt_evaluation_history teh
left join `member`.tc_member_info tmi on tmi.ID = teh.user_id
where teh.object_id = '0Ieu70DwFF'    -- 沃的好物 老爷车
and teh.create_time >= '2022-06-01'
and teh.create_time <= '2022-06-14 23:59:59'
and teh.is_deleted = 0
order by teh.liked_count desc

select * from comment.tt_evaluation_history teh where teh.user_id =4118303
and teh.object_id = '0Ieu70DwFF'

select * from comment.tt_evaluation_history teh where teh.mobile =18273222556
and teh.object_id = '0Ieu70DwFF'