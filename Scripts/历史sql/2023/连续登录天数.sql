-- 每个用户历史上最大连续登录天数
select x3.id
,max(x3.num) -- 最大连续登录天数
from 
	(
	select x2.id
	,x2.ddate
	,count(1) num
	from 
	(
	select x1.id
	,x1.date
	,toDate(toDate(x1.date)-toDate(x1.rank)) ddate
	from 
		(
		select x.id
		,x.date
		,row_number()over(PARTITION by x.id order by toDate(x.date)) rank
		from (
		  -- 对用户登录日期进行去重
			select distinct id
			,date
			from login 
			) x
		)x1
	)x2 group by 1,2
)x3 group by 1
order by 1 

-- 每个用户近期（截至昨天）连续登录天数 lag() lead()
select x4.id,
x4.num  -- 最近一次连续登录天数
from 
	(
	select x3.id
	,x3.ddate -- 连续登录的起始日期
	,x3.num -- 连续登录天数
	,lag(x3.ddate,1) over(PARTITION by x3.id order by x3.ddate desc) drank 
	from 
		(
		select x2.id
		,x2.ddate -- 连续登录的起始日期
		,count(1) num -- 连续登录天数
		from 
			(
			select x1.id
			,toDate(toDate(x1.date)-toDate(x1.rank)) ddate -- 连续登录的起始日期
			,x1.date
			from 
				(
				select x.id
				,x.date
				,row_number() over(PARTITION by x.id order by toDate(x.date)) rank  
				from (
				  -- 对用户登录日期进行去重
					select distinct id
					,date
					from login 
					where toDate(date)<now()
					) x
				)x1
			)x2 group by 1,2
		)x2 group by 1,2
		)x3 
)x4 where x4.drank is null -- 取最近一次连续登录的起始时间

-- 每个用户近期（截至昨天）连续登录天数
select x4.id,
--x4.ddate, -- 最近一次连续登录起始日期
x4.num  -- 最近一次连续登录天数
from 
	(
	select x3.id
	,x3.ddate -- 连续登录的起始日期
	,x3.num -- 连续登录天数
	,row_number() over(PARTITION by x3.id order by x3.ddate desc) drank -- 对登录起始起始排序，取最近一次
	from 
		(
		select x2.id
		,x2.ddate -- 连续登录的起始日期
		,count(1) num -- 连续登录天数
		from 
			(
			select x1.id
			,toDate(toDate(x1.date)-toDate(x1.rank)) ddate -- 连续登录的起始日期
			,x1.date
			from 
				(
				select x.id
				,x.date
				,row_number() over(PARTITION by x.id order by toDate(x.date)) rank  
				from (
				  -- 对用户登录日期进行去重
					select distinct id
					,date
					from login 
					where toDate(date)<now()
					) x
				)x1
			)x2 group by 1,2
		)x3 
)x4 where x4.drank=1 -- 取最近一次连续登录的起始时间

-- 每个用户近期（截至昨天）连续登录天数 lag() lead()
select x4.id,
x4.num  -- 最近一次连续登录天数
from 
	(
	select x3.id
	,x3.ddate -- 连续登录的起始日期
	,x3.num -- 连续登录天数
	,lag(x3.ddate,1) over(PARTITION by x3.id order by x3.ddate desc) drank 
	from 
		(
		select x2.id
		,x2.ddate -- 连续登录的起始日期
		,count(1) num -- 连续登录天数
		from 
			(
			select x1.id
			,toDate(toDate(x1.date)-toDate(x1.rank)) ddate -- 连续登录的起始日期
			,x1.date
			from 
				(
				select x.id
				,x.date
				,row_number() over(PARTITION by x.id order by toDate(x.date)) rank  
				from (
				  -- 对用户登录日期进行去重
					select distinct id
					,date
					from login 
					where toDate(date)<now()
					) x
				)x1
			)x2 group by 1,2
		)x2 group by 1,2
		)x3 
)x4 where x4.drank is null -- 取最近一次连续登录的起始时间

DELETE ods_oper_crm.login 

-- 创建本地表  
CREATE TABLE ods_oper_crm.login 
(
    `id` String,
    `date` String
)
ENGINE = ReplicatedMergeTree
ORDER BY id  -- 根据主键排序
SETTINGS index_granularity = 8192;

