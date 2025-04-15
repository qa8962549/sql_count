## 北京新能源政策宣传活动数据

-- 1、埋点测试
select * from track.track t where t.usertag = '5537985' order by t.`date` desc

-- 2、活动数据
select
case when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页_ONLOAD' then '活动主页'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击预约试驾_CLICK' then '点击活动主页【预约试驾】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击我的邀约_CLICK' then '点击活动主页【我的邀约】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_留资页_ONLOAD' then '「新」动福利「京」邀来电  留资页'	 
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_留资页点击立即报名_CLICK' then '留资页点击【立即报名】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_活动规则页_ONLOAD' then '活动规则页面'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_报名成功页_ONLOAD' then '报名成功分享页'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_报名成功页点击邀请_CLICK' and json_extract(t.`data`,'$.type') = 'page' then '报名成功分享页点击【生成海报，邀友相助】'   -- 这个看看有没有问题
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_报名成功页点击领取奖励_CLICK' then '报名成功分享页点击【领取奖励】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_海报页长按保存_CLICK' then '长按保存分享海报人数'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_报名成功页点击邀请_CLICK' and json_extract(t.`data`,'$.type') = 'modal' then '助力记录点击【邀友相助】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_报名成功页助力记录点击我知道了_CLICK' then '助力记录点击【我知道了】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击即刻前往_CLICK' and json_extract(t.`data`,'$.content') = '仅限新用户参与！您不满足助力条件哦' then '弹窗-不满足助力条件点击【即刻前往】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击我知道了_CLICK' and json_extract(t.`data`,'$.content') = '仅限新用户参与！您不满足助力条件哦' then '弹窗-不满足助力条件点击【我知道了】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击即刻前往_CLICK' and json_extract(t.`data`,'$.content') = '无法重复助力哦' then '弹窗-重复助力点击【即刻前往】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击我知道了_CLICK' and json_extract(t.`data`,'$.content') = '无法重复助力哦' then '弹窗-重复助力点击【我知道了】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击即刻前往_CLICK' and json_extract(t.`data`,'$.content') = 'Wow！真给力！' then '弹窗-助力成功点击【即刻前往】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击我知道了_CLICK' and json_extract(t.`data`,'$.content') = 'Wow！真给力！' then '弹窗-助力成功点击【我知道了】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_报名成功页领取奖励弹窗点击我知道了_CLICK' then '弹窗-领取奖励点击【我知道了】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击我知道了_CLICK' and json_extract(t.`data`,'$.content') = '无法为自己助力哦' then '弹窗-无法为自己助力-失败点击【我知道了】'
	 when json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击我知道了_CLICK' and json_extract(t.`data`,'$.content') = '您暂不符合活动规则，如有疑问请咨询' then '弹窗-黑产用户-暂不符合活动规则点击【我知道了】'
