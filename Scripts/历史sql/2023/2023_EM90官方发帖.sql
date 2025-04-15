-- app评论 BbKqAZuyAh
select 
tmi.MEMBER_NAME 社区昵称,
tmi.CUST_ID 社区会员cust_id,
a.member_id 沃世界会员mmeber_ID,
tmi.MEMBER_PHONE 手机号码,
case when tmi.IS_VEHICLE = '1' then '是'
	when tmi.IS_VEHICLE = '0' then '否'
	end 是否车主,
a.create_time 评论日期,
a.comment_id 一级评论ID,
a.comment_content 评论内容,
a.images 评论图片,
bb.topic_id 主题ID,
tt.topic_name 帖子主题,
a.parent_id 上级评论Id,
a2.comment_content 上级评论内容,
case when a.parent_id='0' then 1
	else  2 end 层级,
LENGTH(regexp_replace(a.comment_content, '[^\u4e00-\u9fff]', '', 'g')) 评论字数,
y.拥车车型 绑定车辆信息,
case when x.customer_business_id is null then '否' else '是' end as 是否已下订沃尔沃EM90
from community.tm_comment a
left join community.tm_comment a2 on a.parent_id =a2.comment_id 
left join community.tm_post tp on a.post_id =tp.post_id 
left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
left join community.tm_topic tt on tt.topic_id=bb.topic_id
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join
(
	select a.member_id
	,group_concat(b.model_name) 拥车车型
	from volvo_cms.vehicle_bind_relation a
	left join basic_data.tm_model b on a.series_code =b.model_code
	where a.deleted = 0
	and a.is_bind=1
	group by 1
		)y on y.MEMBER_ID=a.member_id 
left join (
	select
	*
	FROM cyxdms_retail.tt_sales_orders  a
	left join cyxdms_retail.tt_sales_order_vin  b on a.`so_no`  = b.`vi_no` 
	left join cyxdms_retail.tt_sales_order_detail c on c.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
	WHERE b.`sale_type` = 20131010
	and a.`so_status` in (14041001,14041002,14041003,14041008,14041030)
	and a.`is_deposit` in (10421009,10041001,10041002,70961001,70961002)
	and c.second_id = '1111'    -- basic_data里面的id，对应EM90
	--and a.created_at >= '2023-11-12'   
	 and a.created_at < '2023-11-29'    
	and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
	and a.`is_deleted` ='0'
	and b.`is_deleted` ='0')x on x.customer_tel=tmi.member_phone 
where a.is_deleted =0
--and a.create_time >='2023-09-01'
and a.create_time <'2023-11-29'
and a.post_id in ('LtaG2DwBA6',
'WMsxrwR0N9',
'ADgF8VGODS',
'j1KA1iwVaF',
'yr8uH5TEHf',
'm7gjf0rkYf',
'SyOaNFpSO3',
'wje21Z4VDH',
'jcqGgsp4g2',
'BeOWlHH4sA',
'bfMlHRwVdN',
'BfcDq6S8fi',
'EJsJj5qXfC',
'uawvtZng0L',
'SkQl8fCDK6',
'ZpOUwR45lc',
'rN86aXJayZ',
'oBMb27pR2T',
'0AO0oEnc4F',
'r7KCc7Q94R',
'UnqIvxbt45')



select x.member_id,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 用户会员身份,
tmi.real_name 用户真实姓名,
tmi.MEMBER_PHONE 用户手机号,
count(1) 浏览点击次数,
y.拥车车型 绑定车辆信息,
case when x2.customer_business_id is null then '否' else '是' end as 是否已下订沃尔沃EM90
from 
	(
	select tlp.member_id,tlp.post_id 
	from community.tt_like_post tlp 
	where tlp.is_deleted =0
	and tlp.create_time >='2023-10-09'
	and tlp.create_time <'2023-11-29'
	union all 
	select tvp.member_id ,tvp.post_id 
	from community.tt_view_post tvp 
	where tvp.is_deleted =0
	and tvp.create_time >='2023-10-09'
	and tvp.create_time <'2023-11-29'
)x 
left join "member".tc_member_info tmi on x.member_id=tmi.id 
left join
(
	select a.member_id
	,group_concat(b.model_name) 拥车车型
	from volvo_cms.vehicle_bind_relation a
	left join basic_data.tm_model b on a.series_code =b.model_code
	where a.deleted = 0
	and a.is_bind=1
	group by 1
		)y on y.MEMBER_ID=x.member_id 
