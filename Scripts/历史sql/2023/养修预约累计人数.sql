-- 养修预约累计人数
select x.t 时间,
x.num 单日养修预约人数,
sum(x.num) over(order by x.t asc) 当年养修预约累计人数,
x.num2 单日养修预约订单数,
sum(x.num2) over(order by x.t asc) 当年养修预约累计订单数
from 
	(
	select b.t
	,count(distinct b.owner_one_id) num
	,count(distinct b.maintain_id) num2
	from 
	(
		SELECT DISTINCT tam.owner_one_id
		,tam.maintain_id
		,date_format(tam.CREATED_AT,'%Y-%m-%d') t
		FROM cyx_appointment.tt_appointment_maintain tam 
		JOIN cyx_appointment.tt_appointment ta ON tam.APPOINTMENT_ID = ta.APPOINTMENT_ID
		WHERE tam.CREATED_AT >='2023-01-01' AND tam.CREATED_AT <'2023-09-25'
		AND ta.DATA_SOURCE = 'C'
	-- 		and tam.MAINTAIN_STATUS NOT IN (80671005,80671007,80671011)
	) b 
	GROUP BY 1 
	order by 1 
)x
