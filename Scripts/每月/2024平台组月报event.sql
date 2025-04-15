--购车页面浏览 分车型
select 
	var_car_type
	,count(distinct user) UV
	,count(user) PV
	,count(distinct case when var_is_bind ='1' then user end) UV_bind
	,count(case when var_is_bind ='1' then user end) PV_bind	
	,count(distinct user) - count(distinct case when var_is_bind ='1' then user end) UV_fensi
	,count(user) - count(case when var_is_bind ='1' then user end) PV_fensi
from ods_gio.ods_gio_event_d
where 1=1
and event_time >='2025-03-01'
and client_time >= '2025-03-01' 
and client_time <'2025-04-01'
and event_key ='Page_entry'
and var_page_title='购车'
--and var_btn_name ='开始绑车'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
and var_car_type is not null 
group by rollup(1)
order by 2 desc

select 
	var_car_type
	,var_is_bind
	,user
	,event_time
	,client_time
from ods_gio.ods_gio_event_d
where 1=1
and event_time >='2025-03-01'
and client_time >= '2025-03-01' 
and client_time <'2025-04-01'
and event_key ='Page_entry'
and var_page_title='购车'
--and var_btn_name ='开始绑车'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
and var_car_type is not null 

select 
var_car_type
,var_btn_name DW
,user 
,var_page_title
,event_key 
--,time
from ods_gio.ods_gio_event_d
where event_key ='Button_click'
and var_page_title ='购车'
and var_btn_name ='售后服务承诺'
and event_time >='2025-04-01'
and client_time >= '2025-04-01' 
--and client_time <'2025-04-01'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
--and var_car_type in ('S60','V90 Cross Country')


select 
var_car_type
,var_btn_name DW
,count(distinct user) UV
,count(user) PV
,count(distinct case when var_is_bind ='1' then user end) UV_bind
,count(case when var_is_bind ='1' then user end) PV_bind	
,count(distinct user) - count(distinct case when var_is_bind ='1' then user end) UV_fensi
,count(user) - count(case when var_is_bind ='1' then user end) PV_fensi
from ods_gio.ods_gio_event_d
where event_key ='Button_click'
and var_page_title ='购车'
and var_btn_name ='售后服务承诺'
and event_time >='2025-03-01'
and client_time >= '2025-03-01' 
and client_time <'2025-04-01'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
and var_car_type is not null 
group by 1,2
order by 1,2 desc

