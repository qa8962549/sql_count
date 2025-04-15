--1 2 3
select 
count(distinct user) total_users
,count(distinct user)-count(distinct case when is_vehicle='1' then user else null end) potential_buyers
,count(distinct case when is_vehicle='1' then user else null end) app_car_owner
from ods_oper_crm.ods_oper_crm_active_gio_d_si
where 1=1 
and platform='App'
and dt<'2025-02-01'
 
--今年累计在app发生过活跃的用户数（去重）  截止2025-01-31
select count(distinct user)
from ods_oper_crm.ods_oper_crm_active_gio_d_si 
where 1=1 
and dt>='2025-01-01'
and dt<'2025-02-01'
and platform='App'

--4
select 
count(distinct user) app_car_owner_YAU
from ods_oper_crm.ods_oper_crm_active_gio_d_si
where 1=1 
and is_vehicle='1'
and platform='App'
and dt>='2024-02-01'
and dt<'2025-02-01'
 
 
--5 owners unpair remote control 6 car owners
select 
count(distinct a.user)-count(distinct case when var_is_voc_bind in('1','true') then a.user else null end) owners_unpair_remote_control
,count(distinct case when var_is_voc_bind in('1','true') then a.user else null end) car_owners
from ods_gio.ods_gio_event_d a
inner join ods_oper_crm.ods_oper_crm_usr_gio_d_si b on a.user=b.user
where 1=1
and length(a.user)<9
and event_time<'2025-02-01'
and client_time<'2025-02-01'
and b.is_vehicle='1' -- 绑车
 
--12 匹配EM90/EX30车型 g-car owners
select 
count(distinct case when var_is_voc_bind in('1','true') then a.user else null end) g_car_owners
from ods_gio.ods_gio_event_d a
inner join ods_oper_crm.ods_oper_crm_usr_gio_d_si b on a.user=b.user
join (--'EM90','EX30'车主
	 select
	 distinct 
	-- r.member_id member_id
	 m.cust_id cust_id
	-- tm.model_name `车型（BEV OR T8）`
	 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
	 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) and m.is_deleted = 0 and m.member_status<>'60341003'
	 left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur d on r.vin_code = d.vin and d.is_deleted = 0
	 left join ods_vehi.ods_vehi_tm_vehicle_d tv on r.vin_code = tv.VIN and tv.IS_DELETED = 0
	 left join ods_bada.ods_bada_tm_model_cur tm on ifnull(d.model_id,tv.MODEL_ID) = tm.id and tm.is_deleted = 0
	 left join ods_bada.ods_bada_tm_config_d tc2 on ifnull(d.config_code,tv.CONFIG_CODE) =tc2.CONFIG_CODE and ifnull(d.config_id,tv.CONFIG_ID) =tc2.ID
	 where r.deleted = 0
	 and r.is_bind = 1   -- 绑车
	 and r.is_owner=1  -- 车主
	 and tm.model_name in ('EM90','EX30')
	 and r.date_create<'2025-02-01'
	 )x on a.user::String=x.cust_id::String
where 1=1
and length(a.user)<9
and event_time<'2025-02-01'
and client_time<'2025-02-01'
and b.is_vehicle='1'




