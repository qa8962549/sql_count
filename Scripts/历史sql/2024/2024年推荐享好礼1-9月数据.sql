--被推荐人二次推荐情况
--A今年受邀购车后，发起二次推荐成功购车的推荐人人数
--B接受A邀请（A于24年受邀成功）成功购车后，再邀请C成功购车推荐人人数
-- 10、邀约试驾购车累计数据（明细）
select
m.REAL_NAME "推荐人姓名",
r.invite_member_id "推荐人会员ID",
c.buy_name "推荐人客户姓名(NEWBIE)",
m.level_id `推荐人会员等级`,
m.member_v_num `推荐人现有V值`,
IF(r.invite_mobile = '*',mm.MEMBER_PHONE,r.invite_mobile) "推荐人手机号",
IFNULL(a.年累计成功邀请试驾人数,0) "年累计成功邀请试驾人数",
case when a.年累计成功邀请试驾人数 >= 100 then '是'
	else '否' end "是否达到推荐试驾成功奖励上限",
IFNULL(b.推荐人当前季度成功推荐购车数,0) "推荐人当前季度成功推荐购车数(不含付大定数)",
IFNULL(bb.推荐人当前季度成功推荐直售纯电付大定人数,0) "推荐人当前季度成功推荐直售纯电付大定人数",
'' 是否达到推荐购车奖励上限,       -- 这个字段在Excel表格中使用IF条件判断吧
c.VIN "推荐人VIN",
d.被推荐人姓名,
r.be_invite_member_id "被推荐人会员ID",
c2.buy_name "被推荐人客户姓名(NEWBIE)",
d.被推荐人会员等级 `被推荐人会员等级`,
d.被推荐人现有V值 `被推荐人现有V值`,
r.be_invite_mobile "被推荐人留资手机号",
d.市场活动代码,
d.市场活动名称,
d.省 "被推荐人省份",
d.市 "被推荐人城市",
d.经销商代码,
d.意向车型,
d.预约日期,
r.reserve_time 被推荐人留资时间,
d.线索下发时间,
case when e.试驾手机号 is not null then '否'
	when e.试驾手机号 is null then '是'
	else null end "是否首次APP/沃世界试驾",
coalesce(r.drive_time,d.到店试驾时间) "到店试驾时间",
date(coalesce(r.drive_time,d.到店试驾时间)) - date(r.reserve_time) 留资距完成试驾天数,
case when r.reward_drive_status = 0 then '待开始'
	when r.reward_drive_status = 1 then '已生成'
	when r.reward_drive_status = 2 then '已发放'
	when r.reward_drive_status = 3 then '超过上限'
	when r.reward_drive_status = 4 then '好友非首次到店试驾'
	when r.reward_drive_status = 5 then '超时'
	when r.reward_drive_status = 6 then '发放失败'
	end "被邀请人试驾奖励是否发放",
'' 试驾奖励不发放理由（事件代码）,
case when f.抽奖时间 is not null then '完成'
	else '未完成' end "试驾享礼抽奖是否完成",
