### 思享驾沃世界二维码申请
select a.qr_code_id 二维码code
,count(DISTINCT case when a.eventtype='subscribe' then a.unionid else null end  ) 新增总计
,count(DISTINCT case when a.eventtype='subscribe' and a.vehicle=1 then a.unionid else null end  ) 新增车主
,count(DISTINCT case when a.eventtype='subscribe' and a.vehicle=0 then a.unionid else null end  ) 新增粉丝
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=0 then a.unionid else null end  ) 取关总计
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=0 and a.vehicle=1 then a.unionid else null end  ) 取关车主
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=0 and a.vehicle=0 then a.unionid else null end  ) 取关粉丝
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 then a.unionid else null end  ) 留存总计
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 and a.vehicle=1 then a.unionid else null end  ) 留存车主
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 and a.vehicle=0 then a.unionid else null end  ) 留存粉丝
,count(DISTINCT case when a.eventtype='scan' then a.unionid else null end ) 已关注扫码用户数
,concat( cast(round(count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 then a.unionid else null end  )/count(DISTINCT case when a.eventtype='subscribe' then a.unionid else null end),3)*100 as varchar),'%') 留存率
,round(sum( case when a.eventtype='subscribe' then a.gtime else null end )/count(DISTINCT case when a.eventtype='subscribe' then a.unionid else null end  ),2) 平均留存时长
from (
	select 
	q.qr_code_id
	,q.open_id 微信openid
	,q.eventtype
	,o.unionid
	,o.subscribe_status 关注状态
	,q.create_time 扫码时间
	,ifnull(o.subscribe_time,o.create_time) 关注时间
	,o.unsubscribe_time 取关时间
	,m.mid
	,IFNULL(m.IS_VEHICLE,0) vehicle
	,TIMESTAMPDIFF(DAY,q.create_time,if(o.subscribe_status=1,CURDATE(),o.unsubscribe_time)) gtime
	from volvo_wechat_live.es_qr_code_logs q
	left join volvo_wechat_live.es_car_owners o on q.open_id=o.open_id
	left join (
		#判断是否关注公众号
			select m.id mid,m.is_vehicle,IFNULL(c.union_id,u.unionid) allunionid
			from  member.tc_member_info m 
			left join customer.tm_customer_info c on c.id=m.cust_id
			left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid<>'00000000'
			where m.member_status<>60341003 and m.is_deleted=0 -- 排除黑名单用户
	) m on o.unionid=m.allunionid
	where q.create_time BETWEEN '2021-10-29' and '2021-11-1 23:59:59'
	and o.unionid is not null and o.unionid<>''
	and q.qr_code_id = 1928
)a 
GROUP BY 1 order by 2 DESC;


select a.qr_code_id 二维码code
,a.微信openid
from (
	select 
	q.qr_code_id
	,q.open_id 微信openid
	,q.eventtype
	,o.unionid
	,o.subscribe_status 关注状态
	,q.create_time 扫码时间
	,ifnull(o.subscribe_time,o.create_time) 关注时间
	,o.unsubscribe_time 取关时间
	,m.mid
	,IFNULL(m.IS_VEHICLE,0) vehicle
	,TIMESTAMPDIFF(DAY,q.create_time,if(o.subscribe_status=1,CURDATE(),o.unsubscribe_time)) gtime
	from volvo_wechat_live.es_qr_code_logs q
	left join volvo_wechat_live.es_car_owners o on q.open_id=o.open_id
	left join (
		#判断是否关注公众号
			select m.id mid,m.is_vehicle,IFNULL(c.union_id,u.unionid) allunionid
			from  member.tc_member_info m 
			left join customer.tm_customer_info c on c.id=m.cust_id
			left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid<>'00000000'
			where m.member_status<>60341003 and m.is_deleted=0 -- 排除黑名单用户
	) m on o.unionid=m.allunionid
	where q.create_time BETWEEN '2021-10-29' and '2021-11-1 23:59:59'
	and o.unionid is not null and o.unionid<>''
	and q.qr_code_id = 1928
)a 
GROUP BY 1 order by 2 DESC;
