--4个月内，app+小程序累计登陆超过3天的
select count(distinct x.member_phone)
from 
	(
	select m.member_phone
	from ods_rawd.ods_rawd_events_d_di a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)
	where 1=1
	--and event in ('$AppViewScreen','mini-view')
	and length(a.distinct_id)<9 
	and left(a.$app_version,1)>='5'
	and a.is_bind=1
	and a.time>=date_sub(cast('2023-09-19' as date),interval 4 month)
	and a.time<'2023-09-19'
	group by m.member_phone
	HAVING count(distinct date)>3
	)x


select "464358"-"417485"