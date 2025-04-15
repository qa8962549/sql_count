# V值月报
select
a.V值事件,
a.累计发放V值数,
a.累计发放用户数,
a.消耗量 消耗量,
a.消耗用户数 消耗用户数,
ROUND(a.消耗量/a.累计发放V值数,2)消耗占比,
ROUND(a.消耗用户数/a.累计发放用户数,2)消耗用户数占比,
ifnull(b.过期量,0),
ifnull(b.过期用户数,0)
from
	(
	-- V值侧当前实际发放和消耗
	select r.EVENT_DESC V值事件
	,sum(r.ADD_V_NUM) 累计发放V值数
	,count(DISTINCT r.MEMBER_ID) 累计发放用户数
	,sum(r.CONSUMPTION_INTEGRAL) 消耗量
	,count(DISTINCT case when r.CONSUMPTION_INTEGRAL > 0 then r.MEMBER_ID else null end) 消耗用户数
	from member.tt_member_score_record r
	where -- r.create_time < '2022-03-01'
	r.ADD_V_NUM > 0
	and r.IS_DELETED = 0 
	and r.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 1 order by 2 desc
	)a
left join
(
-- 过期V值（当前月的前一个月获取未使用的V值）
select x.过期v值事件 过期v值事件,
sum(x.过期量) 过期量,
sum(x.过期用户数) 过期用户数
from 
	(
	select 
	'1',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-07-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-07-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.EVENT_TYPE <> 60731025   -- V值退回
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'2',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-06-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-06-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'3',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-05-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-05-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'4',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-04-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-04-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'5',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-03-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-03-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'6',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-02-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-02-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'7',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-01-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-01-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'8',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-12-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-12-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'9',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-12-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-12-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'10',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-11-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-11-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'11',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-10-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-10-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'12',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-9-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-9-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'13',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-08-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-08-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'14',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-07-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-07-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'15',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-06-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-06-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	)x 
	group by 1
	order by 2 desc 
)b
on a.V值事件 = b.过期V值事件
order by 2 desc 

-- V值侧当前实际发放和消耗
select r.EVENT_DESC V值事件
,sum(r.ADD_V_NUM) 累计发放V值数
,count(DISTINCT r.MEMBER_ID) 累计发放用户数
,sum(r.CONSUMPTION_INTEGRAL) 消耗量
,count(DISTINCT case when r.CONSUMPTION_INTEGRAL > 0 then r.MEMBER_ID else null end) 消耗用户数
from member.tt_member_score_record r
where -- r.create_time < '2022-03-01'
r.ADD_V_NUM > 0
and r.IS_DELETED = 0 
and r.EVENT_TYPE <> 60731025   -- V值退回
GROUP BY 1 order by 2 desc
