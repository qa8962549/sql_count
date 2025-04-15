-- （1）2022.5.24-5.30 点击“前往关注”用户数
select 
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-05-24 00:00:00' and t.`date` <= '2022-05-30 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint')= 'collectionPage_homePage_前往关注_click'


-- （2）2022.5.24-5.30 公众号引流关注数（含新增关注用户数、历史取关重新关注用户数） 
        -- PS：关注定义：用户点击过关注按钮且在10分钟内成功关注公众号
select
count(distinct a.usertag) 新关注数量
from(
 #点击关注按钮10分钟内用户关注微信公众号
 select t.usertag,b.mdate
 from track.track t
 join (
  #点击关注按钮时间
  select t.usertag,t.date mdate,m.CUST_ID custid
  from track.track t 
  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
  where json_extract(t.`data`,'$.embeddedpoint')= 'collectionPage_homePage_前往关注_click'
  and t.`date` >= '2022-05-24 00:00:00' and t.`date` <= '2022-05-30 23:59:59'
 ) b on b.usertag=t.usertag
 join customer.tm_customer_info tci on b.custid=tci.id and tci.is_deleted =0
 join volvo_wechat_live.es_car_owners eco on tci.union_id =eco.unionid  -- 联结关注微信公众号表
 where eco.create_time <= DATE_ADD(b.mdate,INTERVAL 10 MINUTE)
 and eco.create_time>=b.mdate
) a

-- 历史取关重新关注用户数
select 
 DISTINCT b.usertag,  
 b.mdate 点击关注按钮时间,
 c.create_time 关注公众号时间,
 c.unsubscribe_time 取关时间,
 c.subscribe_status
 from 
 (
  #点击关注公众号按钮时间
  select t.usertag,t.date mdate,m.CUST_ID custid
  from track.track t 
  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
  where json_extract(t.`data`,'$.embeddedpoint')= 'collectionPage_homePage_前往关注_click'
  and t.`date` >= '2022-05-24 00:00:00' and t.`date` <= '2022-05-30 23:59:59'
  GROUP BY 1
 ) b
 left join customer.tm_customer_info tci on b.custid=tci.id and tci.is_deleted =0
 left join 
 (
 #活动前取关，现状态为关注的用户
 select 
 eco.unionid,
 eco.create_time,
 eco.unsubscribe_time,
 eco.subscribe_status,
 eco.subscribe_time
 FROM volvo_wechat_live.es_car_owners eco
 where eco.unsubscribe_time <='2022-5-24' #活动开始时间之前取关的时间
 and eco.subscribe_status=1 #关注
 order by eco.unsubscribe_time desc 
 )c on c.unionid =tci.union_id
 where c.create_time <= DATE_ADD(b.mdate,INTERVAL 10 MINUTE)   #点击关注按钮10分钟内用户关注微信公众号 
 and c.create_time>=b.mdate
 

-- （3）目前仍关注公众号用户数
 select COUNT(DISTINCT x.usertag)
 from 
 (
 select 
 DISTINCT t.usertag,  
 b.mdate 点击关注按钮时间,
 eco.create_time 关注公众号时间,
 eco.unsubscribe_time 取关时间,
 eco.subscribe_status
 from track.track t
 join (
  -- 点击关注按钮时间
  select t.usertag,t.date mdate,m.CUST_ID custid
  from track.track t 
  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
  where json_extract(t.`data`,'$.embeddedpoint')= 'collectionPage_homePage_前往关注_click'
  and t.`date` >= '2022-05-24 00:00:00' and t.`date` <= '2022-05-30 23:59:59'
  GROUP BY 1
 ) b on b.usertag=t.usertag
 join customer.tm_customer_info tci on b.custid=tci.id and tci.is_deleted =0
 join volvo_wechat_live.es_car_owners eco on tci.union_id =eco.unionid  -- 联结关注微信公众号表
 where eco.create_time <= DATE_ADD(b.mdate,INTERVAL 10 MINUTE)
 and eco.create_time>=b.mdate
 and eco.subscribe_status =1 -- 关注
 ) x


 
 -- 沃世界三周年： 三周年_发酵页关注公众号_ONCLCIK
