--中奖名单
-- 中奖明细
select
a.member_id,
a.nick_name 姓名,
case when d.is_vehicle = '1' then '车主'
	when d.is_vehicle = '0' then '粉丝'
	end `当前是否车主`,
case when d.member_level = 1 then '银卡'
     when d.member_level = 2 then '金卡'
     when d.member_level = 3 then '白金卡' 
     when d.member_level = 4 or d.member_level = 5 then '黑卡' end 会员等级,
case when a.have_win = '1' then '中奖'
	when a.have_win = '0' then '未中奖'
	end 是否中奖,
a.create_time 抽奖时间,
b.prize_name 中奖奖品,
--b.prize_code 中奖奖品code,
b.prize_level_nick_name 奖品等级
from volvo_online_activity_module.lottery_draw_log a
left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
left join `member`.tc_member_info d on a.member_id = d.ID
where 1=1
and (a.lottery_play_code like '%member_202312%'  -- 会员日code
	or a.lottery_play_code like '%2024_newyear%')
and date(a.create_time)>='2023-12-25'
and a.have_win = 1   -- 中奖
order by a.create_time

-- 奖池明细
select
distinct b.lottery_play_code 抽奖场次,
b.prize_code 中奖奖品code,
b.prize_name 中奖奖品,
b.prize_level_nick_name 奖品等级,
b.full_number 奖励投放数量,
1/b.win_rate 中奖概率
from volvo_online_activity_module.lottery_play_pool b
where 1=1
and (b.lottery_play_code like '%member_202312%'  -- 会员日code
	or b.lottery_play_code like '%2024_newyear%')
order by 1,2

-- 抽奖活动人群在T+30d的行为数据统计  淘汰
select distinct a.member_id ,
case when m.IS_VEHICLE = '1' then '车主'
	when m.IS_VEHICLE = '0' then '粉丝'
	end 当前是否车主,
tl.level_name 会员等级,
'' 抽奖后30天内登录天数,
ifnull(c.次数,0) 抽奖后30天内任务数,
ifnull(d.num,0) 抽奖后30天内商城现金支付金额,
ifnull(e.num,0) 历史累计绑定vin数,
m.member_c_num 当前成长值,
ifnull(ft3.文章数量,0) 抽奖后30天内社区发文章数,
ifnull(ft3.动态数量,0) 抽奖后30天内社区发动态数,
ifnull(ft1.点赞,0) 抽奖后30天内点赞数,
ifnull(ft2.评论,0) 抽奖后30天内社区发文章数
from 
(
	select
	DISTINCT a.member_id
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	where a.lottery_play_code  like '%member_202309%'  -- 这里每个月需要变会员日code
	and date(a.create_time)='2023-09-25')a
left join "member".tc_member_info m on a.member_id=m.id 
left join "member".tc_level tl on m.LEVEL_ID = tl.LEVEL_CODE 
left join 
		(-- 0点赞 1收藏
		select
		 a.member_id ,
		count(case when a.like_type=0 then 1 end) 点赞,
		count(case when a.like_type=1 then 1 end) 收藏
		from community.tt_like_post a
		left join community.tm_post b on a.post_id =b.post_id 
		where a.is_deleted <>1
	--	and a.post_id ='cOgh4khS80'
		and a.create_time >='2023-09-26'
		and a.create_time <'2023-10-25'
		group by 1
		)ft1 on ft1.member_id =a.member_id 
left join (-- 评论
		select 
		a.member_id ,
		count(1) 评论
		from community.tm_comment a
		where a.is_deleted <>1
	--	and a.post_id ='cOgh4khS80'
		and a.create_time >='2023-09-26'
		and a.create_time <'2023-10-25'
		group by 1
		)ft2 on ft2.member_id =a.member_id 
left join (-- 发帖数量
		select 
		tp.member_id,
		count(case when tp.post_type=1001 then tp.post_id end ) 动态数量,
		count(case when tp.post_type=1007 then tp.post_id end ) 文章数量
		from community.tm_post tp
		where 1=1
		and tp.create_time >='2023-09-26'
		and tp.create_time <'2023-10-25'
		and tp.is_deleted =0
		group by 1
		)ft3 on ft3.member_id =a.member_id 
left join 
	(
	-- 绑车
	select x.member_id,
	count(distinct x.vin_code) num 
	from 
		(
		select
		r.member_id,
	 	r.bind_date,
		r.vin_code
		from volvo_cms.vehicle_bind_relation r
		where r.deleted = 0
		and r.member_id is not null 
		and r.member_id <>''
		and r.is_bind = 1   -- 绑车
		and r.bind_date<'2023-10-25'
		)x
	group by 1 
	order by 1	
	)e on e.member_id=a.member_id
left join 
	(select t.member_id,
			COUNT(t.MEMBER_ID) 次数
	FROM `member`.tt_member_score_record t
	left join member.tc_member_info b on t.member_id = b.id
	WHERE (t.event_type in ('60731011','60731003','60731013','60731041','60731052','60731049','60731055','60731006','60731050','60731051','60731056','60731054','60741230','60741231') or 
	t.event_desc in('完成App文章浏览（10秒）任务','完成App签到任务','完成App社区点赞任务','完成App文章加精任务','完成App文章被推荐任务','完成WOW商城每月首次下单任务')) -- 任务类型
--	and t.CREATE_TIME BETWEEN '{start_time_1}' and '{end_time}'  -- 时间
	and t.CREATE_TIME >= '2023-09-26' 
	and t.CREATE_TIME <'2023-10-25'
	and t.IS_DELETED =0 and b.member_status<>60341003
	GROUP by 1
	)c on c.member_id=a.member_id 
left join (
	select x.会员id,
	SUM(x.现金支付金额) num
	from 
		(
			select a.order_code 订单编号
			,b.product_id 商城兑换id
			,a.user_id 会员id
			,a.user_name 会员姓名
			,b.spu_name 兑换商品
			,b.spu_id
			,b.sku_id
			,b.spu_bus_id
			,b.sku_code
			,b.sku_real_point 商品单价
			,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
			 WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台
			,CASE b.spu_type 
				WHEN 51121001 THEN '精品' 
				WHEN 51121002 THEN '第三方卡券' 
				WHEN 51121003 THEN '保养类卡券' 
				WHEN 51121004 THEN '精品'
				WHEN 51121006 THEN '一件代发'
				WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
			,CASE  
				WHEN b.spu_type=51121001 THEN '精品' 
				WHEN b.spu_type=51121002 THEN '第三方卡券' 
				WHEN (b.spu_type=51121003 and f.name not like '%充电%') or (f.name is null)  THEN '保养类卡券' 
				WHEN f.name like '%充电%' THEN '充电产品' 
				WHEN b.spu_type=51121004 THEN '精品'
				WHEN b.spu_type=51121006 THEN '一件代发'
				WHEN b.spu_type=51121007 THEN '经销商端产品' ELSE null end 商品类型2
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
		--	and e.退货状态='退款成功' 
			where a.create_time >= '2023-09-26' and a.create_time <'2023-10-25'   -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and e.order_code is null  -- 剔除退款订单
			order by a.create_time)x
		group by 1
		)d on d.会员id=a.member_id 

