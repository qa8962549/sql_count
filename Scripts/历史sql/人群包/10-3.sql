# 10-3 会员日人群包
-- 10-3-1 8月24号00:01分至9月22号23:59分累积新增V值大于等于1,500 V的人群
select distinct n.手机号,
n.微信公众号open_id ,
'10-3-1'
from
	(select
	a.MEMBER_ID 会员ID,
	SUM(a.integral) 累计新增V值 
	from `member`.tt_member_flow_record a
	where a.CREATE_TIME >= '2022-09-23'
	and a.CREATE_TIME <= '2022-10-23 23:59:59'
	and a.RECORD_TYPE = 0   -- 新增
	and a.EVENT_TYPE <> 60731025  -- 剔除退回V值
	and a.STATUS = 1
	and a.IS_DELETED = 0
	group by 1
	order by 2 desc)m
left join
	(
	select a.会员ID,a.客户ID,a.会员昵称,a.姓名,a.性别,a.手机号,a.是否车主,a.VIN,a.VEHICLE_CODE,a.微信小程序open_id,(eco.open_id)微信公众号open_id,a.注册时间
	from
		(
		select 
		m.id 会员ID,
		m.cust_id 客户ID,
		m.create_time 注册时间,
		case when m.member_sex = '10021001' then '先生'
			when m.member_sex = '10021002' then '女士'
			else '未知' end 性别,
		m.member_name 会员昵称,
		m.real_name 姓名,
		m.MEMBER_PHONE 手机号,
		m.is_vehicle 是否车主,
		tmv.VIN,
		tmv.VEHICLE_CODE,
		c.open_id 微信小程序open_id,
		IFNULL(c.union_id,u.unionid) allunionid
		from member.tc_member_info m
		left join `member`.tc_member_vehicle tmv on m.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
		left join customer.tm_customer_info c on c.id=m.cust_id
		left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid <> '00000000'
		where m.is_deleted = 0 and m.member_status <> '60341003'
		) a 
	left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
	and eco.subscribe_status = 1 -- 状态为关注
	and eco.open_id is not null 
	and eco.open_id <> ''
	order by a.注册时间 DESC
)n on m.会员ID = n.会员ID
where m.累计新增V值 >= 1500



-- 9-3-2 近3个月会员日code的UV作为人群
-- 9月会员日
select m.手机号,n.微信公众号open_id,'10-3-2'
from
(select 
distinct tmi.ID 会员ID,tmi.MEMBER_PHONE 手机号
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-09-25'
and t.`date` < '2022-09-26'
and json_extract(t.`data`,'$.embeddedpoint') = 'memberDay9_home_onload')m
left join
(select a.会员ID,a.客户ID,a.会员昵称,a.姓名,a.性别,a.手机号,a.是否车主,a.VIN,a.VEHICLE_CODE,a.微信小程序open_id,(eco.open_id)微信公众号open_id,a.注册时间
from
(
select 
m.id 会员ID,
m.cust_id 客户ID,
m.create_time 注册时间,
case when m.member_sex = '10021001' then '先生'
	when m.member_sex = '10021002' then '女士'
	else '未知' end 性别,
m.member_name 会员昵称,
m.real_name 姓名,
m.MEMBER_PHONE 手机号,
m.is_vehicle 是否车主,
tmv.VIN,
tmv.VEHICLE_CODE,
c.open_id 微信小程序open_id,
IFNULL(c.union_id,u.unionid) allunionid
from member.tc_member_info m
left join `member`.tc_member_vehicle tmv on m.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
left join customer.tm_customer_info c on c.id=m.cust_id
left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid <> '00000000'
where m.is_deleted = 0 and m.member_status <> '60341003'
) a 
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
order by a.注册时间 DESC)n
on m.会员ID = n.会员ID
union 
-- 7月会员日
select m.手机号,n.微信公众号open_id,'10-3-2' from
(select 
distinct tmi.ID 会员ID,tmi.MEMBER_PHONE 手机号
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-07-25'
and t.`date` < '2022-07-26'
and json_extract(t.`data`,'$.embeddedpoint') = 'memberDay7_home_onload')m
left join
(select a.会员ID,a.客户ID,a.会员昵称,a.姓名,a.性别,a.手机号,a.是否车主,a.VIN,a.VEHICLE_CODE,a.微信小程序open_id,(eco.open_id)微信公众号open_id,a.注册时间
from
(
select 
m.id 会员ID,
m.cust_id 客户ID,
m.create_time 注册时间,
case when m.member_sex = '10021001' then '先生'
	when m.member_sex = '10021002' then '女士'
	else '未知' end 性别,
m.member_name 会员昵称,
m.real_name 姓名,
m.MEMBER_PHONE 手机号,
m.is_vehicle 是否车主,
tmv.VIN,
tmv.VEHICLE_CODE,
c.open_id 微信小程序open_id,
IFNULL(c.union_id,u.unionid) allunionid
from member.tc_member_info m
left join `member`.tc_member_vehicle tmv on m.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
left join customer.tm_customer_info c on c.id=m.cust_id
left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid <> '00000000'
where m.is_deleted = 0 and m.member_status <> '60341003'
) a 
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
order by a.注册时间 DESC)n
on m.会员ID = n.会员ID
union 
-- 8月会员日
select m.手机号,n.微信公众号open_id,'10-3-2' from
(select 
distinct tmi.ID 会员ID,tmi.MEMBER_PHONE 手机号
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-08-25'
and t.`date` < '2022-08-26'
and json_extract(t.`data`,'$.embeddedpoint') = 'memberDay8_home_onload')m
left join
(select a.会员ID,a.客户ID,a.会员昵称,a.姓名,a.性别,a.手机号,a.是否车主,a.VIN,a.VEHICLE_CODE,a.微信小程序open_id,(eco.open_id)微信公众号open_id,a.注册时间
from
(
select 
m.id 会员ID,
m.cust_id 客户ID,
m.create_time 注册时间,
case when m.member_sex = '10021001' then '先生'
	when m.member_sex = '10021002' then '女士'
	else '未知' end 性别,
m.member_name 会员昵称,
m.real_name 姓名,
m.MEMBER_PHONE 手机号,
m.is_vehicle 是否车主,
tmv.VIN,
tmv.VEHICLE_CODE,
c.open_id 微信小程序open_id,
IFNULL(c.union_id,u.unionid) allunionid
from member.tc_member_info m
left join `member`.tc_member_vehicle tmv on m.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
left join customer.tm_customer_info c on c.id=m.cust_id
left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid <> '00000000'
where m.is_deleted = 0 and m.member_status <> '60341003'
) a 
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
order by a.注册时间 DESC)n
on m.会员ID = n.会员ID