else null end '分类',
COUNT(usertag) as 'PV',
COUNT(distinct usertag) as 'UV' 
from track.track t
join `member`.tc_member_info m on t.usertag = CAST(m.USER_ID as VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
where t.`date` >= '2022-09-18'
and t.`date` <= '2022-09-18 23:59:59'
group by 1
order by 1


-- 3-1、渠道数据
select
case when t.`data` like '%06426103DFC94F2CA34385B3CBF429DC%' then '06426103DFC94F2CA34385B3CBF429DC'
	when t.`data` like '%CB464F44E06A431B8F4C2FF31231BA88%' then 'CB464F44E06A431B8F4C2FF31231BA88'
	when t.`data` like '%DF6B811E28F74F1EAF897815CD4D95BB%' then 'DF6B811E28F74F1EAF897815CD4D95BB'
	when t.`data` like '%CF573CCC14AC4EEE812E22E2BC0E9E7B%' then 'CF573CCC14AC4EEE812E22E2BC0E9E7B'
	when t.`data` like '%5E579FB179974A02ABF009F04132E9DB%' then '5E579FB179974A02ABF009F04132E9DB'
	when t.`data` like '%F80B7911CDD54BD8976F4F2F2BB3B144%' then 'F80B7911CDD54BD8976F4F2F2BB3B144'
	when t.`data` like '%AB3435B6B9AA49BDB2A4DD06A532DA9F%' then 'AB3435B6B9AA49BDB2A4DD06A532DA9F'
	when t.`data` like '%C27FAB6EA6B748689B8B6BC77B2DD317%' then 'C27FAB6EA6B748689B8B6BC77B2DD317'
	when t.`data` like '%1CAA98CF80FA4201919F374C250BD63F%' then '1CAA98CF80FA4201919F374C250BD63F'
	when t.`data` like '%2EA11C6AADB7442FBAB48B2277B979F4%' then '2EA11C6AADB7442FBAB48B2277B979F4'
	when t.`data` like '%79CB18B81AEE4224B170DAEA2F2E0402%' then '79CB18B81AEE4224B170DAEA2F2E0402'
	when t.`data` like '%F5FD5688F3854C4E9B76C162594BC29A%' then 'F5FD5688F3854C4E9B76C162594BC29A'
	when t.`data` like '%0D348C8B034D4BD89D0A72C956AD9CD0%' then '0D348C8B034D4BD89D0A72C956AD9CD0'
	when t.`data` like '%CFB9742EFF054F6FBCDB23B20F26F8A8%' then 'CFB9742EFF054F6FBCDB23B20F26F8A8'
	when t.`data` like '%447D696DFCA045FDB40D821837E8868C%' then '447D696DFCA045FDB40D821837E8868C'
	when t.`data` like '%F65257D96B004C81A69B7E607819A0CF%' then 'F65257D96B004C81A69B7E607819A0CF'
	when t.`data` like '%73510EE395C94D08A5009C6F43F341A8%' then '73510EE395C94D08A5009C6F43F341A8'
	when t.`data` like '%9831930165954B8E97C96BCE5FD33B72%' then '9831930165954B8E97C96BCE5FD33B72'
	when t.`data` like '%595AA30FBC3F4B7788D3797919DEB519%' then '595AA30FBC3F4B7788D3797919DEB519'
	when t.`data` like '%D597A27E8AB741189659C653BF76D625%' then 'D597A27E8AB741189659C653BF76D625'
	when t.`data` like '%BCC0E0E164B24CEA80E9BD4E06286A40%' then 'BCC0E0E164B24CEA80E9BD4E06286A40'
else null end '分类',
COUNT(usertag) as 'PV',
COUNT(distinct usertag) as 'UV' 
from track.track t
join `member`.tc_member_info m on t.usertag = CAST(m.USER_ID as VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
where t.`date` >= '2022-08-01'
and t.`date` <= '2022-09-18 23:59:59'
group by 1
order by 1


-- 3-2、拉新人数
select 
-- m.IS_VEHICLE,
	case when t.`data` like '%06426103DFC94F2CA34385B3CBF429DC%' then '06426103DFC94F2CA34385B3CBF429DC'
		when t.`data` like '%CB464F44E06A431B8F4C2FF31231BA88%' then 'CB464F44E06A431B8F4C2FF31231BA88'
		when t.`data` like '%DF6B811E28F74F1EAF897815CD4D95BB%' then 'DF6B811E28F74F1EAF897815CD4D95BB'
		when t.`data` like '%CF573CCC14AC4EEE812E22E2BC0E9E7B%' then 'CF573CCC14AC4EEE812E22E2BC0E9E7B'
		when t.`data` like '%5E579FB179974A02ABF009F04132E9DB%' then '5E579FB179974A02ABF009F04132E9DB'
		when t.`data` like '%F80B7911CDD54BD8976F4F2F2BB3B144%' then 'F80B7911CDD54BD8976F4F2F2BB3B144'
		when t.`data` like '%AB3435B6B9AA49BDB2A4DD06A532DA9F%' then 'AB3435B6B9AA49BDB2A4DD06A532DA9F'
		when t.`data` like '%C27FAB6EA6B748689B8B6BC77B2DD317%' then 'C27FAB6EA6B748689B8B6BC77B2DD317'
		when t.`data` like '%1CAA98CF80FA4201919F374C250BD63F%' then '1CAA98CF80FA4201919F374C250BD63F'
		when t.`data` like '%2EA11C6AADB7442FBAB48B2277B979F4%' then '2EA11C6AADB7442FBAB48B2277B979F4'
		when t.`data` like '%79CB18B81AEE4224B170DAEA2F2E0402%' then '79CB18B81AEE4224B170DAEA2F2E0402'
		when t.`data` like '%F5FD5688F3854C4E9B76C162594BC29A%' then 'F5FD5688F3854C4E9B76C162594BC29A'
		when t.`data` like '%0D348C8B034D4BD89D0A72C956AD9CD0%' then '0D348C8B034D4BD89D0A72C956AD9CD0'
		when t.`data` like '%CFB9742EFF054F6FBCDB23B20F26F8A8%' then 'CFB9742EFF054F6FBCDB23B20F26F8A8'
		when t.`data` like '%447D696DFCA045FDB40D821837E8868C%' then '447D696DFCA045FDB40D821837E8868C'
		when t.`data` like '%F65257D96B004C81A69B7E607819A0CF%' then 'F65257D96B004C81A69B7E607819A0CF'
		when t.`data` like '%73510EE395C94D08A5009C6F43F341A8%' then '73510EE395C94D08A5009C6F43F341A8'
		when t.`data` like '%9831930165954B8E97C96BCE5FD33B72%' then '9831930165954B8E97C96BCE5FD33B72'
		when t.`data` like '%595AA30FBC3F4B7788D3797919DEB519%' then '595AA30FBC3F4B7788D3797919DEB519'
		when t.`data` like '%D597A27E8AB741189659C653BF76D625%' then 'D597A27E8AB741189659C653BF76D625'
		when t.`data` like '%BCC0E0E164B24CEA80E9BD4E06286A40%' then 'BCC0E0E164B24CEA80E9BD4E06286A40'
	end '入口',
	count(distinct case when m.IS_VEHICLE = 0 then m.id end) 粉丝
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.IS_VEHICLE = 0
where t.`date` >= '2022-08-01' 
and t.`date` <= '2022-09-18 23:59:59'
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
group by 1;


-- 3-3、激活僵尸粉数
select 
-- 	a.is_vehicle,
	a.channel,
	COUNT(a.usertag)激活数 
	-- count(distinct case when a.IS_VEHICLE = 1 then a.usertag end) 车主,
	-- count(distinct case when a.IS_VEHICLE = 0 then a.usertag end) 粉丝
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
		case when t.`data` like '%06426103DFC94F2CA34385B3CBF429DC%' then '06426103DFC94F2CA34385B3CBF429DC'
		when t.`data` like '%CB464F44E06A431B8F4C2FF31231BA88%' then 'CB464F44E06A431B8F4C2FF31231BA88'
		when t.`data` like '%DF6B811E28F74F1EAF897815CD4D95BB%' then 'DF6B811E28F74F1EAF897815CD4D95BB'
		when t.`data` like '%CF573CCC14AC4EEE812E22E2BC0E9E7B%' then 'CF573CCC14AC4EEE812E22E2BC0E9E7B'
		when t.`data` like '%5E579FB179974A02ABF009F04132E9DB%' then '5E579FB179974A02ABF009F04132E9DB'
		when t.`data` like '%F80B7911CDD54BD8976F4F2F2BB3B144%' then 'F80B7911CDD54BD8976F4F2F2BB3B144'
		when t.`data` like '%AB3435B6B9AA49BDB2A4DD06A532DA9F%' then 'AB3435B6B9AA49BDB2A4DD06A532DA9F'
		when t.`data` like '%C27FAB6EA6B748689B8B6BC77B2DD317%' then 'C27FAB6EA6B748689B8B6BC77B2DD317'
		when t.`data` like '%1CAA98CF80FA4201919F374C250BD63F%' then '1CAA98CF80FA4201919F374C250BD63F'
		when t.`data` like '%2EA11C6AADB7442FBAB48B2277B979F4%' then '2EA11C6AADB7442FBAB48B2277B979F4'
		when t.`data` like '%79CB18B81AEE4224B170DAEA2F2E0402%' then '79CB18B81AEE4224B170DAEA2F2E0402'
		when t.`data` like '%F5FD5688F3854C4E9B76C162594BC29A%' then 'F5FD5688F3854C4E9B76C162594BC29A'
		when t.`data` like '%0D348C8B034D4BD89D0A72C956AD9CD0%' then '0D348C8B034D4BD89D0A72C956AD9CD0'
		when t.`data` like '%CFB9742EFF054F6FBCDB23B20F26F8A8%' then 'CFB9742EFF054F6FBCDB23B20F26F8A8'
		when t.`data` like '%447D696DFCA045FDB40D821837E8868C%' then '447D696DFCA045FDB40D821837E8868C'
		when t.`data` like '%F65257D96B004C81A69B7E607819A0CF%' then 'F65257D96B004C81A69B7E607819A0CF'
		when t.`data` like '%73510EE395C94D08A5009C6F43F341A8%' then '73510EE395C94D08A5009C6F43F341A8'
		when t.`data` like '%9831930165954B8E97C96BCE5FD33B72%' then '9831930165954B8E97C96BCE5FD33B72'
		when t.`data` like '%595AA30FBC3F4B7788D3797919DEB519%' then '595AA30FBC3F4B7788D3797919DEB519'
		when t.`data` like '%D597A27E8AB741189659C653BF76D625%' then 'D597A27E8AB741189659C653BF76D625'
		when t.`data` like '%BCC0E0E164B24CEA80E9BD4E06286A40%' then 'BCC0E0E164B24CEA80E9BD4E06286A40'
		else null end 'channel',
		t.usertag,
		t.`date` 
		from track.track t 
		where t.`date` >= '2022-08-01'
		and t.`date` <= '2022-09-18 23:59:59') a 
	where a.channel is not null
	group by 1,2) b) c on t.usertag = c.usertag
  where 
  t.date >= '2022-08-01'
  and t.date <= '2022-09-18 23:59:59'
  GROUP BY 1,2,3
 ) b on b.usertag=t.usertag
 where t.date< DATE_SUB(b.mdate,INTERVAL 10 MINUTE)
 GROUP BY 1,2,3,4
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1


