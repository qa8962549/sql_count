# 推荐购22Q3代码

# 经销商信息表： volvo_online_activity.recommend_buyv6_dealer
# 推荐购邀请人、被邀请人留资、试驾、购车数据表：volvo_online_activity.recommend_buyv6_invite_record r

# 注意事项
# 1、经销商区域划分-业务提供
# 2、经销商更新-销售部提供

# 【Q3推荐购】新增资料
# 市场活动代码：IBDMJULWSJTJGLZS2022VCCN
# 新人礼包券ID：3652
# 活动新增首页渠道：朋友圈海报（track：1715F001D695488C87EAF12B7F89F0C4）




###############################   推荐购日报   ###############################
# 推荐购日报有自动化PY代码，每天9点半自动跑完发送。

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
where r.create_time >= DATE_ADD(DATE_SUB(CURDATE(),INTERVAL 1 DAY),INTERVAL -DAY(DATE_SUB(CURDATE(),INTERVAL 1 DAY))+1 DAY)
and r.create_time < CURDATE()
and r.period = '2022q3'    -- 限制推荐购活动为22Q3
GROUP BY 1;




###############################   推荐购周报_每周一   ###############################
# 每周修改下时间，跑数后贴在隐藏的2个Sheet中即可，修改下Sheet1时间即可

# 1、一店一码扫码
select
l.qr_code_id,
count(1)PV,
count(DISTINCT l.open_id) UV
from volvo_wechat_live.es_qr_code_logs l 
where l.create_time >= '2022-09-19'    -- 每周修改时间
and l.create_time <= '2022-09-25 23:59:59'  	-- 每周修改时间
and l.qr_code_id in
(
	# 提取并去重长度为3的经销商CODE
	select DISTINCT d.qr_code_id
	from volvo_wechat_live.es_dealer_qrcode d 
	where LENGTH(d.campaign) = 3   -- 筛选长度为3的经销商CODE
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
from volvo_online_activity.recommend_buyv6_invite_record r    -- 推荐购邀请人、被邀请人留资、试驾、购车数据表
where r.create_time >= '2022-09-19'    -- 邀请人邀请时间
and r.create_time <= '2022-09-25 23:59:59'
and r.period = '2022q3'    -- 限制推荐购活动为22Q3
GROUP BY 1;



# 3、试驾数据
select
	r.dealer_code 经销商代码,
	count(case when r.试驾车型='XC40' then 1 else null end) XC40,
	count(case when r.试驾车型='XC40bev' then 1 else null end) XC40bev,
	count(case when r.试驾车型='XC60' then 1 else null end) XC60,
	count(case when r.试驾车型='XC90' then 1 else null end) XC90,
	count(case when r.试驾车型='S60' then 1 else null end) S60,
	count(case when r.试驾车型='S90' then 1 else null end) S90,
	count(case when r.试驾车型='V60' then 1 else null end) V60,
	count(case when r.试驾车型='V90' then 1 else null end) V90,
	count(case when r.试驾车型='C40' then 1 else null end) C40
from
(
	select r.dealer_code,
	case when r.test_drive_car='全新纯电C40' then 'C40'
		when r.test_drive_car='XC40 RECHARGE' then 'XC40bev'
		when r.test_drive_car='V90 Cross Country' then 'V90'
		else r.test_drive_car end 试驾车型
	from volvo_online_activity.recommend_buyv6_invite_record r    -- 推荐购邀请人、被邀请人留资、试驾、购车数据表
	where r.test_drive_status = 'Y'     -- 是否试驾 Y:已试驾   N：未试驾
	and r.create_time >= '2022-09-19'
	and r.create_time <= '2022-09-25 23:59:59'
	and r.period = '2022q3'    -- 限制推荐购活动为22Q3
) r
GROUP BY 1;



###############################   推荐购周报_每周五   ###############################
# 每周五跑上一周周五到这周四的数据，邮件里要写拉新、激活人数（仅限本周期）

-- 1、拉新
select
m.IS_VEHICLE 是否车主,
count(DISTINCT m.id)拉新人数
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) -- and m.is_vehicle = 0
where t.date >= '2022-09-16' and t.date <= '2022-09-22 23:59:59'      -- 每个周期修改一下时间
and t.typeid in ('XWSJXCX_OLD_NEW_ONLOAD_C','XWSJXCX_OLD_NEW_LZONLOAD_C')     -- 推荐购邀请人、被邀请人页面埋点
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
GROUP BY 1 with rollup    -- rollup表示把车主粉丝再进行求和
order by 1;


