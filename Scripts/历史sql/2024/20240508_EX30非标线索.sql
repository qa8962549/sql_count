
--EX30下订页
select a.distinct_id distinctid
,m.id memberid
,case when m.is_vehicle =1 then '车主'
	else '粉丝' end `用户会员身份`
,m.real_name `用户真实姓名`
,m.member_phone `用户手机号`
,x1.vin_code `绑定车辆信息`
,x2.Btn_num `点击EX30下订页面次数`
,x3.dura `浏览EX30下订页面总时长`
,if(x4.cust_id is not null,'是','否') `是否已下订EX30`
,if(x5.distinct_id is not null,'是','否') `是否游览过EX30专区`
,if(x6.mobile is not null,'是','否') `全渠道是否有留资`
from 
(-- 是否进入EX30下订页面[EX30首页的即刻下订按钮]
	select distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where length(distinct_id)<9 
	and event='Page_entry'
--	and event='Page_view'
--	and event='Button_click'
	and ( (`$url` like '%promotion_channel_type=app%'
			and `$url` like '%promotion_channel_sub_type=app%'
			and `$url` like '%promotion_methods=app%'
			and `$url` like '%promotion_activity=202404_ex30_xiaoding%'
			and `$url` like '%promotion_supplement=%')
		or (`$url` like '%promotion_channel_type%miniprogram%'
			and `$url` like '%promotion_channel_sub_type%volvo_world%'
			and `$url` like '%promotion_methods%mini%'
			and `$url` like '%promotion_activity%202404_ex30_xiaoding%'
			and `$url` like '%promotion_supplement%') )
	and `date` >='2024-04-16'
union distinct 
	select distinct distinct_id
	from dwd_23.dwd_23_gio_tracking a
	where length(distinct_id)<9 
	and event='Page_entry'
--	and event='Page_view'
--	and event='Button_click'
	and ( (`$url` like '%promotion_channel_type=app%'
			and `$url` like '%promotion_channel_sub_type=app%'
			and `$url` like '%promotion_methods=app%'
			and `$url` like '%promotion_activity=202404_ex30_xiaoding%'
			and `$url` like '%promotion_supplement=%')
		or (`$url` like '%promotion_channel_type%miniprogram%'
			and `$url` like '%promotion_channel_sub_type%volvo_world%'
			and `$url` like '%promotion_methods%mini%'
			and `$url` like '%promotion_activity%202404_ex30_xiaoding%'
			and `$url` like '%promotion_supplement%') )
	and `date` >='2024-05-07'
)a 
left join
(
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle,m.real_name
	from
	(
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle,m.real_name
		,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
	) m
	where m.rk=1
) m on a.distinct_id = m.cust_id::varchar
left join (select distinct a.cust_id as id,
		a.member_id,
		a.vin_code
		from (
	--		 取最近一次绑车时间
			 select
			 r.member_id,
			 m.cust_id,
			 r.bind_date,
			 r.vin_code,
			 m.member_phone,
			 row_number() over(partition by r.member_id order by r.bind_date desc) rk
			 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
--			 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
			 left join
				(
					-- 清洗会员表
					select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle,m.real_name
					from
					(
						select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle,m.real_name
						,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
						from ods_memb.ods_memb_tc_member_info_cur m
						where  m.member_status <> '60341003'
						and m.cust_id is not null
						and m.is_deleted =0 
						Settings allow_experimental_window_functions = 1
					) m
					where m.rk=1
					) m on toString(r.member_id) =toString(m.id) 
			 where r.deleted = 0
			 and r.is_bind = 1   -- 绑车
			 and r.is_owner=1  -- 车主
			 and r.member_id is not null 
			 and r.member_id <>''
			 and m.member_phone<>'*'
			 and m.member_phone is not null 
			 )a 
		where a.rk=1
--		and a.member_id ='7106880'
		)x1 on toString(x1.id)=a.distinct_id::String
