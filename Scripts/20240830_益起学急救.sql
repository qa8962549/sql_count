-- APP总用户数
select
count(1)`总计`,
count(case when is_vehicle ='1' then 1 else null end)`车主`,
count(case when is_vehicle ='0' then 1 else null end)`粉丝`
from ods_oper_crm.ods_oper_crm_usr_gio_d_si
where min_app is not null 

--活动当日APP日活
select 
count(distinct memberid)`总计`,
count(distinct case when is_vehicle ='1' then memberid else null end)`车主`,
count(distinct case when is_vehicle ='0' then memberid else null end)`粉丝`
from ods_oper_crm.ods_oper_crm_active_gio_d_si 
where platform ='App'
and dt>='2024-08-23'
and dt<'2024-09-01'

--APP活动活跃用户
	select 
	count(distinct a.gio_id) `活动页UV`,
	count(distinct case when m.is_vehicle ='1' then a.gio_id else null end)`车主`,
	count(distinct a.gio_id)-count(distinct case when m.is_vehicle ='1' then a.gio_id else null end)`粉丝`
	from dwd_23.dwd_23_gio_tracking a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.memberid)=toString(m.id)  
	where 1=1
	and event_time > '2024-08-23'
	and `date` >= '2024-08-23'
	and `date` < '2025-01-01'
	and event='Page_entry'
	and page_title ='AED视频答题'
	and var_activity_name = '2024年AED视频答题'
	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- App
--	and (`$lib` in('MiniProgram') or channel ='Mini') -- 小程序

-- 激活人数、APP召回车主
select 
count(distinct a.distinct_id) `召回人数`,
count(distinct case when a.is_vehicle ='1' then a.distinct_id else null end)`车主`,
count(distinct a.distinct_id)-count(distinct case when a.is_vehicle ='1' then a.distinct_id else null end)`粉丝`
from
(-- 525页面
	select distinct_id,toDateTime(left(`time`,19)) as `time`,memberid,m.is_vehicle
	from dwd_23.dwd_23_gio_tracking a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.memberid)=toString(m.id)  
	where 1=1
	and event_time > '2024-08-23' 
	and `date` >= '2024-08-23'
	and `date` < '2025-01-01'
	and event='Page_entry'
	and page_title ='AED视频答题'
	and var_activity_name = '2024年AED视频答题'
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')
) a
left join
(-- 注册会员
	select distinct m.id
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time >= '2024-08-23'
	and  m.create_time < '2025-01-01'
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
			and event_time > '2024-08-23' 
			and `date` >= '2024-08-23'
			and `date` < '2025-01-01'
			and event='Page_entry'
			and page_title ='AED视频答题'
			and var_activity_name = '2024年AED视频答题'
			and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')
		)a
		group by distinct_id
	)a 
	join
	(-- 前30天内活跃用户
		select distinct_id
		,toDateTime(left(`time`,19)) as `time` 
		from dwd_23.dwd_23_gio_tracking a
		where length(distinct_id)<9 
		and event_time > '2024-07-01' 
--		and `date` >= '2024-07-23'
--		and `date` < '2024-08-23'
    	AND toDateTime(`date`) >=toDateTime(now()) - INTERVAL 30 DAY
    	AND toDateTime(`date`) < toDateTime(now())
		and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')
	) b on a.distinct_id=b.distinct_id
	where a.`time`+ interval '-30 day'<= b.`time` and b.`time`< a.`time1`
) c on a.distinct_id = c.distinct_id
where 1=1
and b.id is null -- 剔除新用户
and c.distinct_id is null -- 剔除访问活动前30天内活跃过的车主会员


