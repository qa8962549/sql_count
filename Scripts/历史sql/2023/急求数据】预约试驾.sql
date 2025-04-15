-- 地球日活动数据
select COUNT(1)预约数
from
(
	SELECT
	DISTINCT ta.APPOINTMENT_ID 预约ID,
	ta.CREATED_AT 预约时间,
	ta.ARRIVAL_DATE 实际到店日期,
	ca.active_name 活动名称,
	ta.one_id 客户ID,
	ta.customer_name 姓名,
	ta.customer_phone 手机号,
	tm2.MODEL_NAME 预约车型,
	h.大区,
	h.小区,
	ta.OWNER_CODE 经销商,
	CASE tad.status
		WHEN 70711001 THEN '待试驾'
	    WHEN 70711002 THEN '已试驾' 
	    WHEN 70711003 THEN '已取消'
	    END 试驾状态,
	tad.drive_s_at 试驾开始时间,
	tad.drive_e_at 试驾结束时间,
	ta.is_app 
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
	LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	LEFT JOIN cyxdms_retail.tt_sales_orders tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID
	LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
	LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS
	LEFT JOIN (
	    select 
	        DISTINCT
	        tm.COMPANY_CODE,
	        tg2.ORG_NAME 大区,
	        tg1.ORG_NAME 小区
	    from organization.tm_company tm
	    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
	    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
	    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	    ORDER BY tm.COMPANY_CODE ASC) h on h.COMPANY_CODE = ta.owner_code
	left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID and tm2.IS_DELETED = 0
	WHERE ta.CREATED_AT >= '2023-01-01'
	AND ta.CREATED_AT <= '2023-05-18 23:59:59'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
--	and ca.active_code = 'IBDMMARXC4C40XCX2023VCCN'   -- 地球日市场活动代码
	order by ta.CREATED_AT
) a


--### 预约试驾订单数量  预约试驾到店率
select 
-- a.沃世界来源渠道,
count(1) 预约试驾订单数量
 ,sum(case when a.FIRST_PASSENGER_TIME is not null and a.FIRST_PASSENGER_TIME>a.mdate then 1 else 0 end) 到店数
-- ,sum(case when a.FIRST_PASSENGER_TIME is not null then 1 else 0 end) 到店数
-- ,sum(case when a.FIRST_DRIVE_TIME is not null and a.FIRST_DRIVE_TIME>a.mdate then 1 else 0 end) 试驾数
,round(sum(case when a.FIRST_PASSENGER_TIME is not null and a.FIRST_PASSENGER_TIME>a.mdate then 1 else 0 end)/count(1),3)"预约试驾到店率 - 整体"
-- ,round(sum(case when a.FIRST_DRIVE_TIME is not null and a.FIRST_DRIVE_TIME>a.mdate then 1 else 0 end)/count(1),3) 试驾率
from (
	select a.*,s.FIRST_PASSENGER_TIME,s.FIRST_DRIVE_TIME
	from (
		select m.id memberid
		,m.member_phone
		,a.one_id cust_id
		,a.OWNER_CODE
		-- ,a.CREATED_AT 预约时间
		,a.CUSTOMER_BUSINESS_ID
		,t.active_name 
		,case when t.active_name in ('2022年Q1 沃世界推荐购活动-零售&直售车型','2022年Q3 沃世界推荐购活动-零售&直售车型','2022年Q4 沃世界推荐购活动-零售&直售车型','2022年Q2 沃世界推荐购活动-零售&直售车型') then '推荐购'
					when t.active_name in ('沃世界预约','3.0改版-我的页面-预约试驾','2021 沃世界公众号欢迎语推送','3.0改版-商城首页-预约试驾') then '自然流量'
					else '沃世界线上活动' end 沃世界来源渠道
		,min(a.CREATED_AT) mdate
		from cyx_appointment.tt_appointment a 
		left join activity.cms_active t on a.CHANNEL_ID=t.uid
		left join (
--			#存在cust_id一对多memberid,所以获取最新的cust_id对应的memberid
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
		and a.CREATED_AT >='2022-01-01' and a.CREATED_AT <'2022-05-19'
		GROUP BY 1,2,3,4,5,6 
		order by 3 desc 
	) a 
	left join customer_business.tt_business_statistics s on a.CUSTOMER_BUSINESS_ID=s.CUSTOMER_BUSINESS_ID and s.first_passenger_time >='2022-01-01' and s.first_passenger_time <'2022-05-19'
) a 