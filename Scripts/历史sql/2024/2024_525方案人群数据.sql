--1、KOC/KOL


-- 2、俱乐部会长
select
tmi.cust_id 
--b.create_time
from  community_club.tr_club_friends b --俱乐部成员信息表
left join "member".tc_member_info tmi on b.member_id =tmi.id 
where 1=1
and b.is_deleted = 0
and b.role_type=3 -- 会长

-- 3、白金卡及以上会员
select
count(distinct tmi.cust_id)
from ods_memb.ods_memb_tc_member_info_cur tmi 
join (-- APP注册用户
	select distinct m.distinct_id
	from ads_crm.ads_crm_events_member_d m
	where m.min_app_time is not null 
	and m.min_app_time>='2000-01-01')x on toString(x.distinct_id)=toString(tmi.cust_id)  
where tmi.member_status <> '60341003'
and tmi.is_deleted = 0
and tmi.level_id>=3 -- 白金及以上

select count(distinct x.cust_id)
from 
(
--1、23年至今商城下单达到3次
select 
toInt32(m.cust_id) cust_id
from ods_orde.ods_orde_tt_order_d a 
left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.user_id)=toString(m.id)  
where 1=1
	and toDate(a.create_time) >= '2023-01-01' 
	and toDate(a.create_time) <'2024-01-01'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = 10041002 -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
group by cust_id
having count(1)>=3
union all 
--2、过去3个月有登录过社区（广义社区）
select toInt32(distinct_id)
from 
	(
	select distinct_id,date
	from ods_rawd.ods_rawd_events_d_di 
	where event in ('Page_view','Page_entry') 
	and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') 
		or page_title like '%会员日%' 
		or (activity_name like '2023%' and activity_id is null)
		or (activity_name like '2024%' and activity_id is null)
		)
	and date >= '2024-01-18' 
	and date<'2024-03-18' 
	union all 
	-- 社区互动人数
	select distinct_id,date
	from ods_rawd.ods_rawd_events_d_di 
	where event='Button_click' 
	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
	and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
	and date >= '2024-01-18' 
	and date<'2024-03-18' 
	union all 
	-- 发现 按钮点击（车主）7月开始
	select distinct_id,date
	from ods_rawd.ods_rawd_events_d_di 
	where 1=1
	and event='$AppClick' 
	and `$element_content`='发现'
	and is_bind=1
	and date >= '2024-01-18' 
	and date<'2024-03-18' 
) t 
where length(distinct_id)<9 
union all
--3、APP上线至今被加精或上推荐达到3次
select toInt32(m.cust_id)
from ods_cmnt.ods_cmnt_tm_post_cur a
left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id=m.id
where 1=1
and a.is_deleted =0
and a.create_time >='2024-01-18'
and a.create_time <'2024-03-18'
and (a.recommend=1 -- 上推荐
	or a.selected_time <>0) --加精
group by cust_id
having count(1) >=3
	)x 
join (-- APP注册用户
	select distinct m.distinct_id
	from ads_crm.ads_crm_events_member_d m
	where m.min_app_time is not null 
	and m.min_app_time>='2000-01-01')x1 on toString(x1.distinct_id)=toString(x.cust_id)  

--1、23年至今商城下单不足3次
	select 
a.user_id 
from ods_orde.ods_orde_tt_order_d a 
where 1=1
	and toDate(a.create_time) >= '2023-01-01' 
	and toDate(a.create_time) <'2024-01-01'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = 10041002 -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
group by user_id
having num<3

--2、过去3个月未登录过社区（广义社区）


--1、曾经回过厂 ，注册了小程序但未注APP的车主
select 
count(distinct xx.id)
from ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd   -- 与发票表关联
join ods_cyre.ods_cyre_tt_repair_order_d e on tisd.vin=e.VIN  --工单表
left join	
	(select distinct a.cust_id as id,
	a.vin_code
	from (
--		 取最近一次绑车时间
		 select
		 r.member_id,
		 m.cust_id,
		 r.bind_date,
		 r.vin_code,
		 m.member_phone,
		 row_number() over(partition by r.vin_code order by r.bind_date desc) rk
		 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
		 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.member_id is not null 
		 and r.member_id <>''
		 and m.member_phone<>'*'
		 and m.member_phone is not null 
		 Settings allow_experimental_window_functions = 1
		 )a 
	where a.rk=1
	)xx on xx.vin_code=tisd.vin
join (-- MIni注册用户
	select distinct m.distinct_id
	from ads_crm.ads_crm_events_member_d m
	where 1=1
	and m.min_app_time is null -- 剔除APP注册用户就是小程序注册用户
	)mini on toString(xx.id) =mini.distinct_id
where 1=1
	and tisd.is_deleted =0
	and tisd.invoice_date<'2024-03-18'
	and e.RO_CREATE_DATE <'2024-03-18' -- 回过厂
--	and e.RO_CREATE_DATE >='2023-01-01'
	and e.RO_STATUS = '80491003'-- 已结算工单
	and e.REPAIR_TYPE_CODE <> 'P'-- 售后
	and e.REPAIR_TYPE_CODE <> 'S'
	and e.IS_DELETED = 0


--2、曾经回过厂但都双端都未注册的车主
select 
count(distinct xx.id)
from ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd   -- 与发票表关联
join ods_cyre.ods_cyre_tt_repair_order_d e on tisd.vin=e.VIN  --工单表
left join	
	(select distinct a.cust_id as id,
	a.vin_code
	from (
--		 取最近一次绑车时间
		 select
		 r.member_id,
		 m.cust_id,
		 r.bind_date,
		 r.vin_code,
		 m.member_phone,
		 row_number() over(partition by r.vin_code order by r.bind_date desc) rk
		 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
		 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.member_id is not null 
		 and r.member_id <>''
		 and m.member_phone<>'*'
		 and m.member_phone is not null 
		 Settings allow_experimental_window_functions = 1
		 )a 
	where a.rk=1
	)xx on xx.vin_code=tisd.vin
left join (-- 注册用户
	select distinct m.distinct_id
	from ads_crm.ads_crm_events_member_d m
	)mini on toString(xx.id) =mini.distinct_id
where 1=1
	and tisd.is_deleted =0
--	and tisd.invoice_date>='2023-01-01'
--	and e.RO_CREATE_DATE <'2023-10-01' -- 2023年回过厂
--	and e.RO_CREATE_DATE >='2023-01-01'
	and e.RO_STATUS = '80491003'-- 已结算工单
	and e.REPAIR_TYPE_CODE <> 'P'-- 售后
	and e.REPAIR_TYPE_CODE <> 'S'
	and e.IS_DELETED = 0
	and mini.distinct_id is null -- 剔除注册用户