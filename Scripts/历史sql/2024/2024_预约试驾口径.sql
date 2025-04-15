-- 试驾数
select count(distinct 预约ID) 预约试驾数,
count(distinct case when `最终试驾状态` = '已试驾' then 预约ID end) - count(distinct case when `异常_已试驾状态` = '异常_已试驾' then 预约ID end) 试驾数
from
(-- 预约试驾明细
	SELECT
    DISTINCT 
    ta.APPOINTMENT_ID 预约ID,
    ca.active_name 沃世界来源渠道,
    ta.one_id 客户ID,
    ta.customer_name 姓名,
    tmi.member_phone 注册手机号,
    ta.customer_phone 手机号,
    tm2.model_name 留资车型,
    h.大区,
    h.小区,
    ta.OWNER_CODE 经销商,
    tc2.COMPANY_NAME_CN 经销商名称,
    ta.CREATED_AT 预约时间,
    ta.ARRIVAL_DATE 预约主表_实际到店日期,
--    f.到店时间,
    tc.CODE_CN_DESC `预约单状态`
    ,CASE tad.status
    	WHEN 70711001 THEN '待试驾'
        WHEN 70711002 THEN '已试驾' 
        WHEN 70711003 THEN '已取消'
        END `预约试驾表-试驾状态`
    ,tad.drive_s_at as `预约试驾表-试驾开始时间`
    ,tad.drive_e_at as `预约试驾表-试驾结束时间`
    ,case when (e.DRIVE_STATUS = 20211001 or e.DRIVE_STATUS = 20211004) then  '待试驾'
     	when e.DRIVE_STATUS = 20211003  then  '已试驾'
     	when e.DRIVE_STATUS = 20211002  then  '已取消'
        else null end `试驾工单表-试驾状态`
    ,e.试驾开始时间 as `试驾工单表-试驾开始时间`
    ,e.试驾结束时间 as `试驾工单表-试驾结束时间`
    ,case when tc.CODE_CN_DESC ='已到店' or e.DRIVE_STATUS = 20211003 or e.试驾开始时间 is not null or e.试驾结束时间 is not null then '已试驾'
		  when e.DRIVE_STATUS in (20211001,20211004) then '待试驾'
		  when e.DRIVE_STATUS in (20211002) then '已取消'
		  else tc.CODE_CN_DESC end as `最终试驾状态`
	,case when(tc.CODE_CN_DESC ='已到店' or e.DRIVE_STATUS = 20211003 or e.试驾开始时间 is not null  or e.试驾结束时间 is not null ) -- 已试驾
    		and e.`试驾开始时间` is not null and e.`试驾开始时间` < ta.CREATED_AT then '异常_已试驾' end as 异常_已试驾状态
    ,e.item_id 试驾ID
    FROM cyx_appointment.tt_appointment ta
    LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
    left join `member`.tc_member_info tmi on ta.one_id =tmi.CUST_ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
    LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
    LEFT JOIN 
    (-- 经销商名称
	    select tc2.COMPANY_CODE , tc2.COMPANY_NAME_CN
	    from
	    (-- 排序取最新
		    select tc2.COMPANY_CODE, tc2.COMPANY_NAME_CN
		    ,row_number() over(partition by tc2.COMPANY_CODE  order by tc2.create_time desc) rk
		    from
		    organization.tm_company tc2
	    )tc2
	    where rk=1
    )tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
    LEFT JOIN basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID 
    LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
--    LEFT JOIN cyxdms_retail.tt_sales_orders tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID
--    LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS
    LEFT JOIN 
    (-- 大区小区
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
        ORDER BY tm.COMPANY_CODE asc
    ) h on h.COMPANY_CODE = ta.owner_code
    LEFT JOIN 
	(-- 试驾工单表
		select p.item_id,p.DRIVE_STATUS,p.created_at `试驾工单创建时间`,
		p.CUSTOMER_BUSINESS_ID,p.OWNER_CODE
		,p.DRIVE_S_AT 试驾开始时间
		,p.DRIVE_E_AT 试驾结束时间
		from drive_service.tt_testdrive_plan p
		where p.IS_DELETED = 0
	) e on tad.item_id = e.item_id
--	LEFT JOIN 
--	(-- 存在一个商机ID对应多条到店信息
--		select q.CUSTOMER_BUSINESS_ID,q.ARRIVE_DATE 到店时间
--		from cyx_passenger_flow.tt_passenger_flow_info q
--		where q.IS_DELETED =0
--		and q.ARRIVE_DATE >= '2024-03-18'
--		and q.CUSTOMER_BUSINESS_ID is not null
--	) f on ta.CUSTOMER_BUSINESS_ID = f.CUSTOMER_BUSINESS_ID
    WHERE ta.CREATED_AT >= '2024-03-18'
    AND ta.CREATED_AT <= '2024-03-24'
    and ta.APPOINTMENT_TYPE  in (70691001,70691002)    -- 预约试乘试驾
    AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
    order by ta.CREATED_AT
)a





-- 预约试驾_到店数【24年OKR口径】
select detail.年月,sum(detail.到店数final) as 到店数
from 
(-- 每个人每月到店数
	select 
	arrive.年月,
	arrive.mobile_phone,
	arrive.到店数,
	xiansuo.预约试驾量,
	if(arrive.到店数>xiansuo.预约试驾量,xiansuo.预约试驾量,arrive.到店数) 到店数final
	from 
	(--预约试驾到店数：每人每月
		select date_format(base.liuzi,'%Y-%m') 年月,base.mobile_phone,count(1) 到店数
		from 
		(-- 每条到店线索对应的最早预约时间
			select tpfi.id ,tpfi.mobile_phone,min(ta.created_at) liuzi
			from cyx_appointment.tt_appointment ta
			inner join cyx_passenger_flow.tt_passenger_flow_info tpfi 
				on ta.customer_phone = tpfi.mobile_phone 
			-- 用户预约后得在预约的30天内到店,即 预约时间<= 到店时间 <= 预约时间+30天
				and ta.CREATED_AT <= tpfi.created_at and tpfi.created_at <= (ta.CREATED_AT+ INTERVAL '30 day')
			where date(ta.created_at) BETWEEN '2023-01-01' AND '2023-12-31'
			AND ta.APPOINTMENT_TYPE in (70691001,70691002)    -- 预约试乘试驾
			AND ta.DATA_SOURCE = 'C'
			and ta.is_deleted =0
			group by 1,2
		) base 
		group by 1,2
	) arrive 
	left join 
	(--预约试驾线索数：每人每月
		select date_format(ta.CREATED_AT,'%Y-%m') 年月,ta.customer_phone,
		count(1) 预约试驾量
		from cyx_appointment.tt_appointment ta
		where date(ta.CREATED_AT) BETWEEN '2023-01-01' AND '2023-12-31'
		AND ta.APPOINTMENT_TYPE in (70691001,70691002)    -- 预约试乘试驾
		AND ta.DATA_SOURCE = 'C'
		and ta.is_deleted =0
		group by 1,2
	) xiansuo on xiansuo.年月=arrive.年月 and xiansuo.customer_phone=arrive.mobile_phone
) detail
group by 1 order by 1