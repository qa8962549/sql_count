--1、每个板块（title需要区分板块），看一下打分4，5分（item_value)的人，占总答题人数（去掉回答未使用app的人）占比

--2、开放题：1、把明细拉出来 2、做一个词频 、频次 保留top20。

-- 频率
select x.module,
x.item_value,
x.去重计数,
x.去重计数/x2.去重计数 占比
from 
	(
	SELECT  
	    CASE 
	        WHEN title LIKE '%1)%' THEN '应用本身的性能'
	        WHEN title LIKE '%2)%' THEN '购车服务'
	        WHEN title LIKE '%车辆控制%' THEN '车辆控制'
	        WHEN title LIKE '%车辆远程控制%' THEN '车辆远程控制'
	        WHEN title LIKE '%4)%' THEN '售后服务'
	        WHEN title LIKE '%5)%' THEN '充电服务'
	        WHEN title LIKE '%6)%' THEN '社区'
	        WHEN title LIKE '%7)%' THEN '商城'
	        WHEN title LIKE '%8)%' THEN '会员'
	        WHEN title LIKE '%推荐沃尔沃汽车App%' THEN '推荐沃尔沃汽车app可能性'
	        ELSE NULL
	    END AS module,
	    m.item_value,
	    count(distinct person_id) 去重计数
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	left join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	left join questionnaire.tc_answer_detail m on l.ID = m.PERSON_ID  -- 答题明细表
	where 1=1
	and k.VID='303113905'
	and m.create_time>='2025-03-01'
	and m.create_time<'2025-04-01'
--	and m.q_index='10' -- 满意度题目筛选
	and k.is_deleted=0
	and m.is_deleted=0
	and m.item_value>=0 -- 去掉未使用app的用户
	group by rollup(1,2)
	order by 1,2
	)x 
left join  (SELECT  
	    CASE 
	        WHEN title LIKE '%1)%' THEN '应用本身的性能'
	        WHEN title LIKE '%2)%' THEN '购车服务'
	        WHEN title LIKE '%车辆控制%' THEN '车辆控制'
	        WHEN title LIKE '%车辆远程控制%' THEN '车辆远程控制'
	        WHEN title LIKE '%4)%' THEN '售后服务'
	        WHEN title LIKE '%5)%' THEN '充电服务'
	        WHEN title LIKE '%6)%' THEN '社区'
	        WHEN title LIKE '%7)%' THEN '商城'
	        WHEN title LIKE '%8)%' THEN '会员'
	        ELSE NULL
	    END AS module,
	    count(distinct person_id) 去重计数
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	left join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	left join questionnaire.tc_answer_detail m on l.ID = m.PERSON_ID  -- 答题明细表
	where 1=1
	and k.VID='303113905'
	--and k.VID='277069124'--277069124潜客
	and m.create_time>='2025-03-01'
	and m.create_time<'2025-04-01'
	and m.q_index='10' -- 满意度题目筛选
	and k.is_deleted=0
	and m.is_deleted=0
	and m.item_value>=0-- 去掉未使用app的用户
	group by 1
	order by 1
)x2 on x.module=x2.module
where x.module is not null 
order by 1,2

--test 
	SELECT  distinct 
	k.VID,
	m.title,
	m.is_deleted,
	m.q_index ,
	m.q_column ,
	m.q_row 
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	left join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	left join questionnaire.tc_answer_detail m on l.ID = m.PERSON_ID  -- 答题明细表
	where 1=1
	and k.VID='277069124' -- 277069124  303113905
	and m.create_time>='2025-03-01'
	and m.create_time<'2025-04-01'
--	and m.q_index='10' -- 满意度题目筛选
	and k.is_deleted=0
	and m.is_deleted=0
	and m.item_value>=0 -- 去掉未使用app的用户
--	and m.title LIKE '%车辆远程控制%'
	order by 1 
	