f.中奖奖品,
g.经销商编号 "开票付定经销商",
g.开票人姓名 "开票付定用户名",
g.被邀请人手机号 "开票付定手机号",
g.车架号 "新车车架号",
g.车型 "新车车型",
g.蓝票开票时间,
g.定金支付时间,
g.订单状态,
date(g.蓝票开票时间) - date(coalesce(r.drive_time,d.到店试驾时间)) 购车距完成试驾天数,
h.邀约人购车奖励,
h.邀约人购车奖励状态,
h.被邀约人购车V值奖励,
h.被邀约人购车奖励状态,
i.加电券数量,
'' 不发奖励理由,
r.create_time 
from invite.tm_invite_record r    -- 邀约明细表
left join `member`.tc_member_info m on r.invite_member_id = m.ID and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0    -- 会员表
left join `member`.tc_member_info_phone_repetition mm on r.invite_member_id = mm.MEMBER_ID and mm.IS_DELETED = 0    -- 带*手机号匹配
left join
(
	--  自然年累计推荐成功试驾人数（2023全年）
	select a.邀请人会员ID,COUNT(a.被邀请人会员ID) 年累计成功邀请试驾人数 from
	(
		-- 23Q1推荐购
		select
		c.invite_member_id 邀请人会员ID,
		c.be_invite_member_id 被邀请人会员ID
		from invite.tm_invite_record c
		where c.is_deleted = 0
		and c.drive_time is not null   -- 试驾时间不为空
		and date(c.create_time) between '{d_start_jidu[:4]+"-01-01"}' and '{d_end}'  -- 年初
	) a
	group by 1
	order by 2 desc
) a on r.invite_member_id = a.邀请人会员ID
left join 
(
	--  推荐人当前季度成功推荐购车数（不含付大定人数）
	select
	r.invite_member_id 推荐人会员ID,
	COUNT(distinct r.order_no) 推荐人当前季度成功推荐购车数
	from invite.tm_invite_record r
	left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 'N'
	where r.is_deleted = 0
	and r.order_no is not NULL   -- 筛选订单号不为空
	and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
	and r.is_large_set = '2'    -- 是否付大定:否
	and tc.CODE_CN_DESC not in ('未提交','提交待审批','审批通过没发票','已交车且没有发票','已取消','退车中','已退车','退款中')    -- 剔除无效订单
	and date(r.create_time) between '{d_start_jidu}' and '{d_end}' -- 季度初
	group by 1
	order by 2 desc
) b on r.invite_member_id = b.推荐人会员ID
left join 
(
	--  推荐人当前季度成功推荐直售纯电付大定人数
	select
	r.invite_member_id 推荐人会员ID,
	COUNT(distinct r.order_no) 推荐人当前季度成功推荐直售纯电付大定人数
	from invite.tm_invite_record r
	left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 'N'
	where r.is_deleted = 0
	and r.order_no is not NULL   -- 筛选订单号不为空
	and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
	and r.is_large_set = '1'    -- 是否付大定:是
	and tc.CODE_CN_DESC not in ('未提交','提交待审批','审批通过没发票','已交车且没有发票','已取消','退车中','已退车','退款中')    -- 剔除无效订单
	and date(r.create_time) between '{d_start_jidu}' and '{d_end}' -- 季度初
	group by 1
	order by 2 desc
) bb on r.invite_member_id = bb.推荐人会员ID
left join
(
	--  推荐人最新绑定的VIN
    select vr.vin_code vin, member_id, kp.buy_name
    from (
    	select vin_code, member_id
    		,row_number ()over(partition by member_id order by bind_date desc) rn 
    	from volvo_cms.vehicle_bind_relation  
    	where deleted=0 and is_bind=1 and is_owner=1
    	) vr 
    left join vehicle.tt_invoice_statistics_dms kp 
    on vr.vin_code = kp.vin and kp.is_deleted = 0
    where vr.rn = 1
) c on r.invite_member_id = c.MEMBER_ID
left join
(
	--  被推荐人最新绑定的VIN
    select vr.vin_code vin, member_id, kp.buy_name
    from (
    	select vin_code, member_id
    		,row_number ()over(partition by member_id order by bind_date desc) rn 
    	from volvo_cms.vehicle_bind_relation  
    	where deleted=0 and is_bind=1 and is_owner=1
    	) vr 
    left join vehicle.tt_invoice_statistics_dms kp 
    on vr.vin_code = kp.vin and kp.is_deleted = 0
    where vr.rn = 1
) c2 on r.be_invite_member_id = c2.MEMBER_ID
left join
(
	--  匹配被推荐人留资试驾相关信息
	select
		r.id ,
		ta.APPOINTMENT_ID 预约ID,
		ta.customer_name 被推荐人姓名,
		ta.customer_phone 被推荐人手机号,
		ca.active_code 市场活动代码,
		ca.active_name 市场活动名称,
		tc2.COMPANY_NAME_CN 经销商名称,
		tc2.PROVINCE_NAME 省,
		tc2.CITY_NAME 市,
		ta.OWNER_CODE 经销商代码,
		tm.model_name 意向车型,
		ta.CREATED_AT 预约时间,
		ta.invitations_date 预约日期,
		ta.CREATED_AT 被推荐人留资时间,
		ta.CREATED_AT 线索下发时间,
		tp.drive_s_at 到店试驾时间,
        tmi.level_id 被推荐人会员等级,
		tmi.member_v_num 被推荐人现有V值
	FROM invite.tm_invite_record r
	left join cyx_appointment.tt_appointment ta on ta.appointment_id =r.appointment_id and ta.is_deleted =0
	LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED and ta.is_deleted =0
	LEFT JOIN organization.tm_company tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE and tc2.IS_DELETED = 0 and COMPANY_TYPE = 15061003
	LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID and tad.is_deleted =0
	LEFT JOIN basic_data.tm_model tm on tad.THIRD_ID = tm.ID and tm.IS_DELETED = 0
	LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID and ca.is_deleted =0
    left join drive_service.tt_testdrive_plan tp on tad.item_id = tp.item_id and tp.is_deleted = 0
    left join "member".tc_member_info tmi on tmi.id=r.be_invite_member_id
	where 1=1 
	and r.is_deleted =0
	and date(r.create_time) between '2024-10-01' and '{2024-11-01}' -- 季度初
--	order by ta.CREATED_AT
) d on r.id = d.id
left join
(
	--  历史试驾数据 要算首次试驾 则历史试驾人员不统计在内
	select
	DISTINCT p.MOBILE 试驾手机号
	from `drive_service`.tt_testdrive_plan p      -- 试驾工单表（只要数据存在，那么就算这个人试驾了。）
	where p.DRIVE_S_AT >= '2021-10-01'    -- 试驾开始时间，不用修改
	and date(p.DRIVE_S_AT) < '{d_start}' 
	and p.IS_DELETED = 0
) e on r.be_invite_mobile = e.试驾手机号
left join
(
	--  试驾抽奖奖品
	select
	a.member_id 被邀请人会员ID,
	tmi.MEMBER_PHONE 注册手机号,
	case when a.have_send = '1' then '已发放'
		when a.have_send = '0' then '未发放'
		end 奖品是否发放,
	a.create_time 抽奖时间,
	b.prize_name 中奖奖品
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code and b.is_deleted=0
	left join `member`.tc_member_info tmi on a.member_id =tmi.id
	where a.lottery_code = 'test_driver'   -- 筛选试驾活动
	and date(a.create_time) between '{d_start_jidu}' and '{d_end}' -- 季度初
	and a.have_win = 1   -- 中奖
	order by a.create_time
) f on r.be_invite_member_id = f.被邀请人会员ID
left join
(
	--  邀约表用户留资并购车，购车状态有效明细（不涉及判断奖励发放，只要用户留资并购车，订单有效就算）
	select
    r.id,
	r.invite_member_id 邀请人会员ID,
	r.invite_mobile 邀请人手机号,
	r.be_invite_member_id 被邀请人会员ID,
	r.be_invite_mobile 被邀请人手机号,
	r.order_no 订单号,
	r.invoice_no 发票号,
	r.blue_invoice_time 蓝票开票时间,
	r.order_time 订单时间,
	r.payment_time 定金支付时间,
	case when r.is_large_set = 1 then '是'
		when r.is_large_set = 2 then '否'
		end 是否大定订单,
	r.vehicle_name 车型,
	r.create_time 留资时间,
	tc.CODE_CN_DESC 订单状态,
	tso.OWNER_CODE 经销商编号,
	tso.DRAWER_NAME 开票人姓名,
	tsov.SALES_VIN 车架号
	from invite.tm_invite_record r
	left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 'N'
	left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
	left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
	where r.is_deleted = 0
	and r.order_status in ('14041008','14041003')   -- 有效订单
	and r.order_no is not NULL   -- 筛选订单号不为空
	and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
	and r.red_invoice_time is null   -- 红冲发票为空
	and date(r.create_time) between '{d_start_jidu}' and '{d_end}' -- 季度初
	order by r.create_time
) g on r.id = g.id -- r.be_invite_member_id = g.被邀请人会员ID and r.order_no = g.订单号
left join
(
	-- 邀请人、被邀请人购车奖励
	select
    r.id,
	r.invite_member_id 邀请人会员ID,
	r.invite_mobile 邀请人手机号,
	r.be_invite_member_id 被邀请人会员ID,
	r.be_invite_mobile 被邀请人手机号,
	r.buy_expire_time 邀约购车到期时间,
	r.reserve_time 留资时间,
	r.order_no 订单号,
	r.order_time 订单时间,
	r.blue_invoice_time 蓝票开票时间,
	r.is_large_set 是否大定订单,
	r.reward_invite_num 邀约人购车奖励,
	case when r.reward_status = 0 then '待审核'
		when r.reward_status = 1 then '已发放'
		when r.reward_status = 2 then '审核不通过'
		when r.reward_status = 3 then '发放失败'
		end 邀约人购车奖励状态,
	r.reward_be_invite_num 被邀约人购车V值奖励,
	case when r.reward_be_invite_num is not null and r.reward_status = 0 then '待审核'
		when r.reward_be_invite_num is not null and r.reward_status = 1 then '已发放'
		when r.reward_be_invite_num is not null and r.reward_status = 2 then '审核不通过'
		when r.reward_be_invite_num is not null and r.reward_status = 3 then '发放失败'
		end 被邀约人购车奖励状态,
	r.create_time 留资时间,
	r.is_bonus 额外奖励,
	r.bonus 奖励V值量,
	r.order_status 订单状态
	from invite.tm_invite_record r
	where r.order_status in ('14041008','14041003')   -- 有效订单
	and date(r.create_time) between '{d_start_jidu}' and '{d_end}' -- 季度初
	and r.is_deleted = 0
	and r.order_no is not null     -- 订单号不为空
	and r.red_invoice_time is null     -- 红冲发票为空
	and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
	and r.order_time >= r.reserve_time and r.order_time <= r.buy_expire_time    -- 订单时间大于等于留资时间，且订单时间小于等于邀约购车截止时间
	and ((r.is_large_set = 1 and r.payment_time is not null and r.payment_time >= r.reserve_time and r.payment_time <= r.buy_expire_time)       -- 如果是付大定订单，则付大定时间不为空，且付大定时间大于等于留资时间且付大定时间小于等于邀约购车截止时间
	or (r.is_large_set = 2 and r.blue_invoice_time is not null and r.blue_invoice_time >= r.reserve_time and r.blue_invoice_time <= r.buy_expire_time))      -- 如果是其他时间，则蓝票开票时间不为空，且蓝票开票时间大于等于留资时间且蓝票开票时间小于等于邀约购车截止时间
) h on h.id=r.id  --r.be_invite_member_id = h.被邀请人会员ID and r.order_no = h.订单号
left join
(
	-- 加电券数量
	select i.会员ID,COUNT(i.核销码) 加电券数量 from
	(
		-- 加电券领用情况
		SELECT 
		a.id,
		a.one_id,
		b.id 卡券ID,
		b.coupon_name 卡券名称,
		a.left_value/100 面额,
		b.coupon_code 券号,
		tmi.ID 会员ID,
		a.vin 购买VIN,
		a.get_date 获得时间,
		a.activate_date 激活时间,
		a.expiration_date 卡券失效日期,
		CAST(a.exchange_code as varchar) 核销码,
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
		v.*
		FROM coupon.tt_coupon_detail a 
		JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
		left join `member`.tc_member_info tmi on a.one_id = tmi.CUST_ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
		LEFT JOIN (
		select v.coupon_detail_id
		,v.customer_name 核销用户名
		,v.customer_mobile 核销手机号
		,v.verify_amount 
		,IFNULL(v.dealer_code,v.dealer)  核销经销商
		,v.vin 核销VIN
		,v.operate_date 核销时间
		,v.order_no 订单号
		,v.PLATE_NUMBER
		from coupon.tt_coupon_verify v 
		where v.is_deleted = 0
		order by v.create_time 
		) v ON v.coupon_detail_id = a.id
		WHERE a.coupon_id in ('3801','2936')    -- 卡券ID
		and date(a.get_date) between '{d_start_jidu}' and '{d_end}'  -- 季度初     -- 卡券获取时间
		and a.is_deleted = 0
		order by a.get_date
	) i
	group by 1
) i on r.be_invite_member_id = i.会员ID
where date(r.create_time) between '{d_start_jidu}' and '{d_end}'
and r.is_deleted = 0
order by r.create_time




