select v.vin VIN,ifnull(v.member_phone,x.mobile) 手机号
from 
	(select v.vin,v.member_phone
	from (
	select v.VIN,m.MEMBER_PHONE,v.CREATE_TIME
	,row_number() over(partition by v.vin order by v.create_time desc) rk
	from member.tc_member_vehicle v
	left join member.tc_member_info m on m.ID=v.MEMBER_ID 
	where v.IS_DELETED=0
	) v where v.rk=1
	and LENGTH(v.member_phone)=11 and `LEFT`(v.member_phone,1)='1'
	)v
left join 
	(
		# CDB 手机号
	select b.vin,b.mobile
	from (
		select a.vin,a.mobile,a.rk
		,row_number() over(partition by a.vin order by rk) rk2
		from ( 
					# 企业车主
					select c.vin
					,ifnull( max(case when c.rk=1 then c.mobile else null end),max(case when c.rk=3 then c.mobile else null end) ) mobile
					,c.rk
					from(
						select c.vin
						,case when `LEFT`(c.Mobile_Phone_num,3)='+86' then MID(c.Mobile_Phone_num,4,20)
									else c.Mobile_Phone_num end mobile
						,case when c.Relationship_Type='Owns' then 1 
									when c.Relationship_Type='Contracting' then 3 
									else 4 end rk
						from customer.account_customers c 
						where c.Relationship_End_Date is null
						and c.Mobile_Phone_num is not null 
						and c.vin is not null 
						-- and c.vin<>'LVYZABMD4NP151878' 
					) c
					where LENGTH(c.mobile)=11 and left(c.mobile,1)='1'
					GROUP BY 1 order by 1 
			union 
					# 普通车主
					select d.vin
					,ifnull( ifnull( max(case when d.rk=1 then d.mobile else null end),max(case when d.rk=2 then d.mobile else null end) ),max(case when d.rk=3 then d.mobile else null end)) mobile
					,d.rk
					from(
						select d.vin
						,case when `LEFT`(d.Mobile_Phone_num,3)='+86' then MID(d.Mobile_Phone_num,4,20)
									else d.Mobile_Phone_num end mobile
						,case when d.Relationship_Type='Owns' then 1 
									when d.Relationship_Type='Drives' then 2 
									when d.Relationship_Type='Contracting' then 3 
									else 4 end rk
						from customer.contacts_customers_owns_and_drives d 
						where d.Relationship_End_Date is null 
						and d.Mobile_Phone_num is not null
						and d.vin is not null 
					) d
					where LENGTH(d.mobile)=11 and left(d.mobile,1)='1'
					GROUP BY 1 order by 1 
		)  a 
		order by 1 
	) b 
	where b.rk2=1 and LENGTH(b.mobile)=11 and `LEFT`(b.mobile,1)='1'
		) x on v.vin =x.vin

select 
x.开票年份,
count(x.开票VIN码)
from 
(
SELECT a.VIN 开票VIN码,
left(a.Relationship_Start_Date,4) 开票年份,
left(a.Relationship_Start_Date,10) 开票时间
from customer.contacts_customers_owns_and_drives a
where left(a.Relationship_Start_Date,10)<'2014-12-31'
union 
select b.VIN 开票VIN码,
left(b.Relationship_Start_Date,4) 开票年份,
left(b.Relationship_Start_Date,10) 开票时间
from customer.account_customers b
where left(b.Relationship_Start_Date,10)<'2014-12-31'
)x
group by 1
order by 1

-- 实际交车时间
select 
x.开票VIN码,
x.开票年份,
x.开票时间
from 
(
select 
x.开票VIN码,
x.开票年份,
x.开票时间,
ROW_NUMBER () over(PARTITION by x.开票VIN码 order by x.开票时间 desc ) rk
from 
	(
	SELECT a.VIN 开票VIN码,
	left(a.Delivery_Date,4) 开票年份,
	left(a.Delivery_Date,10) 开票时间,
	ROW_NUMBER () over(PARTITION by a.vin order by a.Delivery_Date desc ) rk
	from customer.contacts_customers_owns_and_drives a
	where left(a.Delivery_Date,10)<'2014-12-31'
	union 
	select b.VIN 开票VIN码,
	left(b.Delivery_Date,4) 开票年份,
	left(b.Delivery_Date,10) 开票时间,
	ROW_NUMBER () over(PARTITION by b.vin order by b.Delivery_Date desc ) rk
	from customer.account_customers b
	where left(b.Delivery_Date,10)<'2014-12-31'
	)x
where x.rk=1
)x where x.rk=1
-- and x.开票VIN码 in 
-- ('YV1DZ4753F2633597',
-- 'LVSHEFEJ77F257255',
-- 'YV1CT5958B1597468',
-- 'LVSHEFAC29F438287',
-- 'LVSHEFAC19F436563',
-- 'LVSHGFAR9EF073390',
-- 'LYVFD63A6FB011991')

select 
x.开票年份,
count(x.开票VIN码)
from 
(
SELECT a.VIN 开票VIN码,
left(a.Relationship_End_Date,4) 开票年份,
left(a.Relationship_End_Date,10) 开票时间
from customer.contacts_customers_owns_and_drives a
where left(a.Relationship_End_Date,10)<'2014-12-31'
union 
select b.VIN 开票VIN码,
left(b.Relationship_End_Date,4) 开票年份,
left(b.Relationship_End_Date,10) 开票时间
from customer.account_customers b
where left(b.Relationship_End_Date,10)<'2014-12-31'
)x
group by 1
order by 1

select 
x.开票年份,
count(x.开票VIN码)
from 
(
SELECT a.VIN 开票VIN码,
left(a.Contact_Created_Date,4) 开票年份,
left(a.Contact_Created_Date,10) 开票时间
from customer.contacts_customers_owns_and_drives a
where left(a.Contact_Created_Date,10)<'2014-12-31'
union 
select b.VIN 开票VIN码,
left(b.Created_Date,4) 开票年份,
left(b.Created_Date,10) 开票时间
from customer.account_customers b
where left(b.Created_Date,10)<'2014-12-31'
)x
group by 1
order by 1
