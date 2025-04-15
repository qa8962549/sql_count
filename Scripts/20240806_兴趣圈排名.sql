113337913798

--兴趣圈活动数据
	select 
	distinct 
	m.member_name,
	f.member_id ,
	m.member_phone ,
	ca.content `兴趣圈名称`,
	ca2.content `已加入兴趣圈名称`
	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cocl.ods_cocl_tr_coterie_friends_d f on o.coterie_id =f.coterie_id 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on m.id::String  =f.member_id ::String
	left join ods_cocl.ods_cocl_tr_coterie_friends_d f2 on f.member_id =f2.member_id -- 已加入兴趣圈
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca2 on f2.coterie_id =ca2.coterie_id 
	where 1=1
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and ca2.attr_type = 10010  -- 筛选兴趣圈
	and ca2.is_deleted =0
	and ca.is_deleted =0 
	and o.is_deleted =0
	and f.is_deleted=0
	and o.coterie_id in ('COTERIE_5Wu8JTdr9m',
'COTERIE_BFq6TQIiUZ',
'COTERIE_BQakNOsRZq',
'COTERIE_BXw3PTH0uw',
'COTERIE_WFAJi2HOok',
'COTERIE_foMJ9pb00h',
'COTERIE_o1chB7Hh0w',
'COTERIE_pR4CUBwEEV',
'COTERIE_rJuA2oQFOJ',
'COTERIE_zreiBhWJMA')
	order by 2 desc 
	
-- 
	select 
	distinct 
	ca.content `兴趣圈名称`,
	f.member_id ,
	m.member_name,
	f.join_time `加入兴趣圈时间`
	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cocl.ods_cocl_tr_coterie_friends_d f on o.coterie_id =f.coterie_id 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on m.id::String  =f.member_id ::String
	where 1=1
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and ca.is_deleted =0 
	and o.is_deleted =0
	and f.is_deleted=0
	and o.coterie_id in (
	'COTERIE_zreiBhWJMA',
	'COTERIE_KvQnzKCuBP',
	'COTERIE_5Wu8JTdr9m')
	order by 2 
	
	
	select 
	distinct 
	ca.content `兴趣圈名称`,
o.coterie_id
	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cocl.ods_cocl_tr_coterie_friends_d f on o.coterie_id =f.coterie_id 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
	left join ods_memb.ods_memb_tc_member_info_cur m on m.id::String  =f.member_id ::String
	where 1=1
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and ca.is_deleted =0 
	and o.is_deleted =0
	and f.is_deleted=0
	and ca.content in ('NCampingLife',
'别赶路 去感受路',
'周末旅行家',
'VOC水上运动圈',
'教师圈',
'WO家食堂',
'有蓬自远方来',
'医师圈',
'沃尔沃骑行Club',
'沃的跑友圈')
	order by 2 