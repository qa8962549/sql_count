


PUSH 人数(MA成功发送) MA看全量（历史累计到当前月）

	SELECT *
	from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d a

-- V2
SELECT
count(distinct b.oneid) UV
,count(distinct case when b.is_vehicle='粉丝' then b.oneid end) fans_UV
,count(distinct case when b.is_vehicle='车主' then b.oneid end) car_UV
from 
(-- 发送
	SELECT distinct b.distinct_id,a.oneid,b.is_vehicle
	from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d a
	join 
	(-- 取身份
		select distinct b.oneid,toString(m.cust_id) distinct_id 
		,case when m.is_vehicle=1 then '车主' else '粉丝' end as is_vehicle
		from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
		join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar
		where b.id_member_id is not null
	)b on a.oneid=b.oneid
	where a.oneid not like '%whitelist%' -- 去除白名单
	and a.context__status = 'SUCCESS' -- 发送成功
	and a.context__touch_channel in ('app_push')
	and a.context__send_time < '2023-08-01' -- 发送时间
)b
join
(-- app用户
	select distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where LENGTH(a.distinct_id)<9
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and a.`date`<'2023-08-01'
)a on a.distinct_id=b.distinct_id





接受/关闭PUSH 人数：多少人是关闭、接受状态 (截止到当前月的最新状态)

