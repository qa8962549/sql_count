-- App各等级用户数量
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	count(distinct id) num
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	join (
	-- app用户
		select *
		from ods_oper_crm.ods_oper_crm_usr_gio_d_si
		where min_app is not null
		and memberid is not null 
		and min_app<'2023-08-01' -- 剔除8月以后注册app用户
		) x2 on x2.memberid::varchar=m.id::varchar -- 和app用户取交集
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1

-- App各等级用户活跃情况
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	count(distinct id) num
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	join (
	-- app活跃用户
		select *
		from ods_oper_crm.ods_oper_crm_active_gio_d_si 
		where platform ='App'
		and dt>='2023-07-01'
		and dt<'2023-08-01'
		and memberid is not null 
		) x2 on x2.memberid::varchar=m.id::varchar -- 和app用户取交集
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1

-- App各等级用户每月的平均登录天数
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	round(sum(x2.day)/count(m.id),2) `每月的平均登录天数`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (
	-- app活跃用户每个月活跃天数
		select 
		memberid,
		count(dt) day
		from ods_oper_crm.ods_oper_crm_active_gio_d_si 
		where platform ='App'
		and dt>='2023-07-01'
		and dt<'2023-08-01'
		and memberid is not null 
		group by 1
		order by 2 desc 
		) x2 on x2.memberid::varchar=m.id::varchar -- 和app用户取交集
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1
	
-- App各等级用户每月的平均签到次数
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	round(sum(x2.num)/count(m.id),2) `每月的平均签到次数`
	from ods_memb.ods_memb_tc_member_info_cur m
	join (
	-- app用户
		select *
		from ods_oper_crm.ods_oper_crm_usr_gio_d_si
		where min_app is not null
		and memberid is not null 
		and min_app<'2023-08-01' -- 剔除8月以后注册app用户
		) xx on xx.memberid::varchar=m.id::varchar -- 和app用户取交集
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (
	-- App各等级用户每月的平均签到次数
		SELECT member_id,count(1) num 
		FROM ods_mms.ods_mms_tt_sign_in_record_d a
		where create_time >='2023-07-01'
		and create_time<'2023-08-01' 
		group by 1 
		order by 2 desc 
	) x2 on x2.member_id::varchar=m.id::varchar -- 和app用户取交集
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1	
	
	
-- App各等级用户每月平均社区活跃次数：阅读、点赞、评论、转发
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	round(sum(x2.num)/count(m.id),2) `每月平均社区活跃次数`
	from ods_memb.ods_memb_tc_member_info_cur m
	join (
	-- app用户
		select *
		from ods_oper_crm.ods_oper_crm_usr_gio_d_si
		where min_app is not null
		and memberid is not null 
		and min_app<'2023-08-01' -- 剔除8月以后注册app用户
		) xx on xx.memberid::varchar=m.id::varchar -- 和app用户取交集
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (
	-- 阅读、点赞、评论、转发
		select x.member_id,
		count(1) num 
		from 
			(
			-- 浏览和分享
			select 
			a.member_id 
			from ods_cmnt.ods_cmnt_tt_view_post_cur a
			where a.is_deleted <>1
			and a.create_time >='2023-07-01'
			and a.create_time <'2023-08-01'
			and a.member_id <>'0'
			union all 
			-- 评论
			select 
			a.member_id 
			from ods_cmnt.ods_cmnt_tm_comment_cur a
			where a.is_deleted <>1
			and a.create_time >='2023-07-01'
			and a.create_time <'2023-08-01'
			union all 
			-- 点赞用户
			select
			a.member_id
			from ods_cmnt.ods_cmnt_tt_like_post_cur a
			where a.is_deleted <>1
			and a.create_time >='2023-07-01'
			and a.create_time <'2023-08-01'
			and a.like_type=0 -- 点赞
			)x 
		group by 1
		order by 2 desc 
		) x2 on x2.member_id::varchar=m.id::varchar -- 和app用户取交集
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1	
	

--	App社区月平均发帖次数（文章+动态）
		select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	round(sum(x2.num)/count(m.id),2) `月平均发帖次数`
	from ods_memb.ods_memb_tc_member_info_cur m
	join (
	-- app用户
		select *
		from ods_oper_crm.ods_oper_crm_usr_gio_d_si
		where min_app is not null
		and memberid is not null 
		and min_app<'2023-08-01' -- 剔除8月以后注册app用户
		) xx on xx.memberid::varchar=m.id::varchar -- 和app用户取交集
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (-- 发帖数量
		select 
		tp.member_id,
		count(1) num
		from ods_cmnt.ods_cmnt_tm_post_cur tp
		where 1=1
		and tp.create_time >='2023-07-01'
		and tp.create_time <'2023-08-01'
		and tp.post_type in ('1001','1007')
		and tp.is_deleted =0
		group by member_id
		) x2 on x2.member_id::varchar=m.id::varchar -- 和app用户取交集
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1	
	
	
--	App社区月优质贴总数（文章&动态加精、上推荐）
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	round(sum(x2.num)/count(m.id),5) `月平均发帖次数`
	from ods_memb.ods_memb_tc_member_info_cur m
	join (
	-- app用户
		select *
		from ods_oper_crm.ods_oper_crm_usr_gio_d_si
		where min_app is not null
		and memberid is not null 
		and min_app<'2023-08-01' -- 剔除8月以后注册app用户
		) xx on xx.memberid::varchar=m.id::varchar -- 和app用户取交集
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (-- 文章&动态加精、上推荐
			select 
			a.member_id
			,count(a.id) num 
			from ods_cmnt.ods_cmnt_tm_post_cur a
			where a.is_deleted =0
			and a.create_time >='2023-07-01'
			and a.create_time <'2023-08-01'
			and (a.recommend=1 -- 上推荐
				or a.selected_time <>0) --加精
			and a.member_id is not null 
			group by 1
		) x2 on x2.member_id::varchar=m.id::varchar -- 和app用户取交集
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1		
	
