SELECT
    bucket_range,
    COUNT(*) AS user_count
FROM (
    SELECT
        width_bucket(member_v_num, min_score, max_score, 369.6133333333333333) AS bucket_id,
        min_score + (width_bucket(member_v_num, min_score, max_score, 369.6133333333333333) - 1) * bucket_width AS bucket_range
    FROM (
        SELECT
            tmi.id,
            tmi.member_v_num,
            -- 计算分数的最小值和最大值
            MIN(member_v_num) OVER () AS min_score,
            MAX(member_v_num) OVER () AS max_score,
            -- 计算每个桶的宽度
            (MAX(member_v_num) OVER () - MIN(member_v_num) OVER ()) / 369.6133333333333333 AS bucket_width
        from "member".tc_member_info tmi 
        where tmi.member_v_num>=0
        and tmi.is_deleted=0
    ) AS subquery
) AS bucketed_data
GROUP BY bucket_range
ORDER BY bucket_range;

select width_bucket(tmi.member_v_num,0,120000,400)*300,
count(tmi.id)
from "member".tc_member_info tmi 
where tmi.member_v_num >=0
group by 1
order by 1



select tmi.id,tmi.member_v_num 
from "member".tc_member_info tmi 
where tmi.member_v_num <0
