--迁移车主数	 车龄1
select formatDateTime(a.min_app,'%Y-%m') t,
count(distinct a.memberid)n,
count(distinct case when x.num is null then a.memberid else null end)nnull,
count(distinct case when x.num =0 then a.memberid else null end)n0,
count(distinct case when x.num =1 then a.memberid else null end)n1,
count(distinct case when x.num =2 then a.memberid else null end)n2,
count(distinct case when x.num =3 then a.memberid else null end)n3,
count(distinct case when x.num =4 then a.memberid else null end)n4,
count(distinct case when x.num =5 then a.memberid else null end)n5,
count(distinct case when x.num =6 then a.memberid else null end)n6,
count(distinct case when x.num =7 then a.memberid else null end)n7,
count(distinct case when x.num =8 then a.memberid else null end)n8,
count(distinct case when x.num =9 then a.memberid else null end)n9,
count(distinct case when x.num >=10 then a.memberid else null end)nn
from ods_oper_crm.ods_oper_crm_usrv2_gio_d_si a
left join 
(
--车龄
	select distinct 
	xx.member_id,
	tisd.invoice_date,
--	xx.model_name model_name,
	floor(datediff('month', toDate(invoice_date), toDate(now())) / 12) AS num --向下取整
--	datediff('year',toDate(tisd.invoice_date),toDate(now())) numx
	from 
		(select distinct a.cust_id as id,
		a.member_id member_id,
		a.vin_code vin_code,
		a.model_name model_name
		from (
	--		 取最近一次绑车时间
			 select
			 r.member_id member_id,
			 m.cust_id cust_id,
			 r.bind_date,
			 r.vin_code vin_code,
			 m.member_phone,
			 row_number() over(partition by r.member_id order by r.bind_date desc) rk,
			 m2.model_name model_name
			 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
			 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
			  left join ods_bada.ods_bada_tm_model_cur m2 on r.series_code=m2.model_code
			 where r.deleted = 0
			 and r.is_bind = 1   -- 绑车
			 and r.is_owner=1  -- 车主
			 )a 
		where a.rk=1 
		)xx 
	left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd on xx.vin_code=tisd.vin  -- 与发票表关联
	where xx.id is not null 
--	order by 2 desc 
	)x on x.member_id =a.memberid 
where min_app>min_mini -- 小程序迁移app
and is_vehicle='1'
and min_app>='2024-01-01'
and min_app<'2025-04-01'
and a.memberid is not null
group by 1 
order by 1 


--迁移车主数	 App注册前1年内小程序活跃分布
select formatDateTime(a.min_app,'%Y-%m') t,
count(a.memberid),
count(case when x2.num is null then a.memberid else null end)anull,
count(case when x2.num =0 then a.memberid else null end)a0,
count(case when x2.num =1 then a.memberid else null end)a1,
count(case when x2.num =2 then a.memberid else null end)a2,
count(case when x2.num =3 then a.memberid else null end)a3,
count(case when x2.num =4 then a.memberid else null end)a4,
count(case when x2.num =5 then a.memberid else null end)a5,
count(case when x2.num =6 then a.memberid else null end)a6,
count(case when x2.num =7 then a.memberid else null end)a7,
count(case when x2.num =8 then a.memberid else null end)a8,
count(case when x2.num =9 then a.memberid else null end)a9,
count(case when x2.num =10 then a.memberid else null end)a10,
count(case when x2.num =11 then a.memberid else null end)a11,
count(case when x2.num =12 then a.memberid else null end)a12,
count(case when x2.num =13 then a.memberid else null end)a13
from ods_oper_crm.ods_oper_crm_usrv2_gio_d_si a
left join 
	(--App注册前1年内小程序活跃分布
	select 
	a.memberid ,
	count(distinct formatDateTime(b.dt,'%Y-%m')) num 
	from ods_oper_crm.ods_oper_crm_usrv2_gio_d_si a
	left join ods_oper_crm.ods_oper_crm_activev2_gio_d_si b on a.memberid =b.memberid 
	where min_app>min_mini -- 小程序迁移app
	and is_vehicle='1' -- 车主
	and min_app>='2024-01-01'
	and min_app<'2025-04-01'
	and b.dt < min_app and b.dt >=min_app- interval '1' year
	group by 1
	order by 2 
	)x2 on x2.memberid =a.memberid 
where min_app>min_mini -- 小程序迁移app
and is_vehicle='1'
and min_app>='2024-01-01'
and min_app<'2025-04-01'
group by 1 
order by 1 


--App注册前后30天内回厂记录
	select 
	formatDateTime(a.min_app,'%Y-%m') t,
	count(distinct a.memberid),
	count(distinct case when o.RO_CREATE_DATE <'2000-01-01' then a.memberid else null end )a0,
	count(distinct case when (o.RO_CREATE_DATE >'2000-01-01' and o.RO_CREATE_DATE <min_app- interval 30 day)
			or o.RO_CREATE_DATE >min_app+ interval 30 day then a.memberid else null end )a1,
	count(distinct case when o.RO_CREATE_DATE < min_app and o.RO_CREATE_DATE >=min_app- interval 30 day then a.memberid else null end)a2,
	count(distinct case when o.RO_CREATE_DATE >min_app and o.RO_CREATE_DATE <=min_app+ interval 30 day then a.memberid else null end)a3
	from ods_oper_crm.ods_oper_crm_usrv2_gio_d_si a
	join ods_memb.ods_memb_tc_member_info_cur m on a.memberid =m.id::String
	left join (	
--	售后回厂的送修人手机号
		select
		distinct o.DELIVERER_MOBILE,
		o.RO_CREATE_DATE ,
		RO_NO
		from ods_cyre.ods_cyre_tt_repair_order_d o
		where 1=1
		and o.IS_DELETED = 0
		and o.REPAIR_TYPE_CODE <> 'P'
		and o.RO_STATUS = '80491003'    -- 已结算工单、
		)o on o.DELIVERER_MOBILE = m.member_phone 
	where min_app>min_mini -- 小程序迁移app
	and a.is_vehicle='1'
	and min_app>='2024-01-01'
	and min_app<'2025-04-01'
--	and o.RO_CREATE_DATE < min_app 
--	and o.RO_CREATE_DATE >=min_app- interval 30 day
	group by 1 
	ORDER BY 1 

--App注册前后30天内回厂记录 test 
	select 
	memberid,
	min_app,
	RO_CREATE_DATE
	from ods_oper_crm.ods_oper_crm_usrv2_gio_d_si a
	join ods_memb.ods_memb_tc_member_info_cur m on a.memberid =m.id::String
	left join (	
--	售后回厂的送修人手机号
		select
		distinct o.DELIVERER_MOBILE,
		o.RO_CREATE_DATE ,
		RO_NO
		from ods_cyre.ods_cyre_tt_repair_order_d o
		where 1=1
		and o.IS_DELETED = 0
		and o.REPAIR_TYPE_CODE <> 'P'
		and o.RO_STATUS = '80491003'    -- 已结算工单、
		)o on o.DELIVERER_MOBILE = m.member_phone 
	where min_app>min_mini -- 小程序迁移app
	and a.is_vehicle='1'
	and min_app>='2024-01-01'
	and min_app<'2025-04-01'
--	and o.RO_CREATE_DATE < min_app 
--	and o.RO_CREATE_DATE >=min_app- interval 30 day



	