-- 2、召回
select
a.is_vehicle 是否车主,
count(DISTINCT a.usertag) 激活僵尸粉人数
from(
	-- 获取访问文章活动10分钟之前的最晚访问时间
	select t.usertag,b.is_vehicle,b.mdate,max(t.date) tdate
	from track.track t
	join (
		-- 获取访问文章活动的最早时间
		select t.usertag,m.IS_VEHICLE,min(t.date) mdate 
		from track.track t 
		join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
		where t.date >= '2022-09-16' and t.date <= '2022-09-22 23:59:59'              -- 每个周期修改一下时间
		and t.typeid in ('XWSJXCX_OLD_NEW_ONLOAD_C','XWSJXCX_OLD_NEW_LZONLOAD_C')       -- 推荐购邀请人、被邀请人页面埋点
		GROUP BY 1,2
	) b on b.usertag=t.usertag
	where t.date< DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
	GROUP BY 1,2,3
) a 
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY)
GROUP BY 1 with rollup
order by 1; 


# 3、活动声量
select
-- 活动声量PV
count(case when a.事件='01一店一码' then a.usertag else null end) 01一店一码,
count(case when a.事件='02沃的活动入口' then a.usertag else null end) 02沃的活动入口,
count(case when a.事件='03首页专题' then a.usertag else null end) 03首页专题,
count(case when a.事件='04沃的活动Banner' then a.usertag else null end) 04沃的活动Banner,
count(case when a.事件='05弹窗' then a.usertag else null end) 05弹窗,
count(case when a.事件='06朋友圈海报' then a.usertag else null end) 06朋友圈海报,
-- 活动声量UV
count(DISTINCT case when a.事件='01一店一码' then a.usertag else null end) 01一店一码,
count(DISTINCT case when a.事件='02沃的活动入口' then a.usertag else null end) 02沃的活动入口,
count(DISTINCT case when a.事件='03首页专题' then a.usertag else null end) 03首页专题,
count(DISTINCT case when a.事件='04沃的活动Banner' then a.usertag else null end) 04沃的活动Banner,
count(DISTINCT case when a.事件='05弹窗' then a.usertag else null end) 05弹窗,
count(DISTINCT case when a.事件='06朋友圈海报' then a.usertag else null end) 06朋友圈海报
from (
	SELECT 
	case when t.typeid='XWSJXCX_HOME_POPUP_BANNER_C' and json_extract(t.data,'$.url')='/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Fmarket-package%2Fmillion-recommend%2Ftemp%2Findex&tcode=D0392CB2BD4E4A7086463B3A0917F189' then '01一店一码'
		when json_extract(t.data,'$.path')='/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Fmarket-package%2Fmillion-recommend%2Ftemp%2Findex&tcode=82672574CFAE4706BEA6A6737554057A' then '02沃的活动入口'
		when json_extract(t.data,'$.tcode')='1CFD31C2E1324900A7C1BFD08EE89218' then '03首页专题'
		when json_extract(t.data,'$.url')='/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Fmarket-package%2Fmillion-recommend%2Ftemp%2Findex&tcode=16BB9CC641C24782B2C71A42CF68A43B' then '04沃的活动Banner'
		when json_extract(t.data,'$.url')='/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Fmarket-package%2Fmillion-recommend%2Ftemp%2Findex&tcode=18423BAD2AE542A59F223F26AC33B0C6' then '05弹窗'
		when t.`data` like '%1715F001D695488C87EAF12B7F89F0C4%' then '06朋友圈海报'
	else null end 事件,
	t.usertag,
	t.date
	from track.track t 
	where t.date BETWEEN '2022-09-16' and '2022-09-22 23:59:59'
) a 
where a.事件 is not null;


# 4、分享数据
select 
'分享数据' 页面,
count(1) PV,
count(DISTINCT t.usertag) UV
from `track`.track t
where t.`date` >= '2022-09-16'
and t.`date` <= '2022-09-22 23:59:59'
and t.typeid in ('XWSJXCX_OLD_NEW_FXHY_C','XWSJXCX_OLD_NEW_BCHB_C')    -- 推荐购邀请人、被邀请人页面埋点



