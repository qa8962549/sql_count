select *
from ods_oper_crm.ods_oper_crm_umt001_em90_his_l

truncate table default.ck_table01;

##查询某表分区
ck001 :) 

select database,table,partition,name, bytes_on_disk  from system.parts where table='ods_oper_crm_umt001_em90_his_l';

select database,table,partition,name, bytes_on_disk  from system.parts where table='lzc_0620_l_si';

┌─database─┬─table┬─partition─┬─name────┬─bytes_on_disk─┐
│ default  │ ck_test1 │ 202302    │ 202302_3_3_0 │           221 │
│ default  │ ck_test1 │ 202301    │ 202301_4_4_0 │           232 │
└──────────┴────────────────────┴───────────┴

##删除某表分区
ck001 :) 

--删除数据
ALTER TABLE ods_oper_crm.ods_oper_crm_umt001_em90_his_l DELETE 
WHERE `_data_inlh_date`='20240703';

DROP TABLE ods_oper_crm.NewTable;

clickhouse-client --host=127.0.0.1 --port 9000 --user default