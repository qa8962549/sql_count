-- 1、沃世界会员总数量，车主数量，非车主数量 
select
case when tmlc.IS_VEHICLE = '1' then '车主'
	when tmlc.IS_VEHICLE = '0' then '非车主'
	end 是否车主,
	COUNT(ID)会员数量
from `member`.tc_member_info tmi
where tmi.CREATE_TIME <= '2022-03-02 18:00:00'
and tmlc.MEMBER_STATUS <> 60341003
and tmlc.IS_DELETED = 0
group by 1

-- 2、根据会员表会员ID匹配用户收货地址信息
select 
tma.MEMBER_ID 会员ID,
tma.CONSIGNEE_NAME 收货人姓名,
tma.CONSIGNEE_PHONE 收货人手机号,
CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址
from `member`.tc_member_address tma
left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
where tma.IS_DELETED = 0
and tma.IS_DEFAULT = 1

-- 3、沃世界小程序会员信息明细
select
tmi.USER_ID,
IFNULL(tmi.REAL_NAME,tmi.MEMBER_NAME) "姓名",
tmi.MEMBER_PHONE "手机号",
tmi.ID "会员ID",
tmi.MEMBER_URL "会员头像",
case when tmi.IS_VEHICLE='1' then '绑定'
	else '未绑定' end '是否绑定车辆',
t.VIN,
tisd.dealer_code 经销商代码,
t.车型,
tr.REGION_NAME 所在地,
tc.CODE_CN_DESC "性别",
tmi.MEMBER_BIRTHDAY "生日",
tmi.MEMBER_HOBBY "爱好兴趣"
from `member`.tc_member_info tmi 
left join
(
# 车系
 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
 from (
 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
 from member.tc_member_vehicle v 
 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
 where v.IS_DELETED=0 
 ) v 
 left join vehicle.tm_vehicle t on v.vin=t.VIN
 left join basic_data.tm_model m on t.MODEL_ID=m.ID
 where v.rk=1
) t on tmi.id=t.member_id
left join dictionary.tc_code tc on tc.CODE_ID =tmi.MEMBER_SEX
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE = tr.REGION_CODE
left join vehicle.tt_invoice_statistics_dms tisd on t.VIN = tisd.vin 
where tmi.IS_DELETED =0 
and tmi.MEMBER_STATUS <>60341003

-- 4、小程序各等级对应的会员数
select tl.LEVEL_NAME ,COUNT(tmi.ID)会员用户数
from `member`.tc_member_info tmi
left join 
(select distinct tl.LEVEL_CODE,tl.LEVEL_NAME
from `member`.tc_level tl
where tl.LEVEL_CODE is not null ) tl on tmi.LEVEL_ID = tl.LEVEL_CODE 
where tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
and tmi.CREATE_TIME < '2022-03-01'
group by tl.LEVEL_NAME
order by tl.LEVEL_CODE

-- 5、小程序各等级对应的车主会员数
select
tl.LEVEL_NAME,COUNT(tmi.ID)车主用户数
from `member`.tc_member_info tmi 
left join 
(select distinct tl.LEVEL_CODE,tl.LEVEL_NAME
from `member`.tc_level tl
where tl.LEVEL_CODE is not null ) tl on tmi.LEVEL_ID = tl.LEVEL_CODE 
where DATE_FORMAT(tmi.create_time,'%Y-%m-%d') < '2022-03-01'
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
and tmi.IS_VEHICLE = 1  -- 车主
group by tl.LEVEL_NAME
order by tl.LEVEL_CODE

-- 试驾专区发帖匹配收货地址
select
fp.id,
fp.activity_code,
case when fp.activity_code = 'testDrivePlaza' then '试驾广场'
 when fp.activity_code = 'carExperience' then '爱车心得'
 else null end 帖子分类,
ft.topic_name 话题分类,
fp.member_id,
tmi.MEMBER_PHONE 手机号,
c.收货人姓名,
c.收货人手机号,
c.收货地址,-- 添加默认收货地址
fp.page_id,
fp.title 帖子标题,
fp.content 发帖内容,
fp.title_img 图片链接,
fp.like_count 点赞量,
fp.comment_count 评论量,
fp.forward_count 转发量,
fp.play_count 播放量,
case when fp.check_status = '1' then '审核通过'
 when fp.check_status = '0' then '审核中'
 else '审核不通过' end 审核状态,