# 线索、潜客、订单&领券核销数据

-- 5、线索
select
count(1)线索数
from customer.tt_clue_clean a 
left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
left join activity.cms_active c on a.campaign_id = c.uid
left join customer_business.tm_clue_source d on d.ID = c.active_channel
left join dictionary.tc_code e on a.clue_status = e.CODE_ID
left join basic_data.tm_model f on a.model_id = f.id
left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
left join (
    select 
        tm.id 经销商表ID,
        tm.ORG_ID 经销商组织ID,
        tm.COMPANY_CODE ,
        tg2.ID 大区组织ID,
        tg2.ORG_NAME ORG_NAME_big,
        tg1.ID 小区组织ID,
        tg1.ORG_NAME ORG_NAME_small,
        tm.COMPANY_NAME_CN ,
        tm.GROUP_COMPANY_NAME
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	) h on h.COMPANY_CODE = a.dealer_code
 left join dictionary.tc_code i on i.code_id = a.gender
where a.create_time between '2022-09-16' and '2022-09-22 23:59:59'
and c.active_code='IBDMJULWSJTJGLZS2022VCCN'   -- 22Q3推荐购市场活动代码
order by a.create_time;


-- 6、潜客
select count(1)潜客数
from customer.tt_pontential_customer a
left join customer_business.tt_customer_business b on b.POTENTIAL_CUSTOMERS_ID = a.id and b.IS_DELETED = 0
left join activity.cms_active c on b.MARKET_ACTIVITY = c.uid
left join customer_business.tm_clue_source d on d.ID = c.active_channel
left join dictionary.tc_code e on b.clue_status = e.CODE_ID
left join customer_business.tt_clue_intent f on f.CUSTOMER_BUSINESS_ID = b.CUSTOMER_BUSINESS_ID and f.IS_MAIN_INTENT = 10041001
left join basic_data.tm_model g on f.SECOND_ID = g.id
left join (
    select 
        tm.id 经销商表ID,
        tm.ORG_ID 经销商组织ID,
        tm.COMPANY_CODE ,
        tL2.ID 大区组织ID,
        tL2.ORG_NAME ORG_NAME_big,
        tg1.ID 小区组织ID,
        tg1.ORG_NAME ORG_NAME_small,
        tm.COMPANY_NAME_CN ,
        tm.GROUP_COMPANY_NAME
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
    ORDER BY tm.COMPANY_CODE ASC
) h on h.COMPANY_CODE = a.dealer_code
left join (
    select
        CUSTOMER_BUSINESS_ID,
        ARCHIVES_TIME,
        FIRST_PASSENGER_TIME,
        FIRST_DRIVE_TIME,
        FIRST_ORDER_TIME,
        DEFEAT_DATE,
        MIN_WORK_CALL_TIME,
        MAX_WORK_CALL_TIME,
        TOTAL_CALL_NUM,
        WORK_CALL_NUM,
        WORK_CONNECT_NUM,
        WORK_CONNECT_TIMES
    from
    customer_business.tt_business_statistics
) i on i.CUSTOMER_BUSINESS_ID = b.CUSTOMER_BUSINESS_ID
where b.created_at between '2022-09-16' and '2022-09-22 23:59:59'
	and c.active_code='IBDMJULWSJTJGLZS2022VCCN'      -- 22Q3推荐购市场活动代码
    and a.is_deleted = 0
	and e.CODE_CN_DESC not in ('待清洗','待分配','无效')
order by b.created_at;


