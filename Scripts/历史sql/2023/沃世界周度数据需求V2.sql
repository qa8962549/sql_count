-- 沃世界数据需求(周一 to shangkun)
-- 需求:上周一到上周日的沃世界周度数据
-- created by curlyan
-- 2021/12/7
-- 埋点测试(这里填写自己的user_id，user_id在会员表中查找)
select * from track.track t where t.usertag = '6039075' order by t.`date` desc
# 沃世界周度数据

	#小程序新增注册数--k
	select DATE_SUB(CURDATE(),INTERVAL 1 DAY) 日期,count(1) 小程序新增注册数
	from member.tc_member_info m
	where m.member_status<>60341003 and m.is_deleted=0
	and m.create_time >=DATE_SUB(CURDATE(),INTERVAL 7 DAY) and m.create_time <CURDATE()
	GROUP BY 1

-- 1 预约试驾
SELECT 
count(1) 预约试驾提交数
,count(case when a.预约状态='已到店' then 1 else null end ) 到店人数
,count(case when a.预约状态='已到店' and a.订单状态 is not null then 1 else null end ) 订单数
FROM(
	SELECT DISTINCT ta.APPOINTMENT_ID
	,ta.OWNER_CODE 经销商
	,ta.ONE_ID
	,CAST(ta.CUSTOMER_BUSINESS_ID AS varchar) 商机ID
	,cast(ta.POTENTIAL_CUSTOMERS_ID AS varchar) 潜客ID
	,ta.CUSTOMER_NAME 姓名
	,ta.CUSTOMER_PHONE 手机号
	,tc.CODE_CN_DESC 预约状态
	,ta.DATA_SOURCE
	,ta.CREATED_AT
	,ta.IS_DELETED
	,ta.INVITATIONS_DATE 预计到店日期
	,ta.ARRIVAL_DATE 实际到店日期
	,tso.CREATED_AT 订单日期
	,tc1.CODE_CN_DESC 订单状态
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
	LEFT JOIN (
		# 车辆订单
		SELECT *,ROW_NUMBER() over(PARTITION BY CUSTOMER_BUSINESS_ID,CUSTOMER_ACTIVITY_ID ORDER BY CREATED_AT DESC) rk
		FROM cyxdms_retail.tt_sales_orders
		WHERE IS_DELETED = 0 
		AND SO_STATUS IN (14041002,14041003,14041008,14041011)
	) tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID AND tso.created_at > ta.CREATED_AT 
	LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS 
	WHERE 
-- 	ta.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
	 ta.APPOINTMENT_TYPE = 70691002
	AND ta.DATA_SOURCE = 'C'
) a ;

-- 2 售后养修预约
SELECT COUNT(IF(tam.MAINTAIN_STATUS NOT IN (80671005,80671007,80671011),1,null)) 预约数
,COUNT(IF(tam.MAINTAIN_STATUS IN (80671002,80671003,80671004,80671008,80671009),1,null)) 进厂数
,COUNT(IF(tam.MAINTAIN_STATUS IN (80671008,80671009),1,null)) 成功数
FROM cyx_appointment.tt_appointment_maintain tam 
JOIN cyx_appointment.tt_appointment ta ON tam.APPOINTMENT_ID = ta.APPOINTMENT_ID
WHERE tam.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
AND ta.DATA_SOURCE = 'C';
-- and ta.IS_APP=0;

-- 3 周活跃度
select 
count(DISTINCT case when m.is_vehicle=1 then m.id else null end) 车主活跃数,
count(DISTINCT case when m.is_vehicle=0 then m.id else null end) 粉丝活跃数
from track.track t 
join member.tc_member_info m on CAST(m.user_id AS VARCHAR)=t.usertag and m.is_deleted=0 and m.member_status<>60341003 -- 排除黑名单用户
where t.date>m.create_time -- 排除注册行为
and t.date between '2022-08-22' AND '2022-08-28 23:59:59'


-- 4 公众号菜单栏周度PVUV
select count(1) PV
,count(DISTINCT t.usertag) UV
from track.track t 
left join member.tc_member_info m on CAST(m.user_id AS VARCHAR)=t.usertag
where t.date between '2022-08-22' AND '2022-08-28 23:59:59'
and json_extract(t.data,'$.tcode') in (
'27638C2A67FF4276BC70B9AD9E15C42D',
'F7C7ECAFD6794B39B03A79CE044EE9DB',
'8950A8746D1B4C11AD04C63F5DF8F874',
'D6D3ED45342845E5ABAF5E158CDBE0B8',
'5308C69D582E4055889030729D45EBFF',
'7E760D98634C46929998A74EBFA65D11',
'64F9E51207DC459AA366091BD6828914',
'D78AF2415C7B40C08CF6A092E7D6F595',
'54F0EB9BAA9F447D95CA3F9EB4F1CCC5',
'E476E8CAADE34F36B6C212663F78D16F',
'12B882A2A6E942D6BDCDFE0FC61E1D3E',
'DF59CC0CBA3C48F7BAAB1F42E55794EF',
'10A17F4E514A4EB18029289030D1FE2B',
'6C287B9D07B04FA99593EDC7DFDDB885', -- 11月(11月活动月历)
-- '0640691971694D08A80462E119AEC6C8', -- 12月(12月活动月历)
'65C9E4B824E6461096A2C2AF666D32CC', -- 1月(1月活动月历)
'CDB6035FF2204FE7ABE3E5E0157EAB17', -- 2月(2月活动月历)
'5525C03279944022B7F0ADA908F8CC4B', -- 3月(沃的活动)
'4FB667B517E54E379FB6EF2CC02F7693', -- 4月(沃的活动)
'D0AE92CA36A341CDA891DDB94156AF4F', -- 5月(沃的活动)
'5FC5EB1089F34B90B648162E94D3A869', -- 6月(沃的活动)
'1201F0E828494419BA4EA989DC7312B6' -- 7月(沃的活动)
'1201F0E828494419BA4EA989DC7312B6' -- 8月活动月历
) ; 