-- 开放式答题文本
SELECT 
m.title,
x.`车型`,
x.`年款`,
m.answer_text,
m.create_time 
from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
left join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
left join questionnaire.tc_answer_detail m on l.ID = m.PERSON_ID  -- 答题明细表
left join (--车款 年限
		 select
		 distinct 
		 r.member_id member_id,
		 m.cust_id cust_id,
		 tm.model_name `车型`,
		 ifnull(tv.CONFIG_YEAR,'未知') `年款`,
		 r.vin_code
		 from volvo_cms.vehicle_bind_relation r
		 left join "member".tc_member_info m on r.member_id =m.id and m.is_deleted = 0 and m.member_status<>'60341003'
		 left join vehicle.tt_invoice_statistics_dms d on r.vin_code = d.vin and d.is_deleted = 0
		 left join vehicle.tm_vehicle tv on r.vin_code = tv.VIN and tv.IS_DELETED = 0
		 left join basic_data.tm_model tm on ifnull(d.model_id,tv.MODEL_ID) = tm.id and tm.is_deleted = 0
		 left join basic_data.tm_config tc2 on ifnull(d.config_code,tv.CONFIG_CODE) =tc2.CONFIG_CODE and ifnull(d.config_id,tv.CONFIG_ID) =tc2.ID
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.is_owner=1  -- 车主
--		 and (--icup车辆
--			(tm.model_name = 'XC90' and tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'XC90 RECHARGE' and tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'S90L' and tv.CONFIG_YEAR >='2022')
--			or (tm.model_name = 'S90L RECHARGE' and tv.CONFIG_YEAR >='2022')
--			or (tm.model_name = 'V90CC' and tv.CONFIG_YEAR >='2022')
--			or (tm.model_name = 'XC60'  and tv.CONFIG_YEAR >='2022')
--			or (tm.model_name = 'XC60 RECHARGE' and tv.CONFIG_YEAR >='2022')
--			or (tm.model_name = 'S60' and tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'S60 RECHARGE' and  tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'V60'  and tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'XC40'  and tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'XC40 RECHARGE'  and tv.CONFIG_YEAR >='2021')
--			or (tm.model_name = 'C40'  and tv.CONFIG_YEAR >='2023')
--		)
--		 and tm.model_name in ('EM90','EX30')
		 and r.date_create<'2025-04-01'
		 )x on x.member_id=k.user_id
where 1=1
and k.VID='303113905' -- 车主问卷
--and k.VID='277069124' -- 潜客问卷
and m.Q_INDEX='12'-- 请对以上打分的原因进行简述:（开放题）
and m.create_time>='2025-01-01'
and m.create_time<'2025-04-01'
and answer_text <>'(空)'
order by 5 desc 


-----------------------潜客
-- 频率
select x.module,
x.item_value,
x.去重计数,
x.去重计数/x2.去重计数 占比
from 
	(
	SELECT  
	    CASE 
	        WHEN title LIKE '%1)%' THEN '应用本身的性能'
	        WHEN title LIKE '%2)%' THEN '购车服务'
	        WHEN title LIKE '%3)车辆远程控制%' THEN '车辆远程控制'
	        WHEN title LIKE '%4)%' THEN '售后服务'
	        WHEN title LIKE '%5)%' THEN '充电服务'
	        WHEN title LIKE '%6)%' THEN '社区'
	        WHEN title LIKE '%7)%' THEN '商城'
	        WHEN title LIKE '%8)%' THEN '会员'
	        WHEN title LIKE '%推荐沃尔沃汽车app%' THEN '推荐沃尔沃汽车app可能性'
	        ELSE NULL
	    END AS module,
	    m.item_value,
	    count(distinct person_id) 去重计数
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	left join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	left join questionnaire.tc_answer_detail m on l.ID = m.PERSON_ID  -- 答题明细表
	where 1=1
	and k.VID='303113905'
	--and k.VID='277069124'--277069124潜客
	and m.create_time>='2025-03-01'
	and m.create_time<'2025-04-01'
	and m.q_index='10' -- 满意度题目筛选
	and k.is_deleted=0
	and m.is_deleted=0
--	and m.item_value>=0 -- 去掉未使用app的用户
	group by rollup(1,2)
	order by 1,2
	)x 