case when fp.is_chosen = '1' then '精选'
 else '非精选' end 是否精选,
fp.create_date 发帖时间,
fp.car_series 车型,
fp.province_name 省,
fp.city_name 市,
fp.district_name 区,
fp.video_img 视频截图
from volvo_online_activity_module.forum_posts fp
left join `member`.tc_member_info tmi on fp.member_id = tmi.ID 
left join volvo_online_activity_module.forum_topic_posts ftp on fp.id = ftp.posts_id
left join volvo_online_activity_module.forum_topic ft on ftp.topic_id = ft.id
left join (
select 
tma.MEMBER_ID,
tma.CONSIGNEE_NAME 收货人姓名,
tma.CONSIGNEE_PHONE 收货人手机号,
CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址
from `member`.tc_member_address tma
left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
where tma.IS_DELETED = 0
and tma.IS_DEFAULT = 1
)c on fp.member_id = c.MEMBER_ID
where fp.activity_code in ('testDrivePlaza','carExperience')
and fp.create_date >= '2022-01-09'
and fp.is_delete = 0
order by fp.create_date desc

-- 卡券领用核销明细
SELECT 
a.id,
a.one_id,
b.id coupon_id,
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
left join `member`.tc_member_info tmi on a.one_id = tmi.CUST_ID 
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
order by v.create_time 
) v ON v.coupon_detail_id = a.id
WHERE 
-- b.coupon_name like '%FIKA%'   -- 业务也不知道卡券ID是多少,模糊匹配一下。
-- a.coupon_id in ('3311','3327','3310')  -- 有多张卡券ID的情况下，使用这个。
a.coupon_id = '3327'
and a.get_date >= '2022-02-25'  -- 卡券获得时间
and a.get_date <= '2022-03-01'  -- 卡券获得时间
and a.is_deleted=0 
order by 7;

-- 商城订单明细
select a.order_code 订单编号
,b.product_id 商城兑换id
,a.user_id 会员id
,a.user_name 会员姓名
,b.spu_name 兑换商品
,b.spu_id
,b.sku_id
,b.sku_code
,b.sku_real_point 商品单价
,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券' 
	WHEN 51121003 THEN '保养类卡券' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
,b.fee/100 总金额
,b.coupon_fee/100 优惠券抵扣金额
,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,a.create_time 兑换时间
,case when b.pay_fee=0 then '纯V值支付' when b.point_amount=0 then '纯现金支付' else '混合支付' end 支付方式
,f.name 分类
,CASE b.spu_type 
	WHEN 51121001 THEN 'VOLVO仓商品' 
	WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
	WHEN 51121003 THEN '虚拟服务卡券' 
	WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
,CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
END AS 商品状态
,CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
END AS 订单状态
,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 关闭原因
,e.`退货状态`
,e.`退货数量`
,e.退回V值
,e.退回时间
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
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
where a.create_time BETWEEN '2021-11-26' and '2021-12-25 23:59:59'   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
order by a.create_time

-- 预约试驾
select
ta.APPOINTMENT_ID 预约ID,
ta.CREATED_AT 预约日期,
ta.OWNER_CODE 经销商代码,
tc2.COMPANY_NAME_CN "经销商名称",
tad.user_name 姓名,
tad.phone 预约手机号,
tmi.ID 会员ID,
tmi.MEMBER_PHONE 沃世界绑定手机号,
tm.MODEL_NAME 车型,
case when tc.code_id = '70711001' then '预约待试驾'
 when tc.code_id = '70711002' then '预约已试驾'
 when tc.code_id = '70711003' then '预约已取消'
 end '预约试驾状态'
from cyx_appointment.tt_appointment ta
left join cyx_appointment.tt_appointment_drive tad on ta.APPOINTMENT_ID = tad.APPOINTMENT_ID
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
left join basic_data.tm_model tm on tad.SECOND_ID = tm.SERIES_ID
left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.MODEL_NAME 
left join dictionary.tc_code tc on tad.STATUS = tc.CODE_ID 
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
where ta.CHANNEL_ID = 'M69ARC8SO3'  -- 活动代码,是cms_active表的uid
and ta.CREATED_AT >= '2022-02-04 12:00:00'
and ta.CREATED_AT < '2022-02-11 12:00:00'
and ta.IS_DELETED = 0

