-- PV UV
select case when t.`data` like '%75FE95B75A7E435E8DDF9A7459A06A91%' then '01 每日签到（车主版）'
	when t.`data` like '%A3CF74ABE7714DD5870A6740E97A05F1%' then '02 养修预约'
	when t.`data` like '%405DA9BC0D594D62A9D4D47F2B7BBCC2%' then '03 充电地图'
	when t.`data` like '%FEC7DB302EAE4F4DB2A26CD9CC50F4F4%' then '04 每日签到（粉丝版）'	
	when t.`data` like '%CD71CAFD7AEF48EB8035F7CE1CE6514C%' then '05 试驾享礼'	
	when t.`data` like '%62E1C5DDDCA44099A857C880D1D8FE14%' then '06 官方直售（车主版）'	
	when t.`data` like '%D9F31C45140845D3B58D7C3E61455180%' then '07 官方直售（粉丝版）'
else null end 分类,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-06-01' and t.`date` < '2022-07-01'
group by 1
order by 1