-- 当前用户V值
select * from `member`.tc_member_info tmi where tmi.MEMBER_PHONE =18721762520

select 
tmi.ID,
tmi.MEMBER_V_NUM 当前剩余V值
from `member`.tc_member_info tmi
where tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0