--App各等级试驾+一键留资的线索数量
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	count(x2.phone)/count(m.member_phone) `线索数量`
	from ods_memb.ods_memb_tc_member_info_cur m
	join (
	-- app用户
		select *
		from ods_oper_crm.ods_oper_crm_usr_gio_d_si
		where min_app is not null
		and memberid is not null 
		and min_app<'2023-08-01' -- 剔除8月以后注册app用户
		) xx on xx.memberid::varchar=m.id::varchar -- 和app用户取交集
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (
	-- 试驾+一键留资的线索数量
		select distinct x.phone
			from 
			(
			select
			a.customer_mobile phone
			from ods_vced.ods_vced_tm_leads_collection_pool_cur a
			left join ods_vced.ods_vced_t_sys_car_model_d c on a.preferred_model_id = c.car_model_id 
			where 1=1
			and a.`create_time` > '2023-07-01'
			and a.`create_time` < '2023-08-01'
			and a.campaign_code in
			(
				-- 一键留资
				select
				DISTINCT trim(code) code
				from ods_oper_crm.ods_oper_crm_umt001_em90_his_d   -- 一键留资表
				where 1=1 
				-- and (car_type = 'ALL' or car_type = 'EX30')    -- 筛选车型
				and channel = '一键留资'   -- 筛选一键留资
				and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = yesterday()
			)
			UNION ALL 
				--预约试驾累计
				SELECT
				m.member_phone phone
				FROM ods_cyap.ods_cyap_tt_appointment_d ta
				left join ods_memb.ods_memb_tc_member_info_cur m on toString(ta.ONE_ID)=toString(m.cust_id) 
				WHERE 1=1
				and ta.CREATED_AT >='2023-07-01'
				and ta.CREATED_AT < '2023-08-01'
				AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
				AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端	
				and ta.IS_DELETED =0
			)x where x.phone<>'*' and x.phone is not null
		)x2 on x2.phone::varchar=m.member_phone::varchar -- 和app用户取交集
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1
	
--各等级留资到店的数量
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	count(x2.phone)/count(m.member_phone) `留资到店的数量`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (
			-- 留资到店
				SELECT
				m.member_phone phone
				FROM ods_cyap.ods_cyap_tt_appointment_d ta
				left join ods_memb.ods_memb_tc_member_info_cur m on toString(ta.ONE_ID)=toString(m.cust_id) 
				WHERE 1=1
				and ta.CREATED_AT >='2023-07-01'
				and ta.CREATED_AT < '2023-08-01'
--				AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
				AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端	
				and ta.IS_DELETED =0
				and ta.ARRIVAL_DATE>='2000-01-01' -- 到店
				and left(m.member_phone,1)='1'
		)x2 on x2.phone=m.member_phone -- 和app用户取交集
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1	
	
--各等级平均留资后到店的天数
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	count(x2.phone)/count(m.member_phone) `留资到店的数量`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (	
	--留资后到店的天数
				SELECT m.member_phone phone,
				toUInt32(toDate(ARRIVAL_DATE)) - toUInt32(toDate(CREATED_AT)) num 
				FROM ods_cyap.ods_cyap_tt_appointment_d ta
				left join ods_memb.ods_memb_tc_member_info_cur m on toString(ta.ONE_ID)=toString(m.cust_id) 
				WHERE 1=1
				and ta.CREATED_AT >='2023-07-01'
				and ta.CREATED_AT < '2023-08-01'
				AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端	
				and ta.IS_DELETED =0
				and ta.ARRIVAL_DATE>='2000-01-01' -- 到店
				)x2 on x2.phone=m.member_phone 
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1	

