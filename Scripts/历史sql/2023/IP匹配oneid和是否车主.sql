-- 根据ip匹配oneid
select DISTINCT SUBSTRING_INDEX(json_extract(t.data,'$.ip'),'"',2) ip,
m.CUST_ID oneid,
case when m.IS_VEHICLE = '1' then '车主'
	when m.IS_VEHICLE = '0' then '粉丝'
	end 是否车主
from track.track t 
left join `member`.tc_member_info m on cast(m.USER_ID as varchar)=t.usertag 
where m.is_deleted = 0 and m.member_status <> '60341003'