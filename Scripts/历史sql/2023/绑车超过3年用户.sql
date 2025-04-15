-- 绑车超过三年的用户
	select a.member_id
	,tmi.cust_id 
	,a.vin_code
	,a.series_code
	,a.bind_date
	from 
		(
		select a.*,
		row_number()over(partition by a.member_id order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		where a.deleted = 0
		and a.is_bind=1)a 
	left join "member".tc_member_info tmi on a.member_id=tmi.id and tmi.is_deleted = 0 and tmi.member_status <> '60341003'
	where a.rk=1
	and a.bind_date <curdate() - interval '3 year'

	

-- 开票经销商区域为南区和西区，且开票时间3年以上（小于2020-08-06）的绑车车主
select tg.大区名称
	,tm.model_name 
	,tmi.member_phone
--	,count(*)
from vehicle.tt_invoice_statistics_dms kp 
inner join (
	select vin_code, member_id
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr 
on kp.vin = vr.vin_code and vr.rn=1
inner join "member".tc_member_info tmi on vr.member_id = tmi.id 
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
inner join (
	select tm.COMPANY_CODE,
		tm.ORG_ID 经销商组织ID,
	    case when tm.city_name like '%市' then left(tm.city_name, length(tm.city_name)-1) else tm.city_name end CITY_NAME,
	    to1.ID 大区组织ID,
	    to1.ORG_NAME 大区名称
	from organization.tm_company tm
	inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	inner JOIN organization.tm_org to1 ON to1.id = tr2.parent_org_id and to1.ORG_TYPE = 15061005 
	where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	) tg
on kp.dealer_code = tg.COMPANY_CODE and tg.大区名称 in ('南区','西区')
left join vehicle.tm_vehicle tv
on kp.vin = tv.vin 
left join basic_data.tm_model tm 
on tv.model_id = tm.id 
where kp.invoice_date < '2020-08-10' and kp.is_deleted = 0 
--and tm.model_name in ('S60', 'XC60', 'S90', 'XC90', 'S60L') 
and length(tmi.member_phone) = 11
--group by rollup(1,2)
--order by 1,2
;