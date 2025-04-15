-- 访问过活动的车主用户-App
select count(a.user_id) PV,
count(distinct a.user_id) UV,
count(distinct case when a.is_bind=1 then a.user_id else null end)`活跃车主数`
from ods_rawd.ods_rawd_events_d_di a
where 1=1
and event='Page_view'
and length(distinct_id)<9 
and date>='2023-12-01'
and date<'2024-01-01'
and page_title='忠诚车主回厂活动'
--and activity_name='2023年12月忠诚车主回厂活动'
--and a.channel='App'
--and a.is_bind=1

-- 召回车主人数（促活）（App30天内未活跃车主会员）
select 
count(distinct a.user_id)
from
	(-- 访问过活动的车主用户-App
	select distinct a.user_id,distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Page_entry'
	and length(distinct_id)<9 
	and date>='2023-12-01'
	and date<'2024-01-01'
	and page_title='忠诚车主回厂活动'
--	and activity_name='2023年12月忠诚车主回厂活动'
	and a.is_bind=1
)a
left join
	(-- 注册会员
	select distinct m.cust_id
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time >= '2023-12-01'
	and m.create_time <'2024-01-01'
)b on a.distinct_id=b.cust_id::varchar
left join
	(-- App 访问过活动前30天内活跃过的车主会员
	select 
	distinct a.user_id
	from
		(-- 访问过活动的车主用户-App
		select a.user_id,`time`,time+ interval '-10 MINUTE' as `time1`
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and event='Page_entry'
		and length(distinct_id)<9 
		and date>='2023-12-01'
		and date<'2024-01-01'
		and page_title='忠诚车主回厂活动'
--		and activity_name='2023年10月商城亲子季'
--		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
		and a.is_bind=1
		)a 
	join
		(--前30天内活跃用户
		select a.user_id,`time`
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and length(distinct_id)<9 
		and date>='2023-11-01'
		and date<'2023-12-01'
--		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
		)b on a.user_id=b.user_id
	where a.`time`+ interval '-30 day'<= b.`time` and b.`time`<a.`time1`
)c on a.user_id=c.user_id
where 1=1
and b.cust_id is null -- 剔除新用户
and c.user_id =0 -- 剔除访问活动前30天内活跃过的车主会员

--200元卡券页面 前往查阅btn PV
select content_title,
btn_name,
count(a.user_id),
count(distinct a.user_id)
from ods_rawd.ods_rawd_events_d_di a
where 1=1
and event='Button_click'
and btn_type='btn'
and length(distinct_id)<9 
and date>='2023-12-01'
and date<'2024-01-01'
and page_title='忠诚车主回厂活动'
--and activity_name='2023年12月忠诚车主回厂活动'
group by content_title,btn_name


-- 浏览过活动页面&提交养修预约工单数量
select count(distinct x.APPOINTMENT_ID )
from ods_rawd.ods_rawd_events_d_di a
global join (
	-- 养修预约
	select 
	       ta.ONE_ID as one_id,
	       tmi.id "会员ID",
	       ta.APPOINTMENT_ID as APPOINTMENT_ID 
	from ods_cyap.ods_cyap_tt_appointment_d ta 
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
	where 1=1
	and tam.IS_DELETED <>1
	and ta.CREATED_AT >= '2023-12-01'
	and ta.CREATED_AT <'2024-01-01'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
)x on toString(a.distinct_id)=toString(x.one_id) 
where 1=1
and event='Page_entry'
and length(distinct_id)<9 
and date>='2023-12-01'
and date<'2024-01-01'
and page_title='忠诚车主回厂活动'
--and activity_name='2023年12月忠诚车主回厂活动'


	-- 养修预约工单提交量
	select 
	       count(ta.APPOINTMENT_ID) 
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
	where 1=1
	and tam.IS_DELETED <>1
	and ta.CREATED_AT >= '2023-12-01'
	and ta.CREATED_AT <'2024-01-01'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005

--养修预约-浏览过活动页面并提交养修预约后实际到店数
	-- 浏览过活动页面&提交养修预约工单数量
