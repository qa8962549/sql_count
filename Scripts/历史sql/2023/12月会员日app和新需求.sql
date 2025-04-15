-- 12月会员日 PVUV   ('memberDay12_home_onload','memberDay12_home_miniProgram_onload','memberDay12_home_app_onload')

-- 2、沃世界会员日活动PV UV
select 
-- DATE(a.date)
count(case when a.事件='01 活动首页' then a.usertag else null end) 'PV活动首页'
,count(DISTINCT case when a.事件='01 活动首页' then a.usertag else null end) 'UV活动首页'
,count(DISTINCT case when a.事件='02 点击订阅本活动' then a.usertag else null end) '活动订阅人数'
-- ,count(case when a.事件='03 前往抽奖页面' then a.usertag else null end) 'PV前往抽奖页面'
-- ,count(DISTINCT case when a.事件='03 前往抽奖页面' then a.usertag else null end) 'UV前往抽奖页面'
from (
	SELECT 
	case when json_extract(t.`data`,'$.embeddedpoint') in('memberDay12_home_onload','memberDay12_home_miniProgram_onload') then '01 活动首页'
	when json_extract(t.`data`,'$.embeddedpoint') = 'memberDay12_订阅_click' then '02 点击订阅本活动'
-- 	when json_extract(t.`data`,'$.embeddedpoint') = 'memberDay12_开启好运大转盘_click' then '03 前往抽奖页面'
	else null end '事件'
	,t.usertag
	,t.date
	from track.track t 
	where t.date between '2022-12-01' and '2022-12-25 23:59:59'
) a 
where a.事件 is not null 

select 
count(user_id) PV,
count(distinct user_id) UV
from events 
where event='Page_view' 
and page_title ='12月会员日' 
and time between '2022-12-01' and '2022-12-31'

-- 活动订阅人数
select count(distinct user_id) 
from events
where event='Button_click'
and page_title ='12月会员日'
and btn_name='订阅本活动'
and time between '2022-12-01' and '2022-12-31'

-- 累计拆盲盒 累计参与拆礼盒小于5天人数
select count(case when x.xx<=5 then 1 end)'累计参与拆礼盒小于等于5天人数'
,count(case when x.xx>5 then 1 end)'累计参与拆礼盒大于5天人数'
,count(case when x.xx>10 then 1 end)'累计参与拆礼盒大于10天人数'
,count(case when x.xx>20 then 1 end)'累计参与拆礼盒大于20天人数'
,count(case when x.xx=25 then 1 end)'累计参与拆礼盒达到25天人数'
from 
	(
	#统计点击按钮数量的用户
	select x.tt,
	count(1) xx
	from 
		(
		#取出点击按钮的用户并去重
		SELECT 
		DISTINCT t.usertag tt,
		json_extract(t.`data`,'$.embeddedpoint')
		from track.track t 
		where t.`date` >='2022-12-01'
		and t.`date` <='2022-12-25 23:59:59'
		and json_extract(t.`data`,'$.embeddedpoint') like '%memberDay12_抽礼盒日历%'
		-- and t.usertag ='6039075'
	)x 
	group by 1
	order by 2 desc 
)x 

-- 许愿币投入总数
select sum(a.used_wish_coins)
from volvo_online_activity.tm_member_day_wish_pool a
where a.is_deleted =0
and a.create_time >='2022-12-01'
and a.create_time <='2022-12-25 23:59:59'

-- 符合许愿资格人数
select count(x.tt)
from 
	(
	#统计点击按钮数量的用户
	select x.tt,
	count(1) xx
	from 
		(
		#取出点击按钮的用户并去重
		SELECT 
		DISTINCT t.usertag tt,
		json_extract(t.`data`,'$.embeddedpoint')
		from track.track t 
		where t.`date` >='2022-12-01'
		and t.`date` <='2022-12-25 23:59:59'
		and json_extract(t.`data`,'$.embeddedpoint') like '%memberDay12_抽礼盒日历%'
		-- and t.usertag ='6039075'
	)x 
	group by 1
	order by 2 desc 
)x where x.xx>=10

-- 许愿成功次数
-- 许愿成功人数
select 
count(t.usertag) 次数,
count(DISTINCT t.usertag)人数
-- json_extract(t.`data`,'$.embeddedpoint')
from track.track t 
where t.`date` >='2022-12-01'
and t.`date` <='2022-12-25 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint') like '%memberDay12_确认投币_click%'

