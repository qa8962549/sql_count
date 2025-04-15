-- 3月至5月22日每月都活跃过的沃世界绑定 （手机号判定）
select count(d.手机号1),
sum(d.登陆天数3月),
sum(d.登陆天数4月),
sum(d.登陆天数5月),
sum(d.登陆天数3月)/count(d.手机号1) 3月当月平均登录天数,
sum(d.登陆天数4月)/count(d.手机号1) 4月当月平均登录天数,
sum(d.登陆天数5月)/count(d.手机号1) 5月当月平均登录天数
from 
( 
	(select m.手机号1,COUNT(m.日期)登陆天数3月 from 
		(select distinct
	DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
	tmi.MEMBER_PHONE 手机号1
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =1
	where t.`date` >= '2022-03-01'        -- 登陆时间
	and t.`date` <= '2022-03-31 23:59:59'
	and t.typeid = 'XWSJXCX_START'   -- 启动小程序
	order by 1)m
	group by 1
	)a 
	join 
	(select m.手机号2,COUNT(m.日期)登陆天数4月 from 
		(select distinct
	DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
	tmi.MEMBER_PHONE 手机号2
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =1
	where t.`date` >= '2022-04-01'        -- 登陆时间
	and t.`date` <= '2022-04-30 23:59:59'
	and t.typeid = 'XWSJXCX_START'   -- 启动小程序
	order by 1)m
	group by 1
	)b on a.手机号1=b.手机号2
	join 
	(select m.手机号3,COUNT(m.日期)登陆天数5月 from 
		(select distinct
	DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
	tmi.MEMBER_PHONE 手机号3
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID as VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 and tmi.IS_VEHICLE =1
	where t.`date` >= '2022-05-01'        -- 登陆时间
	and t.`date` <= '2022-05-22 23:59:59'
	and t.typeid = 'XWSJXCX_START'   -- 启动小程序
	order by 1)m
	group by 1
	)c on b.手机号2=c.手机号3
) d

-- 连续3、4、5月签到人数
select 
count(d.会员ID1),
sum(d.签到天数3月),
sum(d.签到天数4月),
sum(d.签到天数5月),
sum(d.签到天数3月)/count(d.会员ID1) 3月当月平均签到天数,
sum(d.签到天数4月)/count(d.会员ID1) 4月当月平均签到天数,
sum(d.签到天数5月)/count(d.会员ID1) 5月当月平均签到天数
from 
(
	(select m.会员ID1,COUNT(m.日期)签到天数3月
	from 
	(select
	distinct DATE_FORMAT(si.create_time,'%Y-%m-%d')日期,
	tmi.id 会员ID1
	from mine.sign_info si
	left join `member`.tc_member_info tmi on si.member_id =tmi.ID 
	where si.create_time >= '2022-03-01'  -- 签到时间
	and si.create_time <= '2022-03-31 23:59:59'
	and si.is_delete = 0
	and tmi.MEMBER_STATUS <> 60341003
	and tmi.IS_DELETED = 0 
	and tmi.IS_VEHICLE =0
	order by 1)m
	group by 1)a 
	join 
	(select m.会员ID2,COUNT(m.日期)签到天数4月
	from 
	(select
	distinct DATE_FORMAT(si.create_time,'%Y-%m-%d')日期,
	tmi.id 会员ID2
	from mine.sign_info si
	left join `member`.tc_member_info tmi on si.member_id =tmi.ID 
	where si.create_time >= '2022-04-01'  -- 签到时间
	and si.create_time <= '2022-04-30 23:59:59'
	and si.is_delete = 0
	and tmi.MEMBER_STATUS <> 60341003
	and tmi.IS_DELETED = 0 
	and tmi.IS_VEHICLE =0
	order by 1)m
	group by 1)b 
	on a.会员ID1=b.会员ID2
	join 
	(select m.会员ID3,COUNT(m.日期)签到天数5月
	from 
	(select
	distinct DATE_FORMAT(si.create_time,'%Y-%m-%d')日期,
	tmi.id 会员ID3
	from mine.sign_info si
	left join `member`.tc_member_info tmi on si.member_id =tmi.ID 
	where si.create_time >= '2022-05-01'  -- 签到时间
	and si.create_time <= '2022-05-22 23:59:59'
	and si.is_delete = 0
	and tmi.MEMBER_STATUS <> 60341003
	and tmi.IS_DELETED = 0 
	and tmi.IS_VEHICLE =0
	order by 1)m
	group by 1)c
	on b.会员ID2=c.会员ID3
)d
	