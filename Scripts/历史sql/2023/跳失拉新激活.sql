--每天页面跳失率（之访问了主页后离开）
SELECT 
a.date,
a.page_title,
count(distinct a.gio_id) view_UV,
count(distinct x.gio_id) btn_UV,
1-count(distinct x.gio_id)/count(distinct a.gio_id) `跳失率`
from 
	(
-- 浏览用户	
	select 
	distinct gio_id,
	date,
	page_title,
	toDateTime(left(time,19)) t
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event='Page_entry'
	and var_activity_name='2024年5月525车主节'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title in(
	'525车主节·售后惠聚',
	'525车主节',
	'525车主节·会员权益',
	'525车主节·精品好物',
	'525车主节·商城礼券',
	'525车主节·沃尔沃EX30猩朋友见面会')
)a 
left join 
	(
-- 筛选出浏览后5分钟内有点击行为的用户
	select 
	distinct a.gio_id,
	date,
	page_title
	from dwd_23.dwd_23_gio_tracking a
	join 
		(SELECT 
		distinct gio_id,
		page_title,
		date,
		toDateTime(left(time,19)) t
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and date >='2024-05-15'
		and date <'2024-06-01'
		and event ='Button_click'
		and var_activity_name='2024年5月525车主节'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		and page_title in(
		'525车主节·售后惠聚',
		'525车主节',
		'525车主节·会员权益',
		'525车主节·精品好物',
		'525车主节·商城礼券',
		'525车主节·沃尔沃EX30猩朋友见面会')
		)x on x.gio_id=a.gio_id and x.date=a.date and x.page_title=a.page_title
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event='Page_entry'
	and var_activity_name='2024年5月525车主节'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title in(
	'525车主节·售后惠聚',
	'525车主节',
	'525车主节·会员权益',
	'525车主节·精品好物',
	'525车主节·商城礼券',
	'525车主节·沃尔沃EX30猩朋友见面会')
	and date_diff('minute',toDateTime(left(a.time,19)),x.t)<5 -- 浏览和点击在5分钟以内
)x on x.gio_id=a.gio_id and x.date=a.date and x.page_title=a.page_title
group by 1,2
order by 1,2