left join (
	select
	*
	FROM cyxdms_retail.tt_sales_orders  a
	left join cyxdms_retail.tt_sales_order_vin  b on a.`so_no`  = b.`vi_no` 
	left join cyxdms_retail.tt_sales_order_detail c on c.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
	WHERE b.`sale_type` = 20131010
	and a.`so_status` in (14041001,14041002,14041003,14041008,14041030)
	and a.`is_deposit` in (10421009,10041001,10041002,70961001,70961002)
	and c.second_id = '1111'    -- basic_data里面的id，对应EM90  
	and a.created_at < '2023-11-29'
	and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
	and a.`is_deleted` ='0'
	and b.`is_deleted` ='0')x2 on x2.customer_tel=tmi.member_phone 
where x.post_id in 
('LtaG2DwBA6',
'WMsxrwR0N9',
'ADgF8VGODS',
'j1KA1iwVaF',
'yr8uH5TEHf',
'm7gjf0rkYf',
'SyOaNFpSO3',
'wje21Z4VDH',
'jcqGgsp4g2',
'BeOWlHH4sA',
'bfMlHRwVdN',
'BfcDq6S8fi',
'EJsJj5qXfC',
'uawvtZng0L',
'SkQl8fCDK6',
'ZpOUwR45lc',
'rN86aXJayZ',
'oBMb27pR2T',
'0AO0oEnc4F',
'r7KCc7Q94R',
'UnqIvxbt45')
group by 1




-- 总订单数量（含退款）
select
*
FROM cyxdms_retail.tt_sales_orders  a
left join cyxdms_retail.tt_sales_order_vin  b on a.`so_no`  = b.`vi_no` 
left join cyxdms_retail.tt_sales_order_detail c on c.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
WHERE b.`sale_type` = 20131010
and a.`so_status` in (14041001,14041002,14041003,14041008,14041030)
and a.`is_deposit` in (10421009,10041001,10041002,70961001,70961002)
and c.second_id = '1111'    -- basic_data里面的id，对应EM90
--and a.created_at >= '2023-11-12'   
-- and a.created_at < '2023-11-17'    
--and a.created_at < '2023-11-21'
and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
and a.`is_deleted` ='0'
and b.`is_deleted` ='0';

-- 商城好物评论
select a.昵称,a.用户姓名,a.手机号码,a.评论内容,a.评论日期,a.评论图片,a.层级,sum(ifnull(a.点赞数,0))+sum(ifnull(b.评论数,0)) 互动数,a.点赞数
from
(
	SELECT
	tc.comment_id id,
	tc.create_by 会员id,
	tmi.MEMBER_NAME 昵称,
	tmi.REAL_NAME 用户姓名,
	tmi.MEMBER_PHONE 手机号码,
	tc.comment_content 评论内容,
	tc.create_time 评论日期,
	tc.images 评论图片,
	case when tc.parent_id='0' then 1
	else  2 end 层级,
	tc.like_count 点赞数
	FROM community.tm_comment tc 
	left join `member`.tc_member_info tmi on tmi.id = tc.member_id 
	where tc.post_id in ('TxgBM20EtK')
	-- 	and parent_id ='0'
	and tc.create_time BETWEEN '2023-06-02' and '2023-06-05 23:59:59'
	ORDER by tc.create_time
) a 
left join
(
	SELECT
	tc.parent_id ,
	count(*) 评论数
	FROM community.tm_comment tc 
	left join `member`.tc_member_info tmi on tmi.id = tc.member_id 
	where tc.post_id in ('TxgBM20EtK')
	and parent_id <>'0'
	and tc.create_time BETWEEN '2023-06-02' and '2023-06-05 23:59:59'
	group by 1
) b on a.id = b.parent_id
group by 1,2,3,4,5,6,7,9