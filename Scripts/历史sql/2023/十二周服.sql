-- 
select tmi.MEMBER_NAME 昵称,
tsp.member_id,
case tmi.IS_VEHICLE when 1 then '是' else '否' end '是否车主',
a.model_name 绑定车型,
a.company_code 购车经销商,
a.VIN,
if(tr.REGION_NAME = tr2.REGION_NAME ,tr.REGION_NAME ,ifnull("",concat(tr.REGION_NAME,tr2.REGION_NAME))) 省市,
tmi.MEMBER_PHONE 手机号,
tsp.create_date 提交时间,
tst.topic_name 话题,
tsp.content 发帖内容,
tsp.comment_count 评论量,
tsp.like_count 点赞量,
case tsp.check_status when 1 then '审核成功'
when 0 then '审核中'
when -1 then '审核失败' end 审核状态,
case when tsp.chosen = 1 then '是' else '否' end 是否精选,
case when tsp.sort = 1000 then '是' else '否' end 是否置顶,
case when tst.entity_type = 1 then '视频贴' else '文字帖' end 帖子类型,
case when tst.`type` = 0 then '官方话题' else '原创话题' end 话题分类 ,
a.create_time 发帖用户绑车时间,
x.tt 发帖后再次进入小程序时间
from volvo_online_activity.twelve_service_post tsp 
left join volvo_online_activity.twelve_service_topic tst on tsp.topic_id = tst.id 
left join `member`.tc_member_info tmi on tsp.member_id = tmi.ID 
left join 
		(
		select tmi.id,min(t.date) tt
		from track.track t 
		left join `member`.tc_member_info tmi on CAST(tmi.USER_ID as varchar)=t.usertag and tmi.IS_DELETED =0 and tmi.STATUS <>60341003
		left join 
					(
					#最新发帖
					select x.member_id,x.create_date
					from 
						(
						select tsp.member_id,tsp.create_date,ROW_NUMBER() over(partition by tsp.member_id order by tsp.create_date desc) as rk
						from volvo_online_activity.twelve_service_post tsp
						)x where x.rk=1
					)tsp on tsp.member_id =tmi.id 
		where t.date>=tsp.create_date
		group by 1
		)x on x.id=tsp.member_id 
left join 
	(select b.member_id,
	group_concat(distinct tm.MODEL_NAME) model_name,
	group_concat(distinct b.VIN) VIN,
	GROUP_CONCAT(distinct tisd.dealer_code) company_code,
	b.create_time
	from 
		(select a.member_id,a.vin,a.create_time
		from 
			(select tmv.MEMBER_ID,tmv.VIN,tmv.create_time,
			ROW_NUMBER() over(partition by tmv.VIN order by tmv.CREATE_TIME desc) as rk
			from `member`.tc_member_vehicle tmv 
			left join 
				(
				#最新发帖
				select x.member_id,x.create_date
				from 
					(
					select tsp.member_id,tsp.create_date,ROW_NUMBER() over(partition by tsp.member_id order by tsp.create_date desc) as rk
					from volvo_online_activity.twelve_service_post tsp
					)x where x.rk=1
				)tsp on tsp.member_id =tmv.MEMBER_ID 
			where tmv.IS_DELETED = 0
			and tmv.create_time<=tsp.create_date) a 
		where a.rk = 1 ) b
	left join vehicle.tt_invoice_statistics_dms tisd on b.vin = tisd.vin and tisd.IS_DELETED = 0
	left join vehicle.tm_vehicle tv on b.vin = tv.VIN and tv.IS_DELETED = 0
	left join basic_data.tm_model tm on tv.MODEL_ID = tm.id 
	where tm.IS_DELETED = 0
	group by 1) a on a.member_id = tsp.member_id
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE = tr.REGION_ID 
left join dictionary.tc_region tr2 on tmi.MEMBER_CITY = tr2.REGION_ID 
where tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
and tsp.create_date >= '2021-11-01'
and tsp.create_date <'2022-08-01'
order by tsp.create_date;