left join  (SELECT  
	    CASE 
	        WHEN title LIKE '%1)%' THEN '应用本身的性能'
	        WHEN title LIKE '%2)%' THEN '购车服务'
	        WHEN title LIKE '%3)车辆远程控制%' THEN '充电服务'
	        WHEN title LIKE '%4)%' THEN '社区'
	        WHEN title LIKE '%5)%' THEN '商城'
	        WHEN title LIKE '%6)%' THEN '会员'
	        ELSE NULL
	    END AS module,
	    count(distinct person_id) 去重计数
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	left join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	left join questionnaire.tc_answer_detail m on l.ID = m.PERSON_ID  -- 答题明细表
	where 1=1
--	and k.VID='303113905'
	and k.VID='277069124'--277069124潜客
	and m.create_time>='2025-03-01'
	and m.create_time<'2025-04-01'
	and m.q_index='10' -- 满意度题目筛选
	and k.is_deleted=0
	and m.is_deleted=0
	and m.item_value>=0-- 去掉未使用app的用户
	group by 1
	order by 1
)x2 on x.module=x2.module
where x.module is not null 
order by 1,2

-------------------------'EM90','EX30'车主

-- 频率 'EM90','EX30'车主
select x.module,
x.item_value,
x.去重计数,
x.去重计数/x2.去重计数 占比
from 
	(
-- 问卷不同选项计数
	SELECT  
	    CASE 
	        WHEN title LIKE '%1)%' THEN '应用本身的性能'
	        WHEN title LIKE '%2)%' THEN '购车服务'
	        WHEN title LIKE '%3)车辆远程控制%' THEN '车辆远程控制'
	        WHEN title LIKE '%4)%' THEN '售后服务'
	        WHEN title LIKE '%5)%' THEN '充电服务'
	        WHEN title LIKE '%6)%' THEN '社区'
	        WHEN title LIKE '%7)%' THEN '商城'
	        WHEN title LIKE '%8)%' THEN '会员'
	        ELSE NULL
	    END AS module,
	    m.item_value,
	    count(distinct person_id) 去重计数
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	left join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	left join questionnaire.tc_answer_detail m on l.ID = m.PERSON_ID  -- 答题明细表
		join (--'EM90','EX30'车主
		 select
		 distinct 
		 r.member_id member_id,
		 m.cust_id cust_id,
		 tm.model_name `车型（BEV OR T8）`,
		 r.vin_code
		 from volvo_cms.vehicle_bind_relation r
		 left join "member".tc_member_info m on r.member_id =m.id and m.is_deleted = 0 and m.member_status<>'60341003'
		 left join vehicle.tt_invoice_statistics_dms d on r.vin_code = d.vin and d.is_deleted = 0
		 left join vehicle.tm_vehicle tv on r.vin_code = tv.VIN and tv.IS_DELETED = 0
		 left join basic_data.tm_model tm on ifnull(d.model_id,tv.MODEL_ID) = tm.id and tm.is_deleted = 0
		 left join basic_data.tm_config tc2 on ifnull(d.config_code,tv.CONFIG_CODE) =tc2.CONFIG_CODE and ifnull(d.config_id,tv.CONFIG_ID) =tc2.ID
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.is_owner=1  -- 车主
		 and tm.model_name in ('EM90','EX30')
		 and r.date_create<'2025-04-01'
		 )x on x.member_id=k.user_id
	where 1=1
	and k.VID='303113905'
	and m.create_time>='2025-03-01'
	and m.create_time<'2025-04-01'
	and m.q_index='10' -- 满意度题目筛选
	and k.is_deleted=0
	and m.is_deleted=0
	and m.item_value>=0 -- 去掉未使用app的用户
	group by rollup(1,2)
	order by 1,2
	)x 
