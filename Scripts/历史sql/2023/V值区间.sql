-- V值区间 -- 曾经绑过车的粉丝为车主 3
SELECT 
case -- when tmi.MEMBER_V_NUM<0 then '-1'
	when tmi.MEMBER_V_NUM<=0 then 0 
	when tmi.MEMBER_V_NUM>0 and tmi.MEMBER_V_NUM<=3 then '01 (0,3]'
	when tmi.MEMBER_V_NUM>3 and tmi.MEMBER_V_NUM<=10 then '02 (3,10]'
	when tmi.MEMBER_V_NUM>10 and tmi.MEMBER_V_NUM<=100 then '03 (10,100]'
	when tmi.MEMBER_V_NUM>100 and tmi.MEMBER_V_NUM<=300 then '04 (100,300]'
	when tmi.MEMBER_V_NUM>300 and tmi.MEMBER_V_NUM<=600 then '05 (300,600]'
	when tmi.MEMBER_V_NUM>600 and tmi.MEMBER_V_NUM<=1000 then '06 (600,1000]'
	when tmi.MEMBER_V_NUM>1000 and tmi.MEMBER_V_NUM<=2000 then '07 (1000,2000]'
	when tmi.MEMBER_V_NUM>2000 and tmi.MEMBER_V_NUM<=3000 then '08 (2000,3000]'
	when tmi.MEMBER_V_NUM>3000 and tmi.MEMBER_V_NUM<=4000 then '09 (3000,4000]'
	when tmi.MEMBER_V_NUM>4000 and tmi.MEMBER_V_NUM<=5000 then '10 (4000,5000]'
	when tmi.MEMBER_V_NUM>5000 and tmi.MEMBER_V_NUM<=6000 then '11 (5000,6000]'
	when tmi.MEMBER_V_NUM>6000 and tmi.MEMBER_V_NUM<=7000 then '12 (6000,7000]'
	when tmi.MEMBER_V_NUM>7000 and tmi.MEMBER_V_NUM<=8000 then '13 (7000,8000]'
	when tmi.MEMBER_V_NUM>8000 and tmi.MEMBER_V_NUM<=9000 then '14 (8000,9000]'
	when tmi.MEMBER_V_NUM>9000 and tmi.MEMBER_V_NUM<=10000 then '15 (9000,10000]'
	when tmi.MEMBER_V_NUM>10000 and tmi.MEMBER_V_NUM<=12000 then '16 (10000,12000]'
	when tmi.MEMBER_V_NUM>12000 and tmi.MEMBER_V_NUM<=14000 then '17 (12000,14000]'
	when tmi.MEMBER_V_NUM>14000 and tmi.MEMBER_V_NUM<=16000 then '18 (14000,16000]'
	when tmi.MEMBER_V_NUM>16000 and tmi.MEMBER_V_NUM<=18000 then '19 (16000,18000]'
	when tmi.MEMBER_V_NUM>18000 and tmi.MEMBER_V_NUM<=20000 then '20 (18000,20000]'
	when tmi.MEMBER_V_NUM>20000 and tmi.MEMBER_V_NUM<=22000 then '21 (20000,22000]'
	when tmi.MEMBER_V_NUM>22000 and tmi.MEMBER_V_NUM<=24000 then '22 (22000,24000]'
	when tmi.MEMBER_V_NUM>24000 and tmi.MEMBER_V_NUM<=26000 then '23 (24000,26000]'
	when tmi.MEMBER_V_NUM>26000 and tmi.MEMBER_V_NUM<=28000 then '24 (26000,28000]'
	when tmi.MEMBER_V_NUM>28000 and tmi.MEMBER_V_NUM<=30000 then '25 (28000,30000]'
	when tmi.MEMBER_V_NUM>30000 and tmi.MEMBER_V_NUM<=32000 then '26 (30000,32000]'
	when tmi.MEMBER_V_NUM>32000 and tmi.MEMBER_V_NUM<=34000 then '27 (32000,34000]'
	when tmi.MEMBER_V_NUM>34000 and tmi.MEMBER_V_NUM<=36000 then '28 (34000,36000]'
	when tmi.MEMBER_V_NUM>36000 and tmi.MEMBER_V_NUM<=38000 then '29 (36000,38000]'
	when tmi.MEMBER_V_NUM>38000 and tmi.MEMBER_V_NUM<=40000 then '30 (38000,40000]'
	when tmi.MEMBER_V_NUM>40000 and tmi.MEMBER_V_NUM<=42000 then '31 (40000,42000]'
	when tmi.MEMBER_V_NUM>42000 and tmi.MEMBER_V_NUM<=44000 then '32 (42000,44000]'
	when tmi.MEMBER_V_NUM>44000 and tmi.MEMBER_V_NUM<=46000 then '33 (44000,46000]'
	when tmi.MEMBER_V_NUM>46000 and tmi.MEMBER_V_NUM<=48000 then '34 (46000,48000]'
	when tmi.MEMBER_V_NUM>48000 and tmi.MEMBER_V_NUM<=50000 then '35 (48000,50000]'
	when tmi.MEMBER_V_NUM>50000 then '36 (50000,‘+∞]'