-- 5 我的页面预约试驾

-- by week
select count(DISTINCT t.usertag) 点击用户数
from track.track t 
where t.date between '2022-08-22' AND '2022-08-28 23:59:59'
and t.typeid='NEWBIE_MINE_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='预约试驾_MINE_CLICK';

-- 试驾数 (提交用户数)
select count(1)
from (
select m.id memberid,a.one_id cust_id,a.CREATED_AT 预约时间,t.active_name 沃世界来源渠道
from cyx_appointment.tt_appointment a 
left join activity.cms_active t on a.CHANNEL_ID=t.uid
left join (
	#存在cust_id一对多memberid,所以获取最新的cust_id对应的memberid
	select m.*
	from (
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m
		GROUP BY 1)a 
	left JOIN member.tc_member_info m on a.mid=m.ID
) m on a.ONE_ID=m.cust_id
where a.APPOINTMENT_TYPE=70691002  -- 预约类型:试驾
and a.DATA_SOURCE='C' -- 试驾来源: C端
and a.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
and t.active_name = '3.0改版-我的页面-预约试驾'
order by 3 desc 
) a 

-- 6 商城页面预约试驾
-- by week 
select count(DISTINCT t.usertag)
from track.track t 
where t.date between '2022-08-22' AND '2022-08-28 23:59:59'
and t.typeid='XWSJXCX_QRCODE_V' 
and json_extract(t.`data`,'$.embeddedpoint')='shop_banner_CLICK'
and json_extract(t.`data`,'$.tcode')='DB0BB45A12634D618283307799A9ADEC';

-- by day
select DATE(t.date),count(DISTINCT t.usertag)
from track.track t 
where t.date between '2022-08-22' AND '2022-08-28 23:59:59'
and t.typeid='XWSJXCX_QRCODE_V' 
and json_extract(t.`data`,'$.embeddedpoint')='shop_banner_CLICK'
and json_extract(t.`data`,'$.tcode')='DB0BB45A12634D618283307799A9ADEC'
GROUP BY 1 with rollup order by 1 ;
-- 试驾数
select DATE(a.`预约时间`),count(1)
from (
select m.id memberid,a.one_id cust_id,a.CREATED_AT 预约时间,t.active_name 沃世界来源渠道
from cyx_appointment.tt_appointment a 
left join activity.cms_active t on a.CHANNEL_ID=t.uid
left join (
	#存在cust_id一对多memberid,所以获取最新的cust_id对应的memberid
	select m.*
	from (
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m
		GROUP BY 1)a 
	left JOIN member.tc_member_info m on a.mid=m.ID
) m on a.ONE_ID=m.cust_id
where a.APPOINTMENT_TYPE=70691002  -- 预约类型:试驾
and a.DATA_SOURCE='C' -- 试驾来源: C端
and a.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
and t.uid='9I6E6606F1'
order by 3 desc 
) a 
GROUP BY 1 order by 1 ;



-- 7 小程序引流公众号数据

-- 点击数 by week
select count(DISTINCT t.usertag) 点击数
from track.track t 
where t.date between '2022-08-22' AND '2022-08-28 23:59:59'
and t.typeid='NEWBIE_MINE_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='MINE_CLICK_ISOWNER'
and json_extract(t.`data`,'$.title')='沃尔沃汽车沃世界服务号'

-- 关注数 by week 
select count(DISTINCT l.open_id) 关注用户数
from volvo_wechat_live.es_qr_code_logs l 
where l.create_time between '2022-08-22' AND '2022-08-28 23:59:59'
and l.qr_code_id=1917 and l.eventtype='subscribe'


-- 本周期注册数
select count(1) 注册数
from member.tc_member_info m 
where m.CREATE_TIME between '2022-08-22' AND '2022-08-28 23:59:59'
and m.MEMBER_STATUS<>60341003 and m.IS_DELETED=0;


# 沃世界日活跃人数  用日报数据
select DATE(t.date) 日期,count(DISTINCT m.id) 活跃用户数
from track.track t 
JOIN MEMBER.tc_member_info m ON cast(m.USER_ID AS varchar) = t.usertag and m.member_status<>60341003 and m.is_deleted=0
where t.date between '2022-08-22' AND '2022-08-28 23:59:59'
and t.date>m.member_time
GROUP BY 1 order by 1;


