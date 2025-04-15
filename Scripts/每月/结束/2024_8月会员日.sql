
--活动pv、uv
select 
--	count(user_id) as "双端pv",
	count(usr_merged_gio_id) as "App_pv",
	count(distinct usr_merged_gio_id) as "App_uv"
from dwd_23.dwd_23_gio_tracking a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
where 1=1
and event_time > '2024-08-01' 
and `date` = '2024-08-25'
and event='Page_entry'
and page_title ='8月会员日'
and var_activity_name = '2024年8月会员日'
--and length(distinct_id)<9
and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')

-- 拉新人数
select
count(distinct a.gio_id) "拉新人数"
from
(-- 
	select gio_id,distinct_id,toDateTime(left(`time`,19)) as `time`,memberid
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and event_time>'2024-08-01'
	and `date` = '2024-08-25'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and event='Page_entry'
	and page_title ='8月会员日'
	and var_activity_name = '2024年8月会员日'
)a 
join
(	-- app、小程序用户
		select memberid,
		min_app create_time
--		min_mini create_time
		from ods_oper_crm.ods_oper_crm_usr_gio_d_si
		where 1=1
--		and min_mini is not null
		and min_app is not null 
)b1 on a.memberid=b1.memberid
where toDateTime(a.`time`)-toDateTime(b1.create_time)<=600 
and toDateTime(a.`time`)-toDateTime(b1.create_time)>=-600


-- 邀请试驾线索量
select count(x.`邀请人手机号`)
from 
	(
	SELECT  
	distinct 
		tir.invite_code as invite_code,
		tir.invite_member_id `邀请人会员ID`,
		m.member_phone `邀请人手机号`,
		tir.create_time `邀约时间`,
		tir.be_invite_member_id `被邀请人会员ID`,
		tir.be_invite_mobile `被邀请人手机号`,
		tir.reserve_time `留资时间`,
		tir.vehicle_name `留资车型`,
		tir.drive_time `实际试驾时间`
	from ods_invi.ods_invi_tm_invite_record_d tir 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(tir.invite_member_id)=toString(m.id)  
	join (
		select distinct distinct_id
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and event_time > '2024-08-01' and a.`date` = '2024-08-25'
		and length(a.distinct_id)<9
		and event = 'Page_entry'
		and page_title='8月会员日'
		and var_activity_name='2024年8月会员日'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	)x on toString(x.distinct_id) =toString(m.cust_id) 
	where tir.is_deleted=0
	and date(tir.create_time)= '2024-08-25'
	and tir.be_invite_member_id is not null 
)x

-- 邀请试驾到店量 次月统计
select 
count(case when x.drive_time>='2000-01-01' then 1 else null end)`邀请试驾-次月到店试驾量`
from 
	(
	SELECT  
	distinct 
		tir.invite_code as invite_code,
		tir.invite_member_id `邀请人会员ID`,
--		m.member_phone `邀请人手机号`,
		tir.create_time `邀约时间`,
		tir.be_invite_member_id `被邀请人会员ID`,
		tir.be_invite_mobile `被邀请人手机号`,
		tir.reserve_time `留资时间`,
		tir.vehicle_name `留资车型`,
		tir.drive_time  drive_time
	from ods_invi.ods_invi_tm_invite_record_d tir 
--	left join ods_memb.ods_memb_tc_member_info_cur m on toString(tir.invite_member_id)=toString(m.id)  
	join (
		select distinct memberid
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and event_time > '2024-08-01'
		and a.`date` = '2024-08-25'
--		and a.`date` <= '2024-05-31'
		and distinct_id not like '%#%'
		and length(a.distinct_id)<9
		and event = 'Page_entry'
		and page_title='8月会员日'
		and var_activity_name='2024年8月会员日'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	)x on toString(tir.invite_member_id)=toString(x.memberid)  
	where tir.is_deleted=0
	and date(tir.create_time)='2024-08-25'
	and tir.be_invite_member_id is not null 
)x

