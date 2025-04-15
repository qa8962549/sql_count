
--浏览时长和参与度的相关系数r 相关性后面要加显著性校验，参与定义为产生实质行为 参与活动频次 频率 天数
--浏览次数和点击抽奖的相关系数r
	SELECT 
	distinct 
	a.gio_id gio_id,
	x.`参与活动频次` `参与活动频次`,
	x.`参与活动天数` `参与活动天数`,
	x.`参与活动频率` `参与活动频率`,
	ifnull(x1.`规则浏览次数`,0)`规则浏览次数`,
	ifnull(x1.`规则浏览时长`,0)`规则浏览时长`,
	ifnull(x1.`规则浏览进度`,0)`规则浏览进度`,
	ifnull(x2.`抽奖点击次数`,0)`抽奖点击次数`
	from dwd_23.dwd_23_gio_tracking a
	left join 
		(
		SELECT 
		a.gio_id ,
		count(a.date) `参与活动频次`,
		count(distinct a.date) `参与活动天数`,
		count(a.date)/count(distinct a.date) `参与活动频率`
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and date >='2024-05-15'
		and date <'2024-06-01'
		and event='Page_entry'
		and var_activity_name='2024年5月525车主节'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		and page_title in (
		'525车主节·售后惠聚',
		'525车主节',
		'525车主节·会员权益',
		'525车主节·精品好物',
		'525车主节·商城礼券',
		'525车主节·沃尔沃EX30猩朋友见面会'
		)
		group by 1
		order by 2 desc 
	)x on x.gio_id= a.gio_id
	left join 
		(SELECT 
		gio_id ,
		count(1) `规则浏览次数`,
		max(toInt32(view_duration)/1000) `规则浏览时长`,
		max(var_view_advance) `规则浏览进度`
		from dwd_23.dwd_23_gio_tracking
		where 1=1
		and date >='2024-05-15'
		and date <'2024-06-01'
		and event='Page_view'
		and page_title='525车主节·会员权益_活动规则'
		and var_activity_name='2024年5月525车主节'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		and view_duration <'300000'
		group by 1
		order by 4 
	)x1 on x1.gio_id= a.gio_id
	left join 
		(SELECT 
		 gio_id ,
		count(1) `抽奖点击次数`
			from dwd_23.dwd_23_gio_tracking
			where 1=1
			and event='Button_click'
			and date >='2024-05-15'
			and date <'2024-06-01'
			and btn_name in (
			'限定任务抽奖',
			'每日任务抽奖'
	--		'获取更多抽奖机会'
			)
		and page_title='525车主节·会员权益'
		and var_activity_name='2024年5月525车主节'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		group by 1
		order by 2 desc
		)x2 on x2.gio_id= a.gio_id
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event='Page_entry'
	and var_activity_name='2024年5月525车主节'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title in (
	'525车主节·售后惠聚',
	'525车主节',
	'525车主节·会员权益',
	'525车主节·精品好物',
	'525车主节·商城礼券',
	'525车主节·沃尔沃EX30猩朋友见面会'
	)

--525所有	页面PVUV
SELECT
page_title,
count(usr_merged_gio_id) PV,
--count(distinct a.gio_id) UV
count(distinct usr_merged_gio_id ) uv
from dwd_23.dwd_23_gio_tracking a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Page_entry'
and var_activity_name='2024年5月525车主节'
--and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
GROUP BY 1
ORDER BY 2 desc 
	

--精品叠券参与人群的特征
select
distinct
a.one_id,
a.member_id `会员ID`,
--b.coupon_name `卡券名称`,
x3.`性别`,
x3.`会员等级`,
if(length(x4.`身份`)>=2,x4.`身份`,'粉丝') `身份`,
if(x5.cust_id is not null ,'1','0') `是否价格敏感用户`,
if(xx5.cust_id is not null ,'1','0') `是否2024年4月商城下单`,
if(xxx5.cust_id is not null ,'1','0') `是否2024年商城下单`,
ifNull(x6.num,0) `近一年售后返厂次数`,
x7.t `车龄`,
x7.model_name `车型`,
x8.`参与活动天数` `参与活动天数`,
x8.`浏览活动频率` `浏览活动频率`,
x9.`APP活跃天数` `APP活跃天数`
FROM ods_coup.ods_coup_tt_coupon_detail_d a 
JOIN ods_coup.ods_coup_tt_coupon_info_d b ON a.coupon_id = b.id
left join 
	(select 
	m.id,
	case when m.member_level = 1 then '银卡'
     when m.member_level = 2 then '金卡'
     when m.member_level = 3 then '白金卡' 
     when m.member_level = 4 or m.member_level = 5 then '黑卡' end `会员等级`,
	case when m.member_sex = '10021001' then '先生' 
		when m.member_sex = '10021002' then '女士' else '未知' end `性别`
	from ods_memb.ods_memb_tc_member_info_cur m 
	where 1=1
--	and v.relative_type not in ('1','0') -- 筛选当下身份为车主亲友授权
	)x3 on x3.id::String=a.member_id ::String 
left join 
	(select 
	distinct m.distinct_id ,
	ROW_NUMBER ()over(partition by v.member_id order by v.bind_date desc) rk,
	case when v.relative_type not in ('1','0') then '亲友授权'
		else '车主' end `身份`,
	v.vin_code
	from ads_crm.ads_crm_events_member_d m 
	left join ods_vocm.ods_vocm_vehicle_bind_relation_cur v on m.memberid=v.member_id
	where 1=1
--	and v.relative_type not in ('1','0') -- 筛选当下身份为车主亲友授权
	)x4 on x4.distinct_id::String=a.one_id::String and x4.rk=1
left join 
	(select distinct
		h.cust_id cust_id
--		,b.coupon_fee/100 `优惠券抵扣金额`
		from ods_orde.ods_orde_tt_order_d a  -- 订单主表
		left join ods_orde.ods_orde_tt_order_product_d  b on a.order_code = b.order_code  -- 订单商品表
		left join (
			-- 清洗cust_id
			select m.*
			from 
				(-- 清洗cust_id
				select m.*,
				row_number() over(partition by m.cust_id order by m.create_time desc) rk
				from ods_memb.ods_memb_tc_member_info_cur m
				where m.member_status<>'60341003' and m.is_deleted=0
				and m.cust_id is not null 
				Settings allow_experimental_window_functions = 1
				) m
			where m.rk=1) h on toString(a.user_id) = toString(h.id)   -- 会员表(获取会员信息)
		where 1=1
		and b.coupon_fee/100>0 -- 使用优惠券
		and toDate(a.create_time) >= now() - INTERVAL 1 year
		and toDate(a.create_time) <now()   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and b.is_deleted <> 1
		and h.is_deleted <> 1
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = 10041002 -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		order by a.create_time
		) x5 on x5.cust_id=a.one_id 
left join 
	(
	-- 2024年4月是否下单
	select distinct
		h.cust_id cust_id
--		,b.coupon_fee/100 `优惠券抵扣金额`
		from ods_orde.ods_orde_tt_order_d a  -- 订单主表
		left join ods_orde.ods_orde_tt_order_product_d  b on a.order_code = b.order_code  -- 订单商品表
		left join (
			-- 清洗cust_id
			select m.*
			from 
				(-- 清洗cust_id
				select m.*,
				row_number() over(partition by m.cust_id order by m.create_time desc) rk
				from ods_memb.ods_memb_tc_member_info_cur m
				where m.member_status<>'60341003' and m.is_deleted=0
				and m.cust_id is not null 
				Settings allow_experimental_window_functions = 1
				) m
			where m.rk=1) h on toString(a.user_id) = toString(h.id)   -- 会员表(获取会员信息)
		where 1=1
--		and b.coupon_fee/100>0 -- 使用优惠券
		and toDate(a.create_time) >= '2024-04-01'
		and toDate(a.create_time) <'2024-05-01'   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and b.is_deleted <> 1
		and h.is_deleted <> 1
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = 10041002 -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		order by a.create_time
		) xx5 on xx5.cust_id=a.one_id 
