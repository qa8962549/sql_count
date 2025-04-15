
-- 1月新注册会员活跃率   活跃人数/注册人数=活跃率
select count(b1.usertag)/count(a.id) 1月活跃率,
count(b2.usertag)/count(a.id) 2月活跃率,
count(b3.usertag)/count(a.id) 3月活跃率,
count(b4.usertag)/count(a.id) 4月活跃率,
count(b5.usertag)/count(a.id) 5月活跃率
FROM 
	(
	#1月注册会员数
	select tmi.ID,tmi.user_id,tmi.is_vehicle
    FROM `member`.tc_member_info tmi 
    where tmi.CREATE_TIME >='2022-01-01' and tmi.CREATE_TIME <= '2022-01-31 23:59:59' -- 在1月注册会员
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)a
left join 
	(
	#1月新会员在1月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-01-01' and t.date <= '2022-01-31 23:59:59'  -- 1月活跃时间
	and tmi.CREATE_TIME >='2022-01-01' and tmi.CREATE_TIME <= '2022-01-31 23:59:59' -- 在1月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b1 on CAST(a.USER_ID AS VARCHAR) = b1.usertag
left join 
	(
	#1月新会员在2月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-02-01' and t.date <= '2022-02-28 23:59:59'  -- 1月活跃时间
	and tmi.CREATE_TIME >='2022-01-01' and tmi.CREATE_TIME <= '2022-01-31 23:59:59' -- 在1月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b2 on CAST(a.USER_ID AS VARCHAR) = b2.usertag
left join 
	(
	#1月新会员在3月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-03-01' and t.date <= '2022-03-31 23:59:59'  -- 1月活跃时间
	and tmi.CREATE_TIME >='2022-01-01' and tmi.CREATE_TIME <= '2022-01-31 23:59:59' -- 在1月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b3 on CAST(a.USER_ID AS VARCHAR) = b3.usertag
left join 
	(
	#1月新会员在4月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-04-01' and t.date <= '2022-04-30 23:59:59'  -- 1月活跃时间
	and tmi.CREATE_TIME >='2022-01-01' and tmi.CREATE_TIME <= '2022-01-31 23:59:59' -- 在1月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b4 on CAST(a.USER_ID AS VARCHAR) = b4.usertag
left join 
	(
	#1月新会员在5月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-05-01' and t.date <= '2022-05-31 23:59:59'  -- 1月活跃时间
	and tmi.CREATE_TIME >='2022-01-01' and tmi.CREATE_TIME <= '2022-01-31 23:59:59' -- 在1月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b5 on CAST(a.USER_ID AS VARCHAR) = b5.usertag
	where a.is_vehicle=0  -- 粉丝为0 ，车主为1，会员则删掉限制条件
union all
#2月新注册会员活跃率   活跃人数/注册人数=活跃率
select 
0/count(a.id) 1月活跃率,
count(b2.usertag)/count(a.id) 2月活跃率,
count(b3.usertag)/count(a.id) 3月活跃率,
count(b4.usertag)/count(a.id) 4月活跃率,
count(b5.usertag)/count(a.id) 5月活跃率
FROM 
	(
	#2月注册会员数
	select tmi.ID,tmi.user_id,tmi.is_vehicle 
    FROM `member`.tc_member_info tmi 
    where tmi.CREATE_TIME >='2022-02-01' and tmi.CREATE_TIME <= '2022-02-28 23:59:59' -- 在2月注册会员
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)a
left join 
	(
	#2月新会员在2月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-02-01' and t.date <= '2022-02-28 23:59:59'  -- 2月活跃时间
	and tmi.CREATE_TIME >='2022-02-01' and tmi.CREATE_TIME <= '2022-02-28 23:59:59' -- 在2月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b2 on CAST(a.USER_ID AS VARCHAR) = b2.usertag
left join 
	(
	#2月新会员在3月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-03-01' and t.date <= '2022-03-31 23:59:59'  -- 3月活跃时间
	and tmi.CREATE_TIME >='2022-02-01' and tmi.CREATE_TIME <= '2022-02-28 23:59:59' -- 在2月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b3 on CAST(a.USER_ID AS VARCHAR) = b3.usertag
left join 
	(
	#2月新会员在4月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-04-01' and t.date <= '2022-04-30 23:59:59'  -- 4月活跃时间
	and tmi.CREATE_TIME >='2022-02-01' and tmi.CREATE_TIME <= '2022-02-28 23:59:59' -- 在2月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b4 on CAST(a.USER_ID AS VARCHAR) = b4.usertag
left join 
	(
	#2月新会员在5月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-05-01' and t.date <= '2022-05-31 23:59:59'  -- 5月活跃时间
	and tmi.CREATE_TIME >='2022-02-01' and tmi.CREATE_TIME <= '2022-02-28 23:59:59' -- 在2月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b5 on CAST(a.USER_ID AS VARCHAR) = b5.usertag
	where a.is_vehicle=0  -- 粉丝为0 ，车主为1，会员则删掉限制条件
union all
#3月新注册会员活跃率   活跃人数/注册人数=活跃率
select 
0/count(a.id) 1月活跃率,
0/count(a.id) 2月活跃率,
count(b3.usertag)/count(a.id) 3月活跃率,
count(b4.usertag)/count(a.id) 4月活跃率,
count(b5.usertag)/count(a.id) 5月活跃率
FROM 
	(
	#3月注册会员数
	select tmi.ID,tmi.user_id,tmi.is_vehicle 
    FROM `member`.tc_member_info tmi 
    where tmi.CREATE_TIME >='2022-03-01' and tmi.CREATE_TIME <= '2022-03-31 23:59:59' -- 在3月注册会员
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)a
left join 
	(
	#3月新会员在3月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-03-01' and t.date <= '2022-03-31 23:59:59'  -- 3月活跃时间
	and tmi.CREATE_TIME >='2022-03-01' and tmi.CREATE_TIME <= '2022-03-31 23:59:59' -- 在3月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b3 on CAST(a.USER_ID AS VARCHAR) = b3.usertag
left join 
	(
	#3月新会员在4月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-04-01' and t.date <= '2022-04-30 23:59:59'  -- 4月活跃时间
	and tmi.CREATE_TIME >='2022-03-01' and tmi.CREATE_TIME <= '2022-03-31 23:59:59' -- 在3月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b4 on CAST(a.USER_ID AS VARCHAR) = b4.usertag
left join 
	(
	#3月新会员在5月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-05-01' and t.date <= '2022-05-31 23:59:59'  -- 5月活跃时间
	and tmi.CREATE_TIME >='2022-03-01' and tmi.CREATE_TIME <= '2022-03-31 23:59:59' -- 在3月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b5 on CAST(a.USER_ID AS VARCHAR) = b5.usertag
	where a.is_vehicle=0 -- 粉丝为0 ，车主为1，会员则删掉限制条件
union all
#4月新注册会员活跃率   活跃人数/注册人数=活跃率
select 
0/count(a.id) 1月活跃率,
0/count(a.id) 2月活跃率,
0/count(a.id) 3月活跃率,
count(b4.usertag)/count(a.id) 4月活跃率,
count(b5.usertag)/count(a.id) 5月活跃率
FROM 
	(
	#4月注册会员数
	select tmi.ID,tmi.user_id,tmi.is_vehicle 
    FROM `member`.tc_member_info tmi 
    where tmi.CREATE_TIME >='2022-04-01' and tmi.CREATE_TIME <= '2022-04-30 23:59:59' -- 在4月注册会员
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)a
left join 
	(
	#4月新会员在4月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-04-01' and t.date <= '2022-04-30 23:59:59'  -- 4月活跃时间
	and tmi.CREATE_TIME >='2022-04-01' and tmi.CREATE_TIME <= '2022-04-30 23:59:59' -- 在4月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b4 on CAST(a.USER_ID AS VARCHAR) = b4.usertag
left join 
	(
	#4月新会员在5月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-05-01' and t.date <= '2022-05-31 23:59:59'  -- 5月活跃时间
	and tmi.CREATE_TIME >='2022-04-01' and tmi.CREATE_TIME <= '2022-04-30 23:59:59' -- 在4月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b5 on CAST(a.USER_ID AS VARCHAR) = b5.usertag
	where a.is_vehicle=0
union all
#5月新注册会员活跃率   活跃人数/注册人数=活跃率
select 
0/count(a.id) 1月活跃率,
0/count(a.id) 2月活跃率,
0/count(a.id) 3月活跃率,
0/count(a.id) 4月活跃率,
count(b5.usertag)/count(a.id) 5月活跃率
FROM 
	(
	#5月注册会员数
	select tmi.ID,tmi.user_id,tmi.is_vehicle 
    FROM `member`.tc_member_info tmi 
    where tmi.CREATE_TIME >='2022-05-01' and tmi.CREATE_TIME <= '2022-05-31 23:59:59' -- 在5月注册会员
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)a
left join 
	(
	#5月新会员在5月活跃人数
	select DISTINCT t.usertag
	from member.tc_member_info tmi
	left join track.track t on CAST(tmi.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-05-01' and t.date <= '2022-05-31 23:59:59'  -- 5月活跃时间
	and tmi.CREATE_TIME >='2022-05-01' and tmi.CREATE_TIME <= '2022-05-31 23:59:59' -- 在5月注册会员
	and t.date > tmi.create_time
	and tmi.IS_DELETED=0 and tmi.MEMBER_STATUS<>60341003
	)b5 on CAST(a.USER_ID AS VARCHAR) = b5.usertag
where a.is_vehicle=0  -- 粉丝为0 ，车主为1，会员则删掉限制条件
order by 1,2,3,4,5 desc 


--1个月内签到次数
--
--半年内签到次数
--
--签到页逛一逛抽好礼1个月点击次数
-- QIANDAO_首页逛一逛_ONCLICK
--签到页逛一逛抽好礼半年点击次数
--
--半年内通过小程序短信链接进入小程序次数
--
--上个月会员日主页订阅是否点击
--
--上月会员日是否进入活动页面

-- 新增字段4月
SELECT tmi.MEMBER_PHONE 手机号,
ifnull(a.1个月内签到次数,0) 1个月内签到次数,
IFNULL(a1.半年内签到次数,0) 半年内签到次数,
if(b.点击 is not null,'是','否') 上个月会员日主页订阅是否点击,
if(b1.点击 is not null,'是','否') 上月会员日是否进入活动页面
from `member`.tc_member_info tmi 
LEFT JOIN 
	(
	#1个月内签到次数
	select 
	si.member_id,
	count(si.id) 1个月内签到次数
	FROM mine.sign_info si 
	where si.create_time >='2022-03-25'
	and si.create_time <'2022-04-25'
	and si.is_delete<>1
	group by 1
	order by 2 desc 
	)a on a.member_id=tmi.id
left join 
	(
	#半年内签到次数
	select 
	si.member_id,
	count(si.id) 半年内签到次数
	FROM mine.sign_info si 
	where si.create_time >='2021-10-25'
	and si.create_time <'2022-04-25'
	and si.is_delete<>1
	group by 1
	order by 2 desc 
	)a1 on a1.member_id=tmi.id
left join 
	(
	#上个月会员日主页订阅是否点击
	select t.usertag,
	count(t.data) 点击
	from track.track t 
	where json_extract(t.data,'$.embeddedpoint')='memberDay3_home_订阅_click'
	and t.date>='2022-03-25'
	and t.date<='2022-03-25 23:59:59'
	group by 1
	)b on b.usertag=tmi.USER_ID
left join 
	(
	#上月会员日是否进入活动页面
	select t.usertag,
	count(t.data) 点击
	from track.track t 
	where json_extract(t.data,'$.embeddedpoint')='memberDay3_home_onload'
	and t.date>='2022-03-25'
	and t.date<='2022-03-25 23:59:59'
	group by 1
	)b1 on b1.usertag=tmi.USER_ID
where tmi.IS_DELETED <>1 
and tmi.STATUS <>'60341003'
and LENGTH(tmi.MEMBER_PHONE)=11 
and left(tmi.MEMBER_PHONE,1)='1'

-- 新增字段5月
SELECT tmi.MEMBER_PHONE 手机号,
ifnull(a.1个月内签到次数,0) 1个月内签到次数,
IFNULL(a1.半年内签到次数,0) 半年内签到次数,
if(b.点击 is not null,'是','否') 上个月会员日主页订阅是否点击,
if(b1.点击 is not null,'是','否') 上月会员日是否进入活动页面
from `member`.tc_member_info tmi 
LEFT JOIN 
	(
	#1个月内签到次数
	select 
	si.member_id,
	count(si.id) 1个月内签到次数
	FROM mine.sign_info si 
	where si.create_time >='2022-04-25'
	and si.create_time <'2022-05-25'
	and si.is_delete<>1
	group by 1
	order by 2 desc 
	)a on a.member_id=tmi.id
left join 
	(
	#半年内签到次数
	select 
	si.member_id,
	count(si.id) 半年内签到次数
	FROM mine.sign_info si 
	where si.create_time >='2021-11-25'
	and si.create_time <'2022-05-25'
	and si.is_delete<>1
	group by 1
	order by 2 desc 
	)a1 on a1.member_id=tmi.id
left join 
	(
	#上个月会员日主页订阅是否点击
	select t.usertag,
	count(t.data) 点击
	from track.track t 
	where json_extract(t.data,'$.embeddedpoint')='memberDay4_home_订阅_click'
	and t.date>='2022-04-25'
	and t.date<='2022-04-25 23:59:59'
	group by 1
	)b on b.usertag=tmi.USER_ID
left join 
	(
	#上月会员日是否进入活动页面
	select t.usertag,
	count(t.data) 点击
	from track.track t 
	where json_extract(t.data,'$.embeddedpoint')='memberDay4_home_onload'
	and t.date>='2022-04-25'
	and t.date<='2022-04-25 23:59:59'
	group by 1
	)b1 on b1.usertag=tmi.USER_ID
where tmi.IS_DELETED <>1 
and tmi.STATUS <>'60341003'
and LENGTH(tmi.MEMBER_PHONE)=11 
and left(tmi.MEMBER_PHONE,1)='1'


-- 会员日活动明细 （4月会员日ID关联）
select 
DISTINCT tmi.ID id,
tmi.MEMBER_PHONE 手机号,
tmi.USER_ID 用户id,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tmi.CREATE_TIME 注册时间,
case when tmi.LEVEL_ID = '1' then '青铜会员'
	when tmi.LEVEL_ID = '2' then '白银会员'
	when tmi.LEVEL_ID = '3' then '黄金会员'
	when tmi.LEVEL_ID = '4' then '白金会员'
	when tmi.LEVEL_ID = '5' then '钻石会员'
	end '会员等级',
case when tmi.IS_VEHICLE =1 then '是'
	when tmi.IS_VEHICLE =0 then '否'
	end '是否车主',
case when cfu.is_deleted =0 then '是'
else '否' end '是否车友会成员',
o.车型 车辆型号,
a.未使用V值 V值余额,
ifnull(x1.tt,0) 1月活跃,
ifnull(x2.tt,0) 半年活跃,
ifnull(b1.V值消耗,0) 1月V值消费,
ifnull(b2.现金支付金额,0) 1月现金消费,
ifnull(b3.V值消耗,0) 半年V值消费,
ifnull(b4.现金支付金额,0) 半年现金消费,
ifnull(c1.有效期优惠券数量,0) 有效期优惠券数量,
ifnull(c2.过期优惠券,0) 过期优惠券,
ifnull(c3.半年核销优惠券,0) 半年核销优惠券,
ifnull(d1.收藏总数,0)收藏总数,
ifnull(d2.1月分享,0)1月分享,
ifnull(d3.半年分享,0)半年分享,
ifnull(d2.1月点赞,0)1月点赞,
ifnull(d3.半年点赞,0)半年点赞,
ifnull(e1.1月评论,0) 1月评论,
ifnull(e2.半年评论,0) 半年评论,
ifnull(f.半年商城购买次数,0) 半年商城购买次数,
if(g.预约试驾='是','是','否') 预约试驾,
if(h.上月会员日是否活跃='是','是','否') 上月会员日是否活跃,
if(i.上月会员日是否参与抽奖='是','是','否') 上月会员日是否参与抽奖,
if(j1.活跃='是','是','否') 活跃,
if(j2.活动参与1='是','是','否') 活动参与1,
ifnull(j3.活动参与2,0) 活动参与2，
if(h1.7月会员日是否参与='是','是','否') 7月会员日是否活跃
from `member`.tc_member_info tmi 
join 
	(
	#参加4月会员日的用户
	select DISTINCT t.usertag
	from track.track t 
	where json_extract(t.data,'$.embeddedpoint')='memberDay4_home_onload'
	and t.date>='2022-04-25' and t.date<='2022-04-25 23:59:59'
	)xx on cast(tmi.USER_ID as varchar)=xx.usertag 
left join 
	(
	#截止活动开始前的V值余额  
	 select
	 f.MEMBER_ID,
	 m.MEMBER_V_NUM,
	 m.MEMBER_V_NUM-sum(case when f.create_time >= '2022-04-25' then 
	   case when f.RECORD_TYPE=1 then -f.INTEGRAL when f.RECORD_TYPE=0 then f.INTEGRAL else 0 end 
	   else 0 end) 未使用V值
	 from member.tt_member_flow_record f
	 join member.tc_member_info m on f.MEMBER_ID=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	 where f.IS_DELETED=0 
	 and f.EVENT_DESC <>'V值退回'
	 GROUP BY 1
	 order by 3
	) a on a.MEMBER_ID =tmi.ID
left join 
	(
	#4月会员日活动开始前1个月活跃天数
	select x.usertag,COUNT(DISTINCT x.tt) tt
	from 
			(
			select t.usertag,DATE_FORMAT(t.date,'%Y-%m-%d') tt
			from track.track t
			join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
			where t.`date` <'2022-04-25' and t.`date`>='2022-03-25' 
			order by 1
			)x
	group by 1 
	)x1 on tmi.USER_ID=x1.usertag 
left join 
	(
	#4月会员日活动开始前半年活跃天数
	select x.usertag,COUNT(DISTINCT x.tt) tt  
	from 
		(
		select t.usertag,DATE_FORMAT(t.date,'%Y-%m-%d') tt -- 活跃时间格式化成年月日，去掉重复的年月日就是活跃天数
		from track.track t
		join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
		where t.`date` <'2022-04-25' and t.`date`>='2021-10-25' 
		order by 1
		)x
	group by 1 
	)x2 on tmi.USER_ID=x2.usertag 
left join 
	(
	#活动开始前1个月商城V值消耗数量
	select 
	a.MEMBER_ID,
	sum(a.CONSUMPTION_INTEGRAL) V值消耗
	from `member`.tt_member_score_record a
	where 
	a.IS_BACK =0 -- 退回V值
	and a.IS_DELETED =0 -- 未删除
	and a.CREATE_TIME<'2022-04-25'
	and a.CREATE_TIME>='2022-03-25'
	group by 1
	) b1 on b1.MEMBER_ID =tmi.ID
left join 
	(
	#活动开始前1个月商城现金支付金额
	select 
	tmi.ID,
	sum(b.pay_fee)/100 现金支付金额
	from order.tt_order a  -- 订单主表
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join member.tc_member_info tmi on a.user_id = tmi.id and tmi.is_deleted <> 1  -- 会员表(获取会员信息)
	left join
		(
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
	where a.create_time >= '2022-03-25' and a.create_time <'2022-04-25'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	group by 1
	) b2 on b2.ID =tmi.ID
left join 
	(
	#活动开始前半年内商城V值消耗数量
	select 
	a.MEMBER_ID,
	sum(a.CONSUMPTION_INTEGRAL) V值消耗
	from `member`.tt_member_score_record a
	where 
	a.IS_BACK =0 -- 剔除退回V值
	and a.IS_DELETED =0 -- 未删除
	and a.CREATE_TIME<'2022-04-25'
	and a.CREATE_TIME>='2021-10-25'
	group by 1
	) b3 on b3.MEMBER_ID =tmi.ID
left join 
	(
	#活动开始前半年内商城现金支付金额
	select 
	tmi.ID,
	sum(b.pay_fee)/100 现金支付金额
	from order.tt_order a  -- 订单主表
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join member.tc_member_info tmi on a.user_id = tmi.id and tmi.is_deleted <> 1  -- 会员表(获取会员信息)
	left join
		(
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
	where a.create_time >= '2022-10-25' and a.create_time <'2022-04-25'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	group by 1
	) b4 on b4.ID =tmi.ID
left join 
	(
	#活动开始前账户有效期内优惠券数量
	select tcd.one_id,count(tcd.id) 有效期优惠券数量
	from coupon.tt_coupon_detail tcd 
	where tcd.expiration_date >='2022-04-26' -- 有效期时间大于4月会员日
	and tcd.create_time <'2022-04-25' -- 4月会员日之前拿到优惠券
	and tcd.ticket_state ='31061001' -- 已领取
	and tcd.is_deleted <> 1 -- 未删除
	group by 1
	)c1 on tmi.CUST_ID =c1.one_id
left join 
	(
	#活动开始前账户过期优惠券数量
	select tcd.one_id,count(tcd.id) 过期优惠券
	from coupon.tt_coupon_detail tcd 
	where tcd.expiration_date <'2022-04-25' -- 有效期时间小于4月会员日
	and tcd.create_time <'2022-04-25' -- 4月会员日之前拿到优惠券
	and tcd.ticket_state ='31061004'-- 已失效=已过期
	and tcd.is_deleted <> 1 -- 未删除
	group by 1
	)c2 on tmi.CUST_ID =c2.one_id
left join 
	(
	#活动开始前半年内核销优惠券数量
	select tcd.one_id,count(tcd.id) 半年核销优惠券
	from coupon.tt_coupon_detail tcd 
	where tcd.create_time <'2022-04-25' -- 4月会员日之前拿到优惠券
	and tcd.create_time >='2021-10-25'
	and tcd.ticket_state ='31061003'-- 已核销
	and tcd.is_deleted <> 1 -- 未删除
	group by 1
	)c3 on tmi.CUST_ID =c3.one_id
left join 
	(
	#沃世界我的收藏总数
	select col.user_id,
	SUM(CASE when col.type='COLLECTION' then 1 else 0 end) 收藏总数
	from `cms-center`.cms_operate_log col 
	where col.deleted=0 -- 未删除
	group by 1
	)d1 on tmi.USER_ID =d1.user_id
left join 
	(
	#活动开始前1个月分享数量 活动开始前1个月点赞数量
	select col.user_id,
	sum(case when col.type='SUPPORT' then 1 else 0 end) 1月点赞,
	SUM(CASE when col.type='SHARE' then 1 else 0 end) 1月分享
	from `cms-center`.cms_operate_log col 
	where col.deleted=0 -- 未删除
	and col.date_create<'2022-04-25'
	and col.date_create>='2022-03-25'
	group by 1
	)d2 on tmi.USER_ID =d2.user_id
left join 
	(
	#活动开始前半年内分享数量 活动开始前半年内点赞数量
	select col.user_id,
	sum(case when col.type='SUPPORT' then 1 else 0 end) '半年点赞',
	SUM(CASE when col.type='SHARE' then 1 else 0 end) '半年分享'
	from `cms-center`.cms_operate_log col 
	where col.deleted=0 -- 未删除
	and col.date_create<'2022-04-25'
	and col.date_create>='2021-10-25'
	group by 1
	)d3 on tmi.USER_ID =d3.user_id
left join 
	(
	#活动开始前1个月活动页面评论数量
	select teh.user_id,
	count(teh.id) 1月评论
	from comment.tt_evaluation_history teh 
	where teh.create_time <'2022-04-25'
	and teh.create_time >='2022-03-25'
	and teh.object_type='31151016' -- 评论对象为活动
	and teh.is_deleted =0 -- 未删除
	group by 1
	)e1 on e1.user_id=tmi.USER_ID 
left join 
	(
	#活动开始前半年内活动页面评论数量
	select teh.user_id,
	count(teh.id) 半年评论
	from comment.tt_evaluation_history teh 
	where teh.create_time <'2022-04-25'
	and teh.create_time >='2021-10-25'
	and teh.object_type='31151016' -- 评论对象为活动
	and teh.is_deleted =0 -- 未删除
	group by 1
	)e2 on e2.user_id=tmi.USER_ID 
left join 
	(
	#活动开始前半年内商城购买次数
	select 
	tmi.ID,
	count(a.order_code) 半年商城购买次数
	from order.tt_order a  -- 订单主表
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join member.tc_member_info tmi on a.user_id = tmi.id and tmi.is_deleted <> 1  -- 会员表(获取会员信息)
	left join
		(
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
	where a.create_time >= '2021-10-25' and a.create_time <'2022-04-25'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	group by 1
	) f on f.ID =tmi.ID 
left join 
	(
	#半年内是否预约试驾
	select ta.one_id,if(ta.appointment_id<>0,'是','否') 预约试驾 -- if(g.预约试驾=是,'是','否')
	from cyx_appointment.tt_appointment ta 
	where ta.CREATED_AT >= '2021-10-25'
	and ta.CREATED_AT <'2022-04-25'
	and ta.IS_DELETED =0 -- 未删除
	group by 1
	)g on g.one_id=tmi.CUST_ID 
left join 
	(
	#上月会员日是否活跃
	select t.usertag,if(t.date<>0,'是','否') 上月会员日是否活跃 -- if(h.上月会员日是否活跃=是,'是','否')
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` <='2022-03-25 23:59:59' and t.`date`>='2022-03-25'  -- 上月会员日时间
	group by 1
	)h on tmi.USER_ID=h.usertag 
left join 
	(
	#7月会员日是否参与
	select t.usertag,if(t.date<>0,'是','否') 7月会员日是否参与 -- if(h.上月会员日是否活跃=是,'是','否')
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` <='2022-07-25 23:59:59' and t.`date`>='2022-07-25'  -- 上月会员日时间
	and json_extract(t.data,'$.embeddedpoint')='memberDay7_home_onload'
	group by 1
	)h1 on tmi.USER_ID=h1.usertag 
left join 
	(
	#上月会员日是否参与抽奖
	select 
	a.member_id,
	if(a.id<>0,'是','否') 上月会员日是否参与抽奖
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	where a.lottery_play_code = 'member_day_202203' -- 3月会员日抽奖活动入口
	)i on tmi.ID=i.member_id
left join 
	(
	#活动期间是否活跃
	select t.usertag,if(t.date<>0,'是','否') 活跃 -- if(h.上月会员日是否活跃=是,'是','否')
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` <='2022-04-25 23:59:59' and t.`date`>='2022-04-25'  -- 4月会员日时间
	group by 1
	)j1 on tmi.USER_ID=j1.usertag 
left join 
	(
	#活动参与1  是否参与抽奖
	select 
	a.member_id,
	if(a.id<>0,'是','否') 活动参与1
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	where a.lottery_play_code = 'member_day_202204' -- 4月会员日抽奖活动入口
	)j2 on tmi.ID=j2.member_id
left join 
	(
	#活动参与2  抽奖次数
	select 
	a.member_id,
	count(a.id) 活动参与2
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	where a.lottery_play_code = 'member_day_202204' -- 4月会员日抽奖活动入口
	group by 1
	)j3 on tmi.ID=j3.member_id
left join car_friends.car_friends_user cfu on tmi.ID =cfu.member_id  and cfu.is_deleted =0-- 车友会用户表,剔除退出车会友成员
left join 
	(
	select a.CUSTOMER_ID,a.车型
	from 
		(
		select tv.CUSTOMER_ID,
		tv.MODEL_NAME 车型,
		row_number() over(partition by tv.CUSTOMER_ID order by tv.update_time desc) rk
		from vehicle.tm_vehicle tv
		where tv.IS_DELETED =0
		) a
	where a.rk=1
	)o on tmi.CUST_ID =o.CUSTOMER_ID
where tmi.MEMBER_STATUS <> '60341003' and tmi.IS_DELETED = 0


-- x （5月会员日ID关联）
select 
distinct tmi.id id,
tmi.MEMBER_PHONE 手机号,
tmi.USER_ID 用户id,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tmi.CREATE_TIME 注册时间,
case when tmi.LEVEL_ID = '1' then '青铜会员'
	when tmi.LEVEL_ID = '2' then '白银会员'
	when tmi.LEVEL_ID = '3' then '黄金会员'
	when tmi.LEVEL_ID = '4' then '白金会员'
	when tmi.LEVEL_ID = '5' then '钻石会员'
	end '会员等级',
case when tmi.IS_VEHICLE =1 then '是'
	when tmi.IS_VEHICLE =0 then '否'
	end '是否车主',
case when cfu.is_deleted =0 then '是'
else '否' end '是否车友会成员',
o.车型 车辆型号,
a.未使用V值 V值余额,
ifnull(x1.tt,0) 1月活跃,
ifnull(x2.tt,0) 半年活跃,
ifnull(b1.V值消耗,0) 1月V值消费,
ifnull(b2.现金支付金额,0) 1月现金消费,
ifnull(b3.V值消耗,0) 半年V值消费,
ifnull(b4.现金支付金额,0) 半年现金消费,
ifnull(c1.有效期优惠券数量,0) 有效期优惠券数量,
ifnull(c2.过期优惠券,0) 过期优惠券,
ifnull(c3.半年核销优惠券,0) 半年核销优惠券,
ifnull(c4.1月活动参与数,0) 1月活动参与数,
ifnull(d1.收藏总数,0)收藏总数,
ifnull(d2.1月分享,0)1月分享,
ifnull(d3.半年分享,0)半年分享,
ifnull(d2.1月点赞,0)1月点赞,
ifnull(d3.半年点赞,0)半年点赞,
ifnull(e1.1月评论,0) 1月评论,
ifnull(e2.半年评论,0) 半年评论,
ifnull(f.半年商城购买次数,0) 半年商城购买次数,
if(g.预约试驾='是','是','否') 预约试驾,
if(h.上月会员日是否活跃='是','是','否') 上月会员日是否活跃,
if(i.上月会员日是否参与抽奖='是','是','否') 上月会员日是否参与抽奖,
if(j1.活跃='是','是','否') 活跃,
if(j2.活动参与1='是','是','否') 活动参与1,
ifnull(j3.活动参与2,0) 活动参与2
from `member`.tc_member_info tmi 
join 
	(
	#参加5月会员日的用户
	select DISTINCT t.usertag
	from track.track t 
	where json_extract(t.data,'$.embeddedpoint')='memberDay4_home_onload'
	and t.date>='2022-05-25' and t.date<='2022-05-25 23:59:59'
	)xx on cast(tmi.USER_ID as varchar)=xx.usertag 
left join 
	(
	#截止活动开始前的V值余额  
	#剔除4.25以后，6.26之前获取的V值
 select
 f.MEMBER_ID,
 m.MEMBER_V_NUM,
 m.MEMBER_V_NUM-sum(case when f.create_time >= '2022-05-25' then 
   case when f.RECORD_TYPE=1 then -f.INTEGRAL when f.RECORD_TYPE=0 then f.INTEGRAL else 0 end 
   else 0 end) 未使用V值
 from member.tt_member_flow_record f
 join member.tc_member_info m on f.MEMBER_ID=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
 where f.IS_DELETED=0 
 and f.EVENT_DESC <>'V值退回'
 GROUP BY 1
 order by 3
	) a on a.MEMBER_ID =tmi.ID
left join 
	(
	#4月会员日活动开始前1个月活跃天数
	select x.usertag,COUNT(DISTINCT x.tt) tt
	from 
			(
			select t.usertag,DATE_FORMAT(t.date,'%Y-%m-%d') tt
			from track.track t
			join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
			where t.`date` <'2022-05-25' and t.`date`>='2022-04-25' 
			order by 1
			)x
	group by 1 
	)x1 on tmi.USER_ID=x1.usertag 
left join 
	(
	#4月会员日活动开始前半年活跃天数
	select x.usertag,COUNT(DISTINCT x.tt) tt  
	from 
		(
		select t.usertag,DATE_FORMAT(t.date,'%Y-%m-%d') tt -- 活跃时间格式化成年月日，去掉重复的年月日就是活跃天数
		from track.track t
		join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
		where t.`date` <'2022-05-25' and t.`date`>='2021-11-25' 
		order by 1
		)x
	group by 1 
	)x2 on tmi.USER_ID=x2.usertag 
left join 
	(
	#活动开始前1个月商城V值消耗数量
	select 
	a.MEMBER_ID,
	sum(a.CONSUMPTION_INTEGRAL) V值消耗
	from `member`.tt_member_score_record a
	where 
	a.IS_BACK =0 -- 退回V值
	and a.IS_DELETED =0 -- 未删除
	and a.CREATE_TIME<'2022-05-25'
	and a.CREATE_TIME>='2022-04-25'
	group by 1
	) b1 on b1.MEMBER_ID =tmi.ID
left join 
	(
	#活动开始前1个月商城现金支付金额
	select 
	tmi.ID,
	sum(b.pay_fee)/100 现金支付金额
	from order.tt_order a  -- 订单主表
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join member.tc_member_info tmi on a.user_id = tmi.id and tmi.is_deleted <> 1  -- 会员表(获取会员信息)
	left join
		(
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
	where a.create_time >= '2022-04-25' and a.create_time <'2022-05-25'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	group by 1
	) b2 on b2.ID =tmi.ID
left join 
	(
	#活动开始前半年内商城V值消耗数量
	select 
	a.MEMBER_ID,
	sum(a.CONSUMPTION_INTEGRAL) V值消耗
	from `member`.tt_member_score_record a
	where 
	a.IS_BACK =0 -- 剔除退回V值
	and a.IS_DELETED =0 -- 未删除
	and a.CREATE_TIME<'2022-05-25'
	and a.CREATE_TIME>='2021-11-25'
	group by 1
	) b3 on b3.MEMBER_ID =tmi.ID
left join 
	(
	#活动开始前半年内商城现金支付金额
	select 
	tmi.ID,
	sum(b.pay_fee)/100 现金支付金额
	from order.tt_order a  -- 订单主表
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join member.tc_member_info tmi on a.user_id = tmi.id and tmi.is_deleted <> 1  -- 会员表(获取会员信息)
	left join
		(
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
	where a.create_time >= '2022-10-25' and a.create_time <'2022-05-25'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	group by 1
	) b4 on b4.ID =tmi.ID
left join 
	(
	#活动开始前账户有效期内优惠券数量
	select tcd.one_id,count(tcd.id) 有效期优惠券数量
	from coupon.tt_coupon_detail tcd 
	where tcd.expiration_date >='2022-05-25' -- 有效期时间大于5月会员日
	and tcd.create_time <'2022-05-25' -- 5月会员日之前拿到优惠券
	and tcd.ticket_state ='31061001' -- 已领取
	and tcd.is_deleted <> 1 -- 未删除
	group by 1
	)c1 on tmi.CUST_ID =c1.one_id
left join 
	(
	#活动开始前账户过期优惠券数量
	select tcd.one_id,count(tcd.id) 过期优惠券
	from coupon.tt_coupon_detail tcd 
	where tcd.expiration_date <'2022-05-25' -- 有效期时间小于4月会员日
	and tcd.create_time <'2022-05-25' -- 4月会员日之前拿到优惠券
	and tcd.ticket_state ='31061004'-- 已失效=已过期
	and tcd.is_deleted <> 1 -- 未删除
	group by 1
	)c2 on tmi.CUST_ID =c2.one_id
left join 
	(
	#活动开始前半年内核销优惠券数量
	select tcd.one_id,count(tcd.id) 半年核销优惠券
	from coupon.tt_coupon_detail tcd 
	where tcd.create_time <'2022-05-25' -- 4月会员日之前拿到优惠券
	and tcd.create_time >='2021-11-25'
	and tcd.ticket_state ='31061003'-- 已核销
	and tcd.is_deleted <> 1 -- 未删除
	group by 1
	)c3 on tmi.CUST_ID =c3.one_id
left join 
	(
	select a.usertag,count(DISTINCT a.活动) 1月活动参与数
	from 
		( 
		select DISTINCT '1' 活动,'1' 分组, t.usertag
		from track.track t
		where t.date >= '2022-04-25' and t.date < '2022-05-25' 
		and json_extract(t.`data`,'$.embeddedpoint') in('collectionPage_home_预热_click','collectionPage_home_正式_click')
		union all 
		select DISTINCT '2' 活动,'1' 分组, t.usertag
		from track.track t
		where t.date >= '2022-04-25' and t.date < '2022-05-25'  
		and json_extract(t.`data`,'$.embeddedpoint') = 'QIANDAO_SHOUYE_ONLOAD'
		union all 
		select DISTINCT '3' 活动,'2' 分组, t.usertag
		from track.track t
		where t.date >= '2022-04-25' and t.date < '2022-05-25' 
		and json_extract(t.`data`,'$.embeddedpoint') = 'CHEZHUGUSHI_HOME_ONLOAD'
		union all 
		select DISTINCT '4' 活动,'2' 分组, t.usertag
		from track.track t
		where t.date >= '2022-04-25' and t.date < '2022-05-25' 
		and json_extract(t.`data`,'$.embeddedpoint') = '别赶路_首页_onload_'
		union all 
		select DISTINCT '5' 活动,'2' 分组,cast(o.user_id as varchar) usertag
		from 'cms-center'.cms_operate_log o
		where o.type = 'VIEW'
		and date_create >='2022-04-25' and date_create <'2022-05-25' 
		and o.ref_id='mNMJ3Su0Vt' 
		union all 
		select DISTINCT '6' 活动,'2' 分组,cast(o.user_id as varchar) usertag
		from 'cms-center'.cms_operate_log o
		where o.type = 'VIEW'
		and date_create >='2022-04-25' and date_create <'2022-05-25'  
		and o.ref_id='mNMJ3Su0Vt' 
		union all 
		select DISTINCT '7' 活动,'2' 分组,cast(o.user_id as varchar) usertag
		from 'cms-center'.cms_operate_log o
		where o.type = 'VIEW'
		and date_create >='2022-04-25' and date_create <'2022-05-25' 
		and o.ref_id='ktgB0ySwBb'  
		union all 
		select DISTINCT '8' 活动,'1' 分组, t.usertag
		from track.track t
		where t.date >= '2022-04-25' and t.date < '2022-05-25' 
		and json_extract(t.`data`,'$.embeddedpoint') = '525owner2022_home_ONLOAD'
		union all 
		select DISTINCT '9' 活动,'2' 分组, t.usertag
		from track.track t
		where t.date >= '2022-04-25' and t.date < '2022-05-25' 
		and json_extract(t.`data`,'$.embeddedpoint') = 'memberDay5_home_onload'
		) a		
	GROUP BY 1 
	)c4 on c4.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join 
	(
	#沃世界我的收藏总数
	select col.user_id,
	SUM(CASE when col.type='COLLECTION' then 1 else 0 end) 收藏总数
	from `cms-center`.cms_operate_log col 
	where col.deleted=0 -- 未删除
	group by 1
	)d1 on tmi.USER_ID =d1.user_id
left join 
	(
	#活动开始前1个月分享数量 活动开始前1个月点赞数量
	select col.user_id,
	sum(case when col.type='SUPPORT' then 1 else 0 end) 1月点赞,
	SUM(CASE when col.type='SHARE' then 1 else 0 end) 1月分享
	from `cms-center`.cms_operate_log col 
	where col.deleted=0 -- 未删除
	and col.date_create<'2022-05-25'
	and col.date_create>='2022-04-25'
	group by 1
	)d2 on tmi.USER_ID =d2.user_id
left join 
	(
	#活动开始前半年内分享数量 活动开始前半年内点赞数量
	select col.user_id,
	sum(case when col.type='SUPPORT' then 1 else 0 end) '半年点赞',
	SUM(CASE when col.type='SHARE' then 1 else 0 end) '半年分享'
	from `cms-center`.cms_operate_log col 
	where col.deleted=0 -- 未删除
	and col.date_create<'2022-05-25'
	and col.date_create>='2021-11-25'
	group by 1
	)d3 on tmi.USER_ID =d3.user_id
left join 
	(
	#活动开始前1个月活动页面评论数量
	select teh.user_id,
	count(teh.id) 1月评论
	from comment.tt_evaluation_history teh 
	where teh.create_time <'2022-05-25'
	and teh.create_time >='2022-04-25'
	and teh.object_type='31151016' -- 评论对象为活动
	and teh.is_deleted =0 -- 未删除
	group by 1
	)e1 on e1.user_id=tmi.USER_ID 
left join 
	(
	#活动开始前半年内活动页面评论数量
	select teh.user_id,
	count(teh.id) 半年评论
	from comment.tt_evaluation_history teh 
	where teh.create_time <'2022-05-25'
	and teh.create_time >='2021-11-25'
	and teh.object_type='31151016' -- 评论对象为活动
	and teh.is_deleted =0 -- 未删除
	group by 1
	)e2 on e2.user_id=tmi.USER_ID 
left join 
	(
	#活动开始前半年内商城购买次数
	select 
	tmi.ID,
	count(a.order_code) 半年商城购买次数
	from order.tt_order a  -- 订单主表
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join member.tc_member_info tmi on a.user_id = tmi.id and tmi.is_deleted <> 1  -- 会员表(获取会员信息)
	left join
		(
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
	where a.create_time >= '2021-11-25' and a.create_time <'2022-05-25'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	group by 1
	) f on f.ID =tmi.ID 
left join 
	(
	#半年内是否预约试驾
	select ta.one_id,if(ta.appointment_id<>0,'是','否') 预约试驾 -- if(g.预约试驾=是,'是','否')
	from cyx_appointment.tt_appointment ta 
	where ta.CREATED_AT >= '2021-11-25'
	and ta.CREATED_AT <'2022-05-25'
	and ta.IS_DELETED =0 -- 未删除
	group by 1
	)g on g.one_id=tmi.CUST_ID 
left join 
	(
	#上月会员日是否活跃
	select t.usertag,if(t.date<>0,'是','否') 上月会员日是否活跃 -- if(h.上月会员日是否活跃=是,'是','否')
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` <='2022-04-25 23:59:59' and t.`date`>='2022-04-25'  -- 上月会员日时间
	group by 1
	)h on tmi.USER_ID=h.usertag 
left join 
	(
	#上月会员日是否参与抽奖
	select 
	a.member_id,
	if(a.id<>0,'是','否') 上月会员日是否参与抽奖
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	where a.lottery_play_code = 'member_day_202203' -- 3月会员日抽奖活动入口
	)i on tmi.ID=i.member_id
left join 
	(
	#活动期间是否活跃
	select t.usertag,if(t.date<>0,'是','否') 活跃 -- if(h.上月会员日是否活跃=是,'是','否')
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` <='2022-05-25 23:59:59' and t.`date`>='2022-05-25'  -- 4月会员日时间
	group by 1
	)j1 on tmi.USER_ID=j1.usertag 
left join 
	(
	#活动参与1  是否参与抽奖
	select 
	a.member_id,
	if(a.id<>0,'是','否') 活动参与1
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	where a.lottery_play_code = 'member_day_202204' -- 4月会员日抽奖活动入口
	)j2 on tmi.ID=j2.member_id
left join 
	(
	#活动参与2  抽奖次数
	select 
	a.member_id,
	count(a.id) 活动参与2
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	where a.lottery_play_code = 'member_day_202204' -- 4月会员日抽奖活动入口
	group by 1
	)j3 on tmi.ID=j3.member_id
left join car_friends.car_friends_user cfu on tmi.ID =cfu.member_id  and cfu.is_deleted =0-- 车友会用户表,剔除退出车会友成员
left join 
	(
	select a.CUSTOMER_ID,a.车型
	from 
		(
		select tv.CUSTOMER_ID,
		tv.MODEL_NAME 车型,
		row_number() over(partition by tv.CUSTOMER_ID order by tv.update_time desc) rk
		from vehicle.tm_vehicle tv
		where tv.IS_DELETED =0
		) a
	where a.rk=1
	)o on tmi.CUST_ID =o.CUSTOMER_ID
where tmi.MEMBER_STATUS <> '60341003' and tmi.IS_DELETED = 0


-- 匹配5-12-1openid的手机号
select 
(eco.open_id) openid,
a.手机号
from 
	(
	select 
	m.ID 会员ID,
	m.MEMBER_PHONE 手机号,
	IFNULL(c.union_id,u.unionid) allunionid
	from `member`.tc_member_info m 
	left join customer.tm_customer_info c on c.id=m.cust_id
	left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid
	) a
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
group by 1



-- 会员日活动明细 （4月会员日ID关联）
select 
tmi.MEMBER_PHONE 手机号,
a.未使用V值 V值余额,
if(h1.4月会员日是否参与='是','是','否') 4月会员日是否参与
from `member`.tc_member_info tmi 
left join 
	(
	#截止活动开始前的V值余额  
	 select
	 f.MEMBER_ID,
	 m.MEMBER_V_NUM,
	 m.MEMBER_V_NUM-sum(case when f.create_time >= '2022-04-25' then 
	   case when f.RECORD_TYPE=1 then -f.INTEGRAL when f.RECORD_TYPE=0 then f.INTEGRAL else 0 end 
	   else 0 end) 未使用V值
	 from member.tt_member_flow_record f
	 join member.tc_member_info m on f.MEMBER_ID=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	 where f.IS_DELETED=0 
	 and f.EVENT_DESC <>'V值退回'
	 GROUP BY 1
	 order by 3
	) a on a.MEMBER_ID =tmi.ID
left join 
	(
	#4月会员日是否参与
	select t.usertag,if(t.date<>0,'是','否') 4月会员日是否参与 -- if(h.上月会员日是否活跃=是,'是','否')
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` <='2022-04-25 23:59:59' and t.`date`>='2022-04-25'  -- 上月会员日时间
	and json_extract(t.data,'$.embeddedpoint')='memberDay4_home_onload'
	group by 1
	)h1 on tmi.USER_ID=h1.usertag 
where tmi.MEMBER_STATUS <> '60341003' and tmi.IS_DELETED = 0
and LENGTH(tmi.MEMBER_PHONE)=11 
and LEFT(MEMBER_PHONE,1)='1'

-- 会员日活动明细 （5月会员日ID关联）
select 
tmi.MEMBER_PHONE 手机号,
a.未使用V值 V值余额,
if(h1.5月会员日是否参与='是','是','否') 5月会员日是否参与
from `member`.tc_member_info tmi 
left join 
	(
	#截止活动开始前的V值余额  
	 select
	 f.MEMBER_ID,
	 m.MEMBER_V_NUM,
	 m.MEMBER_V_NUM-sum(case when f.create_time >= '2022-05-25' then 
	   case when f.RECORD_TYPE=1 then -f.INTEGRAL when f.RECORD_TYPE=0 then f.INTEGRAL else 0 end 
	   else 0 end) 未使用V值
	 from member.tt_member_flow_record f
	 join member.tc_member_info m on f.MEMBER_ID=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	 where f.IS_DELETED=0 
	 and f.EVENT_DESC <>'V值退回'
	 GROUP BY 1
	 order by 3
	) a on a.MEMBER_ID =tmi.ID
left join 
	(
	#5月会员日是否参与
	select t.usertag,if(t.date<>0,'是','否') 5月会员日是否参与 -- if(h.上月会员日是否活跃=是,'是','否')
	from track.track t
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` <='2022-05-25 23:59:59' and t.`date`>='2022-05-25'  -- 上月会员日时间
	and json_extract(t.data,'$.embeddedpoint')='memberDay5_home_onload'
	group by 1
	)h1 on tmi.USER_ID=h1.usertag 
where tmi.MEMBER_STATUS <> '60341003' and tmi.IS_DELETED = 0
and LENGTH(tmi.MEMBER_PHONE)=11 
and LEFT(MEMBER_PHONE,1)='1'
