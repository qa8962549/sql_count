-- 活动各项监控数据
select o.ref_id
,o.title
,o.PV
,o.UV
,e.one 一级评论数
,e.two 二级评论数
,e.lyl 总评论数
,f.xin 拉新
,d.sli 僵尸粉数
,o.点赞量
,o.转发量
,o.收藏量
,o.车主数
,o.粉丝数
,o.游客数
,o.上线时间 
from (
	select o.ref_id,c.title,c.上线时间
				,sum(case when o.type='VIEW' then 1 else 0 end)  PV
				,count(distinct case when o.type='VIEW' then o.user_id else null end) UV
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=1 then o.user_id else null end) 车主数
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=0 then o.user_id else null end) 粉丝数
				,count(DISTINCT case when o.type='VIEW' and m.id is null then o.user_id else null end) 游客数
				,sum(case when o.type='SUPPORT' then 1 else 0 end) 点赞量
				,sum(CASE when o.type='SHARE' then 1 else 0 end) 转发量
				,sum(CASE when o.type='COLLECTION' then 1 else 0 end) 收藏量
	from cms_center.cms_operate_log o
	left join (
--				#查询文章pageid
			select c.page_id
			,c.title 
			,c.publish_date 上线时间
			from cms_center.cms_content c 
			where c.deleted=0 
			union all 
--			#查询活动pageid
			select a.page_id,a.active_name title,a.date_create 上线时间
			from activity.cms_active a 
			where a.active_locate='沃尔沃汽车沃世界'
			and a.is_deleted=0 and a.page_id is not null and a.page_id<>''
	) c on o.ref_id=c.page_id
	left join (
			select mm.id,mm.user_id,mm.is_vehicle
			from (
			select m.user_id,max(m.id) mid
			from member.tc_member_info m 
			where m.is_deleted=0 and m.member_status<>60341003
			GROUP BY 1  ) m
			LEFT JOIN member.tc_member_info mm on mm.id=m.mid
	)m on m.user_id=o.user_id
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	and o.ref_id='Dg82cQK2sq'
	GROUP BY 1,2,3
) o left join (
	select object_id,
	-- count(object_id) lyl 
	sum(case when top_id is null then 1 else 0 end) one,
	sum(case when top_id is not null then 1 else 0 end) two,
	count(object_id) lyl 
	from comment.tt_evaluation_history 
	where object_id ='Dg82cQK2sq'
	group by 1
) e on e.object_id=o.ref_id
left join (
select a.ref_id,count(a.usertag) sli
from(
		-- 获取访问文章活动10分钟之前的最晚访问时间
		select t.usertag,b.ldate,b.ref_id,max(t.date) tdate
		from track.track t
		join (
			-- 获取访问文章活动的最早时间、
			select ref_id,cast(l.user_id as varchar) user_id,min(date_create) ldate 
			from cms_center.cms_operate_log l
			join member.tc_member_info m on l.user_id=m.user_id
			where l.ref_id='Dg82cQK2sq' 
			and l.type ='VIEW' 
			GROUP BY 1,2
		) b on b.user_id=t.usertag
		where t.date< DATE_SUB(b.ldate,INTERVAL '10' MINUTE)
		GROUP BY 1,2,3
	) a
	where a.tdate < DATE_SUB(a.ldate,INTERVAL '30' DAY) 
	GROUP BY 1
) d on d.ref_id=o.ref_id 
left join (
	select 'Dg82cQK2sq' ref_id,count(DISTINCT m.id) xin
	from track.track t
	join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
	where 
	json_extract_path_text(t.data::json,'pageId')='Dg82cQK2sq' 
--	json_extract(t.`data`,'$.pageId')='Dg82cQK2sq' 
	and m.create_time>=date_sub(t.date,interval '10' MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL '10' MINUTE)
	and t.date>'2023-08-31'
) f on f.ref_id=o.ref_id
--where -- o.title is not null 
--o.ref_id='Dg82cQK2sq';


-- 预约试驾
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
	tad.drive_e_at 试驾结束时间
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
	WHERE ta.CREATED_AT >= '2023-09-01'
	AND ta.CREATED_AT <'2023-10-31'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT

-- 预约试驾 APP端 IBCRMJUNWEWAPPSJ2022VCCN
select x.预约车型,count(x.预约ID)
from 
(
	SELECT
	DISTINCT ta.APPOINTMENT_ID 预约ID,
	ca.active_code,
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
	tad.drive_e_at 试驾结束时间
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
	WHERE ta.CREATED_AT >= '2023-09-01'
	AND ta.CREATED_AT <'2023-10-31'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ca.active_code = 'IBCRMJUNWEWAPPSJ2022VCCN'   -- app
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
--	and ca.active_name like '%App%'
	order by ta.CREATED_AT)x 
	group by 1
	order by 1
	