left join 
	(
	-- 2024年是否下单
	select distinct
		h.cust_id cust_id
--		,b.coupon_fee/100 `优惠券抵扣金额`
		from ods_orde.ods_orde_tt_order_d a  -- 订单主表
		left join ods_orde.ods_orde_tt_order_product_d  b on a.order_code = b.order_code  -- 订单商品表
		left join (
			-- 清洗cust_id
			select m.*
			from 
				(-- 清洗cust_id
				select m.*,
				row_number() over(partition by m.cust_id order by m.create_time desc) rk
				from ods_memb.ods_memb_tc_member_info_cur m
				where m.member_status<>'60341003' and m.is_deleted=0
				and m.cust_id is not null 
				Settings allow_experimental_window_functions = 1
				) m
			where m.rk=1) h on toString(a.user_id) = toString(h.id)   -- 会员表(获取会员信息)
		where 1=1
--		and b.coupon_fee/100>0 -- 使用优惠券
		and toDate(a.create_time) >= '2024-01-01'
		and toDate(a.create_time) <now()   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and b.is_deleted <> 1
		and h.is_deleted <> 1
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = 10041002 -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		order by a.create_time
		) xxx5 on xxx5.cust_id=a.one_id 
left join 
(--参与活动&23年回厂车辆数
	select 
--	datediff('year',toDate(tisd.invoice_date),toDate('2023-12-12')) t,
	xx.vin_code vin_code,
--	xx.model_name,
	count(1) num
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
			 row_number() over(partition by r.vin_code order by r.bind_date desc) rk,
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
	join 
		(select *
		from ods_cyre.ods_cyre_tt_repair_order_d e 
		where 1=1
--		and year(e.RO_CREATE_DATE) ='2023' -- 2023年回过厂
		and e.RO_CREATE_DATE >=toDate(now()) - interval 1 year 
		and e.RO_CREATE_DATE <toDate(now())
		and e.RO_STATUS = '80491003'-- 已结算工单
		and e.REPAIR_TYPE_CODE <> 'P'-- 售后
		and e.REPAIR_TYPE_CODE <> 'S'
		and e.IS_DELETED = 0
		)e on xx.vin_code=e.VIN  --工单表
	where 1=1
	group by 1
	order by 2 desc ) x6 on x6.vin_code=x4.vin_code
left join 
(--车龄
	select 
	xx.vin_code vin_code,
	xx.model_name model_name,
	datediff('year',toDate(tisd.invoice_date),toDate(now())) t
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
			 row_number() over(partition by r.vin_code order by r.bind_date desc) rk,
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
	) x7 on x7.vin_code=x4.vin_code
left join 
(
		SELECT 
		a.memberid  ,
		count(a.date) `参与活动频次`,
		count(distinct a.date) `参与活动天数`,
		count(a.date)/count(distinct a.date) `浏览活动频率`
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and date >='2024-05-15'
		and date <'2024-06-01'
		and event='Page_entry'
		and var_activity_name='2024年5月525车主节'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		and page_title in (
		'525车主节·售后惠聚',
		'525车主节',
		'525车主节·会员权益',
		'525车主节·精品好物',
		'525车主节·商城礼券',
		'525车主节·沃尔沃EX30猩朋友见面会'
		)
		group by 1
		order by 2 desc 
	)x8 on toString(a.member_id) = toString(x8.memberid)
left join 
(
		SELECT 
		a.memberid ,
		count(distinct a.date) `APP活跃天数`
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and date >='2024-05-01'
		and date <'2024-06-01'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		group by 1
		order by 2 desc 
	)x9 on toString(a.member_id) = toString(x9.memberid)
where 1=1
and b.id in ('6730','6731') -- 卡券ID
and a.get_date >= '2024-05-15'
and a.get_date < '2024-06-01'
and a.is_deleted = 0

-- 近一年优惠券用户占比
select 
count(distinct h.cust_id)
--		,b.coupon_fee/100 `优惠券抵扣金额`
		from ods_orde.ods_orde_tt_order_d a  -- 订单主表
		left join ods_orde.ods_orde_tt_order_product_d  b on a.order_code = b.order_code  -- 订单商品表
		left join (
			-- 清洗cust_id
			select m.*
			from 
				(-- 清洗cust_id
				select m.*,
				row_number() over(partition by m.cust_id order by m.create_time desc) rk
				from ods_memb.ods_memb_tc_member_info_cur m
				where m.member_status<>'60341003' and m.is_deleted=0
				and m.cust_id is not null 
				Settings allow_experimental_window_functions = 1
				) m
			where m.rk=1) h on toString(a.user_id) = toString(h.id)   -- 会员表(获取会员信息)
		where 1=1
		and b.coupon_fee/100>0 -- 使用优惠券
		and toDate(a.create_time) >= '2023-06-11' 
--		- INTERVAL 1 year
		and toDate(a.create_time) <'2024-06-11'   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and b.is_deleted <> 1
		and h.is_deleted <> 1
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = 10041002 -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		

--车主节活跃的这部分人，在车主节前1个月内活跃的天数，在车主节期间活跃的天数，在车主节后半个月的活跃天数分布
		SELECT 
		a.usr_merged_gio_id ,
		x1.`前1个月内活跃的天数`,
		x2.`参与525活动天数`,
		x3.`后半个月内活跃的天数`
		from (
		-- 车主节期间活跃
			SELECT 
			distinct usr_merged_gio_id
			from dwd_23.dwd_23_gio_tracking a
			left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
			where 1=1
			and date >='2024-05-15'
			and date <'2024-06-01'
			and a.event='Page_entry'
			and a.var_activity_name='2024年5月525车主节'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
			and page_title in (
			'525车主节·售后惠聚',
			'525车主节',
			'525车主节·会员权益',
			'525车主节·精品好物',
			'525车主节·商城礼券',
			'525车主节·沃尔沃EX30猩朋友见面会') 
			) a
		left join (	
		--车主节前1个月内活跃的天数
			SELECT 
			usr_merged_gio_id  ,
			count(distinct a.date) `前1个月内活跃的天数`
			from dwd_23.dwd_23_gio_tracking a
			left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
			where 1=1
			and date >='2024-04-15'
			and date <'2024-05-15'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
			group by 1
			order by 2 desc )x1 on x1.usr_merged_gio_id=a.usr_merged_gio_id
		left join (
		-- 车主节期间活跃的天数
			SELECT 
			usr_merged_gio_id  ,
			count(distinct a.date) `参与525活动天数`
			from dwd_23.dwd_23_gio_tracking a
			left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
			where 1=1
			and date >='2024-05-15'
			and date <'2024-06-01'
			and event='Page_entry'
			and var_activity_name='2024年5月525车主节'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
			and page_title in (
			'525车主节·售后惠聚',
			'525车主节',
			'525车主节·会员权益',
			'525车主节·精品好物',
			'525车主节·商城礼券',
			'525车主节·沃尔沃EX30猩朋友见面会'
			)
			group by 1
			order by 2 desc )x2 on x2.usr_merged_gio_id=a.usr_merged_gio_id
		left join (	
		-- 车主节后半个月的活跃天数
			SELECT 
			usr_merged_gio_id ,
			count(distinct a.date) `后半个月内活跃的天数`
			from dwd_23.dwd_23_gio_tracking a
			left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
			where 1=1
			and date >='2024-06-01'
			and date <'2024-06-16'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
			group by 1
			order by 2 desc )x3 on x3.usr_merged_gio_id=a.usr_merged_gio_id
	
		
