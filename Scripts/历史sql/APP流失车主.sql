rename table test_shangcheng3 to test_shangcheng

--超过30天未活跃，最后一次活跃为车主身份
select a.did
,m.id 
,m.create_time `会员注册时间`
,b.`首次进入App时间` `首次进入App时间`
,a.time `最近一次进入App时间`
,b1.`最近一次进入Mini时间` `最近一次进入Mini时间`
,d.num `历史打开App次数`
,e.num `历史使用App天数`
,g.`开票时间` `开票时间`
,f.`拥车车型` `拥车车型`
,g.`车辆年款` `车辆年款`
,m.member_sex `性别(1男2女3未知)`
,if(g.`年龄`>=18 and g.`年龄`<100,g.`年龄`,null) `年龄`
,if(r.avg_num >'0','是','否')`是否使用过车控`
,ifnull(r.avg_num,0)`车控月均使用天数`
,r1.mt`最后一次使用车控时间`
,m.member_level `会员等级`
,m.member_v_num `截止其App最后一次访问的V值余额`
,ifnull(h2.`历史累计获取V值`,0) `历史累计获取V值`
,ifnull(h.`历史累计消耗V值（不含过期）`,0) `历史累计消耗V值（不含过期）`
,ifnull(h1.`历史累计V值过期数量`,0) `历史累计V值过期数量`
,ifnull(q.num,0) `历史累计浏览App社区帖子数量`
,p.max_login_interval`除最后一次外，历史最大App登录间隔天数`
,ifnull(i.num,0) `App最近一次活跃前1个月投诉工单数量`
,ifnull(i2.num,0) `App最近一次活跃前3个月投诉工单数量`
,ifnull(j.num,0)`历史累计从App参与会员日活动次数`
,ifnull(k.num,0)`历史累计从App参与权益日活动次数`
,ifnull(l.num,0)`历史累计从App参与权益日成功领取权益次数`
,ifnull(n.num,0)`历史累计浏览App商城首页次数`
,ifnull(o.num,0)`历史累计浏览App商品详情页次数`
from ods_oper_crm.app_chenshui a
left join ods_oper_crm.app_shouci b on a.did =b.did 
left join ods_oper_crm.mini_zuijin b1 on cast(a.did as varchar)=b1.did
left join ods_memb.ods_memb_tc_member_info_cur m on a.did =m.cust_id 
left join ods_oper_crm.app_dakai d on a.did=cast(d.distinct_id as int)
left join ods_oper_crm.app_dakaitianshu e on a.did=cast(e.distinct_id as int)
left join ods_oper_crm.chexing_user f on m.cust_id =f.`a.cust_id`
left join ods_oper_crm.kaipiao_user g on g.`b.sales_vin`=f.`a.vin_code`
left join 
	(
	--# V值消耗总数
	select
	r.member_id,
	SUM(r.integral) `历史累计消耗V值（不含过期）`
	from ods_memb.ods_memb_tt_member_flow_record_cur r
	-- join member.tc_member_info m on r.MEMBER_ID=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	where r.record_type  = 1  -- V值消耗
	and r.create_time  <'2023-09-15'
	and r.event_type <> '60741032'  -- V值过期，2023.4.13添加这个条件
	and r.is_deleted = '0'
	group by r.member_id)h on h.member_id=m.id 
left join 
	(
	--# 历史累计V值过期数量
	select
	r.member_id,
	SUM(r.integral) `历史累计V值过期数量`
	from ods_memb.ods_memb_tt_member_flow_record_cur r
	-- join member.tc_member_info m on r.MEMBER_ID=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	where r.record_type  = 1  -- V值消耗
	and r.create_time  <'2023-09-15'
	and r.event_type = '60741032'  -- V值过期，2023.4.13添加这个条件
	and r.is_deleted = '0'
	group by r.member_id)h1 on h1.member_id=m.id 
left join 
	(
	--# 历史累计获取V值
	select
	r.member_id,
	sum(r.integral) `历史累计获取V值`
	from ods_memb.ods_memb_tt_member_flow_record_cur r
	where 1=1
	and r.record_type  = '0'  -- V值获取
	and r.create_time  <'2023-09-15'
--	and r.event_type = '60741032'  -- V值过期，2023.4.13添加这个条件
	and r.is_deleted = '0'
	and r.event_type <> '60731025'   -- V值退回
--	and r.member_id='5488782'
	group by r.member_id)h2 on h2.member_id=m.id 