-- 	各等级留资后的订单数量	
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	sum(x2.num)/count(m.id) `留资后的订单数量`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (	
--	留资后的订单数量
			SELECT 
			ta.CUSTOMER_PHONE,
			count(x.drawer_tel) num 
			FROM ods_cyap.ods_cyap_tt_appointment_d ta
			left join 
				(
				-- 有效购车订单
				select distinct
				drawer_tel,
				a.created_at 
				FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
				where 1=1 
				and a.so_status in (14041001,14041002,14041003,14041008,14041030) -- 有效订单
				and a.is_deposit in (10421009,10041001,10041002,70961001,70961002) -- 是否交定金
				and a.created_at >= '2023-07-01'
				and a.created_at < '2023-08-01'
				and a.is_deleted = 0
				) x on toString(x.drawer_tel)=toString(ta.CUSTOMER_PHONE) 
			WHERE 1=1
			and ta.CREATED_AT >='2023-07-01'
			and ta.CREATED_AT < '2023-08-01'
			AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端	
			and ta.IS_DELETED =0
			and date(ta.CREATED_AT)>=date(x.created_at)
			group by 1 
			order by 2 desc 
				)x2 on x2.CUSTOMER_PHONE=m.member_phone  
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1	
	
			
--各等级平均留资后订单的天数
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	sum(x2.num)/count(m.id) `留资后订单的天数`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (	
		--留资后到店的天数
			SELECT ta.CUSTOMER_PHONE,
			ifnull(toUInt32(toDate(x.created_at)) - toUInt32(toDate(ta.CREATED_AT)),0)num 
			FROM ods_cyap.ods_cyap_tt_appointment_d ta
			left join 
				(
				-- 有效购车订单
				select distinct
				drawer_tel,
				a.created_at 
				FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
				where 1=1 
				and a.so_status in (14041001,14041002,14041003,14041008,14041030) -- 有效订单
				and a.is_deposit in (10421009,10041001,10041002,70961001,70961002) -- 是否交定金
				and a.created_at >= '2023-07-01'
				and a.created_at < '2023-08-01'
				and a.is_deleted = 0
				) x on toString(x.drawer_tel)=toString(ta.CUSTOMER_PHONE) 
			WHERE 1=1
			and ta.CREATED_AT >='2023-07-01'
			and ta.CREATED_AT < '2023-08-01'
			AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端	
			and ta.IS_DELETED =0
			and num>=0
			order by 2  
			)x2 on x2.CUSTOMER_PHONE=m.member_phone 
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1	

	
--各等级邀请好友试驾线索数
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	sum(x2.num)/count(m.id) `邀请好友试驾线索数`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (
		-- 邀约试驾 当月总留资量
			SELECT 
				t1.invite_member_id ,
				count(t1.be_invite_member_id) num 
			FROM ods_invi.ods_invi_tm_invite_record_d t1 
			WHERE 1=1
			and t1.create_time >='2024-07-01' 
			and t1.create_time <'2024-08-01'
			group by 1 
		)x2 on x2.invite_member_id=m.id 
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1		
	


	
--各等级邀请好友到店试驾数量
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	count(x2.`被邀请人会员ID`)/count(m.id) `邀请好友试驾线索数`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (
		-- 邀约试驾 当月总留资量
			SELECT 
			t1.invite_member_id `邀请人会员ID`,
				t1.be_invite_member_id `被邀请人会员ID`,
				t1.be_invite_mobile `被邀请人会员手机号`,
				t1.reserve_time `留资时间`,
				t1.be_invite_mobile `被邀请人手机号`,
				t1.vehicle_name `留资车型`,
				t1.drive_time `实际试驾时间`
			FROM ods_invi.ods_invi_tm_invite_record_d t1
			WHERE 1=1
			and date(t1.reserve_time)>='2023-07-01' -- 留资时间
			and date(t1.reserve_time)<'2023-08-01'
			and t1.drive_time>='2000-01-01'
			and t1.is_deleted=0
		)x2 on x2.`邀请人会员ID`=m.id 
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1	
	

--各等级邀请好友试驾后到店的天数
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	sum(x2.num)/count(m.id) `邀请好友试驾后到店的天数`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
	left join (
		-- 邀约试驾 当月总留资量
			SELECT 
				t1.invite_member_id `邀请人会员ID`,
				ifnull(toUInt32(toDate(t1.drive_time)) - toUInt32(toDate(t1.reserve_time)),0) num 
			FROM  ods_invi.ods_invi_tm_invite_record_d t1
			WHERE 1=1
			and date(t1.reserve_time)>='2023-07-01' -- 留资时间
			and date(t1.reserve_time)<'2023-08-01'
			and t1.drive_time>='2000-01-01'
			and t1.is_deleted=0
		)x2 on x2.`邀请人会员ID`=m.id 
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1		
	
	
		

