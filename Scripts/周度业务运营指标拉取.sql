--vhc执行率（执行vhc工单组/总工单组）
--执行了VHC的工单组数量
select
	a.vin,
	t.DELIVERY_TAG
from
	cyx_repair.tm_vhc_info a
left join cyx_repair.tt_repair_order t on
	a.owner_code = t.owner_code
	and a.ro_no = t.ro_no
	and t.is_deleted = 0
where
	a.CREATED_AT >= '2024-12-27 00:00:00'
	and a.CREATED_AT < '2025-01-03 00:00:00'
	and a.IS_DELETED = 0
	and t.DELIVERY_TAG = 80011001
	
--总工单组数量
select
	COUNT(distinct vin) as 工单组数量
from
	cyx_repair.tt_repair_order
where
	owner_code = 'SHO'
	and CREATED_AT >= '2024-12-27 00:00:00'
	and CREATED_AT < '2025-01-03 00:00:00'
	and RO_NO = RELATION_RO_NO
	and IS_DELETED = 0
	
	--服务提醒查看率
select
	case
		when business_type = 'missingPartsArrivalNotice' then '缺件到货日期提醒'
		when business_type = 'appointOverTime' then '派工超时提醒'
		when business_type = 'deliveryVehicleOverTime' then '超时交车提醒'
		when business_type = 'receptionOverTime' then '接待超时提醒'
		when business_type = 'deliveryVehicleAhead' then '交车预警提醒'
		else '已离场未交车提醒'
	end
,
	sum(if(is_read = 10041001, 1, 0)) as 已读总记录,
	count(1) as 总发送记录
from
	cyx_repair.tt_msg_user_record
group by
	business_type;

--请帮忙统计保客营销部分数据，时间周期：12 / 6-1 / 9 （每周五-下周四为一个周期，延保部分只需要统计12 / 27-1 / 9 ）
--保客营销部分
-- 保养套餐数据
select
	owner_code,
	count(1)
from
	(
	select
		a.owner_code,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		cyx_repair.tt_repair_order a
	inner join cyx_repair.tt_popup_msg_record c on
		a.owner_code = c.owner_code
		and a.RO_NO = right(c.business_id ,
		12)
			and c.business_type = 'CDPBYTC'
		where
			a.CREATED_AT > '2024-11-01'
			and c.create_time >= '2024-12-03'
		group by
			a.VIN
) aa
group by
	owner_code;

-- 保养套餐购买数据匹配
select
	b.owner_code,
	count(1)
from
	(
	select
		a.owner_code,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		cyx_repair.tt_repair_order a
	inner join cyx_repair.tt_popup_msg_record c on
		a.owner_code = c.owner_code
		and a.RO_NO = right(c.business_id ,
		12)
			and c.business_type = 'CDPBYTC'
		where
			a.CREATED_AT > '2024-11-01'
			and c.create_time >= '2024-12-03'
		group by
			a.VIN
) aa
inner join
cyx_repair.tt_repair_order b on
	aa.vin = b.vin
	and IS_SERVE_CONTRACT_BUY_ORDER = '10041001'
	and b.CREATED_AT > '2024-12-03'
	and aa.minTime <= b.created_at
group by
	b.owner_code;

-- 出险无忧数据
select
	owner_code,
	count(1)
from
	(
	select
		a.owner_code,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		cyx_repair.tt_repair_order a
	inner join cyx_repair.tt_popup_msg_record c on
		a.owner_code = c.owner_code
		and a.RO_NO = right(c.business_id ,
		12)
			and c.business_type = 'CDPCXWY'
		where
			a.CREATED_AT > '2024-11-01'
			and c.create_time >= '2024-12-03'
		group by
			a.VIN
) aa
group by
	owner_code;

-- 出险购买数据匹配
select
	b.dealer_code,
	count(1)
from
	(
	select
		a.owner_code,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		cyx_repair.tt_repair_order a
	inner join cyx_repair.tt_popup_msg_record c on
		a.owner_code = c.owner_code
		and a.RO_NO = right(c.business_id ,
		12)
			and c.business_type = 'CDPCXWY'
		where
			a.CREATED_AT > '2024-11-01'
			and c.create_time >= '2024-12-03'
		group by
			a.VIN
) aa
inner join
dms_manage.tt_extended_warranty_purchase_give b on
	aa.vin = b.vin
	and b.extension_type = 83451001
	and b.CREATED_AT > '2024-12-03'
	and aa.minTime <= b.created_at
