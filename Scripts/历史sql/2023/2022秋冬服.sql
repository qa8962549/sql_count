select * from track.track t where t.usertag = '6039075' order by t.`date` desc

select
case 
when t.typeid ='XWSJXCX_START' then '启动小程序'#
when t.`data` like '%C6BDA35C6ECF4AD1BBF521B216B09037%' then '沃尔沃汽车公众号推文-主页'
when t.`data` like '%ED5312DFA35F488BAE375A399723180E%' then '沃尔沃汽车公众号推文-百万工时二级页'
when t.`data` like '%83FC44C6BA954907A278E57037A3DFD7%' then '沃尔沃汽车公众号推文-养护套餐二级页'
when t.`data` like '%0255C53D10D742C386D364A86C7756FF%' then '沃尔沃汽车公众号推文-免费检测二级页'
when t.`data` like '%EFA8CD4737264037ADB043254ED53DF1%' then '沃尔沃汽车沃世界公众号推文-主页'
when t.`data` like '%18E41D5FA04643829DEFE58F9D94BCF0%' then '沃尔沃汽车沃世界公众号推文-百万工时二级页'
when t.`data` like '%771F79BA1E9F414683EF73B83D64691C%' then '沃尔沃汽车沃世界公众号推文-养护套餐二级页'
when t.`data` like '%AB6921D414284759B29DC7950120812E%' then '沃尔沃汽车沃世界公众号推文-免费检测二级页'
when t.`data` like '%9BC59304A46B4C0FA2CF38EC1AA29976%' then '传播太阳码海报'
when t.`data` like '%3D6A3FEE47C04A4C8426954047340C75%' then '短信-人群包1'
when t.`data` like '%78A577AB959F4B74ADC459A5C37EA5EE%' then '短信-人群包2'
when t.`data` like '%FD96AC88B66844DEB88572CCDD7982DD%' then '短信-人群包3'
when t.`data` like '%D4A911111D25419BB6FA59AC4F2C983F%' then '短信-人群包4'
when t.`data` like '%702CE1D5BC394207AC2569091768FA3E%' then '首页banner'
when t.`data` like '%A190927B644040739BC8192F94ED8F16%' then '首页-活动'
when t.`data` like '%24339CA0F3A0440FA8A053FA378990B4%' then '沃的活动banner'
when t.`data` like '%939C5F348110475EB35151F182F86040%' then '弹窗'
when t.`data` like '%2DB903FCFAFE43399616D0DE2244D7FE%' then '活动月历-服务通知'
when t.`data` like '%497AFA65E9EB40A29080AA6EA34860F8%' then '扫码'
when json_extract(t.`data`,'$.embeddedpoint')=  'winter_home_ONLOAD' then '暖冬守护主页面'
when json_extract(t.`data`,'$.embeddedpoint')=  'memberDay11_home_冬季防寒防冻液_click' then '会员日-防寒保养套餐即刻抢购btn'
when json_extract(t.`data`,'$.embeddedpoint')=  'memberDay11_home_冬季防寒空调消杀_click' then '会员日-防潮保养套餐即刻抢购btn'
when json_extract(t.`data`,'$.embeddedpoint')=  'memberDay11_home_百万工时补贴_click' then '会员日-工时补贴即刻领取btn'
when json_extract(t.`data`,'$.embeddedpoint')=  'winter_coupons_ONLOAD' then '百万工时补贴-二级页面'
when json_extract(t.`data`,'$.embeddedpoint')=  'coupons_一键分享_CLICK' then '点击一键分享'
when json_extract(t.`data`,'$.embeddedpoint')=  'coupons_领取好礼_CLICK' then '点击领取好礼'
when json_extract(t.`data`,'$.embeddedpoint')=  '您已领取成功，请在“我的卡券”中查看卡券详情_查看卡券_CLICK' then '成功领取工时券'
when json_extract(t.`data`,'$.embeddedpoint')=  'winter_merchandise_ONLOAD' then '养护套餐5折起-二级页面'
when json_extract(t.`data`,'$.embeddedpoint')=  '冬季防寒保养套餐_立即购买_CLICK' then '成功购买防寒保养套餐-立即抢购'
when json_extract(t.`data`,'$.embeddedpoint')=  '冬季防寒保养套餐_领取赠品_CLICK' then '成功领取防寒保养套餐赠品'
when json_extract(t.`data`,'$.embeddedpoint')=  '冬季防潮保养套餐_立即购买_CLICK' then '成功购买防潮保养套餐-立即抢购'
when json_extract(t.`data`,'$.embeddedpoint')=  '冬季防潮保养套餐_领取赠品_CLICK' then '成功领取防潮保养套餐赠品'
when json_extract(t.`data`,'$.embeddedpoint')=  '冬季动力保养产品-燃油滤芯_立即购买_CLICK' then '成功购买燃油滤芯-立即抢购'
when json_extract(t.`data`,'$.embeddedpoint')=  '冬季动力保养产品-发动机空气滤芯_立即购买_CLICK' then '成功购买发动机空气滤芯'
when json_extract(t.`data`,'$.embeddedpoint')=  '冬季动力保养产品-火花塞_立即购买_CLICK' then '成功购买火花塞'
when json_extract(t.`data`,'$.embeddedpoint')=  '圣诞精品抢先购_立即购买_CLICK' then '成功购买圣诞礼盒'
when json_extract(t.`data`,'$.embeddedpoint')=  'maintain_立即预约_CLICK' then '点击立即预约'
else null end '分类',
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV,
COUNT(DISTINCT CASE WHEN tmi.is_vehicle =1 THEN t.usertag else null end) 车主UV,
COUNT(DISTINCT CASE WHEN tmi.is_vehicle =0 THEN t.usertag else null end) 粉丝UV
from track.track t
left join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2022-12-26' AND t.`date` <='2022-12-31 23:59:59'
group by 1
order by 1

