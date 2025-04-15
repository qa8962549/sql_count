-- 会员常用信息
select
--tmi.USER_ID,
--IFNULL(tmi.REAL_NAME,tmi.MEMBER_NAME) "姓名",
--tmi.MEMBER_PHONE "手机号",
tmi.ID "会员ID",
if(t.绑车数量<=1,'否','是') 是否多车型,
t.车型,
--t.vin_code,
t.绑车车款,
ifnull(x1.num,0) 近一个月内发布帖子数量,
ifnull(x2.num,0) 近三个月内发布帖子数量,
ifnull(x3.num,0) `总发布动态/文章数`,
ifnull(x4.num,0) `点赞评论收藏浏览 (合计)`
from `member`.tc_member_info tmi 
left join
	( 
	--# 车系
	 select v.member_id,
--	 v.vin_code,
	 count(1) 绑车数量,
	-- ifnull(m.MODEL_NAME,v.model_name)车型,
	 GROUP_CONCAT ( v.vin_code),
	 GROUP_CONCAT (v.model_name) 车型,
	 GROUP_CONCAT (tc2.config_name) 绑车车款
		 from (
		 select 
		 distinct 
		 v.MEMBER_ID,
		 v.series_code,
		 m.model_name,
		 v.vin_code
	--	 ,row_number() over(PARTITION by v.MEMBER_ID order by v.bind_date desc) rk
		 from volvo_cms.vehicle_bind_relation v 
		 left join basic_data.tm_model m on v.series_code=m.MODEL_CODE
		 where v.DELETED=0 
--		 and  v.member_id ='3107162'
		 ) v 
	 left join vehicle.tm_vehicle t on v.vin_code=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	 left join vehicle.tt_invoice_statistics_dms tisd on v.vin_code = tisd.vin 
	 left join basic_data.tm_config tc2 on tisd.config_code =tc2.config_code and tisd.config_id =tc2.id
--	 where v.member_id ='3107162'
	 group by 1
) t on tmi.id=t.member_id
	left join (
	-- 近一个月内发布帖子数量
		select a.member_id,count(a.post_id) num
		from community.tm_post a
		where 1=1
		and a.is_deleted =0
		and a.post_type in ('1001','1007')
		and a.create_time >='2024-04-13'
		and a.create_time <'2024-05-13'
		group by 1
order by 1)x1 on x1.member_id=tmi.id
	left join (
	-- 近3个月内发布帖子数量
		select a.member_id,count(a.post_id) num
		from community.tm_post a
		where 1=1
		and a.is_deleted =0
		and a.post_type in ('1001','1007')
		and a.create_time >='2024-02-13'
		and a.create_time <'2024-05-13'
		group by 1
order by 1)x2 on x2.member_id=tmi.id
	left join (
	-- 发帖数量
		select a.member_id,count(a.post_id) num
		from community.tm_post a
		where 1=1
		and a.is_deleted =0
		and a.post_type in ('1001','1007')
		and a.create_time <'2024-05-13'
		group by 1
order by 1)x3 on x3.member_id=tmi.id
	left join ( 
	-- 话题的活跃（发帖、浏览、互动）
	select 
	x.member_id,
	count(1) num 
	from 
	(
	-- 帖子的参与人数
		select 
		a.member_id
		from community.tm_post a 
		where 1=1
--		and a.create_time>='2024-04-01'
		and a.create_time<'2024-05-13'
		and a.is_deleted =0
		union all
	-- 话题的浏览
		select 
		a.member_id
		from community.tt_view_post a
		where 1=1
--		and a.create_time>='2024-04-01'
		and a.create_time<'2024-05-13'
		and a.is_deleted =0
		union all
	-- 点赞收藏
		select 
		c.member_id
		from community.tt_like_post c 
		where c.is_deleted =0
--		and c.create_time>='2024-04-01'
		and c.create_time<'2024-05-13'
		union all
	-- 评论
		select 
		a.member_id 
		from community.tm_comment a
		where a.is_deleted <>1
--		and a.create_time>='2024-04-01'
		and a.create_time<'2024-05-13'
	)x
	group by 1
	order by 2 desc 
)x4 on x4.member_id=tmi.id
where tmi.IS_DELETED =0 
and tmi.MEMBER_STATUS <>60341003
and tmi.id in ('3020265',
'3060449',
'3107162',
'3109228',
'3170481',
'3171338',
'3178017',
'3191978',
'3206898',
'3245818',
'3371239',
'3371339',
'3464061',
'3564393',
'3573687',
'3635049',
'3705552',
'3838309',
'3896455',
'4197346',
'4200357',
'4242525',
'4284642',
'4391577',
'4526871',
'4567614',
'4578836',
'4615072',
'4622300',
'4650140',
'4729968',
'4769741',
'5248582',
'5519304',
'5553857',
'5582566',
'5585650',
'5746963',
'6075440',
'6083309',
'6353181',
'6629553',
'6799984',
'7864306',
'8099280',
'3020766',
'3034054',
'3082108',
'3102573',
'3109228',
'3467395',
'3762552',
'3896455',
'4526871',
'4578836',
'5504764',
'5792346',
'5876308',
'6075440',
'6083309',
'6353181',
'7082909',
'7825719',
'8209910',
'3705552',
'3940470',
'3371339',
'5519304'
)
--and (t.车型 like '%T8%' 
--or t.车型='XC90')