select count(distinct x.APPOINTMENT_ID )
from ods_rawd.ods_rawd_events_d_di a
global join (
	-- 养修预约
	select 
	       ta.ONE_ID as one_id,
	       tmi.id "会员ID",
	       ta.APPOINTMENT_ID as APPOINTMENT_ID 
	from ods_cyap.ods_cyap_tt_appointment_d ta 
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
	where 1=1
	and tam.IS_DELETED <>1
	and ta.CREATED_AT >= '2023-12-01'
	and ta.CREATED_AT <'2024-01-01'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
	and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')
)x on toString(a.distinct_id)=toString(x.one_id) 
where 1=1
and event='Page_entry'
and length(distinct_id)<9 
and date>='2023-12-01'
and date<'2024-01-01'
and page_title='忠诚车主回厂活动'
	
	
	select count(1)
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
	where 1=1
	and tam.IS_DELETED <>1
	and ta.CREATED_AT >= '2023-12-01'
	and ta.CREATED_AT <'2024-01-01'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
	and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')
	
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
       tam.WORK_ORDER_NUMBER "工单号",
       case when x.APPOINTMENT_ID is not null then '是' else '否' end as `是否通过活动养修预约`
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
	left join 
		(-- 浏览过活动页面&提交养修预约工单数量
		select distinct x.APPOINTMENT_ID as APPOINTMENT_ID
		from ods_rawd.ods_rawd_events_d_di a
		global join (
			-- 养修预约
			select 
			       ta.ONE_ID as one_id,
			       tmi.id "会员ID",
			       ta.APPOINTMENT_ID as APPOINTMENT_ID 
			from ods_cyap.ods_cyap_tt_appointment_d ta 
			left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
			left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
			left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
			left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
			where 1=1
			and tam.IS_DELETED <>1
			and ta.CREATED_AT >= '2023-12-01'
			and ta.CREATED_AT <'2024-01-01'
			and ta.DATA_SOURCE ='C'
			and ta.APPOINTMENT_TYPE =70691005
		)x on toString(a.distinct_id)=toString(x.one_id) 
		where 1=1
		and event='Page_entry'
		and length(distinct_id)<9 
		and date>='2023-12-01'
		and date<'2024-01-01'
		and page_title='忠诚车主回厂活动')x on toString(x.APPOINTMENT_ID) =toString(ta.APPOINTMENT_ID) 
	where 1=1
	and tam.IS_DELETED <>1
	and ta.CREATED_AT >= '2023-12-01'
	and ta.CREATED_AT <'2024-01-01'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
--	and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') -- 进厂

	
-- 卡券领用核销明细 售后卡券 总
select 
--date_format(x.获得时间,'%Y-%m-%d') 日期,
x.coupon_id,
x.卡券状态2,
--concat(x.coupon_id,x.卡券状态),
-- count(case when x.IS_VEHICLE=1 then x.id else null end) 车主,
-- count(case when x.IS_VEHICLE=0 then x.id else null end) 粉丝,
count(x.id)
from 
	(
	SELECT 
	distinct 
	a.id,
	a.one_id,
	a.coupon_id,
	tmi.IS_VEHICLE,
	b.id coupon_id卡券ID,
	b.coupon_name 卡券名称,
	a.left_value/100 面额,
	b.coupon_code 券号,
	tmi.ID 沃世界会员ID,
	tmi.MEMBER_NAME 会员昵称,
	tmi.REAL_NAME 姓名,
	tmi.MEMBER_PHONE 沃世界绑定手机号,
	a.vin 购买VIN,
	a.get_date 获得时间,
	a.activate_date 激活时间,
--	c.associate_vin vin,
--	c.associate_dealer 经销商,
--	tc.company_code 经销商code,
	a.expiration_date 卡券失效日期,
	CAST(a.exchange_code as varchar) 核销码,
-- 	case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
--  	WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台类型,
	CASE a.coupon_source 
	  WHEN 83241001 THEN 'VCDC发券'
	  WHEN 83241002 THEN '沃世界领券'
	  WHEN 83241003 THEN '商城购买'
	END AS 卡券来源,
	CASE a.ticket_state
	  WHEN 31061001 THEN '已领用'
	  WHEN 31061002 THEN '已锁定'
	  WHEN 31061003 THEN '已核销' 
	  WHEN 31061004 THEN '已失效'
	  WHEN 31061005 THEN '已作废'
	END AS 卡券状态,
	v.*,
	case when v.核销时间 is not null then '已核销' else '已领用' end as 卡券状态2
	FROM coupon.tt_coupon_detail a 
	JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
	left join 
	(select tmi.*
	,row_number ()over(partition by tmi.cust_id order by tmi.create_time desc ) rk
	from `member`.tc_member_info tmi 
	where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
	)tmi on a.one_id = tmi.CUST_ID and tmi.member_phone <>'*' and tmi.rk=1
	left join "order".tt_order_product c on a.order_code = c.order_code and c.is_deleted <> 1 -- 订单商品表
	left join organization.tm_company tc on c.associate_dealer =tc.company_short_name_cn and tc.is_deleted <>1 --经销商表
	LEFT JOIN (
	select v.coupon_detail_id
	,v.customer_name 核销用户名
	,v.customer_mobile 核销手机号
	,v.verify_amount 
	,v.dealer_code 核销经销商
	,v.vin 核销VIN
	,v.operate_date 核销时间
	,v.order_no 订单号
	,v.PLATE_NUMBER
	from coupon.tt_coupon_verify v 
	where  v.is_deleted=0
--	and v.operate_date>='2023-12-01'
	and v.operate_date<'2024-01-01'
	order by v.create_time desc
	) v ON v.coupon_detail_id = a.id
	WHERE 1=1
	and a.coupon_id in ('4374','3152')
--	and a.coupon_id ='3152'
--	and a.get_date >= '2023-12-01'
	and a.get_date < '2024-01-01'
	and a.is_deleted=0 
	order by a.get_date desc 
)x 
where 1=1
--and x.卡券状态='已失效' or x.卡券状态='已核销'
group by 1,2
order by 1 desc ,2 desc 


