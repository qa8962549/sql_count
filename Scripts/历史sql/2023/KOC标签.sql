-- 1 月 2月 完成app首次发文章 和完成app文章转发
SELECT a.EVENT_DESC 触发事件,
count(1) 累计发生次数,
sum(a.INTEGRAL) 累计发送V值
from `member`.tt_member_flow_record a
where a.IS_DELETED =0
and a.CREATE_TIME >='2023-01-01'
and a.CREATE_TIME <'2023-02-01'
and a.EVENT_DESC like '%App%'
and a.IS_BACK =0
group by a.EVENT_DESC 
order by 1

SELECT a.EVENT_DESC 触发事件,
count(1) 累计发生次数,
sum(a.INTEGRAL) 累计发送V值
from `member`.tt_member_flow_record a
where a.IS_DELETED =0
and a.CREATE_TIME >='2023-02-01'
and a.CREATE_TIME <'2023-03-01'
and a.EVENT_DESC like '%App%'
and a.IS_BACK =0 
group by a.EVENT_DESC 
order by 1

-- KOC标签
select 
x5.KOC,
m.MEMBER_NAME 姓名,
m.MEMBER_PHONE 联系方式,
m.REAL_NAME 真实姓名,
case when m.IS_VEHICLE = '1' then '绑定'
	when m.IS_VEHICLE = '0' then '未绑定'
	end 是否绑定车辆,
t.车型,
tr2.省份 所在地,
tr.REGION_NAME 省份,
tr3.REGION_NAME 具体城市,
x.小红书发帖数,
x.B站发帖数,
x.知乎发帖数,
x.爱卡汽车发帖数,
x.懂车帝发帖数,
x.汽车之家发帖数,
''主要发布平台,
tr2.COMPANY_CODE 所属经销商集团,
tsov2.DELIVERY_OWNER_CODE 所属门店,
x4.tt 推荐购年份,
x2.tt 推荐购数量,
x3.*,
ifnull(x4.是否VOLVO销售,'否') 是否销售人员,
m.USER_ID 
from 
	(
	select
	DISTINCT a.member_id
	from mine.koc_tasks_summary a
	where a.update_time >= '2022-01-01'
	and a.update_time <= '2023-02-07 23:59:59'
	and a.tasks_status = 1  -- 1表示已完成
	and a.tasks_type = 1  -- 筛选新手任务
	and a.is_delete = 0  -- 逻辑删除
	union 
	# 2022年推荐购被邀请人名单
	# 22Q1
	select DISTINCT r1.inviter_member_id from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r1
	union
	# 22Q2、22Q3
	select DISTINCT r2.inviter_member_id from volvo_online_activity.recommend_buyv6_invite_record r2
	union
	# 22Q4
	select DISTINCT r3.invite_member_id from invite.tm_invite_record r3
	where r3.create_time >= '2022-10-01'
	and r3.create_time <= '2023-02-07 23:59:59'
	and r3.is_deleted = 0
	)a 
left join `member`.tc_member_info m on a.member_id =m.ID 
left join (select
	DISTINCT a.member_id,"KOC" KOC
	from mine.koc_tasks_summary a
	where a.update_time >= '2022-01-01'
	and a.update_time <= '2023-02-07 23:59:59'
	and a.tasks_status = 1  -- 1表示已完成
	and a.tasks_type = 1  -- 筛选新手任务
	and a.is_delete = 0  -- 逻辑删除
	)x5 on x5.member_id=m.ID 
left join (
	select x.member_id,
	case when sum(x.tt)=2022 then '2022'
	when sum (x.tt)=2023 then '2023'
	when sum (x.tt)=4045 then '2023和2022' end tt
	from (
		select
		DISTINCT a.member_id
		,year(a.create_time) tt
		from mine.koc_tasks_summary a
		where a.update_time >= '2022-01-01'
		and a.update_time <= '2023-02-07 23:59:59'
		and a.tasks_status = 1  -- 1表示已完成
		and a.tasks_type = 1  -- 筛选新手任务
		and a.is_delete = 0  -- 逻辑删除
		union 
		# 2022年推荐购被邀请人名单
		# 22Q1
		select DISTINCT r1.inviter_member_id,year(r1.create_time) from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r1
		union
		# 22Q2、22Q3
		select DISTINCT r2.inviter_member_id,year(r2.create_time)  from volvo_online_activity.recommend_buyv6_invite_record r2
		union
		# 22Q4
		select DISTINCT r3.invite_member_id,year(r3.create_time) from invite.tm_invite_record r3
		where r3.create_time >= '2022-10-01'
		and r3.create_time <= '2023-02-07 23:59:59'
		and r3.is_deleted = 0
		)x  
	group by 1
	)x4 on x4.member_id=m.ID 
