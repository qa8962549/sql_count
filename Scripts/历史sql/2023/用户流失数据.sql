--绑车之后，超过365天没进私域 -- 流失用户
--绑车之后，超过365天没进私域，且最后一次活跃时间-最新绑车时间+365=365，算作T+365流失  
--绑车之后，超过365天没进私域，且最后一次活跃时间-最新绑车时间+365=366，算作T+366流失
--绑车之后，超过365天没进私域，且最后一次活跃时间-最新绑车时间+365=367，算作T+367流失

--历史上绑过车的用户数 
 select
 count(distinct r.member_id)
 from volvo_cms.vehicle_bind_relation r
 where r.deleted = 0
 and r.is_bind = 1   -- 绑车
 
-- 绑车后的 流失用户（365天未进入私域且365天无售后工单的用户数）当天 
 -- 最后一次活跃时间-最新绑车时间+365
select 
case when dateDiff('day',toDate(xx.bctime),toDate(xx.mt))=0 or xx.mt is null or dateDiff('day',toDate(xx.bctime),toDate(xx.mt))+365<365 then 365
	 else dateDiff('day',toDate(xx.bctime),toDate(xx.mt))+365 end TN,
count(distinct xx.cust_id) num 
from 
	(
	select distinct dateDiff('day',toDate(x.bind_date),toDate('2023-10-08')) diff_day -- 绑车时间距离2023.10.8的天数
	,x.cust_id
	,toDate(x.bind_date) bctime  -- 绑车时间
	,x1.mt -- 流失用户最后一次活跃时间
	from 
		 (
--		 取最近一次绑车时间
		 select
		 r.member_id,
		 m.cust_id,
		 r.bind_date,
		 row_number() over(partition by r.member_id order by r.bind_date desc) rk
		 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
		 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.member_id is not null 
		 and r.member_id <>''
		 and r.bind_date<='2023-10-08'
		 and r.bind_date>='2018-08-08'
		 Settings allow_experimental_window_functions = 1
		 )x 
	 join 
		(-- 私域活跃或提交工单 流失用户
			select x.id,
			max(x.t) mt -- 最后一次活跃时间
			from 
				(
				-- 小程序活跃
				select distinct toString(m.cust_id) id,toDate(t.`date`) t
				from ods_trac.ods_trac_track_cur t
				left join ods_memb.ods_memb_tc_member_info_cur m on toString(t.usertag)=toString(m.user_id) 
				where t<='2022-08-01'
				and id is not null 
				union all
				-- APP活跃
				select distinct toString(e.distinct_id) id,toDate(e.date) t
				from ods_rawd.ods_rawd_events_d_di e 
				where length(e.distinct_id)<=9
				and ((event in ('$AppViewScreen','$AppClick') and left($app_version,1)='5') or event in('$MPViewScreen','$MPClick'))
				and t<='2023-10-08'
				and id is not null 
				union all 
				-- 提交过工单
				select distinct toString(tam.OWNER_ONE_ID) id,
				toDate(tam.CREATED_AT) t
				from ods_cyap.ods_cyap_tt_appointment_maintain_d tam 
				where tam.WORK_ORDER_NUMBER is not null 
				and t <='2023-10-08'
				and id is not null )x
			group by x.id
			HAVING dateDiff('day',mt,toDate('2023-10-08'))>=365 -- 最近一次活跃时间距离现实时间超过1年，流失用户
		)x1 on toString(x1.id)=toString(x.cust_id) 
	where x.rk=1 
	and diff_day>=365 --绑车时间距离2023.10.8超过365天的车主
	order by bctime 
)xx group by rollup(TN)
order by TN

CREATE FUNCTION nn AS (parameter0, ...) -> expression

			
-- 绑车后的 流失用户（365天未进入私域且365天无售后工单的用户数）当天  test -- 最后一次活跃时间-最新绑车时间+365 
select 
xx.lstime-xx.bctime bcday, -- 成为流失用户的时间-绑车时间
count(distinct xx.cust_id) num -- 流失用户数量
--xx.bctime`绑车时间`,
--xx.lstime `成为流失用户的时间`,
--x1.mt`绑车满N天前的最近一次活跃时间`
--count(distinct case when dateDiff('day',,toDate(x1.mt))<=365 then xx.cust_id else null end) num
from 
	(
	select distinct dateDiff('day',toDate(x.bind_date),toDate('2023-10-08')) diff_day -- 绑车时间距离2023.10.8的天数
	,x.cust_id
	,toDate(x.bind_date) bctime  -- 绑车时间
	,toDate(x.bind_date)+0+365 lstime --预计流失时间
	from 
		 (
--		 取最近一次绑车时间
		 select
		 r.member_id,
		 m.cust_id,
		 r.bind_date,
		 row_number() over(partition by r.member_id order by r.bind_date desc) rk
		 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
		 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.member_id is not null 
		 and r.member_id <>''
		 and r.bind_date<='2023-10-08'
		 and r.bind_date>='2018-08-08'
		 Settings allow_experimental_window_functions = 1
		 )x 
	where x.rk=1 
	and diff_day>=365 --绑车时间距离2023.10.8超过365天的车主
	order by bctime 
	)xx 
