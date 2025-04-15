
	--沃世界预约
select 	
	distinct 
	x.memberid,
--	tmi.id `邀请人会员ID`,
	case when x2.`客户ID` is not null then '是' else '否' end `是否点击后留资成功（Y/N）`
from 
(	-- 沃世界预约
	SELECT 
	distinct 
	distinct_id,
	memberid
	from dwd_23.dwd_23_gio_tracking a
	where length(distinct_id)<9 
    and date(event_time) >= toDateTime('2024-08-01') + interval '-30 day'
	and date between '2024-08-01' and '2024-09-01'
	and event ='Page_entry'
	and `$url` like '%IBCRMJULALL000142024VCCN%'
	)x
left join 
(
	-- 预约试驾
	SELECT
	distinct 
	ta.ONE_ID `客户ID`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	 left join ods_actv.ods_actv_cms_active_d ca ON ca.uid = ta.CHANNEL_ID
	WHERE 1=1
	and date(ta.CREATED_AT) >= '2024-08-01'
	and date(ta.CREATED_AT) < '2024-09-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ca.active_code = 'IBCRMJULALL000142024VCCN'   -- 沃世界预约
	order by ta.CREATED_AT
)x2 on toString(x2.`客户ID`) =toString(x.distinct_id) 


-- 沃世界邀请 邀约试驾 当月总留资量
SELECT 
distinct 
--	x.distinct_id,
	 x.memberid `邀请人会员ID`,
	case when t2.member_id is not null then '是' else '否' end `是否点击后发起邀请（Y/N）`
FROM (-- mini-点击【立即邀请】
	select distinct distinct_id,memberid
	from dwd_23.dwd_23_gio_tracking g
	where length(distinct_id)<9 
    and date(event_time) >= toDateTime('2024-08-01') + interval '-30 day'
	and date between '2024-08-01' and '2024-09-01'
	and event ='$MPViewScreen'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%btn%'
	and `$url` like '%240722_augtestdrive%'
	and `$url` like '%1d215028v1l%'
	)x 
left join 
	(select t2.*
	from ods_invi.ods_invi_tm_invite_code_d t2 
	WHERE t2.create_time >='2024-08-01' 
	and t2.create_time <'2024-09-01'
	)t2 on toString( t2.member_id) =toString(x.memberid)

--APP预约
select 	
	distinct 
	x.memberid,
--	tmi.id `邀请人会员ID`,
	case when x2.`客户ID` is not null then '是' else '否' end `是否点击后留资成功（Y/N）`
from 
(	-- app-点击【立即预约】
	SELECT 
	distinct 
	distinct_id,
	memberid
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) =toString(a.memberid)
	where 1=1
	and event_time >'2024-08-01' 
	and date >'2024-08-01' 
	and event ='Page_entry'
	and var_promotion_channel_type='app'
	and var_promotion_channel_sub_type='app'
	and var_promotion_methods='btn'
	and var_promotion_activity='240722_augtestdrive'
	and var_promotion_supplement='1x215351r18g'
	)x
left join 
(
	-- 预约试驾
	SELECT
	distinct 
	ta.ONE_ID `客户ID`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	WHERE 1=1
	and date(ta.CREATED_AT) >= '2024-08-01'
	and date(ta.CREATED_AT) < '2024-09-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
)x2 on toString(x2.`客户ID`) =toString(x.distinct_id) 

-- app-点击【立即邀请】 当月总留资量
SELECT 
distinct 
--	x.distinct_id,
	x.memberid `邀请人会员ID`,
	case when t2.member_id is not null then '是' else '否' end `是否点击后发起邀请（Y/N）`
FROM (-- app-点击【立即邀请】
	SELECT 
	distinct 
	distinct_id,memberid
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) =toString(a.memberid)
	where 1=1
	and event_time >'2024-08-01' 
	and date >'2024-08-01' 
	and event ='Page_entry'
	and var_promotion_channel_type='app'
	and var_promotion_channel_sub_type='app'
	and var_promotion_methods='btn'
	and var_promotion_activity='240722_augtestdrive'
	and var_promotion_supplement='4p215474m88q'
	)x 
left join 
	(select t2.*
	from ods_invi.ods_invi_tm_invite_code_d t2 
	WHERE t2.create_time >='2024-08-01' 
	and t2.create_time <'2024-09-01'
	)t2 on toString( t2.member_id) =toString(x.memberid)

-- sms-人群包1 邀约 留资
SELECT 
distinct 
	 x.memberid `邀请人会员ID`,
	case when t2.member_id is not null then '是' else '否' end `是否点击后发起邀请（Y/N）`,
	case when x2.`客户ID` is not null then '是' else '否' end `是否点击后留资成功（Y/N）`
FROM (-- 人群包1
	select distinct distinct_id,memberid
	from dwd_23.dwd_23_gio_tracking g
	where length(distinct_id)<9 
    and date(event_time) >= toDateTime('2024-08-01') + interval '-30 day'
	and date between '2024-08-01' and '2024-09-01'
--	and event ='$MPViewScreen'
	and `$url` like '%sms%'
	and `$url` like '%short_link%'
	and `$url` like '%240722_augtestdrive%'
	and `$url` like '%2h215641b34x%'
	)x 