left join  (
-- 问卷总计数量
	SELECT  
	    CASE 
	        WHEN title LIKE '%1)%' THEN '应用本身的性能'
	        WHEN title LIKE '%2)%' THEN '购车服务'
	        WHEN title LIKE '%3)车辆远程控制%' THEN '车辆远程控制'
	        WHEN title LIKE '%4)%' THEN '售后服务'
	        WHEN title LIKE '%5)%' THEN '充电服务'
	        WHEN title LIKE '%6)%' THEN '社区'
	        WHEN title LIKE '%7)%' THEN '商城'
	        WHEN title LIKE '%8)%' THEN '会员'
	        ELSE NULL
	    END AS module,
	    count(distinct person_id) 去重计数
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	left join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	left join questionnaire.tc_answer_detail m on l.ID = m.PERSON_ID  -- 答题明细表
		join (--'EM90','EX30'车主
		 select
		 distinct 
		 r.member_id member_id,
		 m.cust_id cust_id,
		 tm.model_name `车型（BEV OR T8）`,
		 r.vin_code
		 from volvo_cms.vehicle_bind_relation r
		 left join "member".tc_member_info m on r.member_id =m.id and m.is_deleted = 0 and m.member_status<>'60341003'
		 left join vehicle.tt_invoice_statistics_dms d on r.vin_code = d.vin and d.is_deleted = 0
		 left join vehicle.tm_vehicle tv on r.vin_code = tv.VIN and tv.IS_DELETED = 0
		 left join basic_data.tm_model tm on ifnull(d.model_id,tv.MODEL_ID) = tm.id and tm.is_deleted = 0
		 left join basic_data.tm_config tc2 on ifnull(d.config_code,tv.CONFIG_CODE) =tc2.CONFIG_CODE and ifnull(d.config_id,tv.CONFIG_ID) =tc2.ID
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.is_owner=1  -- 车主
		 and tm.model_name in ('EM90','EX30')
		 and r.date_create<'2025-04-01'
		 )x on x.member_id=k.user_id
	where 1=1
	and k.VID='303113905'
	--and k.VID='277069124'--277069124潜客
	and m.create_time>='2025-03-01'
	and m.create_time<'2025-04-01'
	and m.q_index='10' -- 满意度题目筛选
	and k.is_deleted=0
	and m.is_deleted=0
	and m.item_value>=0-- 去掉未使用app的用户
	group by 1
	order by 1
)x2 on x.module=x2.module
where x.module is not null 
order by 1,2

-----------------不同车型 不同年款

