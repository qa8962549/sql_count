-- 筛选出最活跃的用户id
select 
x.oneid,
x.id memberid2
from 
(
select 
m.ID,
m.CUST_ID oneid,
m.user_id,
ROW_NUMBER ()over(PARTITION by m.CUST_ID order by t.`date` desc) rk 
from `member`.tc_member_info m
left join track.track t on cast(m.USER_ID as varchar)=t.usertag 
where m.IS_DELETED =0
and m.member_status<>60341003
-- and m.CUST_ID='6244384'
)x where x.rk=1

-- 
select m.CUST_ID oneid,
m.id
from (select m.CUST_ID,
	m.ID,
	ROW_NUMBER()over(PARTITION by m.CUST_ID order by m.CREATE_TIME desc) rk
	from `member`.tc_member_info m 
	-- where 
)m 
where m.rk=1
and m.CUST_ID in (
'13784020'
)

-- 人
select
tmi.ID "会员ID",
tmi.MEMBER_UPLEVTIME 升级黑卡时间,
x.tt 成长值数量,
if(x2.勋章名称 is not null,'是','否') 是否KOC,
x3.tt 近12个月获取推荐购V值奖励数量
from `member`.tc_member_info tmi 
left join (
	select a.member_id,
	sum(a.ADD_V_NUM) tt
	from member.tt_member_score_record a 
	where a.create_time>='2022-01-01'
	and a.create_time<'2023-01-01'
	and a.is_deleted=0
	and a.status=1
	group by 1
)x on x.member_id=tmi.id
left join 
(
select 
        c.user_id 会员ID,
        e.medal_name 勋章名称
        from mine.madal_detail c
        left join `member`.tc_member_info d on d.ID = c.user_id
        left join mine.user_medal e on e.id = c.medal_id
        left join `member`.tc_level f on f.LEVEL_CODE = d.MEMBER_LEVEL
        left join mine.my_medal_type g on e.`type` = g.union_code
        where 1=1
--         and c.create_time >= '2022-01-01'
--         and c.create_time <='2022-11-10'
        and c.deleted = 1  -- 有效
        and c.status = 1  -- 正常
        and e.medal_name ='特邀发言官'
        GROUP by 1,2 
)x2 on x2.会员ID=tmi.id
left join  
	(select a.member_id ,
	sum(a.reward_num )tt
	from invite.tm_invite_reward a
	where a.create_time >='2022-01-01'
	and a.create_time <'2023-01-01'
	and a.is_deleted =0
	group by 1
	)x3 on x3.member_id=tmi.id
where tmi.IS_DELETED =0 
and tmi.MEMBER_STATUS <>60341003
and tmi.MEMBER_LEVEL =5
order by 1


-- 车
select
tmi.ID "会员ID",
-- tmi.MEMBER_PHONE "手机号",
t.VIN,
tisd.invoice_date 开票时间,
tisd.dealer_code 经销商代码,
t.车型,
c1.region_name 车主城市
-- tmi.MEMBER_UPLEVTIME 升级黑卡时间,
-- x.tt 成长值数量,
-- x2.勋章名称 是否KOC
from `member`.tc_member_info tmi 
left join
(
 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
 from (
 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
 from member.tc_member_vehicle v 
 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
 where v.IS_DELETED=0 
 ) v 
 left join vehicle.tm_vehicle t on v.vin=t.VIN
 left join basic_data.tm_model m on t.MODEL_ID=m.ID
--  where v.rk=1
) t on tmi.id=t.member_id
left join dictionary.tc_code tc on tc.CODE_ID =tmi.MEMBER_SEX
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE = tr.REGION_CODE
left join vehicle.tt_invoice_statistics_dms tisd on t.VIN = tisd.vin 
left join (
 select a.member_id,c.city_name region_name,a.vin
 from (
  select v.member_id,ifnull(d.dealer_code,vv.dealer_code) dealer_code,vv.model_name,v.vin
  from (
    select v.MEMBER_ID,v.VIN
    ,row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
    from member.tc_member_vehicle v 
    where v.is_deleted=0 and v.MEMBER_ID is not null
  ) v
  left join vehicle.tm_vehicle vv on v.vin =vv.vin and vv.IS_DELETED=0
  left join vehicle.tt_invoice_statistics_dms d on v.vin=d.vin and d.IS_DELETED=0
  left join member.tc_member_info m  on v.member_id=m.id
--   where v.rk=1 -- 获取用户最后绑车记录
 ) a left join organization.tm_company c on c.company_code=a.dealer_code and c.COMPANY_TYPE=15061003
) c1 on c1.vin = t.vin
left join (
	select a.member_id,
	sum(a.ADD_V_NUM) tt
	from member.tt_member_score_record a 
	where a.create_time>='2022-01-01'
	and a.create_time<'2023-01-01'
	and a.is_deleted=0
	and a.status=1
	group by 1
)x on x.member_id=tmi.id
left join 
(
select 
        c.user_id 会员ID,
        e.medal_name 勋章名称
        from mine.madal_detail c
        left join `member`.tc_member_info d on d.ID = c.user_id
        left join mine.user_medal e on e.id = c.medal_id
        left join `member`.tc_level f on f.LEVEL_CODE = d.MEMBER_LEVEL
        left join mine.my_medal_type g on e.`type` = g.union_code
        where 1=1
--         and c.create_time >= '2022-01-01'
--         and c.create_time <='2022-11-10'
        and c.deleted = 1  -- 有效
        and c.status = 1  -- 正常
        and e.medal_name ='特邀发言官'
        GROUP by 1,2 
)x2 on x2.会员ID=tmi.id
where tmi.IS_DELETED =0 
and tmi.MEMBER_STATUS <>60341003
and tmi.MEMBER_LEVEL =5
order by 1


