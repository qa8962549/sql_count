-- 3月至5月22日每月都活跃过的沃世界粉丝 （会员id判定）
select 
count(d.会员ID1),
sum(d.登陆天数3月),
sum(d.登陆天数4月),
sum(d.登陆天数5月),
sum(d.登陆天数3月)/count(d.会员ID1) 3月当月平均登录天数,
sum(d.登陆天数4月)/count(d.会员ID1) 4月当月平均登录天数,
sum(d.登陆天数5月)/count(d.会员ID1) 5月当月平均登录天数
from 
( 
	(select m.会员ID1,COUNT(m.日期)登陆天数3月 from 
		(select distinct
	DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
	tmi.ID 会员ID1
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =0
	where t.`date` >= '2022-03-01'        -- 3月登陆时间
	and t.`date` <= '2022-03-31 23:59:59'
	and t.typeid = 'XWSJXCX_START'   -- 启动小程序
	order by 1)m
	group by 1
	)a 
	join 
	(select m.会员ID2,COUNT(m.日期)登陆天数4月 from 
		(select distinct
	DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
	tmi.ID 会员ID2
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =0
	where t.`date` >= '2022-04-01'        -- 4月登陆时间
	and t.`date` <= '2022-04-30 23:59:59'
	and t.typeid = 'XWSJXCX_START'   -- 启动小程序
	order by 1)m
	group by 1
	)b on a.会员ID1=b.会员ID2
	join 
	(select m.会员ID3,COUNT(m.日期)登陆天数5月 from 
		(select distinct
	DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
	tmi.ID 会员ID3
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =0
	where t.`date` >= '2022-05-01'        -- 5月登陆时间
	and t.`date` <= '2022-05-22 23:59:59'
	and t.typeid = 'XWSJXCX_START'   -- 启动小程序
	order by 1)m
	group by 1
	)c on b.会员ID2=c.会员ID3
) d

-- 各月签到天数
select 
count(g.会员ID1) 签到人数,
sum(g.签到天数)
-- sum(g.签到天数3月)/count(g.会员ID1) 3月当月平均签到天数
from 
(
	select 
	f.会员ID1,COUNT(f.日期)签到天数
	from 	
	(	
		select 
		distinct DATE_FORMAT(si.create_time,'%Y-%m-%d')日期,
		e.会员ID1
		from 
		(
			select 
			d.会员ID1-- 获取3月至5月22日每月都活跃过的沃世界粉丝会员ID 与签到表进行关联
			from 
			( 
				(select m.会员ID1,COUNT(m.日期)登陆天数3月 from 
					(select distinct
				DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
				tmi.ID 会员ID1
				from track.track t
				join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =1
				where t.`date` >= '2022-03-01'        -- 登陆时间
				and t.`date` <= '2022-03-31 23:59:59'
				and t.typeid = 'XWSJXCX_START'   -- 启动小程序
				order by 1)m
				group by 1
				)a 
				join 
				(select m.会员ID2,COUNT(m.日期)登陆天数4月 from 
					(select distinct
				DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
				tmi.ID 会员ID2
				from track.track t
				join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =1
				where t.`date` >= '2022-04-01'        -- 登陆时间
				and t.`date` <= '2022-04-30 23:59:59'
				and t.typeid = 'XWSJXCX_START'   -- 启动小程序
				order by 1)m
				group by 1
				)b on a.会员ID1=b.会员ID2
				join 
				(select m.会员ID3,COUNT(m.日期)登陆天数5月 from 
					(select distinct
				DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
				tmi.ID 会员ID3
				from track.track t
				join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =1
				where t.`date` >= '2022-05-01'        -- 登陆时间
				and t.`date` <= '2022-05-22 23:59:59'
				and t.typeid = 'XWSJXCX_START'   -- 启动小程序
				order by 1)m
				group by 1
				)c on b.会员ID2=c.会员ID3
			) d
		)e 
		join mine.sign_info si on e.会员ID1=si.member_id 
		where si.create_time >= '2022-05-01'  -- 签到时间(修改签到时间即可)
		and si.create_time <= '2022-05-22 23:59:59'
	)f
	group by 1
)g

-- 最常去top模块(首页、爱车、商城、我的)
select
	case 
		when t.typeid ='XWSJXCX_HOME_V' then '首页'
		when t.typeid= 'XWSJXCX_CUSTOMER_V' then '爱车'
		when t.typeid= 'XWSJXCX_MALL_HOMEPAGE_V' then '商城'
		when t.typeid= 'XWSJXCX_PERSONEL_V' then '我的'
	else null end '分类',