-- order 订单转化数
select 
--a.商机id,
a.车型名称,
--a.最早线索创建时间,
--b.订单时间
 COUNT( DISTINCT a.`商机id`)
from
	(
	select a.business_id 商机id,
	min(a.create_time) 最早线索创建时间,
	f.MODEL_NAME 车型名称
	from customer.tt_clue_clean a 
	left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
	left join activity.cms_active c on a.campaign_id = c.uid
	left join customer_business.tm_clue_source d on d.ID = c.active_channel
	left join dictionary.tc_code e on a.clue_status = e.CODE_ID
	left join basic_data.tm_model f on a.model_id = f.id
	left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
	 left join dictionary.tc_code i on i.code_id = a.gender
	where a.create_time >= '2023-09-01'
	and a.create_time <'2023-10-31'
	and c.active_code='IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	and e.CODE_CN_DESC not in ('待清洗','待分配','无效')
	GROUP BY 1 
	) a 
join 
	(
	select a.CUSTOMER_BUSINESS_ID 商机id ,min(a.CREATED_AT) 订单时间
	from cyxdms_retail.tt_sales_orders a 
	left join dictionary.tc_code g on g.code_id = a.SO_STATUS
	where a.BUSINESS_TYPE<>14031002
	and a.IS_DELETED = 0
	and a.CREATED_AT  >= '2023-09-01'
	and a.CREATED_AT  <'2023-10-31'
	and g.code_cn_desc in ('提交待审批','审批通过','已交车','退车中')
	GROUP BY 1 
	) b on a.`商机id`=b.`商机id`
	
-- order 订单转化数 APP
select 
--a.商机id,
a.车型名称,
--a.最早线索创建时间,
--b.订单时间
 COUNT( DISTINCT a.`商机id`)
from
	(
	select a.business_id 商机id,
	min(a.create_time) 最早线索创建时间,
	f.MODEL_NAME 车型名称
	from customer.tt_clue_clean a 
	left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
	left join activity.cms_active c on a.campaign_id = c.uid
	left join customer_business.tm_clue_source d on d.ID = c.active_channel
	left join dictionary.tc_code e on a.clue_status = e.CODE_ID
	left join basic_data.tm_model f on a.model_id = f.id
	left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
	 left join dictionary.tc_code i on i.code_id = a.gender
	where a.create_time >= '2023-09-01'
	and a.create_time <'2023-10-31'
	and c.active_code='IBCRMJUNWEWAPPSJ2022VCCN'   -- app
	and e.CODE_CN_DESC not in ('待清洗','待分配','无效')
	GROUP BY 1 
	) a 
join 
	(
	select a.CUSTOMER_BUSINESS_ID 商机id ,min(a.CREATED_AT) 订单时间
	from cyxdms_retail.tt_sales_orders a 
	left join dictionary.tc_code g on g.code_id = a.SO_STATUS
	where a.BUSINESS_TYPE<>14031002
	and a.IS_DELETED = 0
	and a.CREATED_AT  >= '2023-09-01'
	and a.CREATED_AT  <'2023-10-31'
	and g.code_cn_desc in ('提交待审批','审批通过','已交车','退车中')
	GROUP BY 1 
	) b on a.`商机id`=b.`商机id`
group by a.车型名称

-- 帖子数据汇总
select a.post_id
,b.点赞
,c.评论人数
--,b.收藏
,d.PV
,d.UV
from community.tm_post a
left join (
	-- 0点赞 1收藏
	select
	 a.post_id,
	count(case when a.like_type=0 then a.member_id end) 点赞,
	count(case when a.like_type=1 then a.member_id end) 收藏
	from community.tt_like_post a
	left join community.tm_post b on a.post_id =b.post_id 
	where a.is_deleted <>1
--	and a.post_id ='cOgh4khS80'
	and a.create_time >='2023-09-01'
	and a.create_time <'2023-10-31'
	group by 1
	)b on a.post_id =b.post_id 
left join (-- 评论
	select 
	a.post_id ,
	count(a.member_id) 评论人数
	from community.tm_comment a
	where a.is_deleted <>1
--	and a.post_id ='cOgh4khS80'
	and a.create_time >='2023-09-01'
	and a.create_time <'2023-10-31'
	group by 1
	)c on c.post_id=a.post_id 
left join (-- 帖子的PVUV
	select 
	a.post_id ,
	count(a.member_id) PV,
	count(DISTINCT a.member_id) UV
	from community.tt_view_post a
	where 1=1
	and a.create_time >='2023-09-01'
	and a.create_time <'2023-10-31'
	and a.is_deleted =0
	group by 1) d on d.post_id=a.post_id 
