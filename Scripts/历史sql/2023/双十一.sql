#游戏数据统计
select '1抽盲盒参与用户数',count(DISTINCT member_id)
from volvo_online_activity_module.lottery_draw_log a
-- left join volvo_online_activity_module.lottery_play_pool b on a.prize_code =b.prize_code 
where a.lottery_code ='double_eleven'
and a.create_time >='2022-10-28'
and a.create_time <'2022-11-12'
union all 
select '2抽盲盒参与次数（总计）',count(1)
from volvo_online_activity_module.lottery_draw_log a
-- left join volvo_online_activity_module.lottery_play_pool b on a.prize_code =b.prize_code 
where a.lottery_code ='double_eleven'
and a.create_time >='2022-11-11'
and a.create_time <'2022-11-12'
union all 
select '3抽盲盒参与次数（V值）',count(1)
from volvo_online_activity_module.lottery_draw_log a
left join volvo_online_activity_module.lottery_play_pool b on a.prize_code =b.prize_code 
where a.lottery_code ='double_eleven'
and a.create_time >='2022-11-11'
and a.create_time <'2022-11-12'
and b.prize_name like '%V%'
order by 1


-- 奖品统计
select b.prize_name,count(1)
from volvo_online_activity_module.lottery_draw_log a
left join volvo_online_activity_module.lottery_play_pool b on a.prize_code =b.prize_code 
where a.lottery_code ='double_eleven'
and a.create_time >='2022-11-11'
and a.create_time <'2022-11-12'
group by 1
order by 1

-- app愿望清单评论
select m.id,
m.MEMBER_PHONE,
a.comment_content 评论内容,
a.create_time 评论时间,
row_number() over(order by a.create_time) 评论楼层
from community.tm_comment a
left join `member`.tc_member_info m on a.member_id =m.ID 
where a.post_id ='YJOOZAgSfv'
and a.is_deleted =0
-- and a.comment_content like '%#有点东西%'

-- 阶梯满额赠奖品发放明细
-- 满1000元的前100名
	select 
	a.会员id,
	m.MEMBER_PHONE 沃世界注册手机号,
	'' 奖品名称,
	a.消费金额,
	a.最后一笔订单时间,
	b.收货人姓名,
	b.收货人手机号,
	b.收货地址
	from 
	(
		#消费金额以及获取最后一笔订单时间
			select 
			a.会员id,
			case when sum(a.支付V值/3+a.现金支付金额)>=1000 and sum(a.支付V值/3+a.现金支付金额)<2000 then 1
				when sum(a.支付V值/3+a.现金支付金额)>=2000 and sum(a.支付V值/3+a.现金支付金额)<3000 then 2 
				when sum(a.支付V值/3+a.现金支付金额)>=3000 then 3 
				end as 阶梯,
			ROUND(sum(a.支付V值/3+a.现金支付金额),2) 消费金额,
			max(a.兑换时间) 最后一笔订单时间
			from (
			select DISTINCT a.order_code 订单编号
			,b.product_id 商城兑换id
			,a.user_id 会员id
			,a.user_name 会员姓名
			,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
			,CASE b.spu_type 
				WHEN 51121001 THEN '精品' 
				WHEN 51121002 THEN '第三方卡券' 
				WHEN 51121003 THEN '保养类卡券' 
				WHEN 51121004 THEN '精品'
				WHEN 51121006 THEN '一件代发'
				WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
			,b.pay_fee/100 现金支付金额
			,b.point_amount 支付V值
			,a.create_time 兑换时间
			from order.tt_order a  -- 订单主表
			left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
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
			where a.create_time BETWEEN '2022-10-28' and '2022-11-11 23:59:59'  -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004) and a.status<>51031006 ) -- 精品
			and e.order_code is null  -- 剔除退款订单
-- 			and a.user_id=3019144
			order by a.create_time
			) a 
			where a.商品类型='精品'
			group by 1
			order by 2 desc )a 
	left join `member`.tc_member_info m on a.会员id=m.ID 
	left join 
			(
			#匹配收货信息
			select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
			(
			select 
			tma.MEMBER_ID,
			tma.CONSIGNEE_NAME 收货人姓名,
			tma.CONSIGNEE_PHONE 收货人手机号,
			CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址,
			row_number() over(partition by tma.member_address order by tma.create_time desc) rk
			from `member`.tc_member_address tma
			left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
			left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
			left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
			where tma.IS_DELETED = 0
			and tma.IS_DEFAULT = 1   -- 默认收货地址
			)c where c.rk = 1
			)b on b.MEMBER_ID=a.会员id
		order by 5
			
-- 盲盒		
SELECT a.member_id 会员ID,
		m.MEMBER_PHONE 沃世界注册手机号,
		b.prize_name 奖品名称,
		a.create_time 中奖时间,
		m.REAL_NAME 收货人姓名,
		m.MEMBER_PHONE 收货人手机,
		d.address 收货地址
FROM volvo_online_activity_module.lottery_draw_log a
left join volvo_online_activity_module.lottery_play_pool b on a.prize_code = b.prize_code 
left join member.tc_member_info m on a.member_id=m.ID
left join (
	select a.*
	from (
		select m.id,m.REAL_NAME,CONCAT(c.REGION_NAME,cc.REGION_NAME,ccc.REGION_NAME,a.MEMBER_ADDRESS) address
		,row_number() over(partition by a.MEMBER_ID order by a.create_time desc) rk
		from member.tc_member_info m 
		join member.tc_member_address a on m.id=a.member_id and a.IS_DEFAULT=1 and a.IS_DELETED=0
		left join dictionary.tc_region c on a.ADDRESS_PROVINCE=c.REGION_CODE
		left join dictionary.tc_region cc on a.ADDRESS_CITY=cc.REGION_CODE
		left join dictionary.tc_region ccc on a.ADDRESS_REGION=ccc.REGION_CODE
		where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	) a 
	where a.rk=1
) d on d.id=m.id
WHERE a.lottery_code = 'double_eleven'
AND a.have_win = 1
AND a.create_time between '{start_time}' and '{end_time}'