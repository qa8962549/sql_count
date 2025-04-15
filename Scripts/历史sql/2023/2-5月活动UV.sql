
### 2月度活动参与总人数 

select DISTINCT m.id,m.is_vehicle
from (
	select DISTINCT '2' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date >= '2022-02-11 00:00:00' and t.date < '2022-03-01' 
	and json_extract(t.`data`,'$.embeddedpoint')='C40YUSHOU_C40ZHONGCHOU_ONLOAD' 
	union ALL 
	select DISTINCT '2' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date >= '2022-02-01' and t.date < '2022-03-01' 
	and json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_SHOUYE_ONLOAD' 
	union ALL 
	select DISTINCT '2' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date>='2022-02-01' AND t.date<'2022-02-07'
	and json_extract(t.`data`,'$.embeddedpoint')='春节不打烊_onload活动首页_ONLOAD' 
	union all
	select DISTINCT '2' 活动,'1' 分组, t.usertag
	from track.track t
	where DATE(t.date)='2022-02-25'
	and json_extract(t.`data`,'$.embeddedpoint') = 'memberDay2_home_onload'
	union all
	select DISTINCT '4' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-02-15 17:55:16' and date_create <'2022-03-01'  
	and o.ref_id='57cFb7k2sD'
	union all
	select DISTINCT '2' 活动,'1' 分组, t.usertag
	from track.track t
	where t.`date` >= '2022-02-01' and t.`date` < '2022-03-01'
	and json_extract(t.data,'$.path') =  '/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Fdeal-package%2Fowner_story%2Findex' or t.`data` like '%C5CB1FAB5BA549D4BCB8AA0CDDBF671A%' or t.`data` like '%A696862BE0F541F2BB2CFEF90ECBC198%'
	union all
	select DISTINCT '3' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-02-22 19:27:00' and date_create <'2022-03-01' 
	and o.ref_id='7IwzJMAPup' 
	union all 
	select DISTINCT '4' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-02-15 19:21:00' and date_create <'2022-03-01'  
	and o.ref_id='m78ajiHetR'
	union all 
	select DISTINCT '8' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-02-10 11:48:00' and date_create <'2022-03-01'
	and o.ref_id='S0AVYdYP3y'
	union all 
	select DISTINCT '8' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-02-21' and date_create <'2022-03-01'
	and o.ref_id='bHgj1CP6oN'
	union all
	select DISTINCT '8' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-02-01' and date_create <'2022-02-16'
	and o.ref_id='7Z8QiluAsJ'
	union all
	select DISTINCT '8' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-02-01' and date_create <'2022-03-01'
	and o.ref_id='cGa0NCD2PP'
	union all
	select DISTINCT '9' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date>='2022-02-12 12:00:00' AND t.date<'2022-02-16 23:59:59' 
	and json_extract(t.`data`,'$.onLoad')='双节_进入活动'
	) a
left join (
		select mm.id,mm.user_id,mm.is_vehicle
		from (
		select m.user_id,max(m.id) mid
		from member.tc_member_info m 
		where m.is_deleted=0 and m.member_status<>60341003
		-- and m.CREATE_TIME >='2022-02-01' and m.CREATE_TIME <= '2022-02-28 23:59:59' -- 在月注册会员
		GROUP BY 1  ) m
		LEFT JOIN member.tc_member_info mm on mm.id=m.mid
)m on a.usertag=CAST(m.user_id AS VARCHAR) 
-- where ifnull(m.is_vehicle,0)=1 -- 车主
 -- m.is_vehicle=0 -- 粉丝
GROUP BY 1 with rollup 
order by 1 desc 


### 3月度活动参与总人数(去重+分组)