-- app拉新人数
select
count(distinct a.gio_id) `拉新人数`,
count(distinct case when b1.is_vehicle ='1' then a.gio_id else null end)`车主`,
count(distinct a.gio_id)-count(distinct case when b1.is_vehicle ='1' then a.gio_id else null end)`粉丝`
from
(-- 
	select gio_id,distinct_id,toDateTime(left(`time`,19)) as `time`,memberid
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and event_time>'2024-08-23'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and `date` >= '2024-08-23'
	and `date` < '2025-01-01'
	and event='Page_entry'
	and page_title ='AED视频答题'
	and var_activity_name = '2024年AED视频答题'
)a 
join
(	-- app用户
		select memberid,
		min_app create_time,
		is_vehicle
		from ods_oper_crm.ods_oper_crm_usr_gio_d_si
		where 1=1
		and min_app is not null 
--		and is_vehicle='1' --车主
)b1 on a.memberid=b1.memberid
where toDateTime(a.`time`)-toDateTime(b1.create_time)<=600 
and toDateTime(a.`time`)-toDateTime(b1.create_time)>=-600

-- mini拉新人数
select
count(distinct a.gio_id) `拉新人数`,
count(distinct case when b1.is_vehicle ='1' then a.gio_id else null end)`车主`,
count(distinct a.gio_id)-count(distinct case when b1.is_vehicle ='1' then a.gio_id else null end)`粉丝`
from
(-- 
	select gio_id,distinct_id,toDateTime(left(`time`,19)) as `time`,memberid
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and event_time>'2024-08-23'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and `date` >= '2024-08-23'
	and `date` < '2025-01-01'
	and event='Page_entry'
	and page_title ='AED视频答题'
	and var_activity_name = '2024年AED视频答题'
)a 
join
(	-- mini用户
		select memberid,
		min_mini create_time,
		is_vehicle
		from ods_oper_crm.ods_oper_crm_usr_gio_d_si
		where 1=1
		and min_mini is not null 
--		and is_vehicle='1' --车主
)b1 on a.memberid=b1.memberid
where toDateTime(a.`time`)-toDateTime(b1.create_time)<=600 
and toDateTime(a.`time`)-toDateTime(b1.create_time)>=-600


-- 双端去重活动页PV
	select 
	count(a.gio_id) `活动页PV`,
	count(case when m.is_vehicle ='1' then a.gio_id else null end)`车主`,
	count(a.gio_id)-count(case when m.is_vehicle ='1' then a.gio_id else null end)`粉丝`
	from dwd_23.dwd_23_gio_tracking a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.memberid)=toString(m.id)  
	where 1=1
	and event_time > '2024-08-23' 
	and `date` >= '2024-08-23'
	and `date` < '2025-01-01'
	and event='Page_entry'
	and page_title ='AED视频答题'
	and var_activity_name = '2024年AED视频答题'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))

-- 双端去重活动页UV
	select 
	count(distinct a.gio_id) `活动页UV`,
	count(distinct case when m.is_vehicle ='1' then a.gio_id else null end)`车主`,
	count(distinct a.gio_id)-count(distinct case when m.is_vehicle ='1' then a.gio_id else null end)`粉丝`
	from dwd_23.dwd_23_gio_tracking a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.memberid)=toString(m.id)  
	where 1=1
	and event_time > '2024-08-23' 
	and `date` >= '2024-08-23'
	and `date` < '2025-01-01'
	and event='Page_entry'
	and page_title ='AED视频答题'
	and var_activity_name = '2024年AED视频答题'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))

-- 小程序活动页PV
	select 
	count( a.gio_id) `活动页UV`,
	count( case when m.is_vehicle ='1' then a.gio_id else null end)`车主`,
	count( a.gio_id)-count( case when m.is_vehicle ='1' then a.gio_id else null end)`粉丝`
	from dwd_23.dwd_23_gio_tracking a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.memberid)=toString(m.id)  
	where 1=1
	and event_time > '2024-08-23' 
	and `date` >= '2024-08-23'
	and `date` < '2025-01-01'
	and event='Page_entry'
	and page_title ='AED视频答题'
	and var_activity_name = '2024年AED视频答题'