-- 预约试驾
	SELECT
	count(m.member_phone) `预约试驾累计线索量`,
	count(case when m.is_vehicle =1 then m.member_phone else null end) `车主预约试驾累计线索量`,
	count(case when m.is_vehicle =0 then m.member_phone else null end) `粉丝预约试驾累计线索量`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(ta.ONE_ID)=toString(m.cust_id) 
	join (
		select distinct distinct_id
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and event_time > '2024-08-01' and a.`date` = '2024-08-25'
		and distinct_id not like '%#%'
		and length(a.distinct_id)<9
		and event = 'Page_entry'
		and page_title='8月会员日'
		and var_activity_name='2024年8月会员日'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(m.cust_id) 
	WHERE 1=1
	and date(ta.CREATED_AT) = '2024-08-25'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端	

	
-- 浏览过活动页且 一键留资线索 [crm的线索]
select count(a.id)
from ods_vced.ods_vced_tm_leads_collection_pool_cur a
join 
(-- 清洗member_phone
	select m.*
	from 
		(-- 清洗member_phone
		select m.*,
		row_number() over(partition by m.member_phone order by m.create_time desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where m.member_status<>'60341003' and m.is_deleted=0
		) m
	where m.rk=1 and m.cust_id is not null 
) m on a.customer_mobile = m.member_phone 
join 
(-- 浏览过活动页
		select distinct distinct_id
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and event_time > '2024-08-01' and a.`date` = '2024-08-25'
		and distinct_id not like '%#%'
		and length(a.distinct_id)<9
		and event = 'Page_entry'
		and page_title='8月会员日'
		and var_activity_name='2024年8月会员日'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
)x on toString(x.distinct_id) =toString(m.cust_id) 
where 1=1
and toDate(a.create_time) = '2024-08-25' 
--and create_time < '2024-03-27'
and campaign_code in
			(
				-- 一键留资
				select
				DISTINCT trim(code) code
				from ods_oper_crm.ods_oper_crm_umt001_em90_his_d   -- 一键留资表
				where 1=1 
				-- and (car_type = 'ALL' or car_type = 'EX30')    -- 筛选车型
				and channel = '一键留资'   -- 筛选一键留资
				and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = yesterday()
			)
	
--预约试驾累计到店量 次月统计
	SELECT
--	count(m.member_phone) `预约试驾活动留资量`,
--	count(distinct m.member_phone) `预约试驾活动线索（去重）`,
	count(case when ta.ARRIVAL_DATE>='2000-01-01' then 1 else null end)`预约试驾-活动到店试驾量`,
	count(case when ta.ARRIVAL_DATE>='2000-01-01' and m.is_vehicle =1 then 1 else null end)`预约试驾-车主到店`,
	count(case when ta.ARRIVAL_DATE>='2000-01-01' and m.is_vehicle =0 then 1 else null end)`预约试驾-粉丝到店`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(ta.ONE_ID)=toString(m.cust_id) 
	join (
		select distinct distinct_id
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and event_time > '2024-07-01'
		and a.`date` = '2024-07-25'
--		and a.`date` <= '2024-05-31'
		and distinct_id not like '%#%'
		and length(a.distinct_id)<9
		and event = 'Page_entry'
		and page_title='7月会员日'
		and var_activity_name='2024年7月会员日'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	)x on toString(x.distinct_id) =toString(m.cust_id) 
	WHERE 1=1
	and date(ta.CREATED_AT) = '2024-07-25'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端	



-- 一键留资线索到店 [crm的线索]
SELECT sum(dd_final)
from 
(-- 到店数大于线索数时,取线索数作为到店数
	SELECT arrive.year_month,
	arrive.mobile_phone,
	arrive.dd_nums,
	xiansuo.xs_nums,
	if(arrive.dd_nums>xiansuo.xs_nums,xiansuo.xs_nums,arrive.dd_nums) as dd_final
	from 
	(-- 每月每人的到店数
		select left(base.liuzi::varchar,7) year_month,base.mobile_phone,count(1) dd_nums
		from 
		(-- 一键留资后30天内到店
			select pfi.id,pfi.mobile_phone mobile_phone,min(a.create_time) as liuzi
			from ods_cypf.ods_cypf_tt_passenger_flow_info_cur pfi  
			inner join 
			(-- 浏览过活动页且 一键留资线索 
				select a.customer_mobile customer_mobile,a.create_time create_time
				from ods_vced.ods_vced_tm_leads_collection_pool_cur a
				join 
				(-- 清洗member_phone
					select m.cust_id,m.member_phone
					from 
						(-- 清洗member_phone
						select m.*,
						row_number() over(partition by m.member_phone order by m.create_time desc) rk
						from ods_memb.ods_memb_tc_member_info_cur m
						where m.member_status<>'60341003' and m.is_deleted=0
						) m
					where m.rk=1 and m.cust_id is not null 
				) m on a.customer_mobile = m.member_phone 
				join 
				(-- 浏览过活动页
					select distinct distinct_id
					from dwd_23.dwd_23_gio_tracking a
					where 1=1
					and a.`date` = '2024-08-25'
			--		and a.`date` <= '2024-05-31'
--					and distinct_id not like '%#%'
					and length(a.distinct_id)<9
					and event = 'Page_entry'
					and page_title='8月会员日'
					and var_activity_name='2024年8月会员日'
					and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
					)x on toString(x.distinct_id) =toString(m.cust_id) 
				where a.campaign_code in
					(
						-- 一键留资
						select
						DISTINCT trim(code) code
						from ods_oper_crm.ods_oper_crm_umt001_em90_his_d   -- 一键留资表
						where 1=1 
						-- and (car_type = 'ALL' or car_type = 'EX30')    -- 筛选车型
						and channel = '一键留资'   -- 筛选一键留资
						and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = yesterday()
					)
				and a.create_time >= '2024-08-25' -- 只要比最小的到店时间小30天即可
			) a on a.customer_mobile = pfi.mobile_phone 
			where 1=1
			and pfi.created_at = '2024-08-25' 
			and a.create_time <= pfi.created_at 
			and toDate(pfi.created_at) <= date_add(day,30,toDate(a.create_time))
			group by pfi.id,pfi.mobile_phone
		) base
		group by left(base.liuzi::varchar,7),base.mobile_phone
	) arrive 
	left join 
	(-- 浏览过活动页的 每月每人的一键留资线索
		select left(a.create_time::varchar,7) year_month,a.customer_mobile customer_mobile,count(1) xs_nums
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		join 
		(-- 清洗member_phone
			select m.*
			from 
				(-- 清洗member_phone
				select m.*,
				row_number() over(partition by m.member_phone order by m.create_time desc) rk
				from ods_memb.ods_memb_tc_member_info_cur m
				where m.member_status<>'60341003' and m.is_deleted=0
				) m
			where m.rk=1 and m.cust_id is not null 
		) m on a.customer_mobile = m.member_phone 
		join 
		(-- 浏览过活动页
			select distinct distinct_id
					from dwd_23.dwd_23_gio_tracking a
					where 1=1
					and a.`date` = '2024-08-25'
			--		and a.`date` <= '2024-05-31'
					and distinct_id not like '%#%'
					and length(a.distinct_id)<9
					and event = 'Page_entry'
					and page_title='8月会员日'
					and var_activity_name='2024年8月会员日'
					and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(m.cust_id)
		where a.create_time = '2024-08-25'
		 and campaign_code in
			(
				-- 一键留资
				select
				DISTINCT trim(code) code
				from ods_oper_crm.ods_oper_crm_umt001_em90_his_d   -- 一键留资表
				where 1=1 
				-- and (car_type = 'ALL' or car_type = 'EX30')    -- 筛选车型
				and channel = '一键留资'   -- 筛选一键留资
				and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = yesterday()
			)
		group by left(a.create_time::varchar,7) ,customer_mobile
	) xiansuo on xiansuo.year_month=arrive.year_month and xiansuo.customer_mobile=arrive.mobile_phone
) detail
	
	
-- 养修预约 养修预约线索量
	select 
	count(tam.APPOINTMENT_ID)
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join 
		(select tmi.id
		,tmi.cust_id
		,row_number()over(partition by tmi.cust_id order by tmi.create_time desc) rk 
		from ods_memb.ods_memb_tc_member_info_cur tmi
		where tmi.is_deleted =0
		Settings allow_experimental_window_functions = 1
		)tmi on ta.ONE_ID = tmi.cust_id 
	join (
			select distinct distinct_id
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-08-01' and a.`date` = '2024-08-25'
			and distinct_id not like '%#%'
			and length(a.distinct_id)<9
			and event = 'Page_entry'
			and page_title='8月会员日'
			and var_activity_name='2024年8月会员日'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(ta.ONE_ID) 
	where 1=1
	and tam.IS_DELETED <>1
	and date(ta.CREATED_AT)= '2024-08-25'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
	and tmi.rk =1
--	and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') -- 进厂

-- 购买售后卡券
select 
sum(`兑换数量`) `卡券线索数`
from 
(-- 浏览过活动页且 购买售后卡券
	select 
		a.order_code `订单编号`
		,a.create_time `兑换时间`
		,b.product_id `商城兑换id`
		,a.user_id `会员id`
		,h.cust_id 
		,a.user_name `会员姓名`
		,b.spu_name `兑换商品`
		,b.spu_id
		,b.sku_code `商品编码`
		,b.fee/100 `总金额`
		,b.coupon_fee/100 `优惠券抵扣金额`
		,round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额`
		,b.sku_num `兑换数量`
		,case when b.pay_fee=0 then '纯V值支付' when b.point_amount=0 then '纯现金支付' else '混合支付' end `支付方式`
	from ods_orde.ods_orde_tt_order_d a  -- 订单主表
	left join ods_orde.ods_orde_tt_order_product_d  b on a.order_code = b.order_code  -- 订单商品表
	left join ods_memb.ods_memb_tc_member_info_cur h on toString(a.user_id) = toString(h.id)
	join 
	(
			select distinct distinct_id
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-08-01' and a.`date` = '2024-08-25'
			and distinct_id not like '%#%'
			and length(a.distinct_id)<9
			and event = 'Page_entry'
			and page_title='8月会员日'
			and var_activity_name='2024年8月会员日'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(h.cust_id)
	where 1=1
	and toDate(a.create_time) = '2024-08-25' 
--	and a.create_time <'2024-03-27'
	and a.is_deleted = 0  -- 剔除逻辑删除订单
	and b.is_deleted = 0
	and h.is_deleted = 0  
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and b.spu_type='51121003'-- 虚拟服务卡券，也就是保养类卡券 [售后卡券]
	order by a.create_time
) a 	
	
--养修预约到店 次月统计
	select 
	count(case when tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') then 1 else null end )`养修预约活动次月提交实际到店量`
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join 
		(select tmi.id
		,tmi.cust_id
		,row_number()over(partition by tmi.cust_id order by tmi.create_time desc) rk 
		from ods_memb.ods_memb_tc_member_info_cur tmi
		where tmi.is_deleted =0
		Settings allow_experimental_window_functions = 1
		)tmi on ta.ONE_ID = tmi.cust_id 
	join (
			select distinct distinct_id
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-08-01' and a.`date` = '2024-08-25'
			and distinct_id not like '%#%'
			and length(a.distinct_id)<9
			and event = 'Page_entry'
			and page_title='8月会员日'
			and var_activity_name='2024年8月会员日'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(ta.ONE_ID) 
	where 1=1
	and tam.IS_DELETED <>1
	and date(ta.CREATED_AT)= '2024-08-25'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
	and tmi.rk =1
--	and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') -- 进厂

-- 活动GMV
select 
--distinct m.fl
SUM(case when m.fl='精品' then m.`不含税的总金额` else null end) `精品（元）`,
SUM(case when m.fl='售后养护' then m.`不含税的总金额` else null end) `售后（元）`,
SUM(case when m.fl='充电专区' then m.`不含税的总金额` else null end) `充电（元）`,
SUM(case when m.fl='生活服务' then m.`不含税的总金额` else null end) `第三方（元）`,
SUM(case when m.fl='精品' then m.`现金支付金额` else null end)/SUM(case when m.fl='精品' then m.`总金额` else null end)`现金支付金额精品比例`,
SUM(case when m.fl='售后养护' then m.`现金支付金额` else null end)/SUM(case when m.fl='售后养护' then m.`总金额` else null end)`现金支付金额售后比例`,
SUM(case when m.fl='充电专区' then m.`现金支付金额` else null end)/SUM(case when m.fl='充电专区' then m.`总金额` else null end)`现金支付充电比例`,
SUM(case when m.fl='充电专区' or m.fl='精品' or m.fl='售后养护' then m.`现金支付金额` else null end)
/SUM(case when m.fl='充电专区' or m.fl='精品' or m.fl='售后养护' then m.`总金额` else null end)`合计比例`
--,SUM(case when m.fl='充电专区' then m.`现金支付金额` else null end)
--,SUM(case when m.fl='充电专区' then m.`总金额` else null end)
from 
	(select a.order_code `订单编号`
	,b.product_id `商城兑换id`
	,a.user_id `会员id`
	,a.user_name `会员姓名`
--	,x.distinct_id
	,b.spu_name `兑换商品`
	,b.spu_id
	,b.sku_id
	,b.spu_bus_id
	,b.sku_code
	,b.sku_real_point `商品单价`
	,ifnull(ifnull(f2.fl,case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end)
	,CASE WHEN b.spu_type =51121001 THEN '精品'
		WHEN b.spu_type =51121002 THEN '生活服务' --第三方卡券`
		WHEN b.spu_type =51121003 THEN '售后养护' --保养类卡券
		WHEN b.spu_type =51121004 THEN '精品'
		WHEN b.spu_type =51121006 THEN '一件代发'
		WHEN b.spu_type =51121007 THEN '经销商端产品'
		WHEN b.spu_type =51121008 THEN '售后养护'   -- '车辆权益'
		ELSE null end) `fl`
,CASE b.spu_type
		WHEN 51121001 THEN '沃尔沃精品' 
		WHEN 51121002 THEN '第三方卡券' 
		WHEN 51121003 THEN '虚拟服务卡券' 
		WHEN 51121004 THEN '非沃尔沃精品'    -- 还会新增一个子分类
		WHEN 51121006 THEN '一件代发'
		WHEN 51121007 THEN '经销商端产品'
	    WHEN 51121008 THEN '虚拟服务权益'
	    ELSE null end `商品类型`
	,b.fee/100 `总金额`
	,b.coupon_fee/100 `优惠券抵扣金额`
	,round(b.point_amount/3+b.pay_fee/100,2) `实付金额`
	,round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额` -- 剔除优惠券
	,b.pay_fee/100 `现金支付金额`
	,b.point_amount `支付V值`
	,b.sku_num `兑换数量`
	,a.create_time as tt
	,case 
		when b.pay_fee=0 then '纯V值支付'
		when b.point_amount=0 then '纯现金支付' else '混合支付' end `支付方式`
	,f.name `分类`
	,CASE b.spu_type 
		WHEN 51121001 THEN 'VOLVO仓商品'
		WHEN 51121002 THEN 'VOLVO仓第三方卡券'
		WHEN 51121003 THEN '虚拟服务卡券'
		WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS `仓库`
	,CASE b.status
			WHEN 51301001 THEN '待付款'
			WHEN 51301002 THEN '待发货'
			WHEN 51301003 THEN '待收货'
			WHEN 51301004 THEN '收货确认'
			WHEN 51301005 THEN '退货中'
			WHEN 51301006 THEN '交易关闭' 
	END AS `商品状态`
	,CASE a.status
			WHEN 51031002 THEN '待付款'
			WHEN 51031003 THEN '待发货' 
			WHEN 51031004 THEN '待收货' 
			WHEN 51031005 THEN '已完成'
			WHEN 51031006 THEN '已关闭'  
	END AS `订单状态`
	,CASE a.close_reason 
	WHEN 51091003 THEN '用户退款' 
	WHEN 51091004 THEN '用户退货退款' 
	WHEN 51091005 THEN '商家退款' END AS `关闭原因`
	,e.`退货状态` `退货状态`
	,e.`退货数量` `退货数量`
	,e.`退回V值` `退回V值`
	,e.`退回时间` `退回时间`
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
			where m.member_status<>'60341003' 
			and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(a.user_id) = toString(h.id)   -- 会员表(获取会员信息)
	join (
			select distinct distinct_id
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-08-01' 
			and event_time < '2024-09-01' 
			and a.`date` = '2024-08-25'
			and length(a.distinct_id)<9
			and event = 'Page_entry'
			and page_title='8月会员日'
			and var_activity_name='2024年8月会员日'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(h.cust_id) 
	left join ods_good.ods_good_item_spu_d j on b.spu_id = j.id   -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_front_category_d f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
	left join
	(
		-- 获取前台分类[充电专区]的商品 
		select distinct j.id as spu_id ,
		j.name,
		f2.name as fl
		from ods_good.ods_good_item_spu_d j
		left join ods_good.ods_good_item_sku_d i on j.id =i.spu_id 
		left join ods_good.ods_good_item_sku_channel_d s on i.id =s.sku_id 
		left join ods_good.ods_good_front_category_d f2 on s.front_category1_id=f2.id
		where 1=1
		and f2.name='充电专区'
--		and j.is_deleted ='0' -- 该表该字段全为空
--		and i.is_deleted ='0' -- 该表该字段全为空
		and s.is_deleted ='0'
		and f2.is_deleted ='0'
	)f2 on f2.spu_id=b.spu_id
	left join(
	--	#V值退款成功记录
		select so.order_code
		,sp.product_id
		,CASE 
			WHEN so.status ='51171001' THEN '待审核'
			WHEN so.status ='51171002' THEN '待退货入库'
			WHEN so.status ='51171003' THEN '待退款'
			WHEN so.status ='51171004' THEN '退款成功'
			WHEN so.status ='51171005' THEN '退款失败'
			WHEN so.status ='51171006' THEN '作废退货单' END as `退货状态`
		,sum(sp.sales_return_num) `退货数量`
		,sum(so.refund_point) `退回V值`
		,max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code=sp.refund_order_code 
		where so.is_deleted = 0 
		and so.status='51171004' -- 退款成功
		and sp.is_deleted=0
		GROUP BY order_code,product_id,`退货状态`
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	where 1=1
	and toDate(a.create_time) = '2024-08-25' 
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
--	and j.front_category_id is not null
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = 10041002 -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
--	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
--	and e.order_code is null  -- 剔除退款订单
	order by a.create_time) m

————————————————————————————————————————————————————————————————————————————整体数据——————————————————————————————————————————————————————————————————————————————————————————

select x.*
from 
(
-- APP当日启动量
SELECT
1 `rk`,count(1)
from dwd_23.dwd_23_gio_tracking
where 1=1
and event_time > '2024-08-01' and `date` = '2024-08-25'
and event= '$AppStart'
and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or  channel='App')
union all 
-- APP当日下载量
select 2 `rk`,count(1)
from ods_oper_crm.ods_oper_crm_usr_gio_d_si
where 1=1
and date(min_app) = '2024-08-25'
union all 
-- APP总用户数
select 3 `rk`,count(1)
from ods_oper_crm.ods_oper_crm_usr_gio_d_si
where min_app is not null 
union all 
--APP总车主数
select 4 `rk`,count(1)
from ads_crm.ads_crm_events_member_d m
where 1=1
and min_app_time is not null -- 筛选app用户
and date(min_app_time)<= '2024-08-25'
and is_owner =1 -- 筛选车主
union all
--活动当日APP日活
select 5 `rk`,count(distinct memberid)
from ods_oper_crm.ods_oper_crm_active_gio_d_si 
where platform ='App'
and date(dt)= '2024-08-25'
union all
--当月APP月活
select 6 `rk`,count(distinct memberid)
from ods_oper_crm.ods_oper_crm_active_gio_d_si 
where platform ='App'
and dt<='2024-08-25'
and dt>= '2024-08-01'
)x order by 1 

--活动pv、uv
select 
--	count(user_id) as "双端pv",
	count(case when ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel='App') then usr_merged_gio_id end) as "App_pv",
	count(distinct case when ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel='App') then usr_merged_gio_id end) as "App_uv"
from dwd_23.dwd_23_gio_tracking a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
where 1=1
and event_time > '2024-08-01' and `date` = '2024-08-25'
and event='Page_entry'
and page_title ='8月会员日'
and var_activity_name = '2024年8月会员日'
--and length(distinct_id)<9
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` ='MiniProgram' or channel ='Mini'))
		
-- APP拉新人数-车主
select
count(distinct a.gio_id) "拉新人数"
from
(-- 
	select gio_id,distinct_id,toDateTime(left(`time`,19)) as `time`,memberid
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and event_time>'2024-08-01'
	and `date` = '2024-08-25'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and event='Page_entry'
	and page_title ='8月会员日'
	and var_activity_name = '2024年8月会员日'
)a 
join
(	-- app用户
		select memberid,
		min_app create_time
		from ods_oper_crm.ods_oper_crm_usr_gio_d_si
		where 1=1
		and min_app is not null 
		and is_vehicle='1' --车主
)b1 on a.memberid=b1.memberid
where toDateTime(a.`time`)-toDateTime(b1.create_time)<=600 
and toDateTime(a.`time`)-toDateTime(b1.create_time)>=-600




-- 激活人数、APP召回车主、小程序召回车主
select 
count(distinct a.gio_id) `召回人数`
from
(-- 525页面
	select gio_id,distinct_id,toDateTime(left(`time`,19)) as `time`,memberid
	from dwd_23.dwd_23_gio_tracking a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.memberid)=toString(m.id)  
	where 1=1
	and event_time > '2024-08-01' and `date` = '2024-08-25'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and event='Page_entry'
	and page_title ='8月会员日'
	and var_activity_name = '2024年8月会员日'
	and m.is_vehicle ='1' -- 车主
	and length(distinct_id)<9
) a
left join
(-- 注册会员
	select distinct m.id
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time = '2024-08-25'
) b on a.memberid=b.id::varchar
left join
(-- 访问过活动前30天内活跃过的车主会员
	select distinct a.distinct_id
	from
	(-- 取用户在活动期间最早的一次活跃,避免激活用户在活动期间重复活跃,被当成非激活了【注意：活动持续时间超过30天的不能这么取】
		select distinct_id,min(toDateTime(`time0`)) as `time`,min(toDateTime(`time0`)) + interval '-10 MINUTE' as `time1`
		from
		(-- 525页面
			select distinct_id,left(`time`,19) as `time0`
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-08-01' and `date` = '2024-08-25'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
			and event='Page_entry'
			and page_title ='8月会员日'
			and var_activity_name = '2024年8月会员日'
			and length(distinct_id)<9
		)a
		group by distinct_id
	)a 
	join
	(-- 前30天内活跃用户
	--	用户活跃
		select distinct_id
		,toDateTime(left(`time`,19)) as `time` 
		from dwd_23.dwd_23_gio_tracking a
		where length(distinct_id)<9 
		and event_time > '2024-07-01' 
		and `date`>= '2024-07-25'
		and `date`< '2024-08-25' -- 30天前
		and (((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
--		and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$app_version`,1)='5') or channel ='App') -- App
--		and (`$lib` in('MiniProgram') or channel ='Mini') -- 小程序
		and length(distinct_id)<9
	) b on a.distinct_id=b.distinct_id
	where a.`time`+ interval '-30 day'<= b.`time` and b.`time`< a.`time1`
) c on a.distinct_id = c.distinct_id
where 1=1
and b.id is null -- 剔除新用户
and c.distinct_id is null -- 剔除访问活动前30天内活跃过的车主会员

--活动流失预警人数  /车主 注意更改注释
SELECT 
	count(case when current_month.distinct_id is null then last_month.distinct_id end) as `流失用户数`
from (
		--上月活跃用户id
		SELECT
			distinct distinct_id 
		from dwd_23.dwd_23_gio_tracking a
		left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id)=toString(a.memberid) 
		where 1=1
		and event_time > '2024-07-01'
		and `date`>= '2024-07-25'
--		and `date` <= '2024-05-31'
		and event= 'Page_entry'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` ='MiniProgram' or channel ='Mini'))
		and page_title ='7月会员日'
		and var_activity_name = '2024年7月会员日'
--		and m.is_vehicle='1'
		and length(distinct_id)<9 
	) last_month
left join (
		--本月活跃用户id
		SELECT
		distinct distinct_id 
		from dwd_23.dwd_23_gio_tracking a
		left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id)=toString(a.memberid)
		where 1=1
		and event_time > '2024-08-01' and `date` = '2024-08-25'
		and event= 'Page_entry'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` ='MiniProgram' or channel ='Mini'))
		and page_title ='8月会员日'
		and var_activity_name = '2024年8月会员日'
--		and m.is_vehicle='1'
		and length(distinct_id)<9 
) current_month on current_month.distinct_id=last_month.distinct_id

--APP活动订阅人数
	select count(distinct distinct_id)
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and event='Button_click'
	and length(distinct_id)<9 
	and date = '2024-08-25'
	and page_title ='8月会员日'
	and var_activity_name = '2024年8月会员日'
	and btn_name ='订阅活动'
	and length(distinct_id)<9 
--	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))--双端
	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel = 'App') --App
--	and (`$lib` ='MiniProgram' or  channel ='Mini')--Mini

--活跃车主UV
select count(distinct usr_merged_gio_id ) uv
from dwd_23.dwd_23_gio_tracking a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id)=toString(a.memberid) -- 2024年以后得数据可以用mmeberid关联
where 1=1
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))--双端
--and a.`date` >= '2024-05-01' -- App开始使用
and page_title ='8月会员日'
and var_activity_name = '2024年8月会员日'
and event_time > '2024-08-01' and a.`date` = '2024-08-25'
and distinct_id not like '%#%'
and length(distinct_id)<9
and m.is_vehicle =1
	
--参与度-活动
select 
--	count(case when m_level.level_id in (1) then ac_join.distinct_id end) as `银卡活跃用户数`,
	count(case when m_level.level_id in (1) then ac_join.distinct_id end)/count(ac_join.distinct_id) as "银卡参与占比",
--	count(case when m_level.level_id in (2,3,4) then ac_join.distinct_id end) as `金卡及以上活跃用户数`,
	count(case when m_level.level_id in (2,3,4) then ac_join.distinct_id end)/count(ac_join.distinct_id) as "金卡及以上参与占比"
from (
	--上月活跃用户id
	SELECT
		distinct distinct_id 
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event_time > '2024-08-01' and `date` = '2024-08-25'
	and event= 'Page_entry'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` ='MiniProgram' or channel ='Mini'))
	and page_title ='8月会员日'
	and var_activity_name = '2024年8月会员日'
	and length(distinct_id)<9 
) ac_join
	inner join (
	-- 清洗cust_id
	select a.cust_id ,a.level_id,a.rk
	from (
		select 
			 m.cust_id ,m.level_id,
			 row_number() over(partition by m.cust_id order by m.create_time desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where m.member_status<>'60341003' and m.is_deleted=0
		and m.cust_id is not null 
		Settings allow_experimental_window_functions = 1
		) a 
		where a.rk=1
) m_level
on m_level.cust_id::varchar = ac_join.distinct_id

--参与度-整体占比
select
	count(case when m_level.level_id =1 then m_level.cust_id end)/count(m_level.cust_id ) "App银卡整体占比",
	count(case when m_level.level_id in (2,3,4) then m_level.cust_id end)/count(m_level.cust_id ) "App金卡及整体占比"
	from (
	-- 清洗cust_id
	select a.cust_id ,a.level_id,a.rk
	from (
		select 
			 m.cust_id ,m.level_id,
			 row_number() over(partition by m.cust_id order by m.create_time desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where m.member_status<>'60341003' and m.is_deleted=0
		and m.cust_id is not null 
		Settings allow_experimental_window_functions = 1
		) a 
		where a.rk=1
)m_level
 
-- 邀请试驾线索量 会员日当天
SELECT 
count(tir.be_invite_mobile)`邀请试驾活动留资量`,
count(distinct tir.be_invite_mobile)`邀请试驾活动线索（去重）`,
count(case when tir.drive_time>='2000-01-01' then 1 else null end)`邀请试驾-到店试驾量`
from ods_invi.ods_invi_tm_invite_record_d tir 
left join ods_memb.ods_memb_tc_member_info_cur m on toString(tir.invite_member_id)=toString(m.id)  
join (
	select distinct distinct_id
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and event_time > '2024-08-01' and a.`date` = '2024-08-25'
	and distinct_id not like '%#%'
	and length(a.distinct_id)<9
	and event = 'Page_entry'
	and page_title='8月会员日'
	and var_activity_name='2024年8月会员日'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
)x on toString(x.distinct_id) =toString(m.cust_id) 
where tir.is_deleted=0
and date(tir.create_time)= '2024-08-25'
and tir.be_invite_member_id is not null 

-- 活动到店试驾后购车数（新增需求） 会员日当天
SELECT 
count(case when tir.drive_time>='2000-01-01' then 1 else null end)`邀请试驾-到店试驾量_活动到店试驾后购车数`
from ods_invi.ods_invi_tm_invite_record_d tir 
left join ods_memb.ods_memb_tc_member_info_cur m on toString(tir.invite_member_id)=toString(m.id)  
join (
	select distinct distinct_id
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and event_time > '2024-06-01' and a.`date` = '2024-06-25'
	and distinct_id not like '%#%'
	and length(a.distinct_id)<9
	and event = 'Page_entry'
	and page_title='6月会员日'
	and var_activity_name='2024年6月会员日'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
)x on toString(x.distinct_id) =toString(m.cust_id)
join
(
	select
	distinct a.phone_num
	from
	(
		select
		o.customer_tel phone_num
		from ods_cydr.ods_cydr_tt_sales_orders_cur o 
		where o.is_deleted  = 0
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
		UNION ALL  
		select
		o.drawer_tel phone_num
		from ods_cydr.ods_cydr_tt_sales_orders_cur o 
		where o.is_deleted  = 0
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')	
		UNION ALL  
		select
		o.purchase_phone phone_num
		from ods_cydr.ods_cydr_tt_sales_orders_cur o
		where o.is_deleted  = 0
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
	) a
	where length(a.phone_num) = '11'
	and left(a.phone_num,1) = '1'
)x2 on m.member_phone =x2.phone_num
where tir.is_deleted=0
and date(tir.create_time)= '2024-06-25'
and tir.be_invite_member_id is not null 

-- 邀请试驾线索量 当月注意修改月份
SELECT 
--date_trunc('month',tir.create_time) ,
count(tir.be_invite_mobile)`邀请试驾留资量`,
count(case when tir.drive_time>='2000-01-01' then 1 else null end)`邀请试驾-到店试驾量`
FROM ods_invi.ods_invi_tm_invite_record_d tir  
where 1=1
and toDate(tir.create_time)>='2024-08-01'
and tir.is_deleted =0
--group by 1 
--order by 1 

-- 预约试驾 会员日当天 
	SELECT
--	count(m.member_phone) `预约试驾活动留资量`,
	count(distinct m.member_phone) `预约试驾活动线索（去重）`,
	count(case when ta.ARRIVAL_DATE>='2000-01-01' then 1 else null end)`预约试驾-活动到店试驾量`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(ta.ONE_ID)=toString(m.cust_id) 
	join (
		select distinct distinct_id
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and event_time > '2024-08-01' and a.`date` = '2024-08-25'
		and distinct_id not like '%#%'
		and length(a.distinct_id)<9
		and event = 'Page_entry'
		and page_title='8月会员日'
		and var_activity_name='2024年8月会员日'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(m.cust_id) 
	WHERE 1=1
	and date(ta.CREATED_AT) = '2024-08-25'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	
-- 预约试驾 会员日当天  活动到店试驾后购车数（新增需求）
	SELECT
	count(case when ta.ARRIVAL_DATE>='2000-01-01' then 1 else null end)`预约试驾-活动到店试驾量 活动到店试驾后购车数`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(ta.ONE_ID)=toString(m.cust_id) 
	join (
		select distinct distinct_id
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and event_time > '2024-06-01' and a.`date` = '2024-06-25'
		and distinct_id not like '%#%'
		and length(a.distinct_id)<9
		and event = 'Page_entry'
		and page_title='6月会员日'
		and var_activity_name='2024年6月会员日'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(m.cust_id) 
	join
	(
	select
	distinct a.phone_num
	from
	(
		select
		o.customer_tel phone_num
		from ods_cydr.ods_cydr_tt_sales_orders_cur o 
		where o.is_deleted  = 0
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
		UNION ALL  
		select
		o.drawer_tel phone_num
		from ods_cydr.ods_cydr_tt_sales_orders_cur o 
		where o.is_deleted  = 0
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')	
		UNION ALL  
		select
		o.purchase_phone phone_num
		from ods_cydr.ods_cydr_tt_sales_orders_cur o
		where o.is_deleted  = 0
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
	) a
	where length(a.phone_num) = '11'
	and left(a.phone_num,1) = '1'
)x2 on m.member_phone =x2.phone_num
	WHERE 1=1
	and date(ta.CREATED_AT) = '2024-06-25'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端

-- 预约试驾 当月 注意修改月份
	SELECT
	count(m.member_phone) `预约试驾活动留资量`,
--	count(distinct m.member_phone) `预约试驾活动线索（去重）`,
	count(case when ta.ARRIVAL_DATE>='2000-01-01' then 1 else null end)`预约试驾-活动到店试驾量`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(ta.ONE_ID)=toString(m.cust_id) 
	WHERE 1=1
	and ta.CREATED_AT >= '2024-08-01' -- 修改月份
	and ta.CREATED_AT < '2024-09-01' -- 修改月份
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端

-- 养修预约 会员日当天
	select 
	count(tam.WORK_ORDER_NUMBER) `养修预约工单活动提交量`,
	count(case when tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') then 1 else null end )`养修预约活动提交实际到店量`
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join 
		(select tmi.id
		,tmi.cust_id
		,row_number()over(partition by tmi.cust_id order by tmi.create_time desc) rk 
		from ods_memb.ods_memb_tc_member_info_cur tmi
		where tmi.is_deleted =0
		Settings allow_experimental_window_functions = 1
		)tmi on ta.ONE_ID = tmi.cust_id 
	join (
			select distinct distinct_id
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-08-01' and a.`date` = '2024-08-25'
			and distinct_id not like '%#%'
			and length(a.distinct_id)<9
			and event = 'Page_entry'
			and page_title='8月会员日'
			and var_activity_name='2024年8月会员日'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(ta.ONE_ID) 
	where 1=1
	and tam.IS_DELETED <>1
	and date(ta.CREATED_AT)= '2024-08-25'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
	and tmi.rk =1
--	and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') -- 进厂


--养修订单金额（新增需求）
-- 回厂数：养修预约匹后续的回厂：取母工单数 [注：存在不同经销商同一母工单号]
select sum(o.BALANCE_AMOUNT) `养修订单金额`
from
(-- 养修预约		
	select 
			ta.APPOINTMENT_ID as APPOINTMENT_ID
			,ta.CREATED_AT as CREATED_AT
		    ,ta.ONE_ID as ONE_ID
		    ,ta.MEMBER_ID as MEMBER_ID
		    ,substring(ta.CREATED_AT::varchar,1,7) as year_month
		    ,tam.WORK_ORDER_NUMBER as WORK_ORDER_NUMBER -- 【到店】: 不为空
		    ,ta.OWNER_CODE as OWNER_CODE
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	join (
			select distinct distinct_id
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-07-01' and a.`date` = '2024-07-25'
			and distinct_id not like '%#%'
			and length(a.distinct_id)<9
			and event = 'Page_entry'
			and page_title='7月会员日'
			and var_activity_name='2024年7月会员日'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(ta.ONE_ID) 
	where 1=1
	and tam.IS_DELETED <>1
	and date(ta.CREATED_AT)= '2024-07-25'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
	)ta
join
(-- 回厂
	select distinct o.RELATION_RO_NO,o.RO_NO,o.OWNER_CODE,o.BALANCE_AMOUNT
	from ods_cyre.ods_cyre_tt_repair_order_d o
	where o.IS_DELETED = 0
	and o.REPAIR_TYPE_CODE <> 'P'
	and o.RO_STATUS = 80491003    -- 已结算工单
	and date(o.RO_CREATE_DATE) = '2024-07-25'
--	and o.RO_CREATE_DATE < '2024-05-16'
)o on ta.WORK_ORDER_NUMBER=o.RO_NO and ta.OWNER_CODE=o.OWNER_CODE
	
-- 养修预约 当月 注意修改月份
	select 
	count(tam.APPOINTMENT_ID) `养修预约工单活动提交量`,
	count(case when tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') then 1 else null end )`养修预约活动提交实际到店量`
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
	where 1=1
	and tam.IS_DELETED <>1
	and ta.CREATED_AT >= '2024-08-01' -- 修改月份
	and ta.CREATED_AT < '2024-09-01' -- 修改月份
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005

-- 充电订单明细
select count(x.member_id) `充电地图-活动充电订单量`,
sum(x.`充电费款金额`) `充电地图-活动充电付款金额`
from
	(
	select a.member_id as member_id,
	m.member_phone `沃世界注册手机号`,
	a.vin `绑定vin`,
	tm.model_name `车型`,
	a.station_name `充电站`,
	a.start_time `充电开始时间`,
	a.end_time `充电结束时间`,
	a.charge_use_time `充电用时`,
	a.charge_use_power `充电量`,
	a.total_money_crossed `充电费款金额`,
	a.stop_reason `结束原因`
	from ods_chrg.ods_chrg_tt_charge_order_d a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.member_id)=toString(m.id) 
	left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd on toString(tisd.vin) =toString(a.vin )
	left join ods_bada.ods_bada_tm_model_cur tm on tm.id=tisd.model_id 
	join (
			select distinct distinct_id
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-08-01' and a.`date` = '2024-08-25'
			and distinct_id not like '%#%'
			and length(a.distinct_id)<9
			and event = 'Page_entry'
			and page_title='8月会员日'
			and var_activity_name='2024年8月会员日'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(m.cust_id) 
	where a.is_deleted =0
	and tisd.is_deleted =0
	and date(a.create_time)='2024-08-25'
)x 

--# 充电地图当月订单量
select count(x.member_id) `充电地图-当月充电订单量`
--,sum(x.`充电费款金额`) `充电地图-活动充电付款金额`
from
	(
	select a.member_id as member_id,
	m.member_phone `沃世界注册手机号`,
	a.vin `绑定vin`,
	tm.model_name `车型`,
	a.station_name `充电站`,
	a.start_time `充电开始时间`,
	a.end_time `充电结束时间`,
	a.charge_use_time `充电用时`,
	a.charge_use_power `充电量`,
	a.total_money_crossed `充电费款金额`,
	a.stop_reason `结束原因`
	from ods_chrg.ods_chrg_tt_charge_order_d a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.member_id)=toString(m.id) 
	left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd on toString(tisd.vin) =toString(a.vin )
	left join ods_bada.ods_bada_tm_model_cur tm on tm.id=tisd.model_id 
	where a.is_deleted =0
	and tisd.is_deleted =0
	and a.create_time>='2024-04-01'
	and a.create_time<'2024-05-01'
)x 

-- 活动GMV
select 
SUM(m.`不含税的总金额`),
SUM(case when m.fl='精品' then m.`不含税的总金额` else null end) `精品（元）`,
SUM(case when m.fl='售后养护' then m.`不含税的总金额` else null end) `售后（元）`,
SUM(case when m.fl='充电专区' then m.`不含税的总金额` else null end) `充电（元）`,
--SUM(case when m.fl='生活服务' then m.`总金额` else null end) `第三方（元）`,
SUM(m.`现金支付金额` ) `现金支付金额（元）`
--SUM(case when m.fl='售后养护' then m.`现金支付金额` else null end) `现金支付金额售后（元）`,
--SUM(case when m.fl='充电专区' then m.`现金支付金额` else null end) `现金支付金额充电（元）`
from 
	(select a.order_code `订单编号`
	,b.product_id `商城兑换id`
	,a.user_id `会员id`
	,a.user_name `会员姓名`
--	,x.distinct_id
	,b.spu_name `兑换商品`
	,b.spu_id
	,b.sku_id
	,b.spu_bus_id
	,b.sku_code
	,b.sku_real_point `商品单价`
	,ifnull(ifnull(f2.fl,case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end)
	,CASE WHEN b.spu_type =51121001 THEN '精品'
		WHEN b.spu_type =51121002 THEN '生活服务' --第三方卡券`
		WHEN b.spu_type =51121003 THEN '售后养护' --保养类卡券
		WHEN b.spu_type =51121004 THEN '精品'
		WHEN b.spu_type =51121006 THEN '一件代发'
		WHEN b.spu_type =51121007 THEN '经销商端产品'
		WHEN b.spu_type =51121008 THEN '售后养护'   -- '车辆权益'
		ELSE null end) `fl`
,CASE b.spu_type
		WHEN 51121001 THEN '沃尔沃精品' 
		WHEN 51121002 THEN '第三方卡券' 
		WHEN 51121003 THEN '虚拟服务卡券' 
		WHEN 51121004 THEN '非沃尔沃精品'    -- 还会新增一个子分类
		WHEN 51121006 THEN '一件代发'
		WHEN 51121007 THEN '经销商端产品'
	    WHEN 51121008 THEN '虚拟服务权益'
	    ELSE null end `商品类型`
	,b.fee/100 `总金额`
	,b.coupon_fee/100 `优惠券抵扣金额`
	,round(b.point_amount/3+b.pay_fee/100,2) `实付金额`
	,round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额` -- 剔除优惠券
	,b.pay_fee/100 `现金支付金额`
	,b.point_amount `支付V值`
	,b.sku_num `兑换数量`
	,a.create_time as tt
	,case 
		when b.pay_fee=0 then '纯V值支付'
		when b.point_amount=0 then '纯现金支付' else '混合支付' end `支付方式`
	,f.name `分类`
	,CASE b.spu_type 
		WHEN 51121001 THEN 'VOLVO仓商品'
		WHEN 51121002 THEN 'VOLVO仓第三方卡券'
		WHEN 51121003 THEN '虚拟服务卡券'
		WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS `仓库`
	,CASE b.status
			WHEN 51301001 THEN '待付款'
			WHEN 51301002 THEN '待发货'
			WHEN 51301003 THEN '待收货'
			WHEN 51301004 THEN '收货确认'
			WHEN 51301005 THEN '退货中'
			WHEN 51301006 THEN '交易关闭' 
	END AS `商品状态`
	,CASE a.status
			WHEN 51031002 THEN '待付款'
			WHEN 51031003 THEN '待发货' 
			WHEN 51031004 THEN '待收货' 
			WHEN 51031005 THEN '已完成'
			WHEN 51031006 THEN '已关闭'  
	END AS `订单状态`
	,CASE a.close_reason 
	WHEN 51091003 THEN '用户退款' 
	WHEN 51091004 THEN '用户退货退款' 
	WHEN 51091005 THEN '商家退款' END AS `关闭原因`
	,e.`退货状态` `退货状态`
	,e.`退货数量` `退货数量`
	,e.`退回V值` `退回V值`
	,e.`退回时间` `退回时间`
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
			where m.member_status<>'60341003' 
			and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(a.user_id) = toString(h.id)   -- 会员表(获取会员信息)
	join (
			select distinct distinct_id
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-08-01' and a.`date` = '2024-08-25'
			and distinct_id not like '%#%'
			and length(a.distinct_id)<9
			and event = 'Page_entry'
			and page_title='8月会员日'
			and var_activity_name='2024年8月会员日'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(h.cust_id) 
	left join ods_good.ods_good_item_spu_d j on b.spu_id = j.id   -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_front_category_d f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
	left join
	(
		-- 获取前台分类[充电专区]的商品 
		select distinct j.id as spu_id ,
		j.name,
		f2.name as fl
		from ods_good.ods_good_item_spu_d j
		left join ods_good.ods_good_item_sku_d i on j.id =i.spu_id 
		left join ods_good.ods_good_item_sku_channel_d s on i.id =s.sku_id 
		left join ods_good.ods_good_front_category_d f2 on s.front_category1_id=f2.id
		where 1=1
		and f2.name='充电专区'
--		and j.is_deleted ='0' -- 该表该字段全为空
--		and i.is_deleted ='0' -- 该表该字段全为空
		and s.is_deleted ='0'
		and f2.is_deleted ='0'
	)f2 on f2.spu_id=b.spu_id
	left join(
	--	#V值退款成功记录
		select so.order_code
		,sp.product_id
		,CASE 
			WHEN so.status ='51171001' THEN '待审核'
			WHEN so.status ='51171002' THEN '待退货入库'
			WHEN so.status ='51171003' THEN '待退款'
			WHEN so.status ='51171004' THEN '退款成功'
			WHEN so.status ='51171005' THEN '退款失败'
			WHEN so.status ='51171006' THEN '作废退货单' END as `退货状态`
		,sum(sp.sales_return_num) `退货数量`
		,sum(so.refund_point) `退回V值`
		,max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code=sp.refund_order_code 
		where so.is_deleted = 0 
		and so.status='51171004' -- 退款成功
		and sp.is_deleted=0
		GROUP BY order_code,product_id,`退货状态`
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	where 1=1
	and toDate(a.create_time) = '2024-08-25' 
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
--	and j.front_category_id is not null
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = 10041002 -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
--	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
--	and e.order_code is null  -- 剔除退款订单
	order by a.create_time) m

——————————————————————————————————————————————————————二级页——集卡数据——————————————————————————————————————————————————————————————————————————————————————

--二级页PVUV
select count( distinct_id),
count(distinct distinct_id)
from dwd_23.dwd_23_gio_tracking a
where 1=1
and event_time > '2024-08-01' and a.`date` = '2024-08-25'
and distinct_id not like '%#%'
and length(a.distinct_id)<9
and event = 'Page_entry'
and page_title='2024会员日集卡兑好礼'
and var_activity_name='2024会员日集卡兑好礼'
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))

-- 当月集卡-车主/粉丝
select m.is_vehicle,
count(distinct c.member_id)
from ods_voam.ods_voam_activity_card_record_d c 
left join ods_voam.ods_voam_activity_card_d ca on c.activity_card_code=ca.activity_card_code 
join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) =toString(c.member_id)
where date(c.create_time)='2024-08-25'
group by is_vehicle
order by is_vehicle desc 

-- 累计获得卡片人数
select x.num,
count(distinct x.member_id) t
from 
	(
	-- 每位用户累计获取卡片数量
	select c.member_id,
	count(distinct activity_card_id) num 
	from ods_voam.ods_voam_activity_card_record_d c 
	left join ods_voam.ods_voam_activity_card_d ca on c.activity_card_code=ca.activity_card_code 
	where 1=1
	and date(c.create_time)<='2024-08-25'
	group by member_id
	order by member_id desc)x
group by num 
order by num

	
	
———————————————————————————————————————————————————————————活动页各btn活动数据——————————————————————————————————————————————————————————————————————————————

--App渠道 各btn点击
SELECT 
page_title ,
	btn_name,
	content_title,
	ifnull(count(usr_merged_gio_id),0) pv,
	ifnull(count(distinct usr_merged_gio_id),0) uv,
	ifnull(count(case when m.is_vehicle='1' then usr_merged_gio_id else null end),0) pv_cz,
	ifnull(count(distinct case when m.is_vehicle='1' then usr_merged_gio_id else null end ),0) uv_cz,
	ifnull(count(case when m.is_vehicle='0' then usr_merged_gio_id else null end),0) pv_fs,
	ifnull(count(distinct case when m.is_vehicle='0' then usr_merged_gio_id else null end ),0) uv_fs
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) =toString(a.memberid)
where 1=1
and event_time > '2024-08-01' 
and `date` = '2024-08-25'
and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel = 'App')
--and page_title='8月会员日'
and page_title in ('8月会员日','8月会员日二级页面')
--and var_activity_name='2024年8月会员日'
and event ='Button_click'
--and m.is_vehicle='1' -- 车主
--and m.is_vehicle='0' -- 粉丝
group by 1,2,3
order by 1,2,3

SELECT 
distinct page_title 
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) =toString(a.memberid)
where 1=1
and event_time > '2024-08-01' 
and `date` = '2024-08-25'
and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel = 'App')
--and page_title like '%8月会员日%'
and page_title in ('8月会员日','8月会员日二级页面')
--and var_activity_name in ('2024年8月会员日','2024年会员日组队活动')
and event ='Button_click'
group by 1
order by 1

--各btn点击 立即领取
SELECT 
m.level_id,
--	btn_name ,
--	content_title,
	ifnull(count(usr_merged_gio_id),0) pv_fx,
	ifnull(count(distinct usr_merged_gio_id ),0) uv_fx
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) =toString(a.memberid)
where 1=1
and event_time > '2024-08-01' and `date` = '2024-08-25'
and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel = 'App')
and page_title='8月会员日'
and var_activity_name='2024年8月会员日'
and event ='Button_click'
and m.is_vehicle='1' -- 车主
--and m.is_vehicle='0' -- 粉丝
and btn_name='立即领取'
group by 1
order by 1

--分享星愿数	
	select 
	btn_name ,
	ifnull(count(usr_merged_gio_id),0) pv_fx,
	ifnull(count(distinct usr_merged_gio_id ),0) uv_fx
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where 1=1
	and event='Button_click'
	and length(distinct_id)<9 
	and event_time > '2024-08-01' and `date` = '2024-08-25'
	and page_title ='8月会员日_一键领取优惠券弹窗'
	and (($lib in('iOS','Android','HarmonyOS') and left($client_version,1)='5') or channel ='App')
--	and is_bind=0
--	and var_is_bind in ('1','true')  -- 车主
	group by btn_name
	order by btn_name

-- 活动GMV
select 
m.`兑换商品`,
count(1) `订单量`,
SUM(m.`不含税的总金额`)
from 
	(select a.order_code `订单编号`
	,b.product_id `商城兑换id`
	,a.user_id `会员id`
	,a.user_name `会员姓名`
--	,x.distinct_id
	,b.spu_name `兑换商品`
	,b.spu_id
	,b.sku_id
	,b.spu_bus_id
	,b.sku_code
	,b.sku_real_point `商品单价`
	,ifnull(ifnull(f2.fl,case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end)
	,CASE WHEN b.spu_type =51121001 THEN '精品'
		WHEN b.spu_type =51121002 THEN '生活服务' --第三方卡券`
		WHEN b.spu_type =51121003 THEN '售后养护' --保养类卡券
		WHEN b.spu_type =51121004 THEN '精品'
		WHEN b.spu_type =51121006 THEN '一件代发'
		WHEN b.spu_type =51121007 THEN '经销商端产品'
		WHEN b.spu_type =51121008 THEN '售后养护'   -- '车辆权益'
		ELSE null end) `fl`
,CASE b.spu_type
		WHEN 51121001 THEN '沃尔沃精品' 
		WHEN 51121002 THEN '第三方卡券' 
		WHEN 51121003 THEN '虚拟服务卡券' 
		WHEN 51121004 THEN '非沃尔沃精品'    -- 还会新增一个子分类
		WHEN 51121006 THEN '一件代发'
		WHEN 51121007 THEN '经销商端产品'
	    WHEN 51121008 THEN '虚拟服务权益'
	    ELSE null end `商品类型`
	,b.fee/100 `总金额`
	,b.coupon_fee/100 `优惠券抵扣金额`
	,round(b.point_amount/3+b.pay_fee/100,2) `实付金额`
	,round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额` -- 剔除优惠券
	,b.pay_fee/100 `现金支付金额`
	,b.point_amount `支付V值`
	,b.sku_num `兑换数量`
	,a.create_time as tt
	,case 
		when b.pay_fee=0 then '纯V值支付'
		when b.point_amount=0 then '纯现金支付' else '混合支付' end `支付方式`
	,f.name `分类`
	,CASE b.spu_type 
		WHEN 51121001 THEN 'VOLVO仓商品'
		WHEN 51121002 THEN 'VOLVO仓第三方卡券'
		WHEN 51121003 THEN '虚拟服务卡券'
		WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS `仓库`
	,CASE b.status
			WHEN 51301001 THEN '待付款'
			WHEN 51301002 THEN '待发货'
			WHEN 51301003 THEN '待收货'
			WHEN 51301004 THEN '收货确认'
			WHEN 51301005 THEN '退货中'
			WHEN 51301006 THEN '交易关闭' 
	END AS `商品状态`
	,CASE a.status
			WHEN 51031002 THEN '待付款'
			WHEN 51031003 THEN '待发货' 
			WHEN 51031004 THEN '待收货' 
			WHEN 51031005 THEN '已完成'
			WHEN 51031006 THEN '已关闭'  
	END AS `订单状态`
	,CASE a.close_reason 
	WHEN 51091003 THEN '用户退款' 
	WHEN 51091004 THEN '用户退货退款' 
	WHEN 51091005 THEN '商家退款' END AS `关闭原因`
	,e.`退货状态` `退货状态`
	,e.`退货数量` `退货数量`
	,e.`退回V值` `退回V值`
	,e.`退回时间` `退回时间`
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
			where m.member_status<>'60341003' 
			and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(a.user_id) = toString(h.id)   -- 会员表(获取会员信息)
	left join ods_good.ods_good_item_spu_d j on b.spu_id = j.id   -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_front_category_d f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
	left join
	(
		-- 获取前台分类[充电专区]的商品 
		select distinct j.id as spu_id ,
		j.name,
		f2.name as fl
		from ods_good.ods_good_item_spu_d j
		left join ods_good.ods_good_item_sku_d i on j.id =i.spu_id 
		left join ods_good.ods_good_item_sku_channel_d s on i.id =s.sku_id 
		left join ods_good.ods_good_front_category_d f2 on s.front_category1_id=f2.id
		where 1=1
		and f2.name='充电专区'
--		and j.is_deleted ='0' -- 该表该字段全为空
--		and i.is_deleted ='0' -- 该表该字段全为空
		and s.is_deleted ='0'
		and f2.is_deleted ='0'
	)f2 on f2.spu_id=b.spu_id
	left join(
	--	#V值退款成功记录
		select so.order_code
		,sp.product_id
		,CASE 
			WHEN so.status ='51171001' THEN '待审核'
			WHEN so.status ='51171002' THEN '待退货入库'
			WHEN so.status ='51171003' THEN '待退款'
			WHEN so.status ='51171004' THEN '退款成功'
			WHEN so.status ='51171005' THEN '退款失败'
			WHEN so.status ='51171006' THEN '作废退货单' END as `退货状态`
		,sum(sp.sales_return_num) `退货数量`
		,sum(so.refund_point) `退回V值`
		,max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code=sp.refund_order_code 
		where so.is_deleted = 0 
		and so.status='51171004' -- 退款成功
		and sp.is_deleted=0
		GROUP BY order_code,product_id,`退货状态`
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	where 1=1
	and toDate(a.create_time) = '2024-08-25' 
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
--	and j.front_category_id is not null
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = 10041002 -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
--	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
--	and e.order_code is null  -- 剔除退款订单
--	and h.is_vehicle=1
	and h.is_vehicle=0
	and b.spu_id in ('3155',
'3631',
'3161',
'3638',
'3160',
'3301')
	order by a.create_time) m
group by 1
order by 1



——————————————————————————————————————————————————————————分时段&分渠道数据————————————————————————————————————————————————————————————————————————————————————

--分时段二级页PVUV
select 
date_trunc('hour',toDateTime(left(a.time,19))) t,
	ifnull(count(usr_merged_gio_id),0) pv_fx,
	ifnull(count(distinct usr_merged_gio_id ),0) uv_fx
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
where 1=1
and event_time>'2024-08-01'
and a.date = '2024-08-25'
and event = 'Page_entry'
and page_title='8月会员日'
and var_activity_name='2024年8月会员日'
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
group by ROLLUP(t)
order by t

------------------------------------------任务--------------------------------------------

-- 完成守护计划答题
SELECT count(distinct member_id) 
FROM ods_mms.ods_mms_task_record_d mms
WHERE mms.task_id = '89'-- 视频答题
and date(date_create) = '2024-08-25'

-- 完成进入圈子任务
SELECT count(distinct member_id) 
FROM ods_mms.ods_mms_task_record_d mms
WHERE mms.task_id = '90'  -- 加圈
and date(date_create) = '2024-08-25'

--参与打卡人数（去重）
select count(distinct member_id)
from ods_dmoa.ods_dmoa_tm_onlineactivity_event_record_d a
where a.event_code ='sign'
and a.is_deleted =0
and date(a.create_time) ='2024-08-25'
--order by 1 

________________________________________________________组队通关二级页______________________________________________________

--_组队通关二级页
SELECT 
	ifnull(count(usr_merged_gio_id),0) pv_fx,
	ifnull(count(distinct usr_merged_gio_id ),0) uv_fx
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) =toString(a.memberid)
where 1=1
and event_time > '2024-08-01' 
and `date` = '2024-08-25'
and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel = 'App')
--and m.is_vehicle='1' -- 车主
--and m.is_vehicle='0' -- 粉丝
--and page_title='8月会员日'
and page_title ='8月会员日二级页面'
--and var_activity_name='2024年8月会员日'
--and var_activity_name in ('2024年8月会员日','2024年会员日组队活动')
and event ='Page_entry'
	
-- 组队明细
select a.member_id`A-memberID（组队发起人）` ,
m.is_vehicle`A-是否车主`,
a.related_member_id`B-memberID（接受组队邀请成功）`,
m2.is_vehicle`B-是否车主`,
a.update_time `组队成功时间`,
--    business_code,
case when JSONExtract(business_code, 't1', 'String')='2'then '是' else '否' end `是否完成任务一`,
case when JSONExtract(business_code, 't2', 'String')='1'then '是' else '否' end `是否完成任务二`,
case when JSONExtract(business_code, 't3', 'String')='1'then '是' else '否' end `是否完成任务三`
--JSONExtract(business_code, 't2', 'String')`是否完成任务二`,
--JSONExtract(business_code, 't3', 'String')`是否完成任务三`
from ods_dmoa.ods_dmoa_tm_onlineactivity_event_record_d a
left join ods_memb.ods_memb_tc_member_info_cur m on m.id=a.member_id 
left join ods_memb.ods_memb_tc_member_info_cur m2 on m2.id=a.related_member_id 
where a.event_code ='group'
and a.is_deleted =0
and a.create_time >='2024-08-25'
order by 1 

-- 组队结果
SELECT count(DISTINCT x.`A-memberID（组队发起人）`),
count(case when x.`是否完成任务一`='2' then 1 end ),
count(case when x.`是否完成任务二`='1' then 1 end ),
count(case when x.`是否完成任务三`='1' then 1 end )
FROM 
(
select a.member_id`A-memberID（组队发起人）` ,
m.is_vehicle`A-是否车主`,
a.related_member_id`B-memberID（接受组队邀请成功）`,
m2.is_vehicle`B-是否车主`,
a.update_time `组队成功时间`,
--    business_code,
JSONExtract(business_code, 't1', 'String')`是否完成任务一`,
JSONExtract(business_code, 't2', 'String')`是否完成任务二`,
JSONExtract(business_code, 't3', 'String')`是否完成任务三`
from ods_dmoa.ods_dmoa_tm_onlineactivity_event_record_d a
left join ods_memb.ods_memb_tc_member_info_cur m on m.id=a.member_id 
left join ods_memb.ods_memb_tc_member_info_cur m2 on m2.id=a.related_member_id 
where a.event_code ='group'
and a.is_deleted =0
and date(a.create_time) ='2024-07-25'
order by 5 desc 
)x



-- 副本二级页推荐购邀约明细
-- 邀请试驾线索量
SELECT  
distinct 
	tir.invite_code `邀约code` ,
	tir.invite_member_id `邀请人会员ID`,
	case when m.is_vehicle =1 then '车主' else '粉丝' end as `邀请人身份（是否车主）`,
	m.member_phone `邀请人手机号`,
	tir.create_time `邀约时间`,
	tir.be_invite_member_id `被邀请人会员ID`,
	tir.be_invite_mobile `被邀请人手机号`,
	tir.reserve_time `留资时间`,
	tir.vehicle_name `留资车型`,
	case when tir.drive_time<'2000-01-01' then '未试驾' else '已试驾' end `是否试驾`,
	case when toDate(x2.created_at)>=toDate(tir.reserve_time) then '是' else '否' end `是否购车`
from ods_invi.ods_invi_tm_invite_record_d tir 
left join ods_memb.ods_memb_tc_member_info_cur m on toString(tir.invite_member_id)=toString(m.id)  
join (
-- 组队成功
	select 
	m.cust_id distinct_id,
	a.member_id`A-memberID（组队发起人）` ,
	m.is_vehicle`A-是否车主`,
	a.related_member_id`B-memberID（接受组队邀请成功）`,
	m2.is_vehicle`B-是否车主`,
	a.update_time `组队成功时间`,
	--    business_code,
	JSONExtract(business_code, 't1', 'String')`是否完成任务一`,
	JSONExtract(business_code, 't2', 'String')`是否完成任务二`,
	JSONExtract(business_code, 't3', 'String')`是否完成任务三`
	from ods_dmoa.ods_dmoa_tm_onlineactivity_event_record_d a
	left join ods_memb.ods_memb_tc_member_info_cur m on m.id=a.member_id 
	left join ods_memb.ods_memb_tc_member_info_cur m2 on m2.id=a.related_member_id 
	where a.event_code ='group'
	and a.is_deleted =0
	order by 1 
)x on toString(x.distinct_id) =toString(m.cust_id) 
left join (	
	--购车人员手机号
	select
	a.phone_num,max(a.created_at) created_at
	from
	(
		select
		o.customer_tel phone_num,
		o.created_at
		from  ods_cydr.ods_cydr_tt_sales_orders_cur o
		where 1=1
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
		and o.is_deleted  = 0
		UNION ALL  
		select
		o.drawer_tel phone_num,
		o.created_at
		from  ods_cydr.ods_cydr_tt_sales_orders_cur o
		where 1=1
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
		and o.is_deleted  = 0
		UNION ALL  
		select
		o.purchase_phone phone_num,
		o.created_at
		from  ods_cydr.ods_cydr_tt_sales_orders_cur o
		where 1=1
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
		and o.is_deleted  = 0
	) a
	where length(a.phone_num) = '11'
	and left(a.phone_num,1) = '1'
	group by 1
)x2 on x2.phone_num=tir.be_invite_mobile 
where tir.is_deleted=0
and date(tir.create_time)= '2024-08-25'
and tir.be_invite_member_id is not null 



--通过渠道点位进入活动页总数 
	SELECT 
--	m.is_vehicle is_vehicle,
--	var_promotion_channel_type,
--	var_promotion_channel_sub_type,
	var_promotion_methods,
--	var_promotion_activity,
--	var_promotion_supplement,
	count(case when m.is_vehicle='1' then usr_merged_gio_id else null end) pv_cz,
	count(distinct case when m.is_vehicle='1' then usr_merged_gio_id else null end) uv_cz,
	count(case when m.is_vehicle='0' then usr_merged_gio_id else null end) pv_fs,
	count(distinct case when m.is_vehicle='0' then usr_merged_gio_id else null end) uv_fs,
	count(usr_merged_gio_id) pv,
	count(distinct usr_merged_gio_id) uv
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) =toString(a.memberid)
	where 1=1
	and event_time >'2024-08-01' 
	and date ='2024-08-25' 
	and page_title='8月会员日'
	and var_activity_name='2024年8月会员日'
	and event ='Page_entry'
	and var_promotion_channel_type in ('app','sms')
	and var_promotion_supplement in ('3x23599o17s',
	'0v236090a14o',
	'2d238747s61j',
	'1e236276p67a',
	'0b236371l97q',
	'4p236453h39n',
	'4q238617c37c',
	'8q236655c99j')
	group by 1
	order by 1