where a.post_id in ('BBuMw837oq')
group by 1

-- 相关tag此刻帖发帖量
select count(x.id)
from 
	(
	select a.id
	from community.tm_post a
	where a.is_deleted =0
	and a.create_time >='2023-09-01'
	and a.create_time <'2023-10-31'
	-- and a.post_id ='cOgh4khS80'
	and a.post_digest like '%#一日车评人#%'
--	or a.post_digest like '%WO最爱的夏日度假%')
--	or a.post_digest like '%#北欧式生活的一天#%')
)x 

-- app评论 BbKqAZuyAh
select 
tmi.MEMBER_NAME 社区昵称,
tmi.CUST_ID 社区会员id,
case when tmi.IS_VEHICLE = '1' then '是'
	when tmi.IS_VEHICLE = '0' then '否'
	end 是否车主,
case when a.comment_content like '%一日车评人%' then '是' else '否' end 是否带话题,
a.create_time 评论日期,
-- a.id 动态ID,
-- case when tmi.member_sex = '10021001' then '先生'
-- 	when tmi.member_sex = '10021002' then '女士'
-- 	else '未知' end 性别,
a.comment_content 评论内容,
LENGTH(regexp_replace(a.comment_content, '[^\u4e00-\u9fff]', '', 'g')) 评论字数,
--(length(a.comment_content)-CHAR_LENGTH(a.comment_content))/2  评论字数,
a.images 上传图片,
a.member_id 沃世界会员ID,
tmi.MEMBER_NAME 沃世界昵称,
tmi.MEMBER_PHONE 手机号码,
r.收货人姓名,
r.收货人手机号,
r.收货地址,
x.俱乐部名称,
--y.vin,
z.open_id
from community.tm_comment a
left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join 
(
	select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
	(
	select 
	tma.MEMBER_ID,
	tma.CONSIGNEE_NAME 收货人姓名,
	tma.CONSIGNEE_PHONE 收货人手机号,
	CONCAT(ifnull(tr.REGION_NAME,''),ifnull(tr2.REGION_NAME,''),ifnull(tr3.REGION_NAME,''),ifnull(tma.MEMBER_ADDRESS,''))收货地址,
	row_number() over(partition by tma.member_address order by tma.create_time desc) rk
	from `member`.tc_member_address tma
	left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
	left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
	left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
	where tma.IS_DELETED = 0
	and tma.IS_DEFAULT = 1   -- 默认收货地址
	)c where c.rk = 1
)r on r.MEMBER_ID=a.member_id 
left join
(	
--# 小程序会员最新俱乐部
	select
	a.member_id
	,a.俱乐部名称
	from
	(select
	u.member_id,
	a.`name` 俱乐部名称,
	ROW_NUMBER() over(partition by u.member_id order by u.date_create desc) as rk
	from car_friends.car_friends_user u   -- 俱乐部成员表
	join car_friends.car_friends_activity a on a.id = u.activity_id 
	-- and a.audit_status = 3 -- 限定认证俱乐部
	and a.is_deleted = 0
	) a
	where a.rk = 1
)x on x.member_id=a.member_id 
left join
(	 
--# 小程序会员最新绑车VIN
	select
	a.MEMBER_ID
	,a.VIN
	from
	(
	 select
	 tmv.MEMBER_ID,
	 tmv.VIN,
	--  tmi.MEMBER_TIME,
	--  tmv.CREATE_TIME,
	--  tmi.member_phone,
	 ROW_NUMBER() over(partition by tmi.ID order by tmv.CREATE_TIME desc) as rk
	 from `member`.tc_member_vehicle tmv    -- 用户绑定车辆表
	 join `member`.tc_member_info tmi on tmi.ID = tmv.MEMBER_ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0    -- 关联会员表，剔除用户黑名单
	 where tmv.IS_DELETED = 0
	) a
	where a.rk = 1
)y on y.MEMBER_ID=a.member_id 
left join
(	
--# 匹配微信openid
	select a.id member_id,m.open_id
	from `member`.tc_member_info a
	JOIN(
		select a.mid,o.open_id
		from (
--			#结合老库获取新库用户对应的 unionid
			select m.id mid,m.MEMBER_PHONE,c.union_id,u.unionid,IFNULL(c.union_id,u.unionid) allunionid
			from  member.tc_member_info m 
			left join customer.tm_customer_info c on c.id=m.cust_id
			left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid<>'00000000'
			where m.member_status<>60341003 and m.is_deleted=0 and LENGTH(m.member_phone)=11
		)a
		JOIN volvo_wechat_live.es_car_owners o on a.allunionid=o.unionid and o.unionid<>'' and o.subscribe_status=1
	) m on a.ID=m.mid
)z on z.member_id=a.member_id 
where a.is_deleted =0
and a.create_time >='2023-09-01'
and a.create_time <'2023-10-31'
and a.post_id ='BBuMw837oq'
-- and a.comment_content like '%真好%'

