USE tmp_crm;

CREATE TABLE test_lzc (
  `姓名` STRING,
  `年龄` INT,
  `学历` STRING
);


-- 创建名为 test2 的新表，确保表结构与查询结果的列结构匹配

-- 执行查询并将结果保存到临时表 tmp_result
CREATE TABLE tmp_result AS
SELECT 
    DISTINCT 
    a.member_id AS `会员ID`,
    a.id AS `动态ID`,
    a.post_id,
    CAST(a.create_time AS TIMESTAMP) AS `发帖日期`,
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
FROM ods_cmnt.ods_cmnt_tm_post_cur a
LEFT JOIN ods_cmnt.ods_cmnt_tr_topic_post_link_cur bb ON a.post_id = bb.post_id 
LEFT JOIN ods_memb.ods_memb_tc_member_info_cur tmi ON a.member_id = tmi.id AND tmi.IS_DELETED = 0
WHERE 
    a.is_deleted = 0
    AND a.create_time >= '2023-05-25'
    AND a.create_time < '2023-05-31'
    AND bb.topic_id = 'zvKCCcX2Yi';

-- 删除库表
DROP TABLE tmp_crm.test_lzc;



select a.*
from ods_cmnt.ods_cmnt_tm_post_cur a
where 1=1 
and post_id in('Kdqgp0hii4','EG6TcYXfin','XFgbxln7G6','l8gBO6DXcw')
