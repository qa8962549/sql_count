--会员日活动攻略	 会员日和夏服的活动短链
select 
	count(b.usr_merged_gio_id) PV,
	count(distinct b.usr_merged_gio_id) uv
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where 1=1
	and event='Page_entry'
--	and event='Button_click'
	and `$url` like '%promotion_channel_sub_type=app%'
	and `$url` like '%promotion_channel_type=app%'
	and `$url` like '%promotion_methods=limited_task%'
	and `$url` like '%promotion_activity=240717_vipday_2%'
	and `$url` like'%promotion_supplement=v7i1p72ksaoiev3%'
	and a.event_time>='2024-07-01' 
	and a.date='2024-07-25'
--	and date<'2024-08-01'
	
	
--夏季服务节	
select 
	count(b.usr_merged_gio_id) PV,
	count(distinct b.usr_merged_gio_id) uv
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where 1=1
	and event='Page_entry'
--	and event='Button_click'
	and `$url` like '%promotion_channel_sub_type=app%'
	and `$url` like '%promotion_channel_type=app%'
	and `$url` like '%promotion_methods=card_jump%'
	and `$url` like '%promotion_activity=240723_summer%'
	and `$url` like'%promotion_supplement=7n216125t73s%'
	and event_time>='2024-07-01' 
	and date>='2024-07-26'
	and date<'2024-07-29'
	
--test 1 
	SELECT 
	event,
	m.is_vehicle is_vehicle,
	var_promotion_channel_type,
	var_promotion_channel_sub_type,
	var_promotion_methods,
	var_promotion_activity,
	var_promotion_supplement,
	usr_merged_gio_id
--	count(usr_merged_gio_id) pv,
--	count(distinct usr_merged_gio_id) uv
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) =toString(a.memberid)
	where 1=1
	and event_time>='2024-06-01' 
	and date>='2024-07-01'
	and date<'2024-08-01'
--	and event ='Page_entry'
	and var_promotion_channel_type ='app'
	and	var_promotion_methods='card_jump'
	and	var_promotion_activity='240723_summer'
	and	var_promotion_supplement='7n216125t73s'

--test 2	
select 
	event,
	time,
	$url,
	m.is_vehicle is_vehicle,
	var_promotion_channel_type,
	var_promotion_channel_sub_type,
	var_promotion_methods,
	var_promotion_activity,
	var_promotion_supplement,
--	usr_merged_gio_id
	a.gio_id 
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) =toString(a.memberid)
	where 1=1
--	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_sub_type=app%'
	and `$url` like '%promotion_channel_type=app%'
	and `$url` like '%promotion_methods=card_jump%'
	and `$url` like '%promotion_activity=240723_summer%'
	and `$url` like '%promotion_supplement=7n216125t73s%'
	and event_time>='2024-06-01' 
	and a.date>='2024-07-01'
	and a.date<'2024-08-01'
 

 