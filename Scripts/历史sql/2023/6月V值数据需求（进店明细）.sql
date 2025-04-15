6月交车VIN在5月末、6月末    6月消耗的V值

-- 6月进店明细
select v.vin VIN,v.member_id memberID
,case when h.member_id is null then '否' else '是' end 该memberID是否绑定多辆车
,m.cust_id oneID
,ifnull(f.截止5月31号V值余额,m.member_v_num) 截止5月31号V值余额
,ifnull(f.截止6月30号V值余额,m.member_v_num) 截止6月30号V值余额
from (
 #获取全量VIN
 select v.*
 from (
   select v.MEMBER_ID,v.VIN
   ,row_number() over(partition by v.vin order by v.create_time desc) rk
   from member.tc_member_vehicle v 
   where v.is_deleted=0 and v.MEMBER_ID is not null
 ) v
 where v.rk=1 
) v
left join member.tc_member_info m on v.member_id=m.id
left join (
 -- 历史节点剩余V值
 select f.MEMBER_ID,m.MEMBER_V_NUM
 ,m.MEMBER_V_NUM-sum(case when f.create_time>='2022-05-31 23:59:59' then 
      case when f.RECORD_TYPE=1 then -f.INTEGRAL when f.RECORD_TYPE=0 then f.INTEGRAL else 0 end 
      else 0 end) 截止5月31号V值余额
 ,m.MEMBER_V_NUM-sum(case when f.create_time>='2022-06-30 23:59:59' then 
      case when f.RECORD_TYPE=1 then -f.INTEGRAL when f.RECORD_TYPE=0 then f.INTEGRAL else 0 end 
      else 0 end) 截止6月30号V值余额
 from member.tt_member_flow_record f
 join member.tc_member_info m on f.MEMBER_ID=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
 where 
 -- f.create_time >= '2022-02-02' 
 f.IS_DELETED=0 
 -- and f.MEMBER_ID=3368880
 GROUP BY 1,2
) f on f.member_id=v.member_id
left join (
-- memberid 是否绑定多辆车
 select v.member_id,count(1)
 from (
   select v.MEMBER_ID,v.VIN
   ,row_number() over(partition by v.vin order by v.create_time desc) rk
   from member.tc_member_vehicle v 
   where v.is_deleted=0 and v.MEMBER_ID is not null
 ) v
 where v.rk=1
 GROUP BY 1 having count(1)>1
) h on h.member_id=v.member_id 
order by 2 ; 

-- 6月进店明细 消费V值总和
select v.vin VIN,v.member_id memberID
,case when h.member_id is null then '否' else '是' end 该memberID是否绑定多辆车
,m.cust_id oneID
,ifnull(f.6月消费V值总数,m.member_v_num) 6月消费V值总数
from (
 #获取全量VIN
 select v.*
 from (
   select v.MEMBER_ID,v.VIN
   ,row_number() over(partition by v.vin order by v.create_time desc) rk
   from member.tc_member_vehicle v 
   where v.is_deleted=0 and v.MEMBER_ID is not null
 ) v
 where v.rk=1 
) v
left join member.tc_member_info m on v.member_id=m.id
left join (
 -- 历史节点剩余V值
 select f.MEMBER_ID,m.MEMBER_V_NUM
 ,sum(case when f.create_time>='2022-06-01'and f.create_time<='2022-06-30 23:59:59'then 
      case when f.RECORD_TYPE=1 then f.INTEGRAL else 0 end 
      else 0 end) 6月消费V值总数
 from member.tt_member_flow_record f
 join member.tc_member_info m on f.MEMBER_ID=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
 where 
 -- f.create_time >= '2022-02-02' 
 f.IS_DELETED=0 
 -- and f.MEMBER_ID=3368880
 GROUP BY 1,2
) f on f.member_id=v.member_id
left join (
-- memberid 是否绑定多辆车
 select v.member_id,count(1)
 from (
   select v.MEMBER_ID,v.VIN
   ,row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
   from member.tc_member_vehicle v 
   where v.is_deleted=0 and v.MEMBER_ID is not null
 ) v
 where v.rk=1
 GROUP BY 1 having count(1)>1
) h on h.member_id=v.member_id 
order by 2 ; 