left join 
	(select t2.*
	from ods_invi.ods_invi_tm_invite_code_d t2 
	WHERE t2.create_time >='2024-08-01' 
	and t2.create_time <'2024-09-01'
	)t2 on toString( t2.member_id) =toString(x.memberid)
left join 
(
	-- 预约试驾
	SELECT
	distinct 
	ta.ONE_ID `客户ID`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	WHERE 1=1
	and date(ta.CREATED_AT) >= '2024-08-01'
	and date(ta.CREATED_AT) < '2024-09-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
)x2 on toString(x2.`客户ID`) =toString(x.distinct_id) 

-- sms-人群包2
SELECT 
distinct 
	 x.memberid `邀请人会员ID`,
	case when t2.member_id is not null then '是' else '否' end `是否点击后发起邀请（Y/N）`,
	case when x2.`客户ID` is not null then '是' else '否' end `是否点击后留资成功（Y/N）`
FROM (-- 人群包2
	select distinct distinct_id,memberid
	from dwd_23.dwd_23_gio_tracking g
	where length(distinct_id)<9 
    and date(event_time) >= toDateTime('2024-08-01') + interval '-30 day'
	and date between '2024-08-01' and '2024-09-01'
--	and event ='$MPViewScreen'
	and `$url` like '%sms%'
	and `$url` like '%short_link%'
	and `$url` like '%240722_augtestdrive%'
	and `$url` like '%6v215765w60f%'
	)x 
left join 
	(select t2.*
	from ods_invi.ods_invi_tm_invite_code_d t2 
	WHERE t2.create_time >='2024-08-01' 
	and t2.create_time <'2024-09-01'
	)t2 on toString( t2.member_id) =toString(x.memberid)
left join 
(
	-- 预约试驾
	SELECT
	distinct 
	ta.ONE_ID `客户ID`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	WHERE 1=1
	and date(ta.CREATED_AT) >= '2024-08-01'
	and date(ta.CREATED_AT) < '2024-09-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
)x2 on toString(x2.`客户ID`) =toString(x.distinct_id) 

-- sms-人群包3
SELECT 
distinct 
	 x.memberid `邀请人会员ID`,
	case when t2.member_id is not null then '是' else '否' end `是否点击后发起邀请（Y/N）`,
	case when x2.`客户ID` is not null then '是' else '否' end `是否点击后留资成功（Y/N）`
FROM (-- 人群包3
	select distinct distinct_id,memberid
	from dwd_23.dwd_23_gio_tracking g
	where length(distinct_id)<9 
    and date(event_time) >= toDateTime('2024-08-01') + interval '-30 day'
	and date between '2024-08-01' and '2024-09-01'
--	and event ='$MPViewScreen'
	and `$url` like '%sms%'
	and `$url` like '%short_link%'
	and `$url` like '%240722_augtestdrive%'
	and `$url` like '%3g215849r25y%'
	)x 
left join 
	(select t2.*
	from ods_invi.ods_invi_tm_invite_code_d t2 
	WHERE t2.create_time >='2024-08-01' 
	and t2.create_time <'2024-09-01'
	)t2 on toString( t2.member_id) =toString(x.memberid)
left join 
(
	-- 预约试驾
	SELECT
	distinct 
	ta.ONE_ID `客户ID`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	WHERE 1=1
	and date(ta.CREATED_AT) >= '2024-08-01'
	and date(ta.CREATED_AT) < '2024-09-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
)x2 on toString(x2.`客户ID`) =toString(x.distinct_id) 



	-- sms-人群包4
SELECT 
distinct 
	 x.memberid `邀请人会员ID`,
	case when t2.member_id is not null then '是' else '否' end `是否点击后发起邀请（Y/N）`,
	case when x2.`客户ID` is not null then '是' else '否' end `是否点击后留资成功（Y/N）`
FROM (-- 人群包4
	select distinct distinct_id,memberid
	from dwd_23.dwd_23_gio_tracking g
	where length(distinct_id)<9 
    and date(event_time) >= toDateTime('2024-08-01') + interval '-30 day'
	and date between '2024-08-01' and '2024-09-01'
	and event ='$MPViewScreen'
	and `$url` like '%sms%'
	and `$url` like '%short_link%'
	and `$url` like '%240722_augtestdrive%'
	and `$url` like '%3c215971i23p%'
	)x 
left join 
	(select t2.*
	from ods_invi.ods_invi_tm_invite_code_d t2 
	WHERE t2.create_time >='2024-08-01' 
	and t2.create_time <'2024-09-01'
	)t2 on toString( t2.member_id) =toString(x.memberid)
left join 
(
	-- 预约试驾
	SELECT
	distinct 
	ta.ONE_ID `客户ID`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	WHERE 1=1
	and date(ta.CREATED_AT) >= '2024-08-01'
	and date(ta.CREATED_AT) < '2024-09-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
)x2 on toString(x2.`客户ID`) =toString(x.distinct_id) 