--	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$app_version`,1)='5') or channel ='App') -- App
	and (`$lib` in('MiniProgram') or channel ='Mini') -- 小程序

-- 小程序活动页UV
	select 
	count(distinct a.gio_id) `活动页UV`,
	count(distinct case when m.is_vehicle ='1' then a.gio_id else null end)`车主`,
	count(distinct a.gio_id)-count(distinct case when m.is_vehicle ='1' then a.gio_id else null end)`粉丝`
	from dwd_23.dwd_23_gio_tracking a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.memberid)=toString(m.id)  
	where 1=1
	and event_time > '2024-08-23' 
	and `date` >= '2024-08-23'
	and `date` < '2025-01-01'
	and event='Page_entry'
	and page_title ='AED视频答题'
	and var_activity_name = '2024年AED视频答题'
--	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$app_version`,1)='5') or channel ='App') -- App
	and (`$lib` in('MiniProgram') or channel ='Mini') -- 小程序

-- APP活动页PV
	select 
	count( a.gio_id) `活动页UV`,
	count( case when m.is_vehicle ='1' then a.gio_id else null end)`车主`,
	count( a.gio_id)-count( case when m.is_vehicle ='1' then a.gio_id else null end)`粉丝`
	from dwd_23.dwd_23_gio_tracking a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.memberid)=toString(m.id)  
	where 1=1
	and event_time > '2024-08-23' 
	and `date` >= '2024-08-23'
	and `date` < '2025-01-01'
	and event='Page_entry'
	and page_title ='AED视频答题'
	and var_activity_name = '2024年AED视频答题'
	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- App
	


-- APP活动页UV
	select 
	count(distinct a.gio_id) `活动页UV`,
	count(distinct case when m.is_vehicle ='1' then a.gio_id else null end)`车主`,
	count(distinct a.gio_id)-count(distinct case when m.is_vehicle ='1' then a.gio_id else null end)`粉丝`
	from dwd_23.dwd_23_gio_tracking a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.memberid)=toString(m.id)  
	where 1=1
	and event_time > '2024-08-23' 
	and `date` >= '2024-08-23'
	and `date` < '2025-01-01'
	and event='Page_entry'
	and page_title ='AED视频答题'
	and var_activity_name = '2024年AED视频答题'
	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- App
--	and (`$lib` in('MiniProgram') or channel ='Mini') -- 小程序

select x.*
from 
(
--通过第1关用户数	
SELECT 	
'1'::varchar num,
count(distinct a.member_id) `总计`,
count(distinct case when m.is_vehicle ='1' then a.member_id else null end)`车主`,
count(distinct case when m.is_vehicle ='0' then a.member_id else null end)`粉丝`
FROM ods_dmoa.ods_dmoa_tm_question_result_d a
left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id =m.id
WHERE `right_count` = 3 
AND `question_code` = 'aed_question_bank_1'
and create_time  >= '2024-08-23'
and create_time < '2025-01-01'
and a.is_deleted=0
union all 
--通过第2关用户数	
SELECT 	
'2'::varchar num,
count(distinct a.member_id) `总计`,
count(distinct case when m.is_vehicle ='1' then a.member_id else null end)`车主`,
count(distinct case when m.is_vehicle ='0' then a.member_id else null end)`粉丝`
FROM ods_dmoa.ods_dmoa_tm_question_result_d a
left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id =m.id
WHERE `right_count` = 3 
AND `question_code` = 'aed_question_bank_2'
and create_time  >= '2024-08-23'
and create_time < '2025-01-01'
and a.is_deleted=0
union all 
--通过第3关用户数	
SELECT 	
'3'::varchar num,
count(distinct a.member_id) `总计`,
count(distinct case when m.is_vehicle ='1' then a.member_id else null end)`车主`,
count(distinct case when m.is_vehicle ='0' then a.member_id else null end)`粉丝`
FROM ods_dmoa.ods_dmoa_tm_question_result_d a
left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id =m.id
WHERE `right_count` = 3 
AND `question_code` = 'aed_question_bank_3'
and create_time  >= '2024-08-23'
and create_time < '2025-01-01'
and a.is_deleted=0
union all 
--通过第4关用户数	
SELECT 	
'4'::varchar num,
count(distinct a.member_id) `总计`,
count(distinct case when m.is_vehicle ='1' then a.member_id else null end)`车主`,
count(distinct case when m.is_vehicle ='0' then a.member_id else null end)`粉丝`
FROM ods_dmoa.ods_dmoa_tm_question_result_d a
left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id =m.id
WHERE `right_count` = 3 
AND `question_code` = 'aed_question_bank_4'
and create_time  >= '2024-08-23'
and create_time < '2025-01-01'
and a.is_deleted=0
union all 
--通过第5关用户数	
SELECT 	
'5'::varchar num,
count(distinct a.member_id) `总计`,
count(distinct case when m.is_vehicle ='1' then a.member_id else null end)`车主`,
count(distinct case when m.is_vehicle ='0' then a.member_id else null end)`粉丝`
FROM ods_dmoa.ods_dmoa_tm_question_result_d a
left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id =m.id
WHERE `right_count` = 3 
AND `question_code` = 'aed_question_bank_5'
and create_time  >= '2024-08-23'
and create_time < '2025-01-01'
and a.is_deleted=0
)x 
order by 1 


