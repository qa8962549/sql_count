-- 销售商品概览2  _注意修改时间
select 
m.sku_code,
--m.兑换商品,
 sum(m.兑换数量) 总件数,
  sum(m.总金额) 商城销售额
from 
(select a.order_code 订单编号
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
	WHEN b.spu_type=51121003 and f.name not like '%充电%' THEN '保养类卡券' 
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
--and e.退货状态='退款成功' 
where 1=1
--and a.create_time >= '2023-05-01' and a.create_time <'2023-05-19'   -- 518
and a.create_time >= '2024-06-04' and a.create_time <'2024-06-22'   -- 618
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and b.sku_code in ('32355493',
'32355492',
'31422857',
'31422856',
'31422858',
'32284589',
'31422675',
'32355046',
'CDQY300D',
'31422752',
'32355441',
'32355532',
'32355534',
'32284810',
'32355387',
'32355386',
'32355373',
'32355271',
'32355272',
'32355273',
'32355274',
'32355270',
'32355275',
'32355269',
'32355384',
'32355383',
'32355489',
'32355487',
'32355428',
'32355429',
'32355002',
'32355007',
'32355005',
'32355003',
'32355004',
'32355006',
'32355014',
'32355137',
'32355138',
'32355127',
'32355128',
'32355129',
'32355130',
'32355139',
'32355140',
'32355145',
'32355146',
'32355133',
'32355134',
'32355135',
'32355136',
'32355141',
'32355142',
'32355143',
'32355144',
'32355131',
'32355132',
'32355147',
'32355148',
'32332727',
'32332725',
'XFLGG01',
'XFLGG02',
'921000107',
'ZDSKQJHQ',
'FDJXHBXC40',
'FDJXHBXC60',
'FDJXHBXC90',
'FDJXHBS60',
'FDJXHBS90',
'FDJXHBV60',
'FDJXHBV90',
'S60ZNDDWM',
'XC40JCBY02',
'XC40JCBY03',
'XC40JCBY04',
'XC40JCBY05',
'XC60JCBY02',
'XC60JCBY03',
'XC60JCBY04',
'XC60JCBY05',
'XC90JCBY02',
'XC90JCBY03',
'XC90JCBY04',
'XC90JCBY05',
'S60JCBY02',
'S60JCBY03',
'S60JCBY04',
'S60JCBY05',
'S90JCBY02',
'S90JCBY03',
'S90JCBY04',
'S90JCBY05',
'V60JCBY02',
'V60JCBY03',
'V60JCBY04',
'V60JCBY05',
'V90JCBY02',
'V90JCBY03',
'V90JCBY04',
'V90JCBY05',
'C40TYD01',
'XC40BEVTYD01',
'S60LTYD01',
'S60LTYD02',
'S60MTYD01',
'S60MTYD02',
'S60HTYD01',
'S60HTYD02',
'S90LTYD01',
'S90LTYD02',
'S90MTYD01',
'S90MTYD02',
'S90HTYD01',
'S90HTYD02',
'XC40MTYD01',
'XC40HTYD01',
'XC60LTYD01',
'XC60LTYD02',
'XC60MTYD01',
'XC60MTYD02',
'XC60HTYD01',
'XC60HTYD02',
'XC90LTYD01',
'XC90LTYD02',
'XC90HTYD01',
'XC90HTYD02',
'XC90TTYD01',
'XC90TTYD02',
'V60MTYD01',
'V60MTYD02',
'V60HTYD01',
'V60HTYD02',
'N921000100',
'32214963',
'CDQY750D',
'CDQY1500D',
'PPCDZ7KW',
'PPCDZ11KW')
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
order by a.create_time) m
group by 1 
order by 1 



-- 发帖明细
select 
distinct 
a.member_id 会员ID,
a.post_id 文章ID,
tmi.REAL_NAME 用户姓名,
tmi.MEMBER_NAME 用户昵称,
case when tmi.IS_VEHICLE = '1' then '车主' when tmi.IS_VEHICLE = '0' then '粉丝' end 用户类型,
case when tmi.member_level = 1 then '银卡'
     when tmi.member_level = 2 then '金卡'
     when tmi.member_level = 3 then '白金卡' 
     when tmi.member_level = 4 or   tmi.member_level = 5 then '黑卡' end 会员等级,
tmi.MEMBER_PHONE 沃世界注册手机号码,
a.create_time 发帖时间,
l.topic_id 话题id,
replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ','')  "发帖内容",
char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))  "发帖字数",
pm.发帖图片数量,
a.like_count 动态点赞数,
pm.发帖图片链接  发帖图片链接
--a.post_type "帖子类型(动态1001/文章1002/活动1006/UGC文章1007)",
--a.post_state "帖子状态:1上架,2下架,4审核中,5审核不通过"
--tisd.invoice_date 最后购车开票时间
--datediff(a.create_time,tisd.invoice_date)
from community.tm_post a
left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join
(
		-- 发帖内容、图片
	select
	t.post_id,
	replace(string_agg(case when t.类型='text' then t.内容 else null end ,';'),' ','') as 发帖内容,
	string_agg(case when t.类型='image' then t.内容 else null end ,';') as 发帖图片链接,
	count(case when t.类型='image' then t.内容 else null end) as 发帖图片数量
	from
	(
		select
		tpm.post_id,
		tpm.create_time,
		replace(tpm.node_content,E'\\u0000','') 发帖内容,
		json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeType' 类型,
		json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeContent' 内容
		from community.tt_post_material tpm
		where 1=1
--		and tpm.create_time >= '2023-11-06' and tpm.create_time < '2023-11-13'
		and tpm.is_deleted = 0
	) as t
	group by t.post_id
) pm on a.post_id = pm.post_id
where a.is_deleted =0
and a.create_time >='2024-06-04'
and a.create_time <'2024-06-24'
and l.topic_id ='4ra2tsrlVG' --  话题：618夏日好物
--and tmi.IS_VEHICLE = '1'-- 车主
--and char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))>=300 --帖子字数不少于300字
--and pm.发帖图片数量>=6 -- 配图不少于6张的文章及动态
--and datediff(a.create_time,tisd.invoice_date)<=365 -- 最后开票时间距发帖时间在一年以内
--and a.member_id ='6873815'
order by a.create_time

