select left(m.CREATE_TIME,7) 小程序注册时间
,m.ID 
,m.IS_VEHICLE 
-- ,x.交车时间
,a.DRAWER_TEL
,DATE_FORMAT(a.CREATED_AT,'%Y-%m')交车时间
from `member`.tc_member_info m
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
-- left join (select a.vin,left(a.invoice_date,7) 交车时间
-- 	from vehicle.tt_invoice_statistics_dms a
-- 	where a.IS_DELETED =0
-- 	order by 2
-- ) x on x.vin=t.vin
left join (select a.*
from 
	(
	select a.DRAWER_TEL,ROW_NUMBER () over(PARTITION by a.DRAWER_TEL order by a.CREATED_AT desc )rk,a.CREATED_AT
	from cyxdms_retail.tt_sales_orders a
	where a.IS_DELETED=0)a where rk =1
) a on a.DRAWER_TEL=m.MEMBER_PHONE 
where m.IS_DELETED =0
and m.member_status <> '60341003'
order by 1

select 
from vehicle.tt_invoice_statistics_dms a
left join (

select b.SALES_VIN 
from cyxdms_retail.tt_sales_order_vin b


-- 社区发帖人数 以nb为准 0308
SELECT 
DATE_FORMAT(a.create_time,'%Y-%m') tt
,count(DISTINCT a.member_id)
from community.tm_post a
where 1=1
and a.is_deleted =0
and a.create_time >='2022-02-01'
and a.create_time <'2023-03-01'
group by 1
order by 1

-- 上线至今每个月社区发帖（发文章）人数，需要看下其中，俱乐部成员有多少；
select x.tt
,x.是否俱乐部成员
,count(1)
from 
(
SELECT DISTINCT a.member_id,if(b.member_id is null,'否','是') 是否俱乐部成员,DATE_FORMAT(a.create_time,'%Y-%m') tt
from community.tm_post a
left join 
	(select b.member_id
	from car_friends.car_friends_user b 
	where b.is_deleted =0 )b on a.member_id =b.member_id 
where 1=1
and a.is_deleted =0
and a.create_time >='2022-02-01'
and a.create_time <'2023-03-01'
)x 
where 1=1
and x.是否俱乐部成员='是'
group by 1,2
order by 1,2

-- 保客活动传播篇数 以NB为准 2月
select 
count(distinct a.member_id) 人数,
COUNT(a.id) 篇数
from community.tm_post a
where 
a.create_time >='2023-01-01' and a.create_time <'2023-02-01'
-- a.create_time BETWEEN'2023-02-01' and '2022-11-30 23:59:59'
and a.member_id <>0
and a.is_deleted =0


-- 保客活动月均社区传播PV
select count(b.member_id)
from community.tt_view_post b
left join community.tm_post a on a.post_id =b.post_id 
where 
a.create_time >='2023-01-01' and a.create_time <'2023-02-01'
-- a.create_time BETWEEN'2023-02-01' and '2022-11-30 23:59:59'
and a.member_id <>0
and a.is_deleted =0
and  (a.post_digest like '%#ENJOY VOLVO LIFE#%'
OR a.post_digest like '%#enjoy volvo life#%'
OR a.post_digest like '%#Enjoy volvo life#%'
OR a.post_digest like '%#一张封神#%'
OR a.post_digest like '%#一张封神沃时光影#%'
OR a.post_digest like '%#俱在一起WOW#%'
OR a.post_digest like '%#俱在一起wow#%'
OR a.post_digest like '%#WOW的美好新春#%'
OR a.post_digest like '%#wow的美好新春#%'
OR a.post_digest like '%别赶路 去感受路#%')
and b.member_id <>0

select tmi.MEMBER_PHONE ,tmi.ID 
from `member`.tc_member_info tmi 
where tmi.IS_DELETED =0