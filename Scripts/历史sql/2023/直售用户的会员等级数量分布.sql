-- 每个车型每个会员等级的车主数。
-- 会员ID绑定最新车辆信息，这里rk=1取的是最新绑定
 select ifnull(m.MODEL_NAME,v.model_name)车型,
--  x.会员等级,
 sum(case when x.会员等级='普卡' then 1 else 0 end) 普卡,
  sum(case when x.会员等级='银卡' then 1 else 0 end) 银卡,
   sum(case when x.会员等级='金卡' then 1 else 0 end) 金卡,
    sum(case when x.会员等级='白金卡' then 1 else 0 end) 白金卡,
     sum(case when x.会员等级='黑卡' then 1 else 0 end) 黑卡
 from (
 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin,v.create_time
 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
 from member.tc_member_vehicle v 
 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
 where v.IS_DELETED=0 
 ) v 
 left join vehicle.tm_vehicle t on v.vin=t.VIN
 left join basic_data.tm_model m on t.MODEL_ID=m.ID
 left join (
select distinct
c.user_id 会员ID,
f.LEVEL_NAME 会员等级,
c.medal_id 勋章ID,
e.`type` 勋章类型编码,
g.type_name 所属板块,
e.medal_name 勋章名称,
c.create_time 勋章获得时间
from mine.madal_detail c
left join `member`.tc_member_info d on d.ID = c.user_id
left join mine.user_medal e on e.id = c.medal_id
left join `member`.tc_level f on f.LEVEL_CODE = d.MEMBER_LEVEL
left join mine.my_medal_type g on e.`type` = g.union_code
where 
-- c.create_time <= '2022-06-26 23:59:59'and 
c.deleted = 1  -- 有效
and c.status = 1  -- 正常
)x on x.会员ID=v.member_id
 where v.rk=1
 group by 1
 order by 1 desc 