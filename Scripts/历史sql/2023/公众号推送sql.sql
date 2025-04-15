 #获取公众号回复DY用户unionid
 select DISTINCT o.unionid
 ,'DY' click,DATE(l.create_time) 日期
 from volvo_wechat_live.es_wechat_reply_log l
 left join volvo_wechat_live.es_car_owners o on l.openid=o.open_id
 -- where DATE(l.create_time)='2022-03-07'
 where l.create_time BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
 and l.title ='在看'
 order by 3,2
 
 #推送数据 
 select a.*
from (
SELECT a.日期,o.open_id,a.unionid
,case when sum(case when a.click='DY' then 1 else 0 end )=1 and count(1)=1 then 1 
			when sum(case when a.click='DY' then 1 else 0 end )=1 and sum(case when a.click='试驾' then 1 else 0 end )=1 and count(1)=2 then 2 
			when sum(case when a.click='DY' then 1 else 0 end )=1 and sum(case when a.click='注册' then 1 else 0 end )=1 and count(1)=2 then 3 
			when sum(case when a.click='DY' then 1 else 0 end )=1 and sum(case when a.click='试驾' then 1 else 0 end )=1 and sum(case when a.click='注册' then 1 else 0 end )=1 and count(1)=3 then 4
			when sum(case when a.click='DY' then 1 else 0 end )=1 and sum(case when a.click='服务' then 1 else 0 end )=1 and count(1)=2 then 8
			when sum(case when a.click='DY' then 1 else 0 end )=1 and sum(case when a.click='服务' then 1 else 0 end )=1 and sum(case when a.click='注册' then 1 else 0 end )=1 and count(1)=3 then 9
			-- when sum(case when a.click='DY' then 1 else 0 end )=0 and sum(case when a.click='试驾' then 1 else 0 end )=0 and sum(case when a.click='注册' then 1 else 0 end )=1 then 5
			-- when sum(case when a.click='DY' then 1 else 0 end )=0 and sum(case when a.click='试驾' then 1 else 0 end )=1 and sum(case when a.click='注册' then 1 else 0 end )=0 then 6
			-- when sum(case when a.click='DY' then 1 else 0 end )=0 and sum(case when a.click='试驾' then 1 else 0 end )=1 and sum(case when a.click='注册' then 1 else 0 end )=1 then 7 
			else null end type	-- type(1,2,3,4)点击订阅的用户推送,type(5,6,7)没点击订阅的用户不推送
from(
	#获取点击注册和预约试驾用户unionid(注册tcode存在第一次点击没有埋点)
	select DISTINCT e.unionid
	,case when json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7' then '注册' -- 注册tcode如有变化修改这里
				when json_extract(t.data,'$.tcode')='5338621B0499415CBC82CE021DCC73B5' then '试驾' -- 试驾tcode如有变化修改这里
				when json_extract(t.data,'$.tcode')='3A3579491DCF472CB46AAB44CC9AF480' then '服务' -- 服务tcode如有变化修改这里
				else null end click
	,DATE(t.date) 日期
	from track.track t 
	left join authentication.tm_user u on CAST(u.user_id AS VARCHAR)=t.usertag
	left join authentication.tm_emp e on e.emp_id=u.emp_id
	-- where DATE(t.date)='2022-03-07' 
	where t.date BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
	and (json_extract(t.data,'$.tcode')='5338621B0499415CBC82CE021DCC73B5' -- 试驾(同上)
	or json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7' -- 注册(同上)
	or json_extract(t.data,'$.tcode')='3A3579491DCF472CB46AAB44CC9AF480' -- 服务(同上2022.3.7新增)
	) 
	union ALL
	#获取公众号回复DY用户unionid
	select DISTINCT o.unionid
	,'DY' click,DATE(l.create_time) 日期
	from volvo_wechat_live.es_wechat_reply_log l
	left join volvo_wechat_live.es_car_owners o on l.openid=o.open_id
	-- where DATE(l.create_time)='2022-03-07'
	where l.create_time BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
	and l.title ='在看'
	order by 3,2
)a
left join volvo_wechat_live.es_car_owners o on a.unionid=o.unionid -- 公众号用户unionid存在为空,会造成结果open_id为空
-- where o.unionid='ol07G0YY4Kvua_GyCuf2DFDVQD_4'
GROUP BY 1,2,3
order by 4 desc 
) a 
where a.type in (1,2,3,4,8,9)

