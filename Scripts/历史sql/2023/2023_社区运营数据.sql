-- 提交预约试驾前6个月内浏览过此刻页面的用户
	SELECT
	date_trunc('year',ta.CREATED_AT) tt,
	count(distinct ta.ONE_ID)
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	global left join (
		-- 清洗cust_id
		select m.id,m.cust_id
		from 
			(-- 清洗cust_id
			select m.*,
			row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status<>'60341003' and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(ta.ONE_ID) = toString(h.cust_id)   -- 会员表(获取会员信息)
	global left join (
		-- 浏览过页面的用户
			select 
			distinct distinct_id,date
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in('Page_entry','Page_view')
			and page_title ='此刻'
--			and page_title ='此地'
			and date>='2022-01-01'
			and date<'2023-12-16'
			and length(distinct_id)<=9
			)x on toString(x.distinct_id)=toString(h.cust_id) 
	WHERE ta.CREATED_AT >= '2022-01-01'
	AND ta.CREATED_AT <'2023-12-16'
	and x.date>=toDate(ta.CREATED_AT+ interval '-180 day') 
	and x.date<=toDate(ta.CREATED_AT) 
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	group by tt 

-- 提交预约试驾前6个月内浏览过社区推荐页面的用户浏览时长大于5s且有过点击行为
	SELECT
	date_trunc('year',ta.CREATED_AT) tt,
	count(distinct ta.ONE_ID)
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	global left join (
		-- 清洗cust_id
		select m.id,m.cust_id
		from 
			(-- 清洗cust_id
			select m.*,
			row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status<>'60341003' and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(ta.ONE_ID) = toString(h.cust_id)   -- 会员表(获取会员信息)
	global left join (
		-- 浏览过页面的用户 大于5s
			select 
			distinct a.distinct_id,a.date
			from ods_rawd.ods_rawd_events_d_di a
			where 1=1
			and event in('Page_entry','Page_view')
			and page_title in ('推荐','社区推荐页')
			and view_duration_1>=5 --浏览时长大于5s
			and date>='2022-01-01'
			and date<'2023-12-16'
			and length(a.distinct_id)<=9
			and a.distinct_id in (select distinct_id from ods_oper_crm.tuijian_click)
			)x on toString(x.distinct_id)=toString(h.cust_id) 
	WHERE ta.CREATED_AT >= '2022-01-01'
	AND ta.CREATED_AT <'2023-12-16'
	and x.date>=toDate(ta.CREATED_AT+ interval '-180 day') 
	and x.date<=toDate(ta.CREATED_AT) 
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	group by tt 
	
-- 点击用户
CREATE TABLE IF NOT EXISTS tuijian_click
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
-- 点击用户
select 
distinct distinct_id
from ods_rawd.ods_rawd_events_d_di
where 1=1
and event ='Button_click'
and page_title in ('推荐','社区推荐页')
and date>='2022-01-01'
and date<'2023-12-16'
and length(distinct_id)<=9
	
--预约试驾总用户数
	SELECT
	date_trunc('year',ta.CREATED_AT) tt,
	count(distinct ta.ONE_ID)
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	WHERE ta.CREATED_AT >= '2022-01-01'
	AND ta.CREATED_AT <'2023-12-16'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ta.IS_DELETED ='0'
	group by tt 
	
-- 到店试驾前6个月内浏览过此刻页面的用户
	SELECT
	date_trunc('year',ta.CREATED_AT) tt,
	count(distinct ta.ONE_ID)
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON toString(tad.APPOINTMENT_ID) = toString(ta.APPOINTMENT_ID )
	global left join (
		-- 清洗cust_id
		select m.id,m.cust_id
		from 
			(-- 清洗cust_id
			select m.*,
			row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status<>'60341003' and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(ta.ONE_ID) = toString(h.cust_id)   -- 会员表(获取会员信息)
	global left join (
		-- 浏览过页面的用户
			select 
			distinct distinct_id,date
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in('Page_entry','Page_view')
--			and page_title ='此刻'
			and page_title ='此地'
			and date>='2022-01-01'
			and date<'2023-12-16'
			and length(distinct_id)<=9
			)x on toString(x.distinct_id)=toString(h.cust_id) 
	WHERE ta.CREATED_AT >= '2022-01-01'
	AND ta.CREATED_AT <'2023-12-16'
	and x.date>=toDate(ta.CREATED_AT+ interval '-180 day') 
	and x.date<=toDate(ta.CREATED_AT) 
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tad.STATUS ='70711002' -- 已试驾
	group by tt 

-- 到店试驾前6个月内浏览过推荐页页面的用户浏览时长大于5s且有过点击行为
	SELECT
	date_trunc('year',ta.CREATED_AT) tt,
	count(distinct ta.ONE_ID)
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON toString(tad.APPOINTMENT_ID) = toString(ta.APPOINTMENT_ID )
	global left join (
		-- 清洗cust_id
		select m.id,m.cust_id
		from 
			(-- 清洗cust_id
			select m.*,
			row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status<>'60341003' and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(ta.ONE_ID) = toString(h.cust_id)   -- 会员表(获取会员信息)
	global left join (
		-- 浏览过页面的用户 大于5s
			select 
			distinct a.distinct_id,a.date
			from ods_rawd.ods_rawd_events_d_di a
			where 1=1
			and event in('Page_entry','Page_view')
			and page_title in ('推荐','社区推荐页')
			and view_duration_1>=5 --浏览时长大于5s
			and date>='2022-01-01'
			and date<'2023-12-16'
			and length(a.distinct_id)<=9
			and a.distinct_id in (select distinct_id from ods_oper_crm.tuijian_click)
			)x on toString(x.distinct_id)=toString(h.cust_id) 
	WHERE ta.CREATED_AT >= '2022-01-01'
	AND ta.CREATED_AT <'2023-12-16'
	and x.date>=toDate(ta.CREATED_AT+ interval '-180 day') 
	and x.date<=toDate(ta.CREATED_AT) 
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tad.STATUS ='70711002' -- 已试驾
	group by tt 
	
--	到店试驾总用户数
	SELECT
	date_trunc('year',ta.CREATED_AT) tt,
	count(distinct ta.ONE_ID)
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON toString(tad.APPOINTMENT_ID) = toString(ta.APPOINTMENT_ID )
	WHERE ta.CREATED_AT >= '2022-01-01'
	AND ta.CREATED_AT <'2023-12-16'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tad.STATUS ='70711002' -- 已试驾
	group by tt 
	

--下订前6个月内浏览过社区此刻页面的用户
select 
date_trunc('year',toDate(a.created_at)) tt,
count(distinct tmi.cust_id)
FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
left join ods_cydr.ods_cydr_tt_sales_order_vin_cur b on toString(a.so_no) = toString(b.vi_no) 
left join ods_cydr.ods_cydr_tt_sales_order_detail_d c on toString(c.SALES_OEDER_DETAIL_ID) = toString(b.sales_oeder_detail_id) 
left join ods_memb.ods_memb_tc_member_info_cur tmi on toString(a.customer_tel) =toString(tmi.member_phone) 
global left join (
		-- 浏览过页面的用户
			select 
			distinct distinct_id,date
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in('Page_entry','Page_view')
--			and page_title ='此刻'
			and page_title ='此地'
			and date>='2022-01-01'
			and date<'2023-12-16'
			and length(distinct_id)<=9
			)x on toString(x.distinct_id)=toString(tmi.cust_id) 
WHERE 1=1
and b.sale_type = 20131010 -- 预售
and a.is_deposit='10421009' -- 付定金
and a.created_at >= '2022-01-01'      
and a.created_at < '2023-12-16'
and x.date>=toDate(toDate(a.created_at)  + interval '-180 day') 
and x.date<=toDate(a.created_at) 
and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
and a.is_deleted =0
and b.is_deleted =0
and tmi.id is not null 
and tmi.is_deleted = 0 
and tmi.member_status <> '60341003'
group by tt

--下订前6个月内浏览过社区推荐页页面的用户浏览时长大于5s且有过点击行为
select 
date_trunc('year',toDate(a.created_at)) tt,
count(distinct tmi.cust_id)
FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
left join ods_cydr.ods_cydr_tt_sales_order_vin_cur b on toString(a.so_no) = toString(b.vi_no) 
left join ods_cydr.ods_cydr_tt_sales_order_detail_d c on toString(c.SALES_OEDER_DETAIL_ID) = toString(b.sales_oeder_detail_id) 
left join ods_memb.ods_memb_tc_member_info_cur tmi on toString(a.customer_tel) =toString(tmi.member_phone) 
global left join (
		-- 浏览过页面的用户 大于5s
			select 
			distinct a.distinct_id,a.date
			from ods_rawd.ods_rawd_events_d_di a
			where 1=1
			and event in('Page_entry','Page_view')
			and page_title in ('推荐','社区推荐页')
			and view_duration_1>=5 --浏览时长大于5s
			and date>='2022-01-01'
			and date<'2023-12-16'
			and length(a.distinct_id)<=9
			and a.distinct_id in (select distinct_id from ods_oper_crm.tuijian_click)
			)x on toString(x.distinct_id)=toString(tmi.cust_id) 
WHERE 1=1
and b.sale_type = 20131010 -- 预售
and a.is_deposit='10421009' -- 付定金
and a.created_at >= '2022-01-01'      
and a.created_at < '2023-12-16'
and x.date>=toDate(toDate(a.created_at)  + interval '-180 day') 
and x.date<=toDate(a.created_at) 
and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
and a.is_deleted =0
and b.is_deleted =0
and tmi.id is not null 
and tmi.is_deleted = 0 
and tmi.member_status <> '60341003'
group by tt

--下订总用户数
select 
date_trunc('year',toDate(a.created_at)) tt,
count(distinct tmi.cust_id)
FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
left join ods_cydr.ods_cydr_tt_sales_order_vin_cur b on toString(a.so_no) = toString(b.vi_no) 
left join ods_cydr.ods_cydr_tt_sales_order_detail_d c on toString(c.SALES_OEDER_DETAIL_ID) = toString(b.sales_oeder_detail_id) 
left join ods_memb.ods_memb_tc_member_info_cur tmi on toString(a.customer_tel) =toString(tmi.member_phone) 
WHERE 1=1
and b.sale_type= 20131010 -- 预售
and a.is_deposit='10421009' -- 付定金
and a.created_at >= '2022-01-01'      
and a.created_at < '2023-12-16'
and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
and a.is_deleted =0
and b.is_deleted =0
and tmi.id is not null 
and tmi.is_deleted = 0 
and tmi.member_status <> '60341003'
group by tt


--社区发帖用户且有推荐购行为且被推荐人成功留资
	select 
	count(distinct r.invite_member_id),
	count(r.invite_member_id)
	from invite.tm_invite_record r
	where 1=1
	and date(r.create_time)>='2023-01-01'
	and date(r.create_time)<'2023-12-16'
	and r.is_deleted =0
	and r.be_invite_mobile is not null 
	and r.invite_member_id in 
		(select distinct a.member_id
		from community.tm_post a
		where 1=1
		and a.is_deleted =0
		and a.create_time >='2023-01-01'
		and a.create_time <'2023-12-16')

--社区活跃用户有推荐购行为且被推荐人成功留资
	select count(distinct r.invite_member_id),
	count(r.invite_member_id)
	from ods_invi.ods_invi_tm_invite_record_d r
	left join ods_memb.ods_memb_tc_member_info_cur m on r.invite_member_id=m.id
	where 1=1
	and date(r.create_time)>='2023-01-01'
	and date(r.create_time)<'2023-12-16'
	and r.is_deleted =0
	and r.be_invite_mobile is not null 
	and m.cust_id global in 
		(select distinct distinct_id from shequ_huoyue)

-- 推荐购总人数
	select count(distinct r.invite_member_id),
	count(r.invite_member_id)
	from ods_invi.ods_invi_tm_invite_record_d r
	where 1=1
	and date(r.create_time)>='2023-01-01'
	and date(r.create_time)<'2023-12-16'
	and r.is_deleted =0
	and r.be_invite_mobile is not null 
	
-- 社区活跃用户
CREATE TABLE IF NOT EXISTS shequ_huoyue
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
select distinct t.distinct_id
		from 
			(
			select distinct_id,date
			from ods_rawd.ods_rawd_events_d_di 
			where event in ('Page_view','Page_entry') 
			and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
			and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2023%' and activity_id is null))
			and date >= '2023-01-01' 
			and date<'2023-12-16' 
			union all 
			-- 社区互动人数
			select distinct_id,date
			from ods_rawd.ods_rawd_events_d_di 
			where event='Button_click' 
			and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
			and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
			and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
			and date >= '2023-01-01' 
			and date<'2023-12-16' 
			union all 
			-- 发现 按钮点击（车主）7月开始
			select distinct_id,date
			from ods_rawd.ods_rawd_events_d_di 
			where 1=1
			and event='$AppClick' 
			and $element_content='发现'
			and is_bind=1
			and date >= '2023-01-01' 
			and date<'2023-12-16' 
		) t 
		where length(t.distinct_id)<9 
		and t.distinct_id not like '%#%'		

--社区发帖被加精或上推荐的用户 有推荐购行为且被推荐人成功留资人数
select x.num,
count(1) `有推荐购行为且被推荐人成功留资人数`
from 
(	select 
	r.invite_member_id id,
	count(distinct r.be_invite_member_id) num
	from ods_invi.ods_invi_tm_invite_record_d r
	left join ods_memb.ods_memb_tc_member_info_cur m on r.invite_member_id=m.id
	where 1=1
	and date(r.create_time)>='2023-01-01'
	and date(r.create_time)<'2023-12-16'
	and r.is_deleted =0
	and r.be_invite_mobile is not null 
	and m.cust_id global in 
		(select distinct m.cust_id 
		from ods_cmnt.ods_cmnt_tm_post_cur a
		left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id=m.id
		where 1=1
		and a.is_deleted =0
		and a.create_time >='2023-01-01'
		and a.create_time <'2023-12-16'
		and (a.recommend=1 -- 上推荐
			or a.selected_time <>0) --加精
		)
	group by id 
	order by num 
)x 
group by x.num
order by x.num

--社区发帖被加精或上推荐的用户 有推荐购行为且被推荐人成功开单数
select x.num,
count(1) `有推荐购行为且被推荐人成功开单数`
from 
(	select 
	r.invite_member_id id,
	count(distinct r.be_invite_member_id) num
	from ods_invi.ods_invi_tm_invite_record_d r
	left join ods_memb.ods_memb_tc_member_info_cur m on r.invite_member_id=m.id
	where 1=1
		and r.is_deleted = 0
		and r.order_status in ('14041008','14041003')   -- 有效订单 已交车、审核已通过
		and r.order_no is not NULL   -- 筛选订单号不为空
		and r.cancel_large_setorder_time <'1971-01-01'    -- 取消订单时间为空，排除取消订单的情况,因为CK的时间空值为1970
		and r.red_invoice_time<'1971-01-01'  -- 红冲发票为空
		and r.blue_invoice_time >= '2023-01-01'
		and r.blue_invoice_time <'2023-12-16'
	and m.cust_id global in 
		(select distinct m.cust_id 
		from ods_cmnt.ods_cmnt_tm_post_cur a
		left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id=m.id
		where 1=1
		and a.is_deleted =0
		and a.create_time >='2023-01-01'
		and a.create_time <'2023-12-16'
		and (a.recommend=1 -- 上推荐
			or a.selected_time <>0) --加精
		)
	group by id 
	order by num 
)x 
group by x.num
order by x.num

--社区发帖被加精或上推荐的用户 产生推荐购的次数（保存海报或转发）
select x.num,
count(1) 
from 
(
	select 
	r.member_id,
	count(r.member_id) num 
	from invite.tm_invite_code r
	where 1=1
	and date(r.create_time)>='2023-01-01'
	and date(r.create_time)<'2023-12-16'
	and r.is_deleted =0
	and r.member_id in 
		(select distinct a.member_id
		from community.tm_post a
		where 1=1
		and a.is_deleted =0
		and a.create_time >='2023-01-01'
		and a.create_time <'2023-12-16'
		and (a.recommend=1 -- 上推荐
			or a.selected_time <>0) --加精
			)
	group by 1 
	order by 2 desc 
)x group by x.num
order by x.num

-- 社区活跃用户(705,926) 有推荐购行为且被推荐人成功留资人数分布
select x.num,
count(1) 
from 
(
	select 
	r.invite_member_id id,
	count(distinct r.be_invite_member_id) num 
	from ods_invi.ods_invi_tm_invite_record_d r
	left join ods_memb.ods_memb_tc_member_info_cur m on r.invite_member_id=m.id
	where 1=1
	and date(r.create_time)>='2023-01-01'
	and date(r.create_time)<'2023-12-16'
	and r.is_deleted =0
	and r.be_invite_mobile is not null 
	and m.cust_id global in 
		(select distinct distinct_id from ods_oper_crm.shequ_huoyue)
	group by id 
)x group by x.num
order by x.num

-- 社区活跃用户(705,926) 有推荐购行为且被推荐人成功开单数
select x.num,
count(1) 
from 
(
	select 
	r.invite_member_id id,
	count(distinct r.be_invite_member_id) num 
	from ods_invi.ods_invi_tm_invite_record_d r
	left join ods_memb.ods_memb_tc_member_info_cur m on r.invite_member_id=m.id
	where 1=1
		and r.is_deleted = 0
		and r.order_status in ('14041008','14041003')   -- 有效订单 已交车、审核已通过
		and r.order_no is not NULL   -- 筛选订单号不为空
		and r.cancel_large_setorder_time <'1971-01-01'    -- 取消订单时间为空，排除取消订单的情况,因为CK的时间空值为1970
		and r.red_invoice_time<'1971-01-01'  -- 红冲发票为空
		and r.blue_invoice_time >= '2023-01-01'
		and r.blue_invoice_time <'2023-12-16'
	and m.cust_id global in 
		(select distinct distinct_id from ods_oper_crm.shequ_huoyue)
	group by id 
)x group by x.num
order by x.num

--社区活跃用户(705,926) 产生推荐购的次数（保存海报或转发）
select x.num,
count(1) 
from 
(
	select 
	r.member_id id,
	count(r.member_id) num 
	from ods_invi.ods_invi_tm_invite_code_d r
	left join ods_memb.ods_memb_tc_member_info_cur m on m.id=r.member_id
	where 1=1
	and date(r.create_time)>='2023-01-01'
	and date(r.create_time)<'2023-12-16'
	and r.is_deleted =0
	and m.cust_id global in 
		(select distinct distinct_id from ods_oper_crm.shequ_huoyue)
	group by id
	order by num desc 
)x group by x.num
order by x.num
