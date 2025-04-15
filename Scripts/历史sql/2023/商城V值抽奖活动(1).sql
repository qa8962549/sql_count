-- 商城V值抽奖活动数据

-- 埋点测试
select * from track.track t where t.usertag = '5537985' order by t.`date` desc

-- PV UV
select
DATE_FORMAT(t.`date`,'%Y-%m-%d')日期, 
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV 
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar)
where t.`date` >= '2022-04-01'
and t.`date` <= '2022-06-05 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint') = 'shop_vDraw_CLICK'  -- 商城V值抽奖活动
group by 1
order by 1;


-- 参与人数，参与次数
select m.日期,COUNT(distinct m.会员ID)参与用户数,COUNT(m.会员ID)参与次数 from 
(select
DATE_FORMAT(a.create_time,'%Y-%m-%d')日期, 
a.member_id 会员ID,
a.nick_name 姓名,
case when a.have_win = '1' then '中奖'
	when a.have_win = '0' then '未中奖'
	end 是否中奖,
case when a.have_send = '1' then '已发放'
	when a.have_send = '0' then '未发放'
	end 奖品是否发放,
a.create_time 抽奖时间,
b.prize_name 中奖奖品,
b.prize_level_nick_name 奖品等级
from volvo_online_activity_module.lottery_draw_log a
left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
where a.lottery_play_code = 'mall_lottery_1'
-- and a.have_win = 1  -- 0未中奖，1中奖
and a.create_time >= '2022-04-01'
and a.create_time <= '2022-06-05 23:59:59'
order by 1)m
group by 1
order by 1


-- 未中奖次数
select m.日期,COUNT(m.会员ID)未中奖次数 from 
(select
DATE_FORMAT(a.create_time,'%Y-%m-%d')日期, 
a.member_id 会员ID,
a.nick_name 姓名,
case when a.have_win = '1' then '中奖'
	when a.have_win = '0' then '未中奖'
	end 是否中奖,
case when a.have_send = '1' then '已发放'
	when a.have_send = '0' then '未发放'
	end 奖品是否发放,
a.create_time 抽奖时间,
b.prize_name 中奖奖品,
b.prize_level_nick_name 奖品等级
from volvo_online_activity_module.lottery_draw_log a
left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
where a.lottery_play_code = 'mall_lottery_1'
and a.have_win = 0  -- 0未中奖，1中奖
and a.create_time >= '2022-04-01'
and a.create_time <= '2022-06-05 23:59:59'
order by 1)m
group by 1
order by 1


-- 中奖次数
select 
m.日期,
count(case when m.中奖奖品='3V值' then m.id end) 3V,
count(case when m.中奖奖品='9V值' then m.id end) 9V,
count(case when m.中奖奖品='30V值' then m.id end) 30V,
count(case when m.中奖奖品='60V值' then m.id end) 60V,
count(case when m.中奖奖品='90V值' then m.id end) 90V,
count(m.id)-count(m.中奖奖品) 未中奖,
count(case when m.中奖奖品='满500减40' then m.id end) 满500减40,
count(case when m.中奖奖品='满300减20' then m.id end) 满300减20,
count(case when m.中奖奖品='满150减15' then m.id end) 满150减15,
count(case when m.中奖奖品='满200减20' then m.id end) 满200减20
from 
(select
DATE_FORMAT(a.create_time,'%Y-%m-%d')日期, 
a.id,
a.member_id 会员ID,
a.nick_name 姓名,
case when a.have_win = '1' then '中奖'
	when a.have_win = '0' then '未中奖'
	end 是否中奖,
case when a.have_send = '1' then '已发放'
	when a.have_send = '0' then '未发放'
	end 奖品是否发放,
a.create_time 抽奖时间,
b.prize_name 中奖奖品,
b.prize_level_nick_name 奖品等级
from volvo_online_activity_module.lottery_draw_log a
left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
where a.lottery_play_code = 'mall_lottery_1'
-- and a.have_win = 1  -- 0未中奖，1中奖
and a.create_time >= '2022-04-01'
and a.create_time <= '2022-06-05 23:59:59'
order by 1)m
group by 1
order by 1