-- 4-1、预约试驾数据明细（8.1-8.14按日拉取，8.15-9.30按周拉取）
SELECT
DISTINCT ta.APPOINTMENT_ID 预约ID,
tm2.MODEL_NAME 车型,
ta.CREATED_AT 预约时间,
ta.ARRIVAL_DATE 实际到店日期,
ca.active_name 活动名称,
ta.one_id 客户ID,
ta.customer_name 姓名,
ta.customer_phone 手机号,
h.大区,
h.小区,
ta.OWNER_CODE 经销商,
tc2.COMPANY_NAME_CN 经销商名称,
CASE tad.status
	WHEN 70711001 THEN '待试驾'
    WHEN 70711002 THEN '已试驾' 
    WHEN 70711003 THEN '已取消'
    END 试驾状态,
tad.drive_s_at 试驾开始时间,
tad.drive_e_at 试驾结束时间
FROM cyx_appointment.tt_appointment ta
LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
LEFT JOIN organization.tm_company tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
LEFT JOIN basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID 
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
WHERE ta.CREATED_AT >= '2022-08-01'
AND ta.CREATED_AT <= '2022-09-18 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMJULXC4RC4RNY2022VCCN'    -- 北京新能源政策宣传活动code
and ta.CUSTOMER_PHONE not in ('18501603377','17611357618','19822751495','16621035759','13636472669','16621030865','18758197483','15294761658','18501707590')   -- 剔除测试信息
order by ta.CREATED_AT desc


