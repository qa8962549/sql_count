-- 取当月1号
select DATE_ADD(DATE_SUB(CURDATE(),INTERVAL 1 DAY),INTERVAL -DAY(DATE_SUB(CURDATE(),INTERVAL 1 DAY))+1 DAY)

-- 取一店一码ID对应的经销商Code
select
d.qr_code_id 一店一码ID,d.dealer_code 经销商Code
from volvo_wechat_live.es_dealer_qrcode d 
where LENGTH(d.campaign) = 3    -- 筛选长度为3的经销商code

--# 1、一店一码扫码
select
l.qr_code_id,
count(1)PV,
count(DISTINCT l.open_id)UV
from volvo_wechat_live.es_qr_code_logs l 
where 1=1
--l.create_time >= DATE_ADD(DATE_SUB(CURDATE(),INTERVAL 1 DAY),INTERVAL -DAY(DATE_SUB(CURDATE(),INTERVAL 1 DAY))+1 DAY)    -- 取的当月1号
--and l.create_time < CURDATE() 
and l.qr_code_id in
(
 -- 根据二维码表，提取长度为3的经销商CODE
 select
 DISTINCT d.qr_code_id
 from volvo_wechat_live.es_dealer_qrcode d 
 where LENGTH(d.campaign) = 3    -- 长度为3
) 
GROUP BY 1 order by 2 desc;

--# 12、一店一码明细
select
m.mid,
l.qr_code_id 二维码CODE,
d.campaign 经销商CODE,
'' 区域,
l.open_id 用户OPENID,
l.create_time 扫码时间,
l.eventtype 扫码类型,
case when m.open_id is not null then '是' else null end 是否进入推荐购
from volvo_wechat_live.es_qr_code_logs l
left join (
-- # 匹配经销商
 select DISTINCT d.campaign,d.qr_code_id
 from volvo_wechat_live.es_dealer_qrcode d 
 where LENGTH(d.campaign) = 3
) d on l.qr_code_id=d.qr_code_id
left join (
-- # 通过一店一码入口进入推荐购用户OPENID
 select DISTINCT m.open_id,m.mid
 from track.track t
 left join (
--  # rawdata
  select a.mid,a.USER_ID,o.open_id
  from (
--   #结合老库获取新库用户对应的 unionid
   select m.id mid,m.USER_ID,IFNULL(IFNULL(c.union_id,u.unionid),e.unionid) allunionid
   from  member.tc_member_info m 
   left join customer.tm_customer_info c on c.id=m.cust_id
   left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid<>'00000000'
   left join authentication.tm_user u on m.USER_ID=u.user_id
   left join authentication.tm_emp e on u.emp_id=e.emp_id
   where m.member_status<>60341003 and m.is_deleted=0 -- 排除黑名单用户
  )a
  JOIN volvo_wechat_live.es_car_owners o on a.allunionid=o.unionid and o.subscribe_status=1 and o.unionid<>'' and o.unionid is not null 
 ) m on CAST(m.USER_ID AS VARCHAR) = t.usertag
 where t.date between '2022-07-01' and '2022-09-30 23:59:59'
 and t.typeid='XWSJXCX_HOME_POPUP_BANNER_C' 
 and json_extract(t.data,'$.url')='/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Fmarket-package%2Fmillion-recommend%2Ftemp%2Findex&tcode=D0392CB2BD4E4A7086463B3A0917F189'
) m on l.open_id = m.open_id
where l.create_time between '2022-07-01' and '2022-09-30 23:59:59'
and l.qr_code_id in (
 select DISTINCT d.qr_code_id
 from volvo_wechat_live.es_dealer_qrcode d 
 where LENGTH(d.campaign)=3
)  order by 4