left join 
	(-- APP投诉 App最近一次活跃前1个月投诉工单数量
	select 
	c.CallNo phone,
	count(1) num
	from ods_exp.ods_exp_t_job_order_d c 
	left join ods_memb.ods_memb_tc_member_info_cur m on c.CallNo =m.member_phone 
	left join app_chenshui a on m.cust_id =a.did 
	where c.CreationTime >=date_sub(a.time,interval 1 month)
	and c.CreationTime < a.time
	and c.Nature in ('投诉类','协助类')
	group by c.CallNo)i on i.phone=m.member_phone 
left join 
	(-- APP投诉 App最近一次活跃前3个月投诉工单数量
	select 
	c.CallNo phone,
	count(1) num
	from ods_exp.ods_exp_t_job_order_d c
	left join ods_memb.ods_memb_tc_member_info_cur m on c.CallNo =m.member_phone 
	left join app_chenshui a on m.cust_id =a.did 
	where c.CreateDT >=date_sub(a.time,interval 3 month)
	and c.CreateDT < a.time
	and c.Nature in ('投诉类','协助类')
	group by c.CallNo)i2 on i2.phone=m.member_phone 
left join 
	(
	--历史累计从App参与会员日活动次数
	select 
	distinct_id,
	count(distinct concat(distinct_id,page_title)) num 
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Page_view'
	--and a.activity_name like '%会员日%'
	and page_title like '%会员日'
	and page_title not like '%WOW%'
	and (a.`$lib` in('iOS','Android') or a.channel ='App')
	and length(distinct_id)<9
	group by distinct_id
	order by num desc )j on j.distinct_id =cast(a.did as varchar)
left join 
	(
	--历史累计从App参与权益日活动次数
	select 
	distinct_id ,
	count(distinct concat(distinct_id,toString( toYYYYMM(date)))) num
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Page_view'
	and page_title = '我的会员'
	and (a.`$lib` in('iOS','Android') or a.channel ='App')
	and length(distinct_id)<9
	group by distinct_id
	order by num desc )k on k.distinct_id =cast(a.did as varchar)
left join 
	(
	--历史累计从App参与权益日成功领取权益次数
	select 
	distinct_id,
	count(distinct concat(distinct_id,toString( toYYYYMM(date)))) num
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Page_view'
	and page_title like '%权益详情%'
	and subtitle_name like '%已领取%'
	and (a.`$lib` in('iOS','Android') or a.channel ='App')
	and length(distinct_id)<9
	group by distinct_id
	order by num desc )l on l.distinct_id =cast(a.did as varchar)
left join 
	(
	--历史累计浏览App商城首页次数
	select 
	distinct_id,
	count(1) num
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Mall_category_list_view'
	and (a.`$lib` in('iOS','Android') or a.channel ='App')
	and length(distinct_id)<9
	group by distinct_id
	order by num desc )n on n.distinct_id =cast(a.did as varchar)
left join 
	(
	-- volvo商详页——分渠道 历史累计浏览App商品详情页次数
	select  
	distinct_id,
	count(1) num 
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	--and a.`time` >= yesterday()
	--and a.`time` < toDate(now())
	and length(a.distinct_id)<9
	and a.product_id is not null
	and a.product_id <>''
	and (a.`$lib` in('iOS','Android') or a.channel ='App')
	and a.bussiness_name ='商城'
	and a.event ='Button_click'
	and a.page_title not in('商城首页','商品列表页面')
	group by distinct_id
	order by num desc )o on o.distinct_id =cast(a.did as varchar)
left join app_datediffend p on p.distinct_id =cast(a.did as varchar)
left join 
	(
	--历史累计浏览App社区帖子数量	
	select m.cust_id,
	count(distinct a.post_id) num 
	from ods_cmnt.ods_cmnt_tt_view_post_cur a 
	left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id =m.id 
	where a.is_deleted =0
	group by m.cust_id)q  on q.cust_id =a.did
left join chekong_num r on r.distinct_id=cast(a.did as varchar) --车控月均使用天数
left join chekong_maxtime r1 on r1.distinct_id =cast(a.did as varchar) --最后一次使用车控时间

	
-- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
-- 30天未活跃车主 建表
CREATE TABLE IF NOT EXISTS app_chenshui
(
    did Int32,
    time DateTime
) ENGINE = ReplacingMergeTree()
ORDER BY (did, time);

