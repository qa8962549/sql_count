sql 例子如下：
【虚拟号表】：volvo用户t_c_privacy_callsuccessinfo
【话单表】：icd用户下tbilllogX

--使用数据库volvo用户
--拨打次数
select privacycalled,count(1)
from ods_icd.ods_icd_t_c_privacy_callsuccessinfo1_cur t
 where t.called <> t.privacycalled
   and t.callid is not null
   and t.calltime >= date '2024-08-12'
   and t.calltime < date '2024-08-22'
group by t.privacycalled;

select privacycalled,count(1) `拨打次数`
from 
	(
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo1_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo2_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo3_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo4_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo5_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo6_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo7_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo8_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo9_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo10_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo11_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo12_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
)t 
where t.calltime >= '2024-09-11'
and t.calltime < '2024-09-18'
and privacycalled='13040642301'
group by t.privacycalled;

----使用数据库volvo用户
--查询隐私号使用对应callid
select  distinct t.callid
  from ods_icd.ods_icd_t_c_privacy_callsuccessinfo1_cur t
 where t.called <> t.privacycalled
   and t.callid is not null
   and t.calltime >= date '2024-08-12'
   and t.calltime < date '2024-08-22'
   and substr(t.callid,0,1) <> 0;
  
select distinct privacycalled,callid
from 
	(
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo1_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo2_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo3_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo4_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo5_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo6_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo7_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo8_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo9_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo10_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo11_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
	union all 
	select*
	from ods_icd.ods_icd_t_c_privacy_callsuccessinfo12_cur t
	where t.called <> t.privacycalled
	and t.callid is not null
)t 
where 
and substr(t.callid,0,1) <> 0;
and t.privacycalled in ()
  
--使用平台库icd用户
--查询隐私号接通数量
select  t.calleeno,count(1) 
from ods_icd.ods_icd_tbilllog1_cur t
 where t.callend >= to_date('20240812000000', 'yyyy-MM-dd hh24:mi:ss')
 and t.callend < to_date('20240822000000', 'yyyy-MM-dd hh24:mi:ss')
 and t.vdn = 3
-- and t.callid in(
-- --查询的callid结果集 
-- )
 and t.callend-t.callbegin > 0
 group by calleeno;

select  t.calleeno,callend,callbegin
from ods_icd.ods_icd_tbilllog1_cur t
limit 10

 
select callend,
callend,
callbegin
from 
	(
	select *
	from ods_icd.ods_icd_tbilllog1_cur t
	union all 
	select *
	from ods_icd.ods_icd_tbilllog2_cur t
	union all 
	select *
	from ods_icd.ods_icd_tbilllog3_cur t
	union all 
	select *
	from ods_icd.ods_icd_tbilllog4_cur t
	union all 
	select *
	from ods_icd.ods_icd_tbilllog5_cur t
	union all 
	select *
	from ods_icd.ods_icd_tbilllog6_cur t
	union all 
	select *
	from ods_icd.ods_icd_tbilllog7_cur t
	union all 
	select *
	from ods_icd.ods_icd_tbilllog8_cur t
	union all 
	select *
	from ods_icd.ods_icd_tbilllog9_cur t
	union all 
	select *
	from ods_icd.ods_icd_tbilllog10_cur t
	union all 
	select *
	from ods_icd.ods_icd_tbilllog11_cur t
	union all 
	select *
	from ods_icd.ods_icd_tbilllog12_cur t
)t 
 where t.callend >= '2024-09-11'
 and t.callend <'2024-09-18'
 and t.vdn = 3
 and unix_timestamp(t.callend) - unix_timestamp(t.callbegin) > 0
 and calleeno='13040645292'
-- group by calleeno


 --使用平台库icd用户
 --查询隐私号对应接通分钟数
select  t.calleeno,round((unix_timestamp(t.callend) - unix_timestamp(t.callbegin))/60,2)
from ods_icd.ods_icd_tbilllog12_cur t
 where t.callend >= date '2022-01-12'
 and t.callend <date '2024-08-22'
 and t.vdn = 3
 and unix_timestamp(t.callend) - unix_timestamp(t.callbegin) > 0


