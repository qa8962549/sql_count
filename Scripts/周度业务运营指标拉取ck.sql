--vhc执行率（执行vhc工单组/总工单组）
--1执行了VHC的工单组数量
select
1 `a`,count(distinct a.vin)
from
ods_cyre.ods_cyre_tm_vhc_info_d a
left join ods_cyre.ods_cyre_tt_repair_order_d t on a.owner_code = t.OWNER_CODE
and a.ro_no = t.RO_NO
and t.IS_DELETED = 0
where
and a.created_at >= '2025-02-06'
and a.created_at < '2025-02-13'
and a.is_deleted = 0
and t.DELIVERY_TAG = 80011001
	
--2总工单组数量
select
1 `a`,COUNT(distinct VIN) as `工单组数量`
from
ods_cyre.ods_cyre_tt_repair_order_d
where
and CREATED_AT >= '2025-02-06'
and CREATED_AT < '2025-02-13'
and RO_NO = RELATION_RO_NO
and IS_DELETED = 0

	
--3服务提醒查看率
select
	case
		when business_type = 'missingPartsArrivalNotice' then '缺件到货日期提醒'
		when business_type = 'appointOverTime' then '派工超时提醒'
		when business_type = 'deliveryVehicleOverTime' then '超时交车提醒'
		when business_type = 'receptionOverTime' then '接待超时提醒'
		when business_type = 'deliveryVehicleAhead' then '交车预警提醒'
		else '已离场未交车提醒'
	end `状态`
,
	sum(if(is_read = 10041001, 1, 0)) as `已读总记录`,
	count(1) as `总发送记录`
from
	ods_cyre.ods_cyre_tt_msg_user_record_d
where 
	created_time > '2024-11-01'
	and created_time < '2025-02-01'
group by
	business_type;

--请帮忙统计保客营销部分数据，时间周期：12 / 6-1 / 9 （每周五-下周四为一个周期，延保部分只需要统计12 / 27-1 / 9 ）
--4保客营销部分
-- 保养套餐数据
select
	OWNER_CODE,
	count(1)
from
	(
	select
		a.OWNER_CODE,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		ods_cyre.ods_cyre_tt_repair_order_d a
	inner join ods_cyre.ods_cyre_tt_popup_msg_record_d c on
		a.OWNER_CODE = c.owner_code
		and a.RO_NO = right(c.business_id ,
		12)
			and c.business_type = 'CDPBYTC'
		where
			a.CREATED_AT >='2024-12-01'
			and a.CREATED_AT < '2025-02-01'
			and c.create_time >= '2024-12-01'
			and c.create_time < '2025-02-01'
		group by
			1,2,3,4
) aa
group by
	OWNER_CODE;

-- 5保养套餐购买数据匹配
select
	b.OWNER_CODE,
	count(1)
from
	(
	select
		a.OWNER_CODE,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		ods_cyre.ods_cyre_tt_repair_order_d a
	inner join ods_cyre.ods_cyre_tt_popup_msg_record_d c on
		a.OWNER_CODE = c.owner_code
		and a.RO_NO = right(c.business_id ,12)
			and c.business_type = 'CDPBYTC'
		where
			a.CREATED_AT >='2024-12-01'
			and a.CREATED_AT < '2025-02-01'
			and c.create_time >= '2024-12-01'
			and c.create_time < '2025-02-01'
		group by
			1,2,3,4
) aa
inner join
ods_cyre.ods_cyre_tt_repair_order_d b on aa.VIN = b.VIN
where IS_SERVE_CONTRACT_BUY_ORDER = '10041001'
	and b.CREATED_AT >='2024-12-01'
	and b.CREATED_AT < '2025-02-01'
	and aa.minTime <= toDateTime(left(b.CREATED_AT,19))
group by
	b.OWNER_CODE

-- 6出险无忧数据 CDPCXWY
select
	OWNER_CODE,
	count(1)
from
	(
	select
		a.OWNER_CODE,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		ods_cyre.ods_cyre_tt_repair_order_d a
	inner join ods_cyre.ods_cyre_tt_popup_msg_record_d c on
		a.OWNER_CODE = c.owner_code
		and a.RO_NO = right(c.business_id ,12)
			and c.business_type = 'CDPCXWY'
		where
			a.CREATED_AT >='2024-12-01'
			and a.CREATED_AT < '2025-02-01'
			and c.create_time >= '2024-12-01'
			and c.create_time < '2025-02-01'
		group by
			1,2,3,4
) aa
group by
	OWNER_CODE

