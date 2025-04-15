--预热 EX30非标线索挖掘
select
a.*,--d.mobile,
--case when b.distinct_id is null then '否' else '是' end as `是否后续进入EM30专区（预售）`,
--case when c.distinct_id is null then '否' else '是' end as `是否订阅沃尔沃EX30官方资讯`,
case when d.mobile  is null then '否' else '是' end as `是否完成一键留资`,
case when g.purchase_phone is null then '否' else '是' end as `是否已下订沃尔沃EX30`
from
(-- 浏览EX30专区（预售）  用户信息
	select
	m.* ,t.PV
	from
	(	--EX30专区（预售）
	select 
	distinct_id 
	,count(distinct_id) as PV
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and toDate(`time`) >= '2024-03-28' 
	and toDate(`time`) < '2024-07-08'
	and event in ('Page_entry','Button_click')
	and length(distinct_id)<9
	and content_id in ('WKQ7SD91a4',
	'0gQ3BAWCPb',
	'J9gLNojsoG',
	'sOauuE7JYS',
	'hec1dRPG0v',
	'Pzq4s1Ra6N',
	'qQsxfBkG1j',
	'R0ANmGHWcy',
	'IVK4WXvty8',
	'yNgPdbGAab',
	'g4QzzGU3Om',
	'q88mL44aDk',
	'XRgVmLXo6u',
	'5Qg9z2pzsh',
	'Kj63175FcK',
	'eAcz2b85VI',
	'QW8OBrXxbU',
	'5cu0kQ42lr',
	'gjsRN6uHKJ',
	'4swnle1s92',
	'0EcT4XLtrp',
	'MVwJONuukV',
	'irgDJ9DYV4',
	'AJq6hTH0Ml',
	'AtQvR77Ist',
	'0pqmiN3qv6',
	'q7O6yhlt52',
	'NFK6fERTri',
	'2Pa00M64tZ',
	'4DOcOSOp2r',
	'haM3dH2ZWr',
	'xnwXHOOmAi',
	'mwe8FkMf4t',
	'jF6xTe92za',
	'42A1GSYX7h',
	'6NqAtChV9a',
	'dwqUvbgdzj',
	'1YM3b21own',
	'YPqa6T4e1h',
	'9Ge02D2yYm',
	'hIAHt1ROKh',
	'5QO2lxJi3j',
	'ICgtUSBgvu',
	'oEuCJYUKr5',
	'PLKUhyTE0a',
	'DNesG6hs5A',
	'1ku4m3PWoY',
	'FWu8ThtSBv',
	'ISQdOpxRh4',
	'2zg14Y1wLv')
	group by distinct_id)t 
	inner join 	
	(-- 会员信息
		select m.* ,v.`绑定车辆信息`
		from
		(-- 会员表的全量oneid,memberid取最新
			select 
			m.cust_id::varchar as distinct_id
			,m.id::varchar as memberid
			-- ,m.level_id,m.create_time
			,case when m.is_vehicle=1 then '车主' when m.is_vehicle=0 then '粉丝' end as `用户会员身份`
			,m.real_name 
			,m.member_phone
			from
				(-- 清洗cust_id 取其对应的最新信息
				select m.id,m.cust_id,m.level_id ,m.create_time
				,m.is_vehicle,m.real_name ,m.member_phone
				,row_number() over(partition by m.cust_id order by m.create_time desc) rk
				from ods_memb.ods_memb_tc_member_info_cur m
				where m.is_deleted =0 and m.member_status <>'60341003'
				and m.cust_id is not null -- oneid做匹配时,oneid不能空
				Settings allow_experimental_window_functions = 1
				)m
			where m.rk=1
		) m
		left join
		(-- 绑定车辆信息
			select
			a.member_id
			,arrayStringConcat(groupArray(a.model_name),'|') as `绑定车辆信息`
			from
			(-- 用户绑车的车型
				select distinct
				a.member_id--,a.is_bind,a.is_owner,a.vin_code ,a.series_code
				,f.model_name 
				from ods_vocm.ods_vocm_vehicle_bind_relation_cur a -- 绑车关系表
				left join ods_bada.ods_bada_tm_model_cur f on a.series_code =toString(f.series_code)
				where a.deleted =0
				and a.member_id is not null and a.member_id<>''
				and a.is_bind =1 -- 绑车
			)a
			group by a.member_id
		)v on m.memberid=v.member_id
	)m on toString(t.distinct_id) =toString(m.distinct_id)
)a
left join
(-- 是否后续进入EM30专区（预售）
	select distinct distinct_id
	from dwd_23.dwd_23_gio_tracking
	where length(distinct_id)<9 
	and event ='Page_entry'
	and page_title ='沃尔沃EX30'
	and (`$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/ztqGYpYpsc%'
	or `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/TL6DWV5uDZ%'
	or `$url` like '%/src/pages/tabbar/home/webview/index?postId=TL6DWV5uDZ&type=custom&isfromShare=1%')
	--and `time` >= '2024-05-01' 
	and toDate(`time`) < '2024-07-08' 
	and toDate(`time`)  >= '2024-04-25' 
)b on a.`m.distinct_id` =b.distinct_id
left join 
(--是否订阅沃尔沃EX30官方资讯
select 
	distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and `time` >= '2024-07-08' 
	and `time` < '2024-04-26'
	and event='Button_click'
	and length(distinct_id)<9
	and page_title ='沃尔沃EX30'
	and btn_name = '广告'
	and content_id = '17138514101457f6jj974fckc'
	-- and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or channel='App') --app
	--and ($lib in('MiniProgram') or channel ='Mini') -- 小程序
)c on a.`m.distinct_id` =c.distinct_id
left join 
(
--“是否完成一键留资”都指的是【EX30全渠道全量留资】
-- EX30留资手机号
select distinct tcc.mobile as "mobile"
from  ods_cust.ods_cust_tt_clue_clean_cur tcc 
inner join ods_bada.ods_bada_tm_model_cur  tm
on tcc.model_id = toString(tm.id ) 
where 1=1
and tm.model_name ='EX30'
and tcc.create_time >= '2024-03-01'
) d on a.`member_phone` =d.mobile
left join
(-- 是否已下订沃尔沃EX30
	select distinct a.purchase_phone as purchase_phone
	FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
	left join ods_cydr.ods_cydr_tt_sales_order_detail_d c on a.so_no_id =c.SO_NO_ID 
	left join ods_cydr.ods_cydr_tt_sales_order_vin_cur b on c.SALES_OEDER_DETAIL_ID =b.sales_oeder_detail_id 
	where b.sale_type = 20131010 -- 预售
	and c.SECOND_ID = '1114'    -- basic_data里面的id，对应EX30
	and a.so_status in (14041001,14041002,14041003,14041008,14041030) -- 有效订单
	and a.is_deposit in (10421009,10041001,10041002,70961001,70961002) -- 是否交定金
	and a.created_at >= '2024-04-01'
	and a.is_deleted = 0
	and b.is_deleted = 0
	and c.IS_DELETED = 0
)g on a.member_phone =g.purchase_phone


