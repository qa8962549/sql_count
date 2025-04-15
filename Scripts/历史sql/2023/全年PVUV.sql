select 
count(1) PV
from track.track t
-- join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
where t.date>='2022-01-10' and t.date <= '2022-12-07 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint')='北京新能源_首页_ONLOAD' 

select 
count(1) PV
from track.track t
-- join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
where t.date>='2022-5-25' and t.date <= '2022-12-07 23:59:59'
-- and t.typeid in ('XWSJXCX_OLD_NEW_ONLOAD_C','XWSJXCX_OLD_NEW_LZONLOAD_C','XWSJXCX_TJG_FCZ_V')
and json_extract(t.`data`,'$.embeddedpoint') in ('三周年_预热页_ONLOAD','三周年_进行页_ONLOAD','三周年_发酵页_ONLOAD')



-- pageid PVUV	 
select sum(case when o.type='VIEW' then 1 else 0 end)  PV
	from 'cms-center'.cms_operate_log o
	left join (
			select mm.id,mm.user_id,mm.is_vehicle
			from (
			select m.user_id,max(m.id) mid
			from member.tc_member_info m 
			where m.is_deleted=0 and m.member_status<>60341003
			GROUP BY 1  ) m
			LEFT JOIN member.tc_member_info mm on mm.id=m.mid
	)m on m.user_id=o.user_id
	where o.type ='VIEW'
	and date_create <='2022-12-07 23:59:59' and date_create >='2022-01-01'
	and o.ref_id in ('4l8s8HGtUx',
'BNcZFsegGZ',
'u8MVrj0kdw',
'CjQREOxeZ3',
'dfe42Y2dvd'
)	

select sum(case when o.type='VIEW' then 1 else 0 end)  PV
	from 'cms-center'.cms_operate_log o
	left join (
			select mm.id,mm.user_id,mm.is_vehicle
			from (
			select m.user_id,max(m.id) mid
			from member.tc_member_info m 
			where m.is_deleted=0 and m.member_status<>60341003
			GROUP BY 1  ) m
			LEFT JOIN member.tc_member_info mm on mm.id=m.mid
	)m on m.user_id=o.user_id
	where o.type ='VIEW'
	and date_create <='2022-12-07 23:59:59' and date_create >='2022-01-01'
	and o.ref_id ='Wlw7p6yt2B'
	
-- PV UV
select 
COUNT(t.usertag) PV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-08-01 00:00:00' and t.`date` <= '2022-08-31 23:59:59'
and t.`data` like '%7FFF588EA0904E918B326E5271CDF2D8%'