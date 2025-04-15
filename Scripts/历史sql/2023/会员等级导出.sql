-- 小程序各等级对应的会员数
selecth
tmi.ID,
tl.LEVEL_NAME 会员等级,
tmi.MEMBER_C_NUM 成长值
from `member`.tc_member_info tmi 
left join 
(select distinct tl.LEVEL_CODE,tl.LEVEL_NAME
from `member`.tc_level tl
where tl.LEVEL_CODE is not null) tl on tmi.LEVEL_ID = tl.LEVEL_CODE 
where tmi.MEMBER_STATUS <> '60341003'
and tmi.IS_DELETED = 0

-- 
select
-- tmi.ID,
tl.LEVEL_NAME 会员等级,
-- tmi.MEMBER_C_NUM 成长值,
count(1)
from `member`.tc_member_info tmi 
left join 
(select distinct tl.LEVEL_CODE,tl.LEVEL_NAME
from `member`.tc_level tl
where tl.LEVEL_CODE is not null) tl on tmi.LEVEL_ID = tl.LEVEL_CODE 
where tmi.MEMBER_STATUS <> '60341003'
and tmi.IS_DELETED = 0
group by 1
order by 1