-- 插入 30天未活跃车主
INSERT INTO app_chenshui (did, time)
select a.did,
a.time
from 
	(
	-- 最近一次进入App时间
	select cast(distinct_id as int) did
	  ,*
	  ,row_number() over(partition by distinct_id order by time desc) rk
	  from ods_rawd.ods_rawd_events_d_di  
	  where 1=1
--	  and `$lib` in('iOS','Android') 
	  and event ='$AppViewScreen'
	  and length(distinct_id)<9 
	  and left($app_version,1)>='5'
	  Settings allow_experimental_window_functions = 1
	)a 
where a.rk=1 
and a.is_bind=1
and a.time<date_sub(cast('2023-09-15' as date),interval 30 day)
union all
-- 插入2022年7月份之前的车主 因为7月份之前is_bind为空
select a.did,
a.time
from 
	(
	-- 最近一次进入App时间
	select cast(distinct_id as int) did
	  ,*
	  ,m.is_vehicle
	  ,row_number() over(partition by distinct_id order by time desc) rk
	  from ods_rawd.ods_rawd_events_d_di a
	  left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.distinct_id) = toString(m.cust_id) 
	  where 1=1
--	  and `$lib` in('iOS','Android') 
	  and event ='$AppViewScreen'
	  and length(distinct_id)<9 
	  and left($app_version,1)>='5'
	  Settings allow_experimental_window_functions = 1
	)a 
where a.rk=1 
and a.is_vehicle=1 -- 利用member表的车主身份
and a.time<'2022-07-01'

-- 全量车主
--  建表
CREATE TABLE IF NOT EXISTS app_chezhu_all
(
    did Int32,
    time DateTime
) ENGINE = ReplacingMergeTree()
ORDER BY (did, time);

INSERT INTO app_chezhu_all (did, time)
select a.did,
a.time
from 
	(
	-- 最近一次进入App时间
	select cast(distinct_id as int) did
	  ,*
	  ,row_number() over(partition by distinct_id order by time desc) rk
	  from ods_rawd.ods_rawd_events_d_di  
	  where 1=1
--	  and `$lib` in('iOS','Android') 
	  and event ='$AppViewScreen'
	  and length(distinct_id)<9 
	  and left($app_version,1)>='5'
	  Settings allow_experimental_window_functions = 1
	)a 
where a.rk=1 
and a.is_bind=1
and a.time<'2023-09-15'
union all
-- 插入2022年7月份之前的车主 因为7月份之前is_bind为空
select a.did,
a.time
from 
	(
	-- 最近一次进入App时间
	select cast(distinct_id as int) did
	  ,*
	  ,m.is_vehicle
	  ,row_number() over(partition by distinct_id order by time desc) rk
	  from ods_rawd.ods_rawd_events_d_di a
	  left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.distinct_id) = toString(m.cust_id) 
	  where 1=1
--	  and `$lib` in('iOS','Android') 
	  and event ='$AppViewScreen'
	  and length(distinct_id)<9 
	  and left($app_version,1)>='5'
	  Settings allow_experimental_window_functions = 1
	)a 
where a.rk=1 
and a.is_vehicle=1 -- 利用member表的车主身份
and a.time<'2022-07-01'



-- 最近一次进入Mini时间
CREATE TABLE IF NOT EXISTS mini_zuijin
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
select cast(a.distinct_id as varchar) did
,a.time `最近一次进入Mini时间`
from 
	(select distinct_id
	  ,memberid
	  ,is_bind
	  ,time
	  ,row_number() over(partition by distinct_id order by time desc) rk
	  from ods_rawd.ods_rawd_events_d_di  
	  where 1=1
	  and length(distinct_id)<9 
	  and ($lib ='MiniProgram' or channel ='Mini')
	  Settings allow_experimental_window_functions = 1
	  )a 
where a.rk=1 
	

-- 首次进入App时间jianbiao
CREATE TABLE IF NOT EXISTS app_shouci
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
	select a1.*
		from (
		select cast(distinct_id as int) did
		,memberid
		  ,is_bind
		  ,time `首次进入App时间`
		  ,row_number() over(partition by distinct_id order by time) rk
		  from ods_rawd.ods_rawd_events_d_di  
		  where event ='$AppViewScreen'
		  and length(distinct_id)<9 
		  and left($app_version,1)>='5'
		  Settings allow_experimental_window_functions = 1
		)a1 where a1.rk=1 

