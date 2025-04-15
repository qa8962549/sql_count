-- 有抽奖机会但没有抽奖的人，1级奖池抽奖机会仅有7天有效期
select
distinct b.MEMBER_PHONE 沃世界注册手机号
from mine.sign_lottery_chance_info a
left join `member`.tc_member_info b on a.member_id = b.ID
where a.lottery_play_code = 'signLv1'   -- 1级奖池
and a.create_time >= '2022-06-01'  -- 签到2.0活动开始时间
and a.create_time <= '2022-06-10 10:30:00'
and a.use_status = 0   -- 0未使用1已使用2已过期
and a.is_delete = 0  -- 有效