--基盘客户性别画像
	select tisd.vin,
	CASE WHEN substring(tisd.certificate_no, length(tisd.certificate_no) - 1, 1) = 'X' THEN '未知'
    	WHEN CAST(substring(tisd.certificate_no, length(tisd.certificate_no) - 1, 1) AS INTEGER) % 2 = 1 THEN '男'
   		ELSE '女' END 开票人性别,
	x.性别 绑车人性别,
	x2.性别 送修人性别
	from vehicle.tt_invoice_statistics_dms tisd 
	left join
		(
		-- 取最近一次绑车人
		select * 
		from 
			(
			select a.member_id
			,a.vin_code
			,a.bind_date
			,b.model_name 拥车车型
			,row_number()over(partition by a.vin_code order by a.bind_date desc) rk 
			,case when tmi.member_sex = '10021001' then '男' when tmi.member_sex = '10021002' then '女' else '未知' end 性别
			from volvo_cms.vehicle_bind_relation a
			left join basic_data.tm_model b on a.series_code =b.model_code
			left join "member".tc_member_info tmi on tmi.id=a.member_id
			where a.deleted = 0
			and a.is_bind=1
			and a.is_owner=1
			)x where x.rk=1
		)x on x.vin_code=tisd.vin 
	left join 
		(
		-- 进厂回修人的性别
		select *
		from 
			(
			select vin
			,case when tmi.member_sex = '10021001' then '男' when tmi.member_sex = '10021002' then '女' else '未知' end 性别
			,row_number()over(partition by vin order by ro_create_date desc) rk 
			from cyx_repair.tt_repair_order e
			left join cyx_repair.tt_balance_accounts a on a.ro_no = e.ro_no and a.owner_code = e.owner_code   -- 非反结算 
			left join "member".tc_member_info tmi on tmi.member_phone=e.deliverer_mobile
			where 1=1
			and e.ro_status = '80491003'-- 已结算工单
			and e.repair_type_code <> 'P'-- 售后
			and e.repair_type_code <> 'S'
			and e.is_deleted = 0
			and a.IS_RED = 10041002 
			)x where x.rk=1
		)x2 on x2.vin=tisd.vin 
	where certificate_no is not null 
	and length(certificate_no)=18
	and tisd.IS_DELETED =0
	and left(tisd.certificate_no,1) <> '9' -- 剔除公司开票的证件号
	
	

