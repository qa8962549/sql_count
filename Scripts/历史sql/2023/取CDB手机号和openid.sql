###根据附件中的VIN码，匹配出其对应的手机号。逻辑为：NVL(沃世界绑定VIN对应手机号,CDB系统中的手机号)
-- Member ID、会员手机号、会员昵称、公众号Open ID、微信Union ID	
select 
	v.vin VIN,
	v.id MemberID,
	v.member_phone 会员手机号,
	v.MEMBER_NAME 会员昵称
		from (
		select v.VIN,m.MEMBER_PHONE,v.CREATE_TIME,m.id,m.MEMBER_NAME 
		,row_number() over(partition by v.vin order by v.create_time desc) rk
		from member.tc_member_vehicle v
		left join member.tc_member_info m on m.ID=v.MEMBER_ID 
		where v.IS_DELETED=0
		) v 
	where v.rk=1
	and LENGTH(v.member_phone)=11 and `LEFT`(v.member_phone,1)='1'
	
-- 根据各种条件匹配微信公众号openid
	SELECT DISTINCT x.VIN,
	(eco.open_id)微信公众号open_id,
	x.allunionid '微信Union ID'
	from 
		(
		SELECT 
		DISTINCT x.VIN,
		IFNULL(c.union_id,u.unionid) allunionid
		from 
			(
			select v.VIN,m.MEMBER_PHONE,v.CREATE_TIME,m.ID,m.CUST_ID,m.OLD_MEMBERID
			,row_number() over(partition by v.vin order by v.create_time desc) rk
			from member.tc_member_vehicle v
			left join member.tc_member_info m on m.ID=v.MEMBER_ID 
			where v.IS_DELETED=0
			)x 
		left join customer.tm_customer_info c on c.id=x.cust_id
		left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=x.old_memberid
		where x.rk=1
		)x
	left join volvo_wechat_live.es_car_owners eco on x.allunionid = eco.unionid 
	and eco.subscribe_status = 1 -- 状态为关注
	and eco.open_id is not null 
	and eco.open_id <> ''	
	

-- 车辆开票表回匹 潜客手机号、潜客姓名
 select a.SALES_VIN VIN
,b.CUSTOMER_TEL 潜客手机号
,b.customer_name 潜客姓名
-- ,b.PURCHASE_PHONE 下单人手机号
-- ,b.DRAWER_TEL 开票人电话
 from 
(select a.*
	from 
		(select a.SALES_VIN
		,a.VI_NO
		,row_number() over(partition by a.SALES_VIN order by a.created_at desc) rk
		from cyxdms_retail.tt_sales_order_vin a 
		where a.IS_DELETED =0
		)a 
	where a.rk=1
	)a 
left join  
	(select b.*
	from 
		(select b.so_no
		,b.CUSTOMER_TEL 
		,b.PURCHASE_PHONE 
		,b.DRAWER_TEL
		,b.customer_name
		,row_number() over(partition by b.SO_NO order by b.created_at desc) rk
		from cyxdms_retail.tt_sales_orders b
		where b.IS_DELETED =0)b 
		where b.rk=1
	)b on a.VI_NO =b.SO_NO 
	
-- Newbie易保数据表中匹配， 投保人手机号、投保人姓名
	select 
	a.vin VIN,
	SUBSTRING_INDEX(a.mobile,'"',2) 投保人手机号,
	SUBSTRING_INDEX(a.name,'"',2) 投保人姓名
	from
		(
		select
		a.vin,
		-- a.RESULT_DATA,
		row_number() over(PARTITION by a.vin order by a.create_time desc) rk,
		json_extract(json_extract(a.RESULT_DATA,'$.insuredInfo'),'$.insureownermobile') mobile,
		json_extract(json_extract(a.RESULT_DATA,'$.insuredInfo'),'$.insureownername') name
		from vehicle.car_basicinfo a
		where a.IS_DELETED = 0)a
		where a.rk=1	
			
-- 根据VIN值匹配各种手机号 (根据实际情况，需拆分使用)
select 
v.vin VIN
,c.微信公众号open_id
,v.member_phone 绑车人手机号
,b.CUSTOMER_TEL 潜客手机号
,b.PURCHASE_PHONE 下单人手机号
,b.DRAWER_TEL 开票人电话
,x1.mobile B2B手机号
,x2.mobile B2C手机号
,x3.contact_phone 售后工单手机号
,x4.mobile 保险手机号
from (
	select 
	v.vin,
	v.member_phone
		from (
		select v.VIN,m.MEMBER_PHONE,v.CREATE_TIME
		,row_number() over(partition by v.vin order by v.create_time desc) rk
		from member.tc_member_vehicle v
		left join member.tc_member_info m on m.ID=v.MEMBER_ID 
		where v.IS_DELETED=0
		) v 
	where v.rk=1
	and LENGTH(v.member_phone)=11 and `LEFT`(v.member_phone,1)='1'
	)v