--精品叠券被邀请人特征	挽留效果领券弹窗挽留（二级弹窗UV/一级弹窗UV）
--精品叠券被邀请人特征 新用户：浏览了525活动精品或膨胀券页面，5.15~5.31期间的注册用户，并且领取了满100-50、满100-60、满100-70的券的人。
select
DISTINCT a.member_id,
if(length(x.id)>0,'是','否') `是否有试驾行为`,
if(x1.`留存` is not null ,'是','否')`是否次日留存`,
if(x2.`留存` is not null ,'是','否')`是否7日留存`
from (
	select
	distinct
	a.left_value/100 `面额`,
	a.member_id::String member_id,
	a.get_date `获得时间`,
	toDate(x.mt) mt 
	FROM ods_coup.ods_coup_tt_coupon_detail_d a 
	JOIN ods_coup.ods_coup_tt_coupon_info_d b ON a.coupon_id = b.id
	join (
		-- 浏览了525活动精品或膨胀券页面，并且在5.15~5.31期间的注册用户
		select
		DISTINCT b.id,toDate(b.member_time) mt
		from 
		(
			-- 525活动膨胀页
		    select 
			gio_id,distinct_id,
			toDateTime(left(`time`,19)) as `time`,date(date) as date
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
			and event = 'Page_entry'
			and page_title in ('525车主节·商城礼券','525车主节.商城礼券')   -- 浏览了525活动精品或膨胀券页面
			and var_activity_name = '2024年5月525车主节'
--			and LENGTH(gio_id) < 9
			and toDate(`time`) >= '2024-05-15'
			and toDate(`time`) < '2024-06-03'
		) a
		inner join
		(
			-- 清洗会员表
			select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
			from
			(
				select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
				,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
				from ods_memb.ods_memb_tc_member_info_cur m
				where  m.member_status <> '60341003'
				and m.cust_id is not null
				and m.is_deleted =0 
				Settings allow_experimental_window_functions = 1
			) m
			where m.rk=1
			and m.member_time >= '2024-05-15' and m.member_time < '2024-06-03'   -- 限制注册时间在活动期间
		) b on a.distinct_id = b.cust_id::varchar
	)x on a.member_id::String=x.id::String
	where 1=1
	and b.id in ('6729','6730','6731') -- 卡券ID
	and a.get_date >= '2024-05-15'
	and a.get_date < '2024-06-01'
	and a.is_deleted = 0
	order by a.get_date
)a
left join (-- 预约试驾
	SELECT
	distinct
	m.id::String id
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on ta.ONE_ID=m.cust_id
	WHERE 1=1
--	and ta.CREATED_AT >= '2023-01-01'
--	AND ta.CREATED_AT <'2023-12-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and m.id is not null 
	)x on x.id=a.member_id
left join (
-- 次日留存
	select 
	DISTINCT a.member_id member_id,
	case when datediff('day',a.mt,toDate(x1.date))=1 then '次日留存' else null end `留存`
	from 
	(
		select
		distinct
		a.left_value/100 `面额`,
		a.member_id::String member_id,
		a.get_date `获得时间`,
		toDate(x.mt) mt 
		FROM ods_coup.ods_coup_tt_coupon_detail_d a 
		JOIN ods_coup.ods_coup_tt_coupon_info_d b ON a.coupon_id = b.id
		join (
			-- 浏览了525活动精品或膨胀券页面，并且在5.15~5.31期间的注册用户
			select
			DISTINCT b.id,toDate(b.member_time) mt
			from 
			(
				-- 525活动膨胀页
			    select 
				gio_id,distinct_id,
				toDateTime(left(`time`,19)) as `time`,date(date) as date
				from dwd_23.dwd_23_gio_tracking a
				where 1=1
				and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
				and event = 'Page_entry'
				and page_title in ('525车主节·商城礼券','525车主节.商城礼券')   -- 浏览了525活动精品或膨胀券页面
				and var_activity_name = '2024年5月525车主节'
	--			and LENGTH(gio_id) < 9
				and toDate(`time`) >= '2024-05-15'
				and toDate(`time`) < '2024-06-03'
			) a
			inner join
			(
				-- 清洗会员表
				select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
				from
				(
					select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
					,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
					from ods_memb.ods_memb_tc_member_info_cur m
					where  m.member_status <> '60341003'
					and m.cust_id is not null
					and m.is_deleted =0 
					Settings allow_experimental_window_functions = 1
				) m
				where m.rk=1
				and m.member_time >= '2024-05-15' and m.member_time < '2024-06-01'   -- 限制注册时间在活动期间
			) b on a.distinct_id = b.cust_id::varchar
		)x on a.member_id::String=x.id::String
		where 1=1
		and b.id in ('6729','6730','6731') -- 卡券ID
		and a.get_date >= '2024-05-15'
		and a.get_date < '2024-06-01'
		and a.is_deleted = 0
		order by a.get_date)a
	left join (-- 用户活动期间活跃时间
			SELECT 
			distinct 
			memberid,
			toDate(date) date
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and date >='2024-05-15'
			and date <'2024-06-01'
			and event ='Page_entry'
		--	and length(gio_id)<9
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
			)x1 on x1.memberid=a.member_id
		)x1 on x1.member_id=a.member_id and x1.`留存` is not null 
left join (
-- 7日留存
	select 
	DISTINCT a.member_id member_id,
	case when datediff('day',a.mt,toDate(x1.date))=7 then '7日留存' else null end `留存`
	from 
	(
		select
		distinct
		a.left_value/100 `面额`,
		a.member_id::String member_id,
		a.get_date `获得时间`,
		toDate(x.mt) mt 
		FROM ods_coup.ods_coup_tt_coupon_detail_d a 
		JOIN ods_coup.ods_coup_tt_coupon_info_d b ON a.coupon_id = b.id
		join (
			-- 浏览了525活动精品或膨胀券页面，并且在5.15~5.31期间的注册用户
			select
			DISTINCT b.id,toDate(b.member_time) mt
			from 
			(
				-- 525活动膨胀页
			    select 
				gio_id,distinct_id,
				toDateTime(left(`time`,19)) as `time`,date(date) as date
				from dwd_23.dwd_23_gio_tracking a
				where 1=1
				and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
				and event = 'Page_entry'
				and page_title in ('525车主节·商城礼券','525车主节.商城礼券')   -- 浏览了525活动精品或膨胀券页面
				and var_activity_name = '2024年5月525车主节'
	--			and LENGTH(gio_id) < 9
				and toDate(`time`) >= '2024-05-15'
				and toDate(`time`) < '2024-06-03'
			) a
			inner join
			(
				-- 清洗会员表
				select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
				from
				(
					select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
					,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
					from ods_memb.ods_memb_tc_member_info_cur m
					where  m.member_status <> '60341003'
					and m.cust_id is not null
					and m.is_deleted =0 
					Settings allow_experimental_window_functions = 1
				) m
				where m.rk=1
				and m.member_time >= '2024-05-15' and m.member_time < '2024-06-03'   -- 限制注册时间在活动期间
			) b on a.distinct_id = b.cust_id::varchar
		)x on a.member_id::String=x.id::String
		where 1=1
		and b.id in ('6729','6730','6731') -- 卡券ID
		and a.get_date >= '2024-05-15'
		and a.get_date < '2024-06-01'
		and a.is_deleted = 0
		order by a.get_date)a
	left join (-- 用户活动期间活跃时间
			SELECT 
			distinct 
			memberid,
			toDate(date) date
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and date >='2024-05-15'
			and date <'2024-06-01'
			and event ='Page_entry'
		--	and length(gio_id)<9
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
			)x1 on x1.memberid=a.member_id
		)x2 on x2.member_id=a.member_id and x2.`留存` is not null
			