left join (	select x.inviter_member_id member_id,
			count(1) tt
			from 
			(
			select x.inviter_member_id,tm.MODEL_NAME
			from (
				select x.inviter_member_id,x.buy_car
				from 
					(
					# 22Q1
					select r1.inviter_member_id,r1.create_time,r1.buy_car from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r1
					union all
					# 22Q2、22Q3
					select r2.inviter_member_id,r2.create_time,r2.buy_car from volvo_online_activity.recommend_buyv6_invite_record r2
					union all
					# 22Q4
					select r3.invite_member_id,r3.create_time,r3.vehicle_code from invite.tm_invite_record r3
					where r3.create_time >= '2022-10-01'
					and r3.create_time <= '2023-02-07 23:59:59'
					and r3.is_deleted = 0)x 
				where x.buy_car is not null
				)x left join basic_data.tm_model tm on x.buy_car =tm.MODEL_CODE
			union all 
		# 20221.1 ~ 2022.9推荐购推荐购车数
		select a.推荐人member_id,a.新车车型 from
		(
			-- 推荐购 22Q2、22Q3
			SELECT
			m.member_name '推荐人姓名'
			,m.member_phone '推荐人手机号'
			,m.id '推荐人member_id'
			,v.vin '推荐人VIN'
			,v.model_name '车型'
			,r.invitee_name '被推荐人姓名'
			,r.invitee_member_id '被推荐人member_id'
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
					select v.*,row_number() over(partition by v.member_id order by v.create_time desc ) rk,tm.MODEL_NAME
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm on v.vehicle_code = tm.MODEL_CODE and tm.IS_DELETED = 0
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
					where m.member_status <> 60341003 and m.is_deleted=0
					GROUP BY 1) a
					left join member.tc_member_info m on a.mid = m.ID
				)m on m.cust_id =t.customer_id 
				where t.coupon_id in ('3420','3652')     -- 22Q2、Q3卡券ID
			    and t.create_time < CURDATE()
				order by t.operate_date desc
			) c on c.coupon_detail_id=rr.coupon_id
			left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
			where r.create_time >= '2022-04-01'
			and r.create_time <= '2022-09-30 23:59:59'
			and c.核销经销商 is not null
			union all
			-- 推荐购 22Q1
			SELECT
			m.member_name '推荐人姓名'
			,m.member_phone '推荐人手机号'
			,m.id '推荐人member_id'
			,v.vin '推荐人VIN'
			,v.model_name '车型'
			,r.invitee_name '被推荐人姓名'
			,r.invitee_member_id '被推荐人member_id'
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
			from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r 
			#获取推荐人信息
			left join member.tc_member_info m on m.id=r.inviter_member_id and m.is_deleted=0 and m.member_status<>60341003
			left join (
				#匹配推荐人VIN(取最近绑定VIN)
				select a.*
				from(
					select v.*,row_number() over(partition by v.member_id order by v.create_time desc) rk,tm2.MODEL_NAME
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm2 on v.vehicle_code = tm2.MODEL_CODE and tm2.IS_DELETED = 0
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
				where t.coupon_id = '3135'     -- 22Q1卡券ID
			    and t.create_time < CURDATE()
				order by t.operate_date desc
			) c on c.coupon_detail_id=rr.coupon_id
			left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
			where r.create_time >= '2022-01-01'
			and r.create_time <= '2022-03-31 23:59:59'
			and c.核销经销商 is not null
		) a
		union all
		# 2022.10 ~ 2022.12 推荐购购车
		select b.推荐人member_id,b.新车车型 from
		(
			# 邀约表用户留资并购车，购车状态有效明细（不涉及判断奖励发放，只要用户留资并购车，订单有效就算）
			select
			r.invite_member_id 推荐人member_id,
			r.invite_mobile 邀请人手机号,
			v.VIN 新车车架号,
			v.MODEL_NAME 新车车型,
			r.be_invite_member_id 被推荐人member_id,
			r.be_invite_mobile 被邀请人手机号,
			r.order_no 订单号,
			r.invoice_no 发票号,
			r.blue_invoice_time 蓝票开票时间,
			r.order_time 订单时间,
			r.payment_time 定金支付时间,
			case when r.is_large_set = 1 then '是'
				when r.is_large_set = 2 then '否'
				end 是否大定订单,
			r.vehicle_name 车型,
			r.create_time 留资时间,
			tc.CODE_CN_DESC 订单状态,
			tso.OWNER_CODE 经销商编号,
			tso.DRAWER_NAME 开票人姓名,
			tsov.SALES_VIN 车架号
			from invite.tm_invite_record r
			left join
			(
				# 推荐人最新绑定的VIN
				select v.MEMBER_ID,v.VIN,v.MODEL_NAME from
				(
					select
					v.MEMBER_ID,
					v.VIN,
					tm.MODEL_NAME,
					row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm on v.vehicle_code = tm.MODEL_CODE and tm.IS_DELETED = 0
					where v.is_deleted = 0
					and v.MEMBER_ID is not null
				) v
				where v.rk = 1
			) v on r.invite_member_id = v.MEMBER_ID
			left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 0
			left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
			left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
			where r.is_deleted = 0
			and r.order_status in ('14041008','14041003')   -- 有效订单
			and r.order_no is not NULL   -- 筛选订单号不为空
			and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
			and r.red_invoice_time is null   -- 红冲发票为空
			and r.create_time >= '2022-10-01'
			and r.create_time <= '2023-02-07 23:59:59'
			order by r.create_time
		) b)x group by 1
	)x2 on x2.member_id=m.id 