# 沃世界日拉新人数
select DATE(m.CREATE_TIME),count(1)
,count(case when m.IS_VEHICLE=1 then m.ID else null end) 车主数
,count(case when m.IS_VEHICLE=0 then m.ID else null end) 粉丝数
from member.tc_member_info m 
where m.IS_DELETED=0 and m.MEMBER_STATUS <> 60341003
and m.CREATE_TIME between '2022-08-22' AND '2022-08-28 23:59:59'
GROUP BY 1 order by 1 ; 

# 预约试驾周度数据   预约试驾活动来源
SELECT concat(DATE_FORMAT((DATE_SUB(now(),INTERVAL 7 day)),'%Y/%m/%d'),'-',DATE_FORMAT(DATE_SUB(now(),INTERVAL 1 day),'%Y/%m/%d')) 日期,a.沃世界来源渠道,count(1) 
from (
select m.id memberid,m.member_phone,a.one_id cust_id,a.CREATED_AT 预约时间,t.active_name 沃世界来源渠道
from cyx_appointment.tt_appointment a 
left join activity.cms_active t on a.CHANNEL_ID=t.uid
left join (
	#存在cust_id一对多memberid,所以获取最新的cust_id对应的memberid
	select m.*
	from (
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m
		GROUP BY 1)a 
	left JOIN member.tc_member_info m on a.mid=m.ID
) m on a.ONE_ID=m.cust_id
where a.APPOINTMENT_TYPE=70691002  -- 预约类型:试驾
and a.DATA_SOURCE='C' -- 试驾来源: C端
and a.ONE_ID is not null and a.ONE_ID<>''
and a.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
-- and t.active_name='沃世界预约'  
order by 3 desc 
) a
where a.沃世界来源渠道 is not null 
GROUP BY 2 order by 2 desc ;

-- 公众号邀你试驾卡片
select count(1) 提交试驾数
from (
select DISTINCT a.one_id,date(a.CREATED_AT) adate
from cyx_appointment.tt_appointment a 
where a.APPOINTMENT_TYPE=70691002 
and a.DATA_SOURCE='C'
and a.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
and a.CHANNEL_ID='EYVCT6UZC5'
) a 

# 公众号菜单栏周度数据   预约试驾周度数据
select concat(DATE_FORMAT((DATE_SUB(now(),INTERVAL 8 day)),'%Y/%m/%d'),'-',DATE_FORMAT(DATE_SUB(now(),INTERVAL 1 day),'%Y/%m/%d')) 日期,x.*
from 
(
select case 	-- 沃选车
							-- when replace(json_extract(t.data,'$.tcode'),'"','')='8950A8746D1B4C11AD04C63F5DF8F874' then '沃的活动' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='5308C69D582E4055889030729D45EBFF' then '官方直售' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='64F9E51207DC459AA366091BD6828914' then '金融方案' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='27638C2A67FF4276BC70B9AD9E15C42D' then '车型专区' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='D6D3ED45342845E5ABAF5E158CDBE0B8' then '查找经销商' 
							-- 沃服务
							when replace(json_extract(t.data,'$.tcode'),'"','')='D78AF2415C7B40C08CF6A092E7D6F595' then '养修预约' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='54F0EB9BAA9F447D95CA3F9EB4F1CCC5' then '免费取送车' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='E476E8CAADE34F36B6C212663F78D16F' then '充电桩安装' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='12B882A2A6E942D6BDCDFE0FC61E1D3E' then '充电专区' 
							-- 沃探索
							when replace(json_extract(t.data,'$.tcode'),'"','')='F7C7ECAFD6794B39B03A79CE044EE9DB' then '沃世界主场' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='7E760D98634C46929998A74EBFA65D11' then '沃商城' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='10A17F4E514A4EB18029289030D1FE2B' then '车主俱乐部' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='DF59CC0CBA3C48F7BAAB1F42E55794EF' then '车主故事征集' 
							-- when replace(json_extract(t.data,'$.tcode'),'"','')='6C287B9D07B04FA99593EDC7DFDDB885' then '沃的活动月历' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='65C9E4B824E6461096A2C2AF666D32CC' then '活动预告'  -- CDB6035FF2204FE7ABE3E5E0157EAB17
							when replace(json_extract(t.data,'$.tcode'),'"','')='CDB6035FF2204FE7ABE3E5E0157EAB17' then '活动预告'
							when replace(json_extract(t.data,'$.tcode'),'"','')='5525C03279944022B7F0ADA908F8CC4B' then '活动预告'
							when replace(json_extract(t.data,'$.tcode'),'"','')='4FB667B517E54E379FB6EF2CC02F7693' then '活动预告'
							when replace(json_extract(t.data,'$.tcode'),'"','')='D0AE92CA36A341CDA891DDB94156AF4F' then '活动预告'
							when replace(json_extract(t.data,'$.tcode'),'"','')='5FC5EB1089F34B90B648162E94D3A869' then '活动预告'
							else null end 页面
,count(1) PV
,count(DISTINCT t.usertag) UV
from track.track t 
left join member.tc_member_info m on CAST(m.user_id AS VARCHAR)=t.usertag
where t.date between '2022-08-22' AND '2022-08-28 23:59:59'
and json_extract(t.data,'$.tcode') in (
'27638C2A67FF4276BC70B9AD9E15C42D',
'F7C7ECAFD6794B39B03A79CE044EE9DB',
-- '8950A8746D1B4C11AD04C63F5DF8F874',
'D6D3ED45342845E5ABAF5E158CDBE0B8',
'5308C69D582E4055889030729D45EBFF',
'7E760D98634C46929998A74EBFA65D11',
'64F9E51207DC459AA366091BD6828914',
'D78AF2415C7B40C08CF6A092E7D6F595',
'54F0EB9BAA9F447D95CA3F9EB4F1CCC5',
'E476E8CAADE34F36B6C212663F78D16F',
'12B882A2A6E942D6BDCDFE0FC61E1D3E',
'DF59CC0CBA3C48F7BAAB1F42E55794EF',
'10A17F4E514A4EB18029289030D1FE2B',
-- '6C287B9D07B04FA99593EDC7DFDDB885',
-- '0640691971694D08A80462E119AEC6C8',
'65C9E4B824E6461096A2C2AF666D32CC',
'CDB6035FF2204FE7ABE3E5E0157EAB17', -- 2月活动月历
'5525C03279944022B7F0ADA908F8CC4B', -- 3月(沃的活动)
'4FB667B517E54E379FB6EF2CC02F7693', -- 4月
'D0AE92CA36A341CDA891DDB94156AF4F', -- 5月
'5FC5EB1089F34B90B648162E94D3A869', -- 6月
'1201F0E828494419BA4EA989DC7312B6', -- 7月(沃的活动)
'1201F0E828494419BA4EA989DC7312B6' -- 8月活动月历
) 
GROUP BY 1 order by 2 desc
) x 
where x.页面 is not null 

