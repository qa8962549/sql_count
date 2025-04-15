-- 1、累计签到200天及以上，且从未中过奖；
-- 2、累计签到天数降序排列，前500名；
-- 3、使用过补签卡的人群，累计签到天数降序排列，前400名；
-- 4、连续签到100天及以上人群；
-- 
-- 手机号、memberid、oneid
-- 4个人群合并后统一去重


### 累计签到200天及以上，且从未中过奖；
select 
a.手机号,
a.会员ID,
a.oneid,
a.签到天数 累计签到天数
from (
#累计签到天数
	select 
	m.MEMBER_PHONE 手机号,
	m.id 会员ID,
	m.CUST_ID oneid,
	count(DISTINCT f.day_int) 签到天数
	from mine.sign_info f 
	join member.tc_member_info m on f.member_id=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003 
	-- and m.IS_VEHICLE=0
	where f.create_time <= '2022-09-06 23:59:59'
	and LENGTH (m.MEMBER_PHONE)=11 and left(m.MEMBER_PHONE,1)='1'
	GROUP BY 1
	order by 4 desc 
) a 
where a.会员ID not in (
# 一级奖池中奖名单
select DISTINCT l.member_id
from mine.sign_lottery_log l 
where l.lottery_play_code='signLv1' and l.have_win=1
and l.create_time <= '2022-09-06 23:59:59'
and l.member_id is not null 
) and a.签到天数>=200
order by 1 desc 

### 累计签到天数降序排列，前500名；
select 
m.MEMBER_PHONE 手机号,
m.id 会员ID,
m.CUST_ID oneid,
count(DISTINCT f.day_int) 签到天数
from mine.sign_info f 
join member.tc_member_info m on f.member_id=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003 
-- and m.IS_VEHICLE=0
where f.create_time <= '2022-09-06 23:59:59'
and LENGTH (m.MEMBER_PHONE)=11 and left(m.MEMBER_PHONE,1)='1'
GROUP BY 1
order by 4 desc 
limit 500 


### 使用过补签卡的人群，累计签到天数降序排列，前400名；
select 
m.MEMBER_PHONE 手机号,
m.id 会员ID,
m.CUST_ID oneid,
count(DISTINCT f.day_int) 签到天数
from mine.sign_info f 
join member.tc_member_info m on f.member_id=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003 
left join 
	(select x.member_id,if(x.使用数>=1,'是','否') 是否使用补签卡
	from 
		(
		select i.member_id
		-- ,count(case when i.`status`=0 then 1 else null end ) 未使用数
		,count(case when i.`status`=1 then 1 else null end) 使用数
		,count(case when i.`status`=0 then 1 else null end) 未使用数
		from mine.sign_comple_sign_card_info i
		left join member.tc_member_info m on i.member_id=m.ID
		where i.create_time BETWEEN '2022-06-01' and '2022-09-06 23:59:59'
		-- and i.`status`=1
		GROUP BY 1 
		order by 1 desc
		)x 
	group by 1
	) x on x.member_id=f.member_id and x.是否使用补签卡='是'
-- and m.IS_VEHICLE=0
where f.create_time <= '2022-09-06 23:59:59'
and LENGTH (m.MEMBER_PHONE)=11 and left(m.MEMBER_PHONE,1)='1'
GROUP BY 2
order by 4 desc 
limit 400 

###连续签到100天及以上人数
select 
m.MEMBER_PHONE 手机号,
m.id 会员ID,
m.CUST_ID oneid
from (
select d.member_id,max(d.次数) 连续签到次数
	from (
	select c.member_id,c.最早登录时间,count(1) 次数
	from (
		select b.member_id,b.日期,DATE_SUB(b.日期,b.rank) 最早登录时间
		from (
			# 日期降序排序
			select a.MEMBER_ID
			,a.`日期`
			,row_number() over(PARTITION by a.MEMBER_ID order by a.`日期` ) rank
			from (
			select DISTINCT i.MEMBER_ID,DATE(i.CREATE_TIME) 日期
			from mine.sign_info i 
			join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
			where i.is_delete=0 and i.create_time <= '2022-09-06 23:59:59'
			) a 
		) b
	) c GROUP BY 1,2 order by 3 desc 
) d GROUP BY 1 HAVING max(d.次数)>=100 order by 2 desc 
) a 
left join member.tc_member_info m on a.member_id=m.id
where LENGTH (m.MEMBER_PHONE)=11 and left(m.MEMBER_PHONE,1)='1'