-- 7、订单
select
count(DISTINCT a.`商机id`)订单数
from (
	select a.business_id 商机id,min(a.create_time) 最早线索创建时间
	from customer.tt_clue_clean a 
	left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
	left join activity.cms_active c on a.campaign_id = c.uid
	left join customer_business.tm_clue_source d on d.ID = c.active_channel
	left join dictionary.tc_code e on a.clue_status = e.CODE_ID
	left join basic_data.tm_model f on a.model_id = f.id
	left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
	 left join dictionary.tc_code i on i.code_id = a.gender
	where a.create_time between '2022-09-16' and '2022-09-22 23:59:59'
	and c.active_code='IBDMJULWSJTJGLZS2022VCCN'    -- 22Q3推荐购市场活动代码
	and e.CODE_CN_DESC not in ('待清洗','待分配','无效')
	GROUP BY 1 
) a 
join (
	select a.CUSTOMER_BUSINESS_ID 商机id ,min(a.CREATED_AT) 订单时间
	from cyxdms_retail.tt_sales_orders a 
	left join dictionary.tc_code g on g.code_id = a.SO_STATUS
	where a.BUSINESS_TYPE <> 14031002
	and a.IS_DELETED = 0
	-- and a.CREATED_AT  BETWEEN '2021-10-01' and '2021-10-07 23:59:59'
	and g.code_cn_desc in ('提交待审批','审批通过','已交车','退车中')
	GROUP BY 1 
) b on a.`商机id`=b.`商机id`;


# 8、领券总数
select
count(1)领券总数
from volvo_online_activity.recommend_buyv6_reward_record r    -- 推荐购卡券表
where r.create_time >= '2022-09-16' 
and r.create_time <= '2022-09-22 23:59:59'
and r.coupon_id is not null;


-- 9、核销总数
select
count(1)核销总数
from coupon.tt_coupon_verify v    -- 卡券核销表
where v.create_time >= '2022-09-09'
and v.create_time <= '2022-09-15 23:59:59'
and v.coupon_id = 3652   -- 22Q3卡券ID
and IS_DELETED=0;


# 10、推荐购周报邀请领券累计（明细）
SELECT
m.member_name '推荐人姓名'
,m.member_phone '推荐人手机号'
,m.id '推荐人mmberid'
,v.vin '推荐人VIN'
,r.invitee_name '被推荐人姓名'
,r.invitee_member_id '被推荐人memberid'
,r.phone '被推荐人留资手机号'
,r.province  '被推荐人省份'
,r.city  '被推荐人城市'
,d.simple_name '被推荐人意向经销商'
,r.dealer_code '经销商代码'
,r.intent_car '意向车型'
,t.invitations_date '预约日期'
,r.create_time '被推荐人留资时间'
,rr.phone '手机号'
,case when rr.member_id is null then '未领券/不符合SMM条件' else '发送成功' end '领券状态'
,c.*
#获取推荐记录
from volvo_online_activity.recommend_buyv6_invite_record r 
#获取推荐人信息
left join member.tc_member_info m on m.id=r.inviter_member_id and m.is_deleted=0 and m.member_status<>60341003
left join (
	#匹配推荐人VIN(取最近绑定VIN)
	select a.*
	from(
		select v.*,row_number() over(partition by v.member_id order by v.create_time desc ) rk
		from member.tc_member_vehicle v
		where v.is_deleted=0 ) a 
	where a.rk=1 
) v on v.member_id=m.id
left join volvo_online_activity.recommend_buyv6_reward_record rr on rr.reward_invite_id=r.id and rr.reward_type='00'
left join volvo_online_activity.recommend_buyv6_dealer d on r.dealer_code=d.code
left JOIN(
	#核销信息
	select --  t.coupon_id,
	m.id member_id,m.member_name username,t.coupon_detail_id
	,t.dealer '核销经销商'
	,replace(json_extract(t.other_info,'$.new_car_buyer'),'"','') '核销用户名'
	,m.member_phone '核销手机号'
	,replace(json_extract(t.other_info,'$.newcar_vincode'),'"','') '新车车架号'
	,replace(json_extract(t.other_info,'$.newcar_carmodel'),'"','') '新车车型'
	,t.operate_date '微信核销时间'
	from coupon.tt_coupon_verify t 
	join(
		#one_id与memberid一对多,取最近的memberid
		select m.*
		from(
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m 
		where m.member_status<>60341003 and m.is_deleted=0
		GROUP BY 1) a
		left join member.tc_member_info m on a.mid=m.ID
	)m on m.cust_id =t.customer_id 
	where t.coupon_id = 3652     -- 22Q3卡券ID
  and t.create_time BETWEEN '2022-09-16' and CURDATE()
	order by t.operate_date desc
) c on c.coupon_detail_id=rr.coupon_id
left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
where r.create_time BETWEEN '2022-09-16' and CURDATE()
and r.period = '2022q3'    -- 筛选推荐购22Q3
order by r.create_time;