--  邀约表用户留资并购车，购车状态有效明细（不涉及判断奖励发放，只要用户留资并购车，订单有效就算）
select 
date_format(x.t,'%Y-%m'),
count(x2.被邀请人会员ID)
from 
(
select
    r.id,
	r.invite_member_id 邀请人会员ID,
	r.invite_mobile 邀请人手机号,
	r.be_invite_member_id 被邀请人会员ID,
	r.be_invite_mobile 被邀请人手机号,
	date(r.order_time) t
	from invite.tm_invite_record r
	left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 'N'
	left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
	left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
	where r.is_deleted = 0
	and r.order_status in ('14041008','14041003')   -- 有效订单
	and r.order_no is not NULL   -- 筛选订单号不为空
	and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
	and r.red_invoice_time is null   -- 红冲发票为空
	and year(r.create_time)='2024'
	and date(r.order_time) >= '2024-01-01' 
	and date(r.order_time) < '2024-10-01' -- 季度初
	order by r.create_time
)x
join (
select
    r.id,
	r.invite_member_id 邀请人会员ID,
	r.invite_mobile 邀请人手机号,
	r.be_invite_member_id 被邀请人会员ID,
	r.be_invite_mobile 被邀请人手机号
	from invite.tm_invite_record r
	left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 'N'
	left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
	left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
	where r.is_deleted = 0
	and r.order_status in ('14041008','14041003')   -- 有效订单
	and r.order_no is not NULL   -- 筛选订单号不为空
	and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
	and r.red_invoice_time is null   -- 红冲发票为空
	and year(r.create_time)='2024'
	and date(r.order_time) >= '2024-01-01' 
	and date(r.order_time) < '2024-10-01' -- 季度初
	order by r.create_time
)x2 on x2.邀请人会员ID=x.被邀请人会员ID
group by 1 
order by 1 

