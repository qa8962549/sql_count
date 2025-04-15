-- APP会员月活数 
select 
--date_trunc('day',date) t,
count(distinct usr_merged_gio_id ) uv
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
where ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App')
and event_time>='2024-12-01'
and client_time >= '2024-12-01' -- App开始使用
and client_time < '2025-01-01'
and length(user)<9


--App绑车会员月活数
select count(distinct usr_merged_gio_id ) uv
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id)=toString(a.var_memberId) -- 2024年以后得数据可以用mmeberid关联
where ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App')
and event_time>='2024-12-01'
and client_time >= '2024-12-01' -- App开始使用
and client_time < '2025-01-01'
and length(user)<9
and m.is_vehicle =1


-- 社区活跃 yuhui
select count(DISTINCT a.user) as UV
from
(-- 合并GIO和神策
	select DISTINCT user,toDate(event_time) as t
	from ods_gio.ods_gio_event_d a
	where ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App')
	and event_time>='2024-12-01'
	and client_time >= '2024-12-01' -- App开始使用
	and client_time < '2025-01-01'
	and length(user)<9
	and (
	-- 社区浏览人数
	(event_key in ('Page_view','Page_entry') 
		and (var_page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or var_page_title like '%会员日%' or (var_activity_name like '2023%' and var_activity_id is null) or (var_activity_name like '2024%' and var_activity_id is null)) )
	-- 社区互动人数
	or (event_key='Button_click' and var_page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
		and var_btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') )
	)
union all 
	-- 发现 按钮点击（）7月开始
	select DISTINCT user,toDate(event_time) as t
	from ods_gio.ods_gio_event_d a
	join 
		(select m.distinct_id
		from (-- 清洗cust_id
			select toString(m.cust_id) `distinct_id` 
				,m.is_vehicle
				, row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status <> '60341003'
			and m.is_deleted = 0
			and m.is_vehicle =1 -- 车主
			) m
		where m.rk=1
		)x1 on x1.distinct_id=a.user
	where 1=1
	and event_time>='2024-12-01'
--	AND (event='$view_click'and `$text_value`='发现') -- PV
	and ((event_key='Button_click' and var_btn_name='发现' ) or (event_key='$AppClick' and var_sa_element_content='发现' ) or (event_key='$view_click' and `$text_value` ='发现' )) -- UV
	and client_time >= '2024-12-01' -- App开始使用
	and client_time < '2025-01-01'
	and length(user)<9 
)a
--group by t 
--order by t	

 
---------------------------------------------------------------------

--社区 MAU   社区互动浏览人数,不累计，算单月
select 
--date_trunc('day',date) t,
count(distinct usr_merged_gio_id)
from 
	(
	select usr_merged_gio_id,date
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where event in ('Page_view','Page_entry') 
	and ((`$lib` in('iOS','Android','HarmonyOS') and left($client_version,1)='5') or channel ='App')
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') 
		or page_title like '%会员日%' 
		or (var_activity_name like '2023%' and var_activity_id is null)
		or (var_activity_name like '2024%' and var_activity_id is null)
		)
	and date >= '2024-12-01' 
	and date<'2025-01-01' 
	and length(distinct_id)<9 
	union all 
	-- 社区互动人数
	select usr_merged_gio_id,date
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where event='Button_click' 
	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')
	and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
	and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
	and date >= '2024-12-01' 
	and date<'2025-01-01' 
	and length(distinct_id)<9 
	union all 
	-- 发现 按钮点击（车主）7月开始
	select usr_merged_gio_id,date
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
	where 1=1
	and event='Button_click' 
	and btn_name='发现'
	and (var_is_bind='1' or var_is_bind='true')
	and date >= '2024-12-01' 
	and date<'2025-01-01' 
	and length(distinct_id)<9 
) t 
--group by t 
--order by t




	select DISTINCT distinct_id,toDate(`date`) as t
	from dwd_23.dwd_23_gio_tracking a
	join 
		(select m.distinct_id
		from (-- 清洗cust_id
			select toString(m.cust_id) `distinct_id` 
				,m.is_vehicle
				, row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status <> '60341003'
			and m.is_deleted = 0
			and m.is_vehicle =1 -- 车主
			) m
		where m.rk=1
		)x1 on x1.distinct_id=a.distinct_id
	where 1=1
	and event_time>='2024-12-01'
	and ((event='Button_click' and btn_name='发现' )
		or (event='$AppClick' and var_sa_element_content='发现' ))
--	AND event='$view click'and $text value='发现')
	and date >='2024-12-01' 
	and date<'2025-01-01' 
	and length(distinct_id)<9 