select DISTINCT m.id,m.is_vehicle
from (
	select DISTINCT '2' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date >= '2022-03-21 00:00:00' and t.date < '2022-04-01' 
	and json_extract(t.`data`,'$.embeddedpoint')='先心儿童_home_ONLOAD'
	union ALL 
	select DISTINCT '2' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date >= '2022-03-01 00:00:00' and t.date < '2022-04-01' 
	and json_extract(t.`data`,'$.embeddedpoint')='别赶路_首页_onload_'
	union ALL 
	select DISTINCT '1' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-03-01' and date_create <'2022-04-01' 
	and o.ref_id='cNuav6q4we' 
	union all 
	select DISTINCT '3' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-03-24 15:57:00' and date_create <'2022-04-01' 
	and o.ref_id='u0e0KqM1D8' 
	union all 
	select DISTINCT '4' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-03-18 19:40:01' and date_create <'2022-04-01'  
	and o.ref_id='r0sNb2IRhn'
	union all 
	select DISTINCT '8' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-03-08 18:16:00' and date_create <'2022-04-01'
	and o.ref_id='mH6tDffSAz'
	union all 
	select DISTINCT '8' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-03-16 12:14:44' and date_create <'2022-04-01'
	and o.ref_id='8OaYDI10LN'
	union all
	select DISTINCT '8' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-03-18 12:26:36' and date_create <'2022-04-01'
	and o.ref_id='mbaMDNtwh5'
	union all
	select DISTINCT '8' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-03-21 11:37:45' and date_create <'2022-04-01'
	and o.ref_id='9RuIcPRsgf'
	union all
	select DISTINCT '8' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-03-15 16:47:18' and date_create <'2022-04-01'
	and o.ref_id='ireQc6ugCG'
	union all
	select DISTINCT '9' 活动,'1' 分组, t.usertag
	from track.track t
	where DATE(t.date)='2022-03-25' 
	and json_extract(t.`data`,'$.embeddedpoint') = 'memberDay3_home_onload'
) a
left join (
		select mm.id,mm.user_id,mm.is_vehicle
		from (
		select m.user_id,max(m.id) mid
		from member.tc_member_info m 
		where m.is_deleted=0 and m.member_status<>60341003
		-- and m.CREATE_TIME >='2022-03-01' and m.CREATE_TIME <= '2022-03-30 23:59:59' -- 在月注册会员
		GROUP BY 1  ) m
		LEFT JOIN member.tc_member_info mm on mm.id=m.mid
)m on a.usertag=CAST(m.user_id AS VARCHAR) 
-- where ifnull(m.is_vehicle,0)=1 -- 车主
 -- m.is_vehicle=0 -- 粉丝
GROUP BY 1 with rollup 
order by 1 desc 

### 4月度活动参与总人数(去重+分组)

select DISTINCT m.id,m.is_vehicle
from ( 
	select DISTINCT '1' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-04-13' and date_create <'2022-05-01' 
	and o.ref_id='l3uIuK8etQ'  
	union all 
	select DISTINCT '2' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date >= '2022-04-15' and t.date < '2022-05-01' 
	and json_extract(t.`data`,'$.embeddedpoint') = 'CHEZHUGUSHI_HOME_ONLOAD'
	union all
	select DISTINCT '3' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-04-15' and date_create <'2022-05-01' 
	and o.ref_id='C3uwSMsuKQ' 
	union all 
	select DISTINCT '4' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-04-18' and date_create <'2022-05-01' 
	and o.ref_id='AT82CIgMPs'
	union all 
	select DISTINCT '5' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date >= '2022-04-25' and t.date < '2022-04-26' 
	and json_extract(t.`data`,'$.embeddedpoint') = 'memberDay4_home_onload'
	union all 
	select DISTINCT '6' 活动,'2' 分组, t.usertag
	from track.track t
	where t.date >= '2022-04-29' and t.date < '2022-05-01' 
	and json_extract(t.`data`,'$.embeddedpoint') = 'QIANDAO_SHOUYE_ONLOAD'
	union all 
	select DISTINCT '7' 活动,'2' 分组, t.usertag
	from track.track t
	where t.date >= '2022-04-14' and t.date < '2022-05-01' 
	and json_extract(t.`data`,'$.embeddedpoint') = 'C40YUSHOU_C40ZHONGCHOU_ONLOAD'
	union all 
	select DISTINCT '8' 活动,'1' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-04-25' and date_create <'2022-05-01' 
	and o.ref_id='1SeYuMXzCS'
	union all 
	select DISTINCT '9' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date >= '2022-04-09' and t.date < '2022-05-01' 
	and json_extract(t.`data`,'$.embeddedpoint') = 'KOCSPECIALAREA_SHOUYEISKOC_ONLOAD'
	union all 
	select DISTINCT '10' 活动,'2' 分组, t.usertag
	from track.track t
	where t.date >= '2022-04-01' and t.date < '2022-04-29' 
	and json_extract(t.`data`,'$.embeddedpoint') = 'QIANDAO_SHOUYE_ONLOAD'
) a
left join (
		select mm.id,mm.user_id,mm.is_vehicle
		from (
		select m.user_id,max(m.id) mid
		from member.tc_member_info m 
		where m.is_deleted=0 and m.member_status<>60341003
		-- and m.CREATE_TIME >='2022-04-01' and m.CREATE_TIME <= '2022-04-30 23:59:59' -- 在月注册会员
		GROUP BY 1  ) m
		LEFT JOIN member.tc_member_info mm on mm.id=m.mid
)m on a.usertag=CAST(m.user_id AS VARCHAR) 
-- where ifnull(m.is_vehicle,0)=1 -- 车主
 -- m.is_vehicle=0 -- 粉丝