-- 此刻发帖明细
select 
distinct 
a.member_id 会员ID,
a.id 动态ID,
a.post_id ,
--a.club_id ,
--bb.topic_id ,
a.create_time 发帖日期,
a.post_digest 发帖内容,
--(length(a.post_digest)-CHAR_LENGTH(a.post_digest))/2 发帖字数,
LENGTH(regexp_replace(a.post_digest, '[^\u4e00-\u9fff]', '', 'g')) 发帖字数,
a.cover_images "发帖图片(链接)",
tmi.MEMBER_NAME 昵称,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tmi.REAL_NAME 姓名,
tmi.MEMBER_PHONE 沃世界注册手机号码,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
x.收货人姓名,
x.收货人手机号,
x.收货地址,
z.open_id,
a.read_count 浏览量,
a.like_count 点赞数,
a.collect_count 收藏量,
b.tt 评论数,
x1.俱乐部名称 所属俱乐部
from community.tm_post a
left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join 
	(select b.post_id,
	count(1) tt
	from community.tm_comment b 
	where b.is_deleted =0
	and b.create_time >='2023-09-01'
	and b.create_time <'2023-10-31'
	group by 1
) b on b.post_id =a.post_id
left join 
	(
	select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
	(
	select 
	tma.MEMBER_ID,
	tma.CONSIGNEE_NAME 收货人姓名,
	tma.CONSIGNEE_PHONE 收货人手机号,
	CONCAT(ifnull(tr.REGION_NAME,''),ifnull(tr2.REGION_NAME,''),ifnull(tr3.REGION_NAME,''),ifnull(tma.MEMBER_ADDRESS,''))收货地址,
	row_number() over(partition by tma.member_address order by tma.create_time desc) rk
	from `member`.tc_member_address tma
	left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
	left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
	left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
	where tma.IS_DELETED = 0
	and tma.IS_DEFAULT = 1   -- 默认收货地址
	)c where c.rk = 1
)x on x.MEMBER_ID=a.member_id 
left join
(	
--# 小程序会员最新俱乐部
	select
	a.member_id
	,a.俱乐部名称
	from
	(select
	u.member_id,
	a.`name` 俱乐部名称,
	ROW_NUMBER() over(partition by u.member_id order by u.date_create desc) as rk
	from car_friends.car_friends_user u   -- 俱乐部成员表
	join car_friends.car_friends_activity a on a.id = u.activity_id 
	-- and a.audit_status = 3 -- 限定认证俱乐部
	and a.is_deleted = 0
	) a
	where a.rk = 1
)x1 on x1.member_id=a.member_id 
left join
(	 
--# 小程序会员最新绑车VIN
	select
	a.MEMBER_ID
	,a.VIN
	from
	(
	 select
	 tmv.MEMBER_ID,
	 tmv.VIN,
	--  tmi.MEMBER_TIME,
	--  tmv.CREATE_TIME,
	--  tmi.member_phone,
	 ROW_NUMBER() over(partition by tmi.ID order by tmv.CREATE_TIME desc) as rk
	 from `member`.tc_member_vehicle tmv    -- 用户绑定车辆表
	 join `member`.tc_member_info tmi on tmi.ID = tmv.MEMBER_ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0    -- 关联会员表，剔除用户黑名单
	 where tmv.IS_DELETED = 0
	) a
	where a.rk = 1
)y on y.MEMBER_ID=a.member_id 
left join
(	
--# 匹配微信openid
	select a.id member_id,m.open_id
	from `member`.tc_member_info a
	JOIN(
		select a.mid,o.open_id
		from (
--			#结合老库获取新库用户对应的 unionid
			select m.id mid,m.MEMBER_PHONE,c.union_id,u.unionid,IFNULL(c.union_id,u.unionid) allunionid
			from  member.tc_member_info m 
			left join customer.tm_customer_info c on c.id=m.cust_id
			left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid<>'00000000'
			where m.member_status<>60341003 and m.is_deleted=0 and LENGTH(m.member_phone)=11
		)a
		JOIN volvo_wechat_live.es_car_owners o on a.allunionid=o.unionid and o.unionid<>'' and o.subscribe_status=1
	) m on a.ID=m.mid
)z on z.member_id=a.member_id 
where a.is_deleted =0
and a.create_time >='2023-09-01'
and a.create_time <'2023-10-31'
--and a.post_id ='BBuMw837oq'
and a.post_digest like '%#一日车评人#%'