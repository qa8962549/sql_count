-- PV UV数据拉取 525车主节
select 
case when t.data like '%3CCE66106B294AD3B411FC1331B31937%' then '首页弹窗'
	when t.data like '%01C1481CD24445B2B5E04BA595070517%' then '置顶banner'
	when t.data like '%CBA8D72326B74EC8968B32D5EAB6C8F3%' then '沃的活动banner'
    when t.data like '%C4E2E782639B4D909810420AB8CD14AA%' then '活动置顶banner'
	when t.data like '%96F5B677097C4B85A8D240755570DB75%' then '分享海报太阳码'
	when t.data like '%37EBB73D4FA44334A8B2047BEEF86A0D%' then '月历订阅服务通知'
	when t.data like '%6DC563D2F7A3412191BFFA65E66C3AD3%' then '推文引流'
	when t.data like '%1663672BEAE149D6A6EA288281D644EA%' then '5月20号订阅服务通知'
	when t.data like '%009E8D5FB070468DB540E33DB8343867%' then '沃尔沃汽车小程序banner'
	when t.data like '%CA7754F8757D4D7D885A3B17E39A6C15%' then '一店一码banner'
	when t.data like '%7F97CD3B11C148D582B18F7685842628%' then '签到banner'
	when t.data like '%B5486AFB50134B3CAE3B46E52E0D4390%' then '新车主调研问卷'
	when t.data like '%3FB5EE5E83BC4B1595CC6A18B8C53BBF%' then '新关注欢迎语'
	when t.data like '%114AFAF3DE2B47AC8AD23F2A137633B0%' then '5月26号订阅服务通知'
	when t.data like '%4C2BD3D5191D432AA099B415EC58DBA3%' then '售后海报'
	when t.data like '%DF92C05E0D8E4479A55033245DDCE26B%' then '会员日引流'
	when t.data like '%B4C2E13945FF471FBE02C86CBCC88628%' then '5月25号模板消息'
	when t.data like '%F30CDA8538CF4FEA84A003D9D12FAC49%' then '525车主狂欢节'
	when t.data like '%A8C2D7B3217A450089CAC4CA92A2DD46%' then '幸运大翻牌'
	when t.data like '%F0316B7D74D6476E92940B748751D72E%' then '试驾抽好礼'
	when t.data like '%B36827C0C22843C88E10F1927C8052D4%' then '推荐购'
	when t.data like '%5D939ABD283742548EAA96D1861DDF72%' then 'APP下载图文'
	when t.data like '%6E5767DD3B724D5C815F2E11255247EA%' then '爱车养修'
	when t.data like '%C3966678D70749BE98633F863F804841%' then '525限定勋章'
	when t.data like '%5D7DD789F9C14D4C9FB4E7AAF555E56B%' then '签到抽奖-1级奖池'
	when t.data like '%37EDA6A4E0484B429BFB17266E393C28%' then '签到抽奖-2级奖池'
	when t.data like '%969CA126F59A41C9B0696BEDC8401EEA%' then '会员日banner'
else null end '分类',
COUNT(usertag) as 'PV',
COUNT(distinct usertag) as 'UV'
from track.track t
where t.`date` >= '2022-05-23'
and t.`date` <= '2022-05-23 19:00:00'
group by 1
order by 1;