else null end V值余额区间,
count(DISTINCT case when tmi.IS_VEHICLE=1 or (tmi.IS_VEHICLE=0 and tmv.VIN is not null)then tmi.id else null end) 车主数,
count(DISTINCT case when tmi.IS_VEHICLE=0 and tmv.vin is null then tmi.id else null end) 粉丝数,
count(DISTINCT case when tmi.IS_VEHICLE=1 or (tmi.IS_VEHICLE=0 and tmv.VIN is not null) then a.usertag else null end) 车主活跃数,
count(DISTINCT case when tmi.IS_VEHICLE=0 and tmv.vin is null then a.usertag else null end) 粉丝活跃数,
round((COUNT(DISTINCT case when aa.record_type=0 and tmi.IS_VEHICLE=1 or (tmi.IS_VEHICLE=0 and tmv.VIN is not null) then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 or (tmi.IS_VEHICLE=0 and tmv.VIN is not null) then a.usertag else null end)),2) 近6个月活跃车主人均V值流入笔数,
round((COUNT(DISTINCT case when aa.record_type=0 and tmi.IS_VEHICLE=0 and tmv.vin is null then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 and tmv.vin is null then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流入笔数,
round((COUNT(DISTINCT case when aa.record_type=1 and tmi.IS_VEHICLE=1 or (tmi.IS_VEHICLE=0 and tmv.VIN is not null) then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 or (tmi.IS_VEHICLE=0 and tmv.VIN is not null) then a.usertag else null end)),2) 近6个月活跃车主人均V值流出笔数,
round((COUNT(DISTINCT case when aa.record_type=1 and tmi.IS_VEHICLE=0 and tmv.vin is null then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 and tmv.vin is null then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流出笔数,
round((sum(case when aa.record_type=0 and tmi.IS_VEHICLE=1 or (tmi.IS_VEHICLE=0 and tmv.VIN is not null) then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 or (tmi.IS_VEHICLE=0 and tmv.VIN is not null) then a.usertag else null end)),2) 近6个月活跃车主人均V值流入数量,
round((sum(case when aa.record_type=0 and tmi.IS_VEHICLE=0 and tmv.vin is null then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 and tmv.vin is null then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流入数量,
round((sum(case when aa.record_type=1 and tmi.IS_VEHICLE=1 or (tmi.IS_VEHICLE=0 and tmv.VIN is not null) then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 or (tmi.IS_VEHICLE=0 and tmv.VIN is not null) then a.usertag else null end)),2) 近6个月活跃车主人均V值流出数量,
round((sum(case when aa.record_type=1 and tmi.IS_VEHICLE=0 and tmv.vin is null then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 and tmv.vin is null then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流出数量
from `member`.tc_member_info tmi 
left join 
	(
	#近6月活跃两次以上的用户
	select t.usertag,
	count(t.date) 活跃次数
	from track.track t
	where t.date>DATE_SUB('2022-07-27 10:00:00',interval 6 month) 
	group by 1
	having count(t.date)>=2
	) a on a.usertag = cast(tmi.USER_ID as varchar)
left join `member`.tt_member_flow_record aa on aa.MEMBER_ID =tmi.ID and aa.is_deleted=0
left join `member`.tc_member_vehicle tmv on tmi.id=tmv.MEMBER_ID 
where tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
group by 1
order by 1 



-- V值区间  2
SELECT 
case -- when tmi.MEMBER_V_NUM<0 then '-1'
	when tmi.MEMBER_V_NUM=0 then 0 
	when tmi.MEMBER_V_NUM>0 and tmi.MEMBER_V_NUM<=3 then '01 (0,3]'
	when tmi.MEMBER_V_NUM>3 and tmi.MEMBER_V_NUM<=10 then '02 (3,10]'
	when tmi.MEMBER_V_NUM>10 and tmi.MEMBER_V_NUM<=100 then '03 (10,100]'
	when tmi.MEMBER_V_NUM>100 and tmi.MEMBER_V_NUM<=300 then '04 (100,300]'
	when tmi.MEMBER_V_NUM>300 and tmi.MEMBER_V_NUM<=600 then '05 (300,600]'
	when tmi.MEMBER_V_NUM>600 and tmi.MEMBER_V_NUM<=1000 then '06 (600,1000]'
	when tmi.MEMBER_V_NUM>1000 and tmi.MEMBER_V_NUM<=2000 then '07 (1000,2000]'
	when tmi.MEMBER_V_NUM>2000 and tmi.MEMBER_V_NUM<=3000 then '08 (2000,3000]'
	when tmi.MEMBER_V_NUM>3000 and tmi.MEMBER_V_NUM<=4000 then '09 (3000,4000]'
	when tmi.MEMBER_V_NUM>4000 and tmi.MEMBER_V_NUM<=5000 then '10 (4000,5000]'
	when tmi.MEMBER_V_NUM>5000 and tmi.MEMBER_V_NUM<=6000 then '11 (5000,6000]'
	when tmi.MEMBER_V_NUM>6000 and tmi.MEMBER_V_NUM<=7000 then '12 (6000,7000]'
	when tmi.MEMBER_V_NUM>7000 and tmi.MEMBER_V_NUM<=8000 then '13 (7000,8000]'
	when tmi.MEMBER_V_NUM>8000 and tmi.MEMBER_V_NUM<=9000 then '14 (8000,9000]'
	when tmi.MEMBER_V_NUM>9000 and tmi.MEMBER_V_NUM<=10000 then '15 (9000,10000]'
	when tmi.MEMBER_V_NUM>10000 and tmi.MEMBER_V_NUM<=12000 then '16 (10000,12000]'
	when tmi.MEMBER_V_NUM>12000 and tmi.MEMBER_V_NUM<=14000 then '17 (12000,14000]'
	when tmi.MEMBER_V_NUM>14000 and tmi.MEMBER_V_NUM<=16000 then '18 (14000,16000]'
	when tmi.MEMBER_V_NUM>16000 and tmi.MEMBER_V_NUM<=18000 then '19 (16000,18000]'
	when tmi.MEMBER_V_NUM>18000 and tmi.MEMBER_V_NUM<=20000 then '20 (18000,20000]'
	when tmi.MEMBER_V_NUM>20000 and tmi.MEMBER_V_NUM<=22000 then '21 (20000,22000]'
	when tmi.MEMBER_V_NUM>22000 and tmi.MEMBER_V_NUM<=24000 then '22 (22000,24000]'
	when tmi.MEMBER_V_NUM>24000 and tmi.MEMBER_V_NUM<=26000 then '23 (24000,26000]'
	when tmi.MEMBER_V_NUM>26000 and tmi.MEMBER_V_NUM<=28000 then '24 (26000,28000]'
	when tmi.MEMBER_V_NUM>28000 and tmi.MEMBER_V_NUM<=30000 then '25 (28000,30000]'
	when tmi.MEMBER_V_NUM>30000 and tmi.MEMBER_V_NUM<=32000 then '26 (30000,32000]'
	when tmi.MEMBER_V_NUM>32000 and tmi.MEMBER_V_NUM<=34000 then '27 (32000,34000]'
	when tmi.MEMBER_V_NUM>34000 and tmi.MEMBER_V_NUM<=36000 then '28 (34000,36000]'
	when tmi.MEMBER_V_NUM>36000 and tmi.MEMBER_V_NUM<=38000 then '29 (36000,38000]'
	when tmi.MEMBER_V_NUM>38000 and tmi.MEMBER_V_NUM<=40000 then '30 (38000,40000]'
	when tmi.MEMBER_V_NUM>40000 and tmi.MEMBER_V_NUM<=42000 then '31 (40000,42000]'
	when tmi.MEMBER_V_NUM>42000 and tmi.MEMBER_V_NUM<=44000 then '32 (42000,44000]'
	when tmi.MEMBER_V_NUM>44000 and tmi.MEMBER_V_NUM<=46000 then '33 (44000,46000]'
	when tmi.MEMBER_V_NUM>46000 and tmi.MEMBER_V_NUM<=48000 then '34 (46000,48000]'
	when tmi.MEMBER_V_NUM>48000 and tmi.MEMBER_V_NUM<=50000 then '35 (48000,50000]'
	when tmi.MEMBER_V_NUM>50000 then '36 (50000,‘+∞]'
else null end V值余额区间,
count(DISTINCT case when tmi.IS_VEHICLE=1 or (aa.EVENT_TYPE =60731003 and tmi.IS_VEHICLE =0) then tmi.id else null end) 车主数,
count(DISTINCT case when tmi.IS_VEHICLE=0 and aa.EVENT_TYPE <>60731003 then tmi.id else null end) 粉丝数,
count(DISTINCT case when tmi.IS_VEHICLE=1 or (aa.EVENT_TYPE =60731003 and tmi.IS_VEHICLE =0) then a.usertag else null end) 车主活跃数,
count(DISTINCT case when tmi.IS_VEHICLE=0 and aa.EVENT_TYPE <>60731003 then a.usertag else null end) 粉丝活跃数,
round((COUNT(DISTINCT case when aa.record_type=0 and tmi.IS_VEHICLE=1 or (aa.EVENT_TYPE =60731003 and tmi.IS_VEHICLE =0) then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 or (aa.EVENT_TYPE =60731003 and tmi.IS_VEHICLE =0) then a.usertag else null end)),2) 近6个月活跃车主人均V值流入笔数,
round((COUNT(DISTINCT case when aa.record_type=0 and tmi.IS_VEHICLE=0 and aa.EVENT_TYPE <>60731003 then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 and aa.EVENT_TYPE <>60731003 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流入笔数,
round((COUNT(DISTINCT case when aa.record_type=1 and tmi.IS_VEHICLE=1 or (aa.EVENT_TYPE =60731003 and tmi.IS_VEHICLE =0) then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 or (aa.EVENT_TYPE =60731003 and tmi.IS_VEHICLE =0) then a.usertag else null end)),2) 近6个月活跃车主人均V值流出笔数,
round((COUNT(DISTINCT case when aa.record_type=1 and tmi.IS_VEHICLE=0 and aa.EVENT_TYPE <>60731003 then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 and aa.EVENT_TYPE <>60731003 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流出笔数,
round((sum(case when aa.record_type=0 and tmi.IS_VEHICLE=1 or (aa.EVENT_TYPE =60731003 and tmi.IS_VEHICLE =0) then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 or (aa.EVENT_TYPE =60731003 and tmi.IS_VEHICLE =0) then a.usertag else null end)),2) 近6个月活跃车主人均V值流入数量,
round((sum(case when aa.record_type=0 and tmi.IS_VEHICLE=0 and aa.EVENT_TYPE <>60731003 then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 and aa.EVENT_TYPE <>60731003 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流入数量,
round((sum(case when aa.record_type=1 and tmi.IS_VEHICLE=1 or (aa.EVENT_TYPE =60731003 and tmi.IS_VEHICLE =0) then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 or (aa.EVENT_TYPE =60731003 and tmi.IS_VEHICLE =0) then a.usertag else null end)),2) 近6个月活跃车主人均V值流出数量,
round((sum(case when aa.record_type=1 and tmi.IS_VEHICLE=0 and aa.EVENT_TYPE <>60731003 then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 and aa.EVENT_TYPE <>60731003 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流出数量
from `member`.tc_member_info tmi 
left join 
	(
	#近6月活跃两次以上的用户
	select t.usertag,
	count(t.date) 活跃次数
	from track.track t
	where t.date>DATE_SUB('2022-07-27 10:00:00',interval 6 month) 
	group by 1
	having count(t.date)>=2
	) a on a.usertag = cast(tmi.USER_ID as varchar)
left join `member`.tt_member_flow_record aa on aa.MEMBER_ID =tmi.ID and aa.is_deleted=0
where tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
group by 1
order by 1

-- V值区间 绑过车的粉丝归为车主  1
SELECT 
case -- when tmi.MEMBER_V_NUM<0 then '-1'
	when tmi.MEMBER_V_NUM=0 then 0 
	when tmi.MEMBER_V_NUM>0 and tmi.MEMBER_V_NUM<=3 then '01 (0,3]'
	when tmi.MEMBER_V_NUM>3 and tmi.MEMBER_V_NUM<=10 then '02 (3,10]'
	when tmi.MEMBER_V_NUM>10 and tmi.MEMBER_V_NUM<=100 then '03 (10,100]'
	when tmi.MEMBER_V_NUM>100 and tmi.MEMBER_V_NUM<=300 then '04 (100,300]'
	when tmi.MEMBER_V_NUM>300 and tmi.MEMBER_V_NUM<=600 then '05 (300,600]'
	when tmi.MEMBER_V_NUM>600 and tmi.MEMBER_V_NUM<=1000 then '06 (600,1000]'
	when tmi.MEMBER_V_NUM>1000 and tmi.MEMBER_V_NUM<=2000 then '07 (1000,2000]'
	when tmi.MEMBER_V_NUM>2000 and tmi.MEMBER_V_NUM<=3000 then '08 (2000,3000]'
	when tmi.MEMBER_V_NUM>3000 and tmi.MEMBER_V_NUM<=4000 then '09 (3000,4000]'
	when tmi.MEMBER_V_NUM>4000 and tmi.MEMBER_V_NUM<=5000 then '10 (4000,5000]'
	when tmi.MEMBER_V_NUM>5000 and tmi.MEMBER_V_NUM<=6000 then '11 (5000,6000]'
	when tmi.MEMBER_V_NUM>6000 and tmi.MEMBER_V_NUM<=7000 then '12 (6000,7000]'
	when tmi.MEMBER_V_NUM>7000 and tmi.MEMBER_V_NUM<=8000 then '13 (7000,8000]'
	when tmi.MEMBER_V_NUM>8000 and tmi.MEMBER_V_NUM<=9000 then '14 (8000,9000]'
	when tmi.MEMBER_V_NUM>9000 and tmi.MEMBER_V_NUM<=10000 then '15 (9000,10000]'
	when tmi.MEMBER_V_NUM>10000 and tmi.MEMBER_V_NUM<=12000 then '16 (10000,12000]'
	when tmi.MEMBER_V_NUM>12000 and tmi.MEMBER_V_NUM<=14000 then '17 (12000,14000]'
	when tmi.MEMBER_V_NUM>14000 and tmi.MEMBER_V_NUM<=16000 then '18 (14000,16000]'
	when tmi.MEMBER_V_NUM>16000 and tmi.MEMBER_V_NUM<=18000 then '19 (16000,18000]'
	when tmi.MEMBER_V_NUM>18000 and tmi.MEMBER_V_NUM<=20000 then '20 (18000,20000]'
	when tmi.MEMBER_V_NUM>20000 and tmi.MEMBER_V_NUM<=22000 then '21 (20000,22000]'
	when tmi.MEMBER_V_NUM>22000 and tmi.MEMBER_V_NUM<=24000 then '22 (22000,24000]'
	when tmi.MEMBER_V_NUM>24000 and tmi.MEMBER_V_NUM<=26000 then '23 (24000,26000]'
	when tmi.MEMBER_V_NUM>26000 and tmi.MEMBER_V_NUM<=28000 then '24 (26000,28000]'
	when tmi.MEMBER_V_NUM>28000 and tmi.MEMBER_V_NUM<=30000 then '25 (28000,30000]'
	when tmi.MEMBER_V_NUM>30000 and tmi.MEMBER_V_NUM<=32000 then '26 (30000,32000]'
	when tmi.MEMBER_V_NUM>32000 and tmi.MEMBER_V_NUM<=34000 then '27 (32000,34000]'
	when tmi.MEMBER_V_NUM>34000 and tmi.MEMBER_V_NUM<=36000 then '28 (34000,36000]'
	when tmi.MEMBER_V_NUM>36000 and tmi.MEMBER_V_NUM<=38000 then '29 (36000,38000]'
	when tmi.MEMBER_V_NUM>38000 and tmi.MEMBER_V_NUM<=40000 then '30 (38000,40000]'
	when tmi.MEMBER_V_NUM>40000 and tmi.MEMBER_V_NUM<=42000 then '31 (40000,42000]'
	when tmi.MEMBER_V_NUM>42000 and tmi.MEMBER_V_NUM<=44000 then '32 (42000,44000]'
	when tmi.MEMBER_V_NUM>44000 and tmi.MEMBER_V_NUM<=46000 then '33 (44000,46000]'
	when tmi.MEMBER_V_NUM>46000 and tmi.MEMBER_V_NUM<=48000 then '34 (46000,48000]'
	when tmi.MEMBER_V_NUM>48000 and tmi.MEMBER_V_NUM<=50000 then '35 (48000,50000]'
	when tmi.MEMBER_V_NUM>50000 then '36 (50000,‘+∞]'
else null end V值余额区间,
count(DISTINCT case when (x.绑定次数>=2 and tmi.IS_VEHICLE =0) or (tmi.IS_VEHICLE=1) then tmi.id else null end) 车主数,
count(DISTINCT case when x.绑定次数 is null and tmi.IS_VEHICLE =0 then tmi.id else null end) 粉丝数,
count(DISTINCT case when (x.绑定次数>=2 and tmi.IS_VEHICLE =0) or (tmi.IS_VEHICLE=1) then a.usertag else null end) 车主活跃数,
count(DISTINCT case when x.绑定次数 is null and tmi.IS_VEHICLE =0 then a.usertag else null end) 粉丝活跃数,
round((COUNT(DISTINCT case when aa.record_type=0 and (x.绑定次数>=2 and tmi.IS_VEHICLE =0) or (tmi.IS_VEHICLE=1) then aa.id else null end))/(count(DISTINCT case when (x.绑定次数>=2 and tmi.IS_VEHICLE =0) or (tmi.IS_VEHICLE=1) then a.usertag else null end)),2) 近6个月活跃车主人均V值流入笔数,
round((COUNT(DISTINCT case when aa.record_type=0 and x.绑定次数 is null and tmi.IS_VEHICLE =0 then aa.id else null end))/(count(DISTINCT case when x.绑定次数 is null and tmi.IS_VEHICLE =0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流入笔数,
round((COUNT(DISTINCT case when aa.record_type=1 and (x.绑定次数>=2 and tmi.IS_VEHICLE =0) or (tmi.IS_VEHICLE=1) then aa.id else null end))/(count(DISTINCT case when (x.绑定次数>=2 and tmi.IS_VEHICLE =0) or (tmi.IS_VEHICLE=1) then a.usertag else null end)),2) 近6个月活跃车主人均V值流出笔数,
round((COUNT(DISTINCT case when aa.record_type=1 and x.绑定次数 is null and tmi.IS_VEHICLE =0 then aa.id else null end))/(count(DISTINCT case when x.绑定次数 is null and tmi.IS_VEHICLE =0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流出笔数,
round((sum(case when aa.record_type=0 and (x.绑定次数>=2 and tmi.IS_VEHICLE =0) or (tmi.IS_VEHICLE=1) then aa.INTEGRAL else null end))/(count(DISTINCT case when (x.绑定次数>=2 and tmi.IS_VEHICLE =0) or (tmi.IS_VEHICLE=1) then a.usertag else null end)),2) 近6个月活跃车主人均V值流入数量,
round((sum(case when aa.record_type=0 and x.绑定次数 is null and tmi.IS_VEHICLE =0 then aa.INTEGRAL else null end))/(count(DISTINCT case when x.绑定次数 is null and tmi.IS_VEHICLE =0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流入数量,
round((sum(case when aa.record_type=1 and (x.绑定次数>=2 and tmi.IS_VEHICLE =0) or (tmi.IS_VEHICLE=1) then aa.INTEGRAL else null end))/(count(DISTINCT case when (x.绑定次数>=2 and tmi.IS_VEHICLE =0) or (tmi.IS_VEHICLE=1) then a.usertag else null end)),2) 近6个月活跃车主人均V值流出数量,
round((sum(case when aa.record_type=1 and x.绑定次数 is null and tmi.IS_VEHICLE =0 then aa.INTEGRAL else null end))/(count(DISTINCT case when x.绑定次数 is null and tmi.IS_VEHICLE =0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流出数量
from `member`.tc_member_info tmi 
left join 
	(
	#近6月活跃两次以上的用户
	select t.usertag,
	count(t.date) 活跃次数
	from track.track t
	where t.date>DATE_SUB('2022-07-27 10:00:00',interval 6 month) 
	group by 1
	having count(t.date)>=2
	) a on a.usertag = cast(tmi.USER_ID as varchar)
left join `member`.tt_member_flow_record aa on aa.MEMBER_ID =tmi.ID and aa.is_deleted=0
left join 
	(
	-- 绑定次数大于2
	select tmv.member_id,
	count(tmv.id) 绑定次数
	from `member`.tc_member_vehicle tmv 
	group by 1
	having count(tmv.id)>=2
	)x on tmi.id=x.MEMBER_ID 
where tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
group by 1
order by 1



-- V值区间 -- 曾经绑过车的粉丝为车主
SELECT 
case -- when tmi.MEMBER_V_NUM<0 then '-1'
	when tmi.MEMBER_V_NUM=0 then 0 
	when tmi.MEMBER_V_NUM>0 and tmi.MEMBER_V_NUM<=3 then '01 (0,3]'
	when tmi.MEMBER_V_NUM>3 and tmi.MEMBER_V_NUM<=10 then '02 (3,10]'
	when tmi.MEMBER_V_NUM>10 and tmi.MEMBER_V_NUM<=100 then '03 (10,100]'
	when tmi.MEMBER_V_NUM>100 and tmi.MEMBER_V_NUM<=300 then '04 (100,300]'
	when tmi.MEMBER_V_NUM>300 and tmi.MEMBER_V_NUM<=600 then '05 (300,600]'
	when tmi.MEMBER_V_NUM>600 and tmi.MEMBER_V_NUM<=1000 then '06 (600,1000]'
	when tmi.MEMBER_V_NUM>1000 and tmi.MEMBER_V_NUM<=2000 then '07 (1000,2000]'
	when tmi.MEMBER_V_NUM>2000 and tmi.MEMBER_V_NUM<=3000 then '08 (2000,3000]'
	when tmi.MEMBER_V_NUM>3000 and tmi.MEMBER_V_NUM<=4000 then '09 (3000,4000]'
	when tmi.MEMBER_V_NUM>4000 and tmi.MEMBER_V_NUM<=5000 then '10 (4000,5000]'
	when tmi.MEMBER_V_NUM>5000 and tmi.MEMBER_V_NUM<=6000 then '11 (5000,6000]'
	when tmi.MEMBER_V_NUM>6000 and tmi.MEMBER_V_NUM<=7000 then '12 (6000,7000]'
	when tmi.MEMBER_V_NUM>7000 and tmi.MEMBER_V_NUM<=8000 then '13 (7000,8000]'
	when tmi.MEMBER_V_NUM>8000 and tmi.MEMBER_V_NUM<=9000 then '14 (8000,9000]'
	when tmi.MEMBER_V_NUM>9000 and tmi.MEMBER_V_NUM<=10000 then '15 (9000,10000]'
	when tmi.MEMBER_V_NUM>10000 and tmi.MEMBER_V_NUM<=12000 then '16 (10000,12000]'
	when tmi.MEMBER_V_NUM>12000 and tmi.MEMBER_V_NUM<=14000 then '17 (12000,14000]'
	when tmi.MEMBER_V_NUM>14000 and tmi.MEMBER_V_NUM<=16000 then '18 (14000,16000]'
	when tmi.MEMBER_V_NUM>16000 and tmi.MEMBER_V_NUM<=18000 then '19 (16000,18000]'
	when tmi.MEMBER_V_NUM>18000 and tmi.MEMBER_V_NUM<=20000 then '20 (18000,20000]'
	when tmi.MEMBER_V_NUM>20000 and tmi.MEMBER_V_NUM<=22000 then '21 (20000,22000]'
	when tmi.MEMBER_V_NUM>22000 and tmi.MEMBER_V_NUM<=24000 then '22 (22000,24000]'
	when tmi.MEMBER_V_NUM>24000 and tmi.MEMBER_V_NUM<=26000 then '23 (24000,26000]'
	when tmi.MEMBER_V_NUM>26000 and tmi.MEMBER_V_NUM<=28000 then '24 (26000,28000]'
	when tmi.MEMBER_V_NUM>28000 and tmi.MEMBER_V_NUM<=30000 then '25 (28000,30000]'
	when tmi.MEMBER_V_NUM>30000 and tmi.MEMBER_V_NUM<=32000 then '26 (30000,32000]'
	when tmi.MEMBER_V_NUM>32000 and tmi.MEMBER_V_NUM<=34000 then '27 (32000,34000]'
	when tmi.MEMBER_V_NUM>34000 and tmi.MEMBER_V_NUM<=36000 then '28 (34000,36000]'
	when tmi.MEMBER_V_NUM>36000 and tmi.MEMBER_V_NUM<=38000 then '29 (36000,38000]'
	when tmi.MEMBER_V_NUM>38000 and tmi.MEMBER_V_NUM<=40000 then '30 (38000,40000]'
	when tmi.MEMBER_V_NUM>40000 and tmi.MEMBER_V_NUM<=42000 then '31 (40000,42000]'
	when tmi.MEMBER_V_NUM>42000 and tmi.MEMBER_V_NUM<=44000 then '32 (42000,44000]'
	when tmi.MEMBER_V_NUM>44000 and tmi.MEMBER_V_NUM<=46000 then '33 (44000,46000]'
	when tmi.MEMBER_V_NUM>46000 and tmi.MEMBER_V_NUM<=48000 then '34 (46000,48000]'
	when tmi.MEMBER_V_NUM>48000 and tmi.MEMBER_V_NUM<=50000 then '35 (48000,50000]'
	when tmi.MEMBER_V_NUM>50000 then '36 (50000,‘+∞]'
else null end V值余额区间,
count(DISTINCT case when tmi.IS_VEHICLE=1 then tmi.id else null end) 车主数,
count(DISTINCT case when tmi.IS_VEHICLE=0 then tmi.id else null end) 粉丝数,
count(DISTINCT case when tmi.IS_VEHICLE=1 then a.usertag else null end) 车主活跃数,
count(DISTINCT case when tmi.IS_VEHICLE=0 then a.usertag else null end) 粉丝活跃数,
round((COUNT(DISTINCT case when aa.record_type=0 and tmi.is_vehicle=1 then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 then a.usertag else null end)),2) 近6个月活跃车主人均V值流入笔数,
round((COUNT(DISTINCT case when aa.record_type=0 and tmi.is_vehicle=0 then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流入笔数,
round((COUNT(DISTINCT case when aa.record_type=1 and tmi.is_vehicle=1 then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 then a.usertag else null end)),2) 近6个月活跃车主人均V值流出笔数,
round((COUNT(DISTINCT case when aa.record_type=1 and tmi.is_vehicle=0 then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流出笔数,
round((sum(case when aa.record_type=0 and tmi.is_vehicle=1 then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 then a.usertag else null end)),2) 近6个月活跃车主人均V值流入数量,
round((sum(case when aa.record_type=0 and tmi.is_vehicle=0 then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流入数量,
round((sum(case when aa.record_type=1 and tmi.is_vehicle=1 then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 then a.usertag else null end)),2) 近6个月活跃车主人均V值流出数量,
round((sum(case when aa.record_type=1 and tmi.is_vehicle=0 then aa.INTEGRAL else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流出数量
from `member`.tc_member_info tmi 
left join 
	(
	#近6月活跃两次以上的用户
	select t.usertag,
	count(t.date) 活跃次数
	from track.track t
	where t.date>DATE_SUB('2022-07-27 10:00:00',interval 6 month) 
	group by 1
	having count(t.date)>=2
	) a on a.usertag = cast(tmi.USER_ID as varchar)
left join `member`.tt_member_flow_record aa on aa.MEMBER_ID =tmi.ID and aa.is_deleted=0
where tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
group by 1
order by 1

select 
count(DISTINCT case when tmi.IS_VEHICLE=1 or (aa.EVENT_TYPE =60731003 and tmi.IS_VEHICLE =0) then tmi.id else null end) 车主数,
count(DISTINCT case when tmi.IS_VEHICLE=0 and aa.EVENT_TYPE <>60731003 then tmi.id else null end) 粉丝数
from `member`.tc_member_info tmi 
left join `member`.tt_member_flow_record aa on tmi.id=aa.MEMBER_ID 
where tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003


-- V值区间 test 
SELECT 
case when tmi.MEMBER_V_NUM<0 then '-1'
	when tmi.MEMBER_V_NUM=0 then 0 
	when tmi.MEMBER_V_NUM>0 and tmi.MEMBER_V_NUM<=3 then '01 (0,3]'
	when tmi.MEMBER_V_NUM>3 and tmi.MEMBER_V_NUM<=10 then '02 (3,10]'
	when tmi.MEMBER_V_NUM>10 and tmi.MEMBER_V_NUM<=100 then '03 (10,100]'
	when tmi.MEMBER_V_NUM>100 and tmi.MEMBER_V_NUM<=300 then '04 (100,300]'
	when tmi.MEMBER_V_NUM>300 and tmi.MEMBER_V_NUM<=600 then '05 (300,600]'
	when tmi.MEMBER_V_NUM>600 and tmi.MEMBER_V_NUM<=1000 then '06 (600,1000]'
	when tmi.MEMBER_V_NUM>1000 and tmi.MEMBER_V_NUM<=2000 then '07 (1000,2000]'
	when tmi.MEMBER_V_NUM>2000 and tmi.MEMBER_V_NUM<=3000 then '08 (2000,3000]'
	when tmi.MEMBER_V_NUM>3000 and tmi.MEMBER_V_NUM<=4000 then '09 (3000,4000]'
	when tmi.MEMBER_V_NUM>4000 and tmi.MEMBER_V_NUM<=5000 then '10 (4000,5000]'
	when tmi.MEMBER_V_NUM>5000 and tmi.MEMBER_V_NUM<=6000 then '11 (5000,6000]'
	when tmi.MEMBER_V_NUM>6000 and tmi.MEMBER_V_NUM<=7000 then '12 (6000,7000]'
	when tmi.MEMBER_V_NUM>7000 and tmi.MEMBER_V_NUM<=8000 then '13 (7000,8000]'
	when tmi.MEMBER_V_NUM>8000 and tmi.MEMBER_V_NUM<=9000 then '14 (8000,9000]'
	when tmi.MEMBER_V_NUM>9000 and tmi.MEMBER_V_NUM<=10000 then '15 (9000,10000]'
	when tmi.MEMBER_V_NUM>10000 and tmi.MEMBER_V_NUM<=12000 then '16 (10000,12000]'
	when tmi.MEMBER_V_NUM>12000 and tmi.MEMBER_V_NUM<=14000 then '17 (12000,14000]'
	when tmi.MEMBER_V_NUM>14000 and tmi.MEMBER_V_NUM<=16000 then '18 (14000,16000]'
	when tmi.MEMBER_V_NUM>16000 and tmi.MEMBER_V_NUM<=18000 then '19 (16000,18000]'
	when tmi.MEMBER_V_NUM>18000 and tmi.MEMBER_V_NUM<=20000 then '20 (18000,20000]'
	when tmi.MEMBER_V_NUM>20000 and tmi.MEMBER_V_NUM<=22000 then '21 (20000,22000]'
	when tmi.MEMBER_V_NUM>22000 and tmi.MEMBER_V_NUM<=24000 then '22 (22000,24000]'
	when tmi.MEMBER_V_NUM>24000 and tmi.MEMBER_V_NUM<=26000 then '23 (24000,26000]'
	when tmi.MEMBER_V_NUM>26000 and tmi.MEMBER_V_NUM<=28000 then '24 (26000,28000]'
	when tmi.MEMBER_V_NUM>28000 and tmi.MEMBER_V_NUM<=30000 then '25 (28000,30000]'
	when tmi.MEMBER_V_NUM>30000 and tmi.MEMBER_V_NUM<=32000 then '26 (30000,32000]'
	when tmi.MEMBER_V_NUM>32000 and tmi.MEMBER_V_NUM<=34000 then '27 (32000,34000]'
	when tmi.MEMBER_V_NUM>34000 and tmi.MEMBER_V_NUM<=36000 then '28 (34000,36000]'
	when tmi.MEMBER_V_NUM>36000 and tmi.MEMBER_V_NUM<=38000 then '29 (36000,38000]'
	when tmi.MEMBER_V_NUM>38000 and tmi.MEMBER_V_NUM<=40000 then '30 (38000,40000]'
	when tmi.MEMBER_V_NUM>40000 and tmi.MEMBER_V_NUM<=42000 then '31 (40000,42000]'
	when tmi.MEMBER_V_NUM>42000 and tmi.MEMBER_V_NUM<=44000 then '32 (42000,44000]'
	when tmi.MEMBER_V_NUM>44000 and tmi.MEMBER_V_NUM<=46000 then '33 (44000,46000]'
	when tmi.MEMBER_V_NUM>46000 and tmi.MEMBER_V_NUM<=48000 then '34 (46000,48000]'
	when tmi.MEMBER_V_NUM>48000 and tmi.MEMBER_V_NUM<=50000 then '35 (48000,50000]'
	when tmi.MEMBER_V_NUM>50000 then '36 (50000,‘+∞]'
else null end V值余额区间,
count(DISTINCT case when tmi.IS_VEHICLE=1 then tmi.id else null end) 车主数,
count(DISTINCT case when tmi.IS_VEHICLE=0 then tmi.id else null end) 粉丝数,
count(DISTINCT case when tmi.IS_VEHICLE=1 then a.usertag else null end) 车主活跃数,
count(DISTINCT case when tmi.IS_VEHICLE=0 then a.usertag else null end) 粉丝活跃数,
-- round((COUNT(DISTINCT case when aa.record_type=0 and tmi.is_vehicle=1 then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 then a.usertag else null end)),2) 近6个月活跃车主人均V值流入笔数,
-- round((COUNT(DISTINCT case when aa.record_type=0 and tmi.is_vehicle=0 then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流入笔数,
-- round((COUNT(DISTINCT case when aa.record_type=1 and tmi.is_vehicle=1 then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 then a.usertag else null end)),2) 近6个月活跃车主人均V值流出笔数,
-- round((COUNT(DISTINCT case when aa.record_type=1 and tmi.is_vehicle=0 then aa.id else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流出笔数,
round((sum(case when tmi.is_vehicle=1 then b.新增 else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 then a.usertag else null end)),2) 近6个月活跃车主人均V值流入数量,
round((sum(case when tmi.is_vehicle=0 then b.新增 else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流入数量,
round((sum(case when tmi.is_vehicle=1 then b.消耗 else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=1 then a.usertag else null end)),2) 近6个月活跃车主人均V值流出数量,
round((sum(case when tmi.is_vehicle=0 then b.消耗 else null end))/(count(DISTINCT case when tmi.IS_VEHICLE=0 then a.usertag else null end)),2) 近6个月活跃粉丝人均V值流出数量,
sum(case when tmi.is_vehicle=1 then b.新增 else null end) tt,
sum(case when tmi.is_vehicle=0 then b.新增 else null end) tt1
-- b.近6个月活跃车主人均V值流入笔数
from `member`.tc_member_info tmi 
left join 
	(
	#近6月活跃两次以上的用户
	select t.usertag,
	count(t.date) 活跃次数
	from track.track t
	where t.date>DATE_SUB('2022-07-26 23:59:59',interval 6 month) 
	group by 1
	having count(t.date)>=2
	) a on a.usertag = cast(tmi.USER_ID as varchar)
left join 
	(
	select aa.member_id,
	sum(case when aa.record_type=0 then aa.INTEGRAL else null end) 新增,
	sum(case when aa.record_type=1 then aa.INTEGRAL else null end) 消耗
	from `member`.tt_member_flow_record aa
	where aa.is_deleted=0
	group by 1
	)b on b.member_id =tmi.id
-- left join `member`.tt_member_flow_record aa on aa.MEMBER_ID =tmi.ID and aa.is_deleted=0
where tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
group by 1
order by 1