### 预约试驾周度数据
-- 试驾数 (提交用户数)
select count(1)
from (
select m.id memberid,a.one_id cust_id,a.CREATED_AT 预约时间,t.active_name 沃世界来源渠道
from cyx_appointment.tt_appointment a 
left join activity.cms_active t on a.CHANNEL_ID=t.uid
left join (
	#存在cust_id一对多memberid,所以获取最新的cust_id对应的memberid
	select m.*
	from (
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m
		GROUP BY 1)a 
	left JOIN member.tc_member_info m on a.mid=m.ID
) m on a.ONE_ID=m.cust_id
where a.APPOINTMENT_TYPE=70691002  -- 预约类型:试驾
and a.DATA_SOURCE='C' -- 试驾来源: C端
and a.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
and t.active_name = '3.0改版-我的页面-预约试驾'
order by 3 desc 
) a 

-- 试驾数  (提交用户数)  小程序
select DATE(a.`预约时间`),count(1)
from (
select m.id memberid,a.one_id cust_id,a.CREATED_AT 预约时间,t.active_name 沃世界来源渠道
from cyx_appointment.tt_appointment a 
left join activity.cms_active t on a.CHANNEL_ID=t.uid
left join (
	#存在cust_id一对多memberid,所以获取最新的cust_id对应的memberid
	select m.*
	from (
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m
		GROUP BY 1)a 
	left JOIN member.tc_member_info m on a.mid=m.ID
) m on a.ONE_ID=m.cust_id
where a.APPOINTMENT_TYPE=70691002  -- 预约类型:试驾
and a.DATA_SOURCE='C' -- 试驾来源: C端
and a.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
and t.active_name = '3.0改版-我的页面-预约试驾'
order by 3 desc 
) a 
GROUP BY 1 with ROLLUP order by 1 ;

-- 试驾转化  公众号
select count(1) 提交试驾数
from (
select DISTINCT a.one_id,date(a.CREATED_AT) adate
from cyx_appointment.tt_appointment a 
where a.APPOINTMENT_TYPE=70691002 
and a.DATA_SOURCE='C'
and a.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
and a.CHANNEL_ID='EYVCT6UZC5'
) a 