-- 7出险购买数据匹配
select
	b.dealer_code,
	count(1)
from
	(
	select
		a.OWNER_CODE,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		ods_cyre.ods_cyre_tt_repair_order_d a
	inner join ods_cyre.ods_cyre_tt_popup_msg_record_d c on
			a.OWNER_CODE = c.owner_code
			and a.RO_NO = right(c.business_id ,12)
			and c.business_type = 'CDPCXWY'
		where
			a.CREATED_AT >='2025-02-27'
			and a.CREATED_AT < '2025-03-06'
			and c.create_time >= '2025-02-27'
			and c.create_time < '2025-03-06'
		group by
			1,2,3,4
) aa
inner join
ods_dmma.ods_dmma_tt_extended_warranty_purchase_give_d b on aa.VIN = b.vin
where b.extension_type = 83451001
	and b.created_at >='2025-02-27'
	and b.created_at  < '2025-03-06'
	and aa.minTime <= toDateTime(left(b.created_at,19))
group by
	b.dealer_code

	-- 7出险购买数据匹配
select
	b.dealer_code,
	count(1)
from
	(
	select
		a.OWNER_CODE,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		ods_cyre.ods_cyre_tt_repair_order_d a
	inner join ods_cyre.ods_cyre_tt_popup_msg_record_d c on
			a.OWNER_CODE = c.owner_code
			and a.RO_NO = right(c.business_id ,12)
			and c.business_type = 'CDPCXWY'
		where
			a.CREATED_AT >='{last_week}'
			and a.CREATED_AT < '{now_week}'
			and c.create_time >= '{last_week}'
			and c.create_time < '{now_week}'
		group by
			1,2,3,4
) aa
inner join
ods_dmma.ods_dmma_tt_extended_warranty_purchase_give_d b on aa.VIN = b.vin
where b.extension_type = 83451001
	and b.created_at >='{last_week}'
    and b.created_at < '{now_week}'
	and aa.minTime <= toDateTime(left(b.created_at,19))
group by
	b.dealer_code
	
--8 延保弹窗数据统计 CDPYB
select
	OWNER_CODE,
	count(1)
from
	(
	select
		a.OWNER_CODE,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		ods_cyre.ods_cyre_tt_repair_order_d a
	inner join ods_cyre.ods_cyre_tt_popup_msg_record_d c on
			a.OWNER_CODE = c.owner_code
			and a.RO_NO = right(c.business_id ,12)
			and c.business_type = 'CDPYB'
		where
			a.CREATED_AT >='2024-12-01'
			and a.CREATED_AT < '2025-02-01'
			and c.create_time >= '2024-12-01'
			and c.create_time < '2025-02-01'
		group by
			1,2,3,4
) aa
group by
	OWNER_CODE;

-- 9延保弹窗购买记录
select
	b.OWNER_CODE,
	COUNT(1)
from
	(
	select
		a.OWNER_CODE,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		ods_cyre.ods_cyre_tt_repair_order_d a
	inner join ods_cyre.ods_cyre_tt_popup_msg_record_d c on
			a.OWNER_CODE = c.owner_code
			and a.RO_NO = right(c.business_id ,12)
			and c.business_type = 'CDPYB'
		where
			a.CREATED_AT >='2024-12-01'
			and a.CREATED_AT < '2025-02-01'
			and c.create_time >= '2024-12-01'
			and c.create_time < '2025-02-01'
		group by
			1,2,3,4
) aa
inner join
ods_cyre.ods_cyre_tt_repair_order_d b on aa.VIN = b.VIN
where b.IS_EXTEND_INSURANCE = '10041001'
	and b.EXTEND_INSURANCE_NO is not null
	and b.CREATED_AT >='2024-12-01'
	and b.CREATED_AT < '2025-02-01'
	and aa.minTime <= toDateTime(left(b.CREATED_AT,19))
group by
	b.OWNER_CODE
	
	
	
	
	
	
--数据源：dws-cluster-prod-newbie1 库：newbie_prod