left join 
	(select a.*
	from 
		(select a.SALES_VIN
		,a.VI_NO
		,row_number() over(partition by a.SALES_VIN order by a.created_at desc) rk
		from cyxdms_retail.tt_sales_order_vin a 
		where a.IS_DELETED =0
		)a 
	where a.rk=1
	)a on v.vin=a.SALES_VIN
left join 
	(select b.*
	from 
		(select b.so_no
		,b.CUSTOMER_TEL 
		,b.PURCHASE_PHONE 
		,b.DRAWER_TEL
		,row_number() over(partition by b.SO_NO order by b.created_at desc) rk
		from cyxdms_retail.tt_sales_orders b
		where b.IS_DELETED =0)b 
		where b.rk=1
	)b on a.VI_NO =b.SO_NO 
left join (
	SELECT DISTINCT x.VIN,
	(eco.open_id)微信公众号open_id
	from 
		(
		SELECT 
		DISTINCT x.VIN,
		IFNULL(c.union_id,u.unionid) allunionid
		from 
			(
			select v.VIN,m.MEMBER_PHONE,v.CREATE_TIME,m.ID,m.CUST_ID,m.OLD_MEMBERID
			,row_number() over(partition by v.vin order by v.create_time desc) rk
			from member.tc_member_vehicle v
			left join member.tc_member_info m on m.ID=v.MEMBER_ID 
			where v.IS_DELETED=0
			)x 
		left join customer.tm_customer_info c on c.id=x.cust_id
		left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=x.old_memberid
		where x.rk=1
		)x
	left join volvo_wechat_live.es_car_owners eco on x.allunionid = eco.unionid 
	and eco.subscribe_status = 1 -- 状态为关注
	and eco.open_id is not null 
	and eco.open_id <> ''
)c on c.vin=v.vin
left join 
	(
		# CDB 手机号
	select b.vin,b.mobile
	from (
		select a.vin,a.mobile,a.rk
		,row_number() over(partition by a.vin order by rk) rk2
		from (
					# 普通车主B2C
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
		) x1 on v.vin =x1.vin
left join 
	(
		# CDB 手机号
	select b.vin,b.mobile
	from (
		select a.vin,a.mobile,a.rk
		,row_number() over(partition by a.vin order by rk) rk2
		from ( 
					# 企业车主B2B
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
		)  a 
		order by 1 
	) b 
	where b.rk2=1 and LENGTH(b.mobile)=11 and `LEFT`(b.mobile,1)='1'
		) x2 on v.vin =x2.vin
left join 
	(-- 6、售后工单手机号
	select a.*
	from 
	(
		SELECT a.VIN vin
         ,a.contact_name
         ,a.contact_phone
         ,row_number() over(partition by a.vin order by a.created_at desc) rk
		FROM
         cyx_appointment.tt_appointment_maintain a)a
         where a.rk=1
         )x3 on v.vin=x3.vin
left join 
	(
	-- 保险手机号
	select 
	a.vin,
	SUBSTRING_INDEX(a.mobile,'"',2) mobile
	from
		(
		select
		a.vin,
		-- a.RESULT_DATA,
		row_number() over(PARTITION by a.vin order by a.create_time desc) rk,
		json_extract(json_extract(a.RESULT_DATA,'$.insuredInfo'),'$.insureownermobile') mobile
		from vehicle.car_basicinfo a
		where a.IS_DELETED = 0
		) a
	where a.rk = 1
	)x4 on v.vin=x4.vin

		
##################################################################切割线

##############老版本
select v.vin VIN,ifnull(v.member_phone,x.mobile) 手机号
from 
	(
	#绑车人手机号
	select v.vin,v.member_phone
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
					# 企业车主B2B
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
					# 普通车主B2C
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
a.vin,
SUBSTRING_INDEX(a.mobile,'"',2) mobile
from
(
select
a.vin,
-- a.RESULT_DATA,
row_number() over(PARTITION by a.vin order by a.create_time desc) rk,
json_extract(json_extract(a.RESULT_DATA,'$.insuredInfo'),'$.insureownermobile') mobile
from vehicle.car_basicinfo a
where a.IS_DELETED = 0
) a
where a.rk = 1