GROUP BY 1 with rollup; 

### 5月度活动参与总人数(去重+分组)

select DISTINCT m.id,m.is_vehicle
from ( 
	select DISTINCT '1' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date >= '2022-05-19' and t.date < '2022-05-31' 
	and json_extract(t.`data`,'$.embeddedpoint') in('collectionPage_home_预热_click','collectionPage_home_正式_click')
	union all 
	select DISTINCT '2' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date >= '2022-05-01' and t.date < '2022-06-01' 
	and json_extract(t.`data`,'$.embeddedpoint') = 'QIANDAO_SHOUYE_ONLOAD'
	union all 
	select DISTINCT '3' 活动,'2' 分组, t.usertag
	from track.track t
	where t.date >= '2022-05-01' and t.date < '2022-06-01' 
	and json_extract(t.`data`,'$.embeddedpoint') = 'CHEZHUGUSHI_HOME_ONLOAD'
	union all 
	select DISTINCT '4' 活动,'2' 分组, t.usertag
	from track.track t
	where t.date >= '2022-05-01' and t.date < '2022-06-01' 
	and json_extract(t.`data`,'$.embeddedpoint') = '别赶路_首页_onload_'
	union all 
	select DISTINCT '5' 活动,'2' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-05-15' and date_create <'2022-06-01' 
	and o.ref_id='mNMJ3Su0Vt' 
	union all 
	select DISTINCT '6' 活动,'2' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-05-15' and date_create <'2022-06-01' 
	and o.ref_id='mNMJ3Su0Vt' 
	union all 
	select DISTINCT '7' 活动,'2' 分组,cast(o.user_id as varchar) usertag
	from 'cms-center'.cms_operate_log o
	where o.type = 'VIEW'
	and date_create >='2022-05-20' and date_create <'2022-06-01' 
	and o.ref_id='ktgB0ySwBb'  
	union all 
	select DISTINCT '8' 活动,'1' 分组, t.usertag
	from track.track t
	where t.date >= '2022-05-25' and t.date < '2022-06-01' 
	and json_extract(t.`data`,'$.embeddedpoint') = '525owner2022_home_ONLOAD'
	union all 
	select DISTINCT '9' 活动,'2' 分组, t.usertag
	from track.track t
	where t.date >= '2022-05-25' and t.date < '2022-05-26' 
	and json_extract(t.`data`,'$.embeddedpoint') = 'memberDay5_home_onload'
) a
left join (
		select mm.id,mm.user_id,mm.is_vehicle
		from (
		select m.user_id,max(m.id) mid
		from member.tc_member_info m 
		where m.is_deleted=0 and m.member_status<>60341003
		-- and m.CREATE_TIME >='2022-05-01' and m.CREATE_TIME <= '2022-05-31 23:59:59' -- 在月注册会员
		GROUP BY 1  ) m
		LEFT JOIN member.tc_member_info mm on mm.id=m.mid
)m on a.usertag=CAST(m.user_id AS VARCHAR) 
-- where -- ifnull(m.is_vehicle,0)=1
-- m.is_vehicle=0 -- 粉丝
GROUP BY 1 with rollup 
order by 1 desc 