--各等级邀请好友试驾的订单数量
select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	sum(x2.num)/count(m.id) `邀请好友试驾后到店的天数`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
				)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
			)x on x.MEMBER_ID=m.id
		left join (-- 活动到店试驾后购车数（新增需求）
			SELECT 
			tir.invite_member_id invite_member_id,
			count(case when tir.drive_time>='2000-01-01' then 1 else null end) num  -- `邀请试驾-到店试驾量_活动到店试驾后购车数`
			from ods_invi.ods_invi_tm_invite_record_d tir 
			left join ods_memb.ods_memb_tc_member_info_cur m on toString(tir.invite_member_id)=toString(m.id)  
			join
			(
				select
				distinct a.phone_num
				from
				(
					select
					o.customer_tel phone_num
					from ods_cydr.ods_cydr_tt_sales_orders_cur o 
					where o.is_deleted  = 0
					AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
					UNION ALL  
					select
					o.drawer_tel phone_num
					from ods_cydr.ods_cydr_tt_sales_orders_cur o 
					where o.is_deleted  = 0
					AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')	
					UNION ALL  
					select
					o.purchase_phone phone_num
					from ods_cydr.ods_cydr_tt_sales_orders_cur o
					where o.is_deleted  = 0
					AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
				) a
				where length(a.phone_num) = '11'
				and left(a.phone_num,1) = '1'
			)x2 on m.member_phone =x2.phone_num
			where tir.is_deleted=0
			and date(tir.reserve_time)>= '2023-07-01'
			and date(tir.reserve_time)<'2023-08-01'
			and tir.be_invite_member_id is not null 
			group by 1 
			order by 2 desc
			)x2 on x2.invite_member_id=m.id 
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1	

-- 活动到店试驾后购车数（新增需求）
			SELECT 
			*
			from ods_invi.ods_invi_tm_invite_record_d tir 
--			left join ods_memb.ods_memb_tc_member_info_cur m on toString(tir.invite_member_id)=toString(m.id)  
			where tir.is_deleted=0
			and date(tir.create_time)>= '2024-04-01'
			and date(tir.create_time)<'2024-08-01'
			and tir.be_invite_member_id is not null 
			and invite_code is not null 

			
	
--各等级平均邀请好友试驾订单的天数
select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	sum(x2.num)/count(m.id) `邀请好友试驾订单的天数`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
				)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
			)x on x.MEMBER_ID=m.id
		left join (-- 活动到店试驾后购车数（新增需求）
			SELECT 
			tir.be_invite_member_id be_invite_member_id,
			ifnull(toUInt32(toDate(x2.tt)) - toUInt32(toDate(tir.reserve_time)),0) num 
			from ods_invi.ods_invi_tm_invite_record_d tir 
			left join ods_memb.ods_memb_tc_member_info_cur m on toString(tir.be_invite_member_id)=toString(m.id)  
			join
			(
					select
					distinct o.customer_tel phone_num,
					toDate(created_at) tt
					from ods_cydr.ods_cydr_tt_sales_orders_cur o 
					where o.is_deleted  = 0
					AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
					and  length(o.customer_tel) = '11'
					and  left(o.customer_tel,1) = '1'
			)x2 on m.member_phone =x2.phone_num
			where tir.is_deleted=0
			and date(tir.reserve_time)>= '2023-07-01'
			and date(tir.reserve_time)<'2023-08-01'
			and tir.be_invite_member_id is not null 
			and x2.tt>tir.reserve_time
			)x2 on x2.be_invite_member_id=m.id 
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1	
	
				select
					count(distinct o.customer_tel) ,
					count(distinct o.drawer_tel) ,
					count(distinct o.purchase_phone) 
					from ods_cydr.ods_cydr_tt_sales_orders_cur o 
					where o.is_deleted  = 0
					AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')	
	
			
--各等级人均线上商城订单：all、OKR
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	sum(x2.num)/count(m.id) `商城订单`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
		left join (	
		--商城下单
			select
			a.user_id `下单人会员ID`,
			count(user_id) num 
--			sum(b.fee/100) RMB
			--sum(b.point_amount/3+b.pay_fee/100) `实付金额(元)`
			from ods_orde.ods_orde_tt_order_d a    -- 订单表
			left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
			where 1=1
			and a.create_time >= '2023-07-01' 
			and a.create_time < '2023-08-01'   -- 订单时间
			and a.is_deleted <> 1
			and b.is_deleted <> 1
			and a.type = '31011003'  -- 订单类型：沃世界商城订单
			and a.separate_status = '10041002' -- 拆单状态：否
			and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
			AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
			-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			-- and g.order_code is not null  -- 剔除退款订单
			group by 1 
			order by 1)x2 on x2.`下单人会员ID`::String=m.id::String
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1	
			
			
--各等级人均线下售后工单：实付金额
	select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	sum(x2.RMB)/count(m.id) `线下售后工单：实付金额`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2023-07-01'
			and CREATE_TIME<'2023-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
		left join (
			-- 2、售后工单总金额、人数、工单数
			select
			ifnull(o.OWNER_ONE_ID,oc.ONE_ID) OWNER_ONE_ID,
			sum(o.BALANCE_AMOUNT) RMB
			from ods_cyre.ods_cyre_tt_repair_order_d o
			left join ods_cyre.ods_cyre_tm_owner_d oc on o.OWNER_NO =oc.OWNER_NO and o.OWNER_CODE =oc.OWNER_CODE 
			where o.IS_DELETED = 0
			and o.REPAIR_TYPE_CODE <> 'P'
			and o.RO_STATUS = '80491003'    -- 已结算工单
			and o.RO_CREATE_DATE >= '2023-07-01'
			and o.RO_CREATE_DATE < '2023-08-01'
			and OWNER_ONE_ID is not null 
			group by 1 
			order by 1 
			)x2 on x2.OWNER_ONE_ID::varchar=m.cust_id::varchar
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2023-08-01' -- 剔除8月之后注册的用户
	and m.cust_id is not null 
	group by 1
	order by 1	

			
	