-- （1）2022.6.3 点击“前往关注”用户数
 select 
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-06-03 00:00:00' and t.`date` <= '2022-06-03 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint')= '三周年_发酵页关注公众号_ONCLCIK'
 
-- （2）2022.6.1-6.3 公众号引流关注数（含新增关注用户数、历史取关重新关注用户数） 
select
count(distinct a.usertag) 新关注数量
from(
 #点击关注按钮10分钟内用户关注微信公众号
 select t.usertag,b.mdate
 from track.track t
 join (
  #点击关注按钮时间
  select t.usertag,t.date mdate,m.CUST_ID custid
  from track.track t 
  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
  where json_extract(t.`data`,'$.embeddedpoint')= '三周年_发酵页关注公众号_ONCLCIK'
  and t.`date` >= '2022-06-01 00:00:00' and t.`date` <= '2022-06-03 23:59:59'
 ) b on b.usertag=t.usertag
 join customer.tm_customer_info tci on b.custid=tci.id and tci.is_deleted =0
 join volvo_wechat_live.es_car_owners eco on tci.union_id =eco.unionid  -- 联结关注微信公众号表
 where eco.create_time <= DATE_ADD(b.mdate,INTERVAL 10 MINUTE)
 and eco.create_time>=b.mdate
) a


-- 历史取关重新关注用户数
select 
 DISTINCT b.usertag,  
 b.mdate 点击关注按钮时间,
 c.create_time 关注公众号时间,
 c.unsubscribe_time 取关时间,
 c.subscribe_status
 from (
  #点击关注公众号按钮时间
  select t.usertag,t.date mdate,m.CUST_ID custid
  from track.track t 
  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
  where json_extract(t.`data`,'$.embeddedpoint')= '三周年_发酵页关注公众号_ONCLCIK'
  and t.`date` >= '2022-06-01 00:00:00' and t.`date` <= '2022-06-03 23:59:59'
  GROUP BY 1
 ) b
 left join customer.tm_customer_info tci on b.custid=tci.id and tci.is_deleted =0
 left join 
 (
 #活动前取关，现状态为关注的用户
 select 
 eco.unionid,
 eco.create_time,
 eco.unsubscribe_time,
 eco.subscribe_status,
 eco.subscribe_time
 FROM volvo_wechat_live.es_car_owners eco  
 where eco.unsubscribe_time <='2022-06-01' #活动开始时间之前取关的时间  
 and eco.subscribe_status=1
 order by eco.unsubscribe_time desc 
 )c on c.unionid =tci.union_id
 where c.create_time <= DATE_ADD(b.mdate,INTERVAL 10 MINUTE)  #点击关注按钮10分钟内用户关注微信公众号
 and c.create_time>=b.mdate
 


-- （3）目前仍关注公众号用户数
 select COUNT(DISTINCT x.usertag)
 from 
 (
 select 
 DISTINCT t.usertag,  
 b.mdate 点击关注按钮时间,
 eco.create_time 关注公众号时间,
 eco.unsubscribe_time 取关时间,
 eco.subscribe_status
 from track.track t
 join (
  -- 点击关注按钮时间
  select t.usertag,t.date mdate,m.CUST_ID custid
  from track.track t 
  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
  where json_extract(t.`data`,'$.embeddedpoint')= '三周年_发酵页关注公众号_ONCLCIK'
  and t.`date` >= '2022-06-01 00:00:00' and t.`date` <= '2022-06-03 23:59:59'
  GROUP BY 1
 ) b on b.usertag=t.usertag
 join customer.tm_customer_info tci on b.custid=tci.id and tci.is_deleted =0
 join volvo_wechat_live.es_car_owners eco on tci.union_id =eco.unionid  -- 联结关注微信公众号表
 where eco.create_time <= DATE_ADD(b.mdate,INTERVAL 10 MINUTE)
 and eco.create_time>=b.mdate
 and eco.subscribe_status =1 -- 关注
 ) x