left join (	select x.inviter_member_id,
			count(case when x.MODEL_NAME='S60' then 1 end) 'S60',
			count(case when x.MODEL_NAME='S80' then 1 end) 'S80',
			count(case when x.MODEL_NAME='S90' then 1 end) 'S90',
			count(case when x.MODEL_NAME='XC60' then 1 end) 'XC60',
			count(case when x.MODEL_NAME='XC90' then 1 end) 'XC90',
			count(case when x.MODEL_NAME='XC40' then 1 end) 'XC40',
			count(case when x.MODEL_NAME='XC CLASSIC' then 1 end) 'XC CLASSIC',
			count(case when x.MODEL_NAME='C40' then 1 end) 'C40',
			count(case when x.MODEL_NAME='V90 Cross Country' or x.MODEL_NAME='V90CC' then 1 end) 'V90',
			count(case when x.MODEL_NAME='V60' or x.MODEL_NAME='v60' or x.MODEL_NAME='V60 Cross Country' then 1 end) 'V60',
			count(case when x.MODEL_NAME='V40' or x.MODEL_NAME='V40 Cross Country' then 1 end) 'V40'
			from 
			(
			select x.inviter_member_id,tm.MODEL_NAME
			from (
				select x.inviter_member_id,x.buy_car
				from 
					(
					# 22Q1
					select r1.inviter_member_id,r1.create_time,r1.buy_car from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r1
					union all
					# 22Q2、22Q3
					select r2.inviter_member_id,r2.create_time,r2.buy_car from volvo_online_activity.recommend_buyv6_invite_record r2
					union all
					# 22Q4
					select r3.invite_member_id,r3.create_time,r3.vehicle_code from invite.tm_invite_record r3
					where r3.create_time >= '2022-10-01'
					and r3.create_time <= '2023-02-07 23:59:59'
					and r3.is_deleted = 0)x 
				where x.buy_car is not null
				)x left join basic_data.tm_model tm on x.buy_car =tm.MODEL_CODE
			union all 
		# 20221.1 ~ 2022.9推荐购推荐购车数
		select a.推荐人member_id,a.新车车型 from
		(
			-- 推荐购 22Q2、22Q3
			SELECT
			m.member_name '推荐人姓名'
			,m.member_phone '推荐人手机号'
			,m.id '推荐人member_id'
			,v.vin '推荐人VIN'
			,v.model_name '车型'
			,r.invitee_name '被推荐人姓名'
			,r.invitee_member_id '被推荐人member_id'
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
					select v.*,row_number() over(partition by v.member_id order by v.create_time desc ) rk,tm.MODEL_NAME
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm on v.vehicle_code = tm.MODEL_CODE and tm.IS_DELETED = 0
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
					where m.member_status <> 60341003 and m.is_deleted=0
					GROUP BY 1) a
					left join member.tc_member_info m on a.mid = m.ID
				)m on m.cust_id =t.customer_id 
				where t.coupon_id in ('3420','3652')     -- 22Q2、Q3卡券ID
			    and t.create_time < CURDATE()
				order by t.operate_date desc
			) c on c.coupon_detail_id=rr.coupon_id
			left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
			where r.create_time >= '2022-04-01'
			and r.create_time <= '2022-09-30 23:59:59'
			and c.核销经销商 is not null
			union all
			-- 推荐购 22Q1
			SELECT
			m.member_name '推荐人姓名'
			,m.member_phone '推荐人手机号'
			,m.id '推荐人member_id'
			,v.vin '推荐人VIN'
			,v.model_name '车型'
			,r.invitee_name '被推荐人姓名'
			,r.invitee_member_id '被推荐人member_id'
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
			from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r 
			#获取推荐人信息
			left join member.tc_member_info m on m.id=r.inviter_member_id and m.is_deleted=0 and m.member_status<>60341003
			left join (
				#匹配推荐人VIN(取最近绑定VIN)
				select a.*
				from(
					select v.*,row_number() over(partition by v.member_id order by v.create_time desc) rk,tm2.MODEL_NAME
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm2 on v.vehicle_code = tm2.MODEL_CODE and tm2.IS_DELETED = 0
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
				where t.coupon_id = '3135'     -- 22Q1卡券ID
			    and t.create_time < CURDATE()
				order by t.operate_date desc
			) c on c.coupon_detail_id=rr.coupon_id
			left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
			where r.create_time >= '2022-01-01'
			and r.create_time <= '2022-03-31 23:59:59'
			and c.核销经销商 is not null
		) a
		union all
		# 2022.10 ~ 2022.12 推荐购购车
		select b.推荐人member_id,b.新车车型 from
		(
			# 邀约表用户留资并购车，购车状态有效明细（不涉及判断奖励发放，只要用户留资并购车，订单有效就算）
			select
			r.invite_member_id 推荐人member_id,
			r.invite_mobile 邀请人手机号,
			v.VIN 新车车架号,
			v.MODEL_NAME 新车车型,
			r.be_invite_member_id 被推荐人member_id,
			r.be_invite_mobile 被邀请人手机号,
			r.order_no 订单号,
			r.invoice_no 发票号,
			r.blue_invoice_time 蓝票开票时间,
			r.order_time 订单时间,
			r.payment_time 定金支付时间,
			case when r.is_large_set = 1 then '是'
				when r.is_large_set = 2 then '否'
				end 是否大定订单,
			r.vehicle_name 车型,
			r.create_time 留资时间,
			tc.CODE_CN_DESC 订单状态,
			tso.OWNER_CODE 经销商编号,
			tso.DRAWER_NAME 开票人姓名,
			tsov.SALES_VIN 车架号
			from invite.tm_invite_record r
			left join
			(
				# 推荐人最新绑定的VIN
				select v.MEMBER_ID,v.VIN,v.MODEL_NAME from
				(
					select
					v.MEMBER_ID,
					v.VIN,
					tm.MODEL_NAME,
					row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm on v.vehicle_code = tm.MODEL_CODE and tm.IS_DELETED = 0
					where v.is_deleted = 0
					and v.MEMBER_ID is not null
				) v
				where v.rk = 1
			) v on r.invite_member_id = v.MEMBER_ID
			left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 0
			left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
			left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
			where r.is_deleted = 0
			and r.order_status in ('14041008','14041003')   -- 有效订单
			and r.order_no is not NULL   -- 筛选订单号不为空
			and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
			and r.red_invoice_time is null   -- 红冲发票为空
			and r.create_time >= '2022-10-01'
			and r.create_time <= '2023-02-07 23:59:59'
			order by r.create_time
		) b)x group by 1
	)x3 on x3.inviter_member_id=m.ID 