-- 用户ip
SELECT 
distinct 
a.memberid,
a.$ip ip,
a.`$device_model` ,
x.memberid,
x.`$device_model`,
x.ip
from dwd_23.dwd_23_gio_tracking a
join 
(-- 点击邀请按钮的用户
			SELECT 
			distinct 
			memberid,
			$ip ip,
			`$device_model`
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and date >='2024-05-15'
			and date <'2024-06-01'
			and event ='Button_click'
			and page_title in ('525车主节.商城礼券','525车主节·商城礼券_100-50优惠券弹窗')
			and btn_name in ('邀请膨胀','立即邀请')
		--	and length(gio_id)<9
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
			)x 
			on x.ip=a.$ip 
--			and x.`$device_model`=a.`$device_model`
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event ='Page_entry'
--	and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
and memberid in ('8439714',
'8439717',
'8439721',
'8439725',
'8439730',
'8439732',
'8439770',
'8439777',
'8439782',
'8439789',
'8439792',
'8439796',
'8439793',
'8439802',
'8439803',
'8439808',
'8439821',
'8439828',
'8439820',
'8439848',
'8439849',
'8439864',
'8439772',
'8439879',
'8439938',
'8439942',
'8439977',
'8440042',
'8440073',
'8440074',
'8440088',
'8440103',
'8440149',
'8440211',
'8440217',
'8440316',
'8440339',
'8440353',
'8440398',
'8440425',
'8440418',
'8440441',
'8440490',
'8440520',
'8440558',
'8440569',
'8440574',
'8440610',
'8440627',
'8440655',
'8440680',
'8440689',
'8440685',
'8440703',
'8440720',
'8440817',
'8440938',
'8440942',
'8440961',
'8439906',
'8440969',
'8441006',
'8441040',
'8441062',
'8441089',
'8441115',
'8441116',
'8441122',
'8441123',
'8441217',
'8441344',
'8441329',
'8441372',
'8441465',
'8441520',
'8441586',
'8441627',
'8441636',
'8441739',
'8441748',
'8441808',
'8441824',
'8441837',
'8441946',
'8441950',
'8441970',
'8441979',
'8442219',
'8442262',
'8442277',
'8442317',
'8442334',
'8442358',
'8442360',
'8442361',
'8442365',
'8442405',
'8442416',
'8442428',
'8442438',
'8442458',
'8442518',
'8442793',
'8442796',
'8442797',
'8442855',
'8442868',
'8442906',
'8442911',
'8442947',
'8442953',
'8442955',
'8442956',
'8443025',
'8443557',
'8443895',
'8444008',
'8444060',
'8444095',
'8444360',
'8444888',
'8445108',
'8445464',
'8445571',
'8445737',
'8445853',
'8446156',
'8446358',
'8442866',
'8446801',
'8446908',
'8446939',
'8446952',
'8447013',
'8447143',
'8447178',
'8447194',
'8447284',
'8447296',
'8447323',
'8447329',
'8447381',
'8447798',
'8446505',
'8448442',
'8447396',
'8448539',
'8448661',
'8448731',
'8449517',
'8449767',
'8446968',
'8450956',
'8442268',
'8447175',
'8451232',
'8451271',
'8451427',
'8451430',
'8451462',
'8451531',
'8451728',
'8451742',
'8448135',
'8451875',
'8451990',
'8452034',
'8452269',
'8452443',
'8452830',
'8453034',
'8453263',
'8453319',
'8451985',
'8454140',
'8439768',
'8455906',
'8457577',
'8458271',
'8447357',
'8458889',
'8458892',
'8458928',
'8458949',
'8459431',
'8461082',
'8440939',
'8462115',
'8458646',
'8462157',
'8462831',
'8462928',
'8462975',
'8458251',
'8463167',
'8463665',
'8454684',
'8464028',
'8464148',
'8463953',
'8464584',
'8464672',
'8464687',
'8452202',
'8465233',
'8465268',
'8451769',
'8465510',
'8465728',
'8465841',
'8466120',
'8466276',
'8466877',
'8467029',
'8467064',
'8466904',
'8467092',
'8467104',
'8467510',
'8467594',
'8461480',
'8467706',
'8467899',
'8468158',
'8450986',
'8457519',
'8446597',
'8451456',
'8464022',
'8468767',
'8468765',
'8456123',
'8468976',
'8469003',
'8469056',
'8469481',
'8468904',
'8469710',
'8469915',
'8454727',
'8470525',
'8470578',
'8470785',
'8468505',
'8465660',
'8455050',
'8471133',
'8471535',
'8471599',
'8457889',
'8471983',
'8471482',
'8465406',
'8472170',
'8458051',
'8442059',
'8472373',
'8472471',
'8472704',
'8464923',
'8472521',
'8464760',
'8461421',
'8473960',
'8446532',
'8472389',
'8474101',
'8470679',
'8472911',
'8474875',
'8446788',
'8474023',
'8475955',
'8455424',
'8474933',
'8476318',
'8471294',
'8470901',
'8476347',
'8473667',
'8476377',
'8476385',
'8457314',
'8476415',
'8476452',
'8476541',
'8439819',
'8476594',
'8476755',
'8476798',
'8476946',
'8440414',
'8476972',
'8477019',
'8477036',
'8477248',
'8477376',
'8458808',
'8477454',
'8477529',
'8477538',
'8477845',
'8477945',
'8478709',
'8478732',
'8478820',
'8479103',
'8469112',
'8463736',
'8447259',
'8479632',
'8479716',
'8475071',
'8445715',
'8462929',
'8479946',
'8478340',
'8451587',
'8466111',
'8480091',
'8465009',
'8480147',
'8480387',
'8480388',
'8480525',
'8479895',
'8477684',
'8468230',
'8467917',
'8481895',
'8482020',
'8468914',
'8482325',
'8479049',
'8482342',
'8481928',
'8482876',
'8482904',
'8447139',
'8468601',
'8466307',
'8483382',
'8483483',
'8483525',
'8483592',
'8483595',
'8444209',
'8483197',
'8456825',
'8482911',
'8444673',
'8484156',
'8472978',
'8483879',
'8464277',
'8474014',
'8484340',
'8484364',
'8484663',
'8478994',
'8484751',
'8484778',
'8484905',
'8485121',
'8481943',
'8485160',
'8485235',
'8485272',
'8481231',
'8485364',
'8482946',
'8473829',
'8483622',
'8474406',
'8485455',
'8484706',
'8485622',
'8485669',
'8451122',
'8485599',
'8486351',
'8484437',
'8486535',
'8482736',
'8466950',
'8486959',
'8480830',
'8487130',
'8487196',
'8484848',
'8483152',
'8487344',
'8487062',
'8487358',
'8472277',
'8481764',
'8483788',
'8487515',
'8471494',
'8480895',
'8488102',
'8466634',
'8485677',
'8489128',
'8489177',
'8489429',
'8489647',
'8489837',
'8470301',
'8489992',
'8479002',
'8479135',
'8484712',
'8474538',
'8490862',
'8439936',
'8473527',
'8453642',
'8491336',
'8490818',
'8490824',
'8461823',
'8466489',
'8492198',
'8468015',
'8492900',
'8492924',
'8442486',
'8480849',
'8492954',
'8492965',
'8446771',
'8490344',
'8493095',
'8493099',
'8493160',
'8493188',
'8493204')

		
--页面停留时长 
select 
page_title,
avg(x.`页面浏览时长`),
avg(x.var_view_advance)
from 
(SELECT 
gio_id ,
page_title,
toInt32(view_duration)/1000 `页面浏览时长`,
var_view_advance
from dwd_23.dwd_23_gio_tracking a
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Page_view'
and var_activity_name='2024年5月525车主节'
--and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
--and page_title ='525车主节·会员权益'
and view_duration <'300000'
)x
group by 1 
order by 1 