select a.coupon_id,a.卡券名称,a.获得时间,a.卡券状态,a.订单号,b.总金额 from
(-- 卡券领用核销明细
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
WHERE a.coupon_id in ('3446','3445','3418','3417')   -- 4张卡券ID   
and a.get_date <= '2022-06-05 23:59:59'  -- 卡券获得时间
and a.is_deleted = 0
order by a.get_date)a
left JOIN
(-- 根据订单号查询商城下单明细
select m.订单编号,SUM(m.总金额)总金额  from
(select a.order_code 订单编号
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
where a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
and a.order_code in 
(
'384656428409',
'922167741396',
'615642312399',
'349580703331',
'520058597789',
'520058597789',
'503844945082',
'306968952642',
'879448147350',
'664080473562',
'580745463924',
'726275474520',
'537837948321',
'462610865729',
'594313558764',
'750823546032',
'425984936041',
'461036206766',
'672161837453',
'561422171533',
'671373637007',
'232685926273',
'736407936500',
'510971949395',
'243496463952',
'295871603856',
'391604662249',
'828784187130',
'731606134589',
'295110313535',
'401755728633',
'940137907614',
'246393788025',
'382964584217',
'382964584217',
'376357361591',
'463447302582',
'803216791750',
'592097727027',
'164604350348',
'523372760933',
'240908169608',
'223697667971',
'355121158213',
'239365219915',
'674130445252',
'296922142897',
'110595345266',
'669870826665',
'256067615799',
'149071950221',
'906293732721',
'174569911853',
'288096282069',
'425699518981',
'966085925234',
'693230541425',
'625047893470',
'914826363997',
'985199792313',
'421707450528',
'910294498087',
'269036980807',
'204576989125',
'204576989125',
'152765983654',
'871936995508',
'189893999259',
'298674970222',
'964802444723',
'358001407149',
'919391737995',
'301441514011',
'983148806446',
'298768688481',
'989737233682',
'279699686782',
'838132966614',
'995971822598',
'729322826209',
'544509391345',
'314113525831',
'405160353513',
'926016521643',
'124758227428',
'151611946859',
'415162622318',
'310788696814',
'345685596557',
'430004633009',
'492106900486',
'132479495261',
'517021994782',
'852974893205',
'448684271284',
'445416979857',
'445922778557',
'274586630106',
'240484740399',
'427521222774',
'646223801592',
'625781975178',
'979530844017',
'331505784442',
'756843629105',
'683487134996',
'803930746474',
'552079831351',
'384411664089',
'222096599757',
'871636879594',
'336132771332',
'935196387311',
'332997348173',
'317737957820',
'817490370409',
'171646925590',
'409536892945',
'780625186849',
'102987969024',
'603307323918',
'259520142281',
'638820138711',
'451591451968',
'895087617117',
'444920344907',
'388932769758',
'733396213342',
'264719396935',
'840639105765',
'269324481538',
'154531533389',
'386104206277',
'275376553285',
'380391429157',
'380391429157',
'295696731331',
'207766446810',
'580074560426',
'941828457646',
'768820707383',
'214718106828',
'126742628424',
'811543484877',
'705807412383',
'922459571673',
'412497871188',
'970629136074',
'108023293048',
'121809247678',
'771236357201',
'985745377522',
'423755105020',
'948100529960',
'614129851303',
'760846909984',
'117207843667',
'761368542945',
'764859435751',
'327574679183',
'941811784767',
'524382970095',
'687346675551',
'824917505346',
'157381997898',
'588968189302',
'622925543626',
'410825899656',
'654292706805',
'248225939267',
'851960504312',
'694985141792',
'774867837305',
'833735269626',
'297356182235',
'780549488954',
'234338836472',
'966489464791',
'986516497652',
'430655340529',
'703741348956',
'480005370963',
'830027385540',
'766294496081',
'100393718171',
'734746134868',
'206536349078',
'152996878355',
'261038549719',
'508389826396',
'473939957582',
'560123962052',
'866611621047',
'980963369232',
'923672891732',
'979213946338',
'118274785639',
'853231706424',
'556267687532',
'846553133470',
'564100267747',
'857047275738',
'868491394679',
'918876507140',
'394914589678',
'620863386198',
'661133388128',
'561463566834',
'487049768669',
'499863535688',
'353192148095',
'240411439535',
'719180637237',
'305014783748',
'828285114068',
'106898416557',
'719499488892',
'228541345123',
'663743381786',
'672361912271',
'392888232019',
'947793718422',
'297382219926',
'595118889040',
'938340342459',
'874317283136',
'894941968501',
'332425143550',
'837434285923',
'948168923024',
'181866906254',
'646064252698',
'383371742064',
'496361422386',
'148707966922',
'591462244590',
'908960534144',
'168751687434',
'901938740922',
'803867247033',
'233467395752',
'807482501103',
'494474907154',
'146810663872',
'284795997100',
'214503674027',
'767696755866',
'741780312327',
'749147773885',
'273640575524',
'988063472831',
'870033282461',
'466146932374',
'969339666085',
'644101578883',
'949948356521',
'787438324206',
'868059798987',
'167943803584',
'137561876222',
'602389733822',
'512268468546',
'588136542699',
'216436520386',
'536770968821',
'686806837562',
'750996441279',
'530602240767',
'106012244384',
'795060678406',
'507376989879',
'721504123568',
'960752177241',
'824228955396',
'491655191186',
'478275145559',
'935887447272',
'907734413148',
'566213272386',
'566213272386',
'501523607018',
'396210230344',
'716176383620',
'478235746088',
'953040186763',
'717916389928',
'231327560751',
'906812803011',
'252616897642',
'300822351901',
'541504127831',
'761712457989',
'219221961068',
'659998648193',
'736730363637',
'528566329774',
'454262376873',
'258103557537',
'664763306267',
'937007849460',
'420113624243',
'388798662961',
'402919289947',
'532107319396',
'966954707258',
'298729857073',
'646323386320',
'428054193089',
'446260839321',
'290135951328',
'965468846466',
'272251188467',
'930730411694',
'527469845918',
'689076223203',
'882411919066',
'898498975698',
'367215988813',
'972631970156',
'476622539085',
'188292845792',
'230330856599',
'900913117496',
'947888720187',
'871297805953',
'398113594641',
'152737979175',
'987291160575',
'997634717105',
'540577103326',
'695105813663',
'183142670546',
'234518625014',
'139285545097',
'602485532480',
'236291344626',
'125720397453',
'305907822618',
'182802488319',
'885622195986',
'436631602414',
'966565420092',
'398476873695',
'790623566114',
'329203569901',
'490293360777',
'194160242425',
'612008297940',
'131739214952',
'931612753868',
'841295171271',
'101847281887',
'889247826739',
'383328742707',
'364773488593',
'585852888773',
'169409578736',
'925204909948',
'120677930082',
'703986954927',
'384581585927',
'384581585927',
'483864932569',
'234023986906',
'422804868210',
'634734434728',
'648967628537',
'125453161069',
'769501331220',
'852558313188',
'961163321418',
'160870279631',
'360772486124',
'553068411552',
'607701124896',
'935641349402',
'181427457562',
'364649781905',
'622705683782',
'355477552828',
'398146450378',
'362785367230',
'183653791103',
'151142323917',
'424667738203',
'344143307603',
'693174523553',
'431969156022',
'902951404948',
'609903376968',
'661163581688',
'392701927295',
'309694299146',
'570386217482',
'863760852445',
'913186543083',
'931490824023',
'833898430537',
'499862967219',
'496508698846',
'719207652765',
'672269416647',
'420910313704',
'985602493920',
'677319538278',
'982887303154',
'310993821531',
'195324895220',
'768352903414',
'531972778313',
'688630425456',
'776468219918',
'939032694456',
'567779792339',
'780729612615',
'533161351685',
'113467583955',
'784953636187',
'408241447535',
'260941312657',
'770541194851',
'536526109495',
'515455754776',
'687051282702',
'543742121823',
'431389246492',
'338901468361',
'950255924713',
'930385505983',
'350853521092',
'675927162610',
'384808879455',
'371964844017',
'345437964099',
'493674725066',
'610181989231',
'976748377833',
'653343111456',
'910609400761',
'861483821055',
'589658250780',
'727641687264',
'510406117179',
'134482827832',
'921433427141',
'526363371527',
'152631955499',
'534121788275',
'296627346482',
'875460866603',
'965911596935',
'325187680793',
'202050214471',
'454428443504',
'436298460119',
'436298460119',
'765782180616',
'394293133797',
'385687555500',
'244145682647',
'434800791633',
'143516594460',
'502354734016',
'315722307746',
'368619956446',
'628979957161',
'628901964079',
'553738434590',
'932185240390',
'306393949343',
'216117613549',
'355808915288',
'270010599029',
'606410133160',
'642173520294',
'909578118978',
'211061363481',
'138331990605',
'767536193283',
'379330219534',
'924849746380',
'517255638121',
'414855931442',
'815184645395',
'795969957624',
'241683849437',
'879437912062',
'292820789785',
'186739983813',
'818356228714',
'983548417067',
'760724372484',
'389494376142',
'682708221169',
'832820474355',
'794346108991',
'804343191386',
'243312578223',
'613126462171',
'845080620413',
'310258511903',
'294537243083',
'753328762292',
'915786149250',
'757377866808',
'259861972152',
'890637677586',
'426939522772',
'544331682122',
'579948215564',
'520603224042',
'277476647481',
'502030794614',
'717150192778',
'237195387907',
'383435514699',
'626114132738',
'748418613805',
'100298526020',
'666998333301',
'757441479717',
'411637730174',
'725592576150',
'738475381229',
'734361682283',
'626664271382',
'599522320597',
'745662640687',
'186463497553',
'664163939464',
'664163939464',
'576815183879',
'786709520028',
'971293494886',
'861167744574',
'394143832632',
'721180255619',
'910551189504',
'730950404374',
'198611813415',
'513102782375',
'997092801531',
'994458914478',
'408677322529',
'207574989509',
'626033595834',
'189071546880',
'121673809087',
'438740593875',
'407022522282',
'159646664939',
'453313718517',
'921508176067',
'314668744557',
'240533170428',
'941232137033',
'931076377359',
'896199454738',
'304874407512',
'268408565286',
'910133980472',
'447663805961',
'231560742297',
'747194375390',
'523080981016',
'956758177637',
'659214614254',
'136561699068',
'859048180508',
'694320275729',
'154071780987',
'264951205638',
'632102149785',
'713269191782',
'764787424424',
'165547412186',
'321627284580',
'252428497337',
'248390200568',
'532280964166',
'532280964166',
'401521109042',
'832106819778',
'372182667876',
'501773635110',
'745588694442',
'644993586121',
'186079799553',
'553422739726',
'351834472509',
'470483296804',
'529299355503',
'401864451062',
'653875216475',
'991774862411',
'766062296990',
'774378996059',
'921042878805',
'241250196794',
'356138124146',
'733650246065',
'603676335907',
'580555355311',
'338653452121',
'143058181739',
'479432508146',
'152457778505',
'104115971572',
'751023676658',
'669524353876',
'877490504547',
'971811341615',
'202803539848',
'131186386402',
'575964973044',
'904302872459',
'511100124463',
'259393863733',
'974833623964',
'765071206309',
'521261652974',
'789779617878',
'806064141450',
'686187342239',
'734166654249',
'535798424979',
'932005725908',
'644295520781',
'866738278271'
)
order by a.create_time)m 
group by 1)b
on a.订单号 = b.订单编号