COUNT(t.usertag) PV
from track.track t
-- join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
join (
			select 
			d.会员ID1,-- 获取3月至5月22日每月都活跃过的沃世界会员ID 与签到表进行关联
			d.user_id -- 获取3月至5月22日每月都活跃过的沃世界userID 与track表进行关联
			from 
			( 
				(select m.会员ID1,m.user_id,COUNT(m.日期)登陆天数3月 from 
					(select distinct
				DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
				tmi.ID 会员ID1,
				tmi.USER_ID
				from track.track t
				join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =0
				where t.`date` >= '2022-03-01'        -- 登陆时间
				and t.`date` <= '2022-03-31 23:59:59'
				and t.typeid = 'XWSJXCX_START'   -- 启动小程序
				order by 1)m
				group by 1
				)a 
				join 
				(select m.会员ID2,COUNT(m.日期)登陆天数4月 from 
					(select distinct
				DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
				tmi.ID 会员ID2
				from track.track t
				join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =0
				where t.`date` >= '2022-04-01'        -- 登陆时间
				and t.`date` <= '2022-04-30 23:59:59'
				and t.typeid = 'XWSJXCX_START'   -- 启动小程序
				order by 1)m
				group by 1
				)b on a.会员ID1=b.会员ID2
				join 
				(select m.会员ID3,COUNT(m.日期)登陆天数5月 from 
					(select distinct
				DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
				tmi.ID 会员ID3
				from track.track t
				join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =0
				where t.`date` >= '2022-05-01'        -- 登陆时间
				and t.`date` <= '2022-05-22 23:59:59'
				and t.typeid = 'XWSJXCX_START'   -- 启动小程序
				order by 1)m
				group by 1
				)c on b.会员ID2=c.会员ID3
			) d
	)f on t.usertag=CAST(f.user_id AS VARCHAR)
where t.`date` >= '2022-03-01 00:00:00'   -- 每天修改起始时间
and t.`date` <= '2022-05-22 23:59:59'		-- 每天修改截止时间
group by 1
order by 2 desc

-- 埋点测试(这里填写自己的user_id，user_id在会员表中查找)
select * from track.track t where t.usertag = '6039075' order by t.`date` desc

-- 首页下级最常去top模块(推荐、俱乐部、活动、头条、探索、快速入口)
select
case when json_extract(t.`data`,'$.title')= '推荐tab' then '推荐'
	when json_extract(t.`data`,'$.embeddedpoint')= 'home_club_ONLOAD' then '俱乐部'
	when json_extract(t.`data`,'$.pageId')= 'XWSJXCX_HOME_ACTIVITY_LIST' then '活动'
	when t.data like '%/src/pages/market-package/news/list/index?categoryCode=60471006&title=动态%' then '头条'
	when json_extract(t.`data`,'$.title')= '探索tab' then '探索'
	when json_extract(t.`data`,'$.embeddedpoint')= '快速入口_首页_点击：' then '快速入口'
else null end '分类',
COUNT(t.usertag) PV
from track.track t
join (
        #3月至5月22日每月都活跃过的沃世界用户（粉丝or车主）
			select 
			d.会员ID1,-- 获取3月至5月22日每月都活跃过的沃世界会员ID 与签到表进行关联
			d.user_id -- 获取3月至5月22日每月都活跃过的沃世界userID 与track表进行关联
			from 
			( 
				(select m.会员ID1,m.user_id,COUNT(m.日期)登陆天数3月 from 
					(select distinct
				DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
				tmi.ID 会员ID1,
				tmi.USER_ID
				from track.track t
				join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =1
				where t.`date` >= '2022-03-01'        -- 登陆时间
				and t.`date` <= '2022-03-31 23:59:59'
				and t.typeid = 'XWSJXCX_START'   -- 启动小程序
				order by 1)m
				group by 1
				)a 
				join 
				(select m.会员ID2,COUNT(m.日期)登陆天数4月 from 
					(select distinct
				DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
				tmi.ID 会员ID2
				from track.track t
				join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =1
				where t.`date` >= '2022-04-01'        -- 登陆时间
				and t.`date` <= '2022-04-30 23:59:59'
				and t.typeid = 'XWSJXCX_START'   -- 启动小程序
				order by 1)m
				group by 1
				)b on a.会员ID1=b.会员ID2
				join 
				(select m.会员ID3,COUNT(m.日期)登陆天数5月 from 
					(select distinct
				DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
				tmi.ID 会员ID3
				from track.track t
				join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =1
				where t.`date` >= '2022-05-01'        -- 登陆时间
				and t.`date` <= '2022-05-22 23:59:59'
				and t.typeid = 'XWSJXCX_START'   -- 启动小程序
				order by 1)m
				group by 1
				)c on b.会员ID2=c.会员ID3
			) d
	)f on t.usertag=CAST(f.user_id AS VARCHAR)
where t.`date` >= '2022-03-01 00:00:00'   -- 每天修改起始时间
and t.`date` <= '2022-05-22 23:59:59'		-- 每天修改截止时间
group by 1
order by 2 desc

