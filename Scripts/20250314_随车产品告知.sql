SELECT 
distinct 
tsoe.first_deposit_date AS "定金支付时间", 
tsov.CONFIRMED_DATE AS "交车时间", 
tso.SO_NO AS "订单编号", 
--tso.SO_NO_ID,
CASE WHEN tso.strong_weak_agent = 87811001 THEN '强代理' 
WHEN tso.strong_weak_agent = 87811002 THEN '弱代理' 
WHEN tso.strong_weak_agent = 87811004 THEN '新零售' ELSE '批零制' END AS "销售模式",
tsov.sales_vin AS "VIN", 
tso.OWNER_CODE AS "所属经销商", 
h.company_short_name_cn 经销商简称,
h.大区,
h.小区,
tsov.DELIVERY_OWNER_CODE AS "订车门店",
h2.company_short_name_cn 订车门店简称,
h2.大区 订车门店大区,
h2.小区 订车门店小区,
f.model_name 车型,
tc.config_name 配置,
case when tsov.CONFIRMED_DATE is not null then '是'  ELSE '否' end 是否交车,
CASE WHEN tfui.FILE_UPLOAD_INFO_ID IS NULL THEN '否' ELSE '是' end 是否含附件,
--tfui.created_at  最新附件上传时间,
CASE WHEN DATE(tfui.created_at) = CURDATE()- interval '1' day THEN '是' ELSE '否' END AS "是否当天附件",
case when zh.vin is not null then '是'  ELSE '否' end 是否有装潢工单,
zh.装潢工单经销商,
zh.装潢工单工单号
--tfui.updated_at
FROM `cyxdms_retail`.`tt_sales_orders` tso
INNER JOIN `cyxdms_retail`.`tt_sales_order_vin` tsov ON tsov.VI_NO = tso.SO_NO and tsov.is_deleted<>'1'
INNER JOIN cyxdms_retail.tt_sales_orders_ext tsoe ON tsoe.SO_NO_ID = tso.SO_NO_ID and tsoe.is_deleted<>'1'
LEFT JOIN 
	(
	-- 取最新附件时间
	select x.*
	from 
		(
		select tfui.BILL_ID,
		tfui.FILE_UPLOAD_INFO_ID,
		row_number()over(partition by tfui.BILL_ID order by tfui.created_at desc) rk,
		tfui.created_at,
		updated_at
		from cyxdms_retail.tc_file_upload_info tfui 
		where 1=1 
--		and tfui.created_at<curdate() -- 附件上传时间和装潢工单均截止前一天
		and tfui.is_deleted <>'1'
		)x where x.rk=1 
	)tfui ON tfui.BILL_ID = tso.SO_NO_ID
left join 
	(
	-- 装潢工单
	select 
	a.vin,
	RO_CREATE_DATE,
	string_agg(a.owner_code, ', ') 装潢工单经销商,
	string_agg(a.ro_no, ', ') 装潢工单工单号
	from cyx_repair.tt_repair_order a
	left join cyx_repair.tt_ro_hand_repair_project b on a.OWNER_CODE = b.owner_code and a.RO_NO = b.ro_no
	left JOIN `cyxdms_retail`.`tt_sales_order_vin` tsov on a.vin=tsov.sales_vin
	left join `cyxdms_retail`.`tt_sales_orders` tso ON tsov.VI_NO = tso.SO_NO and tsov.is_deleted<>'1'
	left JOIN cyxdms_retail.tt_sales_orders_ext tsoe ON tsoe.SO_NO_ID = tso.SO_NO_ID and tsoe.is_deleted<>'1'
	where a.REPAIR_TYPE_CODE = 'S'
	and b.HAND_REPAIR_PROJECT_CODE = '000000'
	and a.is_deleted = 0
--	and RO_CREATE_DATE<now() -- 附件上传时间和装潢工单均截止前一天
	and RO_CREATE_DATE>=tsoe.first_deposit_date   -- 大于等于定金支付时间，
	and RO_CREATE_DATE< ifnull(tsov.CONFIRMED_DATE+ interval '3' month,now()) -- 小于交车时间+3个月，精确到自然日
--	and 
	group by 1
	)zh on zh.vin=tsov.sales_vin 
LEFT JOIN (
	    select 
	        DISTINCT
	        tm.COMPANY_CODE,
	        tg2.ORG_NAME 大区,
	        tg1.ORG_NAME 小区,
	        company_short_name_cn 
	    from organization.tm_company tm
	    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
	    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
	    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	    ORDER BY tm.COMPANY_CODE ASC) h on h.COMPANY_CODE = tso.OWNER_CODE
LEFT JOIN (
	    select 
	        DISTINCT
	        tm.COMPANY_CODE,
	        tg2.ORG_NAME 大区,
	        tg1.ORG_NAME 小区,
	        company_short_name_cn 
	    from organization.tm_company tm
	    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
	    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
	    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	    ORDER BY tm.COMPANY_CODE ASC) h2 on h2.COMPANY_CODE = tsov.DELIVERY_OWNER_CODE