--预售

select
a.*,--d.mobile,
case when c.distinct_id is null then '否' else '是' end as `是否订阅沃尔沃EX30官方资讯`,
case when d.mobile  is null then '否' else '是' end as `是否完成一键留资`,
case when e.distinct_id is null then '否' else '是' end as `是否进入(了解车型)`,
case when h.mobile  is null then '否' else '是' end as `是否完成【预约赏车】一键留资`,
case when f.distinct_id is null then '否' else '是' end as `是否进入EX30下订页面`,
case when g.purchase_phone is null then '否' else '是' end as `是否已下订沃尔沃EX30`
from
(-- 浏览EX30专区（预售）  用户信息
	select
	m.* ,t.PV
	from
	(	--EX30专区（预售）
	select 
	distinct_id 
	,count(distinct_id) as PV
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and toDate(`time`) >= '2024-03-28' 
	and toDate(`time`) < '2024-07-08'
	and event in ('Page_entry','Button_click')
	and length(distinct_id)<9
	and content_id in ('WKQ7SD91a4',
	'0gQ3BAWCPb',
	'J9gLNojsoG',
	'sOauuE7JYS',
	'hec1dRPG0v',
	'Pzq4s1Ra6N',
	'qQsxfBkG1j',
	'R0ANmGHWcy',
	'IVK4WXvty8',
	'yNgPdbGAab',
	'g4QzzGU3Om',
	'q88mL44aDk',
	'XRgVmLXo6u',
	'5Qg9z2pzsh',
	'Kj63175FcK',
	'eAcz2b85VI',
	'QW8OBrXxbU',
	'5cu0kQ42lr',
	'gjsRN6uHKJ',
	'4swnle1s92',
	'0EcT4XLtrp',
	'MVwJONuukV',
	'irgDJ9DYV4',
	'AJq6hTH0Ml',
	'AtQvR77Ist',
	'0pqmiN3qv6',
	'q7O6yhlt52',
	'NFK6fERTri',
	'2Pa00M64tZ',
	'4DOcOSOp2r',
	'haM3dH2ZWr',
	'xnwXHOOmAi',
	'mwe8FkMf4t',
	'jF6xTe92za',
	'42A1GSYX7h',
	'6NqAtChV9a',
	'dwqUvbgdzj',
	'1YM3b21own',
	'YPqa6T4e1h',
	'9Ge02D2yYm',
	'hIAHt1ROKh',
	'5QO2lxJi3j',
	'ICgtUSBgvu',
	'oEuCJYUKr5',
	'PLKUhyTE0a',
	'DNesG6hs5A',
	'1ku4m3PWoY',
	'FWu8ThtSBv',
	'ISQdOpxRh4',
	'2zg14Y1wLv')
	group by distinct_id)t 
	inner join 	
	(-- 会员信息
		select m.* ,v.`绑定车辆信息`
		from
		(-- 会员表的全量oneid,memberid取最新
			select 
			m.cust_id::varchar as distinct_id
			,m.id::varchar as memberid
			-- ,m.level_id,m.create_time
			,case when m.is_vehicle=1 then '车主' when m.is_vehicle=0 then '粉丝' end as `用户会员身份`
			,m.real_name 
			,m.member_phone
			from
				(-- 清洗cust_id 取其对应的最新信息
				select m.id,m.cust_id,m.level_id ,m.create_time
				,m.is_vehicle,m.real_name ,m.member_phone
				,row_number() over(partition by m.cust_id order by m.create_time desc) rk
				from ods_memb.ods_memb_tc_member_info_cur m
				where m.is_deleted =0 and m.member_status <>'60341003'
				and m.cust_id is not null -- oneid做匹配时,oneid不能空
				Settings allow_experimental_window_functions = 1
				)m
			where m.rk=1
		) m
		left join
		(-- 绑定车辆信息
			select
			a.member_id
			,arrayStringConcat(groupArray(a.model_name),'|') as `绑定车辆信息`
			from
			(-- 用户绑车的车型
				select distinct
				a.member_id--,a.is_bind,a.is_owner,a.vin_code ,a.series_code
				,f.model_name 
				from ods_vocm.ods_vocm_vehicle_bind_relation_cur a -- 绑车关系表
				left join ods_bada.ods_bada_tm_model_cur f on a.series_code =toString(f.series_code)
				where a.deleted =0
				and a.member_id is not null and a.member_id<>''
				and a.is_bind =1 -- 绑车
			)a
			group by a.member_id
		)v on m.memberid=v.member_id
	)m on toString(t.distinct_id) =toString(m.distinct_id)
)a
left join 
(--是否订阅沃尔沃EX30官方资讯
	select  distinct distinct_id
   from
   (
	select 
	distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and `time` >= '2024-04-25 10:21:00' 
	--and `time` < '2024-05-01'
	and event='Button_click'
	and length(distinct_id)<9
	and page_title ='沃尔沃EX30'
	and btn_name = '广告'
	and content_id in( '17138514101457f6jj974fckc','1713335990944egcd8na121bm')
	union all 
	select 
	distinct distinct_id
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	--and `time` >= '2024-05-01'
	and `time` < '2024-05-10'
	and event='Button_click'
	and length(distinct_id)<9
	and page_title ='沃尔沃EX30'
	and btn_name = '广告'
	and content_id in( '17138514101457f6jj974fckc','1713335990944egcd8na121bm')
	)
)c on a.`m.distinct_id` =c.distinct_id
left join 
(
--“是否完成一键留资”都指的是【EX30全渠道全量留资】
-- EX30留资手机号
select distinct tcc.mobile as "mobile"
from  ods_cust.ods_cust_tt_clue_clean_cur tcc 
inner join ods_bada.ods_bada_tm_model_cur  tm
on tcc.model_id = toString(tm.id ) 
where 1=1
and tm.model_name ='EX30'
and tcc.create_time >= '2024-03-01'
) d on a.`member_phone` =d.mobile
left join 
(--是否进入了解车型
    select distinct distinct_id
    from
    (
	select 
	distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and `time` >= '2024-04-25 10:21:00' 
	--and `time` < '2024-05-01'
	and event='Button_click'
	and length(distinct_id)<9
	and page_title ='沃尔沃EX30'
	and btn_name = '图片'
	and content_id in ('1714009165420bfnkn69bhib7','171401119218647224el67cdb' )  --APP、 小程序
	union all 
	select 
	distinct distinct_id
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	--and `time` >= '2024-05-01'
	and `time` < '2024-05-10'
	and event='Button_click'
	and length(distinct_id)<9
	and page_title ='沃尔沃EX30'
	and btn_name =  '图片'
	and content_id in ('1714009165420bfnkn69bhib7','171401119218647224el67cdb' )
	)
)e on a.`m.distinct_id` =e.distinct_id
left join
(-- 是否进入EX30下订页面[EX30首页的即刻下订按钮]
	select distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where length(distinct_id)<9 
	and event='Page_entry'
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
	and `time` >='2024-04-01'
	--and `time` <'2024-05-01'
union all
	select distinct distinct_id
	from dwd_23.dwd_23_gio_tracking a
	where length(distinct_id)<9 
	and event='Page_entry'
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
	--and `time` >='2024-05-01'
	and `time` <'2024-05-10'
)f on a.`m.distinct_id` =f.distinct_id
left join
(-- 是否已下订沃尔沃EX30
	select distinct a.purchase_phone as purchase_phone
	FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
	left join ods_cydr.ods_cydr_tt_sales_order_detail_d c on a.so_no_id =c.SO_NO_ID 
	left join ods_cydr.ods_cydr_tt_sales_order_vin_cur b on c.SALES_OEDER_DETAIL_ID =b.sales_oeder_detail_id 
	where b.sale_type = 20131010 -- 预售
	and c.SECOND_ID = '1114'    -- basic_data里面的id，对应EX30
	and a.so_status in (14041001,14041002,14041003,14041008,14041030) -- 有效订单
	and a.is_deposit in (10421009,10041001,10041002,70961001,70961002) -- 是否交定金
	and a.created_at >= '2024-04-01'
	and a.is_deleted = 0
	and b.is_deleted = 0
	and c.IS_DELETED = 0
)g on a.member_phone =g.purchase_phone
left join 
(
--是否完成【预约赏车】一键留资
select distinct tcc.mobile as "mobile",tcc.campaign_id ,ca.uid,ca.active_code,tcc.create_time
from  ods_cust.ods_cust_tt_clue_clean_cur tcc 
inner join ods_bada.ods_bada_tm_model_cur  tm
on tcc.model_id = toString(tm.id ) 
left join ods_actv.ods_actv_cms_active_d ca on tcc.`campaign_id` = ca.uid
where 1=1
and tm.model_name ='EX30'
--and tcc.create_time <= '2024-02-01'
and tcc.create_time >= '2024-03-01'
and ca.active_code in ('IBCRMMAREX30000012024VCCN')
--order by tcc.create_time
)h on a.`member_phone` =h.mobile
left join 
(
--是否点击【预约赏车】
select 
	distinct  distinct_id 
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and  `time` >= '2024-04-25 10:21:00' 
	--and  `time` < '2024-05-01'
	and event='Button_click'
	and length(distinct_id)<9
	and page_title ='沃尔沃EX30'
	and (`$url` like '%https://mweb.digitalvolvo.com/mweb/oneKeyRetainCapital/s1sHEm64HQ%'
	or `$url` like '%/src/pages/tabbar/home/webview/index?postId=s1sHEm64HQ&type=oneKeyRetainCapital%')
union all 
select 
	distinct  distinct_id 
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	--and  `time` >= '2024-04-25 10:21:00' 
	and  `time` < '2024-05-10'
	and event='Button_click'
	and length(distinct_id)<9
	and page_title ='沃尔沃EX30'
	and (`$url` like '%https://mweb.digitalvolvo.com/mweb/oneKeyRetainCapital/s1sHEm64HQ%'
	or `$url` like '%/src/pages/tabbar/home/webview/index?postId=s1sHEm64HQ&type=oneKeyRetainCapital%')
)j on a.`m.distinct_id` =j.distinct_id
