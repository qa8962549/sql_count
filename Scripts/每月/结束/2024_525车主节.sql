	select *
	from volvo_online_activity_module.lottery_play_init a
	order by a.create_time  desc 


-- 2-5【会员抽奖】抽奖明细
	select
	a.member_id,
	a.nick_name 姓名,
	case when d.is_vehicle =1 then '是' 
		 when d.is_vehicle =0 then '否' 
		 end as 是否车主,
	case when d.level_id=1 then '银卡'
		 when d.level_id=2 then '金卡'
		 when d.level_id=3 then '白金卡'
		 when d.level_id=4 then '黑卡'
		 end as 会员等级,
	d.MEMBER_PHONE 沃世界注册手机号,
	case when a.have_win = '1' then '中奖'
		when a.have_win = '0' then '未中奖'
		end 是否中奖,
	case when a.have_send = '1' then '已发放'
		when a.have_send = '0' then '未发放'
		end 奖品是否发放,
	a.create_time 抽奖时间,
	b.prize_name 中奖奖品,
	b.prize_level_nick_name 奖品等级,
	hour(a.create_time)  时段,
	a.lottery_play_code 抽奖code,
	lpi.lottery_play_name 奖池名称,
	case
		when d.level_id=1 then '银卡'
		when d.level_id>=2 then '金卡及以上'
	end as 会员等级2,
	b.is_deleted
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code 
	left join volvo_online_activity_module.lottery_play_init lpi on lpi.lottery_play_code =a.lottery_play_code 
	left join `member`.tc_member_info d on a.member_id = d.ID
	where 1=1
	and a.lottery_code like 'activity525-2024'  -- 当月会员日code
	and date(a.create_time)>='2024-05-15'
	and date(a.create_time)<'2024-06-01'
	and a.have_win = 1   -- 中奖
	and b.is_deleted =0
--	and b.prize_type='article'
	--and prize_name like '%2024%'
	order by a.create_time desc 

	select *
	from volvo_online_activity_module.lottery_play_pool a
	

-- 2-6【会员抽奖】瓜分V值明细
select 
--date(x.参与瓜分时间),
x.是否车主,
count(distinct x.member_id)
from 
	(
	select 
	tmdva.member_id ,
	--tmi.member_name 会员昵称,
	case tmi.is_vehicle when 1 then '是' when 0 then '否' end 是否车主,
	t.车型,
	date_part('year',curdate()) -date_part('year',tisd.invoice_date) 车龄,
	--datediff(year,curdate(),tisd.invoice_date), -- 绑车时间三年内
	--tisd.invoice_date,
	case tmi.level_id when 1 then '银卡' when 2 then '金卡' when 3 then '白金卡' when 4 then '黑卡' end 会员等级,
	--tmi.member_phone 沃世界手机号,
	tmi.create_time 注册时间,
	tmdva.create_time 参与瓜分时间
	FROM volvo_online_activity.tm_member_day_vvalue_activity tmdva 
	left join "member".tc_member_info tmi on tmi.id =tmdva.member_id and tmi.is_deleted=0
	left join
		( 	
		--# 车系
		 select v.member_id,v.vin_code,ifnull(m.MODEL_NAME,v.model_name)车型
		 from (
		 select v.MEMBER_ID,v.series_code,m.model_name,v.vin_code
		 ,row_number() over(PARTITION by v.MEMBER_ID order by v.bind_date desc) rk
		 from volvo_cms.vehicle_bind_relation v 
		 left join basic_data.tm_model m on v.series_code=m.MODEL_CODE
		 where v.DELETED=0 
		 ) v 
		 left join vehicle.tm_vehicle t on v.vin_code=t.VIN
		 left join basic_data.tm_model m on t.MODEL_ID=m.ID
		 where v.rk=1
	) t on tmi.id=t.member_id
	left join vehicle.tt_invoice_statistics_dms tisd on t.vin_code=tisd.vin and tisd.IS_DELETED =0  -- 与发票表关联
	where 1=1
	and (code = 'activity525-2024') 
	and tmdva.create_time>='2024-05-15'
	and tmdva.create_time<'2024-05-26'
	AND (tmdva.is_deleted = 0) )x 
	group by rollup(1)
	order by 1

