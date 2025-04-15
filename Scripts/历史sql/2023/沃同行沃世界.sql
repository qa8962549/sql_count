

-- 1、品牌大使、特邀发言官勋章人数（2者都有的用户取数为1）
select x.aa,x.会员ID
from 
(
SELECT 1 aa,a.会员ID
FROM (
select 
        c.user_id 会员ID,
        e.medal_name 勋章名称,
        ROW_NUMBER() over(PARTITION by c.user_id ORDER by e.medal_name) ra
        from mine.madal_detail c
        left join `member`.tc_member_info d on d.ID = c.user_id
        left join mine.user_medal e on e.id = c.medal_id
        left join `member`.tc_level f on f.LEVEL_CODE = d.MEMBER_LEVEL
        left join mine.my_medal_type g on e.`type` = g.union_code
        where c.create_time >= '2022-01-01'
        and c.create_time <='2022-11-10'
        and c.deleted = 1  -- 有效
        and c.status = 1  -- 正常
        and e.medal_name in ('特邀发言官','品牌大使')
        GROUP by 1,2) a
WHERE a.ra = 2
union all 
-- 累计签到天数 ≥300天
# 累计签到300天去重
select 2 aa,a.MEMBER_ID
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 
and i.create_time <= '2022-11-10 23:59:59'
) a GROUP BY 2
HAVING count(1)>=300
order by 2 desc 
union all 
-- 成功推荐购车人数 ≥4人（推荐人）
select 3 aa,m.id
from 
(
select x.邀请人手机号,
count(x.下单人手机号) 推荐人当前季度成功推荐台数
from 
	(
		# 订单表
		select 
		    a.SO_NO 销售订单号,
		    a.OWNER_CODE 销售经销商代码,
		    a.CREATED_AT 订单日期,
		    a.SHEET_CREATE_DATE 开单日期,
		    a.CUSTOMER_NAME 客户姓名,
		    a.DRAWER_NAME 开票人姓名,
		    a.DRAWER_TEL 开票人电话,
		    a.CONTACT_NAME 联系人姓名,
		    a.CUSTOMER_TEL 潜客电话,
		    a.PURCHASE_PHONE 下单人手机号,
		    g.CODE_CN_DESC 订单状态,
		    case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
		    b.active_code 市场活动代码,
		    d.SALES_VIN 车架号,
		    f.model_name 车型,
		    j.CODE_CN_DESC 线索客户类型,
		    k.CODE_CN_DESC 客户性别,
		    l.CODE_CN_DESC 交车状态,
		    n.CODE_CN_DESC 订单购买类型,
		    a.VEHICLE_RETURN_DATE 退车完成日期,
		    m.CODE_CN_DESC 退车状态,
		    a.RETURN_REASON 退单原因,
		    a.RETURN_REMARK 退单备注,
		    r.invite_mobile 邀请人手机号
		from cyxdms_retail.tt_sales_orders a 
		left join invite.tm_invite_record r on r.be_invite_mobile=a.PURCHASE_PHONE and r.is_deleted =0
		left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
		left join customer_business.tm_clue_source c on c.ID = b.active_channel
		left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
		left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
		left join basic_data.tm_model f on f.id = e.SECOND_ID
		left join dictionary.tc_code g on g.code_id = a.SO_STATUS
		left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
		left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
		left join dictionary.tc_code k on k.code_id = a.GENDER
		left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
		left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
		left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
		where a.BUSINESS_TYPE <> 14031002
		and a.IS_DELETED = 0
		and a.CREATED_AT >= '2022-10-01'
		and a.CREATED_AT < curdate()
-- 		and b.active_code in ('IBDMSEPWSJTJGLZS2022VCCN','IBDMSEPWEWHBLSZS2022VCCN')
-- 		and a.PURCHASE_PHONE=18600310677
-- 		and r.invite_mobile=13581933003
		order by a.CREATED_AT
	)x where x.'订单是否有效'='Y' and x.邀请人手机号 is not null 
	group by 1
	)xx left join `member`.tc_member_info m on xx.邀请人手机号=m.member_phone and m.is_deleted = 0 and m.member_status <> '60341003'
	where xx.推荐人当前季度成功推荐台数>=4 and m.id is not null and m.member_phone <>'*'
union all 
-- 2、勋章点亮数≥ 5个
SELECT 4 aa,a.会员ID
FROM (
select 
        c.user_id 会员ID,
        e.medal_name 勋章名称,
        ROW_NUMBER() over(PARTITION by c.user_id ORDER by e.medal_name) ra
        from mine.madal_detail c
        left join `member`.tc_member_info d on d.ID = c.user_id
        left join mine.user_medal e on e.id = c.medal_id
        left join `member`.tc_level f on f.LEVEL_CODE = d.MEMBER_LEVEL
        left join mine.my_medal_type g on e.`type` = g.union_code
        where c.create_time >= '2022-01-01'
        and c.create_time <='2022-11-10'
        and c.deleted = 1  -- 有效
        and c.status = 1  -- 正常
        GROUP by 1,2) a
