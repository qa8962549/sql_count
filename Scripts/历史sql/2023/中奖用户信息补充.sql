-- 中奖明细
select
tmi.cust_id,
a.member_id,
tmi.MEMBER_PHONE 沃世界注册手机号,
a.nick_name 姓名,
tmi.create_time 注册时间,
tl.LEVEL_NAME 会员等级,
ifnull(v.次数,0) 会员任务数,
ifnull (c.现金支付金额,0) 商城现金支付金额,
tmi.IS_VEHICLE 当前是否车主,
ifnull(r.bc,0) 历史累计绑定vin数,
tmi.member_c_num 当前成长值,
ifnull(t1.ft,0) 社区发文章数,
ifnull(t2.ft,0) 社区发动态数,
ifnull(dz.dz,0) 点赞数,
ifnull(pl.pl,0) 评论数
from volvo_online_activity_module.lottery_draw_log a
left join "member".tc_member_info tmi on tmi.id =a.member_id 
left join (
	--任务周度完成情况
	select 
	b.id,
	COUNT(t.MEMBER_ID) 次数
	FROM `member`.tt_member_score_record t
	left join member.tc_member_info b on t.member_id = b.id
	WHERE (t.event_type in ('60731011','60731003','60731013','60731041','60731052','60731049','60731055','60731006','60731050','60731051','60731056','60731054','60741230','60741231') or 
	t.event_desc in('完成App文章浏览（10秒）任务','完成App签到任务','完成App社区点赞任务','完成App文章加精任务','完成App文章被推荐任务')) -- 任务类型
	and t.CREATE_TIME >= '2023-07-01' 
	and t.CREATE_TIME<'2023-09-01'  -- 时间
	and t.IS_DELETED =0 and b.member_status <> 60341003
	GROUP by 1)v on v.id=a.member_id 
left join (
	select tc.member_id,count(1) pl
	from community.tm_comment tc
	where tc.is_deleted=0 
	group by 1)pl on pl.member_id=a.member_id 
left join (
	select tlp.member_id,count(1) dz
	from community.tt_like_post tlp 
	where tlp.is_deleted=0 
	and tlp.like_type=0 
	group by 1)dz on dz.member_id=a.member_id 
left join (
	select t.member_id ,COUNT(t.id) ft
	from community.tm_post t
	where t.is_deleted =0
	and t.post_type='1007'
	group by 1)t1 on t1.member_id=a.member_id 
left join (
	select t.member_id ,COUNT(t.id) ft
	from community.tm_post t
	where t.is_deleted =0
	and t.post_type='1001'
	group by 1)t2 on t2.member_id=a.member_id 
left join 
	(
	select r.member_id,count(distinct r.vin_code) bc
	from volvo_cms.vehicle_bind_relation r 
	where r.deleted = 0
	and r.is_bind =1
	group by 1)r
	on a.member_id =r.member_id
left join 
	(select distinct tl.LEVEL_CODE,tl.LEVEL_NAME
	from `member`.tc_level tl
	where tl.LEVEL_CODE is not null) tl on tmi.LEVEL_ID = tl.LEVEL_CODE 
left join 
	(select x.会员id,sum(x.现金支付金额) 现金支付金额
	from (-- 9、商城数据
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
	from "order".tt_order a  -- 订单主表
	left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
	left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
	left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
	left join(
	--	#V值退款成功记录
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
	where 
	 a.create_time <='2023-08-25'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	order by a.create_time) x group by 1)c on a.member_id = c.会员id
where 1=1
and a.lottery_play_code like '%member_202308%'  -- 会员日code
and date(a.create_time)='2023-08-25'
and a.have_win = 1   -- 中奖
order by a.create_time