-- 拉新人数
select 
-- m.IS_VEHICLE,
	case when t.data like '%3CCE66106B294AD3B411FC1331B31937%' then '首页弹窗'
	when t.data like '%01C1481CD24445B2B5E04BA595070517%' then '置顶banner'
	when t.data like '%CBA8D72326B74EC8968B32D5EAB6C8F3%' then '沃的活动banner'
    when t.data like '%C4E2E782639B4D909810420AB8CD14AA%' then '活动置顶banner'
	when t.data like '%96F5B677097C4B85A8D240755570DB75%' then '分享海报太阳码'
	when t.data like '%37EBB73D4FA44334A8B2047BEEF86A0D%' then '月历订阅服务通知'
	when t.data like '%6DC563D2F7A3412191BFFA65E66C3AD3%' then '推文引流'
	when t.data like '%1663672BEAE149D6A6EA288281D644EA%' then '5月20号订阅服务通知'
	when t.data like '%009E8D5FB070468DB540E33DB8343867%' then '沃尔沃汽车小程序banner'
	when t.data like '%CA7754F8757D4D7D885A3B17E39A6C15%' then '一店一码banner'
	when t.data like '%7F97CD3B11C148D582B18F7685842628%' then '签到banner'
	when t.data like '%B5486AFB50134B3CAE3B46E52E0D4390%' then '新车主调研问卷'
	when t.data like '%3FB5EE5E83BC4B1595CC6A18B8C53BBF%' then '新关注欢迎语'
	when t.data like '%114AFAF3DE2B47AC8AD23F2A137633B0%' then '5月26号订阅服务通知'
	when t.data like '%4C2BD3D5191D432AA099B415EC58DBA3%' then '售后海报'
	when t.data like '%DF92C05E0D8E4479A55033245DDCE26B%' then '会员日引流'
	when t.data like '%B4C2E13945FF471FBE02C86CBCC88628%' then '5月25号模板消息'
	when t.data like '%F30CDA8538CF4FEA84A003D9D12FAC49%' then '525车主狂欢节'
	when t.data like '%A8C2D7B3217A450089CAC4CA92A2DD46%' then '幸运大翻牌'
	when t.data like '%F0316B7D74D6476E92940B748751D72E%' then '试驾抽好礼'
	when t.data like '%B36827C0C22843C88E10F1927C8052D4%' then '推荐购'
	when t.data like '%5D939ABD283742548EAA96D1861DDF72%' then 'APP下载图文'
	when t.data like '%6E5767DD3B724D5C815F2E11255247EA%' then '爱车养修'
	when t.data like '%C3966678D70749BE98633F863F804841%' then '525限定勋章'
	when t.data like '%5D7DD789F9C14D4C9FB4E7AAF555E56B%' then '签到抽奖-1级奖池'
	when t.data like '%37EDA6A4E0484B429BFB17266E393C28%' then '签到抽奖-2级奖池'
	when t.data like '%969CA126F59A41C9B0696BEDC8401EEA%' then '会员日banner'
	end '入口',
	count(distinct case when m.IS_VEHICLE = 0 then m.id end) 粉丝
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.IS_VEHICLE = 0
where t.`date` >= '2022-05-23'
and t.`date` <= '2022-05-23 19:00:00'
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
group by 1;


-- 激活僵尸粉数
select 
-- 	a.is_vehicle,
	a.channel,
	-- a.usertag
	count(distinct a.usertag)