WHERE a.ra > 4
union all 
-- 3、会员日参与6次（勋章：WOW辈楷模）
select 
        5 aa,c.user_id 会员ID
        from mine.madal_detail c
        left join `member`.tc_member_info d on d.ID = c.user_id
        left join mine.user_medal e on e.id = c.medal_id
        left join `member`.tc_level f on f.LEVEL_CODE = d.MEMBER_LEVEL
        left join mine.my_medal_type g on e.`type` = g.union_code
        where c.create_time >= '2022-01-01'
        and c.create_time <='2022-11-10'
        and c.deleted = 1  -- 有效
        and c.status = 1  -- 正常
        and e.medal_name in ('WOW辈楷模')
        group by 2
union all 
-- 4、爱心计划徽章点亮
select 
        6 aa,c.user_id 会员ID
        from mine.madal_detail c
        left join `member`.tc_member_info d on d.ID = c.user_id
        left join mine.user_medal e on e.id = c.medal_id
        left join `member`.tc_level f on f.LEVEL_CODE = d.MEMBER_LEVEL
        left join mine.my_medal_type g on e.`type` = g.union_code
        where c.create_time >= '2022-01-01'
        and c.create_time <='2022-11-10'
        and c.deleted = 1  -- 有效
        and c.status = 1  -- 正常
        and e.medal_name in ('爱心大使')
        group by 2