--每天页面跳失率（之访问了主页后离开）
SELECT 
a.date,
a.page_title,
count(distinct a.gio_id) view_UV,
count(distinct x.gio_id) btn_UV,
1-count(distinct x.gio_id)/count(distinct a.gio_id) `跳失率`
from 
	(
-- 浏览用户	
	select 
	distinct gio_id,
	date,
	page_title,
	toDateTime(left(time,19)) t
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event='Page_entry'
	and var_activity_name='2024年5月525车主节'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title in(
	'525车主节·售后惠聚',
	'525车主节',
	'525车主节·会员权益',
	'525车主节·精品好物',
	'525车主节·商城礼券',
	'525车主节·沃尔沃EX30猩朋友见面会')
)a 
left join 
	(
-- 筛选出浏览后5分钟内有点击行为的用户
	select 
	distinct a.gio_id,
	date,
	page_title
	from dwd_23.dwd_23_gio_tracking a
	join 
		(SELECT 
		distinct gio_id,
		page_title,
		date,
		toDateTime(left(time,19)) t
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and date >='2024-05-15'
		and date <'2024-06-01'
		and event ='Button_click'
		and var_activity_name='2024年5月525车主节'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		and page_title in(
		'525车主节·售后惠聚',
		'525车主节',
		'525车主节·会员权益',
		'525车主节·精品好物',
		'525车主节·商城礼券',
		'525车主节·沃尔沃EX30猩朋友见面会')
		)x on x.gio_id=a.gio_id and x.date=a.date and x.page_title=a.page_title
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event='Page_entry'
	and var_activity_name='2024年5月525车主节'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title in(
	'525车主节·售后惠聚',
	'525车主节',
	'525车主节·会员权益',
	'525车主节·精品好物',
	'525车主节·商城礼券',
	'525车主节·沃尔沃EX30猩朋友见面会')
	and date_diff('minute',toDateTime(left(a.time,19)),x.t)<5 -- 浏览和点击在5分钟以内
)x on x.gio_id=a.gio_id and x.date=a.date and x.page_title=a.page_title
group by 1,2
order by 1,2

