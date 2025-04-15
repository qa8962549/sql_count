--答题页面PVUV
	select 
	date,
	count(a.user_id) PV,
	count(distinct a.user_id) UV
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Page_entry'
	and length(distinct_id)<9 
	and date>='2023-10-31'
	and date<'2023-11-12'
--	and page_title ='WOW商城·双11'
	and page_title='参与答题 抢兑好礼'
	and content_title='每日答题赢奖励'
--	and activity_name='2023年双十一活动'
--	and subtitle_name='WOW智识派'
--	and subtitle_name='WOW运动咖'
--	and subtitle_name='WOW乐享家'
	group by `date` 
	order by `date` 
	
--当日答题人数累计 （点击“提交答案”按钮人数）
	select 
	date,
--	count(a.user_id) PV,
	count(distinct a.user_id) UV
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Button_click'
	and length(distinct_id)<9 
	and date>='2023-10-31'
	and date<'2023-11-12'
	and page_title='参与答题 抢兑好礼'
	and btn_name='提交答案'
	group by `date` 
	order by `date` 

--	累计答题数
select x.num num,
count(distinct x.id) num2
from 
(
	select 
	distinct_id as id,
	count(distinct `date`) num
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Button_click'
	and length(distinct_id)<9 
	and date>='2023-10-31'
	and date<'2023-11-12'
	and page_title='参与答题 抢兑好礼'
	and btn_name='提交答案'
--	and is_bind='1'
	and is_bind='0'
	group by distinct_id
	order by num desc 
)x 
group by num
order by num
	
-- 当轮兑奖人数
select 
x.中奖奖品,
--x.is_vehicle,
count(distinct x.member_id)
from 
	(
	select
	a.member_id,
	a.nick_name 姓名,
	d.is_vehicle,
	d.MEMBER_PHONE 沃世界注册手机号,
	case when a.have_win = '1' then '中奖'
		when a.have_win = '0' then '未中奖'
		end 是否中奖,
	case when a.have_send = '1' then '已发放'
		when a.have_send = '0' then '未发放'
		end 奖品是否发放,
	a.create_time 抽奖时间,
	b.prize_name 中奖奖品,
	a.create_time,
	b.prize_level_nick_name 奖品等级
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	left join `member`.tc_member_info d on a.member_id = d.ID
	where a.lottery_code = 'double_eleven_2023'  -- 双十一
	and a.lottery_play_code in
	(
		'double_eleven_2023_1',
		'double_eleven_2023_2',
		'double_eleven_2023_3',
		'double_eleven_2023_4',
		'double_eleven_2023_5',
		'double_eleven_2023_6'
	)
	and a.have_win = 1   -- 中奖
	and a.create_time>='2023-11-04'
	and a.create_time <'2023-11-08'
	order by a.create_time
)x 
--where 
--x.中奖奖品 in ('轻便电脑双肩包','舒享生活-便携舒适护颈枕','单读图书专属主题套餐兑换券','发动机舱养护服务8折优惠券','100度充电权益免费兑换券','精品满100元减30元优惠券')--  WOW智识派_最佳答人奖池
--or x.中奖奖品 in ('LEUCHTTURM灯塔笔记本','金属商务深色宝珠笔','城市森林-超纤皮折叠眼镜盒','100度充电权益5元优惠券','精品满200元减20元优惠券','售后满300元减30元优惠券')--  WOW智识派_全勤玩家奖池
x.中奖奖品 in ('户外运动水壶','随身洗漱包','0度2L玻璃水1元兑换券','空调养护服务7折优惠券','100度充电权益免费兑换券','精品满100元减30元优惠券')--  WOW运动咖_最佳答人奖池
or x.中奖奖品 in ('字母印花购物袋-大号','旅行保温水壶-山峰','时尚运动棒球帽-白檐','100度充电权益5元优惠券','精品满200元减20元优惠券','售后满300元减30元优惠券')--  WOW运动咖_全勤玩家奖池
--x.中奖奖品 in ('售后通用100元代金券兑换券','车载折叠收纳箱','折叠夜灯','花点时间单周1次免费兑换券','100度充电权益免费兑换券','精品满100元减40元优惠券')--  WOW乐享家_最佳答人奖池
-- x.中奖奖品 in ('保鲜便当盒','车载纸巾收纳盒','硅胶手绘餐垫','随身杯-海精灵小号','精品满200元减20元优惠券','售后满300元减30元优惠券')-- WOW乐享家_全勤玩家奖池
group by 1
order by 1