-- 购车页面按钮点击（分车型）
select concat(x.var_car_type,x.DW) DW,
x.*
from 
(
-- EX30 button
select 
var_car_type
,var_btn_name DW
,count(distinct user) UV
,count(user) PV
,count(distinct case when var_is_bind ='1' then user end) UV_bind
,count(case when var_is_bind ='1' then user end) PV_bind	
,count(distinct user) - count(distinct case when var_is_bind ='1' then user end) UV_fensi
,count(user) - count(case when var_is_bind ='1' then user end) PV_fensi
from ods_gio.ods_gio_event_d
where event_key ='Button_click'
and var_page_title ='购车'
and var_btn_name in ('预约试驾',
'立即订购',
'短促Banner',
'金融购车')
and event_time >='2025-03-01'
and client_time >= '2025-03-01' 
and client_time <'2025-04-01'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
and var_car_type is not null 
group by 1,2
order by 1,2 desc
union all 
-- 服务承诺
select 
var_car_type
,'服务承诺' DW
,count(distinct user) UV
,count(user) PV
,count(distinct case when var_is_bind ='1' then user end) UV_bind
,count(case when var_is_bind ='1' then user end) PV_bind	
,count(distinct user) - count(distinct case when var_is_bind ='1' then user end) UV_fensi
,count(user) - count(case when var_is_bind ='1' then user end) PV_fensi
from ods_gio.ods_gio_event_d
where event_key ='Button_click'
and var_page_title ='购车'
and var_btn_name ='了解详情'
and var_content_title='服务承诺'
and event_time >='2025-03-01'
and client_time >= '2025-03-01' 
and client_time <'2025-04-01'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
and var_car_type is not null 
group by 1
order by 1
union all 
-- 购车门店
select 
var_car_type
,'购车门店' DW
,count(distinct user) UV
,count(user) PV
,count(distinct case when var_is_bind ='1' then user end) UV_bind
,count(case when var_is_bind ='1' then user end) PV_bind	
,count(distinct user) - count(distinct case when var_is_bind ='1' then user end) UV_fensi
,count(user) - count(case when var_is_bind ='1' then user end) PV_fensi
from ods_gio.ods_gio_event_d
where event_key ='Button_click'
and var_page_title ='购车'
and ((var_btn_name ='更多'and var_content_title='购车门店') or (var_btn_name in ('经销商图','导航icon')))
and event_time >='2025-03-01'
and client_time >= '2025-03-01' 
and client_time <'2025-04-01'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
and var_car_type is not null 
group by 1
order by 1
union all 
-- 常用工具
select 
var_car_type
,'常用工具' DW
,count(distinct user) UV
,count(user) PV
,count(distinct case when var_is_bind ='1' then user end) UV_bind
,count(case when var_is_bind ='1' then user end) PV_bind	
,count(distinct user) - count(distinct case when var_is_bind ='1' then user end) UV_fensi
,count(user) - count(case when var_is_bind ='1' then user end) PV_fensi
from ods_gio.ods_gio_event_d
where event_key ='Button_click'
and var_page_title ='购车'
and var_btn_name in ('金融计算器','置换增购')
and event_time >='2025-03-01'
and client_time >= '2025-03-01' 
and client_time <'2025-04-01'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
and var_car_type is not null 
group by 1
order by 1
union all 
-- 车型解读 
select 
var_car_type
,'车型解读' DW
,count(distinct user) UV
,count(user) PV
,count(distinct case when var_is_bind ='1' then user end) UV_bind
,count(case when var_is_bind ='1' then user end) PV_bind	
,count(distinct user) - count(distinct case when var_is_bind ='1' then user end) UV_fensi
,count(user) - count(case when var_is_bind ='1' then user end) PV_fensi
from ods_gio.ods_gio_event_d
where event_key ='Button_click'
and var_page_title ='购车'
--and var_btn_name ='内容'
and var_column_name in ('官方解读','大咖测评','用户口碑')
and event_time >='2025-03-01'
and client_time >= '2025-03-01' 
and client_time <'2025-04-01'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
and var_car_type is not null 
group by 1
order by 1
union all 
-- 车型解读 '官方解读','大咖测评','用户口碑'
select 
var_car_type
,var_column_name DW
,count(distinct user) UV
,count(user) PV
,count(distinct case when var_is_bind ='1' then user end) UV_bind
,count(case when var_is_bind ='1' then user end) PV_bind	
,count(distinct user) - count(distinct case when var_is_bind ='1' then user end) UV_fensi
,count(user) - count(case when var_is_bind ='1' then user end) PV_fensi
from ods_gio.ods_gio_event_d
where event_key ='Button_click'
and var_page_title ='购车'
--and var_btn_name ='内容'
and var_column_name in ('官方解读','大咖测评','用户口碑')
and event_time >='2025-03-01'
and client_time >= '2025-03-01' 
and client_time <'2025-04-01'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
and var_car_type is not null 
group by 1,2
order by 1,2
union all 
-- 总计（车主权益）  限时礼遇  会员权益  //里程从容 安心承诺 只己馈礼 专属管家 俱乐部权益 会员权益
select 
var_car_type
,var_btn_name DW
,count(distinct user) UV
,count(user) PV
,count(distinct case when var_is_bind ='1' then user end) UV_bind
,count(case when var_is_bind ='1' then user end) PV_bind	
,count(distinct user) - count(distinct case when var_is_bind ='1' then user end) UV_fensi
,count(user) - count(case when var_is_bind ='1' then user end) PV_fensi
from ods_gio.ods_gio_event_d
where event_key ='Button_click'
and var_page_title ='购车'
and var_content_title='车主权益'
and var_btn_name<>'更多' -- 剔除，避免歧义
and event_time >='2025-03-01'
and client_time >= '2025-03-01' 
and client_time <'2025-04-01'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
and var_car_type is not null 
group by 1,2
order by 1,2
union all 
-- 总计（车主权益）
select 
var_car_type
,var_content_title DW
--,concat(var_car_type,var_content_title)
,count(distinct user) UV
,count(user) PV
,count(distinct case when var_is_bind ='1' then user end) UV_bind
,count(case when var_is_bind ='1' then user end) PV_bind	
,count(distinct user) - count(distinct case when var_is_bind ='1' then user end) UV_fensi
,count(user) - count(case when var_is_bind ='1' then user end) PV_fensi
from ods_gio.ods_gio_event_d
where event_key ='Button_click'
and var_page_title ='购车'
and var_content_title='车主权益'
and var_btn_name<>'更多' -- 剔除，避免歧义
and event_time >='2025-03-01'
and client_time >= '2025-03-01' 
and client_time <'2025-04-01'
and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
and LENGTH(user)<9
and var_car_type is not null 
group by 1,2
order by 1,2
--union all 
---- 售后服务承诺
--select 
--var_car_type
--,var_btn_name DW
--,count(distinct user) UV
--,count(user) PV
--,count(distinct case when var_is_bind ='1' then user end) UV_bind
--,count(case when var_is_bind ='1' then user end) PV_bind	
--,count(distinct user) - count(distinct case when var_is_bind ='1' then user end) UV_fensi
--,count(user) - count(case when var_is_bind ='1' then user end) PV_fensi
--from ods_gio.ods_gio_event_d
--where event_key ='Button_click'
--and var_page_title ='购车'
--and var_btn_name ='售后服务承诺'
--and event_time >='2025-03-01'
--and client_time >= '2025-03-01' 
--and client_time <'2025-04-01'
--and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform` in('MinP') or var_channel ='Mini'))
--and LENGTH(user)<9
--and var_car_type is not null 
--group by 1,2
--order by 1,2 desc
)x
order by 1


	-- 预约试驾
	select 
	'4'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
--	and event_key='$page'
--	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%volvo_world%'
	and `$query` like '%wechat_official_account%'
	and `$query` like'%202312_test_drive_gift%'
	and `$query` like '%menu_bar%'
	and event_time>='2025-04-01' and client_time>='2025-04-01'
	and client_time<'2025-04-01'
	
	
	--官方回购
	select 
	'15'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	-- and event_key='$page'
	and `$query` like '%promotion_supplement=1b286640c91t%'
	and `$query` like '%promotion_activity=241113_gfhgfw%'
	and event_time>='2025-04-01' and client_time>='2025-04-01'
	and client_time<'2025-03-01'