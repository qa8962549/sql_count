-- 首页下级最常去top模块(推荐、俱乐部、活动、头条、探索、快速入口)
select
DATE_FORMAT(t.date,'%Y-%m')日期,
COUNT(distinct t.usertag) PV
from track.track t
where t.typeid= 'XWSJXCX_CUSTOMER_V'
and t.date<'2023-04-23'
group by 1 
order by 1 desc 

select
DATE_FORMAT(t.date,'%Y-%m')日期,
count(distinct case when json_extract(t.`data`,'$.title')='官方直售'then t.usertag else null end ) 官方直售,
count(distinct case when json_extract(t.`data`,'$.title')='官方二手车'then t.usertag else null end ) 官方二手车,
count(distinct case when json_extract(t.`data`,'$.title')='充电桩安装'then t.usertag else null end ) 充电桩安装,
count(distinct case when json_extract(t.`data`,'$.title')='用车助手'then t.usertag else null end ) 用车助手,
count(distinct case when json_extract(t.`data`,'$.title')='大客户购车'then t.usertag else null end ) 大客户购车,
count(distinct case when json_extract(t.`data`,'$.title')='归国留学人员购车'then t.usertag else null end ) 归国留学人员购车,
count(distinct case when json_extract(t.`data`,'$.title')='金融计算器'then t.usertag else null end ) 金融计算器,
count(distinct case when json_extract(t.`data`,'$.title')='置换增购'then t.usertag else null end ) 置换增购,
count(distinct case when json_extract(t.`data`,'$.title')='附近充电站'then t.usertag else null end ) 附近充电站,
count(distinct case when json_extract(t.`data`,'$.title')='养修预约'then t.usertag else null end ) 养修预约,
count(distinct case when json_extract(t.`data`,'$.title')='车主活动'then t.usertag else null end ) 车主活动,
count(distinct case when json_extract(t.`data`,'$.title')='免费取送车'then t.usertag else null end ) 免费取送车,
count(distinct case when json_extract(t.`data`,'$.title')='一键救援'then t.usertag else null end ) 一键救援,
count(distinct case when json_extract(t.`data`,'$.title')='试乘试驾'then t.usertag else null end ) 试乘试驾,
count(distinct case when json_extract(t.`data`,'$.title')='历史保单'then t.usertag else null end ) 历史保单,
count(distinct case when json_extract(t.`data`,'$.title')='提车作业'then t.usertag else null end ) 提车作业,
count(distinct case when json_extract(t.`data`,'$.title')='养修日志'then t.usertag else null end ) 养修日志
from track.track t
where t.typeid= 'XWSJPC_CMSHOME_JGQ_C'
and t.date<'2023-04-23'
and t.date>'2023-01-01'
group by 1
order by 1 desc 

-- and t.data like '%volvo://select/index%'
-- and json_extract(t.`data`,'$.title')='官方直售'	
    

-- group by 1 
-- order by 1 desc 