-- 手机号匹配top模块
select
case when tmi.MEMBER_PHONE='15000378078'THEN'01'
when tmi.MEMBER_PHONE='13818374600'THEN'02'
when tmi.MEMBER_PHONE='18602143229'THEN'03'
when tmi.MEMBER_PHONE='18621579698'THEN'04'
when tmi.MEMBER_PHONE='13585585794'THEN'05'
when tmi.MEMBER_PHONE='15021224341'THEN'06'
when tmi.MEMBER_PHONE='17552758884'THEN'07'
when tmi.MEMBER_PHONE='15900592422'THEN'08'
when tmi.MEMBER_PHONE='15618836428'THEN'09'
when tmi.MEMBER_PHONE='18088978392'THEN'10'
when tmi.MEMBER_PHONE='18616239438'THEN'11'
when tmi.MEMBER_PHONE='15861825493'THEN'12'
when tmi.MEMBER_PHONE='13621697237'THEN'13'
when tmi.MEMBER_PHONE='13917414051'THEN'14'
when tmi.MEMBER_PHONE='13122730610'THEN'15'
when tmi.MEMBER_PHONE='18758197483'THEN'16'
when tmi.MEMBER_PHONE='13916750504'THEN'17'
when tmi.MEMBER_PHONE='15776908536'THEN'18'
when tmi.MEMBER_PHONE='13761701163'THEN'19'
when tmi.MEMBER_PHONE='15821689106'THEN'20'
when tmi.MEMBER_PHONE='18360098408'THEN'21'
when tmi.MEMBER_PHONE='18767100479'THEN'22'
when tmi.MEMBER_PHONE='13641980034'THEN'23'
when tmi.MEMBER_PHONE='13817273768'THEN'24'
when tmi.MEMBER_PHONE='16621032355'THEN'25'
when tmi.MEMBER_PHONE='13916301180'THEN'26'
	 end '手机号',
case when t.typeid ='XWSJXCX_HOME_V' then '首页'
	 when t.typeid= 'XWSJXCX_CUSTOMER_V' then '爱车'
	 when t.typeid= 'XWSJXCX_MALL_HOMEPAGE_V' then '商城'
	 when t.typeid= 'XWSJXCX_PERSONEL_V' then '我的'
	 else null end '分类',
COUNT(t.usertag) PV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-03-01 00:00:00'   -- 每天修改起始时间
and t.`date` <= '2022-05-22 23:59:59'		-- 每天修改截止时间
group by 1,2
order by 1,3 desc

-- 手机号匹配最常去top模块(首页、爱车、商城、我的)
SELECT * 
FROM 
(
SELECT ROW_NUMBER() OVER(PARTITION BY t.手机号 ORDER BY t.分类 DESC) rn,t.*
FROM 
	(select
	case when tmi.MEMBER_PHONE='15000378078'THEN'01'
		when tmi.MEMBER_PHONE='13818374600'THEN'02'
		when tmi.MEMBER_PHONE='18602143229'THEN'03'
		when tmi.MEMBER_PHONE='18621579698'THEN'04'
		when tmi.MEMBER_PHONE='13585585794'THEN'05'
		when tmi.MEMBER_PHONE='15021224341'THEN'06'
		when tmi.MEMBER_PHONE='17552758884'THEN'07'
		when tmi.MEMBER_PHONE='15900592422'THEN'08'
		when tmi.MEMBER_PHONE='15618836428'THEN'09'
		when tmi.MEMBER_PHONE='18088978392'THEN'10'
		when tmi.MEMBER_PHONE='18616239438'THEN'11'
		when tmi.MEMBER_PHONE='15861825493'THEN'12'
		when tmi.MEMBER_PHONE='13621697237'THEN'13'
		when tmi.MEMBER_PHONE='13917414051'THEN'14'
		when tmi.MEMBER_PHONE='13122730610'THEN'15'
		when tmi.MEMBER_PHONE='18758197483'THEN'16'
		when tmi.MEMBER_PHONE='13916750504'THEN'17'
		when tmi.MEMBER_PHONE='15776908536'THEN'18'
		when tmi.MEMBER_PHONE='13761701163'THEN'19'
		when tmi.MEMBER_PHONE='15821689106'THEN'20'
		when tmi.MEMBER_PHONE='18360098408'THEN'21'
		when tmi.MEMBER_PHONE='18767100479'THEN'22'
		when tmi.MEMBER_PHONE='13641980034'THEN'23'
		when tmi.MEMBER_PHONE='13817273768'THEN'24'
		when tmi.MEMBER_PHONE='16621032355'THEN'25'
		when tmi.MEMBER_PHONE='13916301180'THEN'26'
		 end '手机号',
	case when json_extract(t.`data`,'$.title')= '推荐tab' then '推荐'
		when json_extract(t.`data`,'$.embeddedpoint')= 'home_club_ONLOAD' then '俱乐部'
		when json_extract(t.`data`,'$.pageId')= 'XWSJXCX_HOME_ACTIVITY_LIST' then '活动'
		when t.data like '%/src/pages/market-package/news/list/index?categoryCode=60471006&title=动态%' then '头条'
		when json_extract(t.`data`,'$.title')= '探索tab' then '探索'
		when json_extract(t.`data`,'$.embeddedpoint')= '快速入口_首页_点击：' then '快速入口'
		 else null end '分类',
	COUNT(t.usertag) PV
	from track.track t
	join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` >= '2022-03-01 00:00:00'   -- 每天修改起始时间
	and t.`date` <= '2022-05-22 23:59:59'		-- 每天修改截止时间
	group by 1,2
	order by 1,3 desc)t
order by t.手机号)t2 
WHERE t2.rn<4