### 公众号菜单栏周度点击数据
select date(t.date) 日期
,count(1) PV
,count(DISTINCT t.usertag) UV
from track.track t 
left join member.tc_member_info m on CAST(m.user_id AS VARCHAR)=t.usertag
where t.date between '2022-08-22' AND '2022-08-28 23:59:59'
and json_extract(t.data,'$.tcode') in (
'27638C2A67FF4276BC70B9AD9E15C42D',
'F7C7ECAFD6794B39B03A79CE044EE9DB',
-- '8950A8746D1B4C11AD04C63F5DF8F874',
'D6D3ED45342845E5ABAF5E158CDBE0B8',
'5308C69D582E4055889030729D45EBFF',
'7E760D98634C46929998A74EBFA65D11',
'64F9E51207DC459AA366091BD6828914',
'D78AF2415C7B40C08CF6A092E7D6F595',
'54F0EB9BAA9F447D95CA3F9EB4F1CCC5',
'E476E8CAADE34F36B6C212663F78D16F',
'12B882A2A6E942D6BDCDFE0FC61E1D3E',
'DF59CC0CBA3C48F7BAAB1F42E55794EF',
'10A17F4E514A4EB18029289030D1FE2B',
-- '6C287B9D07B04FA99593EDC7DFDDB885',
-- '0640691971694D08A80462E119AEC6C8',
'65C9E4B824E6461096A2C2AF666D32CC',
'CDB6035FF2204FE7ABE3E5E0157EAB17',
'5525C03279944022B7F0ADA908F8CC4B',
'4FB667B517E54E379FB6EF2CC02F7693',
'D0AE92CA36A341CDA891DDB94156AF4F',
'5FC5EB1089F34B90B648162E94D3A869', -- 6月
'1201F0E828494419BA4EA989DC7312B6', -- 7月(沃的活动)
'1201F0E828494419BA4EA989DC7312B6' -- 8月活动月历
)
GROUP BY 1 order by 1;

select a.日期
,max(case when a.页面='官方直售' then a.PV else null end) 官方直售PV
,max(case when a.页面='官方直售' then a.UV else null end) 官方直售UV
,max(case when a.页面='金融方案' then a.PV else null end) 金融方案PV
,max(case when a.页面='金融方案' then a.UV else null end) 金融方案UV
,max(case when a.页面='车型专区' then a.PV else null end) 车型专区PV
,max(case when a.页面='车型专区' then a.UV else null end) 车型专区UV
,max(case when a.页面='查找经销商' then a.PV else null end) 查找经销商PV
,max(case when a.页面='查找经销商' then a.UV else null end) 查找经销商UV
,max(case when a.页面='沃家客服' then a.PV else null end) 沃家客服PV
,max(case when a.页面='沃家客服' then a.UV else null end) 沃家客服UV
,max(case when a.页面='养修预约' then a.PV else null end) 养修预约PV
,max(case when a.页面='养修预约' then a.UV else null end) 养修预约UV
,max(case when a.页面='免费取送车' then a.PV else null end) 免费取送车PV
,max(case when a.页面='免费取送车' then a.UV else null end) 免费取送车UV
,max(case when a.页面='充电桩安装' then a.PV else null end) 充电桩安装PV
,max(case when a.页面='充电桩安装' then a.UV else null end) 充电桩安装UV
,max(case when a.页面='充电专区' then a.PV else null end) 充电专区PV
,max(case when a.页面='充电专区' then a.UV else null end) 充电专区UV
,max(case when a.页面='沃世界主场' then a.PV else null end) 沃世界主场PV
,max(case when a.页面='沃世界主场' then a.UV else null end) 沃世界主场UV
-- ,max(case when a.页面='沃的活动' then a.PV else null end) 沃的活动PV
-- ,max(case when a.页面='沃的活动' then a.UV else null end) 沃的活动UV
,max(case when a.页面='沃的活动月历' then a.PV else null end) 沃的活动PV
,max(case when a.页面='沃的活动月历' then a.UV else null end) 沃的活动UV
,max(case when a.页面='沃商城' then a.PV else null end) 沃商城PV
,max(case when a.页面='沃商城' then a.UV else null end) 沃商城UV
,max(case when a.页面='车主俱乐部' then a.PV else null end) 车主俱乐部PV
,max(case when a.页面='车主俱乐部' then a.UV else null end) 车主俱乐部UV
,max(case when a.页面='车主故事征集' then a.PV else null end) 车主故事征集PV
,max(case when a.页面='车主故事征集' then a.UV else null end) 车主故事征集UV
from (
	select case when replace(json_extract(t.data,'$.tcode'),'"','')='27638C2A67FF4276BC70B9AD9E15C42D' then '车型专区' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='F7C7ECAFD6794B39B03A79CE044EE9DB' then '沃世界主场' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='8950A8746D1B4C11AD04C63F5DF8F874' then '沃的活动' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='D6D3ED45342845E5ABAF5E158CDBE0B8' then '查找经销商' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='5308C69D582E4055889030729D45EBFF' then '官方直售' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='7E760D98634C46929998A74EBFA65D11' then '沃商城' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='64F9E51207DC459AA366091BD6828914' then '金融方案' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='D78AF2415C7B40C08CF6A092E7D6F595' then '养修预约' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='54F0EB9BAA9F447D95CA3F9EB4F1CCC5' then '免费取送车' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='E476E8CAADE34F36B6C212663F78D16F' then '充电桩安装' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='12B882A2A6E942D6BDCDFE0FC61E1D3E' then '充电专区' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='DF59CC0CBA3C48F7BAAB1F42E55794EF' then '车主故事征集' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='10A17F4E514A4EB18029289030D1FE2B' then '车主俱乐部' 
							when replace(json_extract(t.data,'$.tcode'),'"','')='6C287B9D07B04FA99593EDC7DFDDB885' then '沃的活动月历' -- 11月
							when replace(json_extract(t.data,'$.tcode'),'"','')='0640691971694D08A80462E119AEC6C8' then '沃的活动月历' -- 12月
							when replace(json_extract(t.data,'$.tcode'),'"','')='65C9E4B824E6461096A2C2AF666D32CC' then '沃的活动月历'  -- 1月
							when replace(json_extract(t.data,'$.tcode'),'"','')='CDB6035FF2204FE7ABE3E5E0157EAB17' then '沃的活动月历' -- 2月 5525C03279944022B7F0ADA908F8CC4B
							when replace(json_extract(t.data,'$.tcode'),'"','')='5525C03279944022B7F0ADA908F8CC4B' then '沃的活动月历'  -- 3月
							when replace(json_extract(t.data,'$.tcode'),'"','')='4FB667B517E54E379FB6EF2CC02F7693' then '沃的活动月历'  -- 4月
							when replace(json_extract(t.data,'$.tcode'),'"','')='D0AE92CA36A341CDA891DDB94156AF4F' then '沃的活动月历'  -- 5月
							when replace(json_extract(t.data,'$.tcode'),'"','')='5FC5EB1089F34B90B648162E94D3A869' then '沃的活动月历'  -- 6月 
							when replace(json_extract(t.data,'$.tcode'),'"','')='1201F0E828494419BA4EA989DC7312B6' then '沃的活动月历'  -- 7月
							when replace(json_extract(t.data,'$.tcode'),'"','')='1201F0E828494419BA4EA989DC7312B6' then '沃的活动月历'  -- 8月
							else null end 页面
	,date(t.date) 日期
	,count(1) PV
	,count(DISTINCT t.usertag) UV
	from track.track t 
	left join member.tc_member_info m on CAST(m.user_id AS VARCHAR)=t.usertag
	where t.date between '2022-08-22' AND '2022-08-28 23:59:59'
	and json_extract(t.data,'$.tcode') in (
	'27638C2A67FF4276BC70B9AD9E15C42D',
	'F7C7ECAFD6794B39B03A79CE044EE9DB',
	'8950A8746D1B4C11AD04C63F5DF8F874',
	'D6D3ED45342845E5ABAF5E158CDBE0B8',
	'5308C69D582E4055889030729D45EBFF',
	'7E760D98634C46929998A74EBFA65D11',
	'64F9E51207DC459AA366091BD6828914',
	'D78AF2415C7B40C08CF6A092E7D6F595',
	'54F0EB9BAA9F447D95CA3F9EB4F1CCC5',
	'E476E8CAADE34F36B6C212663F78D16F',
	'12B882A2A6E942D6BDCDFE0FC61E1D3E',
	'DF59CC0CBA3C48F7BAAB1F42E55794EF',
	'10A17F4E514A4EB18029289030D1FE2B',
	'6C287B9D07B04FA99593EDC7DFDDB885',
	'0640691971694D08A80462E119AEC6C8',
	'65C9E4B824E6461096A2C2AF666D32CC',
	'CDB6035FF2204FE7ABE3E5E0157EAB17',
	'5525C03279944022B7F0ADA908F8CC4B',
	'4FB667B517E54E379FB6EF2CC02F7693',
	'D0AE92CA36A341CDA891DDB94156AF4F',
	'5FC5EB1089F34B90B648162E94D3A869',
	'1201F0E828494419BA4EA989DC7312B6'
)
	GROUP BY 1,2 order by 1,2
) a GROUP BY 1 order by 1 ;