-- 测试
select count(t.usertag)
from track.track t
where t.`date` >='2022-11-25' AND t.`date` <='2022-11-25 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint')='memberDay11_home_冬季防寒防冻液_click'
-- and json_extract(t.`data`,'$.embeddedpoint')=  'memberDay11_home_冬季防寒空调消杀_click' 
-- and json_extract(t.`data`,'$.embeddedpoint')=  'memberDay11_home_百万工时补贴_click'


-- 宣传渠道转化率
-- 转化人数
select 
'1短信',
count(distinct t.usertag) 粉丝
from track.track t
where t.`date` >='2022-11-25'   -- 每天修改起始时间
and t.`date` <='2022-12-31 23:59:59'  -- 每天修改截止时间
and t.`data` like '%3D6A3FEE47C04A4C8426954047340C75%'
or t.`data` like '%78A577AB959F4B74ADC459A5C37EA5EE%'
or t.`data` like '%FD96AC88B66844DEB88572CCDD7982DD%'
or t.`data` like '%D4A911111D25419BB6FA59AC4F2C983F%'
union all 
select 
'2会员日转化人数',
count(distinct t.usertag)
from track.track t
where t.`date` >='2022-11-25'   -- 每天修改起始时间
and t.`date` <='2022-12-31 23:59:59'  -- 每天修改截止时间
and json_extract(t.`data`,'$.embeddedpoint') in ('memberDay11_home_冬季防寒防冻液_click','memberDay11_home_冬季防寒空调消杀_click','memberDay11_home_百万工时补贴_click')
union all 
select 
'3活动月历转化人数',
count(distinct t.usertag)
from track.track t
where t.`date` >='2022-11-25'   -- 每天修改起始时间
and t.`date` <='2022-12-31 23:59:59'  -- 每天修改截止时间
and t.`data` like '%2DB903FCFAFE43399616D0DE2244D7FE%'
order by 1

-- 触达人数
select 
'2会员日触达人数' ,
count(distinct t.usertag)
from track.track t
where t.`date` >='2022-11-25'   -- 每天修改起始时间
and t.`date` <='2022-12-31 23:59:59'  -- 每天修改截止时间
and json_extract(t.`data`,'$.embeddedpoint')= 'memberDay11_home_onload'

select 
'3活动月历触达人数' ,
count(distinct t.usertag)
from track.track t
where t.`date` >='2022-11-01'   -- 每天修改起始时间
and t.`date` <='2022-12-31 23:59:59'  -- 每天修改截止时间
and json_extract(t.`data`,'$.embeddedpoint')= '月历订阅_点击订阅_2022_11_wow_care_activity'




