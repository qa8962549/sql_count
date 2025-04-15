-- 该年新增绑车用户数
  select year(v.create_time)
--   ,v.member_id
  ,count(1)
  from (
    select v.MEMBER_ID,v.VIN
    ,row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
    ,v.create_time
    from member.tc_member_vehicle v 
    where v.is_deleted=0 and v.MEMBER_ID is not null
  ) v
  left join vehicle.tm_vehicle vv on v.vin =vv.vin and vv.IS_DELETED=0
  left join vehicle.tt_invoice_statistics_dms d on v.vin=d.vin and d.IS_DELETED=0
  left join member.tc_member_info m  on v.member_id=m.id
  where v.rk=1 -- 获取用户最后绑车记录
  and v.create_time>='2019-01-01'
  group by 1
  order by 1
  
   select m.CUST_ID,v.member_id
  from (
    select v.MEMBER_ID,v.VIN
    ,row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
    ,v.create_time
    from member.tc_member_vehicle v 
    where v.is_deleted=0 and v.MEMBER_ID is not null
  ) v
  left join vehicle.tm_vehicle vv on v.vin =vv.vin and vv.IS_DELETED=0
  left join vehicle.tt_invoice_statistics_dms d on v.vin=d.vin and d.IS_DELETED=0
  left join member.tc_member_info m  on v.member_id=m.id
  where v.rk=1 -- 获取用户最后绑车记录
  and v.create_time>='2022-01-01'
  group by 1
  order by 1
  
 -- 累积绑车用户数
select 
 count(DISTINCT case when  year(v.create_time)<'2020' then v.MEMBER_ID end ) '2019',
 count(DISTINCT case when  year(v.create_time)<'2021' then v.MEMBER_ID end ) '2020',
 count(DISTINCT case when  year(v.create_time)<'2022' then v.MEMBER_ID end ) '2021',
 count(DISTINCT case when year(v.create_time)<'2023' then v.MEMBER_ID end ) '2022'
  from (
    select v.MEMBER_ID,v.VIN
    ,row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
    ,v.create_time
    from member.tc_member_vehicle v 
    where v.is_deleted=0 and v.MEMBER_ID is not null
  ) v
  left join vehicle.tm_vehicle vv on v.vin =vv.vin and vv.IS_DELETED=0
  left join vehicle.tt_invoice_statistics_dms d on v.vin=d.vin and d.IS_DELETED=0
  left join member.tc_member_info m  on v.member_id=m.id
  where v.rk=1 -- 获取用户最后绑车记录
  
select m.CUST_ID ,v.member_id
  from (
    select v.MEMBER_ID,v.VIN
    ,row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
    ,v.create_time
    from member.tc_member_vehicle v 
    where v.is_deleted=0 and v.MEMBER_ID is not null
  ) v
  left join vehicle.tm_vehicle vv on v.vin =vv.vin and vv.IS_DELETED=0
  left join vehicle.tt_invoice_statistics_dms d on v.vin=d.vin and d.IS_DELETED=0
  left join member.tc_member_info m  on v.member_id=m.id
  where v.rk=1 -- 获取用户最后绑车记录
  and v.create_time<'2023-01-01'
  
  -- 该年度新增会员数
  select year(m.CREATE_TIME),
  count(DISTINCT m.ID)
  from `member`.tc_member_info m
  where m.IS_DELETED=0 
  and m.MEMBER_STATUS<>60341003
  and m.CREATE_TIME >='2019-01-01'
  group by 1
  order by 1
  
  select DISTINCT m.CUST_ID,m.ID
  from `member`.tc_member_info m
  where m.IS_DELETED=0 
  and m.MEMBER_STATUS<>60341003
  and m.CREATE_TIME >='2022-01-01'
  and m.CREATE_TIME <'2023-01-01'
  group by 1
  order by 1
  
  -- 当年活跃车主总数
  select year(t.`date`),
  count(DISTINCT m.ID)
  from track.track t 
  left join `member`.tc_member_info m on cast(m.USER_ID as varchar)=t.usertag 
  where m.IS_DELETED=0 
  and m.MEMBER_STATUS<>60341003
--   and m.CREATE_TIME >='2019-01-01'
  and t.date>='2019-01-01'
  and m.IS_VEHICLE =1
  group by 1
  order by 1
  
  select DISTINCT m.CUST_ID,m.ID
  from track.track t 
  left join `member`.tc_member_info m on cast(m.USER_ID as varchar)=t.usertag 
  where m.IS_DELETED=0 
  and m.MEMBER_STATUS<>60341003
--   and m.CREATE_TIME >='2019-01-01'
  and t.date>='2022-01-01'
  and t.date<'2023-01-01'
  and m.IS_VEHICLE =1
  group by 1
  order by 1
  
  