-- 4-2、下单情况
select 
    a.SO_NO_ID 销售订单ID,
    a.SO_NO 销售订单号,
    a.COMPANY_CODE 公司代码,
    h.COMPANY_NAME_CN 经销商名称,
    h.GROUP_COMPANY_NAME 集团,
    h.ORG_NAME_big 大区,
    h.ORG_NAME_small 小区,
    a.OWNER_CODE 经销商代码,
    a.CREATED_AT 订单日期,
    a.SHEET_CREATE_DATE 开单日期,
    cast(a.CUSTOMER_BUSINESS_ID as varchar) 商机id ,
    a.CUSTOMER_NAME 客户姓名,
    a.DRAWER_NAME 开票人姓名,
    a.CONTACT_NAME 联系人姓名,
    a.CUSTOMER_TEL 潜客电话,
    a.DRAWER_TEL 开票人电话,
    a.PURCHASE_PHONE 下单人手机号,
    g.CODE_CN_DESC 订单状态,
    case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
    i.CODE_CN_DESC BUSINESS_TYPE,
    a.smmOrderId 订单id_smm,
    a.smmCustId 潜客id_smm,
    a.CUSTOMER_ID ,
    a.CUSTOMER_NO ,
    a.CUSTOMER_ACTIVITY_ID 活动代码id,
    c.CLUE_NAME 来源渠道,
    b.active_code 市场活动代码,
    b.active_name 市场活动名称,
    d.SALES_VIN 车架号,
    f.model_name 车型,
    j.CODE_CN_DESC 线索客户类型,
    k.CODE_CN_DESC 客户性别,
    l.CODE_CN_DESC 交车状态,
    n.CODE_CN_DESC 订单购买类型,
    a.VEHICLE_RETURN_DATE 退车完成日期,
    m.CODE_CN_DESC 退车状态,
    a.RETURN_REASON 退单原因,
    a.RETURN_REMARK 退单备注,
    a.IS_DELETED