--通过渠道点位首次进入活动页 
select 	
--	m.is_vehicle is_vehicle,
--	var_promotion_channel_type,
--	var_promotion_channel_sub_type,
	var_promotion_methods,
--	var_promotion_activity,
--	var_promotion_supplement,
	count(case when is_vehicle='1' then usr_merged_gio_id else null end) pv_cz,
	count(distinct case when is_vehicle='1' then usr_merged_gio_id else null end) uv_cz,
	count(case when is_vehicle='0' then usr_merged_gio_id else null end) pv_fs,
	count(distinct case when is_vehicle='0' then usr_merged_gio_id else null end) uv_fs,
	count(usr_merged_gio_id) pv,
	count(distinct usr_merged_gio_id) uv
from 
(
	SELECT 
	var_promotion_channel_type,
	var_promotion_channel_sub_type,
	var_promotion_methods,
	var_promotion_activity,
	var_promotion_supplement,
	usr_merged_gio_id ,
	m.is_vehicle is_vehicle,
	row_number()over(partition by usr_merged_gio_id order by time desc) rk 
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) =toString(a.memberid)
	where 1=1
	and event_time >'2024-08-01' 
	and date ='2024-08-25' 
	and page_title='8月会员日'
	and var_activity_name='2024年8月会员日'
	and event ='Page_entry'
	and var_promotion_supplement in ('3x23599o17s',
'0v236090a14o',
'2d238747s61j',
'1e236276p67a',
'0b236371l97q',
'4p236453h39n',
'4q238617c37c',
'8q236655c99j')
--	and var_promotion_activity='240717_vipday'
--	and m.is_vehicle='1'
--	and m.is_vehicle='0'
	and var_promotion_channel_type in ('app','sms')
)x where x.rk=1
group by 1
order by 1

	



