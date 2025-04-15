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
--			,to_char(x1.date,'YYYYMMDD')- x1.rank ddate
			,Date(x1.date)- (x1.rank * interval '1 day') ddate -- 连续登录的起始日期
			,x1.date
			from 
				(
				select x.id
				,x.date
				,row_number() over(PARTITION by x.id order by x.date) rank  
				from (	
					select member_id id,
					date(create_time) date
					from mine.sign_info i ) x
				)x1
			)x2 group by 1,2
		)x3 
--		where x3.id='6357837'
		group by 1,2
	)x4  where x4.drank is null -- 取最近一次连续登录的起始时间
	order by 2 desc 