select * from track.track t where t.usertag = '6039075' order by t.`date` desc

 

-- 王者荣耀活动PV UV  kingGlory_home_ONLOAD   MH6nGzQcHz
select 
-- DATE_FORMAT(t.date,'%Y-%m-%d'),
case when t.typeid ='XWSJXCX_START' then '01 启动小程序'
 when json_extract(t.`data`,'$.embeddedpoint')= 'kingGlory_home_ONLOAD' then '02 王者荣耀挑战赛主页面' 
end '分类',
count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2022-08-01'   -- 每天修改起始时间
and t.`date` <= '2022-08-03 23:59:59'  -- 每天修改截止时间
group by 1
order by 1

-- 王者荣耀活动PV UV  总
select 
-- DATE_FORMAT(t.date,'%Y-%m-%d'),
case when t.typeid ='XWSJXCX_START' then '01 启动小程序'
 when json_extract(t.`data`,'$.embeddedpoint')= 'kingGlory_home_ONLOAD' then '02 王者荣耀挑战赛主页面' 
end '分类',
-- count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
-- count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2022-07-16'   -- 每天修改起始时间
and t.`date` <= '2022-08-03 23:59:59'  -- 每天修改截止时间
group by 1
order by 1


-- 活动拉新人数、排除车主
select 
-- DATE_FORMAT(t.date,'%Y-%m-%d'),
count(DISTINCT m.id)拉新人数
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.is_vehicle = 0  -- 排除车主
where t.date >= '2022-08-01' and t.date <= '2022-08-03 23:59:59' 
and json_extract(t.`data`,'$.embeddedpoint')='kingGlory_home_ONLOAD'
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
-- group by 1 
order by 1


