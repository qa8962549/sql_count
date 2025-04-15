
-- APP总用户数
-- APP会员
select count(distinct distinct_id)
from(
	select distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where ((`$lib` in('iOS','Android','HarmonyOS') and left(`$app_version`,1)='5') or channel ='App')
	and a.`time` >= '2022-02-01' -- App开始使用
	and a.`time` < '2024-07-01'
	and distinct_id not like '%#%'
	and length(distinct_id)<9
	union all 
	-- GIO
	select distinct distinct_id
	from dwd_23.dwd_23_gio_tracking gio
	where ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')
	and gio.`time` >= '2024-07-01'
	and gio.`time` < '2024-10-01'
	and gio.distinct_id not like '%#%'
	and length(gio.distinct_id)<9
)
	
	select *
	from ods_gio.ods_gio_event_d a
	limit 10
	
--APP总车主数
select count(distinct x.distinct_id)
from 
	(select distinct distinct_id
	from(
		select distinct distinct_id
		from ods_rawd.ods_rawd_events_d_di a
		where ((`$lib` in('iOS','Android','HarmonyOS') and left(`$app_version`,1)='5') or channel ='App')
		and a.`time` >= '2022-02-01' -- App开始使用
		and a.`time` < '2024-07-01'
		and distinct_id not like '%#%'
		and length(distinct_id)<9
		union all 
		-- GIO
		select distinct distinct_id
		from dwd_23.dwd_23_gio_tracking gio
		where ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')
		and gio.`time` >= '2024-07-01'
		and gio.`time` < '2024-10-01'
		and gio.distinct_id not like '%#%'
		and length(gio.distinct_id)<9
	))x