--3成长值发放用户数
select 
count(distinct o.member_id) `总计`,
count(distinct case when m.is_vehicle ='1' then o.member_id else null end)`车主`,
count(distinct case when m.is_vehicle ='0' then o.member_id else null end)`粉丝`
from ods_memb.ods_memb_tt_member_score_record_cur o
left join ods_memb.ods_memb_tc_member_info_cur m on o.member_id =m.id
where o.event_desc ='益起学急救'
and o.add_c_num=3 -- 三成长值
and o.is_deleted=0 
and o.create_time  >= '2024-08-23'
and o.create_time < '2025-01-01'

--活动累计发放成长值
select 
sum(add_c_num) `总计`,
ifnull(sum(case when m.is_vehicle ='1' then o.add_c_num else null end),0)`车主`,
sum(case when m.is_vehicle ='0' then o.add_c_num else null end)`粉丝`
from ods_memb.ods_memb_tt_member_score_record_cur o
left join ods_memb.ods_memb_tc_member_info_cur m on o.member_id =m.id
where o.event_desc ='益起学急救'
and o.add_c_num=3 -- 三成长值
and o.is_deleted=0 
and o.create_time  >= '2024-08-23'
and o.create_time < '2025-01-01'

select distinct event_desc,add_v_num
from ods_memb.ods_memb_tt_member_score_record_cur o
left join ods_memb.ods_memb_tc_member_info_cur m on o.member_id =m.id
where 1=1
--and o.event_desc ='益起学急救'
and o.event_desc like '%急救%'
--and add_v_num is not null 
--and add_v_num =9 

--9V值发放用户数
select 
count(distinct o.member_id) `总计`,
count(distinct case when m.is_vehicle ='1' then o.member_id else null end)`车主`,
count(distinct case when m.is_vehicle ='0' then o.member_id else null end)`粉丝`
from ods_memb.ods_memb_tt_member_score_record_cur o
left join ods_memb.ods_memb_tc_member_info_cur m on o.member_id =m.id
where o.event_desc ='完成益起学急救任务'
and o.add_v_num =9 -- -9V值发放用户数
and o.is_deleted=0 
and o.create_time  >= '2024-08-23'
and o.create_time < '2025-01-01'


--9V值发放用户数test 
select 
distinct o.member_id
from ods_memb.ods_memb_tt_member_score_record_cur o
left join ods_memb.ods_memb_tc_member_info_cur m on o.member_id =m.id
where o.event_desc ='完成益起学急救任务'
and o.add_v_num =9 -- -9V值发放用户数
and o.is_deleted=0 
and o.create_time  >= '2024-08-23'
and o.create_time < '2025-01-01'

--通过第4关用户数	test
SELECT 	
distinct a.member_id
FROM ods_dmoa.ods_dmoa_tm_question_result_d a
left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id =m.id
WHERE `right_count` = 3 
AND `question_code` = 'aed_question_bank_4'
and create_time  >= '2024-08-23'
and create_time < '2025-01-01'
and a.is_deleted=0