left join
	(
	# 车系
	 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
	 from (
	 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
	 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
	 from member.tc_member_vehicle v 
	 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
	 where v.IS_DELETED=0 
	 ) v 
	 left join vehicle.tm_vehicle t on v.vin=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	 where v.rk=1
	) t on m.id=t.member_id
	left join dictionary.tc_code tc on tc.CODE_ID =m.MEMBER_SEX
	left join dictionary.tc_region tr on m.MEMBER_PROVINCE = tr.REGION_CODE
	left join dictionary.tc_region tr3 on m.MEMBER_CITY =tr3.REGION_CODE 
	left join vehicle.tt_invoice_statistics_dms tisd on t.VIN = tisd.vin 
	left join
			(
				# 获取用户地址
				-- 会员对应城市，根据优先级排序：1、最后绑定经销商城市 2、会员表城市 3、默认收货地址城市
				select
				m.id,
				m.member_phone,
				ifnull(c1.region_name,IFNULL(c2.region_name,c3.region_name)) 省份 ,
				c1.COMPANY_CODE
				from member.tc_member_info m 
				left join
				(
				 #最后绑定经销商城市
				 select a.member_id,c.PROVINCE_NAME region_name,c.COMPANY_CODE,c.COMPANY_NAME_CN 
				 from
				 (
					  select v.member_id,ifnull(d.dealer_code,vv.dealer_code) dealer_code,vv.model_name
					  from
					  (
					    select v.MEMBER_ID,v.VIN
					    ,row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
					    from member.tc_member_vehicle v 
					    where v.is_deleted=0 and v.MEMBER_ID is not null
					  ) v
					  left join vehicle.tm_vehicle vv on v.vin =vv.vin and vv.IS_DELETED=0
					  left join vehicle.tt_invoice_statistics_dms d on v.vin=d.vin and d.IS_DELETED=0
					  left join member.tc_member_info m  on v.member_id=m.id
					  where v.rk=1 -- 获取用户最后绑车记录
				 ) a left join organization.tm_company c on c.company_code=a.dealer_code and c.COMPANY_TYPE=15061003
				) c1 on c1.member_id = m.id
				left join (
				 #会员表城市
				 select m.id,c.REGION_NAME
				 from member.tc_member_info m  
				 left join dictionary.tc_region c on m.MEMBER_PROVINCE=c.REGION_ID
				 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
				) c2 on c2.id= m.id
				left join (
				 #收货地址城市
				 select m.id,cc.REGION_NAME
				 from member.tc_member_info m 
				 left join member.tc_member_address a on m.id=a.member_id and a.IS_DEFAULT=1 and a.status=0
				 left join dictionary.tc_region cc on a.address_province=cc.REGION_ID
				 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
				) c3 on c3.id= m.id
				where m.MEMBER_STATUS<>60341003 and m.IS_DELETED=0 and m.id<>3014773  -- 测试ID
			) tr2 on m.id= tr2.id
		left join (
		select 
		m.ID 
		,count(1) 发贴实际
		,ifnull(sum(case when a.station='小红书' then 1 end),0) 小红书发帖数
		,ifnull(sum(case when a.station='B站' then 1 end),0) B站发帖数
		,ifnull(sum(case when a.station='知乎' then 1 end),0) 知乎发帖数
		,ifnull(sum(case when a.station='爱卡汽车' then 1 end),0) 爱卡汽车发帖数
		,ifnull(sum(case when a.station='懂车帝' then 1 end),0) 懂车帝发帖数
		,ifnull(sum(case when a.station='汽车之家' then 1 end),0) 汽车之家发帖数
		from (
			select distinct css.user_id,
		 css.sharing_url ,
		 css.title ,
		 css.hits ,
		 css.click_volume,
		 css.date_create,
		case when css.sharing_url like '%autohome%' then '汽车之家'
			 when css.sharing_url like '%tieba.baidu%' then '百度贴吧'
			 when css.sharing_url like '%hansiji%' then '5X兴趣社区'
			 when css.sharing_url like '%xcar%' then '爱卡汽车'
			 when css.sharing_url like '%pcauto%' then '太平洋汽车'
			 when css.sharing_url like '%yiche%' or css.sharing_url like '%bitauto%' then '易车网'
			 when css.sharing_url like '%tianya%' then '天涯社区'
			 when css.sharing_url like '%dcdapp%' or css.sharing_url like '%snssdk%' or css.sharing_url like '%dongchedi%' then '懂车帝'
			 when css.sharing_url like '%laosiji%' then '老司机'
			 when css.sharing_url like '%news18a%' then '极趣社区'
			 when css.sharing_url like '%zhihu%' then '知乎'
			 when css.sharing_url like '%hupu%' then '虎扑'
			 when css.sharing_url like '%weibo%' then '微博'
			 when css.sharing_url like '%xhs%' or css.sharing_url like '%xiaohongshu%' then '小红书'
			 when css.sharing_url like '%douyin%' then '抖音'
			 when css.sharing_url like '%bilibili%' then 'B站'
			 when css.sharing_url like '%toutiao%' then '今日头条'
			 when css.sharing_url like '%weixin%' or css.sharing_url like '%微信%' then '微信'
			 when css.sharing_url like '%maiche%' then '买车网' else '其他' end station,
		 ROW_NUMBER() over(PARTITION by css.user_id,css.sharing_url,css.title order by css.click_volume desc) as rk -- 按user_id+url+title 组合去重，取传播数最大的那条
		from volvo_cms.cms_social_sharing css 
		where css.state = 60891002 -- 已通过
	-- 	and css.date_create >= '2022-01-01'
		and css.date_create <= '2023-02-07 23:59:59'
		) a left join `member`.tc_member_info m on a.user_id=m.USER_ID  
		where 1=1
		and a.rk = 1
		and a.station not in ('爱卡汽车','太平洋汽车')
	-- 	and a.user_id='7540394'
		GROUP BY 1
		order by 1 )x on x.id=m.id
	left join 
						(-- 留资和试驾时间差(是否VOLVO销售)
					select DISTINCT x.inviter_member_id,'是' 是否VOLVO销售
					from 
					(
					-- 推荐到购车时间差小于1天
					select DISTINCT r1.inviter_member_id,
					timestampdiff(hour,r1.create_time,a.DRIVE_S_AT) tt
					from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r1
					left join cyx_appointment.tt_appointment_drive a on r1.test_drive_id =a.APPOINTMENT_ID 
					where r1.test_drive_status ='Y'
					union 
					select DISTINCT r1.inviter_member_id,
					timestampdiff(hour,r1.create_time,a.DRIVE_S_AT)
					from volvo_online_activity.recommend_buyv6_invite_record r1
					left join cyx_appointment.tt_appointment_drive a on r1.test_drive_id =a.APPOINTMENT_ID 
					where r1.test_drive_status ='Y'
					union 
					select DISTINCT r3.invite_member_id,timestampdiff(hour,r3.reserve_time ,r3.drive_time)
					from invite.tm_invite_record r3
					where r3.create_time >= '2022-10-01'
					and r3.create_time <= '2023-02-07 23:59:59'
					and r3.is_deleted = 0
					and r3.drive_time is not null
					)x where x.tt<=1
					group by 1
					union
					-- 一天推荐三人以上 
					select DISTINCT x.inviter_member_id,'是' 是否VOLVO销售
					from 
					(
					select DATE_FORMAT(r1.create_time,'%Y-%m-%d'),r1.inviter_member_id,count(1)
					from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r1
					where r1.test_drive_car is not null 
					group by 1,2
					having count(1)>=3
					union
					# 22Q2、22Q3
					select DATE_FORMAT(r2.create_time,'%Y-%m-%d'),r2.inviter_member_id,count(1)
					from volvo_online_activity.recommend_buyv6_invite_record r2
					where r2.test_drive_car is not null 
					group by 1,2
					having count(1)>=3
					union
					# 22Q4
					select DATE_FORMAT(r3.create_time,'%Y-%m-%d'),r3.invite_member_id,count(1)
					from invite.tm_invite_record r3
					where r3.create_time >= '2022-10-01'
					and r3.create_time <= '2023-02-07 23:59:59'
					and r3.is_deleted = 0
					and r3.drive_time is not null
					group by 1,2
					having count(1)>=3
					)x
					union
				-- 	推荐成功率大于80%（推荐人数超过5人）
					select x.inviter_member_id,'是' 是否VOLVO销售
					from 
					(
					select a.inviter_member_id,b.tt/a.tt tt
					from 
					(
					select a.inviter_member_id,sum(a.tt) tt
					from 
						(
						select r1.inviter_member_id,count(1) tt
						from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r1
					-- 	where r1.test_drive_car is not null 
						group by 1
						union all 
						# 22Q2、22Q3
						select r2.inviter_member_id,count(1)
						from volvo_online_activity.recommend_buyv6_invite_record r2
					-- 	where r2.test_drive_car is not null 
						group by 1
						union all 
						# 22Q4
						select r3.invite_member_id,count(1)
						from invite.tm_invite_record r3
						where r3.create_time >= '2022-10-01'
						and r3.create_time <= '2023-02-07 23:59:59'
						and r3.is_deleted = 0
					-- 	and r3.drive_time is not null
						group by 1
						)a 
				-- 		where a.inviter_member_id=3403110
						group by 1
					)a 
					left join 
					(select c.推荐人member_id,COUNT(c.被推荐人member_id) tt  from
					(
						# 20221.1 ~ 2022.9推荐购推荐购车数
						select a.推荐人member_id,a.被推荐人member_id,a.新车车架号,a.新车车型 from
						(
							-- 推荐购 22Q2、22Q3
							SELECT
							m.member_name '推荐人姓名'
							,m.member_phone '推荐人手机号'
							,m.id '推荐人member_id'
							,v.vin '推荐人VIN'
							,v.model_name '车型'
							,r.invitee_name '被推荐人姓名'
							,r.invitee_member_id '被推荐人member_id'
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
									select v.*,row_number() over(partition by v.member_id order by v.create_time desc ) rk,tm.MODEL_NAME
									from member.tc_member_vehicle v
									left join basic_data.tm_model tm on v.vehicle_code = tm.MODEL_CODE and tm.IS_DELETED = 0
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
									where m.member_status <> 60341003 and m.is_deleted=0
									GROUP BY 1) a
									left join member.tc_member_info m on a.mid = m.ID
								)m on m.cust_id =t.customer_id 
								where t.coupon_id in ('3420','3652')     -- 22Q2、Q3卡券ID
							    and t.create_time < CURDATE()
								order by t.operate_date desc
							) c on c.coupon_detail_id=rr.coupon_id
							left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
							where r.create_time >= '2022-04-01'
							and r.create_time <= '2022-09-30 23:59:59'
							and c.核销经销商 is not null
							union all
							-- 推荐购 22Q1
							SELECT
							m.member_name '推荐人姓名'
							,m.member_phone '推荐人手机号'
							,m.id '推荐人member_id'
							,v.vin '推荐人VIN'
							,v.model_name '车型'
							,r.invitee_name '被推荐人姓名'
							,r.invitee_member_id '被推荐人member_id'
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
							from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r 
							#获取推荐人信息
							left join member.tc_member_info m on m.id=r.inviter_member_id and m.is_deleted=0 and m.member_status<>60341003
							left join (
								#匹配推荐人VIN(取最近绑定VIN)
								select a.*
								from(
									select v.*,row_number() over(partition by v.member_id order by v.create_time desc) rk,tm2.MODEL_NAME
									from member.tc_member_vehicle v
									left join basic_data.tm_model tm2 on v.vehicle_code = tm2.MODEL_CODE and tm2.IS_DELETED = 0
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
								where t.coupon_id = '3135'     -- 22Q1卡券ID
							    and t.create_time < CURDATE()
								order by t.operate_date desc
							) c on c.coupon_detail_id=rr.coupon_id
							left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
							where r.create_time >= '2022-01-01'
							and r.create_time <= '2022-03-31 23:59:59'
							and c.核销经销商 is not null
						) a
						union all
						# 2022.10 ~ 2022.12 推荐购购车
						select b.推荐人member_id,b.被推荐人member_id,b.新车车架号,b.新车车型 from
						(
							# 邀约表用户留资并购车，购车状态有效明细（不涉及判断奖励发放，只要用户留资并购车，订单有效就算）
							select
							r.invite_member_id 推荐人member_id,
							r.invite_mobile 邀请人手机号,
							v.VIN 新车车架号,
							v.MODEL_NAME 新车车型,
							r.be_invite_member_id 被推荐人member_id,
							r.be_invite_mobile 被邀请人手机号,
							r.order_no 订单号,
							r.invoice_no 发票号,
							r.blue_invoice_time 蓝票开票时间,
							r.order_time 订单时间,
							r.payment_time 定金支付时间,
							case when r.is_large_set = 1 then '是'
								when r.is_large_set = 2 then '否'
								end 是否大定订单,
							r.vehicle_name 车型,
							r.create_time 留资时间,
							tc.CODE_CN_DESC 订单状态,
							tso.OWNER_CODE 经销商编号,
							tso.DRAWER_NAME 开票人姓名,
							tsov.SALES_VIN 车架号
							from invite.tm_invite_record r
							left join
							(
								# 推荐人最新绑定的VIN
								select v.MEMBER_ID,v.VIN,v.MODEL_NAME from
								(
									select
									v.MEMBER_ID,
									v.VIN,
									tm.MODEL_NAME,
									row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
									from member.tc_member_vehicle v
									left join basic_data.tm_model tm on v.vehicle_code = tm.MODEL_CODE and tm.IS_DELETED = 0
									where v.is_deleted = 0
									and v.MEMBER_ID is not null
								) v
								where v.rk = 1
							) v on r.invite_member_id = v.MEMBER_ID
							left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 0
							left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
							left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
							where r.is_deleted = 0
							and r.order_status in ('14041008','14041003')   -- 有效订单
							and r.order_no is not NULL   -- 筛选订单号不为空
							and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
							and r.red_invoice_time is null   -- 红冲发票为空
							and r.create_time >= '2022-10-01'
							and r.create_time <= '2023-02-07 23:59:59'
							order by r.create_time
						) b
					) c
				-- 	where c.推荐人member_id=3403110
					group by 1	
					having COUNT(c.被推荐人member_id)>=5
					)b on a.inviter_member_id=b.推荐人member_id
					group by 1
				-- 	HAVING b.tt/a.tt >=0.8
					order by 2 desc 
					)x where x.tt>=0.8
					union 
					SELECT m.id,'是' 是否volvo销售
					from `member`.tc_member_info m
					where 1=1
					and m.MEMBER_NAME like '%沃尔沃%'
					)x4 on a.member_id =x4.inviter_member_id
		left join cyxdms_retail.tt_sales_order_vin tsov2 on tsov2.SALES_VIN=t.vin
		where m.MEMBER_NAME is not null