--活动期间经销商code的pv、uv
SELECT 
	var_promotion_channel_sub_type,
	count(usr_merged_gio_id) pv,
	count(distinct usr_merged_gio_id) uv
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
where 1=1
and event_time>'2024-08-01' 
and date ='2024-08-25' 
and event='Page_entry'
and page_title='8月会员日'
and var_activity_name='2024年8月会员日'
--and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` ='MiniProgram' or channel ='Mini'))
and `$url` like '%promotion_channel_type=dealer%'
group by var_promotion_channel_sub_type
order by uv desc







——————————————————————————————————————————————————————————————————优惠券核销&商城售卖情况————————————————————————————————————————————————————————————————————————————

-- 优惠券核销情况
	select 
	x.卡券名称,
	x.卡券状态,
	concat(x.coupon_id,x.卡券状态) 状态合计,
	count(case when x.IS_VEHICLE=1 then x.id else null end) 车主,
	count(case when x.IS_VEHICLE=0 then x.id else null end) 粉丝,
	count(x.id) 合计,
	sum(x.实付金额) 核销订单金额,
	sum(x.优惠券抵扣金额) 卡券抵扣金额,
	sum(x.总金额) `核销订单金额（券前）`,
	sum(x.实付金额)  `核销订单金额（券后）`
	from (
	SELECT 
		a.id,
	 	a.coupon_source,
	    b.coupon_name 卡券名称,
	    b.id coupon_id,
	    a.left_value/100 面额,
	    b.coupon_code 券号,
	    coalesce(a.member_id,tmi1.id) 沃世界会员ID,
	    coalesce(tmi.MEMBER_NAME,tmi1.MEMBER_NAME) 会员昵称,
	    coalesce(tmi.real_name,tmi1.real_name) 姓名,
	    coalesce(tmi.MEMBER_PHONE,tmi1.MEMBER_PHONE) 沃世界绑定手机号,
	    coalesce(tmi.is_vehicle,tmi1.is_vehicle) is_vehicle,
	    t.associate_vin 购买关联VIN,
	    declear_list.company_code 经销商code,
	    t.associate_dealer 购买关联经销商,
	    a.get_date 获得时间,
	    a.activate_date 激活时间,
	    a.expiration_date 卡券失效日期,
	    CAST(a.exchange_code as varchar) 核销码,
	    CASE a.ticket_state
	        WHEN 31061001 THEN '已领用'
		    WHEN 31061002 THEN '已锁定'
		    WHEN 31061003 THEN '已核销' 
		    WHEN 31061004 THEN '已失效'
		    WHEN 31061005 THEN '已作废'
		END AS 卡券状态,
		v.*
	FROM coupon.tt_coupon_detail a  -- 卡券信息表
	JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
	left join `member`.tc_member_info tmi on a.member_id = tmi.id and tmi.is_deleted=0-- 会员表
	left join (
		select tmi.*
			,row_number ()over(partition by tmi.cust_id order by tmi.create_time desc ) rk
		from `member`.tc_member_info tmi 
		where tmi.is_deleted = 0
		) tmi1 on tmi1.cust_id=a.one_id and tmi1.rk=1
	left join (
		select	t.*,sk.coupon_id
		from `order`.tt_order_product t
		inner join goods.item_sku sk
		on t.sku_id =sk.id and sk.is_deleted =0 and sk.sku_status =1
	) t 
	on a.order_code = t.order_code and a.coupon_id= t.coupon_id -- 商品购买关联经销商，Vin
	left join (--获取关联经销商名称
		select company_code,code_name,row_number() over(partition by code_name order by bz) as bz
	    from (
	        (select company_code ,company_short_name_cn as code_name,'1' as bz
	        from organization.tm_company
	        where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and company_short_name_cn is not null )
	        union all 
	        select company_code,official_dealer_name as code_name,'2' as bz
	        from organization.tm_company
	        where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and official_dealer_name is not null and official_dealer_name<>''
	        )
	) declear_list
	on declear_list.code_name = t.associate_dealer and declear_list.bz='1'
	LEFT JOIN (--获取卡券核销信息
		select 
		distinct 
			v.coupon_detail_id
			,v.customer_name 核销用户名
			,v.customer_mobile 核销手机号
			,v.verify_amount 
			,v.dealer_code 核销经销商
			,v.vin 核销VIN
			,v.operate_date 核销时间
			,v.order_no 订单号
			,v.PLATE_NUMBER
			,b.fee/100 总金额
			,b.coupon_fee/100 优惠券抵扣金额
			,round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) 不含税的总金额
			,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
			,b.pay_fee/100 现金支付金额
		from coupon.tt_coupon_verify v  -- 卡券核销信息表
		left join "order".tt_order_product b on v.order_no =b.order_code and v.is_deleted <>1
		left join "order".tt_order a on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表 -- 订单主表 
		where  v.is_deleted=0
		and b.fee/100 is not null 
		order by v.create_time 
	) v ON v.coupon_detail_id = a.id
	where 1=1
	and date(a.get_date)= '2024-08-25'
	and a.is_deleted=0 
	and a.coupon_id in ('7520',
		'7524',
		'7523',
		'7522',
		'7521',
		'7525',
		'7526',
		'7527'
		)
	order by 12
	) x
	where x.卡券状态='已领用' or x.卡券状态='已核销'
	group by 1,2
	order by 1,2 desc 


-- 会员日商品 销售
select 
m.`兑换商品` sp,
m.spu_id spid,
sum(m.`兑换数量`) `12/25-1/24月销量`
from 
	(select a.order_code `订单编号`
	,b.product_id `商城兑换id`
	,a.user_id `会员id`
	,a.user_name `会员姓名`
	,b.spu_name `兑换商品`
	,b.spu_id spu_id
	,b.sku_id
	,b.spu_bus_id
	,b.sku_code
	,b.sku_real_point `商品单价`
	,ifnull(ifnull(f2.fl,case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end)
	,CASE WHEN b.spu_type =51121001 THEN '精品'
		WHEN b.spu_type =51121002 THEN '生活服务' --第三方卡券`
		WHEN b.spu_type =51121003 THEN '售后养护' --保养类卡券
		WHEN b.spu_type =51121004 THEN '精品'
		WHEN b.spu_type =51121006 THEN '一件代发'
		WHEN b.spu_type =51121007 THEN '经销商端产品'
		WHEN b.spu_type =51121008 THEN '售后养护'   -- '车辆权益'
		ELSE null end) `fl`
