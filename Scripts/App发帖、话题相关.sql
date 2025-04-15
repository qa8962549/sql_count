-- 话题数据汇总
select 
--to_char(a.create_time,'yyyy-mm') -- 按月
--to_char(a.create_time,'IYYY-IW') 
a.topic_id 
,f.参与人数
,f.发帖量
,d.PV 阅读量
,c.评论量
,b.点赞
,b.收藏
from community.tr_topic_post_link a
left join (
	-- 0点赞 1收藏
	select
	l.topic_id,
	count(case when a.like_type=0 then a.member_id end) 点赞,
	count(case when a.like_type=1 then a.member_id end) 收藏
	from community.tt_like_post a
	left join community.tm_post b on a.post_id =b.post_id 
	left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0 
	where a.is_deleted <>1
	and a.create_time >='2024-01-01'
	and a.create_time <'2024-09-01'
	group by 1
	order by 1 desc 
	)b on a.topic_id =b.topic_id 
left join (-- 评论
	select 
	l.topic_id,
	count(a.id) 评论量
	from community.tm_comment a
	left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0 
	where a.is_deleted <>1
	and a.create_time >='2024-01-01'
	and a.create_time <'2024-09-01'
	group by 1
	)c on c.topic_id=a.topic_id 
left join (-- 话题的PVUV
	select 
	l.topic_id,
	count(a.member_id) PV -- 阅读量
	from community.tt_view_post a
	left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0 
	where 1=1
	and a.create_time >='2024-01-01'
	and a.create_time <'2024-09-01'
	and a.is_deleted =0
	group by 1
	order by 1 desc ) d on d.topic_id=a.topic_id 
left join (-- 帖子的参与人数
	select 
	l.topic_id,
	count(distinct a.member_id) 参与人数, -- 参与人数
	count(a.id) 发帖量
	from community.tr_topic_post_link l 
	left join community.tm_post a on a.post_id = l.post_id and l.is_deleted = 0 
	where 1=1
	and a.create_time >='2024-01-01'
	and a.create_time <'2024-09-01'
	and a.is_deleted =0
	group by 1
	order by 1) f on f.topic_id=a.topic_id 
where a.topic_id is not null 
and a.create_time >='2024-01-01'
and a.create_time <'2024-09-01'
group by rollup(1)
order by 1

-- 帖子的参与人数
	select 
	distinct tmi.id,
	tmi.member_name ,
	l.topic_id
--	a.po
--	a.post_type ,
--	count(distinct a.member_id) 参与人数, -- 参与人数
--	count(a.id) 发帖量
	from community.tr_topic_post_link l 
	left join community.tm_post a on a.post_id = l.post_id and l.is_deleted = 0 
	left join "member".tc_member_info tmi on a.member_id =tmi.id
	where 1=1
--	and a.create_time >='2024-01-01'
--	and a.create_time <'2024-09-01'
	and a.is_deleted =0
	and topic_id ='3Sqy0jpV1A'
	and tmi.member_name in ('心存善念','郝','Freeman','多多','张正伟','徐徐升起')
--	group by 1
--	order by 1

-- 0点赞 1收藏
	select  
	distinct 
	a.member_id 用户ID,
	tmi.member_name 用户昵称,
	case when tmi.is_vehicle =1 then'车主' else '粉丝' end  是否为车主
	from community.tt_like_post a
	join 
		(
		-- 收藏
		select distinct a.member_id
		from community.tt_like_post a 
		where a.is_deleted =0
		and a.like_type=1
		and a.post_id='qfcXEtjFS4'
		and a.create_time >='2024-07-23'
		and a.create_time <'2024-08-12'
		)a1 on a.member_id=a1.member_id 
	left join "member".tc_member_info tmi on a.member_id =tmi.id
	where a.is_deleted =0
	and a.like_type=0 -- 点赞
	and a.create_time >='2024-07-23'
	and a.create_time <'2024-08-12'
	and a.post_id='qfcXEtjFS4'


