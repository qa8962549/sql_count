select
-- DATE_FORMAT(t.date,'%Y-%m-%d') ,
case 
when t.typeid ='XWSJXCX_START' then '小程序'#
when t.`data` like '%EE0D7595A1724A56A5E6DC4BF74C564B%' then '小程序首页banner '
when t.`data` like '%8E4445B767564C538D1AF6A841F0795C%' then '小程序首页弹窗'
when t.`data` like '%680F8B8137C64537A611AB89F4BF886D%' then '沃的活动列表banner'
when t.`data` like '%375FA8B680AD4C4C972F23DDA25E16D2%' then '小程序文章主活动引流'
when t.`data` like '%08F51F65589443289EECF091BA2D3285%' then '商城首页banner'
when t.`data` like '%0CC72F17CAEE4F1CB9ACC825705F9FEE%' then '海报太阳码'
when t.`data` like '%8F17499925034CD4B2C34ED50525A116%' then '短信-V值逾期-至小程序'
when t.`data` like '%09C45C24100C4EA5BEA66A88C1A07576%' then '攻略推文引流'
when t.`data` like '%0C10B621B36B4D31B8EF40EC18BF9123%' then '其他公众号推文引流'
else null end '分类',
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV,
COUNT(DISTINCT CASE WHEN tmi.is_vehicle =1 THEN t.usertag else null end) 车主UV,
COUNT(DISTINCT CASE WHEN tmi.is_vehicle =0 THEN t.usertag else null end) 粉丝UV
from track.track t
left join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2023-02-20' AND t.`date` <'2023-03-16'
group by 1
order by 1


#消费金额以及获取最后一笔订单时间 
		select a.*
		from (
				select DISTINCT 
				a.fee/100 支付金额
				,a.create_time 兑换时间
				,a.order_code 订单编号
				,CASE a.status
					WHEN 51031002 THEN '待付款' 
					WHEN 51031003 THEN '待发货' 
					WHEN 51031004 THEN '待收货' 
					WHEN 51031005 THEN '已完成'
					WHEN 51031006 THEN '已关闭'  
				END AS 订单状态
				,a.user_id 会员id
				,case when tmi.IS_VEHICLE = '1' then '车主'
				when tmi.IS_VEHICLE = '0' then '粉丝'
				end 用户类型
				,case when tmi.member_sex = '10021001' then '先生'
				when tmi.member_sex = '10021002' then '女士'
				else '未知' end 性别
				,b.收货人姓名
				,tmi.MEMBER_PHONE 注册手机号
				 ,row_number() over(PARTITION by a.user_id order by a.create_time desc) rk
				from order.tt_order a  -- 订单主表
				left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
				left join `member`.tc_member_info tmi on tmi.ID =a.user_id
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
					)b on b.MEMBER_ID=a.user_id 
				where a.create_time >= '2023-03-15' and a.create_time<'2023-03-16'  -- 订单时间
				and a.is_deleted <> 1  -- 剔除逻辑删除订单
				and a.type = 31011003  -- 筛选沃世界商城订单
				and a.separate_status = '10041002' -- 选择拆单状态否
				and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
				AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
				and (b.spu_type in (51121001,51121004) and a.status<>51031006 ) -- 精品
				and e.order_code is null  -- 剔除退款订单
				and a.fee/100>=1000
				order by a.create_time,1 desc
				)a where a.rk=1
				and a.会员id not in ('6303200',
'5832922',
'5564141',
'5368414',
'4285773',
'6562796',
'5625484',
'6118721',
'5837902',
'5287583',
'5643570',
'6348804',
'4591411',
'6160198',
'3084795',
'5292667',
'5286826',
'4788398',
'4749350',
'4770137',
'3509293',
'4572153',
'5566976',
'5856147',
'5640863',
'6503812',
'4719433',
'5920761',
'3328449',
'5261013',
'6425741',
'4398740',
'5860132',
'5866820',
'5369503',
'6418877',
'6149049',
'4200439',
'4544301',
'6544341',
'4226115',
'4724998',
'6337698',
'3123510',
'5285981',
'5972433',
'4623089',
'4559300',
'4555555',
'6311172',
'5784587',
'5793193',
'5617671',
'6420213',
'3545220',
'4571397',
'3237515',
'5347445',
'4236711',
'4813841',
'5993305',
'6123179',
'4591668',
'3341906',
'4787616',
'6163561',
'5285666',
'4583316',
'6018074',
'5363431',
'5841090',
'6304334',
'6591520',
'4617106',
'5806631',
'6246820',
'6599026',
'6239153',
'6674747',
'4321951',
'5806736',
'6387536',
'4539639',
'5603542',
'4657615',
'4794472',
'5890312',
'4621653',
'5872490',
'5511970',
'6568981',
'4604922',
'3406851',
'5565558',
'5634850',
'5798557',
'6201190',
'6060945',
'5791229',
'3786702',
'5579307',
'3443176',
'4724516',
'5968258',
'4783745',
'3305418',
'5615319',
'3588548',
'6573259',
'5814753',
'3564393',
'6602084',
'4726149',
'4469586',
'6043499',
'6396414',
'4531279',
'5789630',
'4316392',
'6686912',
'3831579',
'4222051',
'5775988',
'4082897',
'3131417',
'5247550',
'6391984',
'6113613',
'6128784',
'5885100',
'6674689',
'4453856',
'5736020',
'6019916',
'3453336',
'5741347',
'6714290',
'6230850',
'6714380',
'6696026',
'5659334',
'4730556',
'4300308',
'5905352',
'5953629',
'3906987',
'6720082',
'6720433',
'6692216',
'6386001',
'5244410',
'6126674',
'6360460',
'5258999',
'6722337',
'6053464',
'6505637',
'6680021',
'5826907',
'4747624',
'5875537',
'6203099',
'6637729',
'5262660',
'4621368',
'5560705',
'4627621',
'4656960',
'4641839',
'4647707',
'4761494',
'6466906',
'4756454',
'6358453',
'5769748',
'5395033',
'4755545',
'5775717',
'6702179',
'5283185',
'5889024',
'5267421',
'4665884',
'4254593',
'5938555',
'3776095',
'6695169',
'6594959',
'4249074',
'4747886',
'4726545',
'5978057',
'4722983',
'4291646',
'3966703',
'5587031',
'4454085',
'4617324',
'3876099',
'4761803',
'3385881',
'4221330',
'4424383',
'4468622',
'6423894',
'6190413',
'4212773',
'5842076',
'6315802',
'3612299',
'4645992',
'4745985',
'4578690',
'5869139',
'4639566',
'4724183',
'4758744',
'4771731',
'4728361',
'4735167',
'3286570',
'4729809',
'4787036',
'6461664',
'4755432',
'6681838',
'4806971',
'6113380',
'4231553',
'5634286')
				limit 10

				

-- app评论
select 
a.member_id 会员ID,
a.id 动态ID,
a.create_time 评论日期,
-- '#ENJOY VOLVO LIFE+圣诞快乐#' 评论tag,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tmi.MEMBER_PHONE 手机号码,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
a.comment_content 评论内容,
-- (length(a.comment_content)-CHAR_LENGTH(a.comment_content))/2  评论字数,
a.images 上传图片,
tmi.MEMBER_NAME 昵称,
tmi.real_name 姓名,
a.like_count 点赞数
from community.tm_comment a
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
where a.is_deleted =0
and a.create_time >='2023-02-20'
and a.create_time <'2023-03-16'
and a.post_id ='egqwxeYm38'
-- and a.comment_content like '%真好%'