--私域跳失率
SELECT 
count(distinct a.gio_id) view_UV,
count(distinct x.gio_id) btn_UV,
1-count(distinct x.gio_id)/count(distinct a.gio_id) `跳失率`
from 
	(
-- 浏览用户	
	select 
	distinct gio_id,
	date,
	page_title,
	toDateTime(left(time,19)) t
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event='Page_entry'
--	and var_activity_name='2024年5月525车主节'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
--	and page_title ='525车主节·会员权益'
)a 
left join 
	(
-- 筛选出浏览后5分钟内有点击行为的用户
	select 
	distinct a.gio_id,
	date,
	page_title
	from dwd_23.dwd_23_gio_tracking a
	join 
		(SELECT 
		distinct gio_id,
		page_title,
		date,
		toDateTime(left(time,19)) t
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and date >='2024-05-15'
		and date <'2024-06-01'
		and event ='Button_click'
--		and var_activity_name='2024年5月525车主节'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on x.gio_id=a.gio_id and x.date=a.date and x.page_title=a.page_title
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event='Page_entry'
--	and var_activity_name='2024年5月525车主节'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and date_diff('minute',toDateTime(left(a.time,19)),x.t)<5 -- 浏览和点击在5分钟以内
)x on x.gio_id=a.gio_id and x.date=a.date and x.page_title=a.page_title

--所有按钮 PVUV
SELECT 
page_title,
btn_name ,
count(gio_id) pv,
count(distinct gio_id) uv 
from dwd_23.dwd_23_gio_tracking a
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event ='Button_click'
and var_activity_name='2024年5月525车主节'
--and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
--and page_title ='525车主节·会员权益'
group by 1,2
order by 1 ,3 desc 

SELECT 
count(gio_id) pv,
count(distinct gio_id) uv 
from dwd_23.dwd_23_gio_tracking a
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event ='Button_click'
and var_activity_name='2024年5月525车主节'
--and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
and page_title ='525车主节·会员权益'
and btn_name ='瓜分V值'

--会员抽奖	任务弹窗-任务转化率（任务完成UV/弹窗UV） 人+任务完成UV/弹窗PV。然后看一下点击去完成后，该任务的完成率，以及点击到实际完成的时间差
	SELECT 
	content_title ,
	count(gio_id ) pv ,
	count(distinct gio_id ) uv
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event ='Button_click'
	and var_activity_name='2024年5月525车主节'
	--and length(gio_id)<9
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title like '%抽奖机会弹窗%'
	group by 1
	order by 2 desc 
	

--抽奖任务效果（任务完成UV/参加抽奖UV） 这里看两个点，App签到任务是否帮用户养成活跃习惯，浏览指定页面10s，用户的实际浏览时间，是否有转化


-- 每日任务 累计完成任务
select 
--x.date,
--x.num as "累计完成次数",
count(distinct x.member_id) as "累计完成人数"
--COUNT(distinct case when x.is_vehicle = '1' then x.member_id else null end) "车主人数",
--COUNT(distinct case when x.is_vehicle = '0' then x.member_id else null end) "粉丝人数"
from 
	(
	-- 每位用户每个任务累计完成任务次数
	select 
	date(tr.date_create) as "date",
	tr.member_id,
	m.is_vehicle ,
	--tr.task_id,
	count(tr.id) num 
	from mms.task_record tr 
	inner  join "member".tc_member_info m  on m.id =tr.member_id 
	where m.member_status <> '60341003'
	and m.is_deleted =0 
	--and tr.member_id='3021076'
	--and tr.member_id ='5763985' 
	--and tr.member_id in ('6680132' ,'7320960','4806564')
	and tr.date_create >='2024-05-15'
	and tr.date_create <'2024-06-03'
	and tr.task_id >='51' 
	and tr.task_id <='79' 
	group by 1,2,3--,4
	--,tr.task_id
	--,date(tr.date_create)
	order by 1,2,3--,4
	--,tr.task_id
	--,date(tr.date_create) desc
	)x
--group by num
--order by  num

	-- 限定任务 累计完成任务
select 
--x.num as "累计完成次数",
count(distinct x.member_id) as "累计完成人数"
--COUNT(distinct case when x.is_vehicle = '1' then x.member_id else null end) "车主人数",
--COUNT(distinct case when x.is_vehicle = '0' then x.member_id else null end) "粉丝人数"
from 
	(
	-- 每位用户每个任务累计完成任务次数
	select 
	date(tr.date_create) as "date",
	tr.member_id,
	m.is_vehicle ,
	--tr.task_id,
	count(tr.id) num 
	from mms.task_record tr 
	inner join "member".tc_member_info m  on m.id =tr.member_id 
	where m.member_status <> '60341003'
	and m.is_deleted =0 
	--and tr.member_id='3021076'
	--and tr.member_id ='5763985' 
	--and tr.member_id in ('6680132' ,'7320960','4806564')
	and tr.date_create >='2024-05-15'
	and tr.date_create <'2024-06-01'
	and tr.task_id >='44' 
	and tr.task_id <='49' 
	group by 1,2,3--,4
	--,tr.task_id
	--,date(tr.date_create)
	order by 1,2,3--,4
	--,tr.task_id
	--,date(tr.date_create) desc
	)x
--group by num 
--order by num
	

--每日任务
select 
a.memberid,
--min(case when tr.task_id ='51' and a.`content_title`='App签到' then datediff('second',a.time,toDateTime(tr.date_update)) else null end) "App签到完成人数",
--min(case when tr.task_id ='52' and a.`content_title`='益起走捐步' then datediff('second',a.time,toDateTime(tr.date_update)) else null end) "益起走捐步完成时间",
--min(case when tr.task_id ='53' and a.`content_title`='分享525车主节' then datediff('second',a.time,toDateTime(tr.date_update)) else null end)"分享活动完成时间",
min(case when tr.task_id >=54 and tr.task_id <=79  and a.`content_title`='浏览指定页面10秒' then datediff('second',a.time,toDateTime(tr.date_update)) else null end) "浏览指定页面10秒完成时间"
from 
(
select 
 l.distinct_id as "distinct_id"
 ,l.memberid
 ,toDate(l.`time`) as `date`
 ,l.content_title as `content_title`
 ,l.btn_name as `btn_name`
 ,toDateTime(left(time,19)) time 
from dwd_23.dwd_23_gio_tracking  l
where 1=1
and l.event='Button_click'
and length(l.distinct_id)<9 
and toDate(l.`time`) >= '2024-05-15'
and toDate(l.`time`) <  '2024-06-01'
and l.page_title='525车主节·会员权益_获取更多抽奖机会弹窗'
and l.var_activity_name='2024年5月525车主节'
and l.btn_name='去完成'
and l.content_title in('App签到','益起走捐步','分享525车主节','浏览指定页面10秒')
)a
inner join ods_mms.ods_mms_task_record_d tr on tr.member_id =a.memberid::varchar and a.`date`=date(tr.date_create)
where 1=1
and tr.date_update >='2024-05-15'
and tr.date_update <'2024-06-01'
and tr.deleted ='0'
and tr.task_id >='51' 
and tr.task_id <='79' 
and a.time<=toDateTime(tr.date_update) -- 点击按钮时间小于任务完成时间
group by 1




--限时任务
select 
--date(tr.date_create) as "date",
count(distinct case when tr.task_id ='44' and a.`content_title`='邀请好友试驾' then a.distinct_id else null end) "邀请好友试驾完成人数",
count(distinct case when tr.task_id ='45' and a.`content_title`='提交预约试驾' then a.distinct_id else null end) "提交预约试驾完成人数",
count(distinct case when tr.task_id ='46' and a.`content_title`='前往商城下单'  then a.distinct_id else null end) "前往商城下单完成人数",
count(distinct case when tr.task_id ='47' and a.`content_title`='提交养修预约'  then a.distinct_id else null end) "提交养修预约完成人数",
count(distinct case when tr.task_id ='48' and a.`content_title`='首次绑定爱车'  then a.distinct_id else null end) "首次绑定爱车完成人数",
count(distinct case when tr.task_id ='49' and a.`content_title`='完善个人信息'  then a.distinct_id else null end) "完善个人信息完成人数"
--count(distinct a.distinct_id) as "活动浏览总UV",
--a.distinct_id,b.id,b.is_vehicle ,tr.task_id 
from 
(
select 
 l.distinct_id as "distinct_id",toDate(l.`time`) as `date`,l.content_title as `content_title`,l.btn_name as `btn_name`
from dwd_23.dwd_23_gio_tracking  l
where 1=1
and l.event='Button_click'
and length(l.distinct_id)<9 
and toDate(l.`time`) >= '2024-05-15'
and toDate(l.`time`) <  '2024-06-01'
and l.page_title='525车主节·会员权益_获取更多抽奖机会弹窗'
and l.var_activity_name='2024年5月525车主节'
and l.btn_name='去完成'
and l.content_title in('提交养修预约','完善个人信息','邀请好友试驾','提交预约试驾','前往商城下单','首次绑定爱车')
)a
inner join 
(
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from
	(
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
		,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
	) m
	where m.rk=1
)b on a.distinct_id=b.cust_id::varchar
inner join ods_mms.ods_mms_task_record_d tr on tr.member_id =b.id::varchar
and a.`date`=date(tr.date_create)
where 1=1
and tr.date_create >='2024-05-15'
and tr.date_create <'2024-06-01'
--and tr.deleted ='0'
and tr.task_id >='44' 
and tr.task_id <='49' 
--group by date(tr.date_create) 
--order by date(tr.date_create) 

--限时任务完成时间
SELECT 
avg(x.`邀请好友试驾`),
avg(x.`提交预约试驾`),
avg(x.`前往商城下单`),
avg(x.`提交养修预约`),
avg(x.`首次绑定爱车`),
avg(x.`完善个人信息`)
from 
(
select 
a.memberid,
min(case when tr.task_id ='44' and a.`content_title`='邀请好友试驾' then datediff('second',a.time,toDateTime(tr.date_update)) else null end) "邀请好友试驾",
min(case when tr.task_id ='45' and a.`content_title`='提交预约试驾' then datediff('second',a.time,toDateTime(tr.date_update)) else null end) "提交预约试驾",
min(case when tr.task_id ='46' and a.`content_title`='前往商城下单' then datediff('second',a.time,toDateTime(tr.date_update)) else null end)"前往商城下单",
min(case when tr.task_id ='47' and a.`content_title`='提交养修预约' then datediff('second',a.time,toDateTime(tr.date_update)) else null end) "提交养修预约",
min(case when tr.task_id ='48' and a.`content_title`='首次绑定爱车' then datediff('second',a.time,toDateTime(tr.date_update)) else null end) "首次绑定爱车",
min(case when tr.task_id ='49' and a.`content_title`='完善个人信息' then datediff('second',a.time,toDateTime(tr.date_update)) else null end) "完善个人信息"
from 
(
select 
 l.distinct_id as "distinct_id"
 ,l.memberid
 ,toDate(l.`time`) as `date`
 ,l.content_title as `content_title`
 ,l.btn_name as `btn_name`
 ,toDateTime(left(time,19)) time 
from dwd_23.dwd_23_gio_tracking  l
where 1=1
and l.event='Button_click'
and length(l.distinct_id)<9 
and toDate(l.`time`) >= '2024-05-15'
and toDate(l.`time`) <  '2024-06-01'
and l.page_title='525车主节·会员权益_获取更多抽奖机会弹窗'
and l.var_activity_name='2024年5月525车主节'
and l.btn_name='去完成'
and l.content_title in('提交养修预约','完善个人信息','邀请好友试驾','提交预约试驾','前往商城下单','首次绑定爱车')
)a
inner join ods_mms.ods_mms_task_record_d tr on tr.member_id =a.memberid::varchar and a.`date`=date(tr.date_create)
where 1=1
and tr.date_update >='2024-05-15'
and tr.date_update <'2024-06-01'
and tr.deleted ='0'
and tr.task_id >='44' 
and tr.task_id <='49'  
and a.time<toDateTime(tr.date_update) -- 点击按钮时间小于任务完成时间
group by 1
)x


--会员抽奖	抽奖任务效果（任务完成UV/参加抽奖UV）

--瓜分V值	参与人数
select 
count(distinct x.member_id)
from 
	(
	select 
	tmdva.member_id ,
	--tmi.member_name 会员昵称,
	case tmi.is_vehicle when 1 then '是' when 0 then '否' end 是否车主,
	t.车型,
	date_part('year',curdate()) -date_part('year',tisd.invoice_date) 车龄,
	--datediff(year,curdate(),tisd.invoice_date), -- 绑车时间三年内
	--tisd.invoice_date,
	case tmi.level_id when 1 then '银卡' when 2 then '金卡' when 3 then '白金卡' when 4 then '黑卡' end 会员等级,
	--tmi.member_phone 沃世界手机号,
	tmi.create_time 注册时间,
	tmdva.create_time 参与瓜分时间
	FROM volvo_online_activity.tm_member_day_vvalue_activity tmdva 
	left join "member".tc_member_info tmi on tmi.id =tmdva.member_id and tmi.is_deleted=0
	left join
		( 	
		--# 车系
		 select v.member_id,v.vin_code,ifnull(m.MODEL_NAME,v.model_name)车型
		 from (
		 select v.MEMBER_ID,v.series_code,m.model_name,v.vin_code
		 ,row_number() over(PARTITION by v.MEMBER_ID order by v.bind_date desc) rk
		 from volvo_cms.vehicle_bind_relation v 
		 left join basic_data.tm_model m on v.series_code=m.MODEL_CODE
		 where v.DELETED=0 
		 ) v 
		 left join vehicle.tm_vehicle t on v.vin_code=t.VIN
		 left join basic_data.tm_model m on t.MODEL_ID=m.ID
		 where v.rk=1
	) t on tmi.id=t.member_id
	left join vehicle.tt_invoice_statistics_dms tisd on t.vin_code=tisd.vin and tisd.IS_DELETED =0  -- 与发票表关联
	where 1=1
	and (code = 'activity525-2024') 
	and tmdva.create_time>='2024-05-15'
	and tmdva.create_time<'2024-05-26'
	AND (tmdva.is_deleted = 0) )x 

--瓜分V值	实际裂变效果：拉新（剔除同一IP,同一设备）
--瓜分V值	实际裂变效果：激活（剔除同一IP,同一设备）
	
-- 不同页面每日PVUV
SELECT 
date,
page_title ,
count(a.gio_id) PV,
count(distinct a.gio_id) UV,
avg(toInt32(view_duration)/1000) `页面浏览时长`,
avg(var_view_advance) `平均浏览进度`
from dwd_23.dwd_23_gio_tracking a
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Page_view'
and var_activity_name='2024年5月525车主节'
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
and page_title in (
'525车主节·售后惠聚',
'525车主节',
'525车主节·会员权益',
'525车主节·精品好物',
'525车主节·商城礼券',
'525车主节·沃尔沃EX30猩朋友见面会'
)
group by 1,2
order by 1,2

	
--私域 pvuv
SELECT 
count(a.gio_id) PV,
count(distinct a.gio_id) UV
from dwd_23.dwd_23_gio_tracking a
where 1=1
and event='Page_entry'
and date >='2024-05-15'
and date <'2024-06-01'
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))