# 1、一店一码扫码
select
l.qr_code_id,
count(1)PV,
count(DISTINCT l.open_id)UV
from volvo_wechat_live.es_qr_code_logs l 
where l.create_time >= DATE_ADD(DATE_SUB(CURDATE(),INTERVAL 1 DAY),INTERVAL -DAY(DATE_SUB(CURDATE(),INTERVAL 1 DAY))+1 DAY)
and l.create_time < CURDATE() 
and l.qr_code_id in
(
	-- 根据二维码表，提取长度为3的经销商CODE
	select
	DISTINCT d.qr_code_id
	from volvo_wechat_live.es_dealer_qrcode d 
	where LENGTH(d.campaign) = 3    -- 长度为3
) 
GROUP BY 1 order by 2 desc;

# 2、留资数据
select
r.dealer_code 经销商代码,
count(case when r.intent_car_code='536' then 1 else null end) XC40,
count(case when r.intent_car_code='536ED' then 1 else null end) XC40bev,
count(case when r.intent_car_code='246' then 1 else null end) XC60,
count(case when r.intent_car_code='256' then 1 else null end) XC90,
count(case when r.intent_car_code='224' then 1 else null end) S60,
count(case when r.intent_car_code='238' then 1 else null end) S90,
count(case when r.intent_car_code='225' then 1 else null end) V60,
count(case when r.intent_car_code='236' then 1 else null end) V90,
count(case when r.intent_car_code='539' then 1 else null end) C40
from volvo_online_activity.recommend_buyv6_invite_record r
join (
select
m.mid,
l.qr_code_id 二维码CODE,
d.campaign 经销商CODE,
'' 区域,
l.open_id 用户OPENID,
l.create_time 扫码时间,
l.eventtype 扫码类型,
case when m.open_id is not null then '是' else null end 是否进入推荐购
from volvo_wechat_live.es_qr_code_logs l
left join (
 # 匹配经销商
 select DISTINCT d.campaign,d.qr_code_id
 from volvo_wechat_live.es_dealer_qrcode d 
 where LENGTH(d.campaign) = 3
) d on l.qr_code_id=d.qr_code_id
left join (
 # 通过一店一码入口进入推荐购用户OPENID
 select DISTINCT m.open_id,m.mid
 from track.track t
 left join (
  # rawdata
  select a.mid,a.USER_ID,o.open_id
  from (
   #结合老库获取新库用户对应的 unionid
   select m.id mid,m.USER_ID,IFNULL(IFNULL(c.union_id,u.unionid),e.unionid) allunionid
   from  member.tc_member_info m 
   left join customer.tm_customer_info c on c.id=m.cust_id
   left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid<>'00000000'
   left join authentication.tm_user u on m.USER_ID=u.user_id
   left join authentication.tm_emp e on u.emp_id=e.emp_id
   where m.member_status<>60341003 and m.is_deleted=0 -- 排除黑名单用户
  )a
  JOIN volvo_wechat_live.es_car_owners o on a.allunionid=o.unionid and o.subscribe_status=1 and o.unionid<>'' and o.unionid is not null 
 ) m on CAST(m.USER_ID AS VARCHAR) = t.usertag
 where t.date between '2022-07-01' and '2022-09-30 23:59:59'
 and t.typeid='XWSJXCX_HOME_POPUP_BANNER_C' 
 and json_extract(t.data,'$.url')='/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Fmarket-package%2Fmillion-recommend%2Ftemp%2Findex&tcode=D0392CB2BD4E4A7086463B3A0917F189'
) m on l.open_id = m.open_id
where l.create_time between '2022-07-01' and '2022-09-30 23:59:59'
and l.qr_code_id in (
 select DISTINCT d.qr_code_id
 from volvo_wechat_live.es_dealer_qrcode d 
 where LENGTH(d.campaign)=3
)  order by 4
)x on x.mid=r.invitee_member_id 
where 
-- r.create_time >= DATE_ADD(DATE_SUB(CURDATE(),INTERVAL 1 DAY),INTERVAL -DAY(DATE_SUB(CURDATE(),INTERVAL 1 DAY))+1 DAY)
-- and r.create_time < CURDATE()
 r.period = '2022q3'    -- 限制推荐购活动为22Q3
GROUP BY 1;
