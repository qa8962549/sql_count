-- 	V值预计过期情况
select x.月份,
sum(x.过期量)
from 
	(
	select 
	'8月' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-08-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-08-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'9月' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-09-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-09-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'10月' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-10-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-10-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'11月' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-11-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-11-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'12月' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-12-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-12-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	GROUP BY 2 
	order by 3 desc
	) x 
group by 1 
order by 1 desc