-- 5、车主故事+路书专区+12服发帖总篇数 ≥2篇（审核通过）
union all 
SELECT 7 aa,b.会员ID
from (
SELECT a.会员ID,sum(a.篇数) 总篇数
FROM (
-- 车主故事
select 
tmi.ID 会员ID,
count(DISTINCT os.id) 篇数
from volvo_online_activity.owner_story os 
left join `member`.tc_member_info tmi on os.member_id =tmi.id
WHERE 
os.create_date >='2022-01-01' and os.create_date <='2022-11-10'
and os.is_deleted =0
group by 1
UNION all
-- 路书
SELECT a.会员ID,COUNT(DISTINCT a.路书标题) 篇数
FROM (
select
a.title 路书标题,
a.start_point 出发地,
a.end_point 目的地,
e.name 主题分类,
a.create_time 提交时间,
b.MEMBER_PHONE 沃世界手机号,
a.nick_name 用户昵称,
a.member_id 会员ID,
a.view_num 浏览量,
c.我想去人数,
d.我去过人数
from volvo_online_activity.dont_hurry_road_book a
left join `member`.tc_member_info b on a.member_id = b.ID and b.MEMBER_STATUS <> 60341003 and b.IS_DELETED = 0
left join 
(select
c.road_book_id,
COUNT(c.vote_member_id)我想去人数
from volvo_online_activity.dont_hurry_road_book_like c
where c.is_delete = 0
and c.type = 1 -- 我想去
group by 1)c on a.id = c.road_book_id
left join
(select
d.road_book_id,
COUNT(d.vote_member_id)我去过人数
from volvo_online_activity.dont_hurry_road_book_like d
where d.is_delete = 0
and d.type = 2 -- 我去过
group by 1)d on a.id = d.road_book_id
left join
(select
e.id,
e.name
from volvo_online_activity.dont_hurry_road_theme e)e on a.theme_id = e.id
join (select
f.road_book_id,
f.label_name 话题名称
from volvo_online_activity.dont_hurry_road_book_tag f 
-- where f.label_name = '带着Volvo去旅行'
)f on a.id = f.road_book_id
where a.create_time >= '2022-01-01'        -- 提交时间
and a.create_time <= '2022-11-10'     -- 提交时间
and a.audit_time >= '2022-01-01'       -- 审核时间
and a.audit_time <= '2022-11-10'   -- 审核时间
and a.audit_status = 2    -- 审核通过
and a.is_delete = 0   -- 逻辑删除
group by 1
order by a.create_time) a 
GROUP by a.会员ID
UNION ALL 
-- 十二服
SELECT a.member_id 会员ID,COUNT(DISTINCT a.发帖内容) 篇数
FROM (
select tmi.MEMBER_NAME 昵称,
tsp.member_id,
case tmi.IS_VEHICLE when 1 then '是' else '否' end '是否车主',
a.model_name 绑定车型,
a.company_code 购车经销商,
a.VIN,
if(tr.REGION_NAME = tr2.REGION_NAME ,tr.REGION_NAME ,ifnull("",concat(tr.REGION_NAME,tr2.REGION_NAME))) 省市,
tmi.MEMBER_PHONE 手机号,
tsp.create_date 提交时间,
tst.topic_name 话题,
tsp.content 发帖内容,
tsp.comment_count 评论量,
tsp.like_count 点赞量,
case tsp.check_status when 1 then '审核成功'
when 0 then '审核中'
when -1 then '审核失败' end 审核状态,
case when tsp.chosen = 1 then '是' else '否' end 是否精选,
case when tsp.sort = 1000 then '是' else '否' end 是否置顶,
case when tst.entity_type = 1 then '视频贴' else '文字帖' end 帖子类型,
case when tst.`type` = 0 then '官方话题' else '原创话题' end 话题分类 
from volvo_online_activity.twelve_service_post tsp 
left join volvo_online_activity.twelve_service_topic tst on tsp.topic_id = tst.id 
left join `member`.tc_member_info tmi on tsp.member_id = tmi.ID 
left join 
(select b.member_id,
group_concat(distinct tm.MODEL_NAME) model_name,
group_concat(distinct b.VIN) VIN,
GROUP_CONCAT(distinct tisd.dealer_code) company_code
from 
(select a.member_id,a.vin
from 
(select tmv.MEMBER_ID,tmv.VIN,
ROW_NUMBER() over(partition by tmv.VIN order by tmv.CREATE_TIME desc) as rk
from `member`.tc_member_vehicle tmv 
where tmv.IS_DELETED = 0) a 
where a.rk = 1 ) b
left join vehicle.tt_invoice_statistics_dms tisd on b.vin = tisd.vin and tisd.IS_DELETED = 0
left join vehicle.tm_vehicle tv on b.vin = tv.VIN and tv.IS_DELETED = 0
left join basic_data.tm_model tm on tv.MODEL_ID = tm.id 
where tm.IS_DELETED = 0
group by 1) a on a.member_id = tsp.member_id
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE = tr.REGION_ID 
left join dictionary.tc_region tr2 on tmi.MEMBER_CITY = tr2.REGION_ID 
where tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
and tsp.create_date >= '2022-01-01'   -- 起始时间不变
and tsp.create_date <= '2022-11-10'
order by tsp.create_date) a 
GROUP BY 1) a 
GROUP by 1) b 
where b.总篇数 >=2
union all
-- 商城订单累计总金额 ≥3,000人民币
### 商城V值消耗人数  商城V值消耗数量
select 8 aa,x.会员id
from 
(
select 
b.会员id,
sum(实付金额) 消费金额
from (
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
,DATE_FORMAT(a.create_time,'%Y-%m') 月份
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
where a.create_time <='2022-11-10 23:59:59'   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
-- and a.point_amount<>'3'
order by a.create_time
) b 
GROUP BY 1 order by 2 desc ) x where x.消费金额>=3000
union all
-- 通过线上提交预约功能养修/试驾 ≥2次（提交即可）
select 9 aa,x.id
from 
(
SELECT
m.ID,
count(ta.APPOINTMENT_ID) aa
from cyx_appointment.tt_appointment ta 
join `member`.tc_member_info m on ta.ONE_ID =m.CUST_ID and m.is_deleted = 0 and m.member_status <> '60341003'
where ta.IS_DELETED =0
and ta.CREATED_AT <='2022-11-10 23:59:59'
and ta.ONE_ID is not null 
group by 1
order by 2 desc 
)x where x.aa>=2
union all
-- 累计签到天数 ≥10天
# 累计签到300天去重
select 10,a.MEMBER_ID
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 
and i.create_time <= '2022-11-10 23:59:59'
) a GROUP BY 2
HAVING count(1)>=10
order by 1 
)x 
group by 2
order by 1

select x.会员ID,m.REAL_NAME,m.MEMBER_PHONE,m.CUST_ID
from 
(
SELECT 1 aa,a.会员ID
FROM (
select 
        c.user_id 会员ID,
        e.medal_name 勋章名称,
        ROW_NUMBER() over(PARTITION by c.user_id ORDER by e.medal_name) ra
        from mine.madal_detail c
        left join `member`.tc_member_info d on d.ID = c.user_id
        left join mine.user_medal e on e.id = c.medal_id
        left join `member`.tc_level f on f.LEVEL_CODE = d.MEMBER_LEVEL
        left join mine.my_medal_type g on e.`type` = g.union_code
        where c.create_time >= '2022-01-01'
        and c.create_time <='2022-11-10'
        and c.deleted = 1  -- 有效
        and c.status = 1  -- 正常
        and e.medal_name in ('特邀发言官','品牌大使')
        GROUP by 1,2) a
WHERE a.ra = 2
union all 
-- 累计签到天数 ≥300天
# 累计签到300天去重
select 2 aa,a.MEMBER_ID
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 
and i.create_time <= '2022-11-10 23:59:59'
) a GROUP BY 2
HAVING count(1)>=300
order by 1
)x left join member.tc_member_info m on x.会员ID=m.ID 