-- ————————————————————————————————【私域用户表：ads_crm_events_member_d】————————————————————————————————
-- 私域用户表t+2
select
--u.user_id,
a.*
,b.is_bind as `是否绑车`,b.is_owner as `是否车主`
,c.bind_date as `最晚一次绑车时间`
,d.bind_date as `最晚一次车主绑车时间`
,CASE when e.`App最早一条记录时间` ='1970-01-01 08:00:00' then null else e.`App最早一条记录时间` end as `App最早一条记录时间`
,CASE when e.`App最晚一次活跃时间` ='1970-01-01 08:00:00' then null else e.`App最晚一次活跃时间` end as `App最晚一次活跃时间`
--,i.`time1`,h.`time1`,i.`time2`,h.`time2`
,case when h.`time1`='1970-01-01 08:00:00' then i.`time1`
	when i.`time1` is null then h.`time1`::varchar 
	when i.`time1` <= h.`time1`::varchar then i.`time1`
	else h.`time1`::varchar end as `小程序最早一次活跃时间`
,case when h.`time2`='1970-01-01 08:00:00' then i.`time2` else h.`time2`::varchar end as `小程序最晚一次活跃时间`
from
(-- 基数：把会员表的全量oneid拉出来，memberid匹配他最新注册的那个
	select m.cust_id::varchar as `distinct_id`,m.id as `memberid`,m.level_id ,m.create_time
	from
		(-- 清洗cust_id 取其对应的最新信息
		select m.cust_id,m.id,m.create_time,m.level_id,m.user_id
		,row_number() over(partition by m.cust_id order by m.create_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where m.cust_id is not null -- oneid不能空：因基层是全量的oneid
		Settings allow_experimental_window_functions = 1
		)m
	where m.rk=1
)a
--left JOIN 
--(-- 神策的users表去匹user_id
--select distinct second_id,id as user_id
--from users u 
--where second_id is not null
--)u on u.second_id=a.distinct_id
left JOIN 
(-- 清洗绑车关系表的cust_id 取对应的：是否绑车、是否车主
	select a.cust_id
	,CASE when a.is_bind>=1 then 1 else 0 end is_bind
	,CASE when a.is_owner>=1 then 1 else 0 end is_owner
	from
		(select m.cust_id,sum(a.is_bind) as is_bind,sum(a.is_owner) as is_owner
		from ods_vocm.ods_vocm_vehicle_bind_relation_cur a 
		inner join ods_memb.ods_memb_tc_member_info_cur m on m.id::varchar =a.member_id
		where a.member_id is not null and a.member_id<>''
		group by m.cust_id
		)a 
	where a.cust_id is not null 
)b on a.`distinct_id`=b.cust_id::varchar
left JOIN 
(-- 清洗绑车关系表的cust_id 取对应的：最晚一次绑车时间
	select a.cust_id,a.bind_date
	from
		(select m.cust_id,a.is_bind,a.is_owner,a.bind_date
		,row_number() over(partition by m.cust_id order by a.bind_date desc) rk
		from ods_vocm.ods_vocm_vehicle_bind_relation_cur a 
		inner join ods_memb.ods_memb_tc_member_info_cur m on m.id::varchar =a.member_id
		where a.member_id is not null and a.member_id<>''
		and a.is_bind=1 -- 绑车
		Settings allow_experimental_window_functions = 1
		)a 
	where a.rk=1
	and a.cust_id is not null 
)c on a.`distinct_id`=c.cust_id::varchar
left JOIN 
(-- 清洗绑车关系表的cust_id 取对应的：最晚一次车主绑车时间
	select a.cust_id,a.bind_date
	from
		(select m.cust_id,a.is_bind,a.is_owner,a.bind_date
		,row_number() over(partition by m.cust_id order by a.bind_date desc) rk
		from ods_vocm.ods_vocm_vehicle_bind_relation_cur a 
		inner join ods_memb.ods_memb_tc_member_info_cur m on m.id::varchar =a.member_id
		where a.member_id is not null and a.member_id<>''
		and a.is_bind=1 -- 绑车
		and a.is_owner=1 -- 车主
		Settings allow_experimental_window_functions = 1
		)a 
	where a.rk=1
	and a.cust_id is not null 
)d on a.`distinct_id`=d.cust_id::varchar
left JOIN
(-- App最早/晚一条记录时间
	SELECT a.distinct_id, min(`time`) as `App最早一条记录时间`,max(`time`) as `App最晚一次活跃时间`
	from ods_rawd.ods_rawd_events_d_di a
	where LENGTH(a.distinct_id)<9 -- 会员
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') 
	group by a.distinct_id
)e on a.distinct_id=e.distinct_id
left JOIN 
(-- 神策的Mini会员：小程序最早/晚活跃时间
	select 
	a.distinct_id, 
	MIN(a.`time`) as `time1`, 
	MAX(a.`time`) as `time2`
	from ods_rawd.ods_rawd_events_d_di a
	where LENGTH(a.distinct_id)<9 -- 会员
	and ($lib in('MiniProgram') or channel ='Mini') 
	group by a.distinct_id
)h on h.distinct_id=a.distinct_id
left join
(-- track表的Mini会员：小程序最早/晚活跃时间
	select 
	m.cust_id
	,`time1`,`time2`
	from 
	(-- track表活跃用户-仅Mini
	select t.usertag, min(`date`) as `time1`, MAX(`date`) as `time2`
	from ods_trac.ods_trac_track_cur t
	where t.`date`<'2022-07-16 10:00:00'
	group by t.usertag
	)t
	inner join 
	(-- 清洗cust_id 取其对应的最新信息
	select m.user_id,m.id,m.cust_id
	from
		(-- 按创建时间取最新,当创建时间相同时,按会员ID取最新
		select m.cust_id,m.id,m.create_time,m.level_id,m.user_id
		,row_number() over(partition by m.cust_id order by m.create_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where m.user_id is not null
		and m.cust_id is not null -- oneid不能空：因基层是全量的oneid
		Settings allow_experimental_window_functions = 1
		)m
	where m.rk=1
	)m on t.usertag =m.user_id::varchar
)i on i.cust_id::varchar=a.distinct_id




-- 私域用户表t+1：更新绑车信息
select
a.*,b.`App最早一条记录时间`,b.`App最晚一次活跃时间`,b.`小程序最早一次活跃时间`,b.`小程序最晚一条活跃时间`
from
(	select
	--u.user_id,
	a.*
	,b.is_bind as `是否绑车`,b.is_owner as `是否车主`
	,c.bind_date as `最晚一次绑车时间`
	,d.bind_date as `最晚一次车主绑车时间`
	from
	(-- 基数：把会员表的全量oneid拉出来，memberid匹配他最新注册的那个
		select m.cust_id::varchar as `distinct_id`,m.id as `memberid`,m.level_id ,m.create_time
		from
			(-- 清洗cust_id 取其对应的最新信息
			select m.cust_id,m.id,m.create_time,m.level_id,m.user_id
			,row_number() over(partition by m.cust_id order by m.create_time desc,m.id desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.cust_id is not null -- oneid不能空：因基层是全量的oneid
			Settings allow_experimental_window_functions = 1
			)m
		where m.rk=1
	)a
	--left JOIN 
	--(-- 神策的users表去匹user_id
	--select distinct second_id,id as user_id
	--from users u 
	--where second_id is not null
	--)u on u.second_id=a.distinct_id
	left JOIN 
	(-- 清洗绑车关系表的cust_id 取对应的：是否绑车、是否车主
		select a.cust_id
		,CASE when a.is_bind>=1 then 1 else 0 end is_bind
		,CASE when a.is_owner>=1 then 1 else 0 end is_owner
		from
			(select m.cust_id,sum(a.is_bind) as is_bind,sum(a.is_owner) as is_owner
			from ods_vocm.ods_vocm_vehicle_bind_relation_cur a 
			inner join ods_memb.ods_memb_tc_member_info_cur m on m.id::varchar =a.member_id
			where a.member_id is not null and a.member_id<>''
			group by m.cust_id
			)a 
		where a.cust_id is not null 
	)b on a.`distinct_id`=b.cust_id::varchar
	left JOIN 
	(-- 清洗绑车关系表的cust_id 取对应的：最晚一次绑车时间
		select a.cust_id,a.bind_date
		from
			(select m.cust_id,a.is_bind,a.is_owner,a.bind_date
			,row_number() over(partition by m.cust_id order by a.bind_date desc) rk
			from ods_vocm.ods_vocm_vehicle_bind_relation_cur a 
			inner join ods_memb.ods_memb_tc_member_info_cur m on m.id::varchar =a.member_id
			where a.member_id is not null and a.member_id<>''
			and a.is_bind=1 -- 绑车
			Settings allow_experimental_window_functions = 1
			)a 
		where a.rk=1
		and a.cust_id is not null 
	)c on a.`distinct_id`=c.cust_id::varchar
	left JOIN 
	(-- 清洗绑车关系表的cust_id 取对应的：最晚一次车主绑车时间
		select a.cust_id,a.bind_date
		from
			(select m.cust_id,a.is_bind,a.is_owner,a.bind_date
			,row_number() over(partition by m.cust_id order by a.bind_date desc) rk
			from ods_vocm.ods_vocm_vehicle_bind_relation_cur a 
			inner join ods_memb.ods_memb_tc_member_info_cur m on m.id::varchar =a.member_id
			where a.member_id is not null and a.member_id<>''
			and a.is_bind=1 -- 绑车
			and a.is_owner=1 -- 车主
			Settings allow_experimental_window_functions = 1
			)a 
		where a.rk=1
		and a.cust_id is not null 
	)d on a.`distinct_id`=d.cust_id::varchar
)a
left JOIN `私域用户表t+2` b on a.distinct_id=b.distinct_id




-- 增量
-- 私域用户表更新：昨天活跃过的历史用户的双端最早最新记录时间
select 
a.user_id,a.distinct_id,a.memberid,a.level_id,a.create_time,a.`是否绑车`,a.`是否车主`,a.`最晚一次绑车时间`,a.`最晚一次车主绑车时间`
-- 数据需更新部分
,CASE when (a.`App最早一条记录时间` is null or a.`App最早一条记录时间`>f.`App最早一条记录时间`) then f.`App最早一条记录时间` else a.`App最早一条记录时间` end as `App最早一条记录时间`
,CASE when (f.`App最晚一次活跃时间` is null or f.`App最晚一次活跃时间`<a.`App最晚一次活跃时间`) then a.`App最晚一次活跃时间` else f.`App最晚一次活跃时间` end as `App最晚一次活跃时间`
,CASE when (a.`小程序最早一次活跃时间` is null or a.`小程序最早一次活跃时间`>f.`小程序最早一次活跃时间`) then f.`小程序最早一次活跃时间` else a.`小程序最早一次活跃时间` end as `小程序最早一次活跃时间`
,CASE when (f.`小程序最晚一条活跃时间` is null or f.`小程序最晚一条活跃时间`<a.`小程序最晚一条活跃时间`) then a.`小程序最晚一条活跃时间` else f.`小程序最晚一条活跃时间` end as `小程序最晚一条活跃时间`
from
`私域用户表t+1` a
left join
(-- 最早/晚一条记录时间
	SELECT
	f.distinct_id as distinct_id
	,CASE when e.`time1` <>'1970-01-01 08:00:00' then e.`time1` else null end as `App最早一条记录时间`
	,CASE when e.`time2` <>'1970-01-01 08:00:00' then e.`time2` else null end as `App最晚一次活跃时间`
	,CASE when h.`time1` <>'1970-01-01 08:00:00' then h.`time1` else null end as `小程序最早一次活跃时间`
	,CASE when h.`time2` <>'1970-01-01 08:00:00' then h.`time2` else null end as `小程序最晚一条活跃时间`
	from
	(-- 昨日活跃用户
	SELECT distinct a.distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where LENGTH(a.distinct_id)<9 -- 会员
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
	and toDate(a.$receive_time/1000)>=yesterday() and toDate(a.$receive_time/1000)< toDate(now()) -- 昨日活跃用户信息
	)f
	left JOIN
	(-- App最早/晚一条记录时间
		SELECT a.distinct_id, min(`time`) as `time1`,max(`time`) as `time2`
		from ods_rawd.ods_rawd_events_d_di a
		where LENGTH(a.distinct_id)<9 -- 会员
		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') 
		and toDate(a.$receive_time/1000)>=yesterday() and toDate(a.$receive_time/1000)< toDate(now()) -- 昨日活跃用户信息
		group by a.distinct_id
	)e on e.distinct_id=f.distinct_id
	left JOIN 
	(-- Mini最早/晚活跃时间
		select 
		a.distinct_id, MIN(a.`time`) as `time1`,MAX(a.`time`) as `time2`
		from ods_rawd.ods_rawd_events_d_di a
		where LENGTH(a.distinct_id)<9 -- 会员
		and ($lib in('MiniProgram') or channel ='Mini') 
		and toDate(a.$receive_time/1000)>=yesterday() and toDate(a.$receive_time/1000)< toDate(now()) -- 昨日活跃用户信息
		group by a.distinct_id
	)h on h.distinct_id=f.distinct_id
)f on a.distinct_id=f.distinct_id



-- ————————————————————————————————【私域用户活跃表：ads_crm_events_active_d】————————————————————————————————
-- 私域用户活跃表: 过去的数据
-- 基数：神策+track表的全量会员:每个会员id每端每天的最后一条记录-优先车主 (2022年7月16日10点之前用track，之后用神策)
-- -------------------[神策的全量会员]-------------------
select
--u.user_id,
t.distinct_id,t.`memberid`,t.channel,t.`最后一条记录date` as `date`
,ifNull(t.is_bind,case when t.is_bind2 >=1 then 1 when t.is_bind2<1 then 0 end ) as is_bind
,case when t.is_owner >=1  then 1 when t.is_owner<1 then 0 end as is_owner
,t.`source`
from
(	select
	t.distinct_id,t.`memberid`,t.channel,t.`最后一条记录date`,t.is_bind,t.`source`
	,sum(t.is_bind2) as is_bind2,sum(t.is_owner) as is_owner
	from(-- 每个用户每天最后活跃前的所有绑车过车型 的最后一次解绑绑定时间
		select
		t.distinct_id,t.`memberid`,t.channel,t.`最后一条记录date`,t.is_bind,t.`source`
		,t.vin_code,t.`绑定解绑时间`,t.is_bind2,t.is_owner
		,row_number() over(partition by concat(t.distinct_id,t.`memberid`::varchar,t.channel,t.`最后一条记录date`,t.`source`,ifnull(t.vin_code,'')) order by t.`绑定解绑时间` desc) rk
		from
		(-- 每个用户每端每天最后活跃前的所有 车型的绑车解绑记录
			select
			t.distinct_id,t.`memberid`,t.channel,t.`最后一条记录date`,t.is_bind,t.`source`
			,case when t.`最后一条记录date`>=v.`绑定解绑时间` then v.vin_code else null end as vin_code
			,case when t.`最后一条记录date`>=v.`绑定解绑时间` then v.`绑定解绑时间` else null end as `绑定解绑时间`
			,case when t.`最后一条记录date`>=v.`绑定解绑时间` then v.`event_type` else null end as is_bind2
			,case when t.`最后一条记录date`>=v.`绑定解绑时间` then v.`is_owner` else null end as is_owner
			from
			(-- 用户每天每端 最后一次活跃记录
				select distinct
				a.distinct_id as distinct_id
				,ifNull(m.id,0) as `memberid`--,m.level_id as `会员等级`,m.create_time as `会员注册时间` 
				,a.channel as channel
				,case when (a.is_bind<>1 or a.is_bind is null) and c.is_bind=1 then c.`time`::varchar 
					when a.is_bind is null and c2.is_bind is not null then c2.`time`::varchar else a.`time`::varchar end as `最后一条记录date`
				,case when (a.is_bind<>1 or a.is_bind is null) and c.is_bind=1 then c.is_bind 
					when a.is_bind is null and c2.is_bind is not null then c2.is_bind else a.is_bind end as is_bind
				,'events' as `source`
				from
				(-- 神策的用户活跃记录：清洗神策的distinct_id、端口、每天： 取对应的最新数据
					select a.distinct_id,a.`date`,a.`time`,a.channel,a.is_bind--, a.user_id 
					from
						(SELECT a.distinct_id, a.user_id ,a.`date`,a.`time`,a.is_bind
						,case when (($lib in('MiniProgram') or channel ='Mini') and a.`time` >='2022-07-16 10:00:00' ) then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end as channel
						,row_number() over(partition by concat(a.distinct_id,a.`date`::varchar,case when ($lib in('MiniProgram') or channel ='Mini') then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end) order by a.`time` desc) rk
						from ods_rawd.ods_rawd_events_d_di a
						where LENGTH(a.distinct_id)<9 -- 会员
						and ( (($lib in('MiniProgram') or channel ='Mini') and a.`time` >='2022-07-16 10:00:00' ) or (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') )
						Settings allow_experimental_window_functions = 1
						)a
					where a.rk=1
				)a
				left JOIN 
				(-- 神策的[车主]用户活跃记录：清洗神策的distinct_id、端口、每天： 取对应的最新数据
					select a.distinct_id,a.`date`,a.`time`,a.channel,a.is_bind--, a.user_id 
					from
						(SELECT a.distinct_id, a.user_id ,a.`date`,a.`time`,a.is_bind
						,case when (($lib in('MiniProgram') or channel ='Mini') and a.`time` >='2022-07-16 10:00:00' ) then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end as channel
						,row_number() over(partition by concat(a.distinct_id,a.`date`::varchar,case when ($lib in('MiniProgram') or channel ='Mini') then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end) order by a.`time` desc) rk
						from ods_rawd.ods_rawd_events_d_di a
						where LENGTH(a.distinct_id)<9 -- 会员
						and ( (($lib in('MiniProgram') or channel ='Mini') and a.`time` >='2022-07-16 10:00:00' ) or (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') )
						and a.is_bind=1 -- 车主
						Settings allow_experimental_window_functions = 1
						)a
					where a.rk=1
				)c on a.distinct_id=c.distinct_id and a.`date`=c.`date` and a.channel=c.channel
				left JOIN 
				(-- 神策的[is_bind不为空]用户活跃记录：清洗神策的distinct_id、端口、每天： 取对应的最新数据
					select a.distinct_id,a.`date`,a.`time`,a.channel,a.is_bind--, a.user_id 
					from
						(SELECT a.distinct_id, a.user_id ,a.`date`,a.`time`,a.is_bind
						,case when (($lib in('MiniProgram') or channel ='Mini') and a.`time` >='2022-07-16 10:00:00' ) then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end as channel
						,row_number() over(partition by concat(a.distinct_id,a.`date`::varchar,case when ($lib in('MiniProgram') or channel ='Mini') then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end) order by a.`time` desc) rk
						from ods_rawd.ods_rawd_events_d_di a
						where LENGTH(a.distinct_id)<9 -- 会员
						and ( (($lib in('MiniProgram') or channel ='Mini') and a.`time` >='2022-07-16 10:00:00' ) or (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') )
						and a.is_bind is not null
						Settings allow_experimental_window_functions = 1
						)a
					where a.rk=1
				)c2 on a.distinct_id=c2.distinct_id and a.`date`=c2.`date` and a.channel=c2.channel
				inner JOIN 
				(-- 清洗cust_id 取其对应的最新信息
					select m.cust_id,m.id,m.level_id,m.create_time 
					from
						(-- 按创建时间取最新,当创建时间相同时,按会员ID取最新
						select m.cust_id,m.id,m.create_time,m.level_id,m.user_id
						,row_number() over(partition by m.cust_id order by m.create_time desc,m.id desc) rk
						from ods_memb.ods_memb_tc_member_info_cur m
						where m.cust_id is not null -- oneid不能空：因基层是全量的oneid
						Settings allow_experimental_window_functions = 1
						)m
					where m.rk=1
				)m on a.distinct_id =m.cust_id::varchar
			)t
			left join
			(-- 绑车记录：绑车流水表
				select
				m.cust_id ,a.vin_code,
				a.date_create as `绑定解绑时间`,
				a.event_type::int as event_type,a.is_owner
				FROM ods_vocm.ods_vocm_vehicle_bind_record_d a -- 绑定流水表
				inner join ods_memb.ods_memb_tc_member_info_cur m on m.id::varchar =a.member_id
				where a.deleted = 0 and a.member_id <>''
			)v on t.distinct_id=toString(v.cust_id)
		)t 
		Settings allow_experimental_window_functions = 1
	)t
	where t.rk=1
	group by t.distinct_id,t.`memberid`,t.channel,t.`最后一条记录date`,t.is_bind,t.`source`
)t
--left JOIN 
--(-- 神策的users表去匹user_id
--select distinct second_id,id as user_id
--from users u 
--where second_id is not null
--)u on u.second_id=t.distinct_id
UNION ALL
-- -------------------[track表的全量会员]-------------------
select
--u.user_id,
t.`distinct_id`,t.`memberid`,t.channel,t.`最后一条记录date` as `date`
,case when is_bind >=1 then 1 when is_bind<1 then 0 end as is_bind
,case when is_owner >=1  then 1 when is_owner<1 then 0 end as is_owner
,t.`source`
from
(	select
	t.`distinct_id`,t.`memberid`,t.channel,t.`最后一条记录date`,t.`source`
	,sum(t.is_bind) as is_bind,sum(t.is_owner) as is_owner
	from
		(-- 每个用户每天最后活跃前的所有绑车过车型 的最后一次解绑绑定时间
		select
		t.`distinct_id`,t.`memberid`,t.channel,t.`最后一条记录date`,t.`source`
		,t.vin_code,t.`绑定解绑时间`,t.is_bind,t.is_owner
		,row_number() over(partition by concat(t.`distinct_id`,t.`memberid`::varchar,t.channel,t.`最后一条记录date`::varchar,t.`source`,ifnull(t.vin_code,'')) order by t.`绑定解绑时间` desc) rk
		from
			(-- 每个用户每天最后活跃前的所有 车型的绑车解绑记录
			select
			t.`distinct_id`,t.`memberid`,t.channel,t.`最后一条记录date`,t.`source`
			,case when t.`最后一条记录date`>=v.`绑定解绑时间` then v.vin_code else null end as vin_code
			,case when t.`最后一条记录date`>=v.`绑定解绑时间` then v.`绑定解绑时间` else null end as `绑定解绑时间`
			,case when t.`最后一条记录date`>=v.`绑定解绑时间` then v.`event_type` else null end as is_bind
			,case when t.`最后一条记录date`>=v.`绑定解绑时间` then v.`is_owner` else null end as is_owner
			from
			(-- track表的会员信息：用户每天最后一条记录
				select m.`distinct_id`::varchar as `distinct_id`
				,m.id as `memberid`--,m.level_id,m.create_time
				,'Mini' as channel
				,t.`最后一条记录date`
				,'track' as `source`
				from 
				(-- track表活跃用户-仅Mini
				select t.usertag,Date(t.`date`),max(t.`date`) as `最后一条记录date`
				from ods_trac.ods_trac_track_cur t
				where t.`date`<'2022-07-16 10:00:00'
				group by t.usertag,Date(t.`date`)
				)t
				inner join 
				(-- 清洗cust_id 取其对应的最新信息
				select m.user_id,m.id,m.cust_id as `distinct_id`
				from
					(-- 按创建时间取最新,当创建时间相同时,按会员ID取最新
					select m.cust_id,m.id,m.create_time,m.level_id,m.user_id
					,row_number() over(partition by m.cust_id order by m.create_time desc,m.id desc) rk
					from ods_memb.ods_memb_tc_member_info_cur m
					where m.user_id is not null
					and m.cust_id is not null -- oneid不能空：因基层是全量的oneid
					Settings allow_experimental_window_functions = 1
					)m
				where m.rk=1
				)m on t.usertag =m.user_id::varchar
			)t
			left join
			(-- 绑车记录：绑车流水表
				select
				m.cust_id ,a.vin_code,
				a.date_create as `绑定解绑时间`,
				a.event_type::int as event_type,a.is_owner
				FROM ods_vocm.ods_vocm_vehicle_bind_record_d a -- 绑定流水表
				inner join ods_memb.ods_memb_tc_member_info_cur m on m.id::varchar =a.member_id
				where a.deleted = 0 and a.member_id <>''
			)v on t.`distinct_id`=toString(v.cust_id)
			)t
		Settings allow_experimental_window_functions = 1
		)t where t.rk=1
	group by t.`distinct_id`,t.`memberid`,t.channel,t.`最后一条记录date`,t.`source`
)t
--left JOIN 
--(-- 神策的users表去匹user_id
--select distinct second_id,id as user_id
--from users u 
--where second_id is not null
--)u on u.second_id=t.`distinct_id`





-- 私域用户活跃表：增量
select
--u.user_id,
t.distinct_id,t.`memberid`,t.channel,t.`最后一条记录date`
,case when t.is_bind is null then v1.is_bind1 else t.is_bind end as is_bind
,case when t.is_bind=1 and v1.is_bind1=0 then v0.is_owner0
	when t.is_bind=1 and v1.is_bind1=1 then v1.is_owner1
	when t.is_bind=0 then 0
	when t.is_bind is null then v1.is_owner1 end is_owner
,t.`source`
from
(-- 用户每天每端 最后一次活跃记录
	select distinct
	a.distinct_id as distinct_id
	,ifNull(m.id,0) as `memberid`--,m.level_id as `会员等级`,m.create_time as `会员注册时间` 
	,a.channel as channel
	,case when a.is_bind<>1 and c.is_bind=1 then c.`time`::varchar 
		when a.is_bind is null and c2.is_bind is not null then c2.`time`::varchar else a.`time`::varchar end as `最后一条记录date`
	,case when a.is_bind<>1 and c.is_bind=1 then c.is_bind 
		when a.is_bind is null and c2.is_bind is not null then c2.is_bind else a.is_bind end as is_bind
	,'events' as `source`
	from
	(-- 神策的用户活跃记录：清洗神策的distinct_id、端口、每天： 取对应的最新数据
		select a.distinct_id,a.`date`,a.`time`,a.channel,a.is_bind--, a.user_id 
		from
			(SELECT a.distinct_id, a.user_id ,a.`date`,a.`time`,a.is_bind
			,case when ($lib in('MiniProgram') or channel ='Mini') then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end as channel
			,row_number() over(partition by concat(a.distinct_id,a.`date`::varchar,case when ($lib in('MiniProgram') or channel ='Mini') then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end) order by a.`time` desc) rk
			from ods_rawd.ods_rawd_events_d_di a
			where LENGTH(a.distinct_id)<9 -- 会员
			and a.`time` >= yesterday()
			and ( ($lib in('MiniProgram') or channel ='Mini') or (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') )
			Settings allow_experimental_window_functions = 1
			)a
		where a.rk=1
	)a
	left JOIN 
	(-- 神策的[车主]用户活跃记录：清洗神策的distinct_id、端口、每天： 取对应的最新数据
		select a.distinct_id,a.`date`,a.`time`,a.channel,a.is_bind--, a.user_id 
		from
			(SELECT a.distinct_id, a.user_id ,a.`date`,a.`time`,a.is_bind
			,case when ($lib in('MiniProgram') or channel ='Mini') then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end as channel
			,row_number() over(partition by concat(a.distinct_id,a.`date`::varchar,case when ($lib in('MiniProgram') or channel ='Mini') then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end) order by a.`time` desc) rk
			from ods_rawd.ods_rawd_events_d_di a
			where LENGTH(a.distinct_id)<9 -- 会员
			and a.`time` >= yesterday()
			and ( ($lib in('MiniProgram') or channel ='Mini') or (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') )
			and a.is_bind=1 -- 车主
			Settings allow_experimental_window_functions = 1
			)a
		where a.rk=1
	)c on a.distinct_id=c.distinct_id and a.`date`=c.`date` and a.channel=c.channel
	left JOIN 
	(-- 神策的[is_bind不为空]用户活跃记录：清洗神策的distinct_id、端口、每天： 取对应的最新数据
		select a.distinct_id,a.`date`,a.`time`,a.channel,a.is_bind--, a.user_id 
		from
			(SELECT a.distinct_id, a.user_id ,a.`date`,a.`time`,a.is_bind
			,case when ($lib in('MiniProgram') or channel ='Mini') then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end as channel
			,row_number() over(partition by concat(a.distinct_id,a.`date`::varchar,case when ($lib in('MiniProgram') or channel ='Mini') then 'Mini' when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App' end) order by a.`time` desc) rk
			from ods_rawd.ods_rawd_events_d_di a
			where LENGTH(a.distinct_id)<9 -- 会员
			and a.`time` >= yesterday()
			and ( ($lib in('MiniProgram') or channel ='Mini') or (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') )
			and a.is_bind is not null
			Settings allow_experimental_window_functions = 1
			)a
		where a.rk=1
	)c2 on a.distinct_id=c2.distinct_id and a.`date`=c2.`date` and a.channel=c2.channel
	inner JOIN 
	(-- 清洗cust_id 取其对应的最新信息
		select m.cust_id,m.id as id,m.level_id,m.create_time 
		from
			(-- 按创建时间取最新,当创建时间相同时,按会员ID取最新
			select m.cust_id,m.id,m.create_time,m.level_id,m.user_id
			,row_number() over(partition by m.cust_id order by m.create_time desc,m.id desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.cust_id is not null -- oneid不能空：因基层是全量的oneid
			Settings allow_experimental_window_functions = 1
			)m
		where m.rk=1
	)m on a.distinct_id =m.cust_id::varchar
)t
--left JOIN 
--(-- 神策的users表去匹user_id
--select distinct second_id,id as user_id
--from users u 
--where second_id is not null
--)u on u.second_id=t.distinct_id
left JOIN 
(-- 【旧的】绑车关系表
	select 
	a.cust_id
	,case when a.is_bind>=1 then 1 else 0 end as is_bind0 -- 用户只要有一辆车绑车，就算绑车用户
	,case when a.is_owner>=1 then 1 else 0 end as is_owner0 -- 用户只要有一辆车是车主身份，就算车主用户
	from
		(select m.cust_id,SUM(a.is_bind) as is_bind,SUM(a.is_owner) as is_owner
		from ods_vocm.ods_vocm_vehicle_bind_relation_cur_before a 
		inner join ods_memb.ods_memb_tc_member_info_cur m on m.id::varchar =a.member_id
		where a.member_id is not null and a.member_id<>''
		group by m.cust_id
		)a
)v0 on t.distinct_id=v0.cust_id::varchar
left JOIN 
(-- 【实时】绑车关系表
	select 
	a.cust_id
	,case when a.is_bind>=1 then 1 else 0 end as is_bind1 -- 用户只要有一辆车绑车，就算绑车用户
	,case when a.is_owner>=1 then 1 else 0 end as is_owner1 -- 用户只要有一辆车是车主身份，就算车主用户
	from
		(select m.cust_id,SUM(a.is_bind) as is_bind,SUM(a.is_owner) as is_owner
		from ods_vocm.ods_vocm_vehicle_bind_relation_cur a 
		inner join ods_memb.ods_memb_tc_member_info_cur m on m.id::varchar =a.member_id
		where a.member_id is not null and a.member_id<>''
		group by m.cust_id
		)a
)v1 on t.distinct_id=v1.cust_id::varchar