-- 签到

### 活动数据明细

-- 当月签到人数
select DATE_FORMAT(i.create_time,'%Y-%m') 月份
,count(DISTINCT i.member_id) 签到人数
,count(DISTINCT case when m.IS_VEHICLE=1 then i.member_id else null end) 当月签到车主
,count(DISTINCT case when m.IS_VEHICLE=0 then i.member_id else null end) 当月签到粉丝
from mine.sign_info i 
left join member.tc_member_info m on i.member_id=m.ID
where i.is_delete=0
and i.create_time >='2022-01-01' 
and i.create_time <='2022-07-31 23:59:59'
GROUP BY 1　order by 1 ;

-- 入口PV&UV
	SELECT DATE_FORMAT(t.date,'%Y-%m') 月份,
	COUNT(DISTINCT case when tmi.IS_VEHICLE =0 then tmi.id else null end) 粉丝活动UV,
	COUNT(DISTINCT case when tmi.IS_VEHICLE =1 then tmi.id else null end) 车主活动UV
	from track.track t 
	join `member`.tc_member_info tmi on CAST(tmi.USER_ID as varchar)=t.usertag and tmi.IS_DELETED =0 and tmi.STATUS <>60341003
	where t.date between '2022-01-01' and '2022-07-31 23:59:59'
	and json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_SHOUYE_ONLOAD'
	group by 1
	order by 1
	