left join cyxdms_retail.tt_sales_order_detail tsod on tsod.so_no_id=tso.so_no_id and tsod.IS_DELETED =0
left join basic_data.tm_model f on f.id = tsod.SECOND_ID 
left join basic_data.tm_config tc on tc.id = tsod.four_id 
WHERE tso.SO_STATUS IN (14041001,14041002,14041030,14041008,14041003) -- 未提交、提交待审批、待资质审核、已交车、审批通过
and tsoe.first_deposit_date>='2025-03-01'
and tsoe.first_deposit_date<curdate()
and tso.is_deleted<>'1'  -- 不包含逻辑删除
--and tso.SO_NO in ('VVD2025031200016','HZJR2025031300001')
order by 1 


-- 漏斗
select x.车型,
count(distinct x.订单编号) 订单数量,
count(case when x.是否含附件='是' then 1 else null end) 上传附件数量,
count(case when x.是否有装潢工单='是' then 1 else null end) 装潢工单数量
from 
(
SELECT 
distinct 
tsoe.first_deposit_date AS "定金支付时间", 
tsov.CONFIRMED_DATE AS "交车时间", 
tso.SO_NO AS "订单编号", 
CASE WHEN tso.strong_weak_agent = 87811001 THEN '强代理' 
WHEN tso.strong_weak_agent = 87811002 THEN '弱代理' 
WHEN tso.strong_weak_agent = 87811004 THEN '新零售' ELSE '批零制' END AS "销售模式",
tsov.sales_vin AS "VIN", 
tso.OWNER_CODE AS "所属经销商", 
h.company_short_name_cn 经销商简称,
h.大区,
h.小区,
tsov.DELIVERY_OWNER_CODE AS "订车门店",
h2.company_short_name_cn 订车门店简称,
h2.大区 订车门店大区,
h2.小区 订车门店小区,
f.model_name 车型,
tc.config_name 配置,
case when tsov.CONFIRMED_DATE is not null then '是'  ELSE '否' end 是否交车,
CASE WHEN tfui.FILE_UPLOAD_INFO_ID IS NULL THEN '否' ELSE '是' end 是否含附件,
--tfui.created_at  最新附件上传时间,
CASE WHEN DATE(tfui.created_at) = CURDATE()- interval '1' day THEN '是' ELSE '否' END AS "是否当天附件",
case when zh.vin is not null then '是'  ELSE '否' end 是否有装潢工单,
zh.装潢工单经销商,
zh.装潢工单工单号
FROM `cyxdms_retail`.`tt_sales_orders` tso
INNER JOIN `cyxdms_retail`.`tt_sales_order_vin` tsov ON tsov.VI_NO = tso.SO_NO and tsov.is_deleted<>'1'
INNER JOIN cyxdms_retail.tt_sales_orders_ext tsoe ON tsoe.SO_NO_ID = tso.SO_NO_ID and tsoe.is_deleted<>'1'
LEFT JOIN 
	(
	-- 取最新附件时间
	select x.*
	from 
		(
		select tfui.BILL_ID,
		tfui.FILE_UPLOAD_INFO_ID,
		row_number()over(partition by tfui.BILL_ID order by tfui.created_at desc) rk,
		tfui.created_at
		from cyxdms_retail.tc_file_upload_info tfui 
		where 1=1 
--		and tfui.created_at<curdate() -- 附件上传时间和装潢工单均截止前一天
		and tfui.is_deleted <>'1'
		)x where x.rk=1 
	)tfui ON tfui.BILL_ID = tso.SO_NO_ID
left join 
	(
	-- 装潢工单
	select 
	a.vin,
	RO_CREATE_DATE,
	string_agg(a.owner_code, ', ') 装潢工单经销商,
	string_agg(a.ro_no, ', ') 装潢工单工单号
	from cyx_repair.tt_repair_order a
	left join cyx_repair.tt_ro_hand_repair_project b on a.OWNER_CODE = b.owner_code and a.RO_NO = b.ro_no
	left JOIN `cyxdms_retail`.`tt_sales_order_vin` tsov on a.vin=tsov.sales_vin
	left join `cyxdms_retail`.`tt_sales_orders` tso ON tsov.VI_NO = tso.SO_NO and tsov.is_deleted<>'1'
	left JOIN cyxdms_retail.tt_sales_orders_ext tsoe ON tsoe.SO_NO_ID = tso.SO_NO_ID and tsoe.is_deleted<>'1'
	where a.REPAIR_TYPE_CODE = 'S'
	and b.HAND_REPAIR_PROJECT_CODE = '000000'
	and a.is_deleted = 0
--	and RO_CREATE_DATE<curdate() -- 附件上传时间和装潢工单均截止前一天
	and RO_CREATE_DATE>=tsoe.first_deposit_date   -- 大于等于定金支付时间，
	and RO_CREATE_DATE< ifnull(tsov.CONFIRMED_DATE+ interval '3' month,now()) -- 小于交车时间+3个月，精确到自然日
	group by 1
	)zh on zh.vin=tsov.sales_vin 
LEFT JOIN (
	    select 
	        DISTINCT
	        tm.COMPANY_CODE,
	        tg2.ORG_NAME 大区,
	        tg1.ORG_NAME 小区,
	        company_short_name_cn 
	    from organization.tm_company tm
	    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
	    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
	    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	    ORDER BY tm.COMPANY_CODE ASC) h on h.COMPANY_CODE = tso.OWNER_CODE
LEFT JOIN (
	    select 
	        DISTINCT
	        tm.COMPANY_CODE,
	        tg2.ORG_NAME 大区,
	        tg1.ORG_NAME 小区,
	        company_short_name_cn 
	    from organization.tm_company tm
	    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
	    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
	    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	    ORDER BY tm.COMPANY_CODE ASC) h2 on h2.COMPANY_CODE = tsov.DELIVERY_OWNER_CODE
left join cyxdms_retail.tt_sales_order_detail tsod on tsod.so_no_id=tso.so_no_id and tsod.IS_DELETED =0
left join basic_data.tm_model f on f.id = tsod.SECOND_ID 
left join basic_data.tm_config tc on tc.id = tsod.four_id 
WHERE tso.SO_STATUS IN (14041001,14041002,14041030,14041008,14041003) -- 未提交、提交待审批、待资质审核、已交车、审批通过
and tsoe.first_deposit_date>='2025-03-01' --MTD支付定金   定金支付7天后 已交车
and tsoe.first_deposit_date<curdate() -- MTD支付定金   已交车
--and date(tsoe.first_deposit_date)=curdate()- interval '1' day  -- 昨天
--and tsoe.first_deposit_date<curdate()- interval '6' day  --定金支付7天后
and tsov.CONFIRMED_DATE is not null   -- 已交车
and month(tsoe.first_deposit_date)=month(tsov.CONFIRMED_DATE)  -- 已交车
and year(tsoe.first_deposit_date)=year(tsov.CONFIRMED_DATE) --已交车
and tso.is_deleted<>'1'  -- 不包含逻辑删除
)x 
group by 1 
order by 1 





