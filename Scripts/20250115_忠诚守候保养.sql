--车主的ID，车辆开票日期，最近一次登陆App的时间，最近一次进店时间，卡券是否核销
--卡券编号：KQ202412300077
 select
 distinct 
 r.vin_code vin_code,
 r.member_id member_id,
-- m.cust_id cust_id,
-- m.member_phone member_phone,
 d.invoice_date `车辆开票日期`,
 x.max_app `最近一次登陆App的时间`,
 case when x2.t<'2000-01-01' then null else x2.t end `最近一次进店时间`,
 if(x3.vin is not null,'是','否') `卡券是否核销`
 from 
	 (
	 select r.member_id,
	 r.vin_code,
	 ROW_NUMBER ()over(partition by r.vin_code order by date_create desc) rk
	 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
	 where r.deleted = 0
	 and r.is_bind = 1   -- 绑车
	 and r.is_owner=1  -- 车主
	 )r
 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) and m.is_deleted = 0 and m.member_status<>'60341003'
 left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur d on r.vin_code = d.vin and d.is_deleted = 0
 left join ods_oper_crm.ods_oper_crm_usr_gio_d_si x on x.memberid =r.member_id -- 取最近一次app时间
left join (
		select e.VIN , 
		RO_CREATE_DATE t,
		ROW_NUMBER ()over(partition by e.VIN order by RO_CREATE_DATE desc) rk
		from ods_cyre.ods_cyre_tt_repair_order_d e 
		where 1=1
--		and e.RO_CREATE_DATE >=toDate(now()) - interval 1 year 
--		and e.RO_CREATE_DATE <toDate(now())
		and e.RO_STATUS = '80491003'-- 已结算工单
		and e.REPAIR_TYPE_CODE <> 'P'-- 售后
		and e.REPAIR_TYPE_CODE <> 'S'
		and e.IS_DELETED = 0
	)x2 on x2.VIN=r.vin_code and x2.rk=1
left join (
	-- 卡券核销
	select
	tcv.id id,
	tcv.order_no order_no,
	tcv.coupon_id coupon_id,
	tcv.vin 
	from ods_coup.ods_coup_tt_coupon_verify_d tcv
	where 1=1
	and tcv.order_no is not null
	and tcv.is_deleted = 0
	and tcv.coupon_id='8581'
	)x3 on x3.vin=r.vin_code
where r.rk=1



select vin VIN,
max(delivery_date) 车辆开票日期2
from customer.vehicle_details
where vin is not null 
and delivery_date is not null 
group by 1 