from(
 -- 获取访问文章活动10分钟之前的最晚访问时间
 select t.usertag,b.mdate,b.is_vehicle,b.channel,max(t.date) tdate
 from track.track t
 join (
  -- 获取访问文章活动的最早时间
  select m.is_vehicle,t.usertag,c.channel,min(t.date) mdate 
  from track.track t 
  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
  join 
  (select b.channel,b.usertag,b.min_date,
	ROW_NUMBER() over(partition by b.usertag order by b.min_date) as rk
	from 
	(select a.channel ,a.usertag,min(a.date) as min_date
	from 
	(select 
		case when t.data like '%3CCE66106B294AD3B411FC1331B31937%' then '首页弹窗'
	when t.data like '%01C1481CD24445B2B5E04BA595070517%' then '置顶banner'
	when t.data like '%CBA8D72326B74EC8968B32D5EAB6C8F3%' then '沃的活动banner'
    when t.data like '%C4E2E782639B4D909810420AB8CD14AA%' then '活动置顶banner'
	when t.data like '%96F5B677097C4B85A8D240755570DB75%' then '分享海报太阳码'
	when t.data like '%37EBB73D4FA44334A8B2047BEEF86A0D%' then '月历订阅服务通知'
	when t.data like '%6DC563D2F7A3412191BFFA65E66C3AD3%' then '推文引流'
	when t.data like '%1663672BEAE149D6A6EA288281D644EA%' then '5月20号订阅服务通知'
	when t.data like '%009E8D5FB070468DB540E33DB8343867%' then '沃尔沃汽车小程序banner'
	when t.data like '%CA7754F8757D4D7D885A3B17E39A6C15%' then '一店一码banner'
	when t.data like '%7F97CD3B11C148D582B18F7685842628%' then '签到banner'
	when t.data like '%B5486AFB50134B3CAE3B46E52E0D4390%' then '新车主调研问卷'
	when t.data like '%3FB5EE5E83BC4B1595CC6A18B8C53BBF%' then '新关注欢迎语'
	when t.data like '%114AFAF3DE2B47AC8AD23F2A137633B0%' then '5月26号订阅服务通知'
	when t.data like '%4C2BD3D5191D432AA099B415EC58DBA3%' then '售后海报'
	when t.data like '%DF92C05E0D8E4479A55033245DDCE26B%' then '会员日引流'
	when t.data like '%B4C2E13945FF471FBE02C86CBCC88628%' then '5月25号模板消息'
	when t.data like '%F30CDA8538CF4FEA84A003D9D12FAC49%' then '525车主狂欢节'
	when t.data like '%A8C2D7B3217A450089CAC4CA92A2DD46%' then '幸运大翻牌'
	when t.data like '%F0316B7D74D6476E92940B748751D72E%' then '试驾抽好礼'
	when t.data like '%B36827C0C22843C88E10F1927C8052D4%' then '推荐购'
	when t.data like '%5D939ABD283742548EAA96D1861DDF72%' then 'APP下载图文'
	when t.data like '%6E5767DD3B724D5C815F2E11255247EA%' then '爱车养修'
	when t.data like '%C3966678D70749BE98633F863F804841%' then '525限定勋章'
	when t.data like '%5D7DD789F9C14D4C9FB4E7AAF555E56B%' then '签到抽奖-1级奖池'
	when t.data like '%37EDA6A4E0484B429BFB17266E393C28%' then '签到抽奖-2级奖池'
	when t.data like '%969CA126F59A41C9B0696BEDC8401EEA%' then '会员日banner'
			else null end 'channel',
			t.usertag,
			t.`date` 
		from track.track t 
		where t.`date` >= '2022-05-23'
and t.`date` <= '2022-05-23 19:00:00') a 
	where a.channel is not null
	group by 1,2) b) c on t.usertag = c.usertag
  where 
  t.`date` >= '2022-05-23'
and t.`date` <= '2022-05-23 19:00:00'
  GROUP BY 1,2,3
 ) b on b.usertag=t.usertag
 where t.date< DATE_SUB(b.mdate,INTERVAL 10 MINUTE)
 GROUP BY 1,2,3,4
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1


	when t.data like '%3CCE66106B294AD3B411FC1331B31937%' then '01 首页弹窗'
	when t.data like '%01C1481CD24445B2B5E04BA595070517%' then '02 置顶banner'
	when t.data like '%CBA8D72326B74EC8968B32D5EAB6C8F3%' then '03 沃的活动banner'
    when t.data like '%C4E2E782639B4D909810420AB8CD14AA%' then '04 活动置顶banner'
	when t.data like '%96F5B677097C4B85A8D240755570DB75%' then '05 分享海报太阳码'
	when t.data like '%37EBB73D4FA44334A8B2047BEEF86A0D%' then '06 月历订阅服务通知'
	when t.data like '%6DC563D2F7A3412191BFFA65E66C3AD3%' then '07 推文引流'
	when t.data like '%1663672BEAE149D6A6EA288281D644EA%' then '08 5月20号订阅服务通知'
	when t.data like '%009E8D5FB070468DB540E33DB8343867%' then '09 沃尔沃汽车小程序banner'
	when t.data like '%CA7754F8757D4D7D885A3B17E39A6C15%' then '10 一店一码banner'
	when t.data like '%7F97CD3B11C148D582B18F7685842628%' then '11 签到banner'
	when t.data like '%B5486AFB50134B3CAE3B46E52E0D4390%' then '12 新车主调研问卷'
	when t.data like '%3FB5EE5E83BC4B1595CC6A18B8C53BBF%' then '13 新关注欢迎语'
	when t.data like '%114AFAF3DE2B47AC8AD23F2A137633B0%' then '14 5月26号订阅服务通知'
	when t.data like '%4C2BD3D5191D432AA099B415EC58DBA3%' then '15 售后海报'
	when t.data like '%DF92C05E0D8E4479A55033245DDCE26B%' then '16 会员日引流'
	when t.data like '%B4C2E13945FF471FBE02C86CBCC88628%' then '17 5月25号模板消息'
	when t.data like '%F30CDA8538CF4FEA84A003D9D12FAC49%' then '18 525车主狂欢节'
	when t.data like '%A8C2D7B3217A450089CAC4CA92A2DD46%' then '19 幸运大翻牌'
	when t.data like '%F0316B7D74D6476E92940B748751D72E%' then '20 试驾抽好礼'
	when t.data like '%B36827C0C22843C88E10F1927C8052D4%' then '21 推荐购'
	when t.data like '%5D939ABD283742548EAA96D1861DDF72%' then '22 APP下载图文'
	when t.data like '%6E5767DD3B724D5C815F2E11255247EA%' then '23 爱车养修'
	when t.data like '%C3966678D70749BE98633F863F804841%' then '24 525限定勋章'
	when t.data like '%5D7DD789F9C14D4C9FB4E7AAF555E56B%' then '25 签到抽奖-1级奖池'
	when t.data like '%37EDA6A4E0484B429BFB17266E393C28%' then '26 签到抽奖-2级奖池'
	when t.data like '%969CA126F59A41C9B0696BEDC8401EEA%' then '27 会员日banner'