,CASE b.spu_type
		WHEN 51121001 THEN '沃尔沃精品' 
		WHEN 51121002 THEN '第三方卡券' 
		WHEN 51121003 THEN '虚拟服务卡券' 
		WHEN 51121004 THEN '非沃尔沃精品'    -- 还会新增一个子分类
		WHEN 51121006 THEN '一件代发'
		WHEN 51121007 THEN '经销商端产品'
	    WHEN 51121008 THEN '虚拟服务权益'
	    ELSE null end `商品类型`
	,b.fee/100 `总金额`
	,b.coupon_fee/100 `优惠券抵扣金额`
	,round(b.point_amount/3+b.pay_fee/100,2) `实付金额`
	,b.pay_fee/100 `现金支付金额`
	,b.point_amount `支付V值`
	,b.sku_num `兑换数量`
	,a.create_time as tt
	,case 
		when b.pay_fee=0 then '纯V值支付'
		when b.point_amount=0 then '纯现金支付' else '混合支付' end `支付方式`
	,f.name `分类`
	,CASE b.spu_type 
		WHEN 51121001 THEN 'VOLVO仓商品'
		WHEN 51121002 THEN 'VOLVO仓第三方卡券'
		WHEN 51121003 THEN '虚拟服务卡券'
		WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS `仓库`
	,CASE b.status
			WHEN 51301001 THEN '待付款'
			WHEN 51301002 THEN '待发货'
			WHEN 51301003 THEN '待收货'
			WHEN 51301004 THEN '收货确认'
			WHEN 51301005 THEN '退货中'
			WHEN 51301006 THEN '交易关闭' 
	END AS `商品状态`
	,CASE a.status
			WHEN 51031002 THEN '待付款'
			WHEN 51031003 THEN '待发货' 
			WHEN 51031004 THEN '待收货' 
			WHEN 51031005 THEN '已完成'
			WHEN 51031006 THEN '已关闭'  
	END AS `订单状态`
	,CASE a.close_reason 
	WHEN 51091003 THEN '用户退款' 
	WHEN 51091004 THEN '用户退货退款' 
	WHEN 51091005 THEN '商家退款' END AS `关闭原因`
	,e.`退货状态` `退货状态`
	,e.`退货数量` `退货数量`
	,e.`退回V值` `退回V值`
	,e.`退回时间` `退回时间`
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
	join (
			select distinct distinct_id
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-08-01' and a.`date` = '2024-08-25'
			and distinct_id not like '%#%'
			and length(a.distinct_id)<9
			and event = 'Page_entry'
			and page_title='8月会员日'
			and var_activity_name='2024年8月会员日'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(h.cust_id) 
	left join ods_good.ods_good_item_spu_d j on b.spu_id = j.id   -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_front_category_d f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
	left join
	(
		-- 获取前台分类[充电专区]的商品 
		select distinct j.id as spu_id ,
		j.name,
		f2.name as fl
		from ods_good.ods_good_item_spu_d j
		left join ods_good.ods_good_item_sku_d i on j.id =i.spu_id 
		left join ods_good.ods_good_item_sku_channel_d s on i.id =s.sku_id 
		left join ods_good.ods_good_front_category_d f2 on s.front_category1_id=f2.id
		where 1=1
		and f2.name='充电专区'
--		and j.is_deleted ='0' -- 该表该字段全为空
--		and i.is_deleted ='0' -- 该表该字段全为空
		and s.is_deleted ='0'
		and f2.is_deleted ='0'
	)f2 on f2.spu_id=b.spu_id
	left join(
	--	#V值退款成功记录
		select so.order_code
		,sp.product_id
		,CASE 
			WHEN so.status ='51171001' THEN '待审核'
			WHEN so.status ='51171002' THEN '待退货入库'
			WHEN so.status ='51171003' THEN '待退款'
			WHEN so.status ='51171004' THEN '退款成功'
			WHEN so.status ='51171005' THEN '退款失败'
			WHEN so.status ='51171006' THEN '作废退货单' END as `退货状态`
		,sum(sp.sales_return_num) `退货数量`
		,sum(so.refund_point) `退回V值`
		,max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code=sp.refund_order_code 
		where so.is_deleted = 0 
		and so.status='51171004' -- 退款成功
		and sp.is_deleted=0
		GROUP BY order_code,product_id,`退货状态`
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	where 1=1
	and toDate(a.create_time) >='2024-03-25' 
	and toDate(a.create_time) <'2024-08-25' 
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and b.is_deleted <> 1
	and h.is_deleted <> 1
--	and j.front_category_id is not null
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = 10041002 -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
--	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
--	and e.order_code is null  -- 剔除退款订单
	and b.spu_id in ('3582',
'3143',
'3681',
'3776',
'3778',
'3791',
'3211',
'3215',
'3214')
	order by a.create_time) m
	group by sp,spid
	order by sp,spid


-- 会员日活动销量
select 
m.spu_id sp,
sum(m.`兑换数量`) `销量`,
sum(m.`总金额`) `订单金额`,
sum(m.`现金支付金额`) `实付现金金额`,
sum(m.`现金支付金额`)/sum(m.`总金额`) `实付现金比`
from 
	(select a.order_code `订单编号`
	,b.product_id `商城兑换id`
	,a.user_id `会员id`
	,a.user_name `会员姓名`
	,b.spu_name `兑换商品`
	,b.spu_id spu_id
	,b.sku_id
	,b.spu_bus_id
	,b.sku_code
	,b.sku_real_point `商品单价`
	,ifnull(ifnull(f2.fl,case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end)
	,CASE WHEN b.spu_type =51121001 THEN '精品'
		WHEN b.spu_type =51121002 THEN '生活服务' --第三方卡券`
		WHEN b.spu_type =51121003 THEN '售后养护' --保养类卡券
		WHEN b.spu_type =51121004 THEN '精品'
		WHEN b.spu_type =51121006 THEN '一件代发'
		WHEN b.spu_type =51121007 THEN '经销商端产品'
		WHEN b.spu_type =51121008 THEN '售后养护'   -- '车辆权益'
		ELSE null end) `fl`
,CASE b.spu_type
		WHEN 51121001 THEN '沃尔沃精品' 
		WHEN 51121002 THEN '第三方卡券' 
		WHEN 51121003 THEN '虚拟服务卡券' 
		WHEN 51121004 THEN '非沃尔沃精品'    -- 还会新增一个子分类
		WHEN 51121006 THEN '一件代发'
		WHEN 51121007 THEN '经销商端产品'
	    WHEN 51121008 THEN '虚拟服务权益'
	    ELSE null end `商品类型`
	,b.fee/100 `总金额`
	,b.coupon_fee/100 `优惠券抵扣金额`
	,round(b.point_amount/3+b.pay_fee/100,2) `实付金额`
	,b.pay_fee/100 `现金支付金额`
	,b.point_amount `支付V值`
	,b.sku_num `兑换数量`
	,a.create_time as tt
	,case 
		when b.pay_fee=0 then '纯V值支付'
		when b.point_amount=0 then '纯现金支付' else '混合支付' end `支付方式`
	,f.name `分类`
	,CASE b.spu_type 
		WHEN 51121001 THEN 'VOLVO仓商品'
		WHEN 51121002 THEN 'VOLVO仓第三方卡券'
		WHEN 51121003 THEN '虚拟服务卡券'
		WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS `仓库`
	,CASE b.status
			WHEN 51301001 THEN '待付款'
			WHEN 51301002 THEN '待发货'
			WHEN 51301003 THEN '待收货'
			WHEN 51301004 THEN '收货确认'
			WHEN 51301005 THEN '退货中'
			WHEN 51301006 THEN '交易关闭' 
	END AS `商品状态`
	,CASE a.status
			WHEN 51031002 THEN '待付款'
			WHEN 51031003 THEN '待发货' 
			WHEN 51031004 THEN '待收货' 
			WHEN 51031005 THEN '已完成'
			WHEN 51031006 THEN '已关闭'  
	END AS `订单状态`
	,CASE a.close_reason 
	WHEN 51091003 THEN '用户退款' 
	WHEN 51091004 THEN '用户退货退款' 
	WHEN 51091005 THEN '商家退款' END AS `关闭原因`
	,e.`退货状态` `退货状态`
	,e.`退货数量` `退货数量`
	,e.`退回V值` `退回V值`
	,e.`退回时间` `退回时间`
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
	left join ods_good.ods_good_item_spu_d j on b.spu_id = j.id   -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_front_category_d f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
	left join
	(
		-- 获取前台分类[充电专区]的商品 
		select distinct j.id as spu_id ,
		j.name,
		f2.name as fl
		from ods_good.ods_good_item_spu_d j
		left join ods_good.ods_good_item_sku_d i on j.id =i.spu_id 
		left join ods_good.ods_good_item_sku_channel_d s on i.id =s.sku_id 
		left join ods_good.ods_good_front_category_d f2 on s.front_category1_id=f2.id
		where 1=1
		and f2.name='充电专区'
--		and j.is_deleted ='0' -- 该表该字段全为空
--		and i.is_deleted ='0' -- 该表该字段全为空
		and s.is_deleted ='0'
		and f2.is_deleted ='0'
	)f2 on f2.spu_id=b.spu_id
	left join(
	--	#V值退款成功记录
		select so.order_code
		,sp.product_id
		,CASE 
			WHEN so.status ='51171001' THEN '待审核'
			WHEN so.status ='51171002' THEN '待退货入库'
			WHEN so.status ='51171003' THEN '待退款'
			WHEN so.status ='51171004' THEN '退款成功'
			WHEN so.status ='51171005' THEN '退款失败'
			WHEN so.status ='51171006' THEN '作废退货单' END as `退货状态`
		,sum(sp.sales_return_num) `退货数量`
		,sum(so.refund_point) `退回V值`
		,max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code=sp.refund_order_code 
		where so.is_deleted = 0 
		and so.status='51171004' -- 退款成功
		and sp.is_deleted=0
		GROUP BY order_code,product_id,`退货状态`
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	where 1=1
--	and toDate(a.create_time) >= '2023-12-25' 
	and toDate(a.create_time) = '2024-08-25' 
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and b.is_deleted <> 1
	and h.is_deleted <> 1
--	and j.front_category_id is not null
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = 10041002 -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
--	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
--	and e.order_code is null  -- 剔除退款订单
	and b.spu_id in ('3582',
'3143',
'3681',
'3776',
'3778',
'3791',
'3211',
'3215',
'3214')
	order by a.create_time) m
	group by sp 
	order by sp
	
——————————————————————————————————————————————————————————————————抽奖明细————————————————————————————————————————————————————————————————————————

-- 车主粉丝奖池抽走数量
select x.奖池名称,
count(1)
from 
	(
	select
	a.member_id,
	a.nick_name 姓名,
	case when d.is_vehicle =1 then '是' 
		 when d.is_vehicle =0 then '否' 
		 end as 是否车主,
	case when d.level_id=1 then '银卡'
		 when d.level_id=2 then '金卡'
		 when d.level_id=3 then '白金卡'
		 when d.level_id=4 then '黑卡'
		 end as 会员等级,
	d.MEMBER_PHONE 沃世界注册手机号,
	case when a.have_win = '1' then '中奖'
		when a.have_win = '0' then '未中奖'
		end 是否中奖,
	case when a.have_send = '1' then '已发放'
		when a.have_send = '0' then '未发放'
		end 奖品是否发放,
	a.create_time 抽奖时间,
	b.prize_name 中奖奖品,
	b.prize_level_nick_name 奖品等级,
	hour(a.create_time)  时段,
	a.lottery_play_code 抽奖code,
	lpi.lottery_play_name 奖池名称,
	case
		when d.level_id=1 then '银卡'
		when d.level_id>=2 then '金卡及以上'
	end as 会员等级2
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	left join volvo_online_activity_module.lottery_play_init lpi on lpi.lottery_play_code =a.lottery_play_code 
	left join `member`.tc_member_info d on a.member_id = d.ID
	where 1=1
	and a.lottery_code like '%memberday-2408%'  -- 当月会员日code
	and date(a.create_time)='2024-08-25'
	and a.have_win = 1   -- 中奖
	and b.is_deleted=0
	--and prize_name like '%2024%'
	order by a.create_time
)x group by 1
order by 1 desc 

select *
from volvo_online_activity_module.lottery_draw_log a
where date(a.create_time)='2024-08-25'

-- 13、抽奖V值消耗
select
SUM(r.INTEGRAL)抽奖消耗V值,
count(distinct r.member_id)
from member.tt_member_flow_record r 
where r.EVENT_DESC like '%沃尔沃会员日抽奖抵扣v值%'
and date(r.CREATE_TIME) = '2024-08-25'
order by 1

-- 12、人均抽奖次数
select
 COUNT(a.member_id)抽奖次数,
-- COUNT(DISTINCT a.member_id)抽奖人数,
ROUND(COUNT(a.member_id)/COUNT(DISTINCT a.member_id),2) 人均抽奖次数
from volvo_online_activity_module.lottery_draw_log a
left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
where 1=1
and a.lottery_code like '%memberday-2408%'  -- 当月会员日code
--and a.lottery_play_code like 'member_day_2024%'  -- 当会员日code



-- 抽奖明细
	select
	a.member_id,
	d.create_time 注册时间,
	a.nick_name 姓名,
	case when d.is_vehicle =1 then '是' 
		 when d.is_vehicle =0 then '否' 
		 end as 是否车主,
	case when d.level_id=1 then '银卡'
		 when d.level_id=2 then '金卡'
		 when d.level_id=3 then '白金卡'
		 when d.level_id=4 then '黑卡'
		 end as 会员等级,
	d.MEMBER_PHONE 沃世界注册手机号,
	case when a.have_win = '1' then '中奖'
		when a.have_win = '0' then '未中奖'
		end 是否中奖,
	case when a.have_send = '1' then '已发放'
		when a.have_send = '0' then '未发放'
		end 奖品是否发放,
	a.create_time 抽奖时间,
	b.prize_name 中奖奖品,
	b.prize_level_nick_name 奖品等级,
	hour(a.create_time)  时段,
	a.lottery_play_code 抽奖code,
	lpi.lottery_play_name 奖池名称,
	case
		when d.level_id=1 then '银卡'
		when d.level_id>=2 then '金卡及以上'
	end as 会员等级2
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	left join volvo_online_activity_module.lottery_play_init lpi on lpi.lottery_play_code =a.lottery_play_code 
	left join `member`.tc_member_info d on a.member_id = d.ID
	where a.lottery_code like '%memberday-2408%'  -- 当月会员日code
	and date(a.create_time)='2024-08-25'
	and a.have_win = 1   -- 中奖
	--and prize_name like '%2024%'
	order by a.create_time


——————————————————————————————————————————————————————明细 邀请试驾 预约试驾名单 充电订单 养修预约名单————————————————————————————————————————————————————————

-- 邀请试驾线索量
SELECT  
distinct 
	tir.invite_code `邀约code` ,
	tir.invite_member_id `邀请人会员ID`,
	m.member_phone `邀请人手机号`,
	tir.create_time `邀约时间`,
	tir.be_invite_member_id `被邀请人会员ID`,
	tir.be_invite_mobile `被邀请人手机号`,
	tir.reserve_time `留资时间`,
	tir.vehicle_name `留资车型`,
	tir.drive_time `实际试驾时间`
from ods_invi.ods_invi_tm_invite_record_d tir 
left join ods_memb.ods_memb_tc_member_info_cur m on toString(tir.invite_member_id)=toString(m.id)  
join (
	select distinct distinct_id
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and event_time > '2024-08-01' and a.`date` = '2024-08-25'
	and distinct_id not like '%#%'
	and length(a.distinct_id)<9
	and event = 'Page_entry'
	and page_title='8月会员日'
	and var_activity_name='2024年8月会员日'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
)x on toString(x.distinct_id) =toString(m.cust_id) 
where tir.is_deleted=0
and date(tir.create_time)= '2024-08-25'
and tir.be_invite_member_id is not null 

-- 邀约试驾2023年12月
SELECT  
distinct 
	tir.invite_code `邀约code` ,
	tir.invite_member_id `邀请人会员ID`,
	m.member_phone `邀请人手机号`,
	tir.create_time `邀约时间`,
	tir.be_invite_member_id `被邀请人会员ID`,
	tir.be_invite_mobile `被邀请人手机号`,
	tir.reserve_time `留资时间`,
	tir.vehicle_name `留资车型`,
	tir.drive_time `实际试驾时间`
from ods_invi.ods_invi_tm_invite_record_d tir 
left join ods_memb.ods_memb_tc_member_info_cur m on toString(tir.invite_member_id)=toString(m.id)  
join (
	select distinct distinct_id
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and a.`date` >= '2023-12-25'
	and a.`date` < '2024-01-02'
	and distinct_id not like '%#%'
	and length(a.distinct_id)<9
	and event = 'Page_entry'
	and page_title='18月会员日'
	and var_activity_name='2023年18月会员日'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
)x on toString(x.distinct_id) =toString(m.cust_id) 
where tir.is_deleted=0
and date(tir.create_time) >= '2023-12-25'
and date(tir.create_time) < '2024-01-02'
--and tir.be_invite_member_id is not null 
--and tir.drive_time>='2000-01-01'

-- 邀约试驾 当月总留资量
SELECT 
t2.code `邀约code`, 
	t2.member_id `邀请人会员ID`,
	tmi.member_phone  `邀请人手机号`,
	t2.create_time `邀约时间`,
	t1.be_invite_member_id `被邀请人会员ID`,
	t1.be_invite_mobile `被邀请人会员手机号`,
	t1.reserve_time `留资时间`,
	t1.be_invite_mobile `被邀请人手机号`,
	t1.vehicle_name `留资车型`,
	t1.drive_time `实际试驾时间`,
	tmi.cust_id as distinct_id
FROM ods_invi.ods_invi_tm_invite_code_d t2
left join ods_invi.ods_invi_tm_invite_record_d t1 on t1.invite_code = t2.code 
left join ods_memb.ods_memb_tc_member_info_cur tmi on t2.member_id = tmi.id
WHERE t2.create_time >='2024-08-25' 
and t2.create_time <'2024-01-26'

-- 预约试驾
	SELECT
	distinct 
	ta.ONE_ID `客户ID`,
	m.id `试驾memberID`,
	m.member_phone `沃世界注册手机号`,
	m.is_vehicle,
	ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT `预约时间`,
	tm2.model_name `预约车型`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.CUSTOMER_NAME `姓名`,
	ta.CUSTOMER_PHONE `手机号`,
	h.`大区` as `大区`,
	h.`小区` as `小区`,
	ta.OWNER_CODE `经销商`,
	CASE tad.STATUS
		WHEN 70711001 THEN '待试驾'
	    WHEN 70711002 THEN '已试驾' 
	    WHEN 70711003 THEN '已取消'
	    END `试驾状态`,
	tad.DRIVE_S_AT `试驾开始时间`,
	tad.DRIVE_E_AT `试驾结束时间`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(ta.ONE_ID)=toString(m.cust_id) 
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON toString(tc.CODE_ID)  = toString(ta.IS_ARRIVED)
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON toString(tad.APPOINTMENT_ID) = toString(ta.APPOINTMENT_ID )
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_orders_cur tso ON toString(tso.customer_business_id) = toString(ta.CUSTOMER_BUSINESS_ID)
	LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON toString(ca.uid) = toString(ta.CHANNEL_ID )
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc1 ON toString(tc1.CODE_ID) = toString(tso.so_status)
	join (
		select distinct distinct_id
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and event_time > '2024-08-01' and a.`date` = '2024-08-25'
		and distinct_id not like '%#%'
		and length(a.distinct_id)<9
		and event = 'Page_entry'
		and page_title='8月会员日'
		and var_activity_name='2024年8月会员日'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(m.cust_id) 
	LEFT JOIN (
	    select 
	        DISTINCT
	        tm.company_code as company_code,
	        tg2.ORG_NAME `大区`,
	        tg1.ORG_NAME `小区`
	    from ods_orga.ods_orga_tm_company_cur tm
	     JOIN ods_orga.ods_orga_tr_org_d tr1 ON tr1.org_id = tm.org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg1 ON tg1.ID = tr1.parent_org_id 
	     JOIN ods_orga.ods_orga_tr_org_d tr2 ON tr2.org_id = tr1.parent_org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg2 ON tg2.ID = tr2.parent_org_id 
	    where tm.is_deleted = 0 
	    AND tm.company_type = 15061003 
	    and tg1.ORG_TYPE = 15061007 
	    and tg2.ORG_TYPE = 15061005 
	    ORDER BY tm.company_code ASC) h on toString(h.company_code) = toString(ta.OWNER_CODE)
	left join ods_bada.ods_bada_tm_model_cur tm2 on toString(tad.THIRD_ID) = toString(tm2.id )
	WHERE 1=1
	and date(ta.CREATED_AT) = '2024-08-25'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tm2.is_deleted = 0
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT

	-- 养修预约
	select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.company_name_cn "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.id "会员ID",
       tmi.member_phone "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = 10041001 then'是'
    when tam.IS_TAKE_CAR = 10041002 then '否'
     end  "是否取车",
       case when tam.IS_GIVE_CAR = 10041001 then '是'
         when tam.IS_GIVE_CAR = 10041002 then '否'
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta."CREATED_AT" "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join 
		(select tmi.*
		,row_number()over(partition by tmi.cust_id order by tmi.create_time desc) rk 
		from ods_memb.ods_memb_tc_member_info_cur tmi
		where tmi.is_deleted =0
		Settings allow_experimental_window_functions = 1
		)tmi on ta.ONE_ID = tmi.cust_id 
	join (
			select distinct distinct_id
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-06-01' and a.`date` = '2024-06-25'
			and distinct_id not like '%#%'
			and length(a.distinct_id)<9
			and event = 'Page_entry'
			and page_title='6月会员日'
			and var_activity_name='2024年6月会员日'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(ta.ONE_ID) 
	where 1=1
	and tam.IS_DELETED <>1
	and date(ta.CREATED_AT)= '2024-06-25'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
	and tmi.rk =1
--	and tam.OWNER_ONE_ID='6149495'
--	and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') -- 进厂

		-- 养修预约
	select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.company_name_cn "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.id "会员ID",
       tmi.member_phone "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = 10041001 then'是'
    when tam.IS_TAKE_CAR = 10041002 then '否'
     end  "是否取车",
       case when tam.IS_GIVE_CAR = 10041001 then '是'
         when tam.IS_GIVE_CAR = 10041002 then '否'
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta."CREATED_AT" "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join 
		(select tmi.*
		,row_number()over(partition by tmi.cust_id order by tmi.create_time desc) rk 
		from ods_memb.ods_memb_tc_member_info_cur tmi
		where tmi.is_deleted =0
		Settings allow_experimental_window_functions = 1
		)tmi on ta.ONE_ID = tmi.cust_id 
	join (
		select distinct distinct_id
		from dwd_23.dwd_23_gio_tracking a
		where 1=1
		and a.`date` = '2024-06-25'
		and distinct_id not like '%#%'
		and length(a.distinct_id)<9
		and event = 'Page_entry'
		and page_title='6月会员日'
		and var_activity_name='2024年6月会员日'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(tmi.cust_id) 
	where 1=1
	and tam.IS_DELETED <>1
	and date(ta.CREATED_AT)= '2024-06-25'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
	and tmi.rk =1
	
	
-- 充电订单明细
	select a.member_id as member_id,
	m.member_phone `沃世界注册手机号`,
	a.vin `绑定vin`,
	tm.model_name `车型`,
	a.station_name `充电站`,
	a.start_time `充电开始时间`,
	a.end_time `充电结束时间`,
	a.charge_use_time `充电用时`,
	a.charge_use_power `充电量`,
	a.total_money_crossed `充电费款金额`,
	a.stop_reason `结束原因`
	from ods_chrg.ods_chrg_tt_charge_order_d a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.member_id)=toString(m.id) 
	left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd on toString(tisd.vin) =toString(a.vin )
	left join ods_bada.ods_bada_tm_model_cur tm on tm.id=tisd.model_id 
	join (
			select distinct distinct_id
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and event_time > '2024-08-01' and a.`date` = '2024-08-25'
			and distinct_id not like '%#%'
			and length(a.distinct_id)<9
			and event = 'Page_entry'
			and page_title='8月会员日'
			and var_activity_name='2024年8月会员日'
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		)x on toString(x.distinct_id) =toString(m.cust_id) 
	where a.is_deleted =0
	and tisd.is_deleted =0
	and date(a.create_time)='2024-08-25'


	
	
	
——————————————————————————————————————————————————经销商导流数据————————————————————————————————————————————————————————————————————————————————————————————————————

--活动期间经销商code的pv、uv
SELECT 
	var_promotion_channel_sub_type,
	count(usr_merged_gio_id) pv,
	count(distinct usr_merged_gio_id ) uv
from dwd_23.dwd_23_gio_tracking a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
where 1=1
and event_time>'2024-08-01'
and date ='2024-08-25' 
and event='Page_entry'
and page_title='8月会员日'
and var_activity_name='2024年8月会员日'
and var_promotion_channel_type ='dealer'
--and var_promotion_activity='202406_membersday'
group by var_promotion_channel_sub_type
order by uv desc

--上月 活动期间经销商code的pv、uv
SELECT 
	var_promotion_channel_sub_type,
--	count(usr_merged_gio_id) pv,
	count(distinct usr_merged_gio_id ) uv
from dwd_23.dwd_23_gio_tracking a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
where 1=1
and event_time>'2024-07-01'
and date ='2024-07-25' 
and event='Page_entry'
and page_title='7月会员日'
and var_activity_name='2024年7月会员日'
and var_promotion_channel_type ='dealer'
--and var_promotion_activity='202406_membersday'
group by var_promotion_channel_sub_type
order by uv desc

--活动期间首次访问活动页
select 
	var_promotion_channel_sub_type,
	count(distinct usr_merged_gio_id) uv
from (
  select x.usr_merged_gio_id
  ,x.var_promotion_channel_sub_type
  from (
    select usr_merged_gio_id
    ,distinct_id
    ,var_promotion_channel_sub_type
    ,row_number() over(partition by usr_merged_gio_id order by `time`) as rk
    from dwd_23.dwd_23_gio_tracking a
    left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id
    where 1=1
    and event_time>'2024-08-01'
	and date ='2024-08-25' 
	and event='Page_entry'
	and page_title='8月会员日'
	and var_activity_name='2024年8月会员日'
	and var_promotion_channel_type ='dealer'
  ) x
  where x.rk=1
) basic2
where 1=1
group by var_promotion_channel_sub_type
order by uv desc 

---------------------------------------------------------------------------------

-- 邀请试驾线索量
SELECT  
distinct 
	tir.invite_code `code` ,
	tir.invite_member_id `邀请人会员ID`,
	m.member_phone `邀请人手机号`,
	tir.create_time `邀约时间`,
	tir.be_invite_member_id `被邀请人会员ID`,
	tir.be_invite_mobile `被邀请人手机号`,
	tir.reserve_time `留资时间`,
	tir.vehicle_name `留资车型`,
	case when tir.drive_time<'2000-01-01' then null else tir.drive_time end `实际试驾时间`,
	case when tir.drive_time<'2000-01-01' then '未试驾' else '已试驾' end `试驾状态`
from ods_invi.ods_invi_tm_invite_record_d tir 
left join ods_memb.ods_memb_tc_member_info_cur m on toString(tir.invite_member_id)=toString(m.id)  
join (
	select distinct distinct_id
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and event_time > '2024-08-01' and a.`date` = '2024-08-25'
	and distinct_id not like '%#%'
	and length(a.distinct_id)<9
	and event = 'Page_entry'
	and page_title='8月会员日'
	and var_activity_name='2024年8月会员日'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
)x on toString(x.distinct_id) =toString(m.cust_id) 
where tir.is_deleted=0
and date(tir.create_time)= '2024-08-25'
and tir.be_invite_member_id is not null 