--续保经销商使用率
--续保线索使用经销商数/总经销商数（正常营业）
	
--续保线索使用经销商数
select count(DISTINCT dealer_code) 
from ods_dmma.ods_dmma_tt_invite_insurance_vehicle_record_d 
where 1=1
and follow_status in ('82401002','82401003','82401004') 
and is_deleted=0 
and created_at>='2025-01-22' 
and created_at<'2025-01-29'

--经销商数（营业中）
--select count(company_code)
--from ods_orga.ods_orga_tm_company_cur 
--WHERE status = 16031002 
--and company_type in (15061003,15061017)

--续保线索跟进率
--续保线索跟进数/续保线索下发总数
--续保线索跟进数
select count(*) 
from ods_dmma.ods_dmma_tt_invite_insurance_vehicle_record_d 
where follow_status in ('82401002','82401003','82401004') 
and is_deleted=0 
and created_at>'2025-01-23' 
and created_at<'2025-01-30'

--续保线索下发总数
select count(*) 
from ods_dmma.ods_dmma_tt_invite_insurance_vehicle_record_d 
where  is_deleted=0 
and created_at>'2025-01-23' 
and created_at<'2025-01-30'



--
--六、服务提醒
--
--1.开通服务提醒的经销商数/经销商总数
select owner_code as `经销商`,CASE
   WHEN business_type = 'missingPartsArrivalNotice' THEN '缺件到货日期提醒'
   WHEN business_type = 'appointOverTime' THEN '派工超时提醒'
   WHEN business_type = 'deliveryVehicleOverTime' THEN '超时交车提醒'
   WHEN business_type = 'receptionOverTime' THEN '接待超时提醒'
   WHEN business_type = 'deliveryVehicleAhead' THEN '交车预警提醒'
   ELSE '已离场未交车提醒'
   END as `业务类型`
   , sum(if(is_read=10041001, 1, 0)) as `已读总记录`,count(1) as `总发送记录`
   from ods_cyre.ods_cyre_tt_msg_user_record_d 
    where created_time BETWEEN '2025-02-06' and '2025-02-12'
   GROUP BY owner_code,business_type
  
--以上SQL导出后
--2.查看过服务提醒的经销商数/触发过提醒的经销商总数
--查看过服务提醒的经销商数=筛选出已读总记录不等于0的，然后对经销商列去重
--触发过提醒的经销商总数=经销商列进行去重
--3.服务提醒用户点击“查看”数/提醒发送数
--服务提醒查看数=已读总记录之和
--提醒发送数=总发送记录之和
   select count(distinct if(x.`已读总记录`<>0,`经销商`,null))/ count(distinct x.`经销商`) `查看过服务提醒的经销商数/触发过提醒的经销商总数`,
   sum(`已读总记录`)/sum(`总发送记录`)`服务提醒用户点击“查看”数/提醒发送数`
   from 
	   (select owner_code as `经销商`,CASE
	   WHEN business_type = 'missingPartsArrivalNotice' THEN '缺件到货日期提醒'
	   WHEN business_type = 'appointOverTime' THEN '派工超时提醒'
	   WHEN business_type = 'deliveryVehicleOverTime' THEN '超时交车提醒'
	   WHEN business_type = 'receptionOverTime' THEN '接待超时提醒'
	   WHEN business_type = 'deliveryVehicleAhead' THEN '交车预警提醒'
	   ELSE '已离场未交车提醒'
	   END as `业务类型`
	   , sum(if(is_read=10041001, 1, 0)) as `已读总记录`,count(1) as `总发送记录`
	   from ods_cyre.ods_cyre_tt_msg_user_record_d 
	    where created_time BETWEEN '2025-02-06' and '2025-02-12'
	   GROUP BY owner_code,business_type)x
   
   
