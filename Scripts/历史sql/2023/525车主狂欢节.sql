select * from track.track t where t.usertag = '6039075' order by t.`date` desc

-- 沃世界活动PV UV  
select
case when t.typeid ='XWSJXCX_START' then '01 启动小程序'
 when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_home_ONLOAD' then '02 525车主狂欢节主页面' 
else null end '分类',
count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2022-06-28'   -- 每天修改起始时间
and t.`date` <= '2022-06-30 23:59:59'  -- 每天修改截止时间
group by 1
order by 1

-- 沃世界活动PV UV  总
select
case when t.typeid ='XWSJXCX_START' then '01 启动小程序'
 when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_home_ONLOAD' then '02 525车主狂欢节主页面' 
else null end '分类',
count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2022-05-25'   -- 每天修改起始时间
and t.`date` <= '2022-06-30 23:59:59'  -- 每天修改截止时间
group by 1
order by 1

-- 拉新人数
select 
case when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_home_ONLOAD' then '525车主狂欢节主页面'	
	else null end '入口',
count(distinct case when m.IS_VEHICLE = 0 then m.id end) 粉丝
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.IS_VEHICLE = 0
where t.`date` >='2022-06-28'   -- 每天修改起始时间
and t.`date` <= '2022-06-30 23:59:59'  -- 每天修改截止时间
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
group by 1;