join 
	(-- 私域活跃或提交工单 流失用户 -- 取出用户在绑车400天前的最近一次活跃时间
		select 
		distinct 
		xx.cust_id,
		max(x.t) mt -- 绑车+n+365天前的最近一次活跃时间
		from 
			(
			-- 小程序活跃
			select distinct toString(m.cust_id) id,toDate(t.`date`) t
			from ods_trac.ods_trac_track_cur t
			left join ods_memb.ods_memb_tc_member_info_cur m on toString(t.usertag)=toString(m.user_id) 
			where t<='2022-08-01'
			and id is not null 
			union all
			-- APP活跃
			select distinct toString(e.distinct_id) id,toDate(e.date) t
			from ods_rawd.ods_rawd_events_d_di e 
			where length(e.distinct_id)<=9
			and ((event in ('$AppViewScreen','$AppClick') and left($app_version,1)='5') or event in('$MPViewScreen','$MPClick'))
			and t<='2023-10-08'
			and id is not null 
			union all 
			-- 提交过工单
			select distinct toString(tam.OWNER_ONE_ID) id,
			toDate(tam.CREATED_AT) t
			from ods_cyap.ods_cyap_tt_appointment_maintain_d tam 
			where tam.WORK_ORDER_NUMBER is not null 
			and t <='2023-10-08'
			and id is not null )x
		join 
			(
			-- 最近绑车时间
			select distinct dateDiff('day',toDate(x.bind_date),toDate('2023-10-08')) diff_day -- 绑车时间距离2023.10.8的天数
			,x.cust_id
			,toDate(x.bind_date) bctime  -- 绑车时间
			from 
				 (
		--		 取最近一次绑车时间
				 select
				 r.member_id,
				 m.cust_id,
				 r.bind_date,
				 row_number() over(partition by r.member_id order by r.bind_date desc) rk
				 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
				 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
				 where r.deleted = 0
				 and r.is_bind = 1   -- 绑车
				 and r.member_id is not null 
				 and r.member_id <>''
				 and r.bind_date<='2023-10-08'
				 and r.bind_date>='2018-08-08'
				 Settings allow_experimental_window_functions = 1
				 )x 
			where x.rk=1 
			and diff_day>=365 --绑车时间距离2023.10.8超过365天的车主
			order by bctime 
			)xx on toString(xx.cust_id)=toString(x.id)
		where 1=1
		and x.t<=xx.bctime+0+365 -- 绑车400（N）天的最近一次活跃时间
		group by xx.cust_id
	)x1 on toString(x1.cust_id)=toString(xx.cust_id) 
where xx.lstime-x1.mt=365 -- 活跃时间和流失时间相差一年
group by bcday
order by bcday 



-- 私域活跃或提交工单 流失用户
select x.id,max(x.t) mt -- 最后一次活跃时间
from 
	(
	-- 小程序活跃
	select distinct toString(m.cust_id) id,toDate(t.`date`) t
	from ods_trac.ods_trac_track_cur t
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(t.usertag)=toString(m.user_id) 
	where t<='2022-08-01'
	and id is not null 
	union all
	-- APP活跃
	select distinct toString(e.distinct_id) id,toDate(e.date) t
	from ods_rawd.ods_rawd_events_d_di e 
	where length(e.distinct_id)<=9
	and event in ('$AppViewScreen','$AppClick','$MPViewScreen','$MPClick')
	and t<='2023-10-08'
	and id is not null 
	union all 
	-- 提交过工单
	select distinct toString(tam.OWNER_ONE_ID) id,
	toDate(tam.CREATED_AT) t
	from ods_cyap.ods_cyap_tt_appointment_maintain_d tam 
	where tam.WORK_ORDER_NUMBER is not null 
	and t <='2023-10-08'
	and id is not null )x
group by x.id
HAVING dateDiff('day',mt,toDate('2023-10-08'))>=365

--截止2023年10月8日绑车超过N天的用户(N>=365)
select 
x.t,
x.num,
sum(x.num)over(order by x.t)  -- 累计数量
from 
	(
	-- 绑车天数对应的车主人数
	 select DATEDIFF('2023-10-08',bind_date) t,
	 count(distinct x.member_id) num 
	 from 
		 (
		 select
		 r.member_id,
		 r.bind_date,
		 row_number() over(partition by r.member_id order by r.bind_date desc) rk
		 from volvo_cms.vehicle_bind_relation r
		 where r.deleted = 0
		 and r.member_id is not null 
	 	 and r.member_id <>''
		 and r.is_bind = 1   -- 绑车
		 and r.bind_date<='2023-10-08'
		 )x where x.rk=1 and t>=365
	group by 1 
	order by 1
)x   order by 3 desc 

--截止2023年10月8日绑车不超过N天的用户 (N>=365)
select 
x.t,
x.num,
sum(x.num)over(order by x.t)  -- 累计数量
from 
	(
	-- 绑车天数对应的车主人数
	 select DATEDIFF('2023-10-08',bind_date) t,
	 count(distinct x.member_id) num 
	 from 
		 (
		 select
		 r.member_id,
		 r.bind_date,
		 row_number() over(partition by r.member_id order by r.bind_date desc) rk
		 from volvo_cms.vehicle_bind_relation r
		 where r.deleted = 0
		 and r.member_id is not null 
	 	 and r.member_id <>''
		 and r.is_bind = 1   -- 绑车
		 and r.bind_date<='2023-10-08'
		 )x where x.rk=1 
--		 and t<365
	group by 1 
	order by 1 desc 
)x   
order by 3 