-- 私域页面浏览
select avg(x.`页面浏览时长`),
avg(x.var_view_advance)
from 
(
SELECT 
gio_id ,
toInt32(view_duration)/1000 `页面浏览时长`,
var_view_advance
from dwd_23.dwd_23_gio_tracking a
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Page_view'
--and var_activity_name='2024年5月525车主节'
--and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
--and page_title ='525车主节·售后惠聚'
and view_duration is not null 
and var_view_advance is not null 
and var_view_advance>'0'
and var_view_advance<'100'
and view_duration>'0'
and view_duration <'300000'
)x

--私域	每天页面跳失率（之访问了主页后离开）
SELECT 
--a.date,
count(distinct a.gio_id) view_UV,
count(distinct x.gio_id) btn_UV,
1-count(distinct x.gio_id)/count(distinct a.gio_id) out
from dwd_23.dwd_23_gio_tracking a
left join 
	(SELECT 
	distinct gio_id,date,toDateTime(left(time,19)) t
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event ='Button_click'
--	and var_activity_name='2024年5月525车主节'
	--and length(gio_id)<9
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
--	and page_title ='525车主节·会员权益'
)x on x.gio_id=a.gio_id and x.date=a.date
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Page_entry'
--and var_activity_name='2024年5月525车主节'
--and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
--and page_title ='525车主节·会员权益'
and date_diff('minute',toDateTime(left(a.time,19)),x.t)<5 -- 浏览和点击在十分钟以内


--整体活动 PV UV
SELECT 
count(a.gio_id) PV,
count(distinct a.gio_id) UV
from dwd_23.dwd_23_gio_tracking a
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Page_entry'
and var_activity_name='2024年5月525车主节'
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
and page_title in (
'525车主节·售后惠聚',
'525车主节',
'525车主节·会员权益',
'525车主节·精品好物',
'525车主节·商城礼券',
'525车主节·沃尔沃EX30猩朋友见面会'
)

--整体活动	页面停留时长
--整体活动	页面浏览进度率（百分比）
select avg(x.`页面浏览时长`),
avg(x.var_view_advance)
from 
(
SELECT 
gio_id ,
toInt32(view_duration)/1000 `页面浏览时长`,
var_view_advance
from dwd_23.dwd_23_gio_tracking a
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Page_view'
and var_activity_name='2024年5月525车主节'
--and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
and page_title in (
'525车主节·售后惠聚',
'525车主节',
'525车主节·会员权益',
'525车主节·精品好物',
'525车主节·商城礼券',
'525车主节·沃尔沃EX30猩朋友见面会'
)
and view_duration <'300000'
)x

