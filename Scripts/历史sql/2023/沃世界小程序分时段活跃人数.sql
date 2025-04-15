-- 沃世界小程序分时段活跃人数
select 
DATE_FORMAT(t.date,'%H'), -- 尽量准守时间格式’2022-2-2 23:59:59‘
count(DISTINCT m.id) 人数
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)  
where t.date >= '2022-2-1' and t.date < '2022-5-1' 
and m.IS_DELETED = 0
group by 1
order by 1

