--每个月公众号新增关注人数
select date_format(a.create_time,'%Y-%m')
,count(a.open_id)
from 
	(select a.open_id
	,a.create_time 
	,row_number ()over(partition by a.open_id order by a.create_time) rk 
	from volvo_wechat_live.es_qr_code_logs a
	where a.eventtype ='subscribe')a
where a.rk=1 
and a.create_time>='2021-01-01'
and a.create_time<'2023-01-01'
group by 1
order by 1 