-- 帖子数据汇总
select 
a.post_id
,a.post_title 
,b.点赞
,c.评论人数
,b.收藏
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
--	and a.create_time >='2023-09-21'
--	and a.create_time <'2023-10-31'
	group by 1
	)b on a.post_id =b.post_id 
left join (-- 评论
	select 
	a.post_id ,
	count(a.member_id) 评论人数
	from community.tm_comment a
	where a.is_deleted <>1
--	and a.post_id ='cOgh4khS80'
--	and a.create_time >='2023-09-21'
--	and a.create_time <'2023-10-31'
	group by 1
	)c on c.post_id=a.post_id 
left join (-- 帖子的PVUV
	select 
	a.post_id ,
	count(a.member_id) PV,
	count(DISTINCT a.member_id) UV
	from community.tt_view_post a
	where 1=1
--	and a.create_time >='2023-09-21'
--	and a.create_time <'2023-10-31'
	and a.is_deleted =0
	group by 1) d on d.post_id=a.post_id 
where a.post_id in ('liMlz5xwOa')
group by 1
order by 1

-- 发帖 2023年总发帖人数（去重），2023年总发帖量
	select 
--	date_format(a.create_time,'%Y-%m') t,
	count(distinct a.member_id) "总发帖人数（去重）",
	count(a.post_id) "总发帖量", -- 不同话题下的发帖数量总和  -- KPI口径 
	count(distinct a.post_id) "总发帖量2" -- 发帖数量总和 
	from community.tm_post a
	left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
	left join community.tm_topic tt on bb.topic_id =tt.topic_id 
	where a.is_deleted =0
	and a.create_time>='2024-01-01'
	and a.create_time<'2024-12-01'
--	and bb.topic_id is not null and bb.topic_id<>'' -- 带话题


--------------------------------------------------------------------分割线------------------------------------------------------------------------------------------------
-- 帖子的PVUV
select count(a.member_id) PV,
count(DISTINCT a.member_id) UV
from community.tt_view_post a
left join "member".tc_member_info m on a.member_id =m.id
where a.post_id in ('dXKa0C4aJQ')
--and a.create_time >='2023-09-21'
--and a.create_time <'2023-10-31'
and a.is_deleted =0
and m.is_vehicle =1


-- 0点赞 1收藏
select
a.like_type,
count(a.member_id) 数量
from community.tt_like_post a
left join community.tm_post b on a.post_id =b.post_id 
where a.is_deleted <>1
and a.post_id ='cOgh4khS80'
and a.create_time >='2024-01-01'
and a.create_time <'2023-06-06'
group by 1
order by 1 desc 

-- 评论
select 
count(a.member_id) 文章总评论人数
from community.tm_comment a
where a.is_deleted <>1
and a.post_id ='cOgh4khS80'
and a.create_time >='2024-01-01'
and a.create_time <'2023-06-06'


-- 发帖人数
select 
distinct date_format(x.create_time,'%Y-%m'),
--count(distinct x.member_id)
x.member_id
from 
	(
	select a.id,a.member_id,a.create_time
	from community.tm_post a
	where 1=1
	and a.is_deleted =0
	and a.create_time >='2024-06-01'
	and a.create_time <'2024-10-01'
	-- and a.post_id ='cOgh4khS80'
--	and (a.post_digest like '%#WO最爱的夏日度假#%'
--	or a.post_digest like '%WO最爱的夏日度假%')
--	or a.post_digest like '%#北欧式生活的一天#%')
)x 
--group by 1
order by 1