group by
	b.dealer_code;

-- 延保弹窗数据统计
select
	owner_code,
	count(1)
from
	(
	select
		a.owner_code,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		cyx_repair.tt_repair_order a
	inner join cyx_repair.tt_popup_msg_record c on
		a.owner_code = c.owner_code
		and a.RO_NO = right(c.business_id ,
		12)
			and c.business_type = 'CDPYB'
		where
			a.CREATED_AT > '2024-11-01'
			and c.create_time >= '2024-12-26'
		group by
			a.VIN
) aa
group by
	owner_code;

-- 延保弹窗购买记录
select
	b.OWNER_CODE,
	COUNT(1)
from
	(
	select
		a.owner_code,
		a.RO_NO,
		a.VIN,
		c.create_time,
		min(c.create_time) as minTime
	from
		cyx_repair.tt_repair_order a
	inner join cyx_repair.tt_popup_msg_record c on
		a.owner_code = c.owner_code
		and a.RO_NO = right(c.business_id ,
		12)
			and c.business_type = 'CDPYB'
		where
			a.CREATED_AT > '2024-11-01'
			and c.create_time >= '2024-12-26'
		group by
			a.VIN
) aa
inner join
cyx_repair.tt_repair_order b on
	aa.vin = b.vin
	and b.IS_EXTEND_INSURANCE = '10041001'
	and b.EXTEND_INSURANCE_NO is not null
	and b.CREATED_AT > '2024-12-26'
	and aa.minTime <= b.created_at
group by
	b.OWNER_CODE
	
	
-------------------------月度更新20250314
	
	一、线索跟进情况
1、保养线索：使用系统跟进的经销商数 / 总经销数

--使用系统跟进的经销商数
SELECT  count(DISTINCT dealer_code) FROM `dms_manage`.`tt_accident_clues` 
where follow_status in ('83531002','83531003','83531004') 
and created_at>'2024-12-01' and created_at<'2025-01-01' 

--总经销商数 
在厂端首页/系统管理/组织机构/经销商基础信息维护 查看营业状态为开业中的经销商

2.保养线索跟进 / 保养线索下发总数

--保养线索跟进
select count(*) from dms_manage.tt_invite_vehicle_record 
where invite_type in ('82381001','82381002') 
and is_deleted=0 and follow_status in ('82401002','82401003','82401004') 
and created_at>'2024-12-01' and created_at<'2025-01-01'

--保养线索下发总数
select count(*) from dms_manage.tt_invite_vehicle_record 
where invite_type in ('82381001','82381002') 
and is_deleted=0  and created_at>'2024-12-01' and created_at<'2025-01-01' 

3.事故线索：使用系统跟进的经销商数 / 总经销数

--使用系统跟进的经销商数
SELECT  count(DISTINCT dealer_code) FROM `dms_manage`.`tt_accident_clues` 
where follow_status in ('83531002','83531003','83531004') 
and created_at>'2024-12-01' and created_at<'2025-01-01' 

--总经销数
在厂端首页/系统管理/组织机构/经销商基础信息维护 查看营业状态为开业中的经销商

4.事故线索跟进数 /事故线索下发总数

SELECT  count(*) FROM `dms_manage`.`tt_accident_clues` 
where follow_status in ('83531002','83531003','83531004') 
and created_at>'2024-12-01' and created_at<'2025-01-01'  and is_deleted=0

SELECT  count(*) FROM `dms_manage`.`tt_accident_clues` 
where created_at>'2024-12-01' and created_at<'2025-01-01'  and is_deleted=0

5.续保线索：使用系统跟进的经销商数 / 总经销数

--使用系统跟进的经销商数
SELECT  count(DISTINCT dealer_code) FROM `dms_manage`.`tt_accident_clues` 
where follow_status in ('83531002','83531003','83531004') and created_at>'2024-12-01' and created_at<'2025-01-01' 

--总经销商数 
在厂端首页/系统管理/组织机构/经销商基础信息维护 查看营业状态为开业中的经销商

6.续保线索跟进数/续保线索下发总数

--续保线索跟进数
select count(*) from `dms_manage`.tt_invite_insurance_vehicle_record 
where follow_status in ('82401002','82401003','82401004') and is_deleted=0 and created_at>'2024-12-01' and created_at<'2025-01-01'