-- 历史打开App次数 jianbiao 
CREATE TABLE IF NOT EXISTS app_dakai
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
    SELECT distinct_id, COUNT(1) AS num
    FROM ods_rawd.ods_rawd_events_d_di
    WHERE event='$AppStart'
    AND LENGTH(distinct_id) < 9
    AND time > '2022-03-01'
    GROUP BY distinct_id
  
DROP TABLE IF EXISTS app_dakai;
    
 -- 历史打开App天数 jianbiao 
CREATE TABLE IF NOT EXISTS app_dakaitianshu
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
    SELECT distinct_id,COUNT(distinct date) AS num
    FROM ods_rawd.ods_rawd_events_d_di
    WHERE event='$AppStart'
    AND LENGTH(distinct_id) < 9
    AND time > '2022-03-01'
    GROUP BY distinct_id

    
 -- 车型 jianbiao 
CREATE TABLE IF NOT EXISTS chexing_user
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS 
	
select a.*
	from 
		(
		select a.vin_code
--		,a.cust_id
		,a.series_code
		,a.bind_date
		,b.model_name `拥车车型`
		,m.cust_id 
		,row_number()over(partition by a.member_id order by a.bind_date) rk 
		from ods_vocm.ods_vocm_vehicle_bind_relation_cur a
		left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id=cast(m.id as varchar)
		left join ods_bada.ods_bada_tm_model_cur b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
--		Settings allow_experimental_window_functions = 1
		)a 
	where a.rk=1

 -- 开票 jianbiao 
CREATE TABLE IF NOT EXISTS kaipiao_user
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS 
	select x.*
	from 
		(
		select 
		b.sales_vin,
		b.delivery_owner_code `购车门店`,
		b.created_at,
		kp.invoice_date `开票时间`,
		tc.province_name `门店所在省份`,
		tc.city_name  `门店所在城市`,
		kp.buy_name,
		kp.config_year `车辆年款`,
--		YEAR(NOW())- SUBSTRING(kp.certificate_no,7,4) 年龄,
		YEAR(NOW()) - toInt32(SUBSTRING(certificate_no, 7,4))`年龄`,
		row_number() over(partition by b.sales_vin order by b.created_at desc ) rk,
		a.owner_code
		from ods_cydr.ods_cydr_tt_sales_orders_cur a
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur b on a.so_no  = b.vi_no
		left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur kp on b.sales_vin = kp.vin 
		left join ods_orga.ods_orga_tm_company_cur tc on tc.company_code  = b.delivery_owner_code
		where kp.is_deleted  = 0
		and a.is_deleted  = 0
		Settings allow_experimental_window_functions = 1)x 
	where x.rk=1
	
    
-- 绑车关系表
select 
distinct 
m.id,
m.cust_id ,
x.`开票时间` `开票时间`,
a.`拥车车型` `拥车车型`,
x.`车辆年款` `车辆年款`,
x.`年龄` `年龄`
from ods_memb.ods_memb_tc_member_info_cur m
left join ods_oper_crm.chexing_user a on cast(m.id as varchar)=a.member_id
left join ods_oper_crm.kaipiao_user x on x.`b.sales_vin`=a.vin_code
where 1=1
and m.is_deleted=0
    
--车控 jianbiao 车控月均使用天数
CREATE TABLE IF NOT EXISTS chekong_num
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS

-- 车控按钮点击
SELECT x.distinct_id
,avg(x.num) AS avg_num
FROM (
	select DATE_TRUNC('month',date) AS t
	,distinct_id
	,COUNT(DISTINCT date) AS num
	from ods_rawd.ods_rawd_events_d_di
	where event='$AppClick' 
	and (($lib='iOS' 
	  and $element_path='UIView/VocKit.HomeSideView[0]/UITableView[0]/VocKit.HomeSideViewCell[0][-]'
	  and $element_position in ('0:0','0:1','0:2','0:3')
	  and $screen_name ='Volvo_Cars.ChinaHomeContainerViewController')
	or ($lib='Android' 
	  and $element_path='android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.appcompat.widget.FitWindowsLinearLayout[0]/androidx.appcompat.widget.ContentFrameLayout[0]/android.widget.RelativeLayout[0]/android.widget.LinearLayout[1]/android.widget.RelativeLayout[0]/android.widget.FrameLayout[0]/se.volvo.vcc.ui.fragments.root.MyCarRootFragment[0]/android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.viewpager2.widget.ViewPager2[0]/androidx.viewpager2.widget.ViewPager2.RecyclerViewImpl[0]/android.widget.FrameLayout[0]/androidx.constraintlayout.widget.ConstraintLayout[0]/se.volvo.vcc.ui.fragments.hometab.home.HomeMotionLayout[0]/androidx.recyclerview.widget.RecyclerView[0]/androidx.constraintlayout.widget.ConstraintLayout[-]'
	  and $element_position in ('0','1','2','3')
	  and $screen_name like '%se.volvo.vcc.ui.activities.navigation.tabsnavigation.BottomTabsActivity|se.volvo.vcc.ui.fragments.hometab.home.HomeFragment%'))
	and length(distinct_id)<9
	and distinct_id in (select b.did from ods_oper_crm.app_chenshui b)
	and time<'2023-09-15'
	GROUP BY t,distinct_id
) x
GROUP BY x.distinct_id

--车控使用时间 jianbiao 最后一次使用车控时间
CREATE TABLE IF NOT EXISTS chekong_maxtime
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
	select distinct_id
	,max(time) mt
	from ods_rawd.ods_rawd_events_d_di
	where event='$AppClick' 
	and (($lib='iOS' 
	  and $element_path='UIView/VocKit.HomeSideView[0]/UITableView[0]/VocKit.HomeSideViewCell[0][-]'
	  and $element_position in ('0:0','0:1','0:2','0:3')
	  and $screen_name ='Volvo_Cars.ChinaHomeContainerViewController')
	or ($lib='Android' 
	  and $element_path='android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.appcompat.widget.FitWindowsLinearLayout[0]/androidx.appcompat.widget.ContentFrameLayout[0]/android.widget.RelativeLayout[0]/android.widget.LinearLayout[1]/android.widget.RelativeLayout[0]/android.widget.FrameLayout[0]/se.volvo.vcc.ui.fragments.root.MyCarRootFragment[0]/android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.viewpager2.widget.ViewPager2[0]/androidx.viewpager2.widget.ViewPager2.RecyclerViewImpl[0]/android.widget.FrameLayout[0]/androidx.constraintlayout.widget.ConstraintLayout[0]/se.volvo.vcc.ui.fragments.hometab.home.HomeMotionLayout[0]/androidx.recyclerview.widget.RecyclerView[0]/androidx.constraintlayout.widget.ConstraintLayout[-]'
	  and $element_position in ('0','1','2','3')
	  and $screen_name like '%se.volvo.vcc.ui.activities.navigation.tabsnavigation.BottomTabsActivity|se.volvo.vcc.ui.fragments.hometab.home.HomeFragment%'))
	and length(distinct_id)<9
	and distinct_id in (select b.did from ods_oper_crm.app_chenshui b)
	and time<'2023-09-15'
	GROUP BY distinct_id


--除最后一次外，历史最大App登录间隔天数jianbiao
CREATE TABLE IF NOT EXISTS app_datediffend
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
	SELECT
	    ul1.distinct_id distinct_id,
	    MAX(dateDiff('day', ul1.login_date, ul2.login_date)) AS max_login_interval
	FROM ods_oper_crm.app_datediff AS ul1
	JOIN ods_oper_crm.app_datediff AS ul2 ON ul1.distinct_id = ul2.distinct_id
	    AND ul1.login_rank + 1 = ul2.login_rank
	left join (SELECT
	    distinct_id,
	    MAX(login_rank) AS max_login_rank
	    FROM ods_oper_crm.app_datediff
	    GROUP BY distinct_id)ul3 on ul3.distinct_id=ul1.distinct_id 
	where ul1.login_rank <ul3.max_login_rank
	GROUP BY ul1.distinct_id

-- 登录时间建表
CREATE TABLE IF NOT EXISTS app_datediff
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
    SELECT
        distinct_id,
        date login_date,
        row_number() OVER (PARTITION BY distinct_id ORDER BY login_date) AS login_rank
    FROM ods_rawd.ods_rawd_events_d_di a
    WHERE event ='$AppViewScreen'
    and a.distinct_id in (select b.did from ods_oper_crm.app_chenshui b)
	and length(distinct_id)<9 
	and left($app_version,1)>='5'
    Settings allow_experimental_window_functions = 1
 



		