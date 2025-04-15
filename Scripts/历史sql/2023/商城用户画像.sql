-- 画像V2
select x.*
from 
(
	-- 取用户最近一次下单数据
	select a.order_code 订单编号
	,a.coupon_fee/100 优惠券抵扣金额
	,if(a.coupon_fee='0' or a.coupon_fee is null,'否','是')是否使用优惠券
	,round(a.point_amount/3+a.pay_fee/100,2) 实付金额
	,a.pay_fee/100 现金支付金额
	,round((a.point_amount/3)/(a.point_amount/3+a.pay_fee/100),2) V值支付金额占比
	,x5.截止下单前前V值余额
	,a.point_amount 支付V值
	,a.create_time 兑换时间
	,case when a.pay_fee=0 then '纯V值支付' when a.point_amount=0 then '纯现金支付' else '混合支付' end 支付方式
	,a.user_id 会员id,
	a.user_name 会员姓名,
	a.create_time 最近一次下单时间,
	case when m.member_sex = '10021001' then '先生'
		when m.member_sex = '10021002' then '女士'
		else '未知' end 性别,
	case when m.IS_VEHICLE = '1' then '绑定'
		else '未绑定' end 是否绑定车辆,
	ifnull(t.车型,'未知') 车型,
	tl.LEVEL_NAME 会员等级,
	ifnull(t2.手机型号,'未知') 手机型号,
	ifnull(x.tt,0) 签到天数,
	case when ifnull(x.tt,0)<0.1*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 then '满签率小于10%'
		when ifnull(x.tt,0)>=0.1*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 and ifnull(x.tt,0)<0.2*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 then '满签率10-20%'
		when ifnull(x.tt,0)>=0.2*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 and ifnull(x.tt,0)<0.3*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 then '满签率20-30%'
		when ifnull(x.tt,0)>=0.3*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 and ifnull(x.tt,0)<0.4*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 then '满签率30-40%'
		when ifnull(x.tt,0)>=0.4*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 and ifnull(x.tt,0)<0.5*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 then '满签率40-50%'
		when ifnull(x.tt,0)>=0.5*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 and ifnull(x.tt,0)<0.6*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 then '满签率50-60%'
		when ifnull(x.tt,0)>=0.6*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 and ifnull(x.tt,0)<0.7*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 then '满签率60-70%'
		when ifnull(x.tt,0)>=0.7*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 and ifnull(x.tt,0)<0.8*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 then '满签率70-80%'
		when ifnull(x.tt,0)>=0.8*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 and ifnull(x.tt,0)<0.9*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 then '满签率80-90%'
		when ifnull(x.tt,0)>=0.9*DATEDIFF('2023-02-28 23:59:59','2022-01-10')+1 then '满签率90%以上' else null end '签到满签前率',
	m.MEMBER_V_NUM V值余额,
	case -- when m.MEMBER_V_NUM<0 then '-1'
		when m.MEMBER_V_NUM<=0 then 0 
		when m.MEMBER_V_NUM>0 and m.MEMBER_V_NUM<=3 then '01 (0,3]'
		when m.MEMBER_V_NUM>3 and m.MEMBER_V_NUM<=10 then '02 (3,10]'
		when m.MEMBER_V_NUM>10 and m.MEMBER_V_NUM<=100 then '03 (10,100]'
		when m.MEMBER_V_NUM>100 and m.MEMBER_V_NUM<=300 then '04 (100,300]'
		when m.MEMBER_V_NUM>300 and m.MEMBER_V_NUM<=600 then '05 (300,600]'
		when m.MEMBER_V_NUM>600 and m.MEMBER_V_NUM<=1000 then '06 (600,1000]'
		when m.MEMBER_V_NUM>1000 and m.MEMBER_V_NUM<=2000 then '07 (1000,2000]'
		when m.MEMBER_V_NUM>2000 and m.MEMBER_V_NUM<=3000 then '08 (2000,3000]'
		when m.MEMBER_V_NUM>3000 and m.MEMBER_V_NUM<=4000 then '09 (3000,4000]'
		when m.MEMBER_V_NUM>4000 and m.MEMBER_V_NUM<=5000 then '10 (4000,5000]'
		when m.MEMBER_V_NUM>5000 and m.MEMBER_V_NUM<=6000 then '11 (5000,6000]'
		when m.MEMBER_V_NUM>6000 and m.MEMBER_V_NUM<=7000 then '12 (6000,7000]'
		when m.MEMBER_V_NUM>7000 and m.MEMBER_V_NUM<=8000 then '13 (7000,8000]'
		when m.MEMBER_V_NUM>8000 and m.MEMBER_V_NUM<=9000 then '14 (8000,9000]'
		when m.MEMBER_V_NUM>9000 and m.MEMBER_V_NUM<=10000 then '15 (9000,10000]'
		when m.MEMBER_V_NUM>10000 and m.MEMBER_V_NUM<=12000 then '16 (10000,12000]'
		when m.MEMBER_V_NUM>12000 and m.MEMBER_V_NUM<=14000 then '17 (12000,14000]'
		when m.MEMBER_V_NUM>14000 and m.MEMBER_V_NUM<=16000 then '18 (14000,16000]'
		when m.MEMBER_V_NUM>16000 and m.MEMBER_V_NUM<=18000 then '19 (16000,18000]'
		when m.MEMBER_V_NUM>18000 and m.MEMBER_V_NUM<=20000 then '20 (18000,20000]'
		when m.MEMBER_V_NUM>20000 and m.MEMBER_V_NUM<=22000 then '21 (20000,22000]'
		when m.MEMBER_V_NUM>22000 and m.MEMBER_V_NUM<=24000 then '22 (22000,24000]'
		when m.MEMBER_V_NUM>24000 and m.MEMBER_V_NUM<=26000 then '23 (24000,26000]'
		when m.MEMBER_V_NUM>26000 and m.MEMBER_V_NUM<=28000 then '24 (26000,28000]'
		when m.MEMBER_V_NUM>28000 and m.MEMBER_V_NUM<=30000 then '25 (28000,30000]'
		when m.MEMBER_V_NUM>30000 and m.MEMBER_V_NUM<=32000 then '26 (30000,32000]'
		when m.MEMBER_V_NUM>32000 and m.MEMBER_V_NUM<=34000 then '27 (32000,34000]'
		when m.MEMBER_V_NUM>34000 and m.MEMBER_V_NUM<=36000 then '28 (34000,36000]'
		when m.MEMBER_V_NUM>36000 and m.MEMBER_V_NUM<=38000 then '29 (36000,38000]'
		when m.MEMBER_V_NUM>38000 and m.MEMBER_V_NUM<=40000 then '30 (38000,40000]'
		when m.MEMBER_V_NUM>40000 and m.MEMBER_V_NUM<=42000 then '31 (40000,42000]'
		when m.MEMBER_V_NUM>42000 and m.MEMBER_V_NUM<=44000 then '32 (42000,44000]'
		when m.MEMBER_V_NUM>44000 and m.MEMBER_V_NUM<=46000 then '33 (44000,46000]'
		when m.MEMBER_V_NUM>46000 and m.MEMBER_V_NUM<=48000 then '34 (46000,48000]'
		when m.MEMBER_V_NUM>48000 and m.MEMBER_V_NUM<=50000 then '35 (48000,50000]'
		when m.MEMBER_V_NUM>50000 then '36 (50000,‘+∞]'
	else null end V值余额区间,
	ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0) V值总消耗,
	case -- when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<0 then '-1'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=0 then 0 
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>0 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=3 then '01 (0,3]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>3 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=10 then '02 (3,10]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>10 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=100 then '03 (10,100]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>100 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=300 then '04 (100,300]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>300 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=600 then '05 (300,600]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>600 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=1000 then '06 (600,1000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>1000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=2000 then '07 (1000,2000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>2000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=3000 then '08 (2000,3000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>3000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=4000 then '09 (3000,4000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>4000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=5000 then '10 (4000,5000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>5000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=6000 then '11 (5000,6000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>6000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=7000 then '12 (6000,7000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>7000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=8000 then '13 (7000,8000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>8000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=9000 then '14 (8000,9000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>9000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=10000 then '15 (9000,10000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>10000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=12000 then '16 (10000,12000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>12000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=14000 then '17 (12000,14000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>14000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=16000 then '18 (14000,16000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>16000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=18000 then '19 (16000,18000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>18000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=20000 then '20 (18000,20000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>20000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=22000 then '21 (20000,22000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>22000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=24000 then '22 (22000,24000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>24000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=26000 then '23 (24000,26000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>26000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=28000 then '24 (26000,28000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>28000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=30000 then '25 (28000,30000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>30000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=32000 then '26 (30000,32000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>32000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=34000 then '27 (32000,34000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>34000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=36000 then '28 (34000,36000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>36000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=38000 then '29 (36000,38000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>38000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=40000 then '30 (38000,40000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>40000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=42000 then '31 (40000,42000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>42000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=44000 then '32 (42000,44000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>44000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=46000 then '33 (44000,46000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>46000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=48000 then '34 (46000,48000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>48000 and ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)<=50000 then '35 (48000,50000]'
		when ifnull(m.MEMBER_TOTAL_NUM - m.MEMBER_V_NUM - m.MEMBER_LOCK_V_NUM,0)>50000 then '36 (50000,‘+∞]'
	else null end V值总消耗区间,
	timestampdiff(year,m.CREATE_TIME,'2023-02-28 23:59:59') 会龄,
	ifnull(x2.tt,0) 会员日参与次数,
	x4.最近一次消费间隔,
	x3.下单次数,
	x3.累计支付V值，
	case -- when x3.累计支付V值<0 then '-1'
		when x3.累计支付V值<=0 then 0 
		when x3.累计支付V值>0 and x3.累计支付V值<=3 then '01 (0,3]'
		when x3.累计支付V值>3 and x3.累计支付V值<=10 then '02 (3,10]'
		when x3.累计支付V值>10 and x3.累计支付V值<=100 then '03 (10,100]'
		when x3.累计支付V值>100 and x3.累计支付V值<=300 then '04 (100,300]'
		when x3.累计支付V值>300 and x3.累计支付V值<=600 then '05 (300,600]'
		when x3.累计支付V值>600 and x3.累计支付V值<=1000 then '06 (600,1000]'
		when x3.累计支付V值>1000 and x3.累计支付V值<=2000 then '07 (1000,2000]'
		when x3.累计支付V值>2000 and x3.累计支付V值<=3000 then '08 (2000,3000]'
		when x3.累计支付V值>3000 and x3.累计支付V值<=4000 then '09 (3000,4000]'
		when x3.累计支付V值>4000 and x3.累计支付V值<=5000 then '10 (4000,5000]'
		when x3.累计支付V值>5000 and x3.累计支付V值<=6000 then '11 (5000,6000]'
		when x3.累计支付V值>6000 and x3.累计支付V值<=7000 then '12 (6000,7000]'
		when x3.累计支付V值>7000 and x3.累计支付V值<=8000 then '13 (7000,8000]'
		when x3.累计支付V值>8000 and x3.累计支付V值<=9000 then '14 (8000,9000]'
		when x3.累计支付V值>9000 and x3.累计支付V值<=10000 then '15 (9000,10000]'
		when x3.累计支付V值>10000 and x3.累计支付V值<=12000 then '16 (10000,12000]'
		when x3.累计支付V值>12000 and x3.累计支付V值<=14000 then '17 (12000,14000]'
		when x3.累计支付V值>14000 and x3.累计支付V值<=16000 then '18 (14000,16000]'
		when x3.累计支付V值>16000 and x3.累计支付V值<=18000 then '19 (16000,18000]'
		when x3.累计支付V值>18000 and x3.累计支付V值<=20000 then '20 (18000,20000]'
		when x3.累计支付V值>20000 and x3.累计支付V值<=22000 then '21 (20000,22000]'
		when x3.累计支付V值>22000 and x3.累计支付V值<=24000 then '22 (22000,24000]'
		when x3.累计支付V值>24000 and x3.累计支付V值<=26000 then '23 (24000,26000]'
		when x3.累计支付V值>26000 and x3.累计支付V值<=28000 then '24 (26000,28000]'
		when x3.累计支付V值>28000 and x3.累计支付V值<=30000 then '25 (28000,30000]'
		when x3.累计支付V值>30000 and x3.累计支付V值<=32000 then '26 (30000,32000]'
		when x3.累计支付V值>32000 and x3.累计支付V值<=34000 then '27 (32000,34000]'
		when x3.累计支付V值>34000 and x3.累计支付V值<=36000 then '28 (34000,36000]'
		when x3.累计支付V值>36000 and x3.累计支付V值<=38000 then '29 (36000,38000]'
		when x3.累计支付V值>38000 and x3.累计支付V值<=40000 then '30 (38000,40000]'
		when x3.累计支付V值>40000 and x3.累计支付V值<=42000 then '31 (40000,42000]'
		when x3.累计支付V值>42000 and x3.累计支付V值<=44000 then '32 (42000,44000]'
		when x3.累计支付V值>44000 and x3.累计支付V值<=46000 then '33 (44000,46000]'
		when x3.累计支付V值>46000 and x3.累计支付V值<=48000 then '34 (46000,48000]'
		when x3.累计支付V值>48000 and x3.累计支付V值<=50000 then '35 (48000,50000]'
		when x3.累计支付V值>50000 then '36 (50000,‘+∞]'
	else null end 累计支付V值区间,
	x3.累计实付金额,
	case -- when x3.累计实付金额<0 then '-1'
		when x3.累计实付金额<=0 then 0 
		when x3.累计实付金额>0 and x3.累计实付金额<=3 then '01 (0,3]'
		when x3.累计实付金额>3 and x3.累计实付金额<=10 then '02 (3,10]'
		when x3.累计实付金额>10 and x3.累计实付金额<=100 then '03 (10,100]'
		when x3.累计实付金额>100 and x3.累计实付金额<=300 then '04 (100,300]'
		when x3.累计实付金额>300 and x3.累计实付金额<=600 then '05 (300,600]'
		when x3.累计实付金额>600 and x3.累计实付金额<=1000 then '06 (600,1000]'
		when x3.累计实付金额>1000 and x3.累计实付金额<=2000 then '07 (1000,2000]'
		when x3.累计实付金额>2000 and x3.累计实付金额<=3000 then '08 (2000,3000]'
		when x3.累计实付金额>3000 and x3.累计实付金额<=4000 then '09 (3000,4000]'
		when x3.累计实付金额>4000 and x3.累计实付金额<=5000 then '10 (4000,5000]'
		when x3.累计实付金额>5000 and x3.累计实付金额<=6000 then '11 (5000,6000]'
		when x3.累计实付金额>6000 and x3.累计实付金额<=7000 then '12 (6000,7000]'
		when x3.累计实付金额>7000 and x3.累计实付金额<=8000 then '13 (7000,8000]'
		when x3.累计实付金额>8000 and x3.累计实付金额<=9000 then '14 (8000,9000]'
		when x3.累计实付金额>9000 and x3.累计实付金额<=10000 then '15 (9000,10000]'
		when x3.累计实付金额>10000 and x3.累计实付金额<=12000 then '16 (10000,12000]'
		when x3.累计实付金额>12000 and x3.累计实付金额<=14000 then '17 (12000,14000]'
		when x3.累计实付金额>14000 and x3.累计实付金额<=16000 then '18 (14000,16000]'
		when x3.累计实付金额>16000 and x3.累计实付金额<=18000 then '19 (16000,18000]'
		when x3.累计实付金额>18000 and x3.累计实付金额<=20000 then '20 (18000,20000]'
		when x3.累计实付金额>20000 and x3.累计实付金额<=22000 then '21 (20000,22000]'
		when x3.累计实付金额>22000 and x3.累计实付金额<=24000 then '22 (22000,24000]'
		when x3.累计实付金额>24000 and x3.累计实付金额<=26000 then '23 (24000,26000]'
		when x3.累计实付金额>26000 and x3.累计实付金额<=28000 then '24 (26000,28000]'
		when x3.累计实付金额>28000 and x3.累计实付金额<=30000 then '25 (28000,30000]'
		when x3.累计实付金额>30000 and x3.累计实付金额<=32000 then '26 (30000,32000]'
		when x3.累计实付金额>32000 and x3.累计实付金额<=34000 then '27 (32000,34000]'
		when x3.累计实付金额>34000 and x3.累计实付金额<=36000 then '28 (34000,36000]'
		when x3.累计实付金额>36000 and x3.累计实付金额<=38000 then '29 (36000,38000]'
		when x3.累计实付金额>38000 and x3.累计实付金额<=40000 then '30 (38000,40000]'
		when x3.累计实付金额>40000 and x3.累计实付金额<=42000 then '31 (40000,42000]'
		when x3.累计实付金额>42000 and x3.累计实付金额<=44000 then '32 (42000,44000]'
		when x3.累计实付金额>44000 and x3.累计实付金额<=46000 then '33 (44000,46000]'
		when x3.累计实付金额>46000 and x3.累计实付金额<=48000 then '34 (46000,48000]'
		when x3.累计实付金额>48000 and x3.累计实付金额<=50000 then '35 (48000,50000]'
		when x3.累计实付金额>50000 then '36 (50000,‘+∞]'
	else null end 累计实付金额区间,
	left(ifnull(tr.省份,'未知'),2) 省份,
	row_number() over(PARTITION by a.user_id order by a.create_time desc) rk
	from order.tt_order a  -- 订单主表
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join member.tc_member_info m on a.user_id = m.id and m.is_deleted <> 1  -- 会员表(获取会员信息)
	left join
	(
		# V值退款成功记录
		select so.order_code,sp.product_id
		from `order`.tt_sales_return_order so
		left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
		where so.is_deleted = 0 
		and so.status = 51171004 -- 退款成功
		GROUP BY 1,2
	) e on a.order_code = e.order_code and b.product_id = e.product_id 
	left join
	(
		# 车系
		 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name) 车型
		 from
		 (
			 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin,
			 row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
			 from member.tc_member_vehicle v
			 left join basic_data.tm_model m on v.vehicle_code = m.MODEL_CODE
			 where v.IS_DELETED = 0 
		 ) v 
		 left join vehicle.tm_vehicle t on v.vin = t.VIN
		 left join basic_data.tm_model m on t.MODEL_ID = m.ID
		 where v.rk = 1
	) t on m.id = t.member_id
	left join
	(
		# 获取用户地址
		-- 会员对应城市，根据优先级排序：1、最后绑定经销商城市 2、会员表城市 3、默认收货地址城市
		select
		m.id,
		m.member_phone,
		ifnull(c1.region_name,IFNULL(c2.region_name,c3.region_name)) 省份 
		from member.tc_member_info m 
		left join
		(
		 #最后绑定经销商城市
		 select a.member_id,c.PROVINCE_NAME region_name-- ,a.model_name
		 from
		 (
			  select v.member_id,ifnull(d.dealer_code,vv.dealer_code) dealer_code,vv.model_name
			  from
			  (
			    select v.MEMBER_ID,v.VIN
			    ,row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
			    from member.tc_member_vehicle v 
			    where v.is_deleted=0 and v.MEMBER_ID is not null
			  ) v
			  left join vehicle.tm_vehicle vv on v.vin =vv.vin and vv.IS_DELETED=0
			  left join vehicle.tt_invoice_statistics_dms d on v.vin=d.vin and d.IS_DELETED=0
			  left join member.tc_member_info m  on v.member_id=m.id
			  where v.rk=1 -- 获取用户最后绑车记录
		 ) a left join organization.tm_company c on c.company_code=a.dealer_code and c.COMPANY_TYPE=15061003
		) c1 on c1.member_id = m.id
		left join (
		 #会员表城市
		 select m.id,c.REGION_NAME
		 from member.tc_member_info m  
		 left join dictionary.tc_region c on m.MEMBER_PROVINCE=c.REGION_ID
		 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
		) c2 on c2.id= m.id
		left join (
		 #收货地址城市
		 select m.id,cc.REGION_NAME
		 from member.tc_member_info m 
		 left join member.tc_member_address a on m.id=a.member_id and a.IS_DEFAULT=1 and a.status=0
		 left join dictionary.tc_region cc on a.address_province=cc.REGION_ID
		 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
		) c3 on c3.id= m.id
		where m.MEMBER_STATUS<>60341003 and m.IS_DELETED=0 and m.id<>3014773  -- 测试ID
	) tr on a.user_id = tr.id
	left join 
		(
			# 手机型号
			select t.usertag,max(t.date),
			case when json_extract(t.`data`,'$.ua') like '%iPhone%' then 'IOS'
				when json_extract(t.`data`,'$.ua') like '%Android%' then 'Android'
				else '其他' end 手机型号
			from track.track t 
			group by 1
		) t2 on cast(m.USER_ID as varchar) = t2.usertag
	left join 
		(
		#会员等级
			select distinct tl.LEVEL_CODE,tl.LEVEL_NAME
			from `member`.tc_level tl
			where tl.LEVEL_CODE is not null
			and tl.IS_DELETED = 0
		) tl on m.LEVEL_ID = tl.LEVEL_CODE
	left join 
		(
	# 签到天数
		select a.MEMBER_ID,a.IS_VEHICLE,count(1) tt from
		(
			select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
			from mine.sign_info i 
			join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
			where i.is_delete = 0
			and i.create_time <= '2023-02-28 23:59:59'
		) a
		GROUP BY 1,2 
		order by 2 desc
	) x on x.MEMBER_ID = m.ID
	left join 
		(
		#会员日参与次数
		select x.ID,
		count(1) tt
		from 
			(
			select 
			DISTINCT tmi.ID,
			json_extract(t.`data`,'$.embeddedpoint')
			from track.track t 
			join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
			where t.`date` >= '2022-01-25'
			and t.`date` <= '2023-02-28 23:59:59'
			and json_extract(t.`data`,'$.embeddedpoint') like ('%home_onload%')
			or json_extract(t.`data`,'$.embeddedpoint') like ('%home_miniProgram_onload%')
			)x
		group by 1
		order by 2 desc 
		)x2 on x2.ID = m.ID
	left join 
		(-- 商城简洁版
		select 	a.user_id 会员id
		,count(a.order_code) 下单次数
-- 		,b.coupon_fee/100 优惠券抵扣金额
		,sum(b.point_amount) 累计支付V值
		,sum(round(b.point_amount/3+b.pay_fee/100,2)) 累计实付金额
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
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
		where a.create_time < '2023-03-01'   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		group by 1
		order by a.create_time)x3 on x3.会员id=m.ID
	left join 
		(-- 最近一次消费间隔
		select 
		x.会员id,
		x.tt,
		x2.tt,
		ifnull(DATEDIFF(x.tt,x2.tt),'仅下1次单') 最近一次消费间隔
		from 
			(
				(select x.*
				from (
						select a.user_id 会员id
						,a.create_time tt
						,row_number() over(PARTITION by a.user_id order by a.create_time desc) rk
						from order.tt_order a  -- 订单主表
-- 						left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
						left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
						where a.create_time < '2023-03-01'   -- 订单时间
						and a.is_deleted <> 1  -- 剔除逻辑删除订单
						and a.type = 31011003  -- 筛选沃世界商城订单
						and a.separate_status = '10041002' -- 选择拆单状态否
						and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
						AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
-- 						and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			)x where x.rk=1 )x 
		left join 
			(select x.*
			from (
					select a.user_id 会员id
					,a.create_time tt
					,row_number() over(PARTITION by a.user_id order by a.create_time desc) rk
					from order.tt_order a  -- 订单主表
-- 					left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
					left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
					where a.create_time < '2023-03-01'   -- 订单时间
					and a.is_deleted <> 1  -- 剔除逻辑删除订单
					and a.type = 31011003  -- 筛选沃世界商城订单
					and a.separate_status = '10041002' -- 选择拆单状态否
					and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
					AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
-- 					and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
						)x 
						where x.rk=2 )x2 on x.会员id=x2.会员id
				)) x4 on x4.会员id=m.ID 
		left join 
			( #当前V值减去下单时间至现在获取的V值，就是下单前的V值
			select 
			a.order_id 订单ID,
			a.order_code 订单编号,
			ts.MEMBER_ID,
			tmi.ID,
			a.下单时间,
			tmi.MEMBER_V_NUM 当前V值余额,
			tmi.MEMBER_V_NUM-sum(case when TIMESTAMPDIFF(SECOND, ts.create_time,a.下单时间)<3 then 
		   	 	case when ts.RECORD_TYPE=1 then -ts.INTEGRAL when ts.RECORD_TYPE=0 then ts.INTEGRAL else 0 end 
		   	 	else 0 end) 截止下单前前V值余额
			from `member`.tt_member_flow_record ts
			join 
				(
				#每个用户这段时间第一次下单时间
					select a.user_id,a.create_time 下单时间,a.order_id,a.order_code
					from (
						select a.order_id,a.user_id,a.create_time,a.order_code
						,row_number() over(partition by a.user_id order by a.create_time) rk 
						from `order`.tt_order a 
						where 1=1
		-- 				a.create_time >= '2022-05-31' 
						and a.create_time <'2023-03-01'   -- 订单时间
						and a.is_deleted <> 1  -- 剔除逻辑删除订单
						and a.type = 31011003  -- 筛选沃世界商城订单
						and a.separate_status = '10041002' -- 选择拆单状态否
						and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
						AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
						order by a.create_time desc 
						) a 
					where a.rk=1
				)a on a.user_id=ts.MEMBER_ID
			join `member`.tc_member_info tmi on tmi.id=ts.MEMBER_ID and tmi.STATUS <>60341003 and tmi.IS_DELETED =0
			where ts.IS_DELETED =0 -- 未删除 
			group by 3
			order by 5 desc )x5 on x5.id=m.ID 
		where 1 = 1
		-- and a.create_time >= '2022-02-12 12:00:00' 
		and a.create_time <= '2023-02-28 23:59:59'        -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		order by a.create_time
)x where x.rk = 1