--- 用车助手 2022.1.10
-- 区分车主粉丝-爱车-更多服务
select 
DATE_FORMAT(t.date,'%Y-%m')日期,
case when t.data like '%/src/pages/common/common-auth/index?returnUrl=https%3A%2F%2Fds-f2e.digitalvolvo.com%2Fwebroot-h5%2Findex.html%3FpaymentPlatform%3Dnewbie%26openid%3D%23%2F%' then '01 官方直售'
	when t.data like '%https://usedcar.volvocars.com.cn/%' then '02 官方二手车'
	when t.data like '%/src/pages/xc40-package/xc40-equities/recharge-introduce/recharge-introduce%' then '03 充电桩安装'
	when t.data like '%/src/pages/lovecar-package/car-assistant/index%' then '04 用车助手'
	when t.data like '%/src/pages/lovecar-package/big-customer-buy-car/index/index%' then '05 大客户购车'
	when t.data like '%/src/pages/lovecar-package/student-buy-car/student-buy-car-index/index%' then '06 归国留学人员购车'
	when t.data like '%/src/pages/lovecar-package/finance-count/index%' then '07 金融计算器'
	when t.data like '%volvo://select/index%' then '08 置换增购'
	when t.data like '%/src/pages/xc40-package/xc40-equities/xc40rChargingMap/xc40rChargingMap%' then '09 附近充电站'
	when t.data like '%/src/pages/lovecar-package/repair-order/repair-order%' then '10 养修预约'
	when t.data like '%/src/pages/market-package/active/list/index%' then '11 车主活动'
	when t.data like '%/src/pages/lovecar-package/send-car-reservation/send-car-reservation%' then '12 免费取送车'
	when t.data like '%/src/pages/lovecar-package/rescue/index%' then '13 一键救援'
	when t.data like '%/src/pages/lovecar-package/appointment/appointment%' then '14 试乘试驾'
	when t.data like '%/src/pages/lovecar-package/historical-policy/index/index%' then '15 历史保单'
	when t.data like '%/src/pages/market-package/pickupcar/index%' then '16 提车作业'
	when t.data like '%/src/pages/lovecar-package/maintenance-log/index%' then '17 养修日志'
else null end '分类',
COUNT(t.usertag) as 'PV',
COUNT(distinct t.usertag) as 'UV' 
from track.track t
where t.`date`>='2021-01-01' and t.`date`<'2023-04-23'
group by 1,2
order by 1 desc ,2


-- 爱车点击率占比
select
case when t.typeid="XWSJXCX_OWNER_V" then '01 爱车-车主'
	when t.typeid="XWSJXCX_CUSTOMER_V" then '02 爱车-粉丝'
	else null end '分类',
COUNT(usertag) as 'PV',
COUNT(distinct usertag) as 'UV'
from track.track t
left join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as varchar)
where t.`date`>='2021-01-01' and t.`date`<'2022-01-01'
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
group by 1
order by 1;

-- 车主
select 
case when t.data like '%/src/pages/lovecar-package/my-servers/index%' then '01 更多服务'
	when t.data like '%/src/pages/lovecar-package/car-assistant/index%' then '02 用车助手'
else null end '分类',
tmi.IS_VEHICLE 是否车主,
COUNT(usertag) as 'PV',
COUNT(distinct usertag) as 'UV' 
from track.track t
left join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as varchar)
where t.`date`>='2021-01-01' and t.`date`<'2022-01-01'
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
group by 1,2
order by 1,2;

--- 粉丝
select 
case when t.data like '%/src/pages/lovecar-package/car-assistant/index%' then '01 用车助手'
else null end '分类',
tmi.IS_VEHICLE 是否车主,
COUNT(usertag) as 'PV',
COUNT(distinct usertag) as 'UV' 
from track.track t
left join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as varchar)
where tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
group by 1,2
order by 1,2;

--- 提问、回答
select *
from volvo_cms.question_collect qc
left join volvo_cms.answer_collect ac on qc.uid = ac.question_id 
where qc.is_delete = 0
and ac.is_delete = 0
and ac.from_type = 1


select * from volvo_cms.question_collect qc where qc.is_delete = 0 and qc.title = '怎么修改VOLVO ID呢？'
select * from volvo_cms.answer_collect ac


--- 搜索PV UV
select
case when t.typeid="XWSJXCX_OWNER_YCZS_SEARCH_C" then '搜索'
	else null end '分类',
COUNT(usertag) as 'PV',
COUNT(distinct usertag) as 'UV'
from track.track t
left join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as varchar)
where tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
group by 1
order by 1;


-- 爱车点击率占比
select
case when t.typeid="XWSJXCX_OWNER_V" then '01 爱车-车主'
 when t.typeid="XWSJXCX_CUSTOMER_V" then '02 爱车-粉丝'
 else null end '分类',
COUNT(usertag) as 'PV',
COUNT(distinct usertag) as 'UV'
from track.track t
left join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as varchar)
where tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
group by 1
order by 1;