--瓜分V值
select 
x.是否车主,
--date(x.create_time) as date,
sum(x.integral ) as V值数额
from 
(
select tmdva.member_id ,
	tmi.member_name 会员昵称,
	case tmi.is_vehicle when 1 then '是' when 0 then '否' end 是否车主,
	case tmi.level_id when 1 then '银卡' when 2 then '金卡' when 3 then '白金卡' when 4 then '黑卡' end 会员等级,
	tmi.member_phone 沃世界手机号,
	tmdva.create_time ,
	b.create_time,
	b.integral ,
	b.record_type,
	b.event_desc
FROM volvo_online_activity.tm_member_day_vvalue_activity tmdva 
left join "member".tc_member_info tmi on tmi.id =tmdva.member_id and tmi.is_deleted=0
left join member.tt_member_flow_record b on tmi.id= b.member_id 
where 1=1
and (code = 'activity525-2024') 
AND tmdva.is_deleted = 0
and tmdva.is_send ='1' --是否发放
and b.event_desc ='会员日瓜分V值活动奖励'
and b.record_type='0' --V值新增
and date(b.create_time)>='2024-05-15'
and date(b.create_time)<'2024-06-01'
and tmdva.create_time>='2024-05-15'
and tmdva.create_time<'2024-05-26'
--and tmdva.member_id='3017574'
--and tmi.member_phone ='15023578159'
)x
group by rollup(1)
order by 1
	
-- 瓜分明细
select 
tmdva.member_id ,
--tmi.member_name 会员昵称,
case tmi.is_vehicle when 1 then '是' when 0 then '否' end 是否车主,
t.车型,
date_part('year',curdate()) -date_part('year',tisd.invoice_date) 车龄,
--datediff(year,curdate(),tisd.invoice_date), -- 绑车时间三年内
--tisd.invoice_date,
case tmi.level_id when 1 then '银卡' when 2 then '金卡' when 3 then '白金卡' when 4 then '黑卡' end 会员等级,
--tmi.member_phone 沃世界手机号,
tmi.create_time 注册时间,
tmdva.create_time 参与瓜分时间,
b.create_time V值到账时间
FROM volvo_online_activity.tm_member_day_vvalue_activity tmdva 
left join "member".tc_member_info tmi on tmi.id =tmdva.member_id and tmi.is_deleted=0
left join
	( 	
	--# 车系
	 select v.member_id,v.vin_code,ifnull(m.MODEL_NAME,v.model_name)车型
	 from (
	 select v.MEMBER_ID,v.series_code,m.model_name,v.vin_code
	 ,row_number() over(PARTITION by v.MEMBER_ID order by v.bind_date desc) rk
	 from volvo_cms.vehicle_bind_relation v 
	 left join basic_data.tm_model m on v.series_code=m.MODEL_CODE
	 where v.DELETED=0 
	 ) v 
	 left join vehicle.tm_vehicle t on v.vin_code=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	 where v.rk=1
) t on tmi.id=t.member_id
left join vehicle.tt_invoice_statistics_dms tisd on t.vin_code=tisd.vin and tisd.IS_DELETED =0  -- 与发票表关联
	left join (
	select b.*
	from member.tt_member_flow_record b
	where 1=1
	and b.event_desc ='会员日瓜分V值活动奖励'
	and b.record_type='0' --V值新增
	and date(b.create_time)>='2024-05-15'
	and date(b.create_time)<'2024-06-01')b on tmi.id= b.member_id 
where 1=1
and (code = 'activity525-2024') 
and tmdva.create_time>='2024-05-15'
and tmdva.create_time<'2024-05-26'
AND (tmdva.is_deleted = 0)	
		
--活动期间经销商code的pv、uv
SELECT 
substring(extract($url,'promotion_channel_sub_type=[A-Za-z][A-Za-z][A-Za-z]'),28,30) tt,
--extract($url,'promotion_channel_sub_type=[A-Za-z][A-Za-z][A-Za-z]'),
count(distinct_id) PV,
count(distinct distinct_id) UV
--$url
from dwd_23.dwd_23_gio_tracking
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Page_entry'
and page_title='525车主节'
and var_activity_name='2024年5月525车主节'
and `$url` like '%promotion_channel_type=dealer%'
--and length(distinct_id)<9
group by 1
order by 2 desc 