-- 频率icup 车主
select x.module,
--if(x.`车型`is null ,'车型总计',x.`车型`) `车型`,
--if(x.`年款` is null ,'年款总计',x.`年款`) `年款`,
if(x.item_value is null ,'打分总计',x.item_value) item_value,
--x.item_value,
--if(x.item_value,'总计'),
x.去重计数,
x.去重计数/x2.去重计数 占比
from 
	(
-- 问卷不同选项计数
	SELECT  
	    CASE 
	        WHEN title LIKE '%1)%' THEN '应用本身的性能'
	        WHEN title LIKE '%2)%' THEN '购车服务'
	        WHEN title LIKE '%3)车辆远程控制%' THEN '车辆远程控制'
	        WHEN title LIKE '%4)%' THEN '售后服务'
	        WHEN title LIKE '%5)%' THEN '充电服务'
	        WHEN title LIKE '%6)%' THEN '社区'
	        WHEN title LIKE '%7)%' THEN '商城'
	        WHEN title LIKE '%8)%' THEN '会员'
	        WHEN title LIKE '%推荐沃尔沃汽车app%' THEN '推荐沃尔沃汽车app可能性'
	        ELSE NULL
	    END AS module,
--	    x.`车型`,
--	    x.`年款`,
	    m.item_value::varchar item_value,
	    count(distinct person_id) 去重计数
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	left join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	left join questionnaire.tc_answer_detail m on l.ID = m.PERSON_ID  -- 答题明细表
		join (--车款 年限
		 select
		 distinct 
		 r.member_id member_id,
		 m.cust_id cust_id,
		 tm.model_name `车型`,
		 ifnull(tv.CONFIG_YEAR,'未知') `年款`,
		 r.vin_code
		 from volvo_cms.vehicle_bind_relation r
		 left join "member".tc_member_info m on r.member_id =m.id and m.is_deleted = 0 and m.member_status<>'60341003'
		 left join vehicle.tt_invoice_statistics_dms d on r.vin_code = d.vin and d.is_deleted = 0
		 left join vehicle.tm_vehicle tv on r.vin_code = tv.VIN and tv.IS_DELETED = 0
		 left join basic_data.tm_model tm on ifnull(d.model_id,tv.MODEL_ID) = tm.id and tm.is_deleted = 0
		 left join basic_data.tm_config tc2 on ifnull(d.config_code,tv.CONFIG_CODE) =tc2.CONFIG_CODE and ifnull(d.config_id,tv.CONFIG_ID) =tc2.ID
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.is_owner=1  -- 车主
		 and not (--icup车辆
			(tm.model_name = 'XC90' and tv.CONFIG_YEAR >='2023')
			or (tm.model_name = 'XC90 RECHARGE' and tv.CONFIG_YEAR >='2023')
			or (tm.model_name = 'S90L' and tv.CONFIG_YEAR >='2022')
			or (tm.model_name = 'S90L RECHARGE' and tv.CONFIG_YEAR >='2022')
			or (tm.model_name = 'V90CC' and tv.CONFIG_YEAR >='2022')
			or (tm.model_name = 'XC60'  and tv.CONFIG_YEAR >='2022')
			or (tm.model_name = 'XC60 RECHARGE' and tv.CONFIG_YEAR >='2022')
			or (tm.model_name = 'S60' and tv.CONFIG_YEAR >='2023')
			or (tm.model_name = 'S60 RECHARGE' and  tv.CONFIG_YEAR >='2023')
			or (tm.model_name = 'V60'  and tv.CONFIG_YEAR >='2023')
			or (tm.model_name = 'XC40'  and tv.CONFIG_YEAR >='2023')
			or (tm.model_name = 'XC40 RECHARGE'  and tv.CONFIG_YEAR >='2021')
			or (tm.model_name = 'C40'  and tv.CONFIG_YEAR >='2023')
			or tm.model_name in ('EM90','EX30')
		)
--		 and tm.model_name in ('EM90','EX30')
		 and r.date_create<'2025-04-01'
		 )x on x.member_id=k.user_id
	where 1=1
	and k.VID='303113905'
	and m.create_time>='2025-03-01'
	and m.create_time<'2025-04-01'
	and m.q_index='10' -- 满意度题目筛选
--	and q_row=3 -- 车辆远程控制
	and k.is_deleted=0
	and m.is_deleted=0
	and m.item_value>=0 -- 去掉未使用app的用户
	group by 
	rollup(1,2)
	order by 1,2
	)x 
