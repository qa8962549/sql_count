


select DATE_FORMAT(t.date,'%Y-%m') 月份,
count(DISTINCT t.usertag)
from track.track t
left join(
	#清洗user_id
	select m.*
	from (
	select m.id,m.USER_ID,m.IS_VEHICLE,m.create_time
	,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
	from member.tc_member_info m
	where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003 -- 排除黑名单
	) m
	where m.rk=1
)m on CAST(m.user_id AS varchar)=t.usertag
where t.date >= '2022-01-01' and t.date < '2022-07-01' 
and json_extract(t.`data`,'$.embeddedpoint') = 'MINE_CLICK_FANS' 
group by 1
order by 1