--私域跳失率
SELECT 
count(distinct a.gio_id) view_UV,
count(distinct x.gio_id) btn_UV,
1-count(distinct x.gio_id)/count(distinct a.gio_id) `跳失率`
from 
	(
-- 浏览用户	
	select 
	distinct gio_id,
	date,
	page_title,
	toDateTime(left(time,19)) t
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event='Page_entry'
--	and var_activity_name='2024年5月525车主节'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
--	and page_title ='525车主节·会员权益'
)a 
left join 
	(
-- 筛选出浏览后5分钟内有点击行为的用户
	select 
	distinct a.gio_id,
	date,
	page_title
	from dwd_23.dwd_23_gio_tracking a
	join 
		(SELECT 
		distinct gio_id,
		page_title,
		date,
		toDateTime(left(time,19)) t
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and date >='2024-05-15'
		and date <'2024-06-01'
		and event ='Button_click'
--		and var_activity_name='2024年5月525车主节'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on x.gio_id=a.gio_id and x.date=a.date and x.page_title=a.page_title
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event='Page_entry'
--	and var_activity_name='2024年5月525车主节'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and date_diff('minute',toDateTime(left(a.time,19)),x.t)<5 -- 浏览和点击在5分钟以内
)x on x.gio_id=a.gio_id and x.date=a.date and x.page_title=a.page_title



-- 小程序拉新人数(点击525活动后，前后十分钟注册成为了新会员)
select
count(distinct a.gio_id) "拉新人数"
from
(-- 525页面
	select gio_id,distinct_id,toDateTime(left(`time`,19)) as `time`,memberid
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event ='Button_click'
and var_activity_name='2024年5月525车主节'
--and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
and page_title ='525车主节·会员权益'
and btn_name ='瓜分V值'
)a 
join
(-- 清洗会员表
	select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
	,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
	from ods_memb.ods_memb_tc_member_info_cur m
	where  m.member_status <> '60341003' and m.is_deleted =0 
) b on a.memberid = b.id::varchar
join
(-- Mini-用户最早访问时间
	select distinct_id,min(`time`) as create_time
	from 
	(-- Mini活跃
		select distinct_id,min(toDateTime(left(`time`,19))) as `time` 
		from dwd_23.dwd_23_gio_tracking a
		where length(distinct_id)<9 
		and (`$lib` in('MiniProgram') or channel ='Mini')
		and `date`>='2024-05-01' and `date`< '2024-06-03'
		group by distinct_id
	union ALL 
	--	Mini活跃
		select distinct_id,min(toDateTime(left(`time`::varchar,19))) as `time` 
		from ods_rawd.ods_rawd_events_d_di a
		where length(distinct_id)<9 
		and (`$lib` in('MiniProgram') or channel ='Mini')
		and `date`< '2024-05-01'
		group by distinct_id
	union ALL 
	--	Mini活跃
		select toString(m.cust_id) as distinct_id,min(toDateTime(`date`)) as `time` 
		from ods_trac.ods_trac_track_cur t
		inner join ods_memb.ods_memb_tc_member_info_cur m on toString(t.usertag)=toString(m.user_id)
		group by distinct_id
	)a
	group by distinct_id
)b1 on a.distinct_id=b1.distinct_id
where toDateTime(a.`time`)-toDateTime(b1.create_time)<=600 
and toDateTime(a.`time`)-toDateTime(b1.create_time)>=-600



-- Mini拉新
select count(distinct distinct_id)
from 
(
	select distinct_id,min(`time`) as create_time
	from 
	(-- Mini活跃
		select distinct_id,min(toDateTime(left(`time`,19))) as `time` 
		from dwd_23.dwd_23_gio_tracking a
		where length(distinct_id)<9 
		and (`$lib` in('MiniProgram') or channel ='Mini')
		and `date`>='2024-05-01' and `date`< '2024-06-01'
		group by distinct_id
	union ALL 
	--	Mini活跃
		select distinct_id,min(toDateTime(left(`time`::varchar,19))) as `time` 
		from ods_rawd.ods_rawd_events_d_di a
		where length(distinct_id)<9 
		and (`$lib` in('MiniProgram') or channel ='Mini')
		and `date`< '2024-05-01'
		group by distinct_id
	union ALL 
	--	Mini活跃
		select toString(m.cust_id) as distinct_id,min(toDateTime(`date`)) as `time` 
		from ods_trac.ods_trac_track_cur t
		inner join ods_memb.ods_memb_tc_member_info_cur m on toString(t.usertag)=toString(m.user_id)
		group by distinct_id
	)a
	group by distinct_id
)a 	
where 1=1
and a.create_time >='2024-05-15'
and a.create_time <'2024-06-01'


-- App拉新
select count(distinct distinct_id)
from 
(	select distinct_id,min(`time`) as create_time
	from 
	(-- App活跃
		select distinct_id,min(toDateTime(left(`time`,19))) as `time` 
		from dwd_23.dwd_23_gio_tracking a
		where length(distinct_id)<9 
		and ((`$lib` in('iOS','Android') and left(`$client_version`,1)='5') or channel ='App')
		and `date`>='2024-05-01' and `date`< '2024-06-01'
		group by distinct_id
	union ALL 
	--	App活跃
		select distinct_id,min(toDateTime(left(`time`::varchar,19))) as `time` 
		from ods_rawd.ods_rawd_events_d_di a
		where length(distinct_id)<9 
		and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$app_version`,1)='5') or channel ='App')
		and `date`< '2024-05-01'
		group by distinct_id
	)a
	group by distinct_id)a 	
where 1=1
and a.create_time >='2024-05-15'
and a.create_time <'2024-06-01'




-- APP拉新人数(点击525活动后，前后十分钟注册成为了新会员)
select
count(distinct a.gio_id) "拉新人数"
from
(-- 
	select gio_id,distinct_id,toDateTime(left(`time`,19)) as `time`,memberid
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
		and date >='2024-05-15'
		and date <'2024-06-01'
		and event='Page_entry'
		and var_activity_name='2024年5月525车主节'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		and page_title in (
		'525车主节·售后惠聚',
		'525车主节',
		'525车主节·会员权益',
		'525车主节·精品好物',
		'525车主节·商城礼券',
		'525车主节·沃尔沃525猩朋友见面会'
		)
)a 
join
(-- 清洗会员表
	select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
	,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
	from ods_memb.ods_memb_tc_member_info_cur m
	where  m.member_status <> '60341003' and m.is_deleted =0 
) b on a.memberid = b.id::varchar
join
(-- App-用户最早访问时间
	select distinct_id,min(`time`) as create_time
	from 
	(-- App活跃
		select distinct_id,min(toDateTime(left(`time`,19))) as `time` 
		from dwd_23.dwd_23_gio_tracking a
		where length(distinct_id)<9 
		--	and (`$lib` in('MiniProgram') or channel ='Mini') -- 小程序
--	and ((`$lib` in('iOS','Android') and left(`$client_version`,1)='5') or channel ='App')
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		and `date`>='2024-05-01' and `date`< '2024-06-03'
		group by distinct_id
	union ALL 
	--	App活跃
		select distinct_id,min(toDateTime(left(`time`::varchar,19))) as `time` 
		from ods_rawd.ods_rawd_events_d_di a
		where length(distinct_id)<9 
		and (((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')or (`$lib`='MiniProgram' or channel='Mini')) -- Mini -- App
--		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') -- App
--		and ($lib='MiniProgram' or channel='Mini') -- Mini
		and `date`< '2024-05-01'
		group by distinct_id
	)a
	group by distinct_id
)b1 on a.distinct_id=b1.distinct_id
where toDateTime(a.`time`)-toDateTime(b1.create_time)<=600 
and toDateTime(a.`time`)-toDateTime(b1.create_time)>=-600



	select $ip
	from dwd_23.dwd_23_gio_tracking a
	limit 10


-- 3、整体召回车主、APP召回车主、小程序召回车主
select 
count(distinct a.gio_id) `召回人数`
--count(distinct a.$ip) `实际召回人数`
from
(-- 525页面
	select gio_id,distinct_id,toDateTime(left(`time`,19)) as `time`,memberid
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event ='Button_click'
and var_activity_name='2024年5月525车主节'
--and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
and page_title ='525车主节·会员权益'
and btn_name ='瓜分V值'
--	and var_is_bind in ('1','true')
	and memberid in 
	(-- 清洗会员表
		select toString(m.id) as memberid
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003' and m.is_deleted =0 
	)
) a
left join
(-- 注册会员
	select distinct m.id
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time >= '2024-05-19'
	and m.create_time < '2024-06-03'
) b on a.memberid=b.id::varchar
left join
(-- 访问过活动前30天内活跃过的车主会员
	select distinct a.distinct_id
	from
	(-- 取用户在活动期间最早的一次活跃,避免激活用户在活动期间重复活跃,被当成非激活了【注意：活动持续时间超过30天的不能这么取】
		select distinct_id,min(toDateTime(`time0`)) as `time`,min(toDateTime(`time0`)) + interval '-10 MINUTE' as `time1`
		from
		(-- 525页面
			select distinct_id,left(`time`,19) as `time0`
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event ='Button_click'
and var_activity_name='2024年5月525车主节'
--and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
and page_title ='525车主节·会员权益'
and btn_name ='瓜分V值'
--			and var_is_bind in ('1','true')
		)a
		group by distinct_id
	)a 
	join
	(-- 前30天内活跃用户
	-- 用户活跃
		select distinct_id,toDateTime(left(`time`,19)) as `time` 
		from dwd_23.dwd_23_gio_tracking a
		where length(distinct_id)<9 
		and `date`>='2024-05-01' 
		and `date`< '2024-06-01'
		and (((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
--		and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- App
--		and (`$lib` in('MiniProgram') or channel ='Mini') -- 小程序
	union ALL 
	--	用户活跃
		select distinct_id,toDateTime(left(`time`::varchar,19)) as `time` 
		from ods_rawd.ods_rawd_events_d_di a
		where length(distinct_id)<9 
		and `date`>= date('2024-05-15')+interval '-30 day' 
		and `date`< '2024-05-01' -- 30天前
		and (((`$lib` in('iOS','Android','HarmonyOS') and left(`$app_version`,1)='5') or channel ='App')or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
--		and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$app_version`,1)='5') or channel ='App') -- App
--		and (`$lib` in('MiniProgram') or channel ='Mini') -- 小程序
	) b on a.distinct_id=b.distinct_id
	where a.`time`+ interval '-30 day'<= b.`time` and b.`time`< a.`time1`
) c on a.distinct_id = c.distinct_id
where 1=1
and b.id is null -- 剔除新用户
and c.distinct_id is null -- 剔除访问活动前30天内活跃过的车主会员