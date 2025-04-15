--主会场 PVUV
SELECT 
count(distinct_id) PV,
count(distinct distinct_id) UV
--$url
from dwd_23.dwd_23_gio_tracking
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Page_entry'
and page_title='525车主节'
and var_activity_name='2024年5月525车主节'
--and length(distinct_id)<9

--主会场跳失
SELECT 
count(distinct_id) PV,
count(distinct distinct_id) UV
--$url
from dwd_23.dwd_23_gio_tracking
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Page_entry'
and page_title='525车主节'
and var_activity_name='2024年5月525车主节'
--and length(distinct_id)<9