-- 僵尸粉-track表计算
select
-- DATE_FORMAT(a.tt,'%Y-%m-%d'),
a.is_vehicle 是否车主,
-- ,a.usertag
count(distinct a.usertag) 激活数量
from(
	 -- 获取访问文章活动10分钟之前的最晚访问时间
	 select t.usertag,b.mdate,b.is_vehicle,max(t.date) tdate,b.tt
	 from track.track t
	 join (
	  -- 获取访问文章活动的最早时间
	  select m.is_vehicle,t.usertag,min(t.date) mdate ,t.date tt
	  from track.track t 
	  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
	  where json_extract(t.`data`,'$.embeddedpoint')='kingGlory_home_ONLOAD'
	  and t.`date` >= '2022-08-01' and t.`date` < '2022-08-03 23:59:59' 
	  GROUP BY 1,2
	 ) b on b.usertag=t.usertag
	 where t.date< DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
	 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1
order by 1 desc 


-- {"embeddedpoint":"QIANDAO_首页逛一逛_ONCLICK","ip":"118.178.15.230","type":"modal","ua":"Mozilla/5.0 (iPhone; CPU iPhone OS 15_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.25(0x18001927) NetType/WIFI Language/zh_CN"}
-- 外部入口PVUV
select
-- DATE_FORMAT(t.date,'%Y-%m-%d'),
case 
when t.data like '%294B04BD75854D5285ADB4B1AD5EDB49%' then '01推文'
when t.data like '%408331E3D26F4111A8943BBDD355A22E%' then '02月历订阅UV'
when t.data like '%FDCC5BFF885B43CA9195D633D2E07453%' then '03朋友圈海报'
when t.data like '%8550CF5EB7864D9C9946EBBC84D6CBC8%' then '04POSM物料太阳码海报'
when t.data like '%8AD3C75A82B345F6BAF57D166CA5B6CE%' then '05首页banner'
when t.data like '%A29D9014A389477F9BA93622427F82AB%' then '06首页活动'
when t.data like '%93C6576092C7432386E3A40E722663C7%' then '07弹窗'
when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_首页逛一逛_ONCLICK' then '08签到'
when t.data like '%5DFB99121EE84B75910D9CB0301155FD%' then '09一店一码'
when json_extract(t.`data`,'$.embeddedpoint')='kingGlory_homeJustBuy_CLICK' then '10即刻报名button'
when json_extract(t.`data`,'$.embeddedpoint')='kingGlory_signSubmit_CLICK' then '11提交报名申请button'
when json_extract(t.`data`,'$.embeddedpoint')='kingGlory_signSureAgain_CLICK' then '12确认提交button'
when json_extract(t.`data`,'$.embeddedpoint')='kingGlory_signShare_CLICK' then '13一键分享，邀请组队button'
else null end '分类',
count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2022-08-01'   -- 每天修改起始时间
and t.`date` <= '2022-08-03 23:59:59'  -- 每天修改截止时间
group by 1
order by 1

-- 总 UV
-- 外部入口PVUV
select 
-- DATE_FORMAT(t.date,'%Y-%m-%d'),
case 
when t.data like '%294B04BD75854D5285ADB4B1AD5EDB49%' then '01推文'
when t.data like '%408331E3D26F4111A8943BBDD355A22E%' then '02月历订阅UV'
when t.data like '%FDCC5BFF885B43CA9195D633D2E07453%' then '03朋友圈海报'
when t.data like '%8550CF5EB7864D9C9946EBBC84D6CBC8%' then '04POSM物料太阳码海报'
when t.data like '%8AD3C75A82B345F6BAF57D166CA5B6CE%' then '05首页banner'
when t.data like '%A29D9014A389477F9BA93622427F82AB%' then '06首页活动'
when t.data like '%93C6576092C7432386E3A40E722663C7%' then '07弹窗'
when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_首页逛一逛_ONCLICK' then '08签到'
when t.data like '%5DFB99121EE84B75910D9CB0301155FD%' then '09一店一码'
when json_extract(t.`data`,'$.embeddedpoint')='kingGlory_homeJustBuy_CLICK' then '10即刻报名button'
when json_extract(t.`data`,'$.embeddedpoint')='kingGlory_signSubmit_CLICK' then '11提交报名申请button'
when json_extract(t.`data`,'$.embeddedpoint')='kingGlory_signSureAgain_CLICK' then '12确认提交button'
when json_extract(t.`data`,'$.embeddedpoint')='kingGlory_signShare_CLICK' then '13一键分享，邀请组队button'
else null end '分类',
-- count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
-- count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2022-07-16'   -- 每天修改起始时间
and t.`date` <= '2022-08-03 23:59:59'  -- 每天修改截止时间
group by 1
order by 1

-- 卡券领用核销数量
select 
-- DATE_FORMAT(x.核销时间,'%Y-%m-%d')日期,
case when x.卡卷id =3693 then '01空调清洗剂'
	when x.卡卷id =3692 then '02燃油添加剂'
	else null end as 'xx',
count (x.coupon_detail_id)
from 
(SELECT 
a.id,
m.REAL_NAME,
m.MEMBER_PHONE,
a.one_id,
b.id coupon_id,
a.coupon_id 卡卷id,
b.coupon_name 卡券名称,
b.coupon_code 券号,
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
left JOIN (
select v.coupon_detail_id
,v.customer_name 核销用户名
,v.customer_mobile 核销手机号 
,v.dealer_code 核销经销商
,v.vin 核销VIN
,v.operate_date 核销时间
,v.order_no 订单号
,v.PLATE_NUMBER
from coupon.tt_coupon_verify v 
where v.is_deleted=0
order by v.create_time 
) v ON v.coupon_detail_id = a.id
left join member.tc_member_info m on a.one_id =m.CUST_ID and m.IS_DELETED =0 and m.MEMBER_STATUS <> 60341003
WHERE a.coupon_id 
in
(
'3693',
'3692'
)
and v.核销时间 >= '2022-07-16'
and v.核销时间 <= '2022-08-03 23:59:59'
and a.is_deleted=0
-- and a.ticket_state=31061003
order by 11 desc )x
group by 1
order by 1

-- 卡券明细
select 
sao.member_id,
sao.sku_id,
case when sao.sku_id =7851 then '王者空调清洗剂券'
	when sao.sku_id =7850 then '王者燃油添加剂券'
	else null end as '卡券名称',
tmi.MEMBER_NAME,
-- tmi.MEMBER_PHONE,
'1' 领取数量,
sao.vin 领券车架号,
sao.dealer_code 领券经销商代码,
sao.create_date 领券时间,
v.*
FROM volvo_online_activity.season_activity_order sao 
left join `member`.tc_member_info tmi on sao.member_id =tmi.ID 
left JOIN (
select v.coupon_detail_id
,v.customer_name 核销用户名
-- ,v.customer_mobile 核销手机号
,v.dealer_code 核销经销商
,v.vin 核销VIN
,v.operate_date 核销时间
-- ,v.order_no 订单号
-- ,v.PLATE_NUMBER
from coupon.tt_coupon_verify v 
where v.is_deleted=0
and v.coupon_id in ('3693','3692')
order by v.create_time 
) v ON sao.vin=v.核销VIN 
where sao.sku_id in ('7851','7850')
and sao.create_date >= '2022-07-16'
and sao.create_date <= '2022-08-03 23:59:59'
and sao.receive_coupon_result in ('2','1') -- 卡券接受状态部分接受 全部接受
order by sao.create_date

-- 王者荣耀报名数据
SELECT a.id 序号,
a.member_name 姓名,
a.identity_card 身份证号,
a.wechat_account 微信号,
a.phone 手机号,
a.address 收货地址,
a.dealer_code 报名经销商代码,
a.dealer_name 报名经销商,
a.group_team '战队情况（A/B/C）',
a.positions 擅长位置
from volvo_online_activity.glory_kings_info a
where a.create_date >= '2022-07-16'
and a.create_date <= '2022-08-03 23:59:59'
and a.delete_flag =0
order by 1

-- 成功组队
select x.报名经销商,
x.报名经销商代码,
x.'战队情况（A/B/C）',
count(x.序号) 组队人数
from 
(SELECT a.id 序号,
a.member_name 姓名,
a.identity_card 身份证号,
a.wechat_account 微信号,
a.phone 手机号,
a.address 收货地址,
a.dealer_name 报名经销商,
a.dealer_code 报名经销商代码,
a.group_team '战队情况（A/B/C）',
a.positions 擅长位置
from volvo_online_activity.glory_kings_info a
where a.create_date >= '2022-07-16'
and a.create_date <= '2022-08-03 23:59:59'
and a.delete_flag =0)x
group by 2,3
HAVING count(x.序号)>=5

-- 调剂明细 ： 已成功报名，未成功组队人群。
SELECT a.id 序号,
a.member_name 姓名,
a.identity_card 身份证号,
a.wechat_account 微信号,
a.phone 手机号,
a.address 收货地址,
a.dealer_code 报名经销商代码,
a.group_team '战队情况（A/B/C）',
a.positions 擅长位置,
xx.卡券名称,
xx.领券车架号,
xx.领券经销商代码,
xx.MEMBER_PHONE 购券手机号
from volvo_online_activity.glory_kings_info a
left join 
	(
	select 
	sao.member_id,
	sao.sku_id,
	case when sao.sku_id =7851 then '王者空调清洗剂券'
		when sao.sku_id =7850 then '王者燃油添加剂券'
		else null end as '卡券名称',
	tmi.MEMBER_NAME,
	tmi.MEMBER_PHONE,
	'1' 领取数量,
	sao.vin 领券车架号,
	sao.dealer_code 领券经销商代码,
	sao.create_date 领券时间,
	v.*
	FROM volvo_online_activity.season_activity_order sao 
	left join `member`.tc_member_info tmi on sao.member_id =tmi.ID 
	left JOIN (
	select v.coupon_detail_id
	,v.customer_name 核销用户名
	-- ,v.customer_mobile 核销手机号
	,v.dealer_code 核销经销商
	,v.vin 核销VIN
	,v.operate_date 核销时间
	-- ,v.order_no 订单号
	-- ,v.PLATE_NUMBER
	from coupon.tt_coupon_verify v 
	where v.is_deleted=0
	and v.coupon_id in ('3693','3692')
	order by v.create_time 
	) v ON sao.vin=v.核销VIN 
	where sao.sku_id in ('7851','7850')
	and sao.create_date >= '2022-07-16'
	and sao.create_date <= '2022-08-03 23:59:59'
	and sao.receive_coupon_result in ('2','1') -- 卡券接受状态部分接受 全部接受
	order by sao.create_date
	)xx on xx.member_id=a.member_id 
where a.create_date >= '2022-07-16'
and a.create_date <= '2022-08-03 23:59:59'
and a.delete_flag =0
and CONCAT(a.dealer_code,a.group_team) in 
	(select CONCAT(x.报名经销商代码,x.'战队情况（A/B/C）')
	from 
	(select x.报名经销商,
	x.报名经销商代码,
	x.'战队情况（A/B/C）',
	count(x.序号) 组队人数
	from 
	(SELECT a.id 序号,
	a.member_name 姓名,
	a.identity_card 身份证号,
	a.wechat_account 微信号,
	a.phone 手机号,
	a.address 收货地址,
	a.dealer_name 报名经销商,
	a.dealer_code 报名经销商代码,
	a.group_team '战队情况（A/B/C）',
	a.positions 擅长位置
	from volvo_online_activity.glory_kings_info a
	where a.create_date >= '2022-07-16'
	and a.create_date <= '2022-08-03 23:59:59'
	and a.delete_flag =0)x
	group by 2,3
	HAVING count(x.序号)<5)x
	)
order by 1


-- 报名手机号和购券手机号不一致的
SELECT 
a.member_name 姓名,
x.卡券名称,
x.MEMBER_PHONE 购券手机号,
x.领券时间 购券时间,
x.领券车架号,
x.领券经销商代码,
a.phone 报名手机号,
a.dealer_code 报名经销商代码,
a.group_team '战队情况（A/B/C）'
from volvo_online_activity.glory_kings_info a
left join 
	(select 
	sao.member_id,
	sao.sku_id,
	case when sao.sku_id =7851 then '王者空调清洗剂券'
		when sao.sku_id =7850 then '王者燃油添加剂券'
		else null end as '卡券名称',
	tmi.MEMBER_NAME,
	tmi.MEMBER_PHONE,
	'1' 领取数量,
	sao.vin 领券车架号,
	sao.dealer_code 领券经销商代码,
	sao.create_date 领券时间,
	v.*
	FROM volvo_online_activity.season_activity_order sao 
	left join `member`.tc_member_info tmi on sao.member_id =tmi.ID 
	left JOIN (
	select v.coupon_detail_id
	,v.customer_name 核销用户名
	-- ,v.customer_mobile 核销手机号
	,v.dealer_code 核销经销商
	,v.vin 核销VIN
	,v.operate_date 核销时间
	-- ,v.order_no 订单号
	-- ,v.PLATE_NUMBER
	from coupon.tt_coupon_verify v 
	where v.is_deleted=0
	and v.coupon_id in ('3693','3692')
	order by v.create_time 
	) v ON sao.vin=v.核销VIN 
	where sao.sku_id in ('7851','7850')
	and sao.create_date >= '2022-07-16'
	and sao.create_date <= '2022-08-03 23:59:59'
	and sao.receive_coupon_result in ('2','1') -- 卡券接受状态部分接受 全部接受
	order by sao.create_date)x on x.member_id=a.member_id 
where a.create_date >= '2022-07-16'
and a.create_date <= '2022-08-03 23:59:59'
and a.delete_flag =0
and a.phone <> x.MEMBER_PHONE
order by 1

-- 购券未报名
select 
ROW_NUMBER () over(order by sao.create_date) 序号,
-- sao.member_id 会员id,
tmi.MEMBER_NAME 姓名,
tmi.MEMBER_PHONE 手机号,
case when sao.sku_id =7851 then '王者空调清洗剂券'
	when sao.sku_id =7850 then '王者燃油添加剂券'
	else null end as '卡券名称',
-- sao.dealer_code 领券经销商代码,
sao.create_date 领券时间
FROM volvo_online_activity.season_activity_order sao 
left join `member`.tc_member_info tmi on sao.member_id =tmi.ID 
left JOIN (
select v.coupon_detail_id
,v.customer_name 核销用户名
-- ,v.customer_mobile 核销手机号
,v.dealer_code 核销经销商
,v.vin 核销VIN
,v.operate_date 核销时间
-- ,v.order_no 订单号
-- ,v.PLATE_NUMBER
from coupon.tt_coupon_verify v 
where v.is_deleted=0
and v.coupon_id in ('3693','3692')
order by v.create_time 
) v ON sao.vin=v.核销VIN 
where sao.sku_id in ('7851','7850')
and sao.create_date >= '2022-07-16'
and sao.create_date <= '2022-08-03 23:59:59'
and sao.receive_coupon_result in ('2','1') -- 卡券接受状态部分接受 全部接受
-- order by sao.create_date
and sao.member_id not in 
	(
	select x.member_id
	from 
		(
		-- 买票又报名
		SELECT a.id 序号,
		a.member_id,
		a.member_name 姓名,
		a.identity_card 身份证号,
		a.wechat_account 微信号,
		a.phone 手机号,
		a.address 收货地址,
		a.dealer_name 报名经销商,
		a.dealer_code 报名经销商代码,
		a.group_team '战队情况（A/B/C）',
		a.positions 擅长位置
		from volvo_online_activity.glory_kings_info a
		join 
			(
			select 
			sao.member_id,
			sao.sku_id,
			case when sao.sku_id =7851 then '王者空调清洗剂券'
				when sao.sku_id =7850 then '王者燃油添加剂券'
				else null end as '卡券名称',
			tmi.MEMBER_NAME,
			-- tmi.MEMBER_PHONE,
			'1' 领取数量,
			sao.vin 领券车架号,
			sao.dealer_code 领券经销商代码,
			sao.create_date 领券时间,
			v.*
			FROM volvo_online_activity.season_activity_order sao 
			left join `member`.tc_member_info tmi on sao.member_id =tmi.ID 
			left JOIN (
			select v.coupon_detail_id
			,v.customer_name 核销用户名
			-- ,v.customer_mobile 核销手机号
			,v.dealer_code 核销经销商
			,v.vin 核销VIN
			,v.operate_date 核销时间
			-- ,v.order_no 订单号
			-- ,v.PLATE_NUMBER
			from coupon.tt_coupon_verify v 
			where v.is_deleted=0
			and v.coupon_id in ('3693','3692')
			order by v.create_time 
			) v ON sao.vin=v.核销VIN 
			where sao.sku_id in ('7851','7850')
			and sao.create_date >= '2022-07-16'
			and sao.create_date <= '2022-08-03 23:59:59'
			and sao.receive_coupon_result in ('2','1') -- 卡券接受状态部分接受 全部接受
			order by sao.create_date
		) x on a.member_id=x.member_id
		where a.create_date >= '2022-07-16'
		and a.create_date <= '2022-08-03 23:59:59'
		and a.delete_flag =0
	)x)
	order by sao.create_date desc 
	

-- 活动评论数据
select
DISTINCT teh.id,
teh.object_id 活动ID,
teh.content 评价内容,
case when teh.is_top = '10041001' then '是'
	else '否' end '是否置顶',
teh.create_time 评论时间,
teh.evaluation_source 评论来源,
teh.user_id 评论用户ID,
teh.name 评论姓名,
teh.mobile 评论用户手机号,
tmi.ID 会员ID,
tmi.MEMBER_PHONE 沃世界绑定手机号,
teh.liked_count 点赞数
-- tep.picture_url 
from comment.tt_evaluation_history teh
-- left join comment.tc_evaluation_picture tep on tep.evaluation_id = teh.id  -- 关联评论图片表会有重复图片导致重复数据
left join `member`.tc_member_info tmi on teh.user_id = tmi.id
where teh.object_id = 'MH6nGzQcHz'
and teh.create_time >= '2022-07-16 00:00:00'
and teh.create_time <= '2022-08-03 23:59:59'
and teh.is_deleted = 0
and tmi.MEMBER_PHONE<>'*'
and teh.is_display =10041001 -- 前段释放评论
order by teh.create_time desc