###########################################################

# 邀约成功购车数
	select c.推荐人member_id,COUNT(c.被推荐人member_id) 邀约成功购车数  from
	(
		# 20221.1 ~ 2022.9推荐购推荐购车数
		select a.推荐人member_id,a.被推荐人member_id,a.新车车架号,a.新车车型 from
		(
			-- 推荐购 22Q2、22Q3
			SELECT
			m.member_name '推荐人姓名'
			,m.member_phone '推荐人手机号'
			,m.id '推荐人member_id'
			,v.vin '推荐人VIN'
			,v.model_name '车型'
			,r.invitee_name '被推荐人姓名'
			,r.invitee_member_id '被推荐人member_id'
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
					select v.*,row_number() over(partition by v.member_id order by v.create_time desc ) rk,tm.MODEL_NAME
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm on v.vehicle_code = tm.MODEL_CODE and tm.IS_DELETED = 0
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
					where m.member_status <> 60341003 and m.is_deleted=0
					GROUP BY 1) a
					left join member.tc_member_info m on a.mid = m.ID
				)m on m.cust_id =t.customer_id 
				where t.coupon_id in ('3420','3652')     -- 22Q2、Q3卡券ID
			    and t.create_time < CURDATE()
				order by t.operate_date desc
			) c on c.coupon_detail_id=rr.coupon_id
			left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
			where r.create_time >= '2022-04-01'
			and r.create_time <= '2022-09-30 23:59:59'
			and c.核销经销商 is not null
			union all
			-- 推荐购 22Q1
			SELECT
			m.member_name '推荐人姓名'
			,m.member_phone '推荐人手机号'
			,m.id '推荐人member_id'
			,v.vin '推荐人VIN'
			,v.model_name '车型'
			,r.invitee_name '被推荐人姓名'
			,r.invitee_member_id '被推荐人member_id'
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
			from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r 
			#获取推荐人信息
			left join member.tc_member_info m on m.id=r.inviter_member_id and m.is_deleted=0 and m.member_status<>60341003
			left join (
				#匹配推荐人VIN(取最近绑定VIN)
				select a.*
				from(
					select v.*,row_number() over(partition by v.member_id order by v.create_time desc) rk,tm2.MODEL_NAME
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm2 on v.vehicle_code = tm2.MODEL_CODE and tm2.IS_DELETED = 0
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
				where t.coupon_id = '3135'     -- 22Q1卡券ID
			    and t.create_time < CURDATE()
				order by t.operate_date desc
			) c on c.coupon_detail_id=rr.coupon_id
			left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
			where r.create_time >= '2022-01-01'
			and r.create_time <= '2022-03-31 23:59:59'
			and c.核销经销商 is not null
		) a
		union all
		# 2022.10 ~ 2022.12 推荐购购车
		select b.推荐人member_id,b.被推荐人member_id,b.新车车架号,b.新车车型 from
		(
			# 邀约表用户留资并购车，购车状态有效明细（不涉及判断奖励发放，只要用户留资并购车，订单有效就算）
			select
			r.invite_member_id 推荐人member_id,
			r.invite_mobile 邀请人手机号,
			v.VIN 新车车架号,
			v.MODEL_NAME 新车车型,
			r.be_invite_member_id 被推荐人member_id,
			r.be_invite_mobile 被邀请人手机号,
			r.order_no 订单号,
			r.invoice_no 发票号,
			r.blue_invoice_time 蓝票开票时间,
			r.order_time 订单时间,
			r.payment_time 定金支付时间,
			case when r.is_large_set = 1 then '是'
				when r.is_large_set = 2 then '否'
				end 是否大定订单,
			r.vehicle_name 车型,
			r.create_time 留资时间,
			tc.CODE_CN_DESC 订单状态,
			tso.OWNER_CODE 经销商编号,
			tso.DRAWER_NAME 开票人姓名,
			tsov.SALES_VIN 车架号
			from invite.tm_invite_record r
			left join
			(
				# 推荐人最新绑定的VIN
				select v.MEMBER_ID,v.VIN,v.MODEL_NAME from
				(
					select
					v.MEMBER_ID,
					v.VIN,
					tm.MODEL_NAME,
					row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm on v.vehicle_code = tm.MODEL_CODE and tm.IS_DELETED = 0
					where v.is_deleted = 0
					and v.MEMBER_ID is not null
				) v
				where v.rk = 1
			) v on r.invite_member_id = v.MEMBER_ID
			left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 0
			left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
			left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
			where r.is_deleted = 0
			and r.order_status in ('14041008','14041003')   -- 有效订单
			and r.order_no is not NULL   -- 筛选订单号不为空
			and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
			and r.red_invoice_time is null   -- 红冲发票为空
			and r.create_time >= '2022-10-01'
			and r.create_time <= '2022-12-31 23:59:59'
			order by r.create_time
		) b
	) c
	group by 1		
	having COUNT(c.被推荐人member_id)>=5
		
		
		
		
		
		
