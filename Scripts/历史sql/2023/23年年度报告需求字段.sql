-- 双端总注册用户数量 
	select 
	count(m.id) 注册数
	from member.tc_member_info m
	where m.member_status<>60341003 
	and m.is_deleted=0
	and m.create_time <'2024-01-01'

-- 总	
	select m.id
	,ifnull(x1.bind_date,0) 最近一次绑车时间
	,ifnull(x2.t,0) 最近一次养修预约提交日期
	,ifnull(x3.t,0) 最近一次养修到店日期
	,ifnull(x4.t,0) 最近一次邀请好友试驾日期
	,ifnull(x5.t,0) 最近一次线上预约试驾的日期
	,ifnull(x5.预约车型,0) 最近一次线上预约试驾的车型
	,ifnull(x6.t,0) EM90下订时间
	,ifnull(x7.t,0) 最近一次商城下单的时间
	,ifnull(x7.兑换商品,0) 最近一次商城下单的商品内容
	from member.tc_member_info m
	left join (
	--最近一次绑车时间
			select distinct a.member_id,
			a.vin_code,
			a.bind_date
			from (
				select a.member_id
				,a.vin_code
				,a.bind_date
				,b.model_name 拥车车型
				,row_number()over(partition by a.member_id order by a.bind_date desc) rk 
				from volvo_cms.vehicle_bind_relation a
				left join basic_data.tm_model b on a.series_code =b.model_code
				where a.deleted = 0
				and a.is_bind=1
				)a 
			where a.rk=1
			order by a.member_id
			)x1 on x1.member_id=m.id
		left join (
	-- 最近一次养修预约提交日期
			select x.ID,
--			x.one_id,
			date_format (x.创建时间,'%Y-%m-%d')  t -- 最近一次养修预约提交日期
			from 
				(
				select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
				       ta.APPOINTMENT_ID "预约ID",
				       tmi.ID,
				       ta.one_id ,
				       row_number ()over(partition by tmi.id order by tam.UPDATED_AT desc) rk ,
				       tam.VIN "车架号",
				       tam.CREATED_AT "创建时间",
				       tam.WORK_ORDER_NUMBER "工单号"
				from cyx_appointment.tt_appointment  ta
				left join cyx_appointment.tt_appointment_maintain tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
				left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
				where 1=1
				and ta.CREATED_AT >= '2023-01-01'
				and ta.CREATED_AT < '2024-01-01'
				and ta.APPOINTMENT_TYPE =70691005
				and ta.is_deleted =0
				and ta.one_id is not null 
				and tam.IS_DELETED =0
				and tmi.is_deleted = 0 
				and tmi.member_status <> '60341003'
				and tam.MAINTAIN_STATUS not in ('80671007','80671011','80671012') -- 剔除”取消“相关
--				and ta.one_id ='2643512'
				)x 
			where x.rk=1
			order by ID
			)x2 on x2.ID=m.id
	left join 
		(
--最近一次养修到店日期
		select x.id
		,date_format(x.ENTRY_TIME,'%Y-%m-%d')t
		from 
			(
			select d.OWNER_ONE_ID
			,m.id 
			,d.CREATED_AT
			,r.ENTRY_TIME -- 进厂时间 
			,row_number()over(partition by m.id order by r.ENTRY_TIME desc) rk 
			from cyx_appointment.tt_appointment a 
			left join cyx_appointment.tt_appointment_maintain d on a.appointment_id =d.appointment_id -- 预约表：取经销商
			left join member.tc_member_info m on m.cust_id =a.one_id
			left join cyx_repair.tt_repair_order r on r.RO_NO=d.WORK_ORDER_NUMBER and r.owner_code=a.owner_code  -- 工单表
			where a.one_id is not null
			and d.MAINTAIN_STATUS not in (80671007,80671011,80671012) --取消进厂,未确认,预约失败,超时取消
			and d.CREATED_AT>='2023-01-01'
			and d.CREATED_AT<'2024-01-01'
			and r.ENTRY_TIME>='2023-01-01'
			and r.ENTRY_TIME<'2024-01-01'
			and d.is_deleted=0
			and r.is_deleted =0
			and m.is_deleted = 0 
			and m.member_status <> '60341003'
			)x 
		where x.rk=1
		order by 1 
	)x3 on x3.id=m.id
	left join 
		(
--最近一次邀请好友试驾日期		
		select x.邀请人会员ID ID,
		date_format(x.留资时间,'%Y-%m-%d') t
		from 
			(
				select
				r.invite_member_id 邀请人会员ID,
				row_number ()over(partition by r.invite_member_id order by r.create_time desc )rk ,
				r.be_invite_member_id 被邀请人会员ID,
				r.create_time 留资时间
				from invite.tm_invite_record r
				where r.is_deleted = 0
				and r.create_time >= '2023-01-01'
				and r.create_time < '2024-01-01'
				order by r.create_time
			)x where x.rk=1
		order by id 
	) x4 on x4.id=m.id
	left join (
--最近一次线上预约试驾的日期	
		select 
		x.id,
		date_format(x.CREATED_AT,'%Y-%m-%d') t,
		x.预约车型
		from 
		(
			SELECT
			ta.APPOINTMENT_ID 预约ID,
			ta.one_id ,
			ta.CREATED_AT,
			tmi.id,
			tm2.MODEL_NAME 预约车型,
			row_number ()over(partition by tmi.id order by ta.created_at desc) rk 
			FROM cyx_appointment.tt_appointment ta
			left join "member".tc_member_info tmi on ta.one_id =tmi.cust_id 
			LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
			left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID 
			WHERE ta.CREATED_AT >= '2023-01-01'
			AND ta.CREATED_AT <'2024-01-01'
			AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
			and ta.is_deleted =0
			and tm2.IS_DELETED = 0
			and tmi.is_deleted = 0 and tmi.member_status <> '60341003'
			and tmi.id is not null 
			order by ta.CREATED_AT
			)x where x.rk=1
		order by id 
	)x5 on x5.id=m.id
	left join (
--EM90下订时间
			select
			tmi.id,
			date_format(a.created_at,'%Y-%m-%d')t
			FROM cyxdms_retail.tt_sales_orders  a
			left join cyxdms_retail.tt_sales_order_vin  b on a.`so_no`  = b.`vi_no` 
			left join cyxdms_retail.tt_sales_order_detail c on c.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
			left join "member".tc_member_info tmi on a.customer_tel =tmi.member_phone and tmi.is_deleted = 0 and tmi.member_status <> '60341003'
			WHERE b.`sale_type` = 20131010
--			and a.`so_status` in (14041001,14041002,14041003,14041008,14041030)
--			and a.`is_deposit` in (10421009,10041001,10041002,70961001,70961002)
			and c.second_id = '1111'    -- basic_data里面的id，对应EM90
			and a.created_at >= '2023-01-01'      
			and a.created_at < '2024-01-01'
			and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
			and a.`is_deleted` ='0'
			and b.`is_deleted` ='0'
			and tmi.id is not null 
			order by 1
		)x6 on x6.id=m.id
	left join (
--最近一次商城下单的时间
		select 
		x.id,
		x.兑换商品,
		date_format(x.create_time,'%Y-%m-%d')t
		from 
			(select 
			a.user_id id
			,a.order_code
			,a.create_time
			,b.spu_name 兑换商品
			,row_number ()over(partition by a.user_id order by a.create_time desc,b.product_id ) rk
			from "order".tt_order a  -- 订单主表
			left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
			where 1=1
			and a.create_time >= '2023-01-01' and a.create_time <'2024-01-01'
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			order by a.create_time)x where x.rk=1
			order by 1
		)x7 on x7.id=m.id
	where 1=1
	and m.member_status<>60341003 
	and m.is_deleted=0
	and m.create_time <'2024-01-01'
	order by 2 desc 
	