SELECT CASE WHEN tso.strong_weak_agent = 87811001 THEN '强代理' WHEN tso.strong_weak_agent = 87811002 THEN '弱代理' WHEN tso.strong_weak_agent = 87811004 THEN '新零售' ELSE '批零制' END AS "销售模式"
,tso.SO_NO AS "订单编号"
,tsov.sales_vin AS "VIN"
,tsod.FOUR_ID
,bd_tc.config_name
,tso.OWNER_CODE AS "所属经销商"
,view_org.company_short_name_cn
,view_org.salebigareaname AS "大区"
,view_org.salesmallareaname AS "小区"
,tsov.DELIVERY_OWNER_CODE AS "订车门店"
,view_org2.company_short_name_cn
,view_org2.salebigareaname AS "订车门店大区"
,view_org2.salesmallareaname AS "订车门店小区"
,tso.CUSTOMER_NAME AS "客户名称"
,tso.CUSTOMER_TEL as "联系电话"
,(CASE WHEN tsoe2.lock_invoice = 1 THEN '已开票' WHEN tisa.invoice_status = '0' THEN '已开票' ELSE '未开票' END) AS "开票状态"
,tisa.invoice_date AS "开票日期"
,tso.SO_STATUS AS "订单状态", tsoe.first_deposit_date AS "首次定金支付时间"
,tsov.CONFIRMED_DATE AS "交车时间"
,tso.CREATED_AT
,(CASE WHEN tfui.FILE_UPLOAD_INFO_ID IS NULL THEN '否' ELSE '是' END) AS "是否含附件"
,(CASE WHEN DATE(tfui.created_at) = CURDATE() THEN '是' ELSE '否' END) AS "当天附件"
FROM `cyxdms_retail`.`tt_sales_orders` tso
INNER JOIN `cyxdms_retail`.`tt_sales_order_vin` tsov ON tsov.VI_NO = tso.SO_NO
INNER JOIN `cyxdms_retail`.`tt_sales_order_detail` tsod ON tsod.SO_NO_ID = tso.SO_NO_ID
INNER JOIN cyxdms_retail.tt_sales_orders_ext tsoe ON tsoe.SO_NO_ID = tso.SO_NO_ID
LEFT JOIN cyxdms_retail.tt_sales_orders_ext2 tsoe2 ON tsoe2.SO_NO_ID = tso.SO_NO_ID
LEFT JOIN vehicle.tt_invoice_statistics_all tisa on tisa.vin = tsov.sales_vin and tisa.is_deleted = 0 and tisa.invoice_type = 1 and tisa.invoice_status = '0'
LEFT JOIN cyxdms_retail.tc_file_upload_info tfui ON tfui.BILL_ID = tso.SO_NO_ID
LEFT JOIN basic_data.tm_config bd_tc ON bd_tc.ID = tsod.FOUR_ID
LEFT JOIN sales_report.view_organization_info view_org on view_org.COMPANY_CODE = tso.OWNER_CODE
LEFT JOIN sales_report.view_organization_info view_org2 on view_org2.COMPANY_CODE = tsov.DELIVERY_OWNER_CODE AND view_org2.COMPANY_CODE != ''
WHERE tso.SO_STATUS IN (14041001, 14041002, 14041003, 14041008, 14041030)
