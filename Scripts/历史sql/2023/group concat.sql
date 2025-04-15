select
a.MEMBER_ID,
GROUP_CONCAT(a.EVENT_DESC),
sum(a.ADD_V_NUM) 6月过期的V值所对应的事件发放的V值数,
sum(a.CONSUMPTION_INTEGRAL) 6月过期的V值所对应的事件累计消耗的V值数
-- ,sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值
from `member`.tt_member_score_record a
where a.IS_DELETED=0
and a.CREATE_TIME>='2020-05-01'
and a.CREATE_TIME <'2020-06-01'
and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL 
and a.MEMBER_ID is not null
GROUP BY 1 order by 4 desc