--  B接受A邀请（A于24年受邀成功）成功购车后，再邀请C成功购车推荐人人数
select 
date_format(x2.t,'%Y-%m'),
count(x3.被邀请人会员ID)
from 
(
select
    r.id,
	r.invite_member_id 邀请人会员ID,
	r.invite_mobile 邀请人手机号,
	r.be_invite_member_id 被邀请人会员ID,
	r.be_invite_mobile 被邀请人手机号,
	date(r.order_time) t
	from invite.tm_invite_record r
	left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 'N'
	left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
	left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
	where r.is_deleted = 0
	and r.order_status in ('14041008','14041003')   -- 有效订单
	and r.order_no is not NULL   -- 筛选订单号不为空
	and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
	and r.red_invoice_time is null   -- 红冲发票为空
	and year(r.create_time)='2024'
	and date(r.order_time) >= '2024-01-01' 
	and date(r.order_time) < '2024-10-01' -- 季度初
	order by r.create_time
)x
join (
select
    r.id,
	r.invite_member_id 邀请人会员ID,
	r.invite_mobile 邀请人手机号,
	r.be_invite_member_id 被邀请人会员ID,
	r.be_invite_mobile 被邀请人手机号,
	date(r.order_time) t
	from invite.tm_invite_record r
	left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 'N'
	left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
	left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
	where r.is_deleted = 0
	and r.order_status in ('14041008','14041003')   -- 有效订单
	and r.order_no is not NULL   -- 筛选订单号不为空
	and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
	and r.red_invoice_time is null   -- 红冲发票为空
	and year(r.create_time)='2024'
	and date(r.order_time) >= '2024-01-01' 
	and date(r.order_time) < '2024-10-01' -- 季度初
	order by r.create_time
)x2 on x2.邀请人会员ID=x.被邀请人会员ID
join (
select
    r.id,
	r.invite_member_id 邀请人会员ID,
	r.invite_mobile 邀请人手机号,
	r.be_invite_member_id 被邀请人会员ID,
	r.be_invite_mobile 被邀请人手机号
	from invite.tm_invite_record r
	left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 'N'
	left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
	left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
	where r.is_deleted = 0
	and r.order_status in ('14041008','14041003')   -- 有效订单
	and r.order_no is not NULL   -- 筛选订单号不为空
	and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
	and r.red_invoice_time is null   -- 红冲发票为空
	and year(r.create_time)='2024'
	and date(r.order_time) >= '2024-01-01' 
	and date(r.order_time) < '2024-10-01' -- 季度初
	order by r.create_time
)x3 on x3.邀请人会员ID=x2.被邀请人会员ID
group by 1 
order by 1 


