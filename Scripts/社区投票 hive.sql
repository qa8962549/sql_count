


-- 投票 帖子PGSQL
select 
tvr.object_no 帖子ID,
tp.object_name 帖子名称,
tvr.vote_user_id 用户ID,
tmi.MEMBER_NAME 昵称,
tmi.MEMBER_PHONE 沃世界注册手机号,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
tv.vote_title 投票标题,
x.投票名称,
tvr.create_time 投票时间
from campaign.tr_vote_record tvr
left join `member`.tc_member_info tmi on tmi.id =tvr.vote_user_id and tmi.IS_DELETED =0 -- 投票记录表
left join campaign.tr_vote_bind_info tp on tvr.object_no =tp.object_no and tp.is_deleted =0 -- 投票编号映射活动id表  找到活动对应的投票组件id
left join campaign.tm_vote tv on tp.vote_no =tv.vote_no and tv.is_deleted =0-- 投票编号对应投票标题
left join 
	(SELECT vote_title 投票标题,
    option ->> 'voteOption' AS voteOption,
    option ->> 'picUrl' AS picUrl,
    option ->> 'name' AS 投票名称
	from (SELECT json_array_elements(cast(tv.vote_detail as json) -> 'voteOptions') AS option 
		,tv.vote_title
     	FROM campaign.tm_vote tv) AS subquery)x on tvr.vote_option =x.voteOption
where tvr.is_deleted =0
and tvr.create_time >='2023-06-20'
and tvr.create_time <'2023-06-23'
and tvr.object_no ='X3qE9oMcTx'
and tvr.vote_user_id in ('3829183',
'4213375',
'5597369',
'7112528',
'7195725'
)

-- 投票 帖子hive
SELECT
    tvr.object_no `帖子ID`,
    tp.object_name`帖子名称`,
    tvr.vote_user_id `用户ID`,
    tmi.MEMBER_NAME `昵称`,
    tmi.MEMBER_PHONE `沃世界注册手机号`,
    CASE WHEN tmi.IS_VEHICLE = '1' THEN '车主' 
         WHEN tmi.IS_VEHICLE = '0' THEN '粉丝' 
    END `是否车主`,
    tv.vote_title `投票标题`,
    x.NA `投票名称`,
    tvr.create_time `投票时间`
FROM ods_camp.ods_camp_tr_vote_record_cur tvr
LEFT JOIN ods_memb.ods_memb_tc_member_info_cur tmi ON tmi.id = tvr.vote_user_id AND tmi.IS_DELETED = 0
LEFT JOIN ods_camp.ods_camp_tr_vote_bind_info_cur tp ON tvr.object_no = tp.object_no AND tp.is_deleted = 0
LEFT JOIN ods_camp.ods_camp_tm_vote_cur tv ON tp.vote_no = tv.vote_no AND tv.is_deleted = 0
LEFT JOIN (	
	SELECT 
	tv.vote_title `投票标题`,
--	option,
	VOTE,
	NA
	FROM ods_camp.ods_camp_tm_vote_cur tv
	LATERAL VIEW explode(split(regexp_replace(regexp_extract(get_json_object(vote_detail,'$.voteOptions'),'^\\[(.+)\\]$',1),'\\}\\,\\{', '\\}\\|\\|\\{'),'\\|\\|')) t AS option -- 是炸裂函数
	LATERAL VIEW json_tuple(t.option,'voteOption','name') xx as VOTE,NA) x ON tvr.vote_option = x.VOTE
WHERE tvr.is_deleted = 0
and tvr.create_time >='2023-06-20'
and tvr.create_time <'2023-06-23'
AND tvr.object_no = 'X3qE9oMcTx'
and tvr.vote_user_id in ('3829183',
'4213375',
'5597369',
'7112528',
'7195725'
)


-- 拆分string字符串
	SELECT 
	tv.vote_title `投票标题`,
	option,
	VOTE,
	NA
	FROM ods_camp.ods_camp_tm_vote_cur tv
	LATERAL VIEW explode(split(regexp_replace(regexp_extract(get_json_object(vote_detail,'$.voteOptions'),'^\\[(.+)\\]$',1),'\\}\\,\\{', '\\}\\|\\|\\{'),'\\|\\|')) t AS option -- 是炸裂函数
	LATERAL VIEW json_tuple(t.option,'voteOption','name') xx as VOTE,NA

-- 时间格式
select DATE_FORMAT(tmi.create_time,'Y-M')
from ods_memb.ods_memb_tc_member_info_cur tmi
where tmi.create_time>'2023-01-01'