--各等级人均总消费
select 
	case when x.OLD_LEVEL_ID<>0 then OLD_LEVEL_ID else m.level_id end as level_id ,
	sum(x2.RMB)/count(m.id) `商城订单`
	from ods_memb.ods_memb_tc_member_info_cur m
	left join 
		(
		-- 找出用户每个月最新的变更前等级
		select x.MEMBER_ID,
		x.t,
		x.mt,
		c2.OLD_LEVEL_ID
		from 
			(
			-- 历史等级
			select 
			MEMBER_ID,
			toStartOfMonth(CREATE_TIME) t,
			max(CREATE_TIME) mt 
			from ods_memb.ods_memb_tt_member_level_change_d c
			where 1=1
			and c.IS_DELETED =0
			and CREATE_TIME>='2024-07-01'
			and CREATE_TIME<'2024-08-01'
			and MEMBER_LEVEL_NEW<>0
			and MEMBER_LEVEL_OLD<>0
			group by 1,2
			order by 1,2
			)x
		left join ods_memb.ods_memb_tt_member_level_change_d c2 on c2.MEMBER_ID=x.MEMBER_ID and c2.CREATE_TIME=x.mt
		)x on x.MEMBER_ID=m.id
		left join (	
		--商城下单
			select
			a.user_id `下单人会员ID`,
--			count(user_id) num 
			sum(b.fee/100) RMB
			from ods_orde.ods_orde_tt_order_d a    -- 订单表
			left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
			where 1=1
			and a.create_time >= '2024-07-01' 
			and a.create_time < '2024-08-01'   -- 订单时间
			and a.is_deleted <> 1
			and b.is_deleted <> 1
			and a.type = '31011003'  -- 订单类型：沃世界商城订单
			and a.separate_status = '10041002' -- 拆单状态：否
			and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
			AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
			-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			-- and g.order_code is not null  -- 剔除退款订单
			group by 1 
			order by 1)x2 on x2.`下单人会员ID`::String=m.id::String
	where 1=1
	and m.is_deleted =0
	and m.member_status <> '60341003'
	and m.create_time <'2024-08-01' -- 剔除8月之后注册的用户
	group by 1
	order by 1		

select 
m.level_id ,
count(1)
from ods_memb.ods_memb_tc_member_info_cur m
where m.is_deleted =0
group by 1
order by 1 



	
--留资量及渠道占比
--订单量及渠道占比
select 
date_trunc('month',toDate(x.`create_time`)) t,
count(distinct x2.mobile)
from 
(
select mobile,create_time
from ods_cust.ods_cust_tt_clue_clean_cur a
left join ods_actv.ods_actv_cms_active_d c on a.campaign_id = c.uid
where 1=1
and date(a.`create_time`) >='2023-07-01'
and date(a.`create_time`) < '2024-08-01'
and c.active_code in ()
union all 
select customer_mobile,create_time
from ods_vced.ods_vced_tm_leads_collection_pool_cur a
where 1=1
and date(a.`create_time`) >='2023-07-01'
and date(a.`create_time`) < '2024-08-01'
and a.campaign_code in
		()
)x
group by 1 
order by 1 
	
--订单量及渠道占比
select 
date_trunc('month',toDate(x.mt)) t,
count(distinct x2.drawer_tel)
from 
	(
	select distinct x.mobile,
	min(x.t) mt 
		from (
			select mobile,create_time t
			from ods_cust.ods_cust_tt_clue_clean_cur a
			left join ods_actv.ods_actv_cms_active_d c on a.campaign_id = c.uid
			where 1=1
			and date(a.`create_time`) >='2023-07-01'
			and date(a.`create_time`) < '2023-08-01'
			and c.active_code in ()
			union all 
			select customer_mobile,create_time t
			from ods_vced.ods_vced_tm_leads_collection_pool_cur a
			where 1=1
			and date(a.`create_time`) >='2023-07-01'
			and date(a.`create_time`) < '2023-08-01'
			and a.campaign_code in
					()
		)x
		group by 1 
		order by 1 
	)x
left join 
		(
		-- 有效购车订单
		select
		drawer_tel,
		a.created_at 
		FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
		where 1=1 
		and a.so_status in (14041001,14041002,14041003,14041008,14041030) -- 有效订单
		and a.is_deposit in (10421009,10041001,10041002,70961001,70961002) -- 是否交定金
		and a.created_at >= '2023-07-01'
		and a.created_at < '2023-08-01'
		and a.is_deleted = 0
		) x2 on toString(x2.drawer_tel)=toString(x.mobile) 
group by 1 
order by 1 