#警示数据
select a.type,count(1) nums
from (
	SELECT a.日期,o.open_id,a.unionid
	,case when sum(case when a.click='DY' then 1 else 0 end )=1 and sum(case when a.click='试驾' then 1 else 0 end )=0 and sum(case when a.click='注册' then 1 else 0 end )=0 then 1 
				when sum(case when a.click='DY' then 1 else 0 end )=1 and sum(case when a.click='试驾' then 1 else 0 end )=1 and sum(case when a.click='注册' then 1 else 0 end )=0 then 2 
				when sum(case when a.click='DY' then 1 else 0 end )=1 and sum(case when a.click='试驾' then 1 else 0 end )=0 and sum(case when a.click='注册' then 1 else 0 end )=1 then 3 
				when sum(case when a.click='DY' then 1 else 0 end )=1 and sum(case when a.click='试驾' then 1 else 0 end )=1 and sum(case when a.click='注册' then 1 else 0 end )=1 then 4
				when sum(case when a.click='DY' then 1 else 0 end )=0 and sum(case when a.click='试驾' then 1 else 0 end )=0 and sum(case when a.click='注册' then 1 else 0 end )=1 then 5
				when sum(case when a.click='DY' then 1 else 0 end )=0 and sum(case when a.click='试驾' then 1 else 0 end )=1 and sum(case when a.click='注册' then 1 else 0 end )=0 then 6
				when sum(case when a.click='DY' then 1 else 0 end )=0 and sum(case when a.click='试驾' then 1 else 0 end )=1 and sum(case when a.click='注册' then 1 else 0 end )=1 then 7 
				else null end type	-- type(1,2,3,4)点击订阅的用户推送,type(5,6,7)没点击订阅的用户不推送
	from(
		#获取点击注册和预约试驾用户unionid(注册tcode存在第一次点击没有埋点)
		select DISTINCT e.unionid
		,case when json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7' then '注册' -- 注册tcode如有变化修改这里
					when json_extract(t.data,'$.tcode')='5338621B0499415CBC82CE021DCC73B5' then '试驾' -- 试驾tcode如有变化修改这里
					else null end click
		,DATE(t.date) 日期
		from track.track t 
		left join authentication.tm_user u on CAST(u.user_id AS VARCHAR)=t.usertag
		left join authentication.tm_emp e on e.emp_id=u.emp_id
		-- where t.date>='2021-08-18'
		where t.date BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
		and (json_extract(t.data,'$.tcode')='5338621B0499415CBC82CE021DCC73B5' -- 试驾(同上)
		or json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7') -- 注册(同上)
		union ALL
		#获取公众号回复DY用户unionid
		select DISTINCT o.unionid
		-- ,l.title click,DATE(l.create_time) 日期
		,'DY' click,DATE(l.create_time) 日期
		from volvo_wechat_live.es_wechat_reply_log l
		left join volvo_wechat_live.es_car_owners o on l.openid=o.open_id
		-- where l.create_time>='2021-08-18'
		where l.create_time BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
		and l.title in ('DY','dy','Dy','dY')
		order by 3,2
	)a
	left join volvo_wechat_live.es_car_owners o on a.unionid=o.unionid -- 公众号用户unionid存在为空,会造成结果open_id为空
	GROUP BY 1,2,3
	order by 1,2
) a 
where a.type in (1,2,3,4)
GROUP BY 1 order by 1 

