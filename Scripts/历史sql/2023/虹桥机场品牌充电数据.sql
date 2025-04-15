wxgNy2Hg3o

0B074ECD66CF4FCD88995A2DD9B122EF
4657841009B3431BACEE7503FD3A7F36
CEA6D8CB84494E7CA23827A6C54F9FB6
7BA6D0B4E0AC4478ABEEE20E472AD50D
794BE38D2E06492B800B4289F4596B44
2C8B18CC193847358792D0ED8EF6D16B
推文
朋友圈传播海报
首页banner
首页-活动
弹窗
沃的活动banner

-- UV
select 
case when json_extract(t.data,'$.tcode')='4657841009B3431BACEE7503FD3A7F36' then '5活动'
	when json_extract(t.data,'$.tcode')='CEA6D8CB84494E7CA23827A6C54F9FB6' then '1活动'
	when json_extract(t.data,'$.tcode')='7BA6D0B4E0AC4478ABEEE20E472AD50D' then '2活动'
	when json_extract(t.data,'$.tcode')='794BE38D2E06492B800B4289F4596B44' then '4活动'
	when json_extract(t.data,'$.tcode')='2C8B18CC193847358792D0ED8EF6D16B' then '3活动'
	else null end 分类,
COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='浙江省' then  t.usertag else null end) 浙江,
COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='江苏省' then  t.usertag else null end) 江苏,
COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='上海市' then  t.usertag else null end) 上海,
COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and (tr.REGION_NAME not in ('浙江省','江苏省','上海市')or tr.REGION_NAME is null) then t.usertag else null end) 其他,
COUNT(DISTINCT case when (x.车型 not in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')or x.车型 is null) and tmi.IS_VEHICLE =1 then t.usertag else null end) 其他车主,
COUNT(DISTINCT case when tmi.IS_VEHICLE =0 then t.usertag else null end) 粉丝
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join 
	(
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
	)x on x.member_id=tmi.id
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE =tr.REGION_CODE 
where t.`date` >='2022-08-19' and t.`date` <= '2022-08-25 23:59:59'
group by 1
order by 1

-- PV
select 
case when json_extract(t.data,'$.tcode')='4657841009B3431BACEE7503FD3A7F36' then '5活动'
	else null end 分类,
COUNT( case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='浙江省' then  t.usertag else null end) 浙江,
COUNT( case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='江苏省' then  t.usertag else null end) 江苏,
COUNT( case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='上海市' then  t.usertag else null end) 上海,
COUNT( case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and (tr.REGION_NAME not in ('浙江省','江苏省','上海市')or tr.REGION_NAME is null) then t.usertag else null end) 其他,
COUNT( case when (x.车型 not in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')or x.车型 is null) and tmi.IS_VEHICLE =1 then t.usertag else null end) 其他车主,
COUNT( case when tmi.IS_VEHICLE =0 then t.usertag else null end) 粉丝
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
left join 
	(
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
	)x on x.member_id=tmi.id
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE =tr.REGION_CODE 
where t.`date` >= '2022-08-19' and t.`date` <= '2022-08-25 23:59:59'
group by 1
order by 1

-- 文章明细	改  
select o.ref_id
				,sum(case when o.type='VIEW' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='浙江省' then 1 else 0 end) 浙江PV
				,sum(case when o.type='VIEW' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='江苏省'then 1 else 0 end) 江苏PV
				,sum(case when o.type='VIEW' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='上海市'then 1 else 0 end) 上海PV
				,sum(case when o.type='VIEW' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and (tr.REGION_NAME not in ('浙江省','江苏省','上海市')or tr.REGION_NAME is null) then 1 else 0 end) 其他PV
				,sum(case when o.type='VIEW' and (x.车型 not in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')or x.车型 is null) and tmi.IS_VEHICLE =1 then 1 else 0 end) 其他车主PV
				,sum(case when o.type='VIEW' and tmi.IS_VEHICLE =0 then 1 else 0 end) 粉丝PV
				-- 
				,count(distinct case when o.type='VIEW' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='浙江省' then o.user_id else null end) 浙江UV
				,count(distinct case when o.type='VIEW' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='江苏省'then o.user_id else null end) 江苏UV
				,count(distinct case when o.type='VIEW' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='上海市'then o.user_id else null end) 上海UV
				,count(distinct case when o.type='VIEW' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and (tr.REGION_NAME not in ('浙江省','江苏省','上海市')or tr.REGION_NAME is null) then o.user_id else null end) 其他UV
				,count(distinct case when o.type='VIEW' and (x.车型 not in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')or x.车型 is null) and tmi.IS_VEHICLE =1 then o.user_id else null end) 其他车主UV
				,count(distinct case when o.type='VIEW' and tmi.IS_VEHICLE =0 then o.user_id else null end) 粉丝UV	
	from 'cms-center'.cms_operate_log o
	left join `member`.tc_member_info tmi on tmi.user_id =o.user_id and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	left join 
	(
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
	)x on x.member_id=tmi.id
	left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE =tr.REGION_CODE 
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	-- and date_create BETWEEN '2022-03-24' and '2021-12-23 23:59:59' 
	and date_create <='2022-08-25 23:59:59' and date_create >='2022-08-19'
	and o.ref_id='wxgNy2Hg3o'  

-- 文章明细	改  
select '1点赞'
				,sum(case when o.type='SUPPORT' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='浙江省' then 1 else 0 end) 浙江点赞量
				,sum(case when o.type='SUPPORT' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='江苏省'then 1 else 0 end) 江苏点赞量
				,sum(case when o.type='SUPPORT' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='上海市'then 1 else 0 end) 上海点赞量
				,sum(case when o.type='SUPPORT' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and (tr.REGION_NAME not in ('浙江省','江苏省','上海市')or tr.REGION_NAME is null) then 1 else 0 end) 其他点赞量
				,sum(case when o.type='SUPPORT' and (x.车型 not in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')or x.车型 is null) and tmi.IS_VEHICLE =1 then 1 else 0 end) 其他车主点赞量
				,sum(case when o.type='SUPPORT' and tmi.IS_VEHICLE =0 then 1 else 0 end) 粉丝点赞量
	from 'cms-center'.cms_operate_log o
	left join `member`.tc_member_info tmi on tmi.user_id =o.user_id and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	left join 
	(
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
	)x on x.member_id=tmi.id
	left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE =tr.REGION_CODE 
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	and o.date_create <='2022-08-25 23:59:59' and o.date_create >='2022-08-19'
	-- and o.deleted=0
	and o.ref_id='wxgNy2Hg3o' 
union all 
-- 评论条数
select
'2评论',
COUNT(case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='浙江省' then  teh.content else null end) 浙江,
COUNT(case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='江苏省' then  teh.content else null end) 江苏,
COUNT(case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='上海市' then  teh.content else null end) 上海,
COUNT(case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and (tr.REGION_NAME not in ('浙江省','江苏省','上海市')or tr.REGION_NAME is null)then teh.content else null end) 其他,
COUNT(case when (x.车型 not in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')or x.车型 is null) and tmi.IS_VEHICLE =1 then teh.content else null end) 其他车主,
COUNT(case when IFNULL(tmi.IS_VEHICLE,0) =0 then teh.content else null end) 粉丝
from comment.tt_evaluation_history teh 
left join member.tc_member_info tmi on teh.user_id =tmi.ID
left join 
	(
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
	)x on x.member_id=tmi.id
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE =tr.REGION_CODE 
where teh.object_id = 'wxgNy2Hg3o'
and teh.create_time >= '2022-08-19' and teh.create_time <='2022-08-25 23:59:59'
and teh.is_deleted = 0
union all 
select '3收藏'
				,sum(case when o.type='COLLECTION' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='浙江省' then 1 else 0 end) 浙江收藏量
				,sum(case when o.type='COLLECTION' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='江苏省'then 1 else 0 end) 江苏收藏量
				,sum(case when o.type='COLLECTION' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='上海市'then 1 else 0 end) 上海收藏量
				,sum(case when o.type='COLLECTION' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and (tr.REGION_NAME not in ('浙江省','江苏省','上海市')or tr.REGION_NAME is null) then 1 else 0 end) 其他收藏量
				,sum(case when o.type='COLLECTION' and (x.车型 not in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')or x.车型 is null) and tmi.IS_VEHICLE =1 then 1 else 0 end) 其他车主收藏量
				,sum(case when o.type='COLLECTION' and tmi.IS_VEHICLE =0 then 1 else 0 end) 粉丝转发量
	from 'cms-center'.cms_operate_log o
	left join `member`.tc_member_info tmi on tmi.user_id =o.user_id and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	left join 
	(
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
	)x on x.member_id=tmi.id
	left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE =tr.REGION_CODE 
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	and o.date_create <='2022-08-25 23:59:59' and o.date_create >='2022-08-19'
	-- and o.deleted=0
	and o.ref_id='wxgNy2Hg3o' 
union all 
select '4转发'
				,sum(case when o.type='SHARE' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='浙江省' then 1 else 0 end) 浙江转发量
				,sum(case when o.type='SHARE' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='江苏省'then 1 else 0 end) 江苏转发量
				,sum(case when o.type='SHARE' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='上海市'then 1 else 0 end) 上海转发量
				,sum(case when o.type='SHARE' and x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and (tr.REGION_NAME not in ('浙江省','江苏省','上海市')or tr.REGION_NAME is null) then 1 else 0 end) 其他转发量
				,sum(case when o.type='SHARE' and (x.车型 not in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')or x.车型 is null) and tmi.IS_VEHICLE =1 then 1 else 0 end) 其他车主转发量
				,sum(case when o.type='SHARE' and tmi.IS_VEHICLE =0 then 1 else 0 end) 粉丝转发量
	from 'cms-center'.cms_operate_log o
	left join `member`.tc_member_info tmi on tmi.user_id =o.user_id and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	left join 
	(
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
	)x on x.member_id=tmi.id
	left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE =tr.REGION_CODE 
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	and o.date_create <='2022-08-25 23:59:59' and o.date_create >='2022-08-19'
	-- and o.deleted=0
	and o.ref_id='wxgNy2Hg3o' 
union all 
-- 拉新
select 
-- COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='浙江省' then tmi.id else null end) 浙江,
-- COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='江苏省' then tmi.id else null end) 江苏,
-- COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='上海市' then tmi.id else null end) 上海,
-- COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and (tr.REGION_NAME not in ('浙江省','江苏省','上海市')or tr.REGION_NAME is null) then tmi.id else null end) 其他,
-- COUNT(DISTINCT case when (x.车型 not in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')or x.车型 is null) and (tr.REGION_NAME not in ('浙江省','江苏省','上海市')or tr.REGION_NAME is null) and tmi.IS_VEHICLE =1 then tmi.id else null end) 其他车主,
'5拉新',
0,
0,
0,
0,
0,
COUNT(DISTINCT case when IFNULL(tmi.IS_VEHICLE,0)=0 then tmi.id else null end) 粉丝
from 'cms-center'.cms_operate_log l
left join member.tc_member_info tmi on l.user_id=tmi.user_id and tmi.is_vehicle=0
left join 
	(
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
	)x on x.member_id=tmi.id
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE =tr.REGION_CODE 
where l.date_create <='2022-08-25 23:59:59' and l.date_create >='2022-08-19' 
and l.ref_id='wxgNy2Hg3o' and l.type ='VIEW' 
and tmi.create_time<date_add(l.date_create,INTERVAL 10 minute) and tmi.create_time>=DATE_sub(l.date_create,INTERVAL 10 MINUTE)
union all
-- 激活
select
'6激活',
COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='浙江省' then  t.usertag else null end) 浙江,
COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='江苏省' then  t.usertag else null end) 江苏,
COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and tr.REGION_NAME='上海市' then  t.usertag else null end) 上海,
COUNT(DISTINCT case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40') and (tr.REGION_NAME not in ('浙江省','江苏省','上海市')or tr.REGION_NAME is null) then t.usertag else null end) 其他,
COUNT(DISTINCT case when (x.车型 not in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')or x.车型 is null)and tmi.IS_VEHICLE =1 then t.usertag else null end) 其他车主,
COUNT(DISTINCT case when IFNULL(tmi.IS_VEHICLE,0) =0 then t.usertag else null end) 粉丝
from(
		-- 获取访问文章活动10分钟之前的最晚访问时间
		select t.usertag,b.ldate,b.is_vehicle,max(t.date) tdate
		from track.track t
		join (
			-- 获取访问文章活动的最早时间
			select m.is_vehicle,cast(l.user_id as varchar) user_id,min(date_create) ldate 
			from 'cms-center'.cms_operate_log l
			join member.tc_member_info m on l.user_id=m.user_id
			-- where l.date_create BETWEEN '2022-02-21' and '2022-03-20 23:59:59'  
			where l.date_create <='2022-08-25 23:59:59' and l.date_create >='2022-08-19'
			and l.ref_id='wxgNy2Hg3o' 
			and l.type ='VIEW' 
			GROUP BY 1,2
		) b on b.user_id=t.usertag
		where t.date< DATE_SUB(b.ldate,INTERVAL 10  MINUTE)
		GROUP BY 1,2,3
) t
left join member.tc_member_info tmi on t.usertag =cast(tmi.user_id as varchar)
left join 
	(
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
	)x on x.member_id=tmi.id
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE =tr.REGION_CODE 
where t.tdate < DATE_SUB(t.ldate,INTERVAL 30 DAY) 
order by 1




-- app效果，取custid用户与下载app用户取交集  T8/XC40BEV/C40BEV
select 
tmi.CUST_ID,
tmi.IS_VEHICLE,
case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')then '新能源'
  	when tmi.IS_VEHICLE =0 then '无车'
  	else '其他车型' end 车型,
case when tr.REGION_NAME = '浙江省' then '浙江'
 when tr.REGION_NAME = '江苏省' then '江苏'
 when tr.REGION_NAME = '上海市' then '上海'
 else '其他' end 省市
from member.tc_member_info tmi
join 
	(
	select l.user_id
	from 'cms-center'.cms_operate_log l
	where l.ref_id='wxgNy2Hg3o' and l.type ='VIEW' 
	and l.date_create <='2022-08-25 23:59:59' and l.date_create >='2022-08-19' 
    group by 1
	)on tmi.USER_ID =l.user_id
left join 
 (
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
 )x on x.member_id=tmi.id
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE =tr.REGION_CODE 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003


-- 参加活动的用户 与人群包取交集 短信效果
select 
a.user_id,
x.vin,
tmi.CUST_ID,
tmi.IS_VEHICLE,
case when x.车型 in ('XC60 RECHARGE','XC90 RECHARGE','S60 RECHARGE','S90 RECHARGE','XC40 RECHARGE','全新纯电C40')then '新能源'
  	when tmi.IS_VEHICLE =0 then '无车'
  	else '其他车型' end 车型,
case when tr.REGION_NAME = '浙江省' then '浙江'
 when tr.REGION_NAME = '江苏省' then '江苏'
 when tr.REGION_NAME = '上海市' then '上海'
 else '其他' end 省市
from `cms-center`.cms_operate_log a
left join `member`.tc_member_info tmi on tmi.USER_ID =a.user_id and tmi.is_deleted = 0 and tmi.member_status <> '60341003'
left join 
	(
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
	)x on x.member_id=tmi.id
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE =tr.REGION_CODE 
where a.ref_id='wxgNy2Hg3o' 
and a.date_create <='2022-08-25 23:59:59' and a.date_create >='2022-08-19' 
group by 1


select * from basic_data.tm_model tm
join basic_data.tm_config tc on tm.ID = tc.MODEL_ID and tc.CONFIG_NAME like '%RECHARGE T8%'
where tm.IS_DELETED = 0
and tm.MODEL_NAME like '%60%' or tm.MODEL_NAME like '%90%'