join 
	(select m.distinct_id,m.`是否车主`
	from (-- 清洗cust_id
		select toString(m.cust_id) `distinct_id` 
			,m.member_time 
			,case when m.is_vehicle = 0 then '2粉丝' when m.is_vehicle = 1 then '1车主' end as `是否车主`
			, row_number() over(partition by m.cust_id order by m.create_time desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where m.member_status <> '60341003'
		and m.is_deleted = 0
		and m.cust_id is not NULL
		and date(m.create_time) < date('2024-10-01')
	) m
	where m.rk=1)x1 on x1.distinct_id=x.distinct_id
where x1.`是否车主`='1车主'
	
--App活跃
	select 
	date,
	count(distinct b.usr_merged_gio_id)
	from dwd_23.dwd_23_gio_tracking gio 
	left join ods_gio.ods_gio_user_d b on b.gio_id =gio.gio_id 
	where ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')
	and gio.`time` >= '2024-07-01'
	and gio.`time` < '2024-10-01'
	and gio.distinct_id not like '%#%'
--	and gio.var_is_bind in ('ture','1')
	group by 1
	order by 1

--App车主活跃
	select 
	date,
	count(distinct b.usr_merged_gio_id)
	from dwd_23.dwd_23_gio_tracking gio 
	left join ods_gio.ods_gio_user_d b on b.gio_id =gio.gio_id 
	join 
		(select m.distinct_id,m.`是否车主`
		from (-- 清洗cust_id
			select toString(m.cust_id) `distinct_id` 
				,m.member_time 
				,case when m.is_vehicle = 0 then '2粉丝' when m.is_vehicle = 1 then '1车主' end as `是否车主`
				, row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status <> '60341003'
			and m.is_deleted = 0
			and m.cust_id is not NULL
			and date(m.create_time) < date('2024-10-01')
		) m
		where m.rk=1)x1 on x1.distinct_id=gio.distinct_id
	where ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')
	and gio.`time` >= '2024-07-01'
	and gio.`time` < '2024-10-01'
	and gio.distinct_id not like '%#%'
--	and gio.var_is_bind in ('ture','1')
	and x1.`是否车主`='1车主'
	group by 1
	order by 1

--mini 活跃
	select 
	date,
	count(distinct b.usr_merged_gio_id)
	from dwd_23.dwd_23_gio_tracking gio 
	left join ods_gio.ods_gio_user_d b on b.gio_id =gio.gio_id 
	where (`$lib` ='MiniProgram' or channel ='Mini')
	and gio.`time` >= '2024-12-01'
	and gio.`time` < '2025-02-01'
--	and gio.distinct_id not like '%#%'
	and length(distinct_id)<9
--	and gio.var_is_bind in ('ture','1')
	group by 1
	order by 1
	
-- 车主社区活跃  运营

-- 社区活跃 yuhui
select a.t, count(DISTINCT a.user) as UV
from
(-- 合并GIO和神策
	select DISTINCT user,toDate(client_time) as t
	from ods_gio.ods_gio_event_d a
	where ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App')
	and event_time>='2025-02-01'
	and client_time >= '2025-02-01' -- App开始使用
	and client_time < '2025-03-01'
	and length(user)<9
	and (
	-- 社区浏览人数
	(event_key in ('Page_view','Page_entry') 
		and (var_page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or var_page_title like '%会员日%' or (var_activity_name like '2023%' and var_activity_id is null) or (var_activity_name like '2024%' and var_activity_id is null)) )
	-- 社区互动人数
	or (event_key='Button_click' and var_page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
		and var_btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') )
	)
union all 
	-- 发现 按钮点击（）7月开始
	select DISTINCT user,toDate(client_time) as t
	from ods_gio.ods_gio_event_d a
	join 
		(select m.distinct_id
		from (-- 清洗cust_id
			select toString(m.cust_id) `distinct_id` 
				,m.is_vehicle
				, row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status <> '60341003'
			and m.is_deleted = 0
			and m.is_vehicle =1 -- 车主
			) m
		where m.rk=1
		)x1 on x1.distinct_id=a.user
	where 1=1
	and event_time>='2025-02-01'
--	AND (event='$view_click'and `$text_value`='发现') -- PV
	and ((event_key='Button_click' and var_btn_name='发现' ) or (event_key='$AppClick' and var_sa_element_content='发现' ) or (event_key='$view_click' and `$text_value` ='发现' )) -- UV
	and client_time >= '2025-02-01' -- App开始使用
	and client_time < '2025-03-01'
	and length(user)<9 
)a
group by 1 
order by 1 
	
--功能 -- 车主
select toDate(client_time),count(distinct user) 
from ods_gio.ods_gio_event_d a
	join 
		(select m.distinct_id
		from (-- 清洗cust_id
			select toString(m.cust_id) `distinct_id` 
				,m.is_vehicle
				, row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status <> '60341003'
			and m.is_deleted = 0
			and m.is_vehicle =1 -- 车主
			) m
		where m.rk=1
		)x1 on x1.distinct_id=a.user
where 1=1 
	and event_time>='2025-02-01'
	and client_time >= '2025-02-01' -- App开始使用
	and client_time < '2025-03-01'
	and length(user)<9
	and ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App')
and event_key in('Page_entry','Page_view','Button_click')
and var_page_title in('车型详情','预约试驾','养修预约','预约养修','金融计算器','官方直售_首页','官方二手车','充电专区','在线客服','服务单详情','养修日志','养修日志_进行中','爱车详情','养修日志_全部','养修日志_待评价','结算单','延保服务','保养权益')
group by 1
order by 1
	
-- 车控
	select t,count(DISTINCT id) as UV
	from
	(
		select DISTINCT cast(memberid as varchar) as id,toDate(`date`) as t
		from dwd_23.dwd_23_gio_tracking a
		where length(distinct_id)<9
		and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- App
		and event_time>='2025-02-01'
		and `date`>='2024-10-01' and `date`<'2024-12-01'
		and 
		(-- 1、车控全埋点
			(event='$AppClick' and 
				(-- ————————————[车控全埋点]————————————
				-- 空气清洁
				((`$element_path`='UIView/VocKit.ButtonWithSelectorView[0]/UIStackView[0]/VocKit.Button[0]' and `$title` in('空气清洁','空气净化','空氣淨化','空氣清淨','Air purification','Air cleaning','空気清浄','공기 정화 중') ) or (var_sa_element_id='fragment_air_cleaning_button_action' and `$title` in('空气清洁','空气净化','空氣淨化','空氣清淨','Air purification','Air cleaning','空気清浄','공기 정화 중') ) )
				-- 车门
				or ((`$element_path`='UIView/VocKit.ButtonWithSelectorView[0]/UIStackView[0]/VocKit.Button[0]' and `$title` in('车门','Doors','車門','ドア','문','Drzwi','Türen','Portes','Portas','Puertas')) or (`$element_path`='android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.appcompat.widget.FitWindowsLinearLayout[0]/androidx.appcompat.widget.ContentFrameLayout[0]/android.widget.RelativeLayout[0]/android.widget.LinearLayout[1]/android.widget.RelativeLayout[0]/android.widget.FrameLayout[0]/se.volvo.vcc.ui.fragments.root.MyCarRootFragment[0]/android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.viewpager2.widget.ViewPager2[0]/androidx.viewpager2.widget.ViewPager2.RecyclerViewImpl[0]/android.widget.FrameLayout[-]/androidx.constraintlayout.widget.ConstraintLayout[0]/androidx.constraintlayout.widget.ConstraintLayout[1]/com.volvocars.uiviews.VOCButton[0]' and `$title` in('车门','Doors','車門','ドア','문','Drzwi','Türen','Portes','Portas','Puertas')) or (`$element_path`='android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.appcompat.widget.FitWindowsLinearLayout[0]/androidx.appcompat.widget.ContentFrameLayout[0]/android.widget.RelativeLayout[0]/android.widget.LinearLayout[1]/android.widget.RelativeLayout[0]/android.widget.FrameLayout[0]/se.volvo.vcc.ui.fragments.root.MyCarRootFragment[0]/android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.viewpager2.widget.ViewPager2[0]/androidx.viewpager2.widget.ViewPager2.RecyclerViewImpl[0]/android.widget.FrameLayout[0]/androidx.constraintlayout.widget.ConstraintLayout[0]/android.widget.FrameLayout[0]/androidx.constraintlayout.widget.ConstraintLayout[0]/androidx.recyclerview.widget.RecyclerView[0]/androidx.constraintlayout.widget.ConstraintLayout[-]' and `$title` in('车门','Doors','車門','ドア','문','Drzwi','Türen','Portes','Portas','Puertas')) )
				-- 温度调节
				or (`$title` in('温度调节','Climate','空調','Climatisation','Klimatyzacja') and (`$element_path`='UIView/VocKit.ButtonWithSelectorView[0]/UIStackView[0]/VocKit.Button[0]' or var_sa_element_id in('fragment_hometab_climate_button_start','fragment_climate_bottom_sheet_button_start')) )
				-- 寻找车辆
				or (`$title`='寻找车辆' and (`$element_path` in('UIView/UIStackView[0]/VKMapVehicleView[0]/VocKit.MapButtonsView[0]/VocKit.ButtonWithLoader[1]/VocKit.Button[0]','UIView/UIStackView[0]/VKMapVehicleView[0]/VocKit.MapButtonsView[0]/VocKit.ButtonWithLoader[0]/VocKit.Button[0]') or var_sa_element_id in('layout_action_buttons_linearlayout_right_container','layout_action_buttons_linearlayout_left_container')) )
				)
			) 
		-- 2、车门
			or (event='Button_click'and page_title='车门'and btn_name in ('锁定','解锁'))
		)
	)a
	group by t 
	order by t

	

----------------------------------------------------------------------------------------------------------------------------

-- 使用远程车控天数(车控按钮点击)
 select date,
 count(DISTINCT distinct_id)
 from ods_rawd.ods_rawd_events_d_di
 where length(distinct_id)<9
 and is_bind=1
 and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or channel ='App')
 and ((event='$AppClick' 
	and ( -- ————————————[车控全埋点]————————————
		  -- 空气清洁
		    ( (`$element_path`='UIView/VocKit.ButtonWithSelectorView[0]/UIStackView[0]/VocKit.Button[0]' and `$title` in('空气清洁','空气净化','空氣淨化','空氣清淨','Air purification','Air cleaning','空気清浄','공기 정화 중'))
		    or (`$element_id`='fragment_air_cleaning_button_action' and `$title` in('空气清洁','空气净化','空氣淨化','空氣清淨','Air purification','Air cleaning','空気清浄','공기 정화 중')) )
		  -- 车门
		  or ((`$element_path`='UIView/VocKit.ButtonWithSelectorView[0]/UIStackView[0]/VocKit.Button[0]' and `$title` in('车门','Doors','車門','ドア','문','Drzwi','Türen','Portes','Portas','Puertas'))
		    or (`$element_path`='android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.appcompat.widget.FitWindowsLinearLayout[0]/androidx.appcompat.widget.ContentFrameLayout[0]/android.widget.RelativeLayout[0]/android.widget.LinearLayout[1]/android.widget.RelativeLayout[0]/android.widget.FrameLayout[0]/se.volvo.vcc.ui.fragments.root.MyCarRootFragment[0]/android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.viewpager2.widget.ViewPager2[0]/androidx.viewpager2.widget.ViewPager2.RecyclerViewImpl[0]/android.widget.FrameLayout[-]/androidx.constraintlayout.widget.ConstraintLayout[0]/androidx.constraintlayout.widget.ConstraintLayout[1]/com.volvocars.uiviews.VOCButton[0]' and `$title` in('车门','Doors','車門','ドア','문','Drzwi','Türen','Portes','Portas','Puertas'))
		    or (`$element_path`='android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.appcompat.widget.FitWindowsLinearLayout[0]/androidx.appcompat.widget.ContentFrameLayout[0]/android.widget.RelativeLayout[0]/android.widget.LinearLayout[1]/android.widget.RelativeLayout[0]/android.widget.FrameLayout[0]/se.volvo.vcc.ui.fragments.root.MyCarRootFragment[0]/android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.viewpager2.widget.ViewPager2[0]/androidx.viewpager2.widget.ViewPager2.RecyclerViewImpl[0]/android.widget.FrameLayout[0]/androidx.constraintlayout.widget.ConstraintLayout[0]/android.widget.FrameLayout[0]/androidx.constraintlayout.widget.ConstraintLayout[0]/androidx.recyclerview.widget.RecyclerView[0]/androidx.constraintlayout.widget.ConstraintLayout[-]' and `$title` in('车门','Doors','車門','ドア','문','Drzwi','Türen','Portes','Portas','Puertas')) )
		  -- 温度调节
		  or ( `$title` in('温度调节','Climate','空調','Climatisation','Klimatyzacja') and (`$element_path`='UIView/VocKit.ButtonWithSelectorView[0]/UIStackView[0]/VocKit.Button[0]' or `$element_id` in('fragment_hometab_climate_button_start','fragment_climate_bottom_sheet_button_start')) )
		  -- 寻找车辆
		  or ( `$title`='寻找车辆' and (`$element_path` in('UIView/UIStackView[0]/VKMapVehicleView[0]/VocKit.MapButtonsView[0]/VocKit.ButtonWithLoader[1]/VocKit.Button[0]','UIView/UIStackView[0]/VKMapVehicleView[0]/VocKit.MapButtonsView[0]/VocKit.ButtonWithLoader[0]/VocKit.Button[0]') or `$element_id` in('layout_action_buttons_linearlayout_right_container','layout_action_buttons_linearlayout_left_container')) )
		  ))  
	  or 
	  -- 车门
	  (event='Button_click'and page_title='车门'and btn_name in ('锁定','解锁')) )
 and `date`>='2024-04-01'
 and `date`<'2024-07-01'
 group by date
 order by date






-- App粉丝注册时长
select 
case when datediff('day',toDate('2023-09-01'),toDate(m.create_time))<=30 then 1 else 2 end tt
,count(distinct m.id)
from ods_memb.ods_memb_tc_member_info_cur m
global join ods_rawd_events_d_di a on toString(m.cust_id)=toString(a.distinct_id)  
where 1=1
and ((a.$lib in('iOS','Android') and left(a.$app_version,1)='5') or a.channel ='App') -- APP
and a.date >= '2024-07-01' 
and a.date<'2023-09-01' 
and length(a.distinct_id)<9
and a.is_bind=0 -- 粉丝
group by tt

-- App粉丝注册时长test
select 
case when datediff('day',toDate(x.mt),toDate('2023-09-01'))<=30 then 1 
	when datediff('day',toDate(x.mt),toDate('2023-09-01'))>=31 and datediff('day',toDate(x.mt),toDate('2023-09-01'))<=60 then 2 
	when datediff('day',toDate(x.mt),toDate('2023-09-01'))>=61 and datediff('day',toDate(x.mt),toDate('2023-09-01'))<=90 then 3 
	when datediff('day',toDate(x.mt),toDate('2023-09-01'))>=91 and datediff('day',toDate(x.mt),toDate('2023-09-01'))<=180 then 4
	when datediff('day',toDate(x.mt),toDate('2023-09-01'))>=181 and datediff('day',toDate(x.mt),toDate('2023-09-01'))<=365 then 5 
	when datediff('day',toDate(x.mt),toDate('2023-09-01'))>=366 and datediff('day',toDate(x.mt),toDate('2023-09-01'))<=730 then 6
else 7 end tt
,count(distinct x.distinct_id)
from ods_rawd_events_d_di a
global left join (
	select 
	a.distinct_id,
	min(a.date) mt
	from ods_rawd_events_d_di a 
	where 1=1
	and ((a.$lib in('iOS','Android') and left(a.$app_version,1)='5') or a.channel ='App') -- APP
	and length(a.distinct_id)<9
	and a.is_bind=0 -- 粉丝
	group by distinct_id
	)x on x.distinct_id=a.distinct_id
where 1=1
and ((a.$lib in('iOS','Android') and left(a.$app_version,1)='5') or a.channel ='App') -- APP
and a.date >= '2023-08-01' 
and a.date<'2023-09-01' 
and length(a.distinct_id)<9
and a.is_bind=0 -- 粉丝
and a.distinct_id GLOBAL not in (
	select distinct distinct_id 
	from ods_rawd_events_d_di 
	where is_bind=1
	and date >= '2023-08-01' 
	and date<'2023-09-01' )
group by tt

------------------------------------------------


