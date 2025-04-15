  
-- KOC标签
select 
"KOC" KOC,
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
from  `member`.tc_member_info m
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
					UNION 
					SELECT m.id,'是' 是否volvo销售
					from `member`.tc_member_info m
					where 1=1
					and m.MEMBER_NAME like '%沃尔沃%'
					)x4 on m.id =x4.inviter_member_id
				left join cyxdms_retail.tt_sales_order_vin tsov2 on tsov2.SALES_VIN=t.vin
where m.id in ('3411867',
'3601819',
'3309080',
'3344124',
'3408495',
'3809456',
'4563552',
'4098690',
'3788147',
'3328449',
'3719761',
'4602847',
'4129905',
'4064023',
'4453841',
'3591412',
'3626987',
'3593618',
'3860425',
'3740505',
'3805627',
'4308006',
'4161678',
'4266297',
'4261392',
'3626969',
'4730874',
'3822616',
'4283973',
'4610896',
'3042212',
'4214720',
'3293491',
'3350199',
'3050529',
'4274374',
'3176846',
'4620091',
'4383767',
'3101493',
'3101898',
'4298836',
'4531565',
'3717910',
'4139687',
'4560722',
'4440915',
'3617822',
'3311366',
'3630544',
'4758236',
'3733345',
'3331548',
'3307627',
'4022482',
'4653910',
'4400867',
'3800116',
'3821981',
'3814559',
'3389334',
'4642876',
'3822138',
'3802310',
'3800669',
'3454326',
'3248236',
'4720247',
'4386523',
'3295132',
'4550513',
'3552079',
'4651366',
'3435461',
'3028306',
'3349169',
'3355830',
'3866999',
'3724051',
'3523731',
'3812974',
'3525309',
'4759228',
'3754337',
'4321992',
'4164043',
'4424584',
'3108458',
'4243761',
'3591234',
'4221647',
'4440421',
'3785174',
'3685575',
'3592946',
'4090961',
'4281269',
'4249974',
'3519318',
'3674197',
'3249150',
'3384061',
'4420380',
'3722040',
'4288040',
'3561555',
'4152308',
'3287386',
'4636198',
'3479201',
'4522807',
'3837164',
'4121573',
'4320609',
'4546229',
'3553719',
'4360389',
'4629597',
'3788328',
'3825460',
'3341906',
'3628276',
'4274362',
'4375251',
'3682552',
'4458294',
'3412758',
'3318942',
'4244475',
'4296518',
'4185098',
'4755437',
'3671351',
'3371339',
'4223730',
'3214557',
'4187837',
'4724180',
'3860698',
'4248946',
'4649212',
'3604841',
'3575258',
'3679689',
'3615310',
'4199686',
'3429131',
'3108564',
'4079402',
'3581910',
'3239549',
'4092173',
'4285255',
'3757922',
'4571486',
'3207376',
'4167554',
'4180301',
'3488334',
'4768242',
'4672169',
'3445868',
'3684450',
'3485120',
'4435851',
'5289267',
'3600965',
'4086758',
'3790887',
'4586290',
'4540253',
'4256572',
'4542446',
'3708101',
'3220540',
'4535279',
'4172246',
'3676537',
'4562714',
'3365019',
'3861562',
'4256621',
'4166004',
'3697031',
'4083099',
'3501462',
'4227941',
'3177594',
'4438683',
'3242011',
'3113722',
'3513672',
'3434492',
'3452001',
'3018468',
'3615064',
'4273645',
'3261811',
'4063478',
'3589851',
'4296701',
'4324115',
'3058390',
'3241647',
'3389623',
'3495260',
'3297946',
'3448832',
'3635049',
'4251644',
'3043532',
'3057338',
'4151420',
'4473220',
'4635355',
'4562028',
'4265474',
'4195002',
'3533837',
'3020766',
'3796122',
'4252048',
'3630117',
'3409839',
'4631183',
'3057542',
'3414342',
'4548748',
'4459845',
'3687485',
'3446374',
'4394408',
'4625444',
'3642270',
'3046007',
'3275563',
'4197346',
'3081573',
'4396366',
'3245834',
'3517216',
'3574349',
'3556414',
'4180737',
'3217591',
'4584610',
'3015036',
'3613721',
'3034054',
'3187265',
'3604794',
'3540936',
'4089827',
'3194296',
'3084482',
'3638754',
'3453336',
'4247541',
'4229236',
'3533265',
'3043124',
'3048243',
'3080741',
'3441684',
'4528755',
'4150626',
'4182731',
'4195993',
'3965863',
'4402533',
'3882618',
'3463958',
'3641739',
'3809300',
'3535422',
'3614808',
'3702002',
'3691480',
'3107498',
'3393368',
'3418439',
'3565830',
'3591132',
'3715735',
'3754927',
'3793060',
'4643060',
'4164065',
'4186308',
'4198684',
'4228570',
'4235935',
'4274821',
'4275322',
'4279022',
'4536898',
'4585335',
'4592442',
'3506063',
'4620659',
'4622300',
'4645502',
'4717955',
'4739443',
'4741416',
'5298720',
'4774555',
'4801100',
'5281786',
'4812800',
'5295706',
'5261644',
'5305600',
'5307627',
'3034404',
'3042183',
'3125147',
'3143192',
'3201606',
'3213258',
'3344016',
'3372255',
'3412275',
'3452942',
'3462708',
'4585027',
'3509211',
'3517203',
'3557378',
'3564683',
'3574519',
'3613218',
'3722161',
'3770540',
'3778818',
'3790920',
'3800660',
'3819397',
'3823652',
'3825289',
'3831581',
'3860095',
'3904896',
'3940470',
'3981866',
'4085778',
'4092740',
'4127954',
'4138098',
'4159383',
'4190959',
'4199589',
'4206256',
'4223368',
'4230352',
'4231713',
'4236611',
'4238701',
'4255493',
'4266927',
'4271320',
'4297298',
'4300095',
'4300436',
'4311270',
'4311747',
'4316586',
'4317618',
'4441405',
'4470667',
'4522383',
'4542963',
'4739051',
'4553162',
'4558007',
'4635112',
'4571397',
'4583698',
'4624047',
'4633511',
'4799528',
'4659350',
'4718444',
'4718467',
'4723138',
'4743194',
'4767549',
'4769056',
'4785741',
'4787286',
'4789772',
'4795210',
'4796886',
'4812670',
'4806337',
'4816892',
'3692243',
'5014314',
'5244449',
'5263073',
'5258632',
'5252355',
'5251762',
'5268167',
'5288367',
'5292685',
'5331830',
'3423365',
'4163033',
'4446673',
'4547897',
'4563391',
'5272696',
'5285843',
'5494760',
'3364486',
'3626069',
'4433094',
'4464554',
'4783691',
'5259758',
'4200742',
'4544991',
'3107704',
'4571268',
'5528144',
'5294504',
'5483467',
'5504678',
'5528197',
'4222087',
'4459994',
'4582931',
'4604927',
'4646855',
'4805582',
'5257058',
'5278513',
'3202500',
'3861097',
'4631077',
'4759669',
'5257915',
'5364882',
'5541941',
'5545919',
'5547704',
'5552034',
'5552056',
'4267056',
'4618192',
'4580039',
'5308440',
'3840991',
'4126782',
'4245024',
'4742574',
'4759478',
'3233378',
'4583172',
'3509293',
'3553870',
'3567772',
'3696540',
'3714985',
'3732534',
'3736566',
'3747040',
'3795080',
'3929460',
'4081500',
'4147110',
'4184642',
'4260499',
'4309450',
'4348641',
'4360440',
'4463008',
'4550899',
'4578038',
'4962285',
'4617766',
'4658183',
'4731571',
'3233418',
'4760708',
'4800301',
'4790181',
'5265148',
'5273556',
'3509627',
'4815507',
'5290054',
'4818278',
'5254746',
'5327713',
'5282830',
'5289473',
'5296793',
'5393075',
'5494420',
'5521627',
'5510407',
'5514662',
'5522782',
'5545686',
'5579700',
'5580232',
'5593871',
'5593962',
'5594937',
'4806858',
'5294766',
'3340894',
'3449438',
'3635608',
'3764874',
'4126645',
'4214622',
'4355171',
'4466560',
'4561719',
'5551404',
'5254237',
'5546643',
'5599197',
'4180488',
'4328129',
'4725663',
'4779488',
'5275779',
'5598493',
'3604788',
'3845338',
'4144601',
'4166585',
'4272473',
'4276321',
'4291446',
'4296819',
'4528368',
'4576792',
'4643889',
'4681377',
'4732922',
'5260219',
'5372608',
'5503211',
'5573048',
'5616737',
'5608855',
'5614472',
'5615688',
'5615749',
'5615778',
'5615823',
'5615828',
'5615883',
'5615952',
'5616660',
'5616802',
'5616807',
'5618064',
'5619219',
'5619551',
'3944889',
'4726645',
'4273566',
'3492282',
'4801678',
'4642162',
'4317118',
'5510280',
'4181117',
'4808707',
'4738050',
'4350376',
'3371240',
'4257172',
'5298120',
'5254852',
'4376599',
'4165030',
'5488075',
'4469618',
'4410468',
'4574046',
'4151011',
'4723986',
'4092870',
'4655909',
'5294786',
'5378466',
'5384393',
'5296962',
'5496243',
'5264418',
'5390081',
'3792798',
'5386654',
'5276312',
'4809820',
'4776172',
'4321844',
'4470397',
'5525389',
'3520892',
'3867398',
'4437744',
'5513259',
'3165849',
'3247721',
'3427253',
'3627123',
'3628265',
'3674436',
'3831579',
'4240661',
'4341064',
'4427756',
'4451749',
'5629158',
'4541383',
'4547906',
'4623811',
'5301007',
'5447955',
'5538299',
'5569437',
'5569889',
'5608860',
'5608866',
'5620474',
'5624686',
'5625623',
'5626231',
'3170680',
'3267170',
'3512574',
'3569109',
'3639475',
'3672654',
'3726452',
'3765235',
'4219287',
'4253999',
'4275933',
'4314517',
'4365416',
'4527581',
'4541678',
'3299379',
'4716803',
'4813937',
'3028879',
'5259955',
'5377693',
'5537266',
'5540517',
'5543840',
'5559434',
'5598545',
'5630291',
'5630525',
'5630669',
'5632374',
'3081915',
'3114065',
'3505941',
'3596775',
'3602582',
'3745608',
'3795015',
'3819279',
'3855974',
'3911718',
'4153557',
'4158861',
'4209773',
'4252885',
'4255181',
'4261642',
'4266757',
'4312507',
'4367654',
'4544672',
'4556047',
'3723442',
'4604856',
'4716993',
'4623722',
'5288031',
'4641361',
'4641502',
'4761833',
'4777184',
'4783434',
'4785354',
'5250425',
'4817254',
'5247014',
'5271677',
'5295783',
'5296243',
'5340366',
'5307349',
'5324938',
'5491604',
'5508664',
'5535623',
'5527095',
'5539668',
'5545840',
'5567692',
'5564141',
'5565993',
'5587788',
'5604877',
'5610874',
'5616752',
'5620482',
'5621095',
'5624742',
'5626576',
'5631091',
'5632085',
'5632104',
'5637253',
'5637057',
'5637243',
'5638249',
'5639303',
'5639378',
'5642081',
'5642322',
'5643154',
'5643533',
'5645732',
'5644842',
'5644843',
'5646267',
'5646434',
'5647178',
'5647238',
'5648443',
'5648736',
'5648766',
'5648772',
'5648784',
'5648800',
'3036801',
'3165261',
'3218973',
'3289946',
'3344719',
'3380401',
'3436784',
'3436850',
'3498101',
'3547146',
'3601368',
'3635273',
'3640476',
'3666201',
'3673613',
'3680198',
'3705678',
'3823613',
'3837133',
'3869061',
'3929630',
'4072083',
'4139753',
'4181882',
'4217189',
'4249258',
'4283254',
'4317537',
'4390568',
'4393616',
'4413403',
'4461972',
'4572454',
'4614871',
'3300247',
'4616515',
'4716992',
'4719602',
'4754673',
'4785415',
'4793090',
'4806616',
'5280568',
'5478594',
'5283683',
'5297441',
'5390343',
'5512756',
'5519950',
'5588862',
'5646320',
'5627216',
'5639482',
'5641775',
'5644804',
'5649709',
'5648437',
'5648642',
'5648653',
'5649996',
'5650730',
'5650782',
'5650793',
'5650940',
'5651024',
'5651049',
'5651057',
'5652093',
'5652165',
'5652168',
'5653236',
'5653398',
'5654103',
'5654435',
'5654570',
'5654623',
'5654685',
'5654811',
'5655793',
'5655862',
'5655923',
'5656483',
'5658180',
'5659160',
'5659591',
'5659664',
'5659704',
'5659725',
'5659896',
'5659966',
'5666709',
'5666801',
'5666870',
'3322748',
'3530495',
'3686496',
'3894150',
'4239231',
'4290095',
'4414066',
'4558799',
'5676984',
'4781480',
'5516409',
'5408817',
'5498249',
'5529932',
'5559817',
'5569725',
'5593315',
'5604781',
'5607279',
'5628787',
'5629056',
'5633497',
'5671071',
'5657471',
'5659650',
'5659726',
'5659724',
'5669454',
'5669487',
'5669527',
'5670539',
'5670550',
'5670946',
'5671042',
'5671048',
'5671052',
'5671057',
'5671067',
'5671400',
'5671555',
'5672080',
'5672394',
'5672417',
'5672598',
'5673374',
'5674048',
'5674239',
'5674554',
'5674685',
'5674761',
'5674766',
'5676395',
'5676500',
'5677857',
'3821903',
'5539462',
'5555390',
'3811287',
'3733339',
'4173028',
'5359121',
'3251320',
'3859872',
'4171505',
'5248465',
'5291373',
'4173098',
'3226592',
'3485812',
'3564391',
'3566082',
'3860355',
'4340367',
'4396454',
'4734637',
'5577532',
'5600279',
'5617872',
'5633244',
'5636916',
'5641963',
'5642067',
'5678946',
'5675586',
'5675720',
'5686185',
'3026098',
'3077478',
'3622357',
'3668683',
'3671918',
'3699562',
'3780692',
'3825458',
'4092961',
'4125901',
'4266050',
'4420646',
'4432052',
'4433361',
'4456294',
'4468395',
'5266017',
'4563537',
'3613190',
'4581874',
'4751628',
'4798008',
'4815132',
'5267840',
'5272243',
'5364212',
'5389476',
'5544657',
'5550781',
'5592117',
'5612658',
'5620072',
'5632379',
'5640961',
'5657797',
'5672272',
'5681169',
'5686388',
'5686786',
'5687078',
'5688897',
'5690376',
'5693160',
'5691490',
'5691656',
'5691691',
'5692296',
'5692518',
'5693668',
'5694462',
'5694471',
'5694506',
'3220714',
'5559232',
'5675671',
'5688160',
'5693249',
'5695318',
'3114597',
'3372047',
'3385021',
'3563301',
'3593518',
'3602679',
'3676773',
'3683015',
'3700620',
'3710893',
'3771166',
'3823275',
'3938093',
'4189039',
'4198749',
'4207198',
'4213912',
'4237655',
'4356594',
'4427895',
'4428600',
'4544829',
'4546363',
'4587243',
'4619844',
'4630944',
'4726487',
'4733031',
'4769352',
'4794149',
'4806564',
'5276416',
'5347640',
'5379555',
'5509185',
'5373424',
'5533063',
'5536835',
'5555442',
'5561417',
'5607518',
'5619038',
'5638654',
'5641150',
'5707201',
'5676860',
'5687102',
'5687116',
'5699719',
'5690247',
'5691033',
'5693764',
'5693774',
'5694587',
'5695884',
'5696214',
'5696218',
'5697025',
'5697806',
'5698752',
'5699989',
'5700041',
'5701283',
'5701319',
'5701361',
'5701372',
'5705157',
'5705329',
'5705364',
'5705372',
'5707189',
'5707239',
'3019159',
'3023933',
'3040441',
'3048571',
'3566398',
'3594625',
'3684781',
'3705479',
'3725039',
'3833627',
'4147389',
'4222471',
'4244792',
'4291874',
'4291892',
'4395237',
'4441575',
'5649517',
'5302530',
'4798944',
'4637033',
'5367196',
'4655974',
'4782233',
'5299712',
'5557940',
'5554537',
'5619105',
'5638241',
'5640101',
'5640669',
'5648079',
'5655287',
'5672439',
'5678326',
'5678710',
'5687611',
'5691506',
'5698142',
'5700093',
'5704798',
'5707283',
'5707304',
'5707325',
'5707778',
'5709408',
'5709925',
'5709917',
'5710251',
'5710275',
'5710363',
'5710705',
'5720356',
'5721508',
'5707189',
'5726127',
'5726124',
'5726149',
'5726209',
'5624686',
'5620482',
'5726272',
'5726735',
'5726751',
'5726968',
'5726984',
'5726973',
'5727039',
'5727082',
'5727139',
'5727382',
'3540979',
'4534538',
'4568567',
'5632773',
'5607964',
'5657015',
'5680689',
'5699242',
'5729527',
'5729595',
'5734454',
'5727881',
'5728596',
'5729609',
'5729606',
'5729610',
'5729606',
'5729677',
'4291874',
'5732322',
'5735198',
'5735567',
'3122907',
'3290398',
'3515036',
'3540956',
'4105855',
'4389860',
'4463354',
'4657935',
'4727816',
'4736230',
'4770529',
'5261991',
'5570205',
'5622798',
'5650251',
'5675532',
'5708496',
'5708547',
'5719248',
'5734871',
'5736869',
'5738068',
'5738082',
'5738101',
'5738110',
'5738120',
'5738314',
'5738703',
'5740673',
'4299895',
'4334540',
'4557362',
'5743453',
'4615202',
'4641514',
'5756294',
'5259962',
'5534170',
'5592320',
'5637109',
'5640263',
'5643397',
'5675657',
'5694242',
'5672394',
'5677600',
'5738718',
'5743330',
'5743575',
'5745355',
'5747349',
'5755445',
'5755823',
'5756694',
'5758188',
'5760176',
'3565931',
'3795263',
'4441765',
'4669538',
'4617847',
'5508033',
'5512726',
'4657615',
'5604798',
'5630712',
'5641587',
'5653993',
'5678119',
'5681856',
'5772388',
'5736517',
'5759745',
'5763838',
'5764294',
'5764784',
'5767494',
'4722247',
'5523921',
'5360467',
'5545254',
'5599571',
'5644163',
'5737794',
'5707283',
'5780735',
'5785372',
'3271120',
'4301324',
'4331238',
'4570441',
'4778818',
'5620008',
'5627221',
'5743847',
'5762232')


