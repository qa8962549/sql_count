-- 1、新手任务、成长任务发帖完成人数
select
date_format(a.create_time,'%Y-%m-%d') 日期,
a.member_id 会员ID,
m.member_name 会员昵称,
m.member_phone 手机号,
date_format(a.update_time,'%Y-%m-%d') 完成任务日期,
a.task_name 完成任务类型
from mine.koc_tasks_task_info a
left join "member".tc_member_info m on a.member_id = m.id and m.member_status <> 60341003 and m.is_deleted = 0
where a.update_time >= '2023-06-01'
and a.update_time <= '2023-06-15 23:59:59'
and a.task_status = 2  -- 完成任务
and a.is_delete = 0

select * from campaign.tr_campaign_sign_up a
where a.is_deleted = 0