-- 10-3-3 近180天商城有正向订单的用户的人群；； 
select 
DISTINCT x.手机号,
(eco.open_id)微信公众号open_id,
'10-3-3'
from (
select a.order_code 订单编号
,a.create_time 
,h.MEMBER_PHONE 手机号
,h.id
,h.CUST_ID 
,h.OLD_MEMBERID 
,IFNULL(c.union_id,u.unionid) allunionid
,a.user_id 会员id
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join `member`.tc_member_vehicle tmv on h.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
left join customer.tm_customer_info c on c.id=h.cust_id
left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=h.old_memberid and u.unionid <> '00000000'
left join(
	#V值退款成功记录
	select so.order_code,sp.product_id
	,CASE so.status 
		WHEN 51171001 THEN '待审核' 
		WHEN 51171002 THEN '待退货入库' 
		WHEN 51171003 THEN '待退款' 
		WHEN 51171004 THEN '退款成功' 
		WHEN 51171005 THEN '退款失败' 
		WHEN 51171006 THEN '作废退货单' END AS 退货状态
	,sum(sp.sales_return_num) 退货数量
	,sum(so.refund_point) 退回V值
	,max(so.create_time) 退回时间
	from `order`.tt_sales_return_order so
	left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
	where so.is_deleted = 0 
	and so.status=51171004 -- 退款成功
	GROUP BY 1,2,3
) e on a.order_code = e.order_code and b.product_id =e.product_id 
where a.create_time >= DATE_SUB('2022-10-23 23:59:59',INTERVAL 180 day)   -- 近180天的订单时间
and a.create_time <= '2022-10-23 23:59:59'
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
order by a.create_time desc) x
left join volvo_wechat_live.es_car_owners eco on x.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
where LENGTH(x.手机号) = 11 and left(x.手机号,1) = '1' -- 排除无效手机号



-- 10-3-4 6~8月在沃世界活跃过，但在9月1日~9月22日未活跃的人群；
select 
distinct a.手机号,
(eco.open_id)微信公众号open_id,
'10-3-4'
from
(
select 
DISTINCT m.id 会员ID,
m.create_time 注册时间,
a.max_date 最近活跃时间,
m.MEMBER_PHONE 手机号,
IFNULL(c.union_id,u.unionid) allunionid
from track.track t 
join 
(select t.usertag,max(t.`date`) max_date
 from track.track t
 group by 1) a on a.usertag = t.usertag
left join member.tc_member_info m on t.usertag = cast(m.USER_ID as varchar)
left join `member`.tc_member_vehicle tmv on m.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
left join customer.tm_customer_info c on c.id=m.cust_id
left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid <> '00000000'
where m.is_deleted = 0 and m.member_status <> '60341003'
and (a.max_date >= '2022-07-01' or a.max_date is null) -- 7~9月在沃世界活跃过，但在10月1日~10月22日未活跃的人群；
and (a.max_date <= '2022-09-30 23:59:59' or a.max_date is null)
-- and (a.max_date not BETWEEN '2022-10-01' and '2022-10-22 23:59:59' or a.max_date is null)   -- 最新活跃日期不在8.1 - 8.23，这个双边界不包含
and (a.max_date > m.MEMBER_TIME or a.max_date is null)   -- 访问时间大于注册时间
order by a.max_date desc
) a 
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
and LENGTH(a.手机号) = 11 and left(a.手机号,1) = '1' -- 排除无效手机号