left join  (
-- 问卷总计数量
	SELECT  
	    CASE 
	        WHEN title LIKE '%1)%' THEN '应用本身的性能'
	        WHEN title LIKE '%2)%' THEN '购车服务'
	        WHEN title LIKE '%3)车辆远程控制%' THEN '车辆远程控制'
	        WHEN title LIKE '%4)%' THEN '售后服务'
	        WHEN title LIKE '%5)%' THEN '充电服务'
	        WHEN title LIKE '%6)%' THEN '社区'
	        WHEN title LIKE '%7)%' THEN '商城'
	        WHEN title LIKE '%8)%' THEN '会员'
	        WHEN title LIKE '%推荐沃尔沃汽车app%' THEN '推荐沃尔沃汽车app可能性'
	        ELSE NULL
	    END AS module,
--	    x.`车型`,
--	    x.`年款`,
--	    m.item_value,
	    count(distinct person_id) 去重计数
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	left join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	left join questionnaire.tc_answer_detail m on l.ID = m.PERSON_ID  -- 答题明细表
		join (--车款 年限
		 select
		 distinct 
		 r.member_id member_id,
		 m.cust_id cust_id,
		 tm.model_name `车型`,
		 ifnull(tv.CONFIG_YEAR,'未知') `年款`,
		 r.vin_code
		 from volvo_cms.vehicle_bind_relation r
		 left join "member".tc_member_info m on r.member_id =m.id and m.is_deleted = 0 and m.member_status<>'60341003'
		 left join vehicle.tt_invoice_statistics_dms d on r.vin_code = d.vin and d.is_deleted = 0
		 left join vehicle.tm_vehicle tv on r.vin_code = tv.VIN and tv.IS_DELETED = 0
		 left join basic_data.tm_model tm on ifnull(d.model_id,tv.MODEL_ID) = tm.id and tm.is_deleted = 0
		 left join basic_data.tm_config tc2 on ifnull(d.config_code,tv.CONFIG_CODE) =tc2.CONFIG_CODE and ifnull(d.config_id,tv.CONFIG_ID) =tc2.ID
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.is_owner=1  -- 车主
--		and not (--icup车辆
--			(tm.model_name = 'XC90' and tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'XC90 RECHARGE' and tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'S90L' and tv.CONFIG_YEAR >='2022')
--			or (tm.model_name = 'S90L RECHARGE' and tv.CONFIG_YEAR >='2022')
--			or (tm.model_name = 'V90CC' and tv.CONFIG_YEAR >='2022')
--			or (tm.model_name = 'XC60'  and tv.CONFIG_YEAR >='2022')
--			or (tm.model_name = 'XC60 RECHARGE' and tv.CONFIG_YEAR >='2022')
--			or (tm.model_name = 'S60' and tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'S60 RECHARGE' and  tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'V60'  and tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'XC40'  and tv.CONFIG_YEAR >='2023')
--			or (tm.model_name = 'XC40 RECHARGE'  and tv.CONFIG_YEAR >='2021')
--			or (tm.model_name = 'C40'  and tv.CONFIG_YEAR >='2023')
--			or tm.model_name in ('EM90','EX30')
--		)
		 and tm.model_name in ('EM90','EX30')
		 and r.date_create<'2025-04-01'
		 )x on x.member_id=k.user_id
	where 1=1
	and k.VID='303113905'
	and m.create_time>='2025-03-01'
	and m.create_time<'2025-04-01'
	and m.q_index='10' -- 满意度题目筛选
--	and q_row=3 -- 车辆远程控制
	and k.is_deleted=0
	and m.is_deleted=0
	and m.item_value>=0-- 去掉未使用app的用户
	group by 1
	order by 1
)x2 on x.module=x2.module 
where x.module is not null 
order by 1,2




--------------------------------

--问卷中心近6个月内完成的问卷数量，以及问卷在一天中和一周中，用户完成并提交的时间分布
	SELECT  
	count(distinct k.id) 计数
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	where 1=1
	and l.submit_time >=curdate() - interval'6'month
	and l.submit_time<curdate()
	and k.is_deleted=0
--	and l.is_deleted=0
	
--问卷在一天中和一周中，用户完成并提交的时间分布	
	SELECT  
	case when hour(k.create_time)>=0 and hour(k.create_time)<=7	then'1 0-7'
		when hour(k.create_time)>=8 and hour(k.create_time)<=15	then'2 8-15'
		when hour(k.create_time)>=16 and hour(k.create_time)<=23then'3 16-23'
		else null end 一天时间分布,
		count(distinct k.id) 计数
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	where 1=1
	and l.submit_time >=curdate() - interval'6'month
	and l.submit_time<curdate()
	and k.is_deleted=0
	group by 1 
	order by 1 

--问卷在一天中和一周中，用户完成并提交的时间分布	
	SELECT  
	EXTRACT(DOW FROM create_time) + 1 周几, -- 周几函数
--	 TO_CHAR(create_time, 'Dy') AS weekday_name,
		count(distinct k.id) 计数
	from questionnaire.tc_questionnaire_record k -- 问卷生成记录表
	join questionnaire.tc_answer_person l on k.ENCRYPT_PARAMETER = l.SOURCE_DETAIL -- 答题人表
	where 1=1
	and l.submit_time >=curdate() - interval'6'month
	and l.submit_time<curdate()
	and k.is_deleted=0
	group by 1 
	order by 1 

	select count()
	from 
	questionnaire.tc_answer_detail m   -- 答题明细表
	where  create_time>=curdate() - interval'6'month
	and create_time<curdate()
