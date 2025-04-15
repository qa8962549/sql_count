--点击该活动MA链接后，进入App活跃的车主memberID
select distinct d.id `memberID`
from ods_oper_crm.ods_oper_crm_ma_send_click_d_si a
left join
(-- 会员ID
	select distinct b.oneid,
	m.id::String id,
	m.member_phone 
	from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
	join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar  
	where b.id_member_id is not null
	and m.is_vehicle=1 -- 车主
) d on a.send_oneid = d.oneid
join 
(
	--进入push链接
	SELECT
	distinct memberid,time
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and toDate(event_time) >='2024-11-30'
	and toDate(event_time) < '2024-12-02'
	and toDate(date) >= '2024-11-30'
	and toDate(date) < '2024-12-02'
	and event='Page_entry'
	and `$url` like '%postId=C26B36EqFX%'
	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or  channel='App')
)x on x.memberid=d.id
where 1=1
and date(a.send_context__send_time) >= '2024-11-30'	-- 发送时间限制
and date(a.send_context__send_time) < '2024-12-02'
and a.send_context__status = 'SUCCESS'	-- 发送状态
and a.send_context__task_id = '6568'
and a.send_channel_new in ('sms','app_push')
and x.time>=a.click_context__click_time -- 点击后进入链接业务
--and toDateTime(a.click_context__click_time) >= toDateTime(a.send_context__send_time)
--and toDateTime(a.click_context__click_time) <= toDateTime(a.send_context__send_time) + interval '3 day'	-- T+3天内的点击




select distinct d.id `memberID`
from ods_oper_crm.ods_oper_crm_ma_send_click_d_si a
left join
(-- 会员ID
	select distinct b.oneid,m.id,m.member_phone 
	from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
	join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar  
	where b.id_member_id is not null
) d on a.send_oneid = d.oneid
where 1=1
and date(a.send_context__send_time) >= '2024-11-30'	-- 发送时间限制
and date(a.send_context__send_time) < '2024-12-02'
and a.send_context__status = 'SUCCESS'	-- 发送状态
and a.send_context__task_id = '6568'
and a.send_channel_new in ('sms','app_push')