-- 1、社交分享发帖明细(7.15之后社交分享发帖，就不审核了，已经没有社交分享入口了)
select
a.nick_name 用户昵称,
a.user_id userId,
a.phone 手机号,
a.welfare_type 赚福利类型,
b.CODE_CN_DESC 认证类型,
a.sharing_url 分享链接,
a.reviewer 审核人,
a.date_create 提交时间,
a.date_update 审核时间,
c.CODE_CN_DESC 审核状态,
a.title 文章标题,
d.CODE_CN_DESC 渠道来源,
a.subject_content 主题类容,
a.hits 点赞加评论,
a.click_volume 浏览量
from volvo_cms.cms_social_sharing a
left join dictionary.tc_code b on a.sharing_type = b.CODE_ID
left join dictionary.tc_code c on a.state = c.CODE_ID 
left join dictionary.tc_code d on a.source = d.CODE_ID
where a.date_create >= '2022-07-15'
-- and a.date_update <= '2022-06-19 23:59:59'
and c.CODE_CN_DESC = '已通过'


-- 2、懂车帝打分数据拉取
select
css.nick_name 昵称,
css.user_id,
css.phone 手机号,
tc.CODE_CN_DESC 懂车帝任务区分,
css.image 图片,
css.sharing_url 分享链接,
tc2.CODE_CN_DESC 审核状态,
css.date_update 审核时间,
css.uid,
css.title 文章标题,
css.subject_content 主题内容,
css.member_id 会员ID
from volvo_cms.cms_social_sharing css
left join dictionary.tc_code tc on css.sharing_type = tc.CODE_ID 
left join dictionary.tc_code tc2 on css.state = tc2.CODE_ID 
where css.date_update >= '2022-07-11'
and css.date_update <= '2022-07-17 23:59:59'
and css.state = '60891002'   -- 已通过
and css.sharing_type in ('60871019','60871022')   -- 入门新星任务二、特殊任务



