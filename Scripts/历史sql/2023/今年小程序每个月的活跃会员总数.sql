-- 今年小程序每个月的活跃会员总数
select 
DATE_FORMAT(t.date,'%Y-%m') 月份,
count(distinct tmi.id) 活跃会员人数
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 
where t.`date` >= '2022-01-01'   -- 时间自行修改
and t.date<'2022-08-01'
and t.date > tmi.member_time
group by 1 with rollup
order by 1