left join (
-- 是否进入EX30下订页面[EX30首页的即刻下订按钮]
	select x.distinct_id,
	count(1) Btn_num
	from 
	(
		select distinct_id
		from ods_rawd.ods_rawd_events_d_di a
		where length(distinct_id)<9 
		and event='Button_click'
		and ( (`$url` like '%promotion_channel_type=app%'
				and `$url` like '%promotion_channel_sub_type=app%'
				and `$url` like '%promotion_methods=app%'
				and `$url` like '%promotion_activity=202404_ex30_xiaoding%'
				and `$url` like '%promotion_supplement=%')
			or (`$url` like '%promotion_channel_type%miniprogram%'
				and `$url` like '%promotion_channel_sub_type%volvo_world%'
				and `$url` like '%promotion_methods%mini%'
				and `$url` like '%promotion_activity%202404_ex30_xiaoding%'
				and `$url` like '%promotion_supplement%') )
		and `date` >='2024-04-16'
	union distinct
		select distinct_id
		from dwd_23.dwd_23_gio_tracking a
		where length(distinct_id)<9 
		and event='Button_click'
		and ( (`$url` like '%promotion_channel_type=app%'
				and `$url` like '%promotion_channel_sub_type=app%'
				and `$url` like '%promotion_methods=app%'
				and `$url` like '%promotion_activity=202404_ex30_xiaoding%'
				and `$url` like '%promotion_supplement=%')
			or (`$url` like '%promotion_channel_type%miniprogram%'
				and `$url` like '%promotion_channel_sub_type%volvo_world%'
				and `$url` like '%promotion_methods%mini%'
				and `$url` like '%promotion_activity%202404_ex30_xiaoding%'
				and `$url` like '%promotion_supplement%') )
		and `date` >='2024-05-07'
		)x
		group by 1
)x2 on x2.distinct_id::String=a.distinct_id::String
left join (
select x.distinct_id,
sum(x.dura) dura
from 
(
	select distinct_id,view_duration/1000 dura 
	from ods_rawd.ods_rawd_events_d_di a
	where length(distinct_id)<9 
	and event='Page_view'
	and ( (`$url` like '%promotion_channel_type=app%'
			and `$url` like '%promotion_channel_sub_type=app%'
			and `$url` like '%promotion_methods=app%'
			and `$url` like '%promotion_activity=202404_ex30_xiaoding%'
			and `$url` like '%promotion_supplement=%')
		or (`$url` like '%promotion_channel_type%miniprogram%'
			and `$url` like '%promotion_channel_sub_type%volvo_world%'
			and `$url` like '%promotion_methods%mini%'
			and `$url` like '%promotion_activity%202404_ex30_xiaoding%'
			and `$url` like '%promotion_supplement%') )
	and `date` >='2024-04-16'
union distinct
	select distinct_id,view_duration::int/1000 dura
	from dwd_23.dwd_23_gio_tracking a
	where length(distinct_id)<9 
	and event='Page_view'
	and ( (`$url` like '%promotion_channel_type=app%'
			and `$url` like '%promotion_channel_sub_type=app%'
			and `$url` like '%promotion_methods=app%'
			and `$url` like '%promotion_activity=202404_ex30_xiaoding%'
			and `$url` like '%promotion_supplement=%')
		or (`$url` like '%promotion_channel_type%miniprogram%'
			and `$url` like '%promotion_channel_sub_type%volvo_world%'
			and `$url` like '%promotion_methods%mini%'
			and `$url` like '%promotion_activity%202404_ex30_xiaoding%'
			and `$url` like '%promotion_supplement%') )
	and `date` >='2024-05-07'
	)x group by 1
)x3 on x3.distinct_id::String=a.distinct_id::String
left join 
	(
	--下订
	select tmi.cust_id cust_id 
	FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
	left join ods_cydr.ods_cydr_tt_sales_order_detail_d c on a.so_no_id = c.SO_NO_ID 
	left join ods_cydr.ods_cydr_tt_sales_order_vin_cur  b on c.SALES_OEDER_DETAIL_ID = b.sales_oeder_detail_id
	left join ods_memb.ods_memb_tc_member_info_cur tmi on toString(a.customer_tel) =toString(tmi.member_phone ) 
	WHERE b.sale_type = 20131010 -- 预售
	and c.SECOND_ID = '1114'    -- basic_data里面的id，对应EX30
	and a.is_deposit='10421009' -- 付定金
	and a.created_at >= '2024-04-16'      
	--and a.created_at < '2024-01-01'
	and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
	and a.is_deleted =0
	and b.is_deleted =0
	and tmi.id is not null 
	and tmi.is_deleted = 0 
	and tmi.member_status <> '60341003'
	order by 1
)x4 on x4.cust_id::String=a.distinct_id::String
left join (
	select distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and `date` >= '2024-04-16' and `date` < '2024-05-06'
	and event='Page_entry'
	-- and length(distinct_id)<9
	and page_title ='沃尔沃EX30'
	and
	(
		`$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/LIOUa3IY2r%'
		or `$url` like '%/src/pages/tabbar/home/webview/index?postId=LIOUa3IY2r&type=custom&isfromShare=1%'
		or `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/7guejCx8zr%'
		or `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/ztqGYpYpsc%'
		or `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/TL6DWV5uDZ%'
		or `$url` like '%/src/pages/tabbar/home/webview/index?postId=TL6DWV5uDZ&type=custom&isfromShare=1%'
	)
	and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or `$lib` ='MiniProgram' or  channel in ('Mini', 'App') )   -- 双端
	-- and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or channel='App') --app
	-- and ($lib in('MiniProgram') or channel ='Mini') -- 小程序
)x5 on x5.distinct_id::String=a.distinct_id::String
left join 
	(
	--“是否完成一键留资”都指的是【EX30全渠道全量留资】
	-- EX30留资手机号
	select distinct tcc.mobile mobile
	from ods_cust.ods_cust_tt_clue_clean_cur tcc
	join ods_bada.ods_bada_tm_model_cur tm on toString(tcc.model_id)= toString(tm.id) 
	where tcc.create_time >= '2024-03-01'
	and model_name='EX30'
)x6 on x6.mobile=m.member_phone 