--最近一次绑车时间
--最近一次养修预约提交日期
--最近一次养修到店日期
--最近一次邀请好友试驾日期
--最近一次线上预约试驾的日期
--最近一次线上预约试驾的车型	
--EM90下订时间
--最近一次商城下单的时间
--最近一次商城下单的商品内容
--用户昵称&注册时间&陪伴时间
	select 
	m.id,
	m.member_name 用户昵称,
	date_format(m.create_time,'%Y-%m-%d')注册时间,
	datediff('2023-12-31',m.create_time) 陪伴时间
	from member.tc_member_info m
	where m.member_status<>60341003 
	and m.is_deleted=0
	and m.create_time <'2024-01-01'
	
--累计签到天数
select a.MEMBER_ID
,count(1)
from (
	select DISTINCT i.MEMBER_ID,
	i.create_time  日期
	from mms.tt_sign_in_record i 
	join member.tc_member_info m on i.member_id=m.id-- and m.is_vehicle=1
	where 1=1
	and i.is_deleted=0 
	and m.is_deleted=0 and m.member_status<>60341003 
	and i.create_time < '2026-01-01'
	and i.create_time >= '2024-01-01'
) a 
GROUP BY 1
order by 2 desc 

select *
FROM mms.tt_sign_in_record a  -- 签到表
where a.member_id='5777167'

--连续签到天数
select x.member_id,
max(x.num) 连续签到天数
from 
(
	SELECT 
	d.member_id,
	d.连续签到,
	COUNT(*) num
	from (
		SELECT c.*,c.date_ - c.qd_rank 连续签到
		FROM(
				select a.member_id,
				a.create_time,
				ROW_NUMBER() over(PARTITION by a.member_id ORDER by a.create_time) qd_rank,
				DATE(a.create_time)-'1999-01-01' date_
				FROM mms.tt_sign_in_record a  -- 签到表
				left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
				WHERE a.create_time >= '2023-01-01' 
				and  a.create_time<'2024-01-01'  -- 每月的时间
				and a.is_deleted = 0) c 
			)d 
	group by 1,2
	order by 1 
)x
group by 1 
order by 2 desc 