--
--七、店补采纳跟进
--1.使用背靠背店补的经销商数/经销商总数
--使用背靠背店补的经销商数
select count(distinct a.dealer_code)
 from dms_manage.tt_part_purchase_order a inner JOIN dms_manage.tt_part_purchase_order_detail b on a.id=b.purchase_order_id
 inner JOIN cyx_repair.tt_short_part c on b.id=c.purchase_order_detail_id inner JOIN cyx_repair.tt_repair_order d on c.OWNER_CODE=d.OWNER_CODE 
 and c.SHEET_NO=d.RO_NO inner JOIN cyx_repair.tt_ro_repair_part e on d.OWNER_CODE=e.OWNER_CODE and d.RO_NO=e.RO_NO and b.part_no=e.part_no 
 where  c.is_linked=10041001 
 and d.RO_NO is not null 
 and a.created_at>='2025-02-06'
 and a.created_at<'2025-02-12'


--2.事故单背靠背订单行/事故工单出库行（月度）

--事故单背靠背订单行
select count(*)
--a.created_at as 采购下单时间, a.order_level as 单据类型, a.dealer_code as 经销商编码, a.purchase_no as 采购单号,
-- b.part_no as 零件号, b.order_quantity as 采购数量, c.SHEET_NO as 工单号, d.REPAIR_TYPE_CODE as 维修类型, d.RO_CREATE_DATE as 开单日期,
-- d.VIN as 车架号 
 from dms_manage.tt_part_purchase_order a 
 inner JOIN dms_manage.tt_part_purchase_order_detail b on a.id=b.purchase_order_id
 inner JOIN cyx_repair.tt_short_part c on b.id=c.purchase_order_detail_id inner JOIN cyx_repair.tt_repair_order d on c.OWNER_CODE=d.OWNER_CODE
 and c.SHEET_NO=d.RO_NO
 inner JOIN cyx_repair.tt_ro_repair_part e on d.OWNER_CODE=e.OWNER_CODE and d.RO_NO=e.RO_NO and b.part_no=e.part_no and e.IS_DELETED = 0
 INNER JOIN cyx_repair.tt_repair_order f on f.OWNER_CODE=e.OWNER_CODE and f.RO_NO=e.RO_NO and f.IS_DELETED = 0
 where a.created_at BETWEEN '2025-02-12' and '2025-02-19' and c.is_linked=10041001 and d.RO_NO is not null and d.repair_type_code='I'
 and e.part_no is not null
union all 
--事故工单出库行（月度）
select 
count(*)
--d.OWNER_CODE, d.ro_no, d.created_at, e.part_no, e.part_quantity 
from cyx_repair.tt_repair_order d 
inner JOIN cyx_repair.tt_ro_repair_part e
on d.OWNER_CODE=e.OWNER_CODE and d.RO_NO=e.RO_NO and e.IS_DELETED = 0 WHERE d.created_at BETWEEN '2025-02-12' and '2025-02-19' and d.IS_DELETED = 0
and d.repair_type_code='I' and e.part_no is not null 



--1.已结算的工单组包含免费项目的工单数量/已结算的工单组（除工单组为仅零售/PDS和保修）
--已结算的工单组包含免费项目的工单数量
SELECT count(1)
  FROM(SELECT t.owner_code,
       t.ro_no,
       t.RO_CREATE_DATE
  FROM cyx_repair.tt_ro_add_item a
  LEFT JOIN cyx_repair.tt_repair_order t ON a.owner_code=t.owner_code AND a.ro_no=t.ro_no AND t.IS_DELETED=0
 WHERE a.ADD_ITEM_CODE IN('CLJC','CLQX')
   and t.RO_STATUS='80491003'
   and t.REPAIR_TYPE_CODE in('I','M','N')
   AND t.RO_CREATE_DATE>='2025-02-13' 
   and t.RO_CREATE_DATE<'2025-02-20'
   AND a.IS_DELETED=0
 GROUP BY t.ro_no,t.owner_code)aa
 
 --已结算的工单组
SELECT count(1)
  FROM(SELECT t.owner_code,t.ro_no,
       t.RO_CREATE_DATE
FROM cyx_repair.tt_ro_add_item a
LEFT JOIN cyx_repair.tt_repair_order t
    ON a.owner_code = t.owner_code
    AND a.ro_no = t.ro_no
    AND t.IS_DELETED = 0
WHERE  t.RO_STATUS='80491003' and t.REPAIR_TYPE_CODE in ('I','M','N')
  AND t.RO_CREATE_DATE  >='2025-02-13' 
  and t.RO_CREATE_DATE<'2025-02-20'
GROUP BY t.ro_no,t.owner_code)aa
 