-- 3、KOC名单
select
a.member_id
from mine.koc_tasks_summary a
where a.update_time >= '2022-01-01'
and a.update_time <= '2023-02-07 23:59:59'
and a.tasks_status = 1  -- 1表示已完成
and a.tasks_type = 1  -- 筛选新手任务
and a.is_delete = 0  -- 逻辑删除


	select
	DISTINCT a.member_id,"KOC" KOC
	from mine.koc_tasks_summary a
	where a.update_time >= '2022-01-01'
	and a.update_time <= '2023-02-07 23:59:59'
	and a.tasks_status = 1  -- 1表示已完成
	and a.tasks_type = 1  -- 筛选新手任务
	and a.is_delete = 0  -- 逻辑删除
	union 
	# 2022年推荐购被邀请人名单
	# 22Q1
	select DISTINCT r1.inviter_member_id,""from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r1
	union
	# 22Q2、22Q3
	select DISTINCT r2.inviter_member_id,""from volvo_online_activity.recommend_buyv6_invite_record r2
	union
	# 22Q4
	select DISTINCT r3.invite_member_id,""from invite.tm_invite_record r3
	where r3.create_time >= '2022-10-01'
	and r3.create_time <= '2023-02-07 23:59:59'
	and r3.is_deleted = 0
	
	-- 留资和试驾时间差(是否VOLVO销售)
	select DISTINCT x.inviter_member_id,'是' 是否VOLVO销售
	from 
	(
	select DISTINCT r1.inviter_member_id,
	timestampdiff(hour,r1.create_time,a.DRIVE_S_AT) tt
	from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r1
	left join cyx_appointment.tt_appointment_drive a on r1.test_drive_id =a.APPOINTMENT_ID 
	where r1.test_drive_status ='Y'
	union 
	select DISTINCT r1.inviter_member_id,
	timestampdiff(hour,r1.create_time,a.DRIVE_S_AT)
	from volvo_online_activity.recommend_buyv6_invite_record r1
	left join cyx_appointment.tt_appointment_drive a on r1.test_drive_id =a.APPOINTMENT_ID 
	where r1.test_drive_status ='Y'
	union 
	select DISTINCT r3.invite_member_id,timestampdiff(hour,r3.reserve_time ,r3.drive_time)
	from invite.tm_invite_record r3
	where r3.create_time >= '2022-10-01'
	and r3.create_time <= '2023-02-07 23:59:59'
	and r3.is_deleted = 0
	and r3.drive_time is not null
	)x where x.tt<=1
	group by 1
	union
	-- 一天推荐三人以上 
	select DISTINCT x.inviter_member_id,'是' 是否VOLVO销售
	from 
	(
	select DATE_FORMAT(r1.create_time,'%Y-%m-%d'),r1.inviter_member_id,count(1)
	from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r1
	where r1.test_drive_car is not null 
	group by 1,2
	having count(1)>=3
	union
	# 22Q2、22Q3
	select DATE_FORMAT(r2.create_time,'%Y-%m-%d'),r2.inviter_member_id,count(1)
	from volvo_online_activity.recommend_buyv6_invite_record r2
	where r2.test_drive_car is not null 
	group by 1,2
	having count(1)>=3
	union
	# 22Q4
	select DATE_FORMAT(r3.create_time,'%Y-%m-%d'),r3.invite_member_id,count(1)
	from invite.tm_invite_record r3
	where r3.create_time >= '2022-10-01'
	and r3.create_time <= '2023-02-07 23:59:59'
	and r3.is_deleted = 0
	and r3.drive_time is not null
	group by 1,2
	having count(1)>=3
	)x
	union
