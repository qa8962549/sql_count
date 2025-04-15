-- 1、小程序各等级对应的会员数
select tl.LEVEL_NAME ,COUNT(tmi.ID)会员用户数
from `member`.tc_member_info tmi
left join 
(select distinct tl.LEVEL_CODE,tl.LEVEL_NAME
from `member`.tc_level tl
where tl.LEVEL_CODE is not null ) tl on tmi.LEVEL_ID = tl.LEVEL_CODE 
where tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
and tmi.CREATE_TIME < '2022-05-01'
group by tl.LEVEL_NAME
order by tl.LEVEL_CODE


-- 2、小程序各等级对应的车主会员数
select
tl.LEVEL_NAME,COUNT(tmi.ID)车主用户数
from `member`.tc_member_info tmi 
left join 
(select distinct tl.LEVEL_CODE,tl.LEVEL_NAME
from `member`.tc_level tl
where tl.LEVEL_CODE is not null ) tl on tmi.LEVEL_ID = tl.LEVEL_CODE 
where DATE_FORMAT(tmi.create_time,'%Y-%m-%d') < '2022-05-01'
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
and tmi.IS_VEHICLE = 1  -- 车主
group by tl.LEVEL_NAME
order by tl.LEVEL_CODE