--续保线索下发总数
select count(*) from `dms_manage`.tt_invite_insurance_vehicle_record 
where  is_deleted=0 and created_at>'2024-12-01' and created_at<'2025-01-01'

7.故障灯线索：使用系统跟进的经销商数 / 总经销数

--使用系统跟进的经销商数
SELECT  count(DISTINCT dealer_code) FROM `dms_manage`.`tt_accident_clues` 
where follow_status in ('83531002','83531003','83531004') and created_at>'2024-12-01' and created_at<'2025-01-01' 

--总经销商数 
在厂端首页/系统管理/组织机构/经销商基础信息维护 查看营业状态为开业中的经销商

8.故障灯线索跟进数/故障灯线索下发总数

--故障灯线索跟进数
SELECT count(*) FROM `dms_manage`.`tt_fault_light_clue`
where  is_deleted=0 and created_at>'2024-12-01' 
and created_at<'2025-01-01' and follow_status not  in ('10551001','10551004','10551015')

--故障灯线索下发总数
SELECT count(*) FROM `dms_manage`.`tt_fault_light_clue` 
where  is_deleted=0 and created_at>'2024-12-01' and created_at<'2025-01-01' 


二、环检单
1.环检单执行率：开单台次/应开单台次

--环检单开单台次:
select count(distinct b.vin) from  cyx_repair.tm_precheck_order a 
inner join cyx_repair.tt_repair_order  b on a.owner_code=b.OWNER_CODE  and a.ro_no=b.ro_no 
where b.IS_DELETED =0 and  b.RO_CREATE_DATE >='2024-12-01' and b.RO_CREATE_DATE <='2024-12-31 23:59:59'

--应开单台次
select count(distinct vin) from  cyx_repair.tt_repair_order  
where IS_DELETED =0 and  RO_CREATE_DATE >='2024-12-01' and RO_CREATE_DATE <='2024-12-31 23:59:59'

2.App端查查看用户数/总推送数


三、工单原厂件占比

1.执行零件/应执行零件

--执行零件
select count(1) from cyx_repair.tt_maintain_reminder_record where is_deleted=0 and use_status=10041001 and created_at>='2024-12-01' and created_at<'2025-01-01'

--应执行零件
select count(1) from cyx_repair.tt_maintain_reminder_record where is_deleted=0 and use_status=10041002 and created_at>='2024-12-01' and created_at<'2025-01-01'

2.已结算的工单组包含免费项目的工单数量/已结算的工单组（除工单组为仅零售/PDS和保修）

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
   AND t.RO_CREATE_DATE>='2025-01-14'
   and t.RO_CREATE_DATE<'2025-01-16'
   AND a.IS_DELETED=0
 GROUP BY t.ro_no,t.owner_code)aa
 
--已结算的工单组（除工单组为仅零售/PDS和保修）
 SELECT count(1)
  FROM(SELECT t.owner_code,t.ro_no,
       t.RO_CREATE_DATE
FROM cyx_repair.tt_ro_add_item a
LEFT JOIN cyx_repair.tt_repair_order t
    ON a.owner_code = t.owner_code
    AND a.ro_no = t.ro_no
    AND t.IS_DELETED = 0
WHERE  t.RO_STATUS='80491003' and t.REPAIR_TYPE_CODE in ('I','M','N')
  AND t.RO_CREATE_DATE  >= '2025-01-10' and t.RO_CREATE_DATE<'2025-01-14'
GROUP BY t.ro_no,t.owner_code)aa



五、电子结算单
1.结算单开单/总工单

--结算单开单
select count(1) from cyx_repair.tt_balance_accounts a inner join cyx_repair.tt_repair_order b on a.ro_no=b.ro_no and a.owner_code=b.owner_code  where a.is_deleted=0 and b.is_deleted=0 and is_red=10041002 and b.RO_CREATE_DATE>='2024-12-01' and b.RO_CREATE_DATE <='2024-12-31 23:59:59'

--总工单
select count(1) from  cyx_repair.tt_repair_order  where IS_DELETED =0 and  RO_CREATE_DATE >='2024-12-01' and RO_CREATE_DATE <='2024-12-31 23:59:59'




六、延保
1.（新车延保C端+ B端订单量）/总新车销量