-- 养修预约
select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.COMPANY_NAME_CN "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID ,
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
where ta.CREATED_AT >= '2022-02-04 12:00:00'
and ta.CREATED_AT < '2022-02-11 12:00:00'
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005;

# 查询试驾活动PV UV
select
case when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_SHOUYE_ONLOAD' then '01 首页页面'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_HUODONGGUIZE_ONCLICK' then '02 首页活动规则'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_GERENZHONGXIN_ONCLICK' then '03 首页个人中心'
	 when json_extract(t.`data`,'$.embeddedpoint') = '试驾专区_点击活动速递' then '04 首页活动速递'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_YUYUESHIJIA_ONCLICK' then '05 首页赢限定试驾礼/礼盒'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_WOYOUCHANGTAN_ONLOAD' then '06 首页试驾广场'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_WOYOUCHANGTAN_ONLOAD' then '07 首页爱车心得'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_ZAISHOUCHEXING_ONCLICK' then '08 首页在售车型btn'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_ZHISHOUCHEXING_ONCLICK' then '09 首页直售车型btn'
	 when json_extract(t.`data`,'$.embeddedpoint') = '预约试驾_提交' then '10 试驾预约页-提交'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_WOYOUCHANGTAN_ONLOAD' then '11 沃友畅谈页'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_SHIJIAGUANGCHANGGENGDUO_ONCLICK' then '13 沃友畅谈页-试驾广场btn'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_AICHEXINDEGENGDUO_ONCLICK' then '14 沃友畅谈页-爱车心得btn'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_XIANGQING_ONLOAD' then '15 所有发帖详情页-点赞、评论、访问'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_SHIJIAGUANGCHANG_ONLOAD' then '16 试驾广场'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_SHIJIAGUANGCHANGTAB_ONCLICK' and json_extract(t.`data`,'$.index')='0' then '17 试驾广场-最新tab'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_SHIJIAGUANGCHANGTAB_ONCLICK' and json_extract(t.`data`,'$.index')='1' then '18 试驾广场-精华帖tab'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_SHIJIAGUANGCHANGTAB_ONCLICK' and json_extract(t.`data`,'$.index')='2' then '19 试驾广场-各车型的tab'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_AICHEXINDE_ONLOAD' then '20 爱车心得'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_AICHEXINDETAB_ONCLICK' and json_extract(t.`data`,'$.index')='1' then '21 爱车心得-最新tab'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_AICHEXINDETAB_ONCLICK' and json_extract(t.`data`,'$.index')='0' then '22 爱车心得-精华帖tab'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_WOYAOFATIE_ONCLICK' then '23 我要发帖btn'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_GERENZHONGXIN_ONLOAD' then '24 个人中心页'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_CHAKANWODETIEZI_ONCLICK' then '25 个人中心-我的发帖btn'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_WODECAOGAOXIANG_ONCLICK' then '26 个人中心-草稿箱btn'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_QUFATIE_ONCLICK' then '27 个人中心-去发帖btn'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_DIANPINGCHOUJIANG_ONCLICK' then '28 点评页-试驾抽奖btn'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_SHIJIACHOUJIANG_ONLOAD' then '29 抽奖页面'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_LIJICHOUJIANG_ONCLICK' then '30 抽奖页面-立即抽奖btn'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_JINRUSHIJIA_ONCLICK' then '31 抽奖页面-进入试驾专区btn'
	 when json_extract(t.`data`,'$.embeddedpoint') = 'SHIJIAZHUANQU_CHOUJIANGHUOQUDIZHI_ONCLICK' then '32 抽奖页面-填写收货地址btn'
else null end '分类',
COUNT(t.usertag) as 'PV',
COUNT(distinct t.usertag) as 'UV' 
from track.track t   
where t.`date` >= '2022-01-09'
group by 1
order by 1;


-- 埋点测试(这里填写自己的user_id，user_id在会员表中查找)
select * from track.track t where t.usertag = '6039075' order by t.`date` desc


