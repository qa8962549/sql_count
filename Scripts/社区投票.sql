-- 投票 帖子postid：zdMtPl5v8q
select 
tvr.object_no 帖子ID,
tp.object_name 帖子名称,
tvr.vote_user_id 用户ID,
tmi.MEMBER_NAME 昵称,
--tmi.MEMBER_PHONE 沃世界注册手机号,
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
and tvr.create_time >='2024-06-26'
and tvr.create_time <'2024-07-01'
and tvr.object_no in ('C2uWXBK7I3'
)
order by 1 


-- 投票选项对应id字符串
SELECT vote_title 投票标题,
    option ->> 'voteOption' AS voteOption,
    option ->> 'picUrl' AS picUrl,
    option ->> 'name' AS 投票名称
from  (SELECT json_array_elements(cast(tv.vote_detail as json) -> 'voteOptions') AS option 
		,tv.vote_title
     	FROM campaign.tm_vote tv) AS subquery;

