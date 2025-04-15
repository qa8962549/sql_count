CREATE TABLE IF NOT EXISTS test1
(
    id Int32,
    time DateTime
) ENGINE = ReplacingMergeTree()
ORDER BY (id, time);

INSERT into test1
select m.id ,m.create_time 
from ods_memb.ods_memb_tc_member_info_cur m 
where date(m.create_time) ='2023-09-19'
limit 10

INSERT into test1
select m.id ,m.create_time 
from ods_memb.ods_memb_tc_member_info_cur m 
where date(m.create_time) ='2023-09-18'
limit 10

