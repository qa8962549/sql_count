--水军账号

SELECT a.ID,a.MEMBER_PHONE  FROM `member`.`tc_member_info`  a
where a.`MEMBER_PHONE` in(
"16280368338"
,"16280368339"
,"16280368340"
,"16280368341"
,"16745117434"
,"16745117433"
,"16745117432"
,"16745117431"
,"16745117430"
,"16745117429"
,"16745117428"
,"16745117427"
,"16211845139"
,"16211845138"
,"16211845137"
,"16211845136"
,"16211845135"
,"16211845134"
,"16211845133"
,"16211845132"
,"17121757312"
,"17121757311"
,"17121757310"
,"17121757309"
,"17121757308"
,"17121757307"
,"17121757306"
,"17121757305"
,"17121757304"
,"17121757303"
)

-- 去水军日报
select pv_day as post_day,post_title,post_id,pv_count '日PV',pv_count_total '总PV' ,uv_count '日UV',uv_count_total '总UV' ,comment_count '日评论数',comment_count_total '总评论数' ,lik.like_count '日点赞数',like_count_total '总点赞数'
from tm_post p left join
(SELECT date_format(create_time,'%Y/%m/%d') pv_day,post_id as pv_post_id,count(0) as pv_count FROM `tt_view_post` where member_id  not in(
 "6021804"
,"6046186"
,"6023001"
,"6043046"
,"6021534"
,"6021769"
,"6043124"
,"6019179"
,"6043154"
,"6019296"
,"6042920"
,"6019749"
,"6042911"
,"6042929"
,"6021545"
,"6020119"
,"6042865"
,"6021520"
,"6043167"
,"6044817"
,"6020112"
,"6043056"
,"6020063"
,"6020128"
,"6019769"
) group by post_id,pv_day) pv on p.post_id=pv_post_id
left join (SELECT  post_id as tpv_post_id,count(0) as pv_count_total FROM `tt_view_post` where member_id  not in(
 "6021804"
,"6046186"
,"6023001"
,"6043046"
,"6021534"
,"6021769"
,"6043124"
,"6019179"
,"6043154"
,"6019296"
,"6042920"
,"6019749"
,"6042911"
,"6042929"
,"6021545"
,"6020119"
,"6042865"
,"6021520"
,"6043167"
,"6044817"
,"6020112"
,"6043056"
,"6020063"
,"6020128"
,"6019769"
)  group by post_id) tpv on pv_post_id=tpv_post_id
left join ( SELECT date_format(create_time,'%Y/%m/%d') uv_day,post_id as uv_post_id,count(distinct member_id) as uv_count FROM `tt_view_post` where member_id  not in(
 "6021804"
,"6046186"
,"6023001"
,"6043046"
,"6021534"
,"6021769"
,"6043124"
,"6019179"
,"6043154"
,"6019296"
,"6042920"
,"6019749"
,"6042911"
,"6042929"
,"6021545"
,"6020119"
,"6042865"
,"6021520"
,"6043167"
,"6044817"
,"6020112"
,"6043056"
,"6020063"
,"6020128"
,"6019769"
)  group by post_id,uv_day ) uv on uv_day=pv_day and uv_post_id= pv_post_id
left join (SELECT  post_id as tuv_post_id,count(distinct member_id) as uv_count_total FROM `tt_view_post` where member_id  not in(
 "6021804"
,"6046186"
,"6023001"
,"6043046"
,"6021534"
,"6021769"
,"6043124"
,"6019179"
,"6043154"
,"6019296"
,"6042920"
,"6019749"
,"6042911"
,"6042929"
,"6021545"
,"6020119"
,"6042865"
,"6021520"
,"6043167"
,"6044817"
,"6020112"
,"6043056"
,"6020063"
,"6020128"
,"6019769"
)  group by post_id) tuv on uv_post_id=tuv_post_id
left join (select date_format(create_time,'%Y/%m/%d') comment_day,post_id as comment_post_id,count(0) comment_count from tm_comment  where is_deleted=0 and member_id  not in(
 "6021804"
,"6046186"
,"6023001"
,"6043046"
,"6021534"
,"6021769"
,"6043124"
,"6019179"
,"6043154"
,"6019296"
,"6042920"
,"6019749"
,"6042911"
,"6042929"
,"6021545"
,"6020119"
,"6042865"
,"6021520"
,"6043167"
,"6044817"
,"6020112"
,"6043056"
,"6020063"
,"6020128"
,"6019769"
)  group by  post_id,comment_day) c on pv_day=comment_day and pv_post_id=comment_post_id
left join (select post_id as tcomment_post_id,count(0) comment_count_total from tm_comment where `is_deleted` =0 and member_id  not in(
 "6021804"
,"6046186"
,"6023001"
,"6043046"
,"6021534"
,"6021769"
,"6043124"
,"6019179"
,"6043154"
,"6019296"
,"6042920"
,"6019749"
,"6042911"
,"6042929"
,"6021545"
,"6020119"
,"6042865"
,"6021520"
,"6043167"
,"6044817"
,"6020112"
,"6043056"
,"6020063"
,"6020128"
,"6019769"
)  group by  post_id) ct on comment_post_id=tcomment_post_id
left join
(select date_format(create_time,'%Y/%m/%d') like_day,post_id as like_post_id,count(*) as like_count from tt_like_post where is_deleted=0 and like_type=0 and member_id  not in(
 "6021804"
,"6046186"
,"6023001"
,"6043046"
,"6021534"
,"6021769"
,"6043124"
,"6019179"
,"6043154"
,"6019296"
,"6042920"
,"6019749"
,"6042911"
,"6042929"
,"6021545"
,"6020119"
,"6042865"
,"6021520"
,"6043167"
,"6044817"
,"6020112"
,"6043056"
,"6020063"
,"6020128"
,"6019769"
)  group by post_id,like_day) lik on pv_day = like_day and pv_post_id=like_post_id
left join
(select post_id as tlike_post_id,count(*) as like_count_total from tt_like_post where is_deleted=0 and like_type=0 and member_id  not in(
 "6021804"
,"6046186"
,"6023001"
,"6043046"
,"6021534"
,"6021769"
,"6043124"
,"6019179"
,"6043154"
,"6019296"
,"6042920"
,"6019749"
,"6042911"
,"6042929"
,"6021545"
,"6020119"
,"6042865"
,"6021520"
,"6043167"
,"6044817"
,"6020112"
,"6043056"
,"6020063"
,"6020128"
,"6019769"
)  group by post_id) tlik on like_post_id=tlike_post_id
where p.is_deleted=0 ORDER BY post_day DESC;