--9 在app发生过活跃，且统计时绑车且开启过车控的用户数中，当前车辆绑了icup的
select 
count(distinct case when var_is_voc_bind in('1','true') then a.user else null end) car_owners
from ods_gio.ods_gio_event_d a
join ods_oper_crm.ods_oper_crm_usr_gio_d_si b on a.user=b.user
join (--车辆绑了icup的车主
	 select
	 distinct 
	-- r.member_id member_id
	 m.cust_id cust_id
	-- tm.model_name `车型（BEV OR T8）`
	 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
	 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) and m.is_deleted = 0 and m.member_status<>'60341003'
	 left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur d on r.vin_code = d.vin and d.is_deleted = 0
	 left join ods_vehi.ods_vehi_tm_vehicle_d tv on r.vin_code = tv.VIN and tv.IS_DELETED = 0
	 left join ods_bada.ods_bada_tm_model_cur tm on ifnull(d.model_id,tv.MODEL_ID) = tm.id and tm.is_deleted = 0
	 left join ods_bada.ods_bada_tm_config_d tc2 on ifnull(d.config_code,tv.CONFIG_CODE) =tc2.CONFIG_CODE and ifnull(d.config_id,tv.CONFIG_ID) =tc2.ID
	 where r.deleted = 0
	 and r.is_bind = 1   -- 绑车
	 and r.is_owner=1  -- 车主
	 and (--icup车辆
			(tm.model_name = 'XC90' and tm.model_code = '256' and tv.CONFIG_YEAR in ('2023','2024','2025'))
			or (tm.model_name = 'XC90 RECHARGE' and tm.model_code = '256' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2023','2024','2025'))
			or (tm.model_name = 'S90L' and tm.model_code = '238' and tv.CONFIG_YEAR in ('2022','2023','2024','2025'))
			or (tm.model_name = 'S90L RECHARGE' and tm.model_code = '238' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2022','2023','2024','2025'))
			or (tm.model_name = 'V90CC' and tm.model_code = '236' and tv.CONFIG_YEAR in ('2022','2023','2024','2025'))
			or (tm.model_name = 'XC60' and tm.model_code = '246' and tv.CONFIG_YEAR in ('2022','2023','2024','2025'))
			or (tm.model_name = 'XC60 RECHARGE' and tm.model_code = '246' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2022','2023','2024','2025'))
			or (tm.model_name = 'S60' and tm.model_code = '224' and tv.CONFIG_YEAR in ('2023','2024','2025'))
			or (tm.model_name = 'S60 RECHARGE' and tm.model_code = '224' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2023','2024','2025'))
			or (tm.model_name = 'V60' and tm.model_code = '225' and tv.CONFIG_YEAR in ('2023','2024','2025'))
			or (tm.model_name = 'XC40' and tm.model_code = '536' and tv.CONFIG_YEAR in ('2023','2024','2025'))
			or (tm.model_name = 'XC40 RECHARGE' and tm.model_code = '536' and tv.CONFIG_YEAR in ('2021','2022','2023','2024','2025'))
			or (tm.model_name = 'C40' and tm.model_code = '539' and tv.CONFIG_YEAR in ('2023','2024','2025'))
		)
	 and r.date_create<'2025-02-01'
	 )x on a.user::int=x.cust_id
where 1=1
and length(a.user)<9
and event_time<'2025-02-01'
and client_time<'2025-02-01'
and b.is_vehicle='1'
settings join_use_nulls=1

--10 在app发生过活跃，且统计时绑车且开启过车控的用户数中，当前车辆绑了NON-icup的
select 
count(distinct case when var_is_voc_bind in('1','true') then a.user else null end) car_owners
from ods_gio.ods_gio_event_d a
inner join ods_oper_crm.ods_oper_crm_usr_gio_d_si b on a.user=b.user
join (--当前车辆绑了NON-icup的
	 select
	 distinct 
	-- r.member_id member_id
	 m.cust_id cust_id
	-- tm.model_name `车型（BEV OR T8）`
	 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
	 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) and m.is_deleted = 0 and m.member_status<>'60341003'
	 left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur d on r.vin_code = d.vin and d.is_deleted = 0
	 left join ods_vehi.ods_vehi_tm_vehicle_d tv on r.vin_code = tv.VIN and tv.IS_DELETED = 0
	 left join ods_bada.ods_bada_tm_model_cur tm on ifnull(d.model_id,tv.MODEL_ID) = tm.id and tm.is_deleted = 0
	 left join ods_bada.ods_bada_tm_config_d tc2 on ifnull(d.config_code,tv.CONFIG_CODE) =tc2.CONFIG_CODE and ifnull(d.config_id,tv.CONFIG_ID) =tc2.ID
	 where r.deleted = 0
	 and r.is_bind = 1   -- 绑车
	 and r.is_owner=1  -- 车主
	 and (--non icup车辆
			(tm.model_name = 'S80L' and tm.model_code = '144' and tv.CONFIG_YEAR = '2015')
			or (tm.model_name = 'XC60'and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
			or (tm.model_name = 'S60' and tm.model_code = '134' and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
			or (tm.model_name = 'S60L' and tv.CONFIG_YEAR in ('2015','2016','2017','2018','2019'))
			or (tm.model_name = 'V60' and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
			or (tm.model_name = 'V60CC' and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
			or (tm.model_name = 'V40' and tm.model_code = '525' and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
			or (tm.model_name = 'V40CC' and tm.model_code = '526' and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
			or (tm.model_name = 'XC90' and tm.model_code = '256' and tv.CONFIG_YEAR in ('2016','2017','2018','2019','2020','2021','2022'))
			or (tm.model_name = 'XC90 RECHARGE' and tm.model_code = '256' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2016','2017','2018','2019','2020','2021','2022'))
			or (tm.model_name = 'S90' and tm.model_code = '234' and tv.CONFIG_YEAR = '2017')
			or (tm.model_name = 'S90L' and tm.model_code = '238' and tv.CONFIG_YEAR in ('2018','2019','2020','2021'))
			or (tm.model_name = 'S90L RECHARGE' and tm.model_code = '238' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2018','2019','2020','2021'))
			or (tm.model_name = 'V90CC' and tm.model_code = '236' and tv.CONFIG_YEAR in ('2018','2019','2020','2021'))
			or (tm.model_name = 'XC60' and tm.model_code = '246' and tv.CONFIG_YEAR in ('2018','2019','2020','2021'))
			or (tm.model_name = 'XC60 RECHARGE' and tm.model_code = '246' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2019','2020','2021'))
			or (tm.model_name = 'S60' and tm.model_code = '224' and tv.CONFIG_YEAR in ('2020','2021','2022'))
			or (tm.model_name = 'S60 RECHARGE' and tm.model_code = '224' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2020','2021','2022'))
			or (tm.model_name = 'V60' and tm.model_code = '225' and tv.CONFIG_YEAR in ('2020','2021','2022'))
			or (tm.model_name = 'XC40' and tm.model_code = '536' and tv.CONFIG_YEAR in ('2018','2019','2020','2021','2022'))
		)
	 and r.date_create<'2025-02-01'
	 )x on a.user::int=x.cust_id
where 1=1
and length(a.user)<9
and event_time<'2025-02-01'
and client_time<'2025-02-01'
and b.is_vehicle='1'
settings join_use_nulls=1







-- icup   用户数
select distinct vb.member_id ,tv.VIN ,tm.model_name `车型` ,tm.model_code ,tv.CONFIG_YEAR `年款` ,m.create_time 
from ods_vehi.ods_vehi_tm_vehicle_d tv -- 车辆主表
join ods_bada.ods_bada_tm_model_cur tm on tm.model_code = tv.MODEL_CODE 
join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd on tisd.vin = tv.VIN and tisd.is_deleted = 0 -- 有效发票表
join ods_vocm.ods_vocm_vehicle_bind_relation_cur vb on vb.vin_code = tv.VIN and vb.deleted = 0 and vb.is_bind = 1 and vb.is_owner = 1
left join ods_memb.ods_memb_tc_member_info_cur m on vb.member_id = toString(m.id) and m.is_deleted = 0
where 
(-- TSP车辆
	(tm.model_name = 'S80L' and tm.model_code = '144' and tv.CONFIG_YEAR = '2015')
	or (tm.model_name = 'XC60'and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
	or (tm.model_name = 'S60' and tm.model_code = '134' and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
	or (tm.model_name = 'S60L' and tv.CONFIG_YEAR in ('2015','2016','2017','2018','2019'))
	or (tm.model_name = 'V60' and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
	or (tm.model_name = 'V60CC' and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
	or (tm.model_name = 'V40' and tm.model_code = '525' and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
	or (tm.model_name = 'V40CC' and tm.model_code = '526' and tv.CONFIG_YEAR in ('2015','2016','2017','2018'))
	or (tm.model_name = 'XC90' and tm.model_code = '256' and tv.CONFIG_YEAR in ('2016','2017','2018','2019','2020','2021','2022'))
	or (tm.model_name = 'XC90 RECHARGE' and tm.model_code = '256' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2016','2017','2018','2019','2020','2021','2022'))
	or (tm.model_name = 'S90' and tm.model_code = '234' and tv.CONFIG_YEAR = '2017')
	or (tm.model_name = 'S90L' and tm.model_code = '238' and tv.CONFIG_YEAR in ('2018','2019','2020','2021'))
	or (tm.model_name = 'S90L RECHARGE' and tm.model_code = '238' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2018','2019','2020','2021'))
	or (tm.model_name = 'V90CC' and tm.model_code = '236' and tv.CONFIG_YEAR in ('2018','2019','2020','2021'))
	or (tm.model_name = 'XC60' and tm.model_code = '246' and tv.CONFIG_YEAR in ('2018','2019','2020','2021'))
	or (tm.model_name = 'XC60 RECHARGE' and tm.model_code = '246' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2019','2020','2021'))
	or (tm.model_name = 'S60' and tm.model_code = '224' and tv.CONFIG_YEAR in ('2020','2021','2022'))
	or (tm.model_name = 'S60 RECHARGE' and tm.model_code = '224' and tv.CONFIG_NAME like '%T8%' and tv.CONFIG_YEAR in ('2020','2021','2022'))
	or (tm.model_name = 'V60' and tm.model_code = '225' and tv.CONFIG_YEAR in ('2020','2021','2022'))
	or (tm.model_name = 'XC40' and tm.model_code = '536' and tv.CONFIG_YEAR in ('2018','2019','2020','2021','2022'))
)