-- 此刻发帖明细
select 
a.member_id 会员ID,
a.id 动态ID,
a.create_time 发帖日期,
-- '' 发帖tag,
a.post_digest 发帖内容,
-- (length(a.post_digest)-CHAR_LENGTH(a.post_digest))/2 发帖字数,
-- a.cover_images '发帖图片(链接)',
tmi.MEMBER_NAME 昵称,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tmi.REAL_NAME 姓名,
tmi.MEMBER_PHONE 沃世界注册手机号码,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
a.read_count 浏览量,
a.like_count 点赞数,
a.collect_count 收藏量,
b.tt 评论数
from community.tm_post a
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join 
	(select b.post_id,
	count(1) tt
	from community.tm_comment b 
	where b.is_deleted =0
	and b.create_time >='2024-01-01'
	and b.create_time <'2024-09-01'
	group by 1
) b on b.post_id =a.post_id
where a.is_deleted ='0'
--and a.create_time >='2024-01-01'
--and a.create_time <'2024-09-01'
--and a.post_type ='1007'-- 文章
 and a.post_id in ()
--and a.post_digest like '%EX90，沃的Tech心声%' 

-- 发帖明细
select 
distinct 
a.member_id 会员ID,
a.post_id 文章ID,
tmi.REAL_NAME 用户姓名,
tmi.MEMBER_NAME 用户昵称,
case when tmi.IS_VEHICLE = '1' then '车主' when tmi.IS_VEHICLE = '0' then '粉丝' end 用户类型,
case when tmi.member_level = 1 then '银卡'
     when tmi.member_level = 2 then '金卡'
     when tmi.member_level = 3 then '白金卡' 
     when tmi.member_level = 4 or   tmi.member_level = 5 then '黑卡' end 会员等级,
tmi.MEMBER_PHONE 沃世界注册手机号码,
a.create_time 发帖时间,
l.topic_id 话题id,
replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ','')  "发帖内容",
char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))  "发帖字数",
pm.发帖图片数量,
a.like_count 动态点赞数,
pm.发帖图片链接  发帖图片链接
--a.post_type "帖子类型(动态1001/文章1002/活动1006/UGC文章1007)",
--a.post_state "帖子状态:1上架,2下架,4审核中,5审核不通过"
--tisd.invoice_date 最后购车开票时间
--datediff(a.create_time,tisd.invoice_date)
from community.tm_post a
left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join
(
		-- 发帖内容、图片
	select
	t.post_id,
	replace(string_agg(case when t.类型='text' then t.内容 else null end ,';'),' ','') as 发帖内容,
	string_agg(case when t.类型='image' then t.内容 else null end ,';') as 发帖图片链接,
	count(case when t.类型='image' then t.内容 else null end) as 发帖图片数量
	from
	(
		select
		tpm.post_id,
		tpm.create_time,
		replace(tpm.node_content,E'\\u0000','') 发帖内容,
		json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeType' 类型,
		json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeContent' 内容
		from community.tt_post_material tpm
		where 1=1
--		and tpm.create_time >= '2023-11-06' and tpm.create_time < '2023-11-13'
		and tpm.is_deleted = 0
	) as t
	group by t.post_id
) pm on a.post_id = pm.post_id
left join(
		select a.member_id
		,a.vin_code
		,a.bind_date
		,b.model_name 拥车车型
		,row_number()over(partition by a.member_id order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
		)x on x.member_id=a.member_id and x.rk=1
left join vehicle.tt_invoice_statistics_dms tisd on x.vin_code=tisd.vin   -- 与发票表关联
where a.is_deleted =0
and a.create_time >='2025-01-01'
--and a.create_time <'2024-05-07'
and l.topic_id ='1zeWlU2tjw' 
--and a.post_id='1zeWlU2tjw'
--and tmi.IS_VEHICLE = '1'-- 车主
--and char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))>=300 --帖子字数不少于300字
and pm.发帖图片数量>=1 -- 配图不少于1张的文章及动态
--and datediff(a.create_time,tisd.invoice_date)<=365 -- 最后开票时间距发帖时间在一年以内
--and a.member_id ='6873815'
order by a.create_time

-- app评论 BbKqAZuyAh
select 
tmi.MEMBER_NAME 社区昵称,
tmi.CUST_ID 社区会员id,
case when tmi.IS_VEHICLE = '1' then '是'
	when tmi.IS_VEHICLE = '0' then '否'
	end 是否车主,
