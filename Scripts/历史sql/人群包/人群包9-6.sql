-- 9-6-1：点击活动主页【预约试驾】会跳转留资页并提交，且累计邀请人数<20人 的人群；
-- 5、邀请拉新记录
select a.phone,
count(case when b.if_success =1 then b.id else null end) 累计邀请人数
from volvo_online_activity.new_energy_data a     
left join volvo_online_activity.new_energy_help_record b on a.member_id =b.inviter_member_id and b.is_delete =0
where a.is_delete =0
and a.create_date <='2022-09-20 23:59:59'
group by 1 
order by 2 desc 


-- 4-1、预约试驾数据明细（8.1-8.14按日拉取，8.15-9.30按周拉取）
SELECT
DISTINCT ta.customer_phone 手机号
FROM cyx_appointment.tt_appointment ta
LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
WHERE ta.CREATED_AT >= '2022-08-01'
AND ta.CREATED_AT <= '2022-09-20 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMJULXC4RC4RNY2022VCCN'    -- 北京新能源政策宣传活动code
and ta.CUSTOMER_PHONE not in ('18501603377','17611357618','19822751495','16621035759','13636472669','16621030865','18758197483','15294761658','18501707590')   -- 剔除测试信息

-- 9-6-2：给他人助力，但是没有在【预约试驾】留资页点击提交的人群；
select
DISTINCT m.MEMBER_PHONE 
from track.track t
join `member`.tc_member_info m on t.usertag = CAST(m.USER_ID as VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
where t.`date` >= '2022-08-01'
and t.`date` <= '2022-09-20 23:59:59'
and ((json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击即刻前往_CLICK' and json_extract(t.`data`,'$.content') = 'Wow！真给力！')or 
(json_extract(t.`data`,'$.embeddedpoint') = '北京新能源_首页点击我知道了_CLICK' and json_extract(t.`data`,'$.content') = 'Wow！真给力！'))
and m.MEMBER_PHONE not in 
(SELECT
DISTINCT ta.customer_phone 手机号
FROM cyx_appointment.tt_appointment ta
LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
WHERE ta.CREATED_AT >= '2022-08-01'
AND ta.CREATED_AT <= '2022-09-20 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMJULXC4RC4RNY2022VCCN'    -- 北京新能源政策宣传活动code
and ta.CUSTOMER_PHONE not in ('18501603377','17611357618','19822751495','16621035759','13636472669','16621030865','18758197483','15294761658','18501707590')   -- 剔除测试信息
)
group by 1
order by 1