from cyxdms_retail.tt_sales_orders a 
left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
left join customer_business.tm_clue_source c on c.ID = b.active_channel
left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
left join basic_data.tm_model f on f.id = e.SECOND_ID
left join dictionary.tc_code g on g.code_id = a.SO_STATUS
left join (
    select 
        tm.id 经销商表ID,
        tm.ORG_ID 经销商组织ID,
        tm.COMPANY_CODE ,
        tL2.ID 大区组织ID,
        tL2.ORG_NAME ORG_NAME_big,
        tg1.ID 小区组织ID,
        tg1.ORG_NAME ORG_NAME_small,
        tm.COMPANY_NAME_CN ,
        tm.GROUP_COMPANY_NAME,
        concat(tm.province_name,tm.city_name,tm.county_name) 城市
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	) h on h.COMPANY_CODE = a.COMPANY_CODE
 left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
 left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
 left join dictionary.tc_code k on k.code_id = a.GENDER
 left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
 left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
where a.BUSINESS_TYPE<>14031002
and a.IS_DELETED = 0
and a.CREATED_AT BETWEEN '2022-08-01' AND '2022-09-25 23:59:59'
and b.active_code = 'IBDMJULXC4RC4RNY2022VCCN'   -- 北京新能源政策宣传活动code
order by a.CREATED_AT

-- 预约试驾车型
select x.车型,
count(DISTINCT x.预约ID)
from 
	(
	SELECT
	DISTINCT ta.APPOINTMENT_ID 预约ID,
	tm2.MODEL_NAME 车型,
	ta.CREATED_AT 预约时间,
	ta.ARRIVAL_DATE 实际到店日期,
	ca.active_name 活动名称,
	ta.one_id 客户ID,
	ta.customer_name 姓名,
	ta.customer_phone 手机号,
	h.大区,
	h.小区,
	ta.OWNER_CODE 经销商,
	tc2.COMPANY_NAME_CN 经销商名称,
	CASE tad.status
		WHEN 70711001 THEN '待试驾'
	    WHEN 70711002 THEN '已试驾' 
	    WHEN 70711003 THEN '已取消'
	    END 试驾状态,
	tad.drive_s_at 试驾开始时间,
	tad.drive_e_at 试驾结束时间
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
	LEFT JOIN organization.tm_company tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
	LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	LEFT JOIN basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID 
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
	WHERE ta.CREATED_AT >= '2022-08-01'
	AND ta.CREATED_AT <= '2022-09-18 23:59:59'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ca.active_code = 'IBDMJULXC4RC4RNY2022VCCN'    -- 北京新能源政策宣传活动code
	and ta.CUSTOMER_PHONE not in ('18501603377','17611357618','19822751495','16621035759','13636472669','16621030865','18758197483','15294761658','18501707590')   -- 剔除测试信息
	order by ta.CREATED_AT desc
)x 
group by 1