--非私域渠道留资-订单平均天数
select 
--date_trunc('month',toDate(x.mt)) t,
sum(x.num)/count(distinct x.mobile)
from 
	(
	select 
	x.mobile,
	toUInt32(toDate(x2.created_at)) - toUInt32(toDate(x.mt)) num 
	from 
		(
		select distinct x.mobile,
		min(x.t) mt 
			from (
				select mobile,create_time t
				from ods_cust.ods_cust_tt_clue_clean_cur a
				left join ods_actv.ods_actv_cms_active_d c on a.campaign_id = c.uid
				where 1=1
				and date(a.`create_time`) >='2023-07-01'
				and date(a.`create_time`) < '2023-08-01'
				and c.active_code in ('IBDMMARWSJGZHHYY2023VCCN',
	'IBDMAPRWSJZCHYT12023VCCN',
	'IBDMAPRWSJYYSJT12023VCCN',
	'IBDMAPRWSJZCHYT22023VCCN',
	'IBDMNOV3WDYMYYSJ2021VCCN',
	'WSJYY',
	'IBDMJUNALLKSYYMP2023VCCN',
	'IBDMJULALLWCDWXC2023VCCN',
	'IBCRMJUNWEWAPPSJ2022VCCN',
	'IBDMJANS905GZSBT2023VCCN',
	'IBDMJANS603GZSBT2023VCCN',
	'IBDMFEBS905GZSBT2023VCCN',
	'IBDMJANC40XC4DJP2023VCCN',
	'IBDMAPRC40XSBQET2023VCCN',
	'IBDMAPRS90BTHYHJ2023VCCN',
	'IBDMAPRXC40RYYSJ2023VCCN',
	'IBDMAPRXC40BYYSJ2023VCCN',
	'IBDMAPRC40BEYYSJ2023VCCN',
	'IBDMAPRXC60YYSJI2023VCCN',
	'IBDMAPRXC6T8YYSJ2023VCCN',
	'IBDMAPRS60YYSJIA2023VCCN',
	'IBDMAPRS60T8YYSJ2023VCCN',
	'IBDMAPRV60YYSJIA2023VCCN',
	'IBDMAPRXC90YYSJI2023VCCN',
	'IBDMAPRXC9T8YYSJ2023VCCN',
	'IBDMAPRS90YYSJIA2023VCCN',
	'IBDMAPRS90T8YYSJ2023VCCN',
	'IBDMAPRV90CCYYSJ2023VCCN',
	'IBDMMAYC40BEVYSJ2023VCCN',
	'IBDMMAYXC40BEVSJ2023VCCN',
	'IBDMMAYV90CCYYSJ2023VCCN',
	'IBDMMAYV60CXZCSJ2023VCCN',
	'IBDMMAYXC40RYBSJ2023VCCN',
	'IBDMMAYXC60CYYSJ2023VCCN',
	'IBDMMAYS60CXZCSJ2023VCCN',
	'IBDMMAYXC90CYYSJ2023VCCN',
	'IBDMMAYS90CXZCSJ2023VCCN',
	'IBDMJUNXC4CXZCSJ2023VCCN',
	'IBDMJUNXC4BCXPSJ2023VCCN',
	'IBDMJUNC40BCXPSJ2023VCCN',
	'IBDMJUNXC6CXZCSJ2023VCCN',
	'IBDMJUNS60CXZCSJ2023VCCN',
	'IBDMJUNV60CXZCSJ2023VCCN',
	'IBDMJUNXC9CXZCSJ2023VCCN',
	'IBDMJUNS90CXZCSJ2023VCCN',
	'IBDMJUNV90CXZCSJ2023VCCN',
	'IBDMJULXC4CXZCSJ2023VCCN',
	'IBDMJULX4BCXZCSJ2023VCCN',
	'IBDMJULC4BCXZCSJ2023VCCN',
	'IBDMJULXC6CXZCSJ2023VCCN',
	'IBDMJULS60CXZCSJ2023VCCN',
	'IBDMJULV60CXZCSJ2023VCCN',
	'IBDMJULXC9CXZCSJ2023VCCN',
	'IBDMJULS90CXZCSJ2023VCCN',
	'IBDMJULV90CXZCSJ2023VCCN',
	'IBDMAUGXC4ICPRTD2023VCCN',
	'IBDMAUGXC4BCPRTD2023VCCN',
	'IBDMAUGC40BCPRTD2023VCCN',
	'IBDMAUGXC60CPRTD2023VCCN',
	'IBDMAUGS609CPRTD2023VCCN',
	'IBDMAUGV609CPRTD2023VCCN',
	'IBDMAUGXC90CPRTD2023VCCN',
	'IBDMAUGS909CPRTD2023VCCN',
	'IBDMAUGV90CCPRTD2023VCCN',
	'IBCRMDECALL000222023VCCN',
	'IBCRMNOVALL000082023VCCN',
	'IBCRMOCTALL000112023VCCN',
	'IBCRMJANALL000032024VCCN',
	'IBCRMFEBALL000012024VCCN',
	'IBCRMMARALL000012024VCCN',
	'IBCRMAPRALL000032024VCCN',
	'IBCRMMAYALL000462024VCCN',
	'IBDMDECHBJHHDXCX2022VCCN',
	'IBDMDECHBJHHDAPP2022VCCN',
	'IBDMMARHBJHLZXCX2023VCCN',
	'IBDMMARHBJHLZAPP2023VCCN',
	'IBDMJUNALLWSJXCX2023VCCN',
	'IBDMJUNALLWEWAPP2023VCCN',
	'IBDMSEPMIXTJXHLM2023VCCN',
	'IBDMSEPMIXTJXHLA2023VCCN',
	'IBCRMJANALL000042024VCCN',
	'IBCRMJANALL000052024VCCN',
	'IBCRMJANALL000482024VCCN',
	'IBCRMFEBALL000472024VCCN',
	'IBCRMMARALL000272024VCCN',
	'IBCRMMARALL000262024VCCN',
	'IBCRMJUNALL000502024VCCN',
	'IBCRMJUNALL000492024VCCN',
	'IBDMMARXC4C40XCX2023VCCN',
	'IBDMAPR525YYSXCX2023VCCN',
	'IBDMMAYVXS469XCX2023VCCN',
	'IBDMJUNALLXSSJMP2023VCCN',
	'IBCRMAUGALL000102023VCCN',
	'IBDMAUGMIXSJXCXD2023VCCN',
	'IBCRMSEPALL000572023VCCN',
	'IBCRMNOVALL000302023VCCN',
	'IBCRMDECALL000152023VCCN',
	'IBCRMJANALL000062024VCCN',
	'IBCRMJANALL000492024VCCN',
	'IBCRMMARALL000162024VCCN',
	'IBCRMAPRALL000662024VCCN',
	'IBCRMMAYALL000722024VCCN',
	'IBCRMJUNALL000482024VCCN',
	'IBCRMJULALL000142024VCCN',
	'IBCRMSEPALL000212024VCCN',
	'IBDMSEPMIXGEFXCX2023VCCN',
	'IBCRMJUNALL000322024VCCN',
	'IBCRMJUNALL000312024VCCN',
	'IBCRMJUNALL000542024VCCN  ',
	'IBCRMJUNALL000532024VCCN  ',
	'IBAUTOAUGALLAUA000052024VCCN',
	'IBCRMJULALL000102024VCCN',
	'IBCRMJUNALL000572024VCCN',
	'IBCRMAUGS90000222024VCCN')
				union all 
				select customer_mobile,create_time t
				from ods_vced.ods_vced_tm_leads_collection_pool_cur a
				where 1=1
				and date(a.`create_time`) >='2023-07-01'
				and date(a.`create_time`) < '2023-08-01'
				and a.campaign_code in
						('IBDMMARWSJGZHHYY2023VCCN',
	'IBDMAPRWSJZCHYT12023VCCN',
	'IBDMAPRWSJYYSJT12023VCCN',
	'IBDMAPRWSJZCHYT22023VCCN',
	'IBDMNOV3WDYMYYSJ2021VCCN',
	'WSJYY',
	'IBDMJUNALLKSYYMP2023VCCN',
	'IBDMJULALLWCDWXC2023VCCN',
	'IBCRMJUNWEWAPPSJ2022VCCN',
	'IBDMJANS905GZSBT2023VCCN',
	'IBDMJANS603GZSBT2023VCCN',
	'IBDMFEBS905GZSBT2023VCCN',
	'IBDMJANC40XC4DJP2023VCCN',
	'IBDMAPRC40XSBQET2023VCCN',
	'IBDMAPRS90BTHYHJ2023VCCN',
	'IBDMAPRXC40RYYSJ2023VCCN',
	'IBDMAPRXC40BYYSJ2023VCCN',
	'IBDMAPRC40BEYYSJ2023VCCN',
	'IBDMAPRXC60YYSJI2023VCCN',
	'IBDMAPRXC6T8YYSJ2023VCCN',
	'IBDMAPRS60YYSJIA2023VCCN',
	'IBDMAPRS60T8YYSJ2023VCCN',
	'IBDMAPRV60YYSJIA2023VCCN',
	'IBDMAPRXC90YYSJI2023VCCN',
	'IBDMAPRXC9T8YYSJ2023VCCN',
	'IBDMAPRS90YYSJIA2023VCCN',
	'IBDMAPRS90T8YYSJ2023VCCN',
	'IBDMAPRV90CCYYSJ2023VCCN',
	'IBDMMAYC40BEVYSJ2023VCCN',
	'IBDMMAYXC40BEVSJ2023VCCN',
	'IBDMMAYV90CCYYSJ2023VCCN',
	'IBDMMAYV60CXZCSJ2023VCCN',
	'IBDMMAYXC40RYBSJ2023VCCN',
	'IBDMMAYXC60CYYSJ2023VCCN',
	'IBDMMAYS60CXZCSJ2023VCCN',
	'IBDMMAYXC90CYYSJ2023VCCN',
	'IBDMMAYS90CXZCSJ2023VCCN',
	'IBDMJUNXC4CXZCSJ2023VCCN',
	'IBDMJUNXC4BCXPSJ2023VCCN',
	'IBDMJUNC40BCXPSJ2023VCCN',
	'IBDMJUNXC6CXZCSJ2023VCCN',
	'IBDMJUNS60CXZCSJ2023VCCN',
	'IBDMJUNV60CXZCSJ2023VCCN',
	'IBDMJUNXC9CXZCSJ2023VCCN',
	'IBDMJUNS90CXZCSJ2023VCCN',
	'IBDMJUNV90CXZCSJ2023VCCN',
	'IBDMJULXC4CXZCSJ2023VCCN',
	'IBDMJULX4BCXZCSJ2023VCCN',
	'IBDMJULC4BCXZCSJ2023VCCN',
	'IBDMJULXC6CXZCSJ2023VCCN',
	'IBDMJULS60CXZCSJ2023VCCN',
	'IBDMJULV60CXZCSJ2023VCCN',
	'IBDMJULXC9CXZCSJ2023VCCN',
	'IBDMJULS90CXZCSJ2023VCCN',
	'IBDMJULV90CXZCSJ2023VCCN',
	'IBDMAUGXC4ICPRTD2023VCCN',
	'IBDMAUGXC4BCPRTD2023VCCN',
	'IBDMAUGC40BCPRTD2023VCCN',
	'IBDMAUGXC60CPRTD2023VCCN',
	'IBDMAUGS609CPRTD2023VCCN',
	'IBDMAUGV609CPRTD2023VCCN',
	'IBDMAUGXC90CPRTD2023VCCN',
	'IBDMAUGS909CPRTD2023VCCN',
	'IBDMAUGV90CCPRTD2023VCCN',
	'IBCRMDECALL000222023VCCN',
	'IBCRMNOVALL000082023VCCN',
	'IBCRMOCTALL000112023VCCN',
	'IBCRMJANALL000032024VCCN',
	'IBCRMFEBALL000012024VCCN',
	'IBCRMMARALL000012024VCCN',
	'IBCRMAPRALL000032024VCCN',
	'IBCRMMAYALL000462024VCCN',
	'IBDMDECHBJHHDXCX2022VCCN',
	'IBDMDECHBJHHDAPP2022VCCN',
	'IBDMMARHBJHLZXCX2023VCCN',
	'IBDMMARHBJHLZAPP2023VCCN',
	'IBDMJUNALLWSJXCX2023VCCN',
	'IBDMJUNALLWEWAPP2023VCCN',
	'IBDMSEPMIXTJXHLM2023VCCN',
	'IBDMSEPMIXTJXHLA2023VCCN',
	'IBCRMJANALL000042024VCCN',
	'IBCRMJANALL000052024VCCN',
	'IBCRMJANALL000482024VCCN',
	'IBCRMFEBALL000472024VCCN',
	'IBCRMMARALL000272024VCCN',
	'IBCRMMARALL000262024VCCN',
	'IBCRMJUNALL000502024VCCN',
	'IBCRMJUNALL000492024VCCN',
	'IBDMMARXC4C40XCX2023VCCN',
	'IBDMAPR525YYSXCX2023VCCN',
	'IBDMMAYVXS469XCX2023VCCN',
	'IBDMJUNALLXSSJMP2023VCCN',
	'IBCRMAUGALL000102023VCCN',
	'IBDMAUGMIXSJXCXD2023VCCN',
	'IBCRMSEPALL000572023VCCN',
	'IBCRMNOVALL000302023VCCN',
	'IBCRMDECALL000152023VCCN',
	'IBCRMJANALL000062024VCCN',
	'IBCRMJANALL000492024VCCN',
	'IBCRMMARALL000162024VCCN',
	'IBCRMAPRALL000662024VCCN',
	'IBCRMMAYALL000722024VCCN',
	'IBCRMJUNALL000482024VCCN',
	'IBCRMJULALL000142024VCCN',
	'IBCRMSEPALL000212024VCCN',
	'IBDMSEPMIXGEFXCX2023VCCN',
	'IBCRMJUNALL000322024VCCN',
	'IBCRMJUNALL000312024VCCN',
	'IBCRMJUNALL000542024VCCN  ',
	'IBCRMJUNALL000532024VCCN  ',
	'IBAUTOAUGALLAUA000052024VCCN',
	'IBCRMJULALL000102024VCCN',
	'IBCRMJUNALL000572024VCCN',
	'IBCRMAUGS90000222024VCCN')
			)x
			group by 1 
			order by 1 
		)x
	left join 
			(
			-- 有效购车订单
			select
			drawer_tel,
			a.created_at 
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
			where 1=1 
			and a.so_status in (14041001,14041002,14041003,14041008,14041030) -- 有效订单
			and a.is_deposit in (10421009,10041001,10041002,70961001,70961002) -- 是否交定金
			and a.created_at >= '2023-07-01'
			and a.created_at < '2023-08-01'
			and a.is_deleted = 0
			) x2 on toString(x2.drawer_tel)=toString(x.mobile) 
	where x2.created_at>=x.mt
	--group by 1 
	order by 2 desc 
)x 



