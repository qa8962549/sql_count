select m.memberid member_id
,m.max_app_time `最近一次登录App的时间`
--,m2.member_v_num `用户当前剩余V值`
,ifnull(m2.member_v_num,0) - ifnull(m2.member_lock_v_num,0) `用户当前剩余V值`
from ads_crm.ads_crm_events_member_d m
left join ods_memb.ods_memb_tc_member_info_cur m2 on toString(m.memberid)=toString(m2.id)

select distinct distinct_id,
date
from ods_rawd.ods_rawd_events_d_di o 
where o.distinct_id ='5864821
'
and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')