-- IF(a.comment_content like '%在一起W%','是','否') '是否带#俱在一起WOW#话题',
-- '评论内容做筛选' as  '是否带#俱在一起WOW#话题',
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
and a.create_time >='2024-01-01'
and a.create_time <'2024-09-01'
and a.post_id ='1CgzjkYez5'
-- and a.comment_content like '%真好%'

--兴趣圈用户内容数据
	select 
	distinct 
	p.create_time `发布时间`,
	pm.`发帖字数` `发帖字数`,
	pm.`发帖图片数量` `发帖图片数量`,
	p.like_count `动态点赞数`,
	pm.`发帖内容` `发帖内容`,
	l2.topic `发帖话题（该内容下所有引用tag）`,
	pm.`发帖图片链接` `发帖图片链接`,
	p.member_id `发布者ID`
--	p.post_id `内容ID`,
--	p.post_title `内容标题`,
	from ods_cmnt.ods_cmnt_tm_post_cur p 
	left join ods_cmnt.ods_cmnt_tr_topic_post_link_cur l on p.post_id = l.post_id
	left join 
		(select post_id,arrayStringConcat(arrayCompact(groupArray(l.topic_id)), ',') topic
		from ods_cmnt.ods_cmnt_tm_post_cur p 
		left join ods_cmnt.ods_cmnt_tr_topic_post_link_cur l on p.post_id = l.post_id
		where 1=1
		and l.topic_id in ('ItqesqL6hY','KEe2ppZMxt')
		group by 1 
		)l2 on p.post_id = l2.post_id
	left join
		(-- 发帖内容、图片
			select
				t.post_id,
				REPLACE(replaceRegexpAll(replaceRegexpAll(arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'text' THEN t.`内容` ELSE NULL END), ';'), '<.*?>', ''),'#(.*?)#', ''),' ','') `发帖内容`,
				lengthUTF8(REPLACE(replaceRegexpAll(replaceRegexpAll(arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'text' THEN t.`内容` ELSE NULL END), ';'), '<.*?>', ''),'#(.*?)#', ''),' ','')) `发帖字数`,
				arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'image' THEN t.`内容` ELSE NULL END), ';') AS `发帖图片链接`,
				count(case when t.`类型`='image' then t.`内容` else null end) as `发帖图片数量`
			from(
				select 
					tpm.post_id
					,tpm.create_time
					,visitParamExtractString(tpm.node_content, 'nodeType') `类型`
					,visitParamExtractString(tpm.node_content, 'nodeContent') `内容`
				from (
				select
					tpm.post_id
					,tpm.create_time
					,arrayJoin(splitByString('},{',cast(tpm.node_content as String)) ) as node_content
				from ods_cmnt.ods_cmnt_tt_post_material_cur tpm
				where 1=1
--				and tpm.create_time between '2024-07-19 15:00:00' and '2024-07-28 23:59:59'
				and tpm.is_deleted = 0) tpm 
			) as t
			group by t.post_id
		) pm on p.post_id = pm.post_id
	where 1=1
	and p.create_time>='2024-10-10'
	and p.create_time<'2024-10-21'
	and l.topic_id in ('ItqesqL6hY','KEe2ppZMxt')
--	and l2.topic in ('KEe2ppZMxt,ItqesqL6hY','ItqesqL6hY,KEe2ppZMxt')
	and pm.`发帖字数`>=15
	and pm.`发帖图片数量`>=1
	order by 2 desc 
	
	
	
	select 
	p.member_id,
	post_id,
	p.create_time,
	count(distinct topic_id) `话题数量`
--	arrayStringConcat(arrayCompact(groupArray(l.topic_id)), ',') topic
		from ods_cmnt.ods_cmnt_tm_post_cur p 
		left join ods_cmnt.ods_cmnt_tr_topic_post_link_cur l on p.post_id = l.post_id
		where 1=1
--		and l.topic_id in ('ItqesqL6hY','KEe2ppZMxt')
		group by 1,2,3
		order by 4 desc ,3 desc ,1
		
	