-- 拉新人数
select 
'1拉新用户数',
count(distinct case when m.IS_VEHICLE = 0 then m.id end) 粉丝
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.IS_VEHICLE = 0
where t.`date` >='2022-12-26'   -- 每天修改起始时间
and t.`date` <='2022-12-31 23:59:59'  -- 每天修改截止时间
and json_extract(t.`data`,'$.embeddedpoint')= 'winter_home_ONLOAD' 
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
union all 
-- 激活僵尸粉数
select
'2激活沉默用户数',
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
  where json_extract(t.`data`,'$.embeddedpoint') = 'winter_home_ONLOAD'
  and t.`date` >='2022-12-26'   -- 每天修改起始时间
  and t.`date` <='2022-12-31 23:59:59'  -- 每天修改截止时间
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date < DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
union all 
-- 成功提交养修预约人数
select
'3提交养修数',
COUNT(DISTINCT b.养修预约ID)成功提交养修预约人数 from
(select
distinct tmi.ID 会员ID
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-11-25' and t.`date` <='2022-12-31 23:59:59'  
and json_extract(t.`data`,'$.embeddedpoint')=  'maintain_立即预约_CLICK')a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
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
where ta.CREATED_AT >= '2022-12-26'
and ta.CREATED_AT <='2022-12-31 23:59:59' 
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID
union all 
-- 成功提交养修预约并进厂人数
select 
'4实际到店数',
COUNT(b.养修预约ID)成功提交养修预约并进厂人数 from
(select
distinct tmi.ID 会员ID
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-12-26' and t.`date` <='2022-12-31 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint')=  'maintain_立即预约_CLICK')a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
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
where ta.CREATED_AT >= '2022-12-26'
and ta.CREATED_AT <='2022-12-31 23:59:59'
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID
where b.养修状态 in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')
order by 1

-- 此刻发帖明细
select x.点赞数,
x.收藏量,
x.评论数
from 
	(
	select 
	a.id 动态ID,
	a.read_count 浏览量,
	a.like_count 点赞数,
	x.评论数,
	a.collect_count 收藏量
	from community.tm_post a
	left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
	left join (
		select a.post_id ,
		count(b.comment_content) 评论数
		from community.tm_post a
		left join community.tm_comment b on a.post_id =b.post_id and b.is_deleted =0
		where a.is_deleted =0
-- 		and a.create_time >='2022-12-26' 
-- 		and a.create_time <='2022-12-31 23:59:59'
		and a.post_id='70Q9Xwe3yp'
		group by 1
	)x on x.post_id=a.post_id 
	where a.is_deleted =0
-- 	group by 1
	and a.post_id ='70Q9Xwe3yp'
)x

-- 卡券领用核销数量
select 
-- DATE_FORMAT(x.核销时间,'%Y-%m-%d')日期,
case when x.卡卷id in('4087','4088') then '0w20机油保养服务'
	when x.卡卷id =4089 then '防冻液'
	when x.卡卷id =4090 then '空调消杀'
	when x.卡卷id =4091 then '燃油滤芯'
	when x.卡卷id =4092 then '发动机空气滤芯'
	when x.卡卷id =4093 then '火花塞'
	when x.卡卷id =4094 then '圣诞礼盒'
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
WHERE a.coupon_id in ('4095',
'4087',
'4088',
'4089',
'4090',
'4091',
'4092',
'4093',
'4094'
)
and v.核销时间 >= '2022-12-26'
and v.核销时间 <='2022-12-31 23:59:59'
and a.is_deleted=0
and a.ticket_state=31061003
order by 11 desc )x
group by 1
order by 1



-- 沃世界小程序分时段活跃人数
select 
DATE_FORMAT(t.date,'%Y-%m-%d %H'), -- 尽量准守时间格式’2022-2-2 23:59:59‘
count(t.usertag) PV,
count(DISTINCT t.usertag) UV
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)  
where json_extract(t.`data`,'$.embeddedpoint') = 'winter_home_ONLOAD'
and t.`date` >='2022-12-26'   -- 每天修改起始时间
and t.`date` <='2022-12-31 23:59:59'  -- 每天修改截止时间
and m.IS_DELETED = 0
group by 1
order by 1



-- app评论(长图文70Q9Xwe3yp)
select 
a.id,
a.member_id 会员ID,
tmi.MEMBER_NAME 昵称,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tmi.real_name 姓名,
tmi.MEMBER_PHONE 手机号码,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
'' 评论tag,
a.create_time 评论日期,
a.comment_content 评论内容,
a.like_count 点赞数,
(length(a.comment_content)-CHAR_LENGTH(a.comment_content))/2  评论字数
from community.tm_comment a
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
where a.is_deleted =0
and a.create_time >='2022-11-25' 
and a.create_time <='2022-12-31 23:59:59'
and a.post_id ='70Q9Xwe3yp'