--活动累计发放V值数
select 
sum(add_v_num) `总计`,
ifnull(sum(case when m.is_vehicle ='1' then o.add_v_num else null end),0)`车主`,
sum(case when m.is_vehicle ='0' then o.add_v_num else null end)`粉丝`
from ods_memb.ods_memb_tt_member_score_record_cur o
left join ods_memb.ods_memb_tc_member_info_cur m on o.member_id =m.id
where o.event_desc like '%急救%'
and o.add_v_num =9 -- -9V值发放用户数
--and o.add_v_num <>0 -- -9V值发放用户数
and o.is_deleted=0 
and o.create_time  >= '2024-08-23'
and o.create_time < '2025-01-01'

--投票数据：
SELECT substring(option_name,25,6),
vote_num
FROM ods_dmoa.ods_dmoa_tm_vote_option_d a
where 1=1
and create_time  >= '2024-08-23'
and create_time < '2025-01-01'
order by 1 desc 

-- 投票明细
SELECT option_id,
count(distinct o.member_id) `总计`,
count(distinct case when m.is_vehicle ='1' then o.member_id else null end)`车主`,
count(distinct case when m.is_vehicle ='0' then o.member_id else null end)`粉丝`
FROM ods_dmoa.ods_dmoa_tt_vote_record_d o
left join ods_memb.ods_memb_tc_member_info_cur m on o.member_id =m.id
group by 1 
order by 2 desc  


--话题发帖篇数
	select 
	count( a.id) `话题发帖篇数`,
	count( case when m.is_vehicle ='1' then a.id else null end)`车主`,
	count( a.id)-count( case when m.is_vehicle ='1' then a.id else null end)`粉丝`
	from ods_cmnt.ods_cmnt_tr_topic_post_link_cur l 
	left join ods_cmnt.ods_cmnt_tm_post_cur a on a.post_id = l.post_id and l.is_deleted = 0
	left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id =m.id
	where 1=1
	and a.create_time >='2024-08-23'
	and a.create_time <'2025-01-01'
	and a.is_deleted =0
	and l.topic_id ='k1eSZh19ES'

--话题参与人数
	select 
	count(distinct a.member_id) `话题参与人数`,
	count(distinct case when m.is_vehicle ='1' then a.member_id else null end)`车主`,
	count(distinct a.member_id)-count(distinct case when m.is_vehicle ='1' then a.member_id else null end)`粉丝`
	from ods_cmnt.ods_cmnt_tr_topic_post_link_cur l 
	left join ods_cmnt.ods_cmnt_tm_post_cur a on a.post_id = l.post_id and l.is_deleted = 0
	left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id =m.id
	where 1=1
	and a.create_time >='2024-08-23'
	and a.create_time <'2025-01-01'
	and a.is_deleted =0
	and l.topic_id ='k1eSZh19ES'
	
--参与答题（通过任一关）并发帖用户数
	select 
	count(distinct a.member_id) `话题参与人数`,
	count(distinct case when m.is_vehicle ='1' then a.member_id else null end)`车主`,
	count(distinct a.member_id)-count(distinct case when m.is_vehicle ='1' then a.member_id else null end)`粉丝`
	from ods_cmnt.ods_cmnt_tr_topic_post_link_cur l 
	left join ods_cmnt.ods_cmnt_tm_post_cur a on a.post_id = l.post_id and l.is_deleted = 0
	left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id =m.id
	join (
	--通过任一关
		SELECT distinct a.member_id
		FROM ods_dmoa.ods_dmoa_tm_question_result_d a
		left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id =m.id
		WHERE `right_count` = 3 
		AND `question_code` like '%aed_question_bank%'
		and create_time  >= '2024-08-23'
		and create_time < '2025-01-01'
		and a.is_deleted=0
		)x on x.member_id=a.member_id 
	where 1=1
	and a.create_time >='2024-08-23'
	and a.create_time <'2025-01-01'
	and a.is_deleted =0
	and l.topic_id ='k1eSZh19ES'