-- V2
-- 截止至当前月,用户的最新状态
select COUNT(a.distinct_id) 
,count(distinct case when b.is_vehicle='粉丝' then a.distinct_id end) fans_UV
,count(distinct case when b.is_vehicle='车主' then a.distinct_id end) car_UV
from
(-- 按时间降序排列
	select distinct_id ,push_permission_status
	,row_number() over(partition by a.distinct_id order by a.`time` desc) rk
	from ods_rawd.ods_rawd_events_d_di a
	where LENGTH(a.distinct_id)<9
	and a.event in ('Page_entry','Page_view','Button_click')
	and a.push_permission_status is not null
	and a.`date` >= '2023-09-19' and a.`date`<'2023-10-01'
)a
join 
(-- 清洗cust_id 取其对应的最新信息
	select distinct m.distinct_id,is_vehicle
	from 
	(-- 清洗cust_id
		select m.cust_id::varchar as `distinct_id`,m.member_time,
		case when m.is_vehicle=0 then '粉丝' when m.is_vehicle=1 then '车主' end as is_vehicle,
		row_number() over(partition by m.cust_id order by m.create_time desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where m.member_status<>'60341003' and m.is_deleted=0
		and m.cust_id is not null 
	) m
	where m.rk=1
)b on a.distinct_id=b.distinct_id
where a.rk=1 and a.push_permission_status = 0





关闭前已接受PUSH 次数：截止到现在是关闭，其上一次状态是打开的最新打开时间，算这个时间差的push次数
目的：被打扰多少次，会关闭push

-- V2
SELECT
PV,count(distinct oneid) UV
,count(distinct case when is_vehicle='粉丝' then oneid end) fans_UV
,count(distinct case when is_vehicle='车主' then oneid end) car_UV
from
(-- 计算用户关闭前已接受PUSH次数
	select
	b.oneid,b.is_vehicle,
	count(distinct b.PV) PV
	from
	(-- 0——1——0：其中“1”处在的时间区间 [次0的最新时间, 最新关闭前打开PUSH的最新时间]
		select a.distinct_id,a.date0,b.date1
		from
		(-- 次0的最新时间
			select a.distinct_id,max(a.date1) date0
			from
			(-- 用户所有0的时间(前提：最新关闭前最近打开PUSH的用户)
				select distinct_id,toDateTime(`time`) date1
				from ods_rawd.ods_rawd_events_d_di a
				where LENGTH(a.distinct_id)<9
				and a.event in ('Page_entry','Page_view','Button_click')
				and a.push_permission_status =0
				and a.`date` >= '2023-09-19' and a.`date`<'2024-03-07'
				and distinct_id in
				(-- 最新关闭前最近打开PUSH的用户
					select distinct b.distinct_id 
					from
					(-- 截止到现在,最新状态是关闭de最新关闭时间
						select distinct_id,maxtime
						from
						(-- 按时间降序排列
							select distinct_id,push_permission_status,toDateTime(a.`time`) maxtime
							,row_number() over(partition by a.distinct_id order by a.`time` desc) rk
							from ods_rawd.ods_rawd_events_d_di a
							where LENGTH(a.distinct_id)<9
							and a.event in ('Page_entry','Page_view','Button_click')
							and a.push_permission_status is not null
							and a.`date` >= '2023-09-19' and a.`date`<'2024-03-07'
						)a 
						where a.rk=1 and a.push_permission_status=0
					)a
					JOIN 
					(-- 取接受PUSH状态的用户最新时间
						select distinct_id,max(`time`) maxtime
						from ods_rawd.ods_rawd_events_d_di a
						where LENGTH(a.distinct_id)<9
						and a.event in ('Page_entry','Page_view','Button_click')
						and a.push_permission_status =1
						and a.`date` >= '2023-09-19' and a.`date`<'2024-03-07'
						group by distinct_id
					)b on a.distinct_id=b.distinct_id
					where a.maxtime > b.maxtime
				)
			)a
			join
			(-- 最新关闭前打开PUSH的最新时间
				select distinct b.distinct_id distinct_id,toDateTime(b.maxtime) date1
				from
				(-- 截止到现在,最新状态是关闭de最新关闭时间
					select distinct_id,maxtime
					from
					(-- 按时间降序排列
						select distinct_id,push_permission_status,toDateTime(a.`time`) maxtime
						,row_number() over(partition by a.distinct_id order by a.`time` desc) rk
						from ods_rawd.ods_rawd_events_d_di a
						where LENGTH(a.distinct_id)<9
						and a.event in ('Page_entry','Page_view','Button_click')
						and a.push_permission_status is not null
						and a.`date` >= '2023-09-19' and a.`date`<'2024-03-07'
					)a 
					where a.rk=1 and a.push_permission_status=0
				)a
				JOIN 
				(-- 取接受PUSH状态的用户最新时间
					select distinct_id,max(`time`) maxtime
					from ods_rawd.ods_rawd_events_d_di a
					where LENGTH(a.distinct_id)<9
					and a.event in ('Page_entry','Page_view','Button_click')
					and a.push_permission_status =1
					and a.`date` >= '2023-09-19' and a.`date`<'2024-03-07'
					group by distinct_id
				)b on a.distinct_id=b.distinct_id
				where a.maxtime > b.maxtime
			)b on a.distinct_id=b.distinct_id
			where a.date1<b.date1 -- 关键节点：所有0的时间 < (最新关闭前打开PUSH的最新时间),即排掉了 最新状态为0时的所有时间数据
			group by a.distinct_id
		)a
		join
		(-- 最新关闭前打开PUSH的最新时间
			select distinct b.distinct_id distinct_id,toDateTime(b.maxtime) date1
			from
			(-- 截止到现在,最新状态是关闭de最新关闭时间
				select distinct_id,maxtime
				from
				(-- 按时间降序排列
					select distinct_id,push_permission_status,toDateTime(a.`time`) maxtime
					,row_number() over(partition by a.distinct_id order by a.`time` desc) rk
					from ods_rawd.ods_rawd_events_d_di a
					where LENGTH(a.distinct_id)<9
					and a.event in ('Page_entry','Page_view','Button_click')
					and a.push_permission_status is not null
					and a.`date` >= '2023-09-19' and a.`date`<'2024-03-07'
				)a 
				where a.rk=1 and a.push_permission_status=0
			)a
			JOIN 
			(-- 取接受PUSH状态的用户最新时间
				select distinct_id,max(`time`) maxtime
				from ods_rawd.ods_rawd_events_d_di a
				where LENGTH(a.distinct_id)<9
				and a.event in ('Page_entry','Page_view','Button_click')
				and a.push_permission_status =1
				and a.`date` >= '2023-09-19' and a.`date`<'2024-03-07'
				group by distinct_id
			)b on a.distinct_id=b.distinct_id
			where a.maxtime > b.maxtime
		)b on a.distinct_id=b.distinct_id
	)a
	join
	(-- 发送
		SELECT distinct b.distinct_id distinct_id
		,a.oneid oneid
		,b.is_vehicle is_vehicle
		,concat(a.context__task_id,
				a.context__touch_channel,
				a.context__content_model_id,
				a.context__original_url,
				a.context__individual_id,
				a.context__send_time) PV
		,toDateTime(a.context__send_time) push_date
		from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d a
		join 
		(-- 取身份
			select distinct b.oneid,toString(m.cust_id) distinct_id 
			,case when m.is_vehicle=1 then '车主' else '粉丝' end as is_vehicle
			from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
			join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar
			where b.id_member_id is not null
		)b on a.oneid=b.oneid
		join
		(-- app用户
			select distinct distinct_id
			from ods_rawd.ods_rawd_events_d_di a
			where LENGTH(a.distinct_id)<9
			and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
			and a.`date`<'2024-03-07'
		)c on c.distinct_id=b.distinct_id
		where a.oneid not like '%whitelist%' -- 去除白名单
		and a.context__status = 'SUCCESS' -- 发送成功
		and a.context__touch_channel in ('app_push')
		and a.context__send_time < '2024-03-07' -- 发送时间
	)b on a.distinct_id=b.distinct_id
	where a.date0 < b.push_date and b.push_date < a.date1
	group by b.oneid,b.is_vehicle
)a
group by PV order by PV






















-- 发送UV_23年9月之前
-- V1
SELECT --left(a.context__send_time,7) as month1, 
count(distinct a.oneid) UV
,count(distinct case when b.is_vehicle='粉丝' then a.oneid end) fans_UV
,count(distinct case when b.is_vehicle='车主' then a.oneid end) car_UV
from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d a
join 
(-- 取身份
	select distinct b.oneid,case when m.is_vehicle=1 then '车主' else '粉丝' end as is_vehicle
	from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
	join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar
	where b.id_member_id is not null
)b on a.oneid=b.oneid
where a.oneid not like '%whitelist%' -- 去除白名单
and a.context__status = 'SUCCESS' -- 发送成功
and a.context__touch_channel in ('app_push')
and a.context__send_time<'2024-04-01' -- 发送时间
--group by month1 order by month1




-- push_permission_status 9月19日才有的值,且得是最新版本才有
-- V1
SELECT
count(distinct b.oneid) UV
,count(distinct case when b.is_vehicle='粉丝' then b.oneid end) fans_UV
,count(distinct case when b.is_vehicle='车主' then b.oneid end) car_UV
from 
(-- 发送
	SELECT distinct b.distinct_id,a.oneid,b.is_vehicle
	from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d a
	join 
	(-- 取身份
		select distinct b.oneid,toString(m.cust_id) distinct_id 
		,case when m.is_vehicle=1 then '车主' else '粉丝' end as is_vehicle
		from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
		join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar
		where b.id_member_id is not null
	)b on a.oneid=b.oneid
	where a.oneid not like '%whitelist%' -- 去除白名单
	and a.context__status = 'SUCCESS' -- 发送成功
	and a.context__touch_channel in ('app_push')
	and a.context__send_time < '2024-04-01' -- 发送时间
)b
join
(-- 用户的最新状态
	select *
	from
	(-- 截止至当前月,按时间降序排列
		select distinct_id ,push_permission_status
		,row_number() over(partition by a.distinct_id order by a.`time` desc) rk
		from ods_rawd.ods_rawd_events_d_di a
		where LENGTH(a.distinct_id)<9
		and a.event in ('Page_entry','Page_view','Button_click')
		and a.push_permission_status is not null
		and a.`date` >= '2023-09-19' and a.`date`<'2024-04-01'
	)a
	where a.rk=1 and a.push_permission_status = 1
)a on a.distinct_id=b.distinct_id




-- 关闭前已接受PUSH 次数
-- V1
SELECT
PV,count(distinct oneid) UV
,count(distinct case when is_vehicle='粉丝' then oneid end) fans_UV
,count(distinct case when is_vehicle='车主' then oneid end) car_UV
from
(
	SELECT
	b.oneid,b.is_vehicle,
	count(distinct b.PV) PV
	from 
	(-- 发送
		SELECT distinct b.distinct_id distinct_id
		,a.oneid oneid
		,b.is_vehicle is_vehicle
		,concat(a.context__task_id,
				a.context__touch_channel,
				a.context__content_model_id,
				a.context__original_url,
				a.context__individual_id,
				a.context__send_time) PV
		,toDateTime(a.context__send_time) date1
		from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d a
		join 
		(-- 取身份
			select distinct b.oneid,toString(m.cust_id) distinct_id 
			,case when m.is_vehicle=1 then '车主' else '粉丝' end as is_vehicle
			from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
			join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar
			where b.id_member_id is not null
		)b on a.oneid=b.oneid
		join
		(-- app用户
			select distinct distinct_id
			from ods_rawd.ods_rawd_events_d_di a
			where LENGTH(a.distinct_id)<9
			and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
			and a.`date`<'2023-08-01'
		)c on c.distinct_id=b.distinct_id
		where a.oneid not like '%whitelist%' -- 去除白名单
		and a.context__status = 'SUCCESS' -- 发送成功
		and a.context__touch_channel in ('app_push')
		and a.context__send_time < '2024-04-01' -- 发送时间
	)b
	join
	(-- 关闭前已接受PUSH
		select a.distinct_id,max(a.date1) date1
		from
		(-- 取(状态：接受PUSH)用户所有时间
			select distinct distinct_id,toDateTime(`time`) date1
			from ods_rawd.ods_rawd_events_d_di a
			where LENGTH(a.distinct_id)<9
			and a.event in ('Page_entry','Page_view','Button_click')
			and a.push_permission_status =1 -- 接受PUSH
			and a.`date` >= '2023-09-19'
		)a
		left join
		(-- 需剔除这部分数据(1、从来没关过PUSH的; 2、关闭PUSH后又打开PUSH,并一直开着PUSH的用户)
			select a.distinct_id,toDateTime(a.maxtime) date1
			from
			(-- 取接受PUSH状态的用户最新时间
				select distinct_id,max(`time`) maxtime
				from ods_rawd.ods_rawd_events_d_di a
				where LENGTH(a.distinct_id)<9
				and a.event in ('Page_entry','Page_view','Button_click')
				and a.push_permission_status =1 -- 接受PUSH
				and a.`date` >= '2023-09-19'
				group by distinct_id
			)a
			left JOIN 
			(-- 取关闭PUSH状态的用户最新时间
				select distinct_id,max(`time`) maxtime
				from ods_rawd.ods_rawd_events_d_di a
				where LENGTH(a.distinct_id)<9
				and a.event in ('Page_entry','Page_view','Button_click')
				and a.push_permission_status =0 -- 关闭PUSH
				and a.`date` >= '2023-09-19'
				group by distinct_id
			)b on a.distinct_id=b.distinct_id
			where a.maxtime > b.maxtime
		)b on a.distinct_id=b.distinct_id and a.date1=b.date1
		where b.distinct_id is null
		group by a.distinct_id
	)a on a.distinct_id=b.distinct_id
	where a.date1 > b.date1 
	group by b.oneid,b.is_vehicle
)a
group by PV order by PV 

发送app_push,用户接受app_push 间隔多久
