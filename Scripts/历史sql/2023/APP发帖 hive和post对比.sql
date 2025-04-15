-- 此刻发帖明细 post
select 
distinct 
a.member_id 会员ID,
a.id 动态ID,
a.post_id ,
a.create_time 发帖日期,
a.post_digest 发帖内容,
--(length(a.post_digest)-CHAR_LENGTH(a.post_digest))/2 发帖字数,
LENGTH(regexp_replace(a.post_digest, '[^\u4e00-\u9fff]', '', 'g')) 发帖字数,
a.cover_images "发帖图片(链接)",
tmi.MEMBER_NAME 昵称,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tmi.REAL_NAME 姓名,
tmi.MEMBER_PHONE 沃世界注册手机号码,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主
from community.tm_post a
left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
where a.is_deleted =0
and a.create_time >='2023-05-25'
and a.create_time <'2023-05-31'
and bb.topic_id ='zvKCCcX2Yi'

-- 此刻发帖明细 hive
SELECT 
    DISTINCT 
    a.member_id AS `会员ID`,
    a.id AS `动态ID`,
    a.post_id,
    a.create_time AS `发帖日期`,
    a.post_digest AS `发帖内容`,
    LENGTH(REGEXP_REPLACE(a.post_digest, '[^\u4e00-\u9fff]', '')) AS `发帖字数`,
    a.cover_images AS `发帖图片(链接)`,
    tmi.member_name AS `昵称`,
    CASE 
        WHEN tmi.member_sex = '10021001' THEN '先生'
        WHEN tmi.member_sex = '10021002' THEN '女士'
        ELSE '未知'
    END AS `性别`,
    tmi.real_name AS `姓名`,
    tmi.member_phone AS `沃世界注册手机号码`,
    CASE 
        WHEN tmi.is_vehicle = '1' THEN '车主'
        WHEN tmi.is_vehicle = '0' THEN '粉丝'
    END AS `是否车主`
from ods_cmnt.ods_cmnt_tm_post_cur a
left join ods_cmnt.ods_cmnt_tr_topic_post_link_cur bb on a.post_id =bb.post_id 
left join ods_memb.ods_memb_tc_member_info_cur tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
WHERE 
    a.is_deleted = 0
    AND a.create_time >= '2023-05-25'
    AND a.create_time < '2023-05-31'
    AND bb.topic_id = 'zvKCCcX2Yi';