----整体活动	页面跳失率（之访问了主页后离开）
SELECT 
--a.date,
count(distinct a.gio_id) view_UV,
count(distinct x.gio_id) btn_UV,
1-count(distinct x.gio_id)/count(distinct a.gio_id) out
from dwd_23.dwd_23_gio_tracking a
left join 
	(SELECT 
	distinct gio_id,date,toDateTime(left(time,19)) t
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event ='Button_click'
	and var_activity_name='2024年5月525车主节'
	--and length(gio_id)<9
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title in (
'525车主节·售后惠聚',
'525车主节',
'525车主节·会员权益',
'525车主节·精品好物',
'525车主节·商城礼券',
'525车主节·沃尔沃EX30猩朋友见面会'
)
)x on x.gio_id=a.gio_id and x.date=a.date
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Page_entry'
and var_activity_name='2024年5月525车主节'
--and length(gio_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
and page_title in (
'525车主节·售后惠聚',
'525车主节',
'525车主节·会员权益',
'525车主节·精品好物',
'525车主节·商城礼券',
'525车主节·沃尔沃EX30猩朋友见面会'
)
and date_diff('minute',toDateTime(left(a.time,19)),x.t)<5 -- 浏览和点击在十分钟以内
--group by 1
--order by 1 




--订阅秒杀转化漏斗：浏览——点击——进入——订单
	SELECT '浏览',
	count(distinct gio_id)
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and (date ='2024-05-15' or date='2024-05-25')
--	and date <'2024-06-01'
	and event ='Page_entry'
	and var_activity_name='2024年5月525车主节'
	--and length(gio_id)<9
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title ='525车主节·售后惠聚'
	union all 
	SELECT 
	'点击秒杀',
	count(distinct gio_id)
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and (date ='2024-05-15' or date='2024-05-25')
	and event ='Button_click'
	and var_activity_name='2024年5月525车主节'
	--and length(gio_id)<9
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title ='525车主节·售后惠聚'
	AND var_subtitle_name='限时秒杀 畅享纯净呼吸'
	AND btn_name='立即抢购'

-- 秒杀时间前后3分钟进入秒杀页面的用户 带来的订单量
with x as (
	SELECT 
	distinct 
	memberid 
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and time >='2024-05-15 12:57:00'
	and time <='2024-05-15 13:03:00'
	and event ='Page_entry'
	and var_activity_name='2024年5月525车主节'
	--and length(gio_id)<9
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title ='525车主节·售后惠聚'
	union all
	SELECT 
	distinct memberid
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and time >='2024-05-25 12:57:00'
	and time <='2024-05-25 13:03:00'
	and event ='Page_entry'
	and var_activity_name='2024年5月525车主节'
	--and length(gio_id)<9
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title ='525车主节·售后惠聚'
	)
select count(distinct x1.`订单编号`)
from x
	join (select 
		to2.order_code `订单编号`
		,top2.product_id `商城兑换id`
		,to2.create_time `下单时间`
		,top2.promotion_id `促销id`
		,tc.CODE_EN_DESC `订单来源`
		,top2.sku_id sku_id
		,top2.spu_id spu_id
		,top2.spu_name `兑换商品名称`
		,is2.coupon_id  coupon_id
		,top2.sku_num `兑换数量`
		,top2.sku_real_price/100 `商品价格（元）`
		,top2.sku_price/100 `折扣价`
		,floor(top2.sku_price/top2.sku_real_price,2)*10 `折扣率`
		,top2.sku_real_price/100-top2.sku_price/100 `优惠金额_元`
		,top2.fee/100 `订单金额（元）`
		,top2.pay_fee/100 `现金支付金额`
		,top2.point_amount `支付V值`
		,top2.point_fee/100 `V值抵扣金额`
		,top2.coupon_fee/100 `优惠券抵扣金额`
		,to2.user_id `会员id`
		,tmi.is_vehicle `会员身份`
	from ods_orde.ods_orde_tt_order_d to2
	left join ods_orde.ods_orde_tt_order_product_d top2 on top2.order_code =to2.order_code and top2.is_deleted =0
	left join ods_memb.ods_memb_tc_member_info_cur tmi on toString(tmi.id)=to2.user_id and tmi.is_deleted =0
	left join ods_good.ods_good_item_sku_d is2 on is2.id =top2.sku_id and tmi.is_deleted =0
	left join ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =to2.order_source and tc.IS_DELETED ='N'
	where 1=1
	--and date(to2.create_time) in ('2024-05-15','2024-05-30')
	and (date(to2.create_time) = '2024-05-15' or  date(to2.create_time) ='2024-05-30')
	and to2.is_deleted = 0  -- 剔除逻辑删除订单
	and to2.type = 31011003  -- 筛选沃世界商城订单
	and to2.separate_status = '10041002' -- 选择拆单状态否
	and to2.status NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (to2.close_reason NOT IN (51091001,51091002) OR to2.close_reason IS NULL ) -- 去除超时未支付和取消订单
	order by to2.create_time desc
)x1 on x1.`会员id`=x.memberid

		
	
--对整体活跃的贡献	单位权重曲线评价活动引流效果
--对整体活跃的贡献	活动PVUV和私域PVUV对比
select 
app.date,
app.uv,
act.uv,
concat(toString(round(act.uv/app.uv,3)*100),'%') rat
from (--  ods_gio_event_d
	SELECT 
	toDate(client_time) date,
	count(distinct usr_merged_gio_id) uv
	from ods_gio.ods_gio_event_d a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where 1=1
	and event_time >='2023-05-01'
	and client_time >='2023-05-01'
	and client_time <'2024-06-11'
	and (((`$platform` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel = 'App')or (`$platform` ='MinP' or var_channel ='Mini' ))
	--and length(user)<9
	group by 1 
	order by 1
	)app
left join (
	SELECT 
	toDate(date) date,
--	count(gio_id ) pv ,
	count(distinct gio_id ) uv
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event ='Page_entry'
	and var_activity_name='2024年5月525车主节'
	--and length(gio_id)<9
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
--	and page_title ='525车主节·售后惠聚'
--	AND var_subtitle_name='限时秒杀 畅享纯净呼吸'
--	AND btn_name='订阅活动'
	group by 1
	order by 1
)act  on act.date=app.date

--21.app每天的会员活跃（4月1日到现在），车主节每天的会员活跃
select 
app.date,
app.uv,
act.uv,
concat(toString(round(act.uv/app.uv,3)*100),'%') rat
from (
-- APP活跃
	SELECT 
	toDate(date) date,
	count(distinct usr_merged_gio_id ) uv
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where 1=1
	and date >='2024-04-01'
	and date <now()
	and (`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5')
	--and length(user)<9
	group by 1 
	order by 1
	)app
left join (
-- 525
	SELECT 
	toDate(date) date,
	count(distinct usr_merged_gio_id ) uv
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where 1=1
	and date >='2024-05-15'
	and date <'2024-06-01'
	and event ='Page_entry'
	and var_activity_name='2024年5月525车主节'
	--and length(gio_id)<9
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')
--	and page_title ='525车主节·售后惠聚'
--	AND var_subtitle_name='限时秒杀 畅享纯净呼吸'
--	AND btn_name='订阅活动'
	group by 1
	order by 1
)act  on act.date=app.date



-- 22.过去一年每个月会员日的活跃人数，每个月的app会员月活
	select 
	var_activity_name,
	count(distinct usr_merged_gio_id ) uv
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where 1=1
	and date >='2023-05-01'
	and date <'2024-06-01'
	and event ='Page_entry'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and page_title in ('1月会员日','2月会员日','3月会员日','4月会员日','525车主节'
	,'6月会员日','7月会员日','8月会员日'
	,'9月会员日','10月会员日','11月会员日','12月会员日'
	)
	and (var_activity_name like '%会员日%' or  var_activity_name like '%车主节%')
	group by var_activity_name
	order by var_activity_name  

-- 每月月活
	select 
	left(date,7),
	count(distinct usr_merged_gio_id ) uv
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where 1=1
	and date >='2023-05-01'
	and date <'2024-06-01'
--	and event ='Page_entry'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	group by 1
	order by 1



--对整体活跃的贡献	车主节对私域活跃是否存在显著促进作用
--对整体活跃的贡献	活动拉新（分端）和私域新注册用户对比
--对整体活跃的贡献	活动激活和私域整体激活对比

---------------------------	
	
-- 日活UV
select x.t,
x.uv `gio_tracking UV`,
x1.uv `gio_event UV`
from 
	(
	-- dwd_23_gio_tracking
	SELECT 
	Date(date) t,
	count(distinct usr_merged_gio_id ) uv
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where 1=1
	and date >='2024-05-01'
	and date <'2024-05-11'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` ='MiniProgram' or channel ='Mini'))
	--and length(distinct_id)<9
	group by 1
	order by 1
	)x 
left join 
	(--  ods_gio_event_d
	SELECT 
	Date(client_time) t,
	count(distinct usr_merged_gio_id) uv
	from ods_gio.ods_gio_event_d a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where 1=1
	and event_time >='2024-05-01'
	and client_time >='2024-05-01'
	and client_time <'2024-05-11'
	and (((`$platform` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel = 'App')or (`$platform` ='MinP' or var_channel ='Mini' ))
	--and length(user)<9
	group by 1 
	order by 1
	)x1 on x1.t=x.t



-- 525活动MA触达人数
	SELECT 
		event_date_ts 
		,count(distinct oneid) `发送人数`
	from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d 
	where 1=1
	and context__task_id in ('4257','4258','4259','4273','4260','4261','4272','4267',
		'4268','4286','4287','4288','4289','4277','4398','4432','4435','4437','4439','4434','4436','4438','4440','4427','4428','4429','4470','4485',
		'4486','4487','4489','4490','4491','4492','4493','4506','4499','4528'
	)
	and oneid not like '%whitelist%' -- 去除白名单
	and context__status = 'SUCCESS'
	and context__touch_channel in ('mms','sms','app_push','wechat_mp_template')
--	and 
	group by 1
	order by 1
	
	SELECT *
	from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d 
	limit 10