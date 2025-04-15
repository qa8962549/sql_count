-- 累计车主用户数
select 
	 count(distinct case when m.create_time < '2024-02-01' then m.id end) `1月`
	,count(distinct case when m.create_time < '2024-03-01' then m.id end) `2月`
	,count(distinct case when m.create_time < '2024-04-01' then m.id end) `3月`
	,count(distinct case when m.crea
	te_time < '2024-05-01' then m.id end) `4月`
	,count(distinct case when m.create_time < '2024-06-01' then m.id end) `5月`
	,count(distinct case when m.create_time < '2024-07-01' then m.id end) `6月`
	,count(distinct case when m.create_time < '2024-08-01' then m.id end) `7月`
	,count(distinct case when m.create_time < '2024-09-01' then m.id end) `8月`
	,count(distinct case when m.create_time < '2024-10-01' then m.id end) `9月`
	,count(distinct case when m.create_time < '2024-11-01' then m.id end) `10月`
	,count(distinct case when m.create_time < '2024-12-01' then m.id end) `11月`
	,count(distinct case when m.create_time < '2025-01-01' then m.id end) `12月`
--select distinct vb.member_id ,tv.VIN ,tm.model_name `车型` ,tm.model_code ,tv.CONFIG_YEAR `年款` ,m.create_time 
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



-- 月活数量
select mdt ,count(distinct m.id)
from ods_vehi.ods_vehi_tm_vehicle_d tv -- 车辆主表
join ods_bada.ods_bada_tm_model_cur tm on tm.model_code = tv.MODEL_CODE 
join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd on tisd.vin = tv.VIN and tisd.is_deleted = 0 -- 有效发票表
join ods_vocm.ods_vocm_vehicle_bind_relation_cur vb on vb.vin_code = tv.VIN and vb.deleted = 0 and vb.is_bind = 1 and vb.is_owner = 1
left join ods_memb.ods_memb_tc_member_info_cur m on vb.member_id = toString(m.id) and m.is_deleted = 0
join (select distinct memberid ,month(dt) mdt from ods_oper_crm.ods_oper_crm_active_gio_l_si where dt >= '2024-01-01') a on a.memberid = toString(m.id)
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
group by 1
order by 1



















