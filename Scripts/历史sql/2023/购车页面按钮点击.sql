select
t.typeid,t.data
-- DATE_FORMAT(t.date,'%Y-%m')日期,
-- COUNT(distinct t.usertag) PV
from track.track t 
where 1=1
and t.date>='2023-03-23'
-- and t.typeid= 'XWSJXCX_CUSTOMER_V'
and json_extract(t.`data`,'$.title')='养修日志'

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