--最晚登录时间
select x.id,
x.tt
from 
	(
	select id,
	tt,
	row_number()over(partition by id order by 
			case when toHour(tt)>=21 and toHour(tt)<=24 then concat(toString('2023-01-01'),substring(toString(tt),11,18))
				when toHour(tt)<=5 and toHour(tt)>=0 then concat(toString('2023-01-02'),substring(toString(tt),11,18)) end as lt 
				desc)rk
	from (
				-- 小程序
				select distinct toString(m.cust_id) id,toDate(t.`date`) t,toDateTime(date) tt
				from ods_trac.ods_trac_track_cur t
				left join ods_memb.ods_memb_tc_member_info_cur m on toString(t.usertag)=toString(m.user_id) 
				where t<'2024-01-01'
				and t>='2023-01-01'
				and id is not null 
				union all
				-- APP
				select distinct toString(e.distinct_id) id,toDate(e.date) t,toDateTime(time)tt
				from ods_rawd.ods_rawd_events_d_di e 
				where length(e.distinct_id)<=9
				and (($lib in('MiniProgram') or channel ='Mini') or (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App'))
				and t<'2024-01-01'
				and t>='2023-01-01' 
				and id is not null )
	where 1=1
	and (toHour(tt)>=21 or toHour(tt)<=5)
	and id not like '%#%'
	Settings allow_experimental_window_functions = 1)x
where x.rk=1

--身份标签-所属俱乐部
select
	b.member_id ,
	group_concat(a.content) 俱乐部
from community_club.tt_club_attr_audit a
left join community_club.tr_club_friends b 
on a.club_id  = b.club_id and b.is_deleted = 0
where to_date(b.create_time)>= '2023-01-01' 
and to_date(b.create_time)<'2024-01-01'
and a.attr_type  = '10010'--俱乐部信息 10010俱乐部名称
and a.is_deleted = 0
and a.audit_status = '10030'--审核状态 已通过
group by 1
--order by 1 
order by length(俱乐部) desc 

--身份标签-特殊成就

--勋章成就
select 
c.user_id 会员ID,
group_concat(e.medal_name) num 
from mine.madal_detail c
left join `member`.tc_member_info d on d.ID = c.user_id and d.is_deleted = 0 and d.member_status <> '60341003'
left join mine.user_medal e on e.id = c.medal_id
where c.create_time < '2024-01-01'
and c.create_time >= '2023-01-01'
and c.deleted = 1  -- 有效
and c.status = 1  -- 正常
group by 1
order by 1


--最高互动内容的点赞量&最高互动内容的发布时间
select tp.member_id,
tp.post_id ,
tp.create_time ,
max(ifnull(x.点赞,0))
from community.tm_post tp 
left join (
	select
	a.post_id,
	count(a.member_id) 点赞
	from community.tt_like_post a
	where a.is_deleted <>1
	and a.like_type=0
	and a.create_time >='2023-01-01'
	and a.create_time <'2024-01-01'
	group by 1
	) x on x.post_id=tp.post_id
where tp.is_deleted =0
and tp.post_type in ('1001','1007')
group by 1
order by 4 desc 

-- 打开充电地图次数
	select distinct_id,
	count(1) num 
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event in ('$AppViewScreen','$MPViewScreen')
	and length(distinct_id)<9 
	and date>='2023-01-01'
	and date<'2024-01-01'
	and (`$screen_name` ='充电地图首页' or `$title` ='充电地图首页')
	group by distinct_id
	order by num desc 

--使用远程车控天数（包括空调启动、开关锁等）
	select distinct_id
	,COUNT(DISTINCT date) AS num
	from ods_rawd.ods_rawd_events_d_di
	where event='$AppClick' 
	and (($lib='iOS' 
	  and $element_path='UIView/VocKit.HomeSideView[0]/UITableView[0]/VocKit.HomeSideViewCell[0][-]'
	  and $element_position in ('0:0','0:1','0:2','0:3')
	  and $screen_name ='Volvo_Cars.ChinaHomeContainerViewController')
	or ($lib='Android' 
	  and $element_path='android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.appcompat.widget.FitWindowsLinearLayout[0]/androidx.appcompat.widget.ContentFrameLayout[0]/android.widget.RelativeLayout[0]/android.widget.LinearLayout[1]/android.widget.RelativeLayout[0]/android.widget.FrameLayout[0]/se.volvo.vcc.ui.fragments.root.MyCarRootFragment[0]/android.widget.LinearLayout[0]/android.widget.FrameLayout[0]/androidx.viewpager2.widget.ViewPager2[0]/androidx.viewpager2.widget.ViewPager2.RecyclerViewImpl[0]/android.widget.FrameLayout[0]/androidx.constraintlayout.widget.ConstraintLayout[0]/se.volvo.vcc.ui.fragments.hometab.home.HomeMotionLayout[0]/androidx.recyclerview.widget.RecyclerView[0]/androidx.constraintlayout.widget.ConstraintLayout[-]'
	  and $element_position in ('0','1','2','3')
	  and $screen_name like '%se.volvo.vcc.ui.activities.navigation.tabsnavigation.BottomTabsActivity|se.volvo.vcc.ui.fragments.hometab.home.HomeFragment%'))
	and length(distinct_id)<9
	and date<'2024-01-01'
	and date>='2023-01-01'
	GROUP BY distinct_id