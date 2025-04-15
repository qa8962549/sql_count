rename table ods_oper_crm.level_lzc to ods_oper_crm.level_lzc_20240201

CREATE TABLE ods_oper_crm.level_lzc_20230201
(
    `id` Int32,
    `会员等级` String,
    `成长值` Int32
)
--ENGINE = Log;
ENGINE = ReplicatedMergeTree
ORDER BY id  -- 根据主键排序
SETTINGS index_granularity = 8192;

CREATE TABLE ods_oper_crm.level_lzc_20230801
(
    `id` Int32,
    `会员等级` String,
    `成长值` Int32
)
--ENGINE = Log;
ENGINE = ReplicatedMergeTree
ORDER BY id  -- 根据主键排序
SETTINGS index_granularity = 8192;

CREATE TABLE ods_oper_crm.level_lzc_20240101
(
    `id` Int32,
    `会员等级` String,
    `成长值` Int32
)
--ENGINE = Log;
ENGINE = ReplicatedMergeTree
ORDER BY id  -- 根据主键排序
SETTINGS index_granularity = 8192;

CREATE TABLE ods_oper_crm.level_lzc_20240201
(
    `id` Int32,
    `会员等级` String,
    `成长值` Int32
)
--ENGINE = Log;
ENGINE = ReplicatedMergeTree
ORDER BY id  -- 根据主键排序
SETTINGS index_granularity = 8192;



--当前有效成长值
	select r.member_id
	,m.member_c_num  
	,m.level_id 
	,sum(r.add_c_num) as total_c_num
	from ods_memb.ods_memb_tt_member_score_record_cur r
	left join ods_memb.ods_memb_tc_member_info_cur m on r.member_id =m.id
	where r.status = 1  -- 状态：1 有效 0 无效
	and r.is_deleted = 0 
	and r.add_c_num > 0
	and is_back = 0 
	and toDate(r.create_time) >today() + interval '-12 month'
--	and r.r.member_id ='5798431'
	group by r.member_id,m.member_c_num ,m.level_id 
	

--当前有效成长值
	select r.member_id
	,m.member_c_num  
	,m.level_id 
	,sum(r.add_c_num) as total_c_num
	from "member".tt_member_score_record r
	left join member.tc_member_info m on r.member_id =m.id
	where r.status = 1  -- 状态：1 有效 0 无效
	and r.is_deleted = 0 
	and r.add_c_num > 0
	and is_back = 0 
	and r.create_time >curdate() + interval '-18 month'
--	and r.r.member_id ='5798431'
	group by r.member_id,m.member_c_num ,m.level_id 

--成长值——等级变化	
	select m.id
	,m.level_id 
	,m.member_c_num 累计成长值  -- 
	,ifnull(r1.当前有效成长值,0) 当前有效成长值
	,ifnull(r2.半年前有效成长值,0) 半年前有效成长值
	,ifnull(r3.一年前有效成长值,0) 一年前有效成长值
	,c.old_level_id 
	,c.new_level_id 
	,c.event_desc
	,c.create_time 
	from member.tc_member_info m
	left join (
--	当前有效成长值
		select r.member_id
		,sum(r.add_c_num) 当前有效成长值
		from "member".tt_member_score_record r
		where 1=1
--		and r.status = 1  -- 状态：1 有效 0 无效
		and r.is_deleted = 0 
		and r.add_c_num > 0
		and is_back = 0 
--		and r.create_time <curdate() + interval '-6 month'
		and r.create_time >curdate() + interval '-12 month'
		group by 1
		)r1 on r1.member_id=m.id
	left join 	(
--	半年前有效成长值
		select r.member_id
		,sum(r.add_c_num) 半年前有效成长值
		from "member".tt_member_score_record r
		where 1=1
--		and r.status = 1  -- 状态：1 有效 0 无效
		and r.is_deleted = 0 
		and r.add_c_num > 0
		and is_back = 0 
		and r.create_time <curdate() + interval '-6 month'
		and r.create_time >curdate() + interval '-18 month'
		group by 1
		)r2 on r2.member_id =m.id
	left join (
--	1年前有效成长值
		select r.member_id
		,sum(r.add_c_num) 一年前有效成长值
		from "member".tt_member_score_record r
		where 1=1
--		and r.status = 1  -- 状态：1 有效 0 无效
		and r.is_deleted = 0 
		and r.add_c_num > 0
		and is_back = 0 
		and r.create_time <curdate() + interval '-12 month'
		and r.create_time >curdate() + interval '-24 month'
		group by 1
		)r3 on r3.member_id=m.id
	left join member.tt_member_level_change c on c.member_id =m.id
	where c.status=1
	and c.create_time is not null 
--	and c.event_desc='等级降级'
	and m.id='3132572'
	order by create_time desc 

	
select *
from ods_oper_crm.level_lzc_20230801 l1
join ods_oper_crm.level_lzc_20240201 l2 on l1.id =l2.id 
where l1.`会员等级` <>l2.`会员等级`
	
select l1.id 
	,l1.`会员等级` 
	,l2.id
	,l2.`会员等级` 
	,c.OLD_LEVEL_ID 
	,c.NEW_LEVEL_ID 
	,c.EVENT_DESC
	,c.CREATE_TIME 
from ods_oper_crm.level_lzc_20230801 l1
join ods_oper_crm.level_lzc_20240201 l2 on l1.id =l2.id 
join ods_memb.ods_memb_tt_member_level_change_d c on c.MEMBER_ID =l1.id
where l1.`会员等级` <>l2.`会员等级`
and c.LEVEL_TYPE is not null 
and c.STATUS =1
and c.IS_DELETED =0
and l1.id='3301769'
--and c.EVENT_DESC='等级降级'
and c.EVENT_DESC in ('等级降级','等级升级')
--and c.CREATE_TIME>='2023-07-02 14:57:00'
--and c.CREATE_TIME<='2023-07-11 11:30:00'
order by c.CREATE_TIME 

select MEMBER_ID 
,c.OLD_LEVEL_ID 
	,c.NEW_LEVEL_ID 
	,c.EVENT_DESC
	,c.CREATE_TIME 
from ods_memb.ods_memb_tt_member_level_change_d c
where 1=1
and c.LEVEL_TYPE is not null 
and c.STATUS =1
and c.IS_DELETED =0
and MEMBER_ID='3301769'
and c.EVENT_DESC in ('等级降级','等级升级')
--and c.CREATE_TIME>='2023-07-06'
--and c.CREATE_TIME<='2023-07-11'





