-- 小程序登录次数
select count(1)
from track.track t 
left join `member`.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
where t.typeid ='XWSJXCX_START'
and t.`date` <'2023-04-07'
and t.`date` >='2023-01-01'

-- 小程序登录次数（活跃人数）
select count(distinct m.ID)
from track.track t 
left join `member`.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
where t.typeid ='XWSJXCX_START'
and t.`date` <'2021-01-01'
and t.`date` >='2020-01-01'

-- 小程序登录次数 手机号明细
select distinct m.ID
,m.MEMBER_PHONE 
from track.track t 
left join `member`.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
where t.typeid ='XWSJXCX_START'
and t.`date` <'2021-01-01'
and t.`date` >='2020-01-01'
and m.id is not null 
and m.MEMBER_PHONE is not null 
and m.MEMBER_PHONE <>'*'

-- 用户匹配APP手机号
select distinct m.ID
,m.MEMBER_PHONE 
from track.track t 
left join `member`.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
where 1=1
-- and t.typeid ='XWSJXCX_START'
-- and t.`date` <'2021-01-01'
-- and t.`date` >='2020-01-01'
and m.id is not null 
and m.MEMBER_PHONE is not null 
and m.MEMBER_PHONE <>'*'

-- 小程序
select m.IS_VEHICLE,count(1)
from `member`.tc_member_info m 
where 1=1
and m.is_deleted = 0 and m.member_status <> '60341003'
and m.CREATE_TIME  <'2021-01-01'
-- and m.CREATE_TIME >='2020-01-01'
group by 1