-- 前100名用户许愿币总数
select sum(x.tt)
from 
(
select a.used_wish_coins tt
from volvo_online_activity.tm_member_day_wish_pool a
where a.is_deleted =0
and a.create_time >='2022-12-01'
and a.create_time <='2022-12-25 23:59:59'
order by a.used_wish_coins desc 
limit 100
)x

-- 获得WOW辈楷模电子勋章的人数
-- 获得WOW辈翘楚电子勋章的人数
select 
case when m.勋章名称 = 'WOW辈楷模' then '01 WOW辈楷模'
	when m.勋章名称 = 'WOW辈翘楚' then '02 WOW辈翘楚' end 所属板块,
COUNT(m.会员ID)勋章发放数量  from
(
select distinct
c.user_id 会员ID,
f.LEVEL_NAME 会员等级,
c.medal_id 勋章ID,
e.`type` 勋章类型编码,
g.type_name 所属板块,
e.medal_name 勋章名称,
c.create_time 勋章获得时间
from mine.madal_detail c
left join `member`.tc_member_info d on d.ID = c.user_id
left join mine.user_medal e on e.id = c.medal_id
left join `member`.tc_level f on f.LEVEL_CODE = d.MEMBER_LEVEL
left join mine.my_medal_type g on e.`type` = g.union_code
where c.create_time <= '2023-01-02 23:59:59'
and c.deleted = 1  -- 有效
and c.status = 1  -- 正常
)m
group by 1
order by 1


-- 通过12月会员日发帖人数
-- 通过12月会员日发帖数量
select 
count(DISTINCT a.member_id) 通过12月会员日发帖人数,
count(DISTINCT a.id) 通过12月会员日发帖数量
from track.track t 
left join `member`.tc_member_info m on cast(m.USER_ID as varchar)=t.usertag 
left join community.tm_post a on a.member_id =m.id 
where a.is_deleted =0 
and a.create_time >='2022-12-01' 
and a.create_time <='2023-01-02 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint') like '%memberDay12_前往发帖_click%' 
and a.create_time >=t.`date` 


-- 连续参加12次会员日活动活动累计留存人数
-- 活动等级会员占比（银卡及以上）等级会员参与度


-- 26、中奖信息(这里需要匹配两次,一次是匹配用户自己填写的最新默认收货地址，一次是匹配用户中奖之后填写的收货地址)
select
a.member_id,
a.nick_name 姓名,
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
x.收货人姓名 默认收货人姓名,
x.收货人手机号 默认收货人手机号,
x.收货地址 默认收货地址,
c.收货人手机号 中奖之后填写收货手机号,
c.收货人姓名 中奖之后填写收货人姓名,
c.收货地址 中奖之后填写收货地址
from volvo_online_activity_module.lottery_draw_log a
left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
left join
(select
c.lottery_play_code,
c.会员ID,
c.收货人姓名,
c.收货人手机号,
c.填写收货地址时间,
c.收货地址
from
 (select c.lottery_play_code,c.会员ID,c.收货人姓名,c.收货人手机号,c.填写收货地址时间,c.收货地址,row_number() over(partition by c.收货地址 order by c.填写收货地址时间 desc) rk
 from
  (
   select
   lai.lottery_play_code,
   lai.member_id 会员ID,
   lai.addressee 收货人姓名,
   lai.phone 收货人手机号,
   lai.create_time 填写收货地址时间,
   CONCAT(ifnull(lai.province_name,""),ifnull(lai.city_name,""),ifnull(lai.area_name,""),ifnull(lai.street,""),ifnull(lai.other_address,""))收货地址
   from volvo_online_activity_module.lottery_addressee_info lai
   where lai.is_delete = 0
   order by lai.member_id
  )c
)c where c.rk = 1) c on left(a.lottery_play_code,17) = c.lottery_play_code and a.member_id = c.会员ID
left join `member`.tc_member_info d on a.member_id = d.ID
left join 
	(select 
	tma.MEMBER_ID 会员ID,
	tma.CONSIGNEE_NAME 收货人姓名,
	tma.CONSIGNEE_PHONE 收货人手机号,
	CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址
	from `member`.tc_member_address tma
	left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
	left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
	left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
	where tma.IS_DELETED = 0
	and tma.IS_DEFAULT = 1  )x -- s默认收货地址
	on a.member_id =x.会员ID
where a.lottery_play_code like '%member_day_202212%'  -- 12月会员日code
and a.have_win = 1   -- 中奖
order by a.create_time