-- 此刻发帖明细
select 
a.id 动态ID,
a.member_id 会员ID,
tmi.MEMBER_NAME 昵称,
a.create_time 发帖日期,
a.post_digest 发帖内容,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tmi.REAL_NAME 姓名,
tmi.MEMBER_PHONE 沃世界注册手机号码,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
a.read_count 浏览量,
a.like_count 点赞数,
x.评论数,
a.collect_count 收藏量
from community.tm_post a
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join (
	select a.post_id ,
	count(b.comment_content) 评论数
	from community.tm_post a
	left join community.tm_comment b on a.post_id =b.post_id and b.is_deleted =0
	where a.is_deleted =0
	and b.create_time >='2022-11-25' 
	and b.create_time <='2022-12-31 23:59:59'
	group by 1
)x on x.post_id=a.post_id 
where a.is_deleted ='0'
and a.create_time >='2022-11-25' 
and a.create_time <='2022-12-31 23:59:59'
-- and a.post_id ='0sOqdQTFMf'
-- and a.member_id ='3372047'
-- and a.create_time ='2022-11-06 08:23:40'
and a.post_digest like '%#沃尔沃服务节#%' 

-- 此刻发帖明细(带tag发帖量)
select count(x.动态ID)
from 
(
select 
a.id 动态ID,
a.member_id 会员ID,
tmi.MEMBER_NAME 昵称,
a.create_time 发帖日期,
a.post_digest 发帖内容,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tmi.REAL_NAME 姓名,
tmi.MEMBER_PHONE 沃世界注册手机号码,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
a.read_count 浏览量,
a.like_count 点赞数,
x.评论数,
a.collect_count 收藏量
from community.tm_post a
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join (
	select a.post_id ,
	count(b.comment_content) 评论数
	from community.tm_post a
	left join community.tm_comment b on a.post_id =b.post_id and b.is_deleted =0
	where a.is_deleted =0
	and a.create_time >='2022-12-26' 
	and a.create_time <='2022-12-31 23:59:59'
	group by 1
)x on x.post_id=a.post_id 
where a.is_deleted ='0'
and a.create_time >='2022-12-26' 
and a.create_time <='2022-12-31 23:59:59'
-- and a.post_id ='0sOqdQTFMf'
and a.member_id ='3372047'
-- and a.create_time ='2022-11-06 08:23:40'
and a.post_digest like '%#沃尔沃服务节#%' 
)x

SELECT  a.OWNER_CODE,a.`RO_NO` ,
	     a.LABOUR_CODE '工时代码',
	     a.LABOUR_NAME '工时名称',
	     a.LABOUR_PRICE '工时单价',
	     a.LABOUR_AMOUNT '工时费'
from cyx_repair.tt_ro_labour a
-- where a.IS_DELETED=0 and concat(a.OWNER_CODE,a.RO_NO) in (select count(vin) from `dms_manage`.tt_common_temp_data where `tmp2`  = '220901')

cyx_repair.tt_repair_order（工单） = cyx_repair.tt_booking_order（预约表）
条件：OWNER_CODE = OWNER_CODE AND BOOKING_ORDER_NO= BOOKING_ORDER_NO

cyx_repair.tt_booking_order（预约表） ='cyx_appointment`.`tt_appointment_maintain'
条件：APPOINTMENT_ID = APPOINTMENT_ID

工时表和工单表进行关联：
工单关联的工时 ：一对多（一个工单可以加多个工时，工时表中有工单号和经销商号）

select 
DISTINCT b.* from
(select
distinct tmi.ID 会员ID
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-11-25' and t.`date` <='2022-12-31 23:59:59'  
and json_extract(t.`data`,'$.embeddedpoint')=  'maintain_立即预约_CLICK')a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
--        tc2.COMPANY_NAME_CN "经销商名称",
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
       tam.WORK_ORDER_NUMBER "工单号",
       tb.OWNER_CODE,
       tro.RO_NO,
       tro.LABOUR_PRICE 工时单价,
       tro.LABOUR_AMOUNT 工时费
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
-- left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
left join cyx_repair.tt_booking_order tb on tam.APPOINTMENT_ID =tb.APPOINTMENT_ID and tb.IS_DELETED <>1 -- 预约表
-- left join cyx_repair.tt_ro_labour trl on CONCAT(tro.OWNER_CODE,tro.BOOKING_ORDER_NO) =CONCAT(tb.OWNER_CODE,tb.BOOKING_ORDER_NO) and tro.IS_DELETED <>1 -- 工单
left join cyx_repair.tt_repair_order tro on CONCAT(tro.OWNER_CODE,tro.BOOKING_ORDER_NO) =CONCAT(tb.OWNER_CODE,tb.BOOKING_ORDER_NO) and tro.IS_DELETED <>1 -- 工单
where ta.CREATED_AT >= '2022-11-25'
and ta.CREATED_AT <='2022-12-31 23:59:59' 
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID

SELECT  a.OWNER_CODE,a.`RO_NO` ,
	     a.LABOUR_CODE '工时代码',
	     a.LABOUR_NAME '工时名称',
	     a.LABOUR_PRICE '工时单价',
	     a.LABOUR_AMOUNT '工时费'
from cyx_repair.tt_ro_labour a


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
-- x.dealer_code 经销商Code
FROM coupon.tt_coupon_detail a 
left join
	(
	# 车系
	 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
	 from (
	 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
	 ,row_number() over(PARTITION by v.vin order by v.create_time desc) rk
	 from member.tc_member_vehicle v 
	 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
	 where v.IS_DELETED=0 
	 ) v 
	 left join vehicle.tm_vehicle t on v.vin=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	 where v.rk=1
-- 	 and v.vin='LVYPD10D0KP105748'
) t on a.vin=t.vin
left join `member`.tc_member_info m on m.id =t.member_id and m.IS_DELETED =0 and m.MEMBER_STATUS <> 60341003
left JOIN 
(
	select b.*,
	case when b.id in ('4087','4089') then '8081' 
		when b.id in ('4088','4090') then '8082'
		when b.id ='4091' then '8083'
		when b.id ='4092' then '8084'
		when b.id ='4093' then '8085'
		when b.id ='4094' then '8086'
		end as sku
	from coupon.tt_coupon_info b
)b ON a.coupon_id = b.id 
-- left join (
-- 	-- 添加手机号 
-- 	select 
-- 	DISTINCT sao.vin,
-- 	sao.member_id,
-- 	tmi.REAL_NAME,
-- 	tmi.MEMBER_PHONE,
-- 	sao.coupon_id,
-- 	sao.dealer_code,
-- 	sao.sku_id
-- 	FROM volvo_online_activity.season_activity_order sao 
-- 	left join `member`.tc_member_info tmi on sao.member_id =tmi.ID 
-- 	where sao.sku_id in ('8081',
-- 	'8082',
-- 	'8083',
-- 	'8084',
-- 	'8085',
-- 	'8086'
-- 	)
-- 	and sao.create_date >= '2022-11-25'
-- 	and sao.create_date <= '2022-12-31 23:59:59'
-- 	and sao.delete_flag =0
-- 	and sao.receive_coupon_result <>0
-- 	and sao.code ='winter_2022'
-- 	group by 1) x on 
-- 	x.member_id=m.id and x.sku_id=b.sku
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
'4095',
'4087',
'4088',
'4089',
'4090',
'4091',
'4092',
'4093',
'4094'
)
-- and a.get_date >= '2022-11-25'
-- and a.get_date <= '2022-12-31 23:59:59'
and a.is_deleted=0
and a.ticket_state <>31061005
-- and a.id ='23816111'
order by 11 desc



-- 检验
select 
b.coupon_name,
a.coupon_id,
count(a.id)
from coupon.tt_coupon_detail a 
left JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
WHERE a.coupon_id 
in
(
'4095',
'4087',
'4088',
'4089',
'4090',
'4091',
'4092',
'4093',
'4094'
)
-- and a.get_date >= '2022-11-25'
-- and a.get_date <= '2022-12-31 23:59:59'
and a.is_deleted=0
and a.ticket_state <>31061005
group by 1 with ROLLUP 
order by 3 desc 


	-- 添加手机号 
	select 
	sao.sku_id,
	count(1)
	FROM volvo_online_activity.season_activity_order sao 
	left join `member`.tc_member_info tmi on sao.member_id =tmi.ID 
	where sao.sku_id in ('8081',
	'8082',
	'8083',
	'8084',
	'8085',
	'8086'
	)
	and sao.create_date >= '2022-11-25'
	and sao.create_date <= '2022-12-31 23:59:59'
	and sao.delete_flag =0
	and sao.receive_coupon_result <>0
	and sao.code ='winter_2022'
	group by 1
	order by 2 desc 

-- 卡券和经销商
select a.member_id,
a.vin,
a.coupon_id,
a.sku_id,
a.dealer_code,
a.dealer_name,
a.create_date
from volvo_online_activity.season_activity_order a
where a.code ='winter_2022'
and a.create_date >='2022-11-25'
and a.create_date <='2022-12-31 23:59:59'
and a.delete_flag =0
order by a.create_date 
