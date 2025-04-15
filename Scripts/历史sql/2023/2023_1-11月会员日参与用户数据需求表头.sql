	--历史累计从App参与会员日活动次数
	select 
	distinct
	distinct_id,
	m.id,
	m.member_name,
	groupUniqArray(page_title) `2023年参与会员日活动时间`,
	count(distinct concat(distinct_id,page_title)) `2023年参与会员日活动总次数`,
	groupUniqArray(channel)`参与渠道`
	from ods_rawd.ods_rawd_events_d_di a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)  
	where 1=1
	and event='Page_view'
	and (page_title like '%会员日' OR page_title = '525车主节') -- 2023年5月的会员日叫作车主节
	and page_title<>'12月会员日'  -- 2022年12月会员日 会通过其他渠道进入产生脏数据
	and page_title not like '%WOW%'
--	and year(date)='2023'
--	and day(date)='25'
	and date>='2023-01-01'
	and ((a.`$lib` in('iOS','Android') or a.channel ='App') or ($lib='MiniProgram' or channel='Mini'))
	and length(distinct_id)<9
	group by distinct_id,m.id,m.member_name
	order by `2023年参与会员日活动总次数` desc 
	
	--历史累计从App参与会员日活动次数 test
	select 
	distinct 
	distinct_id,
	page_title,
	date
	from ods_rawd.ods_rawd_events_d_di a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)  
	where 1=1
	and event='Page_view'
--	and (page_title like '%会员日' OR page_title = '525车主节')
--	and page_title<>'12月会员日'
--	and page_title not like '%WOW%'
	and year(date)='2023'
	and day(date)='25'
	and ((a.`$lib` in('iOS','Android') or a.channel ='App') or ($lib='MiniProgram' or channel='Mini'))
	and length(distinct_id)<9
	and page_title='12月会员日'