--推荐人等级变化
select
ifnull(x.NEW_LEVEL_ID,tmi.level_id),
count(distinct r.invite_member_id) 推荐人会员ID
from invite.tm_invite_record r
left join 
	(select  x.MEMBER_ID,
	x.NEW_LEVEL_ID
	from 
			(
			select MEMBER_ID 
			,c.OLD_LEVEL_ID 
			,c.NEW_LEVEL_ID 
			,c.EVENT_DESC
			,c.CREATE_TIME 
			,row_number ()over(partition by MEMBER_ID order by c.CREATE_TIME desc) rk 
			from "member".tt_member_level_change c
			where 1=1
			and c.LEVEL_TYPE is not null 
			and c.STATUS =1
			and c.IS_DELETED =0
			--and MEMBER_ID='3301769'
			and c.EVENT_DESC in ('等级降级','等级升级')
			--and c.CREATE_TIME>='2023-07-06'
			and c.CREATE_TIME<'2024-10-01'
			order by 1 
			)x where x.rk=1
		)x on x.MEMBER_ID=r.invite_member_id
left join "member".tc_member_info tmi on tmi.id=r.invite_member_id
where r.is_deleted = 0
and date(r.create_time) >= '2024-01-01' 
and date(r.create_time) < '2024-10-01' -- 季度初
group by 1 
order by 1 