-- 4-3、预约试驾线索明细，看有效线索量就根据线索状态筛选一下，剔除无效线索，这里的无效有好几个状态，找小白，或者参考之前的有效线索SQL
select
DATE_FORMAT(x.线索创建时间,'%Y-%m-%d'),
count(x.线索状态)总效线索,
count(case when x.线索状态 in ('待清洗','待分配','无效','无效审批中') then x.线索编号 else null end )无效线索,
count(case when x.是否到店='Y' then x.线索编号 else null end ) 实际到点量,
'0'
from 
(
	select 
    a.clue_id 线索编号,
    cast(a.business_id as varchar) 商机id,
    a.dealer_code 经销商代码,
    h.COMPANY_NAME_CN 经销商名称,
    h.GROUP_COMPANY_NAME 集团,
    h.ORG_NAME_big 大区,
    h.ORG_NAME_small 小区,
    a.name 客户姓名,
    a.mobile 客户电话,
    i.CODE_CN_DESC 客户性别,
    a.campaign_id 活动代码id,
    c.active_code 市场活动代码,
    c.active_name 市场活动名称,
    d.CLUE_NAME 来源渠道,
    f.model_name 意向车型,
    b.SHOP_NUMBER 到店次数,
    if(b.SHOP_NUMBER>0,'Y','N') 是否到店,
    g.FIRST_DRIVE_TIME 首次试驾时间,
    b.TEST_DRIVE_TIME 试驾次数,
    if(b.TEST_DRIVE_TIME>0,'Y','N') 是否试驾,
    a.allot_time 线索下发时间,
    b.FATE_AFFIRM_TIME 首次跟进时间,
    b.NEW_ACTION_TIME 最后跟进时间,
    a.handle_time 采集时间,
    b.created_at 商机创建时间,
    a.create_time 线索创建时间,
    e.CODE_CN_DESC 线索状态,
    a.smmclueid 线索id_SMM,
    if(a.smmclueid is null,'NEWBIE','SMM') 来源系统,
    a.smmcustid 潜客id_SMM,
    g.FIRST_ORDER_TIME 首次下单时间,
    g.DEFEAT_DATE 战败时间,
    g.MIN_WORK_CALL_TIME 最早工作号外呼时间,
    g.MAX_WORK_CALL_TIME 最新工作号外呼时间,
    g.TOTAL_CALL_NUM newbie外呼次数,
    g.WORK_CALL_NUM 工作号通话次数,
    g.WORK_CONNECT_NUM 工作号接通次数,
    g.WORK_CONNECT_TIMES 工作号累计通话时长
from customer.tt_clue_clean a 
left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
left join activity.cms_active c on a.campaign_id = c.uid
left join customer_business.tm_clue_source d on d.ID = c.active_channel
left join dictionary.tc_code e on a.clue_status = e.CODE_ID
left join basic_data.tm_model f on a.model_id = f.id
left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
left join (
    select 
        tm.id 经销商表ID,
        tm.ORG_ID 经销商组织ID,
        tm.COMPANY_CODE ,	
        tL2.ID 大区组织ID,
        tL2.ORG_NAME ORG_NAME_big,
        tg1.ID 小区组织ID,
        tg1.ORG_NAME ORG_NAME_small,
        tm.COMPANY_NAME_CN ,
        tm.GROUP_COMPANY_NAME
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	) h on h.COMPANY_CODE = a.dealer_code
 left join dictionary.tc_code i on i.code_id = a.gender
where a.create_time >= '2022-09-18'
and a.create_time <= '2022-09-18 23:59:59'
and a.mobile not in ('18501603377','17611357618','19822751495','16621035759','13636472669','16621030865','18758197483','15294761658','18501707590')   -- 剔除测试信息
and c.active_code = 'IBDMJULXC4RC4RNY2022VCCN'   -- 北京新能源政策宣传活动code
)x 
group by 1
order by 1


-- 5、邀请拉新记录
select a.phone,
count(case when b.if_success =1 then b.id else null end) 累计邀请人数,
if(count(case when b.if_success =1 then b.id else null end)>=20,'是','否') 是否邀请满20人,
x.create_date 邀请满20人达成时间
from volvo_online_activity.new_energy_data a     
left join volvo_online_activity.new_energy_help_record b on a.member_id =b.inviter_member_id and b.is_delete =0
left join 
	(
	#拉新20人获取奖励时间
	select a.phone,
	ROW_NUMBER ()over(PARTITION by a.phone order by b.create_date) rk,
	b.create_date
	from volvo_online_activity.new_energy_data a 
	left join volvo_online_activity.new_energy_help_record b on a.member_id =b.inviter_member_id and b.is_delete =0
	where b.if_success =1
-- 	and a.phone=18910989489
	)x on x.phone=a.phone and x.rk=20
where a.is_delete =0
and a.create_date <='2022-09-18 23:59:59'
group by 1 
order by 2 desc 


