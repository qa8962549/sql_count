	-- 购车数据
select 
count(distinct x.phone_num)
--,x2.bind_date
from 
(
	select
	distinct a.phone_num,a.created_at
	from
	(
		select
		o.customer_tel phone_num,
		o.created_at
		from ods_oper_crm_cyh_em90_booking_snapshot_d_si t 
		join ods_cydr.ods_cydr_tt_sales_orders_cur o on t.SO_NO =o.so_no
		UNION ALL  
		select
		o.drawer_tel phone_num,
		o.created_at
		from ods_oper_crm_cyh_em90_booking_snapshot_d_si t 
		join ods_cydr.ods_cydr_tt_sales_orders_cur o on t.SO_NO =o.so_no
		UNION ALL  
		select
		o.purchase_phone phone_num,
		o.created_at
		from ods_oper_crm_cyh_em90_booking_snapshot_d_si t 
		join ods_cydr.ods_cydr_tt_sales_orders_cur o on t.SO_NO =o.so_no
	) a
	where length(a.phone_num) = '11'
	and left(a.phone_num,1) = '1'
)x 
left join 		
	(
--		 取最近一次绑车时间
		 select
		 r.member_id,
		 m.cust_id,
		 r.bind_date,
		 r.vin_code,
		 m.member_phone,
		 row_number() over(partition by m.member_phone order by r.bind_date desc) rk
		 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
		 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.is_owner=1  -- 车主
		 and r.member_id is not null 
		 and r.member_id <>''
		 and m.member_phone<>'*'
		 and m.member_phone is not null 
		 Settings allow_experimental_window_functions = 1
	)x2 on x.phone_num=x2.member_phone 
where x2.bind_date is not null 


select count(tl.SO_NO)
from ods_oper_crm_cyh_em90_booking_snapshot_d_si tl
--where t1.cancel_time > '2023-10-01'
            