-- 购
select
tmi.ID "会员ID",
x.create_time,
x.reward_num
from `member`.tc_member_info tmi 
left join 
	(select a.member_id ,
	a.create_time ,
	a.reward_num 
	from invite.tm_invite_reward a
	where a.create_time >='2022-01-01'
	and a.create_time <'2023-01-01'
	and a.is_deleted =0)x 
	on x.member_id=tmi.id
where tmi.IS_DELETED =0 
and tmi.MEMBER_STATUS <>60341003
and tmi.MEMBER_LEVEL =5
and x.create_time is not NULL 
and x.reward_num<>60
order by 1

select a.member_id,
a.create_time,
a.v_price
from volvo_online_activity.recommend_buyv6_reward_record a
where 1=1
-- and a.create_time >='2022-01-01'
-- and a.create_time <'2023-01-01'
and a.v_price <>0
-- and reward_target_type=1
order by 2 desc



# 22Q4推荐购
-- 邀请人、被邀请人购车奖励
select
r.invite_member_id 邀请人会员ID,
r.invite_mobile 邀请人手机号,
r.be_invite_member_id 被邀请人会员ID,
r.be_invite_mobile 被邀请人手机号,
r.buy_expire_time 邀约购车到期时间,
r.reserve_time 留资时间,
r.order_no 订单号,
r.order_time 订单时间,
r.blue_invoice_time 蓝票开票时间,
r.is_large_set 是否大定订单,
r.reward_invite_num 邀约人购车奖励,
case when r.reward_status = 0 then '待审核'
	when r.reward_status = 1 then '已发放'
	when r.reward_status = 2 then '审核不通过'
	when r.reward_status = 3 then '发放失败'
	end 邀约人购车奖励状态,
r.reward_be_invite_num 被邀约人购车V值奖励,
case when r.reward_be_invite_num is not null and r.reward_status = 0 then '待审核'
	when r.reward_be_invite_num is not null and r.reward_status = 1 then '已发放'
	when r.reward_be_invite_num is not null and r.reward_status = 2 then '审核不通过'
	when r.reward_be_invite_num is not null and r.reward_status = 3 then '发放失败'
	end 被邀约人购车奖励状态,
r.create_time 留资时间,
r.is_bonus 额外奖励,
r.bonus 奖励V值量,
r.order_status 订单状态
from invite.tm_invite_record r
where r.order_status in ('14041008','14041003')   -- 有效订单
and r.create_time >= '2022-10-01'
and r.create_time < CURDATE()
and r.is_deleted = 0
and r.order_no is not null     -- 订单号不为空
and r.red_invoice_time is null     -- 红冲发票为空
and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
and r.order_time >= r.reserve_time and r.order_time <= r.buy_expire_time    -- 订单时间大于等于留资时间，且订单时间小于等于邀约购车截止时间
and ((r.is_large_set = 1 and r.payment_time is not null and r.payment_time >= r.reserve_time and r.payment_time <= r.buy_expire_time)       -- 如果是付大定订单，则付大定时间不为空，且付大定时间大于等于留资时间且付大定时间小于等于邀约购车截止时间
or (r.is_large_set = 2 and r.blue_invoice_time is not null and r.blue_invoice_time >= r.reserve_time and r.blue_invoice_time <= r.buy_expire_time))