-- 沃尔沃EX30所有文章的评论
select 
tmi.MEMBER_NAME 社区昵称,
tmi.CUST_ID 社区会员cust_id,
a.member_id 沃世界会员mmeber_ID,
tmi.MEMBER_PHONE 手机号码,
case when tmi.IS_VEHICLE = '1' then '是'
	when tmi.IS_VEHICLE = '0' then '否'
	end 是否车主,
a.create_time 评论日期,
a.comment_id 一级评论ID,
a.comment_content 评论内容,
a.images 评论图片,
bb.topic_id 主题ID,
tt.topic_name 帖子主题,
a.parent_id 上级评论Id,
a2.comment_content 上级评论内容,
case when a.parent_id='0' then 1
	else  2 end 层级,
LENGTH(regexp_replace(a.comment_content, '[^\u4e00-\u9fff]', '', 'g')) 评论字数,
y.拥车车型 绑定车辆信息,
if(x2.mobile is not null,'是','否') `全渠道是否有留资`,
case when x.customer_business_id is null then '否' else '是' end as 是否已下订沃尔沃EX30
from community.tm_comment a
left join community.tm_comment a2 on a.parent_id =a2.comment_id 
left join community.tm_post tp on a.post_id =tp.post_id 
left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
left join community.tm_topic tt on tt.topic_id=bb.topic_id
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join
(
	select a.member_id
	,group_concat(b.model_name) 拥车车型
	from volvo_cms.vehicle_bind_relation a
	left join basic_data.tm_model b on a.series_code =b.model_code
	where a.deleted = 0
	and a.is_bind=1
	group by 1
		)y on y.MEMBER_ID=a.member_id 
left join (
	select
	*
	FROM cyxdms_retail.tt_sales_orders  a
	left join cyxdms_retail.tt_sales_order_vin  b on a.`so_no`  = b.`vi_no` 
	left join cyxdms_retail.tt_sales_order_detail c on c.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
	WHERE b.`sale_type` = 20131010
	and a.`so_status` in (14041001,14041002,14041003,14041008,14041030)
	and a.`is_deposit` in (10421009,10041001,10041002,70961001,70961002)
	and c.second_id = '1114'    -- basic_data里面的id，对应Ex30
	--and a.created_at >= '2023-11-12'   
--	 and a.created_at < '2023-11-29'    
	and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
	and a.`is_deleted` ='0'
	and b.`is_deleted` ='0')x on x.customer_tel=tmi.member_phone
left join 
	(
	--“是否完成一键留资”都指的是【EX30全渠道全量留资】
	-- EX30留资手机号
	select distinct tcc.mobile mobile
	from customer.tt_clue_clean tcc
	join basic_data.tm_model tm on tcc.model_id= tm.id
	where tcc.create_time >= '2024-04-16'
	and model_name='EX30'
)x2 on x2.mobile=tmi.member_phone 
where a.is_deleted =0
--and a.create_time >='2023-09-01'
--and a.create_time <'2023-11-29'
and a.post_id in ('jF6xTe92za',
'mwe8FkMf4t',
'xnwXHOOmAi',
'haM3dH2ZWr',
'4DOcOSOp2r',
'2Pa00M64tZ',
'NFK6fERTri',
'eAcz2b85VI',
'Kj63175FcK',
'q7O6yhlt52',
'0pqmiN3qv6',
'FWu8ThtSBv',
'ISQdOpxRh4',
'2zg14Y1wLv')

-- 1、EX30专区PV UV（双端）
select
count(a.distinct_id) "app活动浏览总PV",
COUNT(case when b.is_vehicle = '1' then a.distinct_id else null end) "车主pv",
COUNT(case when b.is_vehicle = '0' then a.distinct_id else null end) "粉丝pv",
COUNT(case when length(a.distinct_id) > 9 then a.distinct_id else null end) "游客pv",
COUNT(distinct a.distinct_id) as "app活动浏览总UV",
COUNT(distinct case when b.is_vehicle = '1' then a.distinct_id else null end) "车主UV",
COUNT(distinct case when b.is_vehicle = '0' then a.distinct_id else null end) "粉丝UV",
COUNT(distinct case when length(a.distinct_id) > 9 then a.distinct_id else null end) "游客uv"
from 
(
	select 
	user_id,distinct_id,date
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and `date` >= '2024-04-16' and `date` < '2024-05-06'
	and event='Page_entry'
	-- and length(distinct_id)<9
	and page_title ='沃尔沃EX30'
	and
	(
		`$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/LIOUa3IY2r%'
		or `$url` like '%/src/pages/tabbar/home/webview/index?postId=LIOUa3IY2r&type=custom&isfromShare=1%'
		or `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/7guejCx8zr%'
		or `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/ztqGYpYpsc%'
		or `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/TL6DWV5uDZ%'
		or `$url` like '%/src/pages/tabbar/home/webview/index?postId=TL6DWV5uDZ&type=custom&isfromShare=1%'
	)
	and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or `$lib` ='MiniProgram' or  channel in ('Mini', 'App') )   -- 双端
	-- and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or channel='App') --app
	-- and ($lib in('MiniProgram') or channel ='Mini') -- 小程序
) a
left join
(
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from
	(
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
		,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
	) m
	where m.rk=1
) b on a.distinct_id = b.cust_id::varchar