-- 日报

select pv_day as post_day,post_title,post_id,pv_count '日PV',pv_count_total '总PV' ,uv_count '日UV',uv_count_total '总UV' ,comment_count '日评论数',comment_count_total '总评论数' ,lik.like_count '日点赞数',like_count_total '总点赞数'
from tm_post p left join
(SELECT date_format(create_time,'%Y/%m/%d') pv_day,post_id as pv_post_id,count(0) as pv_count FROM `tt_view_post` group by post_id,pv_day) pv on p.post_id=pv_post_id
left join (SELECT  post_id as tpv_post_id,count(0) as pv_count_total FROM `tt_view_post` group by post_id) tpv on pv_post_id=tpv_post_id
left join ( SELECT date_format(create_time,'%Y/%m/%d') uv_day,post_id as uv_post_id,count(distinct member_id) as uv_count FROM `tt_view_post` group by post_id,uv_day ) uv on uv_day=pv_day and uv_post_id= pv_post_id
left join (SELECT  post_id as tuv_post_id,count(distinct member_id) as uv_count_total FROM `tt_view_post` group by post_id) tuv on uv_post_id=tuv_post_id
left join (select date_format(create_time,'%Y/%m/%d') comment_day,post_id as comment_post_id,count(0) comment_count from tm_comment where is_deleted=0 group by  post_id,comment_day) c on pv_day=comment_day and pv_post_id=comment_post_id
left join (select post_id as tcomment_post_id,count(0) comment_count_total from tm_comment where `is_deleted` =0 group by  post_id) ct on comment_post_id=tcomment_post_id
left join
(select date_format(create_time,'%Y/%m/%d') like_day,post_id as like_post_id,count(*) as like_count from tt_like_post where is_deleted=0 and like_type=0 group by post_id,like_day) lik on pv_day = like_day and pv_post_id=like_post_id
left join
(select post_id as tlike_post_id,count(*) as like_count_total from tt_like_post where is_deleted=0 and like_type=0 group by post_id) tlik on like_post_id=tlike_post_id
where p.is_deleted=0 ORDER BY post_day DESC