-- mingxi
	SELECT 
	distinct 
	a.id,
	a.one_id,
	a.coupon_id,
	tmi.IS_VEHICLE,
	b.id coupon_id卡券ID,
	b.coupon_name 卡券名称,
	a.left_value/100 面额,
	b.coupon_code 券号,
	tmi.ID 沃世界会员ID,
	tmi.MEMBER_NAME 会员昵称,
	tmi.REAL_NAME 姓名,
	tmi.MEMBER_PHONE 沃世界绑定手机号,
	a.vin 购买VIN,
	a.get_date 获得时间,
	a.activate_date 激活时间,
--	c.associate_vin vin,
--	c.associate_dealer 经销商,
--	tc.company_code 经销商code,
	a.expiration_date 卡券失效日期,
	CAST(a.exchange_code as varchar) 核销码,
-- 	case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
--  	WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台类型,
	CASE a.coupon_source 
	  WHEN 83241001 THEN 'VCDC发券'
	  WHEN 83241002 THEN '沃世界领券'
	  WHEN 83241003 THEN '商城购买'
	END AS 卡券来源,
	CASE a.ticket_state
	  WHEN 31061001 THEN '已领用'
	  WHEN 31061002 THEN '已锁定'
	  WHEN 31061003 THEN '已核销' 
	  WHEN 31061004 THEN '已失效'
	  WHEN 31061005 THEN '已作废'
	END AS 卡券状态,
	v.*,
	case when v.核销时间 is not null then '已核销' else '已领用' end as 卡券状态2
	FROM coupon.tt_coupon_detail a 
	JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
	left join 
	(select tmi.*
	,row_number ()over(partition by tmi.cust_id order by tmi.create_time desc ) rk
	from `member`.tc_member_info tmi 
	where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
	)tmi on a.one_id = tmi.CUST_ID and tmi.member_phone <>'*' and tmi.rk=1
	left join "order".tt_order_product c on a.order_code = c.order_code and c.is_deleted <> 1 -- 订单商品表
	left join organization.tm_company tc on c.associate_dealer =tc.company_short_name_cn and tc.is_deleted <>1 --经销商表
	LEFT JOIN (
	select v.coupon_detail_id
	,v.customer_name 核销用户名
	,v.customer_mobile 核销手机号
	,v.verify_amount 
	,v.dealer_code 核销经销商
	,v.vin 核销VIN
	,v.operate_date 核销时间
	,v.order_no 订单号
	,v.PLATE_NUMBER
	from coupon.tt_coupon_verify v 
	where  v.is_deleted=0
	and v.operate_date < '2024-01-01'
	order by v.create_time 
	) v ON v.coupon_detail_id = a.id
	WHERE 1=1
	and a.coupon_id in ('4374','3152')
--	and a.get_date >= '2023-01-01'
	and a.get_date < '2024-01-01'
	and a.is_deleted=0 
	and 卡券状态2='已领用'
	order by a.get_date desc 
	