-- 许愿池-用户许愿成功详情（12月26日拉取）
select a.member_id 
,m.REAL_NAME 姓名
,m.MEMBER_PHONE 沃尔沃汽车APP注册手机号
,m.MEMBER_C_NUM 成长值
,a.used_wish_coins/a.wish_count '投入许愿币数量/每次'
,'' 投入许愿币的时间
,a.used_wish_coins 投入许愿币总数
,x.收货人姓名 默认收货人姓名
,x.收货人手机号 默认收货人手机号
,x.收货地址 默认收货地址
,c.收货人手机号 中奖之后填写收货手机号
,c.收货人姓名 中奖之后填写收货人姓名
,c.收货地址 中奖之后填写收货地址
from volvo_online_activity.tm_member_day_wish_pool a
left join `member`.tc_member_info m on a.member_id =m.ID 
left join
(select
c.lottery_play_code,
c.会员ID,
c.收货人姓名,
c.收货人手机号,
c.填写收货地址时间,
c.收货地址
from
 (select c.lottery_play_code,c.会员ID,c.收货人姓名,c.收货人手机号,c.填写收货地址时间,c.收货地址,row_number() over(partition by c.会员ID order by c.填写收货地址时间 desc) rk
 from
  (
   select
   lai.lottery_play_code,
   lai.member_id 会员ID,
   lai.addressee 收货人姓名,
   lai.phone 收货人手机号,
   lai.create_time 填写收货地址时间,
   CONCAT(ifnull(lai.province_name,""),ifnull(lai.city_name,""),ifnull(lai.area_name,""),ifnull(lai.street,""),ifnull(lai.other_address,""))收货地址
   from volvo_online_activity_module.lottery_addressee_info lai
   where lai.is_delete = 0
   and lai.lottery_play_code='member_day_202212'
   order by lai.member_id
  )c
)c where c.rk = 1) c on a.member_id = c.会员ID
left join 
	(select 
	tma.MEMBER_ID 会员ID,
	tma.CONSIGNEE_NAME 收货人姓名,
	tma.CONSIGNEE_PHONE 收货人手机号,
	CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址
	from `member`.tc_member_address tma
	left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
	left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
	left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
	where tma.IS_DELETED = 0
	and tma.IS_DEFAULT = 1  )x -- s默认收货地址
	on a.member_id =x.会员ID
where m.IS_DELETED =0
and a.is_deleted =0
order by a.used_wish_coins desc 


-- 用户发帖详情（1月3日拉取）
select 
a.member_id 会员ID,
tmi.REAL_NAME 姓名,
'#沃尔沃会员日#' 发帖tag,
a.post_digest 正文内容,
a.like_count 点赞数,
a.collect_count 收藏数,
a.read_count 浏览量,
x.收货人姓名 默认收货人姓名,
x.收货人手机号 默认收货人手机号,
x.收货地址 默认收货地址,
c.收货人手机号 中奖之后填写收货手机号,
c.收货人姓名 中奖之后填写收货人姓名,
c.收货地址 中奖之后填写收货地址
from community.tm_post a
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join 
	(
	select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
	(
	select 
	tma.MEMBER_ID,
	tma.CONSIGNEE_NAME 收货人姓名,
	tma.CONSIGNEE_PHONE 收货人手机号,
	CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址,
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
(select
c.lottery_play_code,
c.会员ID,
c.收货人姓名,
c.收货人手机号,
c.填写收货地址时间,
c.收货地址
from
 (select c.lottery_play_code,c.会员ID,c.收货人姓名,c.收货人手机号,c.填写收货地址时间,c.收货地址,row_number() over(partition by c.会员ID order by c.填写收货地址时间 desc) rk
 from
  (
   select
   lai.lottery_play_code,
   lai.member_id 会员ID,
   lai.addressee 收货人姓名,
   lai.phone 收货人手机号,
   lai.create_time 填写收货地址时间,
   CONCAT(ifnull(lai.province_name,""),ifnull(lai.city_name,""),ifnull(lai.area_name,""),ifnull(lai.street,""),ifnull(lai.other_address,""))收货地址
   from volvo_online_activity_module.lottery_addressee_info lai
   where lai.is_delete = 0
   and lai.lottery_play_code='member_day_202212'
   order by lai.member_id
  )c
)c where c.rk = 1) c on a.member_id = c.会员ID
where a.is_deleted ='0'
and a.create_time >='2022-11-03' 
and a.create_time <'2023-01-03'
and a.post_digest like '%#沃尔沃会员日#%' 