-- 激活僵尸粉数
select
a.is_vehicle 是否车主,
count(distinct a.usertag) 激活数量
from(
 -- 获取访问文章活动10分钟之前的最晚访问时间
 select t.usertag,b.mdate,b.is_vehicle,max(t.date) tdate
 from track.track t
 join (
  -- 获取访问文章活动的最早时间
  select m.is_vehicle,t.usertag,min(t.date) mdate 
  from track.track t 
  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
  where json_extract(t.`data`,'$.embeddedpoint') = '525owner2022_home_ONLOAD'
  and t.`date` >='2022-06-28'   -- 每天修改起始时间
  and t.`date` <= '2022-06-30 23:59:59'  -- 每天修改截止时间
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date < DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1
ORDER BY 1 DESC;

-- 外部入口PVUV 总
select
case 
when t.data like '%48FBDF6C6D1940B8977FF203E4C4466C%' then '01推文'
when t.data like '%B38AEDC34E234ABDA0908EC0FDBF48F9%' then '02月历订阅UV'
when t.data like '%C33CB5D81418458F9849B01A536639B9%' then '03传播海报'
when t.data like '%2F28E54C8D54451B96474DCA11CFFC8B%' then '04主页面太阳码海报'
when t.data like '%41B2F0B02932413C9A04820A04186447%' then '05嘉实多王者荣耀套餐太阳码海报'
when t.data like '%3FB1B6595C484D0FB2A6D3F6102E04E1%' then '06极速性能套餐太阳码海报'
when t.data like '%51808A5275034355BFDAC97294727B06%' then '07安心舒适套餐太阳码海报'
else null end '分类',
count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2022-05-25'   -- 每天修改起始时间
and t.`date` <= '2022-06-30 23:59:59'  -- 每天修改截止时间
group by 1
order by 1

-- 外部入口PVUV
select
case 
when t.data like '%48FBDF6C6D1940B8977FF203E4C4466C%' then '01推文'
when t.data like '%B38AEDC34E234ABDA0908EC0FDBF48F9%' then '02月历订阅UV'
when t.data like '%C33CB5D81418458F9849B01A536639B9%' then '03传播海报'
when t.data like '%2F28E54C8D54451B96474DCA11CFFC8B%' then '04主页面太阳码海报'
when t.data like '%41B2F0B02932413C9A04820A04186447%' then '05嘉实多王者荣耀套餐太阳码海报'
when t.data like '%3FB1B6595C484D0FB2A6D3F6102E04E1%' then '06极速性能套餐太阳码海报'
when t.data like '%51808A5275034355BFDAC97294727B06%' then '07安心舒适套餐太阳码海报'
else null end '分类',
count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2022-06-28'   -- 每天修改起始时间
and t.`date` <= '2022-06-30 23:59:59'  -- 每天修改截止时间
group by 1
order by 1

-- 内部入口PVUV
select
case 
when t.data like '%6FC6FD261DBF41399E6B066D66C74C66%' then '01首页banner'
when t.data like '%ADFAFC649669456AB7B16DE5D5AF25E7%' then '02首页-活动'
when t.data like '%E722BD37473D486E87BE4CE2095045E0%' then '03沃的活动banner'
when t.data like '%A0DC8BBE15D143AD93C9529544292075%' then '04弹窗'
when t.data like '%EE39DB0D0CC840B1A51D40D4373557AC%' then '05签到'
when t.data like '%9632B4031E8A4C978D5D2CDD29363D7F%' then '06一店一码进入活动'
when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_orsKass_ONLOAD' then '07嘉实多王者荣耀套餐二级页面'
when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_orsKass_buy_CLICK' then '08嘉实多王者荣耀套餐二级页面-立即抢购'
-- when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_paySuccess_CLICK' then '09支付完成页面-领取赠品券'
when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_orsKass_gift_CLICK' then '10嘉实多王者荣耀套餐二级页面-领取赠品'
when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_orsKass_king_CLICK' then '11嘉实多王者荣耀套餐二级页面-领取王者荣耀周边'
-- when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_message_CLICK' then '11领取王者荣耀周边-提交收货信息-二次确认'
when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_peaceComfort_ONLOAD' then '12极速性能套餐二级页面'
when json_extract(t.`data`,'$.embeddedpoint')= '2022_05_525_carowner1_member_day_activity' then '13极速性能套餐二级页面-刹车盘抵扣券-立即订阅'
when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_peaceComfort_brake_CLICK' then '14极速性能套餐二级页面-刹车盘抵扣券-立即抢购'
when json_extract(t.`data`,'$.embeddedpoint')= '2022_05_525_carowner2_member_day_activity' then '15极速性能套餐二级页面-蓄电池抵用券-立即订阅'
when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_peaceComfort_battery_CLICK' then '16极速性能套餐二级页面-蓄电池抵用券-立即抢购'
when json_extract(t.`data`,'$.embeddedpoint')= '2022_05_525_carowner3_member_day_activity' then '17极速性能套餐二级页面-polostar抵扣券-立即订阅'
when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_peaceComfort_Polestar_CLICK' then '18极速性能套餐二级页面-polostar抵扣券-立即抢购'
when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_speedPerman_ONLOAD' then '19安心舒适套餐二级页面'
when json_extract(t.`data`,'$.embeddedpoint')= '525owner2022_speedPerman_CLICK' then '20安心舒适套餐二级页面-立即抢购'
else null end '分类',
count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 
where t.`date` >='2022-06-28'   -- 每天修改起始时间
and t.`date` <= '2022-06-30 23:59:59'  -- 每天修改截止时间
and tmi.IS_DELETED = 0
group by 1
order by 1

-- 抢购UV
select 
case when sao.sku_id =7815 or sao.sku_id =7816 then '嘉实多王者荣耀套餐成功抢购'
	 -- when sao.sku_id =7815 or sao.sku_id =7816 then '嘉实多王者荣耀套餐成功抢购'
	when sao.sku_id =7817 then '刹车片成功抢购UV'
	when sao.sku_id =7818 then '蓄电池成功抢购UV'
	when sao.sku_id =7819 then 'Polostar抵扣券成功抢购UV'
	when sao.sku_id =7820 then '延保抵扣券成功抢购 UV'
	end '抢购UV',
count(DISTINCT sao.member_id)
from volvo_online_activity.season_activity_order sao 
where sao.create_date >= '2022-06-28'   -- 每天修改起始时间
and sao.create_date<= '2022-06-30 23:59:59'	-- 每天修改截止时间
and sao.delete_flag =0
and sao.receive_coupon_result in ('2','1')
group by 1
order by sao.sku_id 

-- 购买套餐地址
select case when sao.sku_id =7815 then '嘉实多王者焕新版'
	when sao.sku_id =7816 then '嘉实多王者焕新plus增强版'
	end '所购套餐',
m.id 会员ID,
m.MEMBER_PHONE 手机号,
sao.order_code 订单号,
sao.create_date 购买时间,
d.CONSIGNEE_NAME 姓名,
d.CONSIGNEE_PHONE 电话,
CONCAT(b.address,b.number_plate) 收货地址,
d.address 会员默认收货地址
from volvo_online_activity.season_activity_order sao
left join `member`.tc_member_info m on m.ID =sao.member_id and m.IS_DELETED =0 and m.MEMBER_STATUS<>60341003 
left join (
	select a.*
	from (
		select m.id,m.REAL_NAME,a.CONSIGNEE_NAME,a.CONSIGNEE_PHONE,CONCAT(c.REGION_NAME,cc.REGION_NAME,ccc.REGION_NAME,a.MEMBER_ADDRESS) address
		,row_number() over(partition by a.MEMBER_ID order by a.create_time desc) rk
		from member.tc_member_info m 
		join member.tc_member_address a on m.id=a.member_id and a.IS_DEFAULT=1 and a.IS_DELETED=0
		left join dictionary.tc_region c on a.ADDRESS_PROVINCE=c.REGION_CODE
		left join dictionary.tc_region cc on a.ADDRESS_CITY=cc.REGION_CODE
		left join dictionary.tc_region ccc on a.ADDRESS_REGION=ccc.REGION_CODE
		where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	) a 
	where a.rk=1
) d on d.id=sao.member_id
left join volvo_online_activity.car_owner_info b on sao.order_code =b.order_code and b.delete_flag =0
where sao.create_date >= '2022-05-25'   -- 每天修改起始时间
and sao.create_date<= '2022-06-30 23:59:59'	-- 每天修改截止时间
and sao.delete_flag =0
and sao.receive_coupon_result in ('2','1') -- 卡券接受状态部分接受 全部接受
and sao.sku_id in ('7815','7816')

select
a.member_id 会员ID, 
a.name 姓名,
a.phone 手机号,
a.address  地址,
a.order_code 订单号,
b.spu_name  所购套餐
from   volvo_online_activity.car_owner_info  a
left join order.tt_order_product  b
on  a.order_code = b.order_code
where  b.is_deleted=0
and a.delete_flag =0
and a.create_date >= '2022-05-25 00:00:00'
and a.create_date <= '2022-07-01 00:00:00'



-- 卡券领用核销明细 总
SELECT
a.id,
m.id 会员id,
m.REAL_NAME,
m.MEMBER_PHONE,
a.one_id,
b.id coupon_id,
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
left join `member`.tc_member_info m on a.one_id =m.CUST_ID and m.IS_DELETED =0 and m.MEMBER_STATUS <> 60341003
left JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
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
WHERE a.coupon_id 
in
(
'3533',
'3534',
'3535',
'3536',
'3537',
'3538',
'3539',
'3540'
)
and a.get_date >= '2022-05-25'
and a.get_date <= '2022-06-30 23:59:59'
and a.is_deleted=0
order by 11 desc


-- 添加手机号 
select 
sao.vin,
sao.member_id,
tmi.MEMBER_NAME,
tmi.MEMBER_PHONE,
sao.dealer_code
FROM volvo_online_activity.season_activity_order sao 
left join `member`.tc_member_info tmi on sao.member_id =tmi.ID 
where sao.sku_id in ('7815',
'7816',
'7817',
'7818',
'7819',
'7820')
and sao.create_date >= '2022-05-25'
and sao.create_date <= '2022-06-30 23:59:59'


SELECT 
X.卡券名称,
COUNT(X.id)
FROM 
(SELECT
a.id,
m.REAL_NAME,
m.MEMBER_PHONE,
a.one_id,
b.id coupon_id,
a.coupon_id 卡卷,
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
WHERE 
a.coupon_id in ('3533','3534','3535','3536','3537','3538','3539','3540')
and a.get_date >= '2022-05-25'
and a.get_date <= '2022-06-30 23:59:59'
and a.is_deleted=0
order by 11 desc )X
group by 1

-- 卡券领用核销数量
select 
-- DATE_FORMAT(x.核销时间,'%Y-%m-%d')日期,
case when x.卡卷id =3533 then '01嘉实多王者焕新版-0W-20保养券 1份'
	when x.卡卷id =3535 then '02燃油添加剂'
	when x.卡卷id =3534 then '03嘉实多王者焕新PLUS增强版-0W-20保养券 2份'
	when x.卡卷id =3536 then '04刹车片抵扣券'
	when x.卡卷id =3537 then '05蓄电池抵扣券'
	when x.卡卷id =3538 then '06Polostar抵扣券'
	when x.卡卷id =3539 then '07延保抵扣券'
	when x.卡卷id =3540 then '08原厂后排舒适头枕兑换券（2只）'
	else null end as 'xx',
count (x.id)
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
WHERE a.coupon_id in ('3533',
'3534',
'3535',
'3536',
'3537',
'3538',
'3539',
'3540'
)
and v.核销时间 >= '2022-06-28'
and v.核销时间 <= '2022-06-30 23:59:59'
and a.is_deleted=0
and a.ticket_state=31061003
order by 11 desc )x
group by 1
order by 1