--（新车延保C端+ B端订单量）
SELECT count(*) FROM `dms_manage`.`tt_extended_warranty_purchase_give` a inner join `dms_manage`.`tt_extended_warranty_product`t on a.product_name=t.product_name and a.product_no=t.product_no and t.is_deleted=0 where a.created_at>='2024-07-01' and a.created_at <'2024-08-01' and a.source=81561001 and t.new_old_type=81531001

--总新车销量


2.延保B端订单量(非赠送)/总进场台次

--延保B端订单量(非赠送)
select count(*) from `dms_manage`.`tt_extended_warranty_purchase_give` a where a.created_at>='2024-07-01' and a.created_at <'2024-08-01'  and a.owner_code not in ('VVD','VVH') 

--总进厂台次
select count(*)  from cyx_repair.tt_repair_order where RO_CREATE_DATE>='2024-07-01' and RO_CREATE_DATE<'2024-08-01' 


七、保养套餐
1.保养套餐B端订单量(非赠送)/总进场台次

--保养套餐b端订单数
select count(*) from vehicle.care_buyed 
where CREATE_TIME >='2024-07-01' and CREATE_TIME <'2024-08-01' and activity_type=83411002 and source ='NEWBIE'

--总进厂台次
select count(*)  from cyx_repair.tt_repair_order 
where RO_CREATE_DATE>='2024-07-01' and RO_CREATE_DATE<'2024-08-01' 




八、店补采纳跟进
1.1.使用背靠背店补的经销商数/经销商总数

--使用背靠背店补的经销商数
select count(distinct a.dealer_code)
 from dms_manage.tt_part_purchase_order a inner JOIN dms_manage.tt_part_purchase_order_detail b on a.id=b.purchase_order_id
 inner JOIN cyx_repair.tt_short_part c on b.id=c.purchase_order_detail_id inner JOIN cyx_repair.tt_repair_order d on c.OWNER_CODE=d.OWNER_CODE 
 and c.SHEET_NO=d.RO_NO inner JOIN cyx_repair.tt_ro_repair_part e on d.OWNER_CODE=e.OWNER_CODE and d.RO_NO=e.RO_NO and b.part_no=e.part_no 
 where  c.is_linked=10041001 and d.RO_NO is not null 
 and a.created_at>='2025-01-01'
 and a.created_at<'2025-02-01'

 --总经销商数
在厂端首页/系统管理/组织机构/经销商基础信息维护 查看营业状态为开业中的经销商
2.事故单背靠背订单行/事故工单出库行（月度）

--事故单背靠背订单行
select count(*)
--b.id, a.created_at as 采购下单时间, a.order_level as 单据类型, a.dealer_code as 经销商编码, a.purchase_no as 采购单号,
-- b.part_no as 零件号, b.order_quantity as 采购数量, c.SHEET_NO as 工单号, d.REPAIR_TYPE_CODE as 维修类型, d.RO_CREATE_DATE as 开单日期,
-- d.VIN as 车架号 
 from dms_manage.tt_part_purchase_order a 
 inner JOIN dms_manage.tt_part_purchase_order_detail b on a.id=b.purchase_order_id
 inner JOIN cyx_repair.tt_short_part c on b.id=c.purchase_order_detail_id inner JOIN cyx_repair.tt_repair_order d on c.OWNER_CODE=d.OWNER_CODE
 and c.SHEET_NO=d.RO_NO
 inner JOIN cyx_repair.tt_ro_repair_part e on d.OWNER_CODE=e.OWNER_CODE and d.RO_NO=e.RO_NO and b.part_no=e.part_no and e.IS_DELETED = 0
 INNER JOIN cyx_repair.tt_repair_order f on f.OWNER_CODE=e.OWNER_CODE and f.RO_NO=e.RO_NO and f.IS_DELETED = 0
 where a.created_at BETWEEN '2025-02-03' and '2025-03-10' 
 and c.is_linked=10041001 and d.RO_NO is not null and d.repair_type_code='I'
 and e.part_no is not null;

--事故工单出库行（月度）
select count(*)
--d.OWNER_CODE, d.ro_no, d.created_at, e.part_no, e.part_quantity 
from cyx_repair.tt_repair_order d inner JOIN cyx_repair.tt_ro_repair_part e
on d.OWNER_CODE=e.OWNER_CODE and d.RO_NO=e.RO_NO and e.IS_DELETED = 0 
WHERE d.created_at BETWEEN '2025-02-03' and '2025-03-10' and d.IS_DELETED = 0
and d.repair_type_code='I' and e.part_no is not null 
	
	
	