# 11、留资累计
SELECT
a.dealer_code 经销商代码,
count(a.invitee_member_id) 累计留资数
from(
	select
	DISTINCT i.invitee_member_id,
	i.dealer_code
	from volvo_online_activity.recommend_buyv6_invite_record i
	where i.create_time >= '2022-07-01'
	and i.create_time < CURDATE()
	and i.test_drive_status <> 'N'
	and i.period = '2022q3'    -- 筛选推荐购22Q3
	order by 1
) a 
GROUP BY 1 order by 2 desc;



# 12、一店一码明细
select
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
	select DISTINCT m.open_id
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
	where t.date between '2022-07-15' and '2022-07-21 23:59:59'
	and t.typeid='XWSJXCX_HOME_POPUP_BANNER_C' 
	and json_extract(t.data,'$.url')='/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Fmarket-package%2Fmillion-recommend%2Ftemp%2Findex&tcode=D0392CB2BD4E4A7086463B3A0917F189'
) m on l.open_id = m.open_id
where l.create_time between '2022-07-12' and '2022-07-28 23:59:59'
and l.qr_code_id in (
	select DISTINCT d.qr_code_id
	from volvo_wechat_live.es_dealer_qrcode d 
	where LENGTH(d.campaign)=3
)  order by 4;



## 1、客诉查询
SELECT
m.member_name '推荐人姓名'
,m.member_phone '推荐人手机号'
,m.id '推荐人memberid'
,v.vin '推荐人VIN'
,r.invitee_name '被推荐人姓名'
,r.invitee_member_id '被推荐人memberid'
,r.phone '被推荐人留资手机号'
,r.province  '被推荐人省份'
,r.city  '被推荐人城市'
,d.simple_name '被推荐人意向经销商'
,r.dealer_code '经销商代码'
,r.intent_car '意向车型'
,t.invitations_date '预约日期'
,r.create_time '被推荐人留资时间'
,rr.phone '手机号'
,case when rr.member_id is null then '未领券/不符合SMM条件' else '发送成功' end '领券状态'
,c.*
#获取推荐记录
from volvo_online_activity.recommend_buyv6_invite_record r 
#获取推荐人信息
left join member.tc_member_info m on m.id=r.inviter_member_id and m.is_deleted=0 and m.member_status<>60341003
left join (
	#匹配推荐人VIN(取最近绑定VIN)
	select a.*
	from(
		select v.*,row_number() over(partition by v.member_id order by v.create_time desc ) rk
		from member.tc_member_vehicle v
		where v.is_deleted=0 ) a 
	where a.rk=1 
) v on v.member_id=m.id
left join volvo_online_activity.recommend_buyv6_reward_record rr on rr.reward_invite_id=r.id and rr.reward_type='00'
left join volvo_online_activity.recommend_buyv6_dealer d on r.dealer_code=d.code
left JOIN(
	#核销信息
	select --  t.coupon_id,
	m.id member_id,m.member_name username,t.coupon_detail_id
	,t.dealer '核销经销商'
	,replace(json_extract(t.other_info,'$.new_car_buyer'),'"','') '核销用户名'
	,m.member_phone '核销手机号'
	,replace(json_extract(t.other_info,'$.newcar_vincode'),'"','') '新车车架号'
	,replace(json_extract(t.other_info,'$.newcar_carmodel'),'"','') '新车车型'
	,t.operate_date '微信核销时间'
	from coupon.tt_coupon_verify t 
	join(
		#one_id与memberid一对多,取最近的memberid
		select m.*
		from(
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m 
		where m.member_status<>60341003 and m.is_deleted=0
		GROUP BY 1) a
		left join member.tc_member_info m on a.mid=m.ID
	)m on m.cust_id =t.customer_id 
	where t.coupon_id = 3652  -- 22Q3卡券ID
  and t.create_time >= '2022-07-01' and t.create_time <= CURDATE() 
	order by t.operate_date desc
) c on c.coupon_detail_id=rr.coupon_id
left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
where r.create_time >= '2022-07-01' and r.create_time <= CURDATE() 
-- and v.vin = 'LVYZBAKD3MP089446'  -- 推荐人VIN
-- and r.invitee_member_id = '5946694'   -- 邀请人会员ID
and m.member_phone = '13671578504'
order by r.create_time;