-- 	推荐成功率大于80%（推荐人数超过5人）
	select x.inviter_member_id,'是' 是否VOLVO销售
	from 
	(
	select a.inviter_member_id,b.tt/a.tt tt
	from 
	(
	select a.inviter_member_id,sum(a.tt) tt
	from 
		(
		select r1.inviter_member_id,count(1) tt
		from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r1
	-- 	where r1.test_drive_car is not null 
		group by 1
		union all 
		# 22Q2、22Q3
		select r2.inviter_member_id,count(1)
		from volvo_online_activity.recommend_buyv6_invite_record r2
	-- 	where r2.test_drive_car is not null 
		group by 1
		union all 
		# 22Q4
		select r3.invite_member_id,count(1)
		from invite.tm_invite_record r3
		where r3.create_time >= '2022-10-01'
		and r3.create_time <= '2023-02-07 23:59:59'
		and r3.is_deleted = 0
	-- 	and r3.drive_time is not null
		group by 1
		)a 
-- 		where a.inviter_member_id=3403110
		group by 1
	)a 
	left join 
	(select c.推荐人member_id,COUNT(c.被推荐人member_id) tt  from
	(
		# 20221.1 ~ 2022.9推荐购推荐购车数
		select a.推荐人member_id,a.被推荐人member_id,a.新车车架号,a.新车车型 from
		(
			-- 推荐购 22Q2、22Q3
			SELECT
			m.member_name '推荐人姓名'
			,m.member_phone '推荐人手机号'
			,m.id '推荐人member_id'
			,v.vin '推荐人VIN'
			,v.model_name '车型'
			,r.invitee_name '被推荐人姓名'
			,r.invitee_member_id '被推荐人member_id'
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
					select v.*,row_number() over(partition by v.member_id order by v.create_time desc ) rk,tm.MODEL_NAME
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm on v.vehicle_code = tm.MODEL_CODE and tm.IS_DELETED = 0
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
					where m.member_status <> 60341003 and m.is_deleted=0
					GROUP BY 1) a
					left join member.tc_member_info m on a.mid = m.ID
				)m on m.cust_id =t.customer_id 
				where t.coupon_id in ('3420','3652')     -- 22Q2、Q3卡券ID
			    and t.create_time < CURDATE()
				order by t.operate_date desc
			) c on c.coupon_detail_id=rr.coupon_id
			left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
			where r.create_time >= '2022-04-01'
			and r.create_time <= '2022-09-30 23:59:59'
			and c.核销经销商 is not null
			union all
			-- 推荐购 22Q1
			SELECT
			m.member_name '推荐人姓名'
			,m.member_phone '推荐人手机号'
			,m.id '推荐人member_id'
			,v.vin '推荐人VIN'
			,v.model_name '车型'
			,r.invitee_name '被推荐人姓名'
			,r.invitee_member_id '被推荐人member_id'
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
			from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r 
			#获取推荐人信息
			left join member.tc_member_info m on m.id=r.inviter_member_id and m.is_deleted=0 and m.member_status<>60341003
			left join (
				#匹配推荐人VIN(取最近绑定VIN)
				select a.*
				from(
					select v.*,row_number() over(partition by v.member_id order by v.create_time desc) rk,tm2.MODEL_NAME
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm2 on v.vehicle_code = tm2.MODEL_CODE and tm2.IS_DELETED = 0
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
				where t.coupon_id = '3135'     -- 22Q1卡券ID
			    and t.create_time < CURDATE()
				order by t.operate_date desc
			) c on c.coupon_detail_id=rr.coupon_id
			left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
			where r.create_time >= '2022-01-01'
			and r.create_time <= '2022-03-31 23:59:59'
			and c.核销经销商 is not null
		) a
		union all
		# 2022.10 ~ 2022.12 推荐购购车
		select b.推荐人member_id,b.被推荐人member_id,b.新车车架号,b.新车车型 from
		(
			# 邀约表用户留资并购车，购车状态有效明细（不涉及判断奖励发放，只要用户留资并购车，订单有效就算）
			select
			r.invite_member_id 推荐人member_id,
			r.invite_mobile 邀请人手机号,
			v.VIN 新车车架号,
			v.MODEL_NAME 新车车型,
			r.be_invite_member_id 被推荐人member_id,
			r.be_invite_mobile 被邀请人手机号,
			r.order_no 订单号,
			r.invoice_no 发票号,
			r.blue_invoice_time 蓝票开票时间,
			r.order_time 订单时间,
			r.payment_time 定金支付时间,
			case when r.is_large_set = 1 then '是'
				when r.is_large_set = 2 then '否'
				end 是否大定订单,
			r.vehicle_name 车型,
			r.create_time 留资时间,
			tc.CODE_CN_DESC 订单状态,
			tso.OWNER_CODE 经销商编号,
			tso.DRAWER_NAME 开票人姓名,
			tsov.SALES_VIN 车架号
			from invite.tm_invite_record r
			left join
			(
				# 推荐人最新绑定的VIN
				select v.MEMBER_ID,v.VIN,v.MODEL_NAME from
				(
					select
					v.MEMBER_ID,
					v.VIN,
					tm.MODEL_NAME,
					row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
					from member.tc_member_vehicle v
					left join basic_data.tm_model tm on v.vehicle_code = tm.MODEL_CODE and tm.IS_DELETED = 0
					where v.is_deleted = 0
					and v.MEMBER_ID is not null
				) v
				where v.rk = 1
			) v on r.invite_member_id = v.MEMBER_ID
			left join dictionary.tc_code tc on r.order_status = tc.CODE_ID and tc.IS_DELETED = 0
			left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
			left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
			where r.is_deleted = 0
			and r.order_status in ('14041008','14041003')   -- 有效订单
			and r.order_no is not NULL   -- 筛选订单号不为空
			and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
			and r.red_invoice_time is null   -- 红冲发票为空
			and r.create_time >= '2022-10-01'
			and r.create_time <= '2023-02-07 23:59:59'
			order by r.create_time
		) b
	) c
-- 	where c.推荐人member_id=3403110
	group by 1	
	having COUNT(c.被推荐人member_id)>=5
	)b on a.inviter_member_id=b.推荐人member_id
	group by 1
-- 	HAVING b.tt/a.tt >=0.8
	order by 2 desc 
	)x where x.tt>=0.8
	union 
SELECT m.id,'是' 是否volvo销售
from `member`.tc_member_info m
where 1=1
and m.MEMBER_NAME like '%沃尔沃%'
-- and m.MEMBER_NAME like '%A%'

	
	
	