------------------------------------------------------------------------------;
#公众号欢迎语周度数据 优化
select a.日期
,a.注册PV,a.注册UV,b.注册数
,a.`试驾PV`,a.试驾UV,ifnull(c.试驾数,0)
,ifnull(a.`服务PV`,0),ifnull(a.`服务UV`,0)
,ifnull(a.`即刻参与PV`,0),ifnull(a.`即刻参与UV`,0)
,ifnull(a.`立即下定PV`,0),ifnull(a.`立即下定UV`,0)
,ifnull(a.回复在看UV,0)
,ifnull(a.点击沃世界攻略UV,0)
from (
	select a.`日期`
	,count(case when a.click='注册' then a.usertag else null end ) 注册PV
	,count(DISTINCT case when a.click='注册' then a.usertag else null end ) 注册UV
	,count(case when a.click='试驾' then a.usertag else null end ) 试驾PV
	,count(DISTINCT case when a.click='试驾' then a.usertag else null end ) 试驾UV
	,count(case when a.click='服务' then a.usertag else null end ) 服务PV
	,count(DISTINCT case when a.click='服务' then a.usertag else null end ) 服务UV
	,count(case when a.click='即刻参与' then a.usertag else null end ) 即刻参与PV
	,count(DISTINCT case when a.click='即刻参与' then a.usertag else null end ) 即刻参与UV
	,count(case when a.click='立即下定' then a.usertag else null end ) 立即下定PV
	,count(DISTINCT case when a.click='立即下定' then a.usertag else null end ) 立即下定UV
	,count(DISTINCT case when a.click='DY' then a.usertag else null end ) 回复在看UV
	,count(DISTINCT case when a.click='点击沃世界攻略' then a.usertag else null end ) 点击沃世界攻略UV
	from (
		#获取点击注册和预约试驾用户unionid(注册tcode存在第一次点击没有埋点)
		select t.usertag
		,case when json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7' then '注册' -- 注册tcode如有变化修改这里
					when json_extract(t.data,'$.tcode')='5338621B0499415CBC82CE021DCC73B5' then '试驾' -- 试驾tcode如有变化修改这里
					when json_extract(t.data,'$.tcode')='3A3579491DCF472CB46AAB44CC9AF480' then '服务' -- 服务tcode如有变化修改这里
					when json_extract(t.data,'$.tcode')='4ED6C33AA748420EBF85727E931EC0C7' then '即刻参与' -- 服务tcode如有变化修改这里
					when json_extract(t.data,'$.tcode')='AE5D71F975C14048B3786097D21B45A3' then '立即下定' -- 服务tcode如有变化修改这里
					when json_extract(t.data,'$.tcode')='5625A16E5C844A9D8870578DB7F53F00' then '点击沃世界攻略' -- 服务tcode如有变化修改这里
					else null end click
		,DATE(t.date) 日期
		from track.track t  
		where t.date >='2022-08-22' and t.date<='2022-08-28 23:59:59'
		and (json_extract(t.data,'$.tcode')='5338621B0499415CBC82CE021DCC73B5' -- 试驾(同上)
		or json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7' -- (同上)
		or json_extract(t.data,'$.tcode')='3A3579491DCF472CB46AAB44CC9AF480' -- 车主服务(同上2022.3.7新增)
		or json_extract(t.data,'$.tcode')='4ED6C33AA748420EBF85727E931EC0C7' -- 即刻参与(同上2022.3.7新增)
		or json_extract(t.data,'$.tcode')='AE5D71F975C14048B3786097D21B45A3' -- 立即下定(同上2022.3.7新增)
		or json_extract(t.data,'$.tcode')='5625A16E5C844A9D8870578DB7F53F00' -- 点击沃世界攻略(同上2022.3.7新增)
		) 
		union ALL
		#获取公众号回复DY用户unionid
		select o.unionid usertag
		,'DY' click,DATE(l.create_time) 日期
		from volvo_wechat_live.es_wechat_reply_log l
		left join volvo_wechat_live.es_car_owners o on l.openid=o.open_id
		-- where DATE(l.create_time)='2022-03-07'
		where l.create_time >='2022-08-22' and l.create_time <='2022-08-28 23:59:59'
		and l.title ='在看'
		order by 3,2
	) a  
	GROUP BY 1 order by 1 
) a
left join (
	SELECT date(a.date) 日期,count(DISTINCT a.unionid) 注册数
	from(
		select DISTINCT e.unionid
		,case when json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7' then '注册' 
					when json_extract(t.data,'$.tcode')='5338621B0499415CBC82CE021DCC73B5' then '试驾'
					else null end click
		,m.id,t.date,m.create_time
		from track.track t 
		left join authentication.tm_user u on CAST(u.user_id AS VARCHAR)=t.usertag
		left join authentication.tm_emp e on e.emp_id=u.emp_id
		left join member.tc_member_info m on CAST(m.USER_ID AS VARCHAR)=t.usertag
		where t.date >='2022-08-22' and t.date<='2022-08-28 23:59:59'
		-- where t.date BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
		and json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7' -- 注册
		and date(t.date)=date(m.CREATE_TIME)
	)a
	GROUP BY 1
	order by 1
) b on a.日期=b.日期
left join (
	-- 试驾转化
	select a.adate 日期,count(1) 试驾数
	from (
	select DISTINCT a.one_id,date(a.CREATED_AT) adate
	from cyx_appointment.tt_appointment a 
	where a.APPOINTMENT_TYPE=70691002 
	and a.DATA_SOURCE='C'
	and a.CREATED_AT >='2022-08-22' and a.created_at<='2022-08-28 23:59:59'
	and a.CHANNEL_ID='EYVCT6UZC5'
	) a 
	GROUP BY 1 order by 1
) c on c.日期=a.日期
order by 1 ;