-- 9-3-5 截止9月22日，白银及以上会员 只取一半
select * from
(
select
	distinct a.手机号,eco.open_id 微信公众号Open_ID,'10-3-5'
from
(
	select
		a.MEMBER_PHONE 手机号,
		IFNULL(c.union_id,u.unionid) allunionid
	from `member`.tc_member_info a    -- 会员表作为主表
	left join customer.tm_customer_info c on c.id=a.cust_id
	left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=a.old_memberid and u.unionid <> '00000000'
	where a.MEMBER_TIME <= '2022-10-23 23:59:59'    -- 会员截止到2022.9.22全量数据
	and a.MEMBER_STATUS <> 60341003    -- 剔除黑名单
	and a.IS_DELETED = 0
	and a.MEMBER_LEVEL >= 2  -- 白银及以上等级
) a
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
and LENGTH(a.手机号) = 11 and left(a.手机号,1) = '1' -- 排除无效手机号
)
order by RAND() LIMIT 153350





-- 9-3-6 最近180天没有预约养修的车主且近6个月活跃过(类似于：剔除近180天点击了养修预约按钮且到店了的车主)
select distinct a.手机号,eco.open_id 微信公众号Open_ID,'10-3-6' from
(
	select
	DISTINCT a.MEMBER_PHONE 手机号, 
	IFNULL(c.union_id,u.unionid) allunionid
	from member.tc_member_info a
	left join customer.tm_customer_info c on c.id=a.cust_id
	left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=a.old_memberid and u.unionid <> '00000000'
	where a.is_deleted = 0
	and a.is_vehicle = 1   -- 筛选车主
	and a.MEMBER_STATUS <> 60341003  -- 剔除黑名单
	and a.id not in
	(
		select distinct b.会员ID from
		(
			-- 近180天养修预约并且成功进厂
			select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
			       ta.APPOINTMENT_ID "预约ID",
			       ta.OWNER_CODE "经销商代码",
			       tc2.COMPANY_NAME_CN "经销商名称",
			       ta.ONE_ID "车主oneid",
			       tam.OWNER_ONE_ID,
			       ta.CUSTOMER_NAME "联系人姓名",
			       ta.CUSTOMER_PHONE "联系人手机号",
			       tmi.ID "会员ID",
			       tmi.MEMBER_PHONE "沃世界绑定手机号",
			       tam.CAR_MODEL "预约车型",
			       tam.CAR_STYLE "预约车款",
			       tam.VIN "车架号",
			       case when tam.IS_TAKE_CAR = "10041001" then "是" 
			    		when tam.IS_TAKE_CAR = "10041002" then "否" 
			       end  "是否取车",
			       case when tam.IS_GIVE_CAR = "10041001" then "是"
			            when tam.IS_GIVE_CAR = "10041002" then "否"
			       end "是否送车",
				   tam.MAINTAIN_STATUS "养修状态code",
			       tc.CODE_CN_DESC "养修状态",
			       tam.CREATED_AT "创建时间",
			       tam.UPDATED_AT "修改时间",
			       ta.CREATED_AT "预约时间",
			       tam.WORK_ORDER_NUMBER "工单号"
			from cyx_appointment.tt_appointment  ta
			left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
			left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
			left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
			left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
			where ta.CREATED_AT >= DATE_SUB('2022-10-23 23:59:59',INTERVAL 180 day)   -- 近180天的订单时间
			and ta.CREATED_AT <= '2022-10-23 23:59:59'
			and ta.DATA_SOURCE = "C"    -- C端
			and ta.APPOINTMENT_TYPE = 70691005    -- 养修预约
			and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')    -- 筛选预约状态为：有效
			order by ta.CREATED_AT DESC
		) b
	)
	and a.MEMBER_PHONE in
	(
		select 
		distinct m.MEMBER_PHONE
		from track.track t 
		join 
		(select t.usertag,max(t.`date`) max_date
		 from track.track t
		 group by 1) a on a.usertag = t.usertag
		left join member.tc_member_info m on t.usertag = cast(m.USER_ID as varchar)
		where m.is_deleted = 0 and m.member_status <> 60341003
		and (a.max_date >= DATE_SUB('2022-10-23 23:59:59',INTERVAL 180 DAY) or a.max_date is null)
		and (a.max_date <= '2022-10-23 23:59:59' or a.max_date is null)
		and (a.max_date > m.MEMBER_TIME or a.max_date is null)   -- 访问时间大于注册时间
	)
) a
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
and LENGTH(a.手机号) = 11 and left(a.手机号,1) = '1' -- 排除无效手机号