--活动期间首次访问活动页
select 
	tt,
--	count(gio_id) pv,
	count(distinct distinct_id) uv
from (
  select x.distinct_id
  ,x.tt
  from (
    select distinct_id
    ,tt
    ,row_number() over(partition by distinct_id order by `time`) as rk
	from (SELECT 
		substring(extract($url,'promotion_channel_sub_type=[A-Za-z][A-Za-z][A-Za-z]'),28,30) tt,
		distinct_id,
		time
		--$url
		from dwd_23.dwd_23_gio_tracking
		where 1=1
		and date >='2024-05-15'
		and date <'2024-06-01'
		and event='Page_entry'
		and page_title='525车主节'
		and var_activity_name='2024年5月525车主节'
		and `$url` like '%promotion_channel_type=dealer%' )	
  ) x
  where x.rk=1
) basic2
where 1=1
group by tt
order by uv desc 


-- 2-8【会员抽奖】页面数据
SELECT 
btn_name ,
count(gio_id) PV,
count(distinct distinct_id) UV,
count(case when var_is_bind='true' then distinct_id else null end) `车主PV`,
count(distinct case when var_is_bind='true' then distinct_id else null end) `车主UV`,
count(case when var_is_bind='false' then distinct_id else null end) `粉丝PV`,
count(distinct case when var_is_bind='false' then distinct_id else null end) `粉丝UV`
from dwd_23.dwd_23_gio_tracking
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Button_click'
and page_title='525车主节·会员权益'
and var_activity_name='2024年5月525车主节'
and ((`$lib` in('iOS','Android','HarmonyOS','MiniProgram') and left(`$client_version`,1)='5') or channel in ('Mini', 'App'))
--and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- app
--and (`$lib` ='MiniProgram' or  channel ='Mini') -- mini
group by 1 
order by 1

sELECT 
btn_name ,
var_is_bind,
distinct_id
from dwd_23.dwd_23_gio_tracking
where 1=1
and date >='2024-05-15'
and date <'2024-06-01'
and event='Button_click'
and page_title='525车主节·会员权益'
and var_activity_name='2024年5月525车主节'
and ((`$lib` in('iOS','Android','HarmonyOS','MiniProgram') and left(`$client_version`,1)='5') or in ('Mini', 'App'))

-- banner 点击
select 
--btn_name ,
count(distinct_id) PV,
count(distinct distinct_id) UV,
count(case when var_is_bind='true' then distinct_id else null end) `车主PV`,
count(distinct case when var_is_bind='true' then distinct_id else null end) `车主UV`,
count(case when var_is_bind='false' then distinct_id else null end) `粉丝PV`,
count(distinct case when var_is_bind='false' then distinct_id else null end) `粉丝UV`
from dwd_23.dwd_23_gio_tracking
where 1=1
--and event='$MPViewScreen'
and event='Button_click'
and `$url` like '%promotion_methods=app_banner%'
and `$url` like '%promotion_activity=20240428_member_equity%'
and `$url` like '%promotion_supplement=a5%'
--and `$url` like'%servicecenter_autoreply%'
--and `$url` like '%EX90%'
and date >='2024-05-15'
and date <'2024-06-01'

-- banner 点击
select 
--btn_name ,
count(distinct_id) PV,
count(distinct distinct_id) UV,
count(case when var_is_bind='true' then distinct_id else null end) `车主PV`,
count(distinct case when var_is_bind='true' then distinct_id else null end) `车主UV`,
count(case when var_is_bind='false' then distinct_id else null end) `粉丝PV`,
count(distinct case when var_is_bind='false' then distinct_id else null end) `粉丝UV`
from dwd_23.dwd_23_gio_tracking
where 1=1
--and event='$MPViewScreen'
--and event='Button_click'
and `$url` like '%https://newbie.digitalvolvo.com/onlineactivity/memberday-2404/index.html#/memberday/collection%'
--and `$url` like'%servicecenter_autoreply%'
--and `$url` like '%EX90%'
and date >='2024-05-15'
and date <'2024-06-01'