###### 公众号欢迎语周度数据 old
select a.*,ifnull(b.回复订阅用户数,0) 回复订阅用户数
from (
	-- 试驾注册PVUV
	SELECT a.日期
	,count(case when a.click='注册' then a.unionid else null end ) 点击注册PV
	,count(DISTINCT case when a.click='注册' then a.unionid else null end ) 点击注册UV
	,count(case when a.click='试驾' then a.unionid else null end ) 点击试驾PV
	,count(DISTINCT case when a.click='试驾' then a.unionid else null end ) 点击试驾UV
	from(
		select e.unionid-- ,t.usertag userid
		,case when json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7' then '注册' 
					when json_extract(t.data,'$.tcode')='5338621B0499415CBC82CE021DCC73B5' then '试驾'
					else null end click
		,DATE(t.date) 日期
		from track.track t 
		left join authentication.tm_user u on CAST(u.user_id AS VARCHAR)=t.usertag
		left join authentication.tm_emp e on e.emp_id=u.emp_id
		where t.date between '2022-08-22' AND '2022-08-28 23:59:59'
		-- where t.date BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
		and (json_extract(t.data,'$.tcode')='5338621B0499415CBC82CE021DCC73B5' -- 试驾
		or json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7') -- 注册
	)a
	GROUP BY 1
	order by 1
) a 
left join (
	-- 订阅数据
	select DATE(l.create_time) 日期
	,count(o.unionid) 回复订阅次数
	,count(DISTINCT o.unionid) 回复订阅用户数
	from volvo_wechat_live.es_wechat_reply_log l
	left join volvo_wechat_live.es_car_owners o on l.openid=o.open_id
	where l.create_time between '2022-08-22' AND '2022-08-28 23:59:59'
	-- where l.create_time BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
	and l.title ='在看'-- in ('DY','dy','Dy','dY')
	GROUP BY 1 order by 1 
)b on a.日期=b.日期
order by 1 ;


-- 注册转化
SELECT date(a.date),count(DISTINCT a.unionid)
from(
	select DISTINCT e.unionid
	,case when json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7' then '注册' 
				when json_extract(t.data,'$.tcode')='5338621B0499415CBC82CE021DCC73B5' then '试驾'
				else null end click
	,m.id,t.date,m.create_time
	from track.track t 
	left join authentication.tm_user u on CAST(u.user_id AS VARCHAR)=t.usertag
	left join authentication.tm_emp e on e.emp_id=u.emp_id
	left join member.tc_member_info m on CAST(m.USER_ID AS VARCHAR)=t.usertag
	where t.date between '2022-08-22' AND '2022-08-28 23:59:59'
	-- where t.date BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
	and json_extract(t.data,'$.tcode')='B797939E29824BE0AB10A44A4874FDC7' -- 注册
	and date(t.date)=date(m.CREATE_TIME)
)a
GROUP BY 1
order by 1 ;

-- 试驾转化
select a.adate,count(1) 提交试驾数
from (
select DISTINCT a.one_id,date(a.CREATED_AT) adate
from cyx_appointment.tt_appointment a 
where a.APPOINTMENT_TYPE=70691002 
and a.DATA_SOURCE='C'
and a.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
and a.CHANNEL_ID='EYVCT6UZC5'
) a 
GROUP BY 1 WITH ROLLUP 
order by 1


-------------------------------------------------


#活跃数
select DATE(t.date) 日期,count(DISTINCT m.id) 活跃用户数
from track.track t 
JOIN MEMBER.tc_member_info m ON cast(m.USER_ID AS varchar) = t.usertag and m.member_status<>60341003 and m.is_deleted=0
where t.date >= DATE_SUB(CURDATE(),INTERVAL 8 DAY) and t.date<CURDATE()
and t.date>m.member_time
GROUP BY 1 order by 1 ;

# 沃世界日拉新人数
select DATE(m.CREATE_TIME),count(1)
,count(case when m.IS_VEHICLE=1 then m.ID else null end) 车主数
,count(case when m.IS_VEHICLE=0 then m.ID else null end) 粉丝数
from member.tc_member_info m 
where m.IS_DELETED=0 and m.MEMBER_STATUS <> 60341003
and m.CREATE_TIME between '2022-08-22' AND '2022-08-28 23:59:59'
GROUP BY 1 order by 1 ; 


-- 21年日均
select DATE(m.create_time),count(1) '新增用户数'
from member.tc_member_info m
where m.member_status<>60341003 and m.is_deleted=0
and m.create_time >='2021-01-01' and m.create_time<'2022-01-01'
GROUP BY 1 order by 1 ;


select DATE(m.create_time),count(1) '新增用户数'
from member.tc_member_info m
where m.member_status<>60341003 and m.is_deleted=0
and m.create_time >= DATE_SUB('2022-08-28 23:59:59',INTERVAL 7 DAY) and m.create_time<='2022-08-28 23:59:59'
GROUP BY 1 with ROLLUP 
order by 1 ;



-- 沃世界预约试驾分渠道
SELECT a.沃世界来源渠道,count(1) 
from (
select m.id memberid,m.member_phone,a.one_id cust_id,a.CREATED_AT 预约时间,t.active_name 沃世界来源渠道
from cyx_appointment.tt_appointment a 
left join activity.cms_active t on a.CHANNEL_ID=t.uid
left join (
	#存在cust_id一对多memberid,所以获取最新的cust_id对应的memberid
	select m.*
	from (
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m
		GROUP BY 1)a 
	left JOIN member.tc_member_info m on a.mid=m.ID
) m on a.ONE_ID=m.cust_id
where a.APPOINTMENT_TYPE=70691002  -- 预约类型:试驾
and a.DATA_SOURCE='C' -- 试驾来源: C端
and a.ONE_ID is not null and a.ONE_ID<>''
and a.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
-- and t.active_name='沃世界预约'  
order by 3 desc 
) a
GROUP BY 1 order by 2 desc ;