--推荐人V值变化
select 
case when x.`截止日期V值余额` >=0 and x.`截止日期V值余额` <=1000 then '01V值区间0-1000 人数'
	 when x.`截止日期V值余额` >=1001 and x.`截止日期V值余额` <=3000 then '02V值区间'
	 when x.`截止日期V值余额` >=3001 and x.`截止日期V值余额` <=5000 then '03V值区间'
	  when x.`截止日期V值余额` >=5001 and x.`截止日期V值余额` <=6000 then '04V值区间'
	   when x.`截止日期V值余额` >=7001 and x.`截止日期V值余额` <=10000 then '05V值区间'
	    when x.`截止日期V值余额` >=10001 and x.`截止日期V值余额` <=20000 then '061V值区间'
	     when x.`截止日期V值余额` >=20001 and x.`截止日期V值余额` <=30000 then '07V值区间'
	      when x.`截止日期V值余额` >=30001 then '08V值区间' 
	      else null end `分组`,
	 count(distinct x.id)
from 
	(
	-- 沃世界V值过期数据
	select a.id
	,c.`截止日期V值余额`
	from (	-- 发起过推荐购的人
			select distinct tir.invite_member_id id
			from invite.tm_invite_record tir 
			where tir.is_deleted = 0
			and date(tir.create_time) < '2024-02-01'
			and date(tir.create_time)  >= '2024-01-01'  
		--	and be_invite_member_id is not null
			) a 
	left join(
		 -- 历史节点剩余V值
		 select f.MEMBER_ID,m.MEMBER_V_NUM
		 ,m.MEMBER_V_NUM-sum(case when f.create_time>'2024-02-01' then 
					case when f.RECORD_TYPE=1 then -f.INTEGRAL when f.RECORD_TYPE=0 then f.INTEGRAL else 0 end 
					else 0 end) `截止日期V值余额`
		 from member.tt_member_flow_record f
		 join member.tc_member_info m on f.MEMBER_ID=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
		 where f.create_time >'2024-02-01' 
		 and f.IS_DELETED=0 
	--	 and f.MEMBER_ID=4270038
		 GROUP BY 1,2
	) c on c.MEMBER_ID=a.id
)x 
where x.`截止日期V值余额`>=0 and x.`截止日期V值余额` is not null 
group by 1
order by 1 