--实物奖品兑奖详情
select 
x.is_vehicle,
count(x.member_id)
from 
(
	select
	a.member_id,
	a.nick_name 姓名,
	case when d.is_vehicle =1 then '车主'
	 	when d.is_vehicle=0 then '粉丝'
	 	end 用户类型,
	d.MEMBER_PHONE 沃世界注册手机号,
	case when a.have_win = '1' then '中奖'
		when a.have_win = '0' then '未中奖'
		end 是否中奖,
	case when a.have_send = '1' then '已发放'
		when a.have_send = '0' then '未发放'
		end 奖品是否发放,
	a.create_time 抽奖时间,
	b.prize_name 中奖奖品,
	b.prize_level_nick_name 奖品等级
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	left join `member`.tc_member_info d on a.member_id = d.ID
	where a.lottery_code = 'double_eleven_2023'  -- 双十一
	and a.lottery_play_code in
	(
		'double_eleven_2023_1',
		'double_eleven_2023_2',
		'double_eleven_2023_3',
		'double_eleven_2023_4',
		'double_eleven_2023_5',
		'double_eleven_2023_6'
	)
	and a.have_win = 1   -- 中奖
	and a.create_time>='2023-10-31'
	and a.create_time <'2023-11-15'
	and d.member_phone='15687110110'
	order by b.prize_name)x
	group by 1

	select *
	from volvo_online_activity_module.lottery_draw_log ldl 
	where ldl.member_id ='3061636'
	order by create_time desc 

-- 此刻发帖明细
select 
a.member_id 会员ID,
a.post_id 内容ID,
a.post_state,
case when tmi.IS_VEHICLE = '1' then '车主' when tmi.IS_VEHICLE = '0' then '粉丝' end 是否车主,
tmi.REAL_NAME 姓名,
tmi.MEMBER_NAME 昵称,
case when tmi.member_sex = '10021001' then '先生' when tmi.member_sex = '10021002' then '女士' else '未知' end 性别,
tmi.MEMBER_PHONE 沃世界注册手机号码,
a.create_time 发帖日期,
z.发帖内容,
z.发帖字数,
z.发帖图片数量,
a.like_count 点赞数,
z.发帖图片链接,
g.话题名称,
ifnull(x.num,0)  兑奖记录（数量）,
ifnull(x1.中奖次数,0) 中奖次数,
x1.奖品明细
from community.tm_post a
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join community.tr_topic_post_link b on a.post_id =b.post_id
left join
(-- 发帖内容、图片
	select t.post_id,
	string_agg(case when t.类型='text' then t.内容 else null end ,';') as 发帖内容,
	char_length(case when t.类型='text' then t.内容 else null end) as 发帖字数,
	string_agg(case when t.类型='image' then t.内容 else null end ,';') as 发帖图片链接,
	count(case when t.类型='image' then t.内容 else null end) as 发帖图片数量
	from (
	select
	tpm.post_id,
	tpm.create_time,
	tpm.node_content 发帖内容,
	json_array_elements(tpm.node_content::json)->>'nodeType' 类型,
	json_array_elements(tpm.node_content::json)->>'nodeContent' 内容
	from community.tt_post_material tpm
	where tpm.create_time >='2023-10-31 ' 
--	and tpm.create_time <='2023-10-31 23:59:59'
	and node_content not like '%\u0000%'
	and tpm.is_deleted = 0) as t
	group by t.post_id
)z on a.post_id =z.post_id
left join 
	(-- 帖子带的话题名称
	select a.post_id,STRING_AGG( b.topic_id, '、') AS 话题标签,STRING_AGG( c.topic_name, '、') AS 话题名称
	from community.tm_post a
	left join community.tr_topic_post_link b on a.post_id =b.post_id
	left join community.tm_topic c on c.topic_id =b.topic_id
	where a.is_deleted =0
	group by a.post_id
)g on a.post_id =g.post_id
left join 
	( 	
	--实物奖品兑奖详情
	select
	a.member_id,
	count(1) num 
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	left join `member`.tc_member_info d on a.member_id = d.ID
	where a.lottery_code = 'double_eleven_2023'  -- 双十一
	and a.lottery_play_code in
	(
		'double_eleven_2023_1',
		'double_eleven_2023_2',
		'double_eleven_2023_3',
		'double_eleven_2023_4',
		'double_eleven_2023_5',
		'double_eleven_2023_6'
	)
	and a.have_win = 1   -- 中奖
	and a.create_time>='2023-10-31'
	and a.create_time <'2023-11-12'
	group by 1
	) x on x.member_id=a.member_id 
left join 
	( 	
	--历史获奖详情
	select
	a.member_id,
	count(1) 中奖次数,
	GROUP_CONCAT(b.prize_name) 奖品明细
	from volvo_online_activity_module.lottery_draw_log a
	left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	left join `member`.tc_member_info d on a.member_id = d.ID
	where a.have_win = 1   -- 中奖
--	and a.create_time>='2023-10-31'
--	and a.create_time <'2023-11-06'
	group by 1
	) x1 on x1.member_id=a.member_id 
where 1=1
and a.is_deleted =0
and a.create_time >='2023-10-31'
and a.create_time <'2023-11-12'
and b.topic_id = 'ckgN4zwGVd' 
order by a.create_time