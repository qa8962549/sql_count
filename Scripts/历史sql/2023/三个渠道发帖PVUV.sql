-- 帖子的PVUV
	select a.post_id,
	a.read_count `PV(tm_post)`,
	x.PV as `PV(tt_view_post)`,
	x.UV as `UV(tt_view_post)`,
	x2.PV as `PV(神策)`,
	x2.UV as `UV(神策)`
	from ods_cmnt.ods_cmnt_tm_post_cur a
	global left join 
		(-- 帖子的PVUV tt_view_post
		select 
		a.post_id ,
		count(a.member_id) PV,
		count(DISTINCT a.member_id) UV
		from ods_cmnt.ods_cmnt_tt_view_post_cur a
		where 1=1
		and a.create_time >='2023-01-01'
--		and a.create_time <'2023-10-31'
		and a.is_deleted =0
		group by post_id)x on x.post_id=a.post_id 
	left join 
		(
	    select content_id,
	    count(user_id) PV,
		count(distinct user_id) UV
		from ods_rawd_events_d_di
		where content_id is not null
		and event='Page_entry'
		and page_title='内容详情'  
		and date>='2023-01-01'
		group by content_id
		) x2 on toString(x2.content_id) =toString(a.post_id) 
	where 1=1
	and a.create_time >='2023-01-01'
	and a.is_deleted =0
--	and a.post_id='3rMNHdq6KF'
order by a.read_count desc 
