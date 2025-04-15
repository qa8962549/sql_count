-- 时间范围：2022年3月30~6月15日


-- 需求1：小程序“养修预约”功能按钮点击用户数
select
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2022-03-30' and t.`date` <= '2022-06-15 23:59:59'
and t.`data` like '%/src/pages/lovecar-package/repair-order/repair-order%'

-- 成功提交养修预约人数 需求2：小程序“养修预约”功能预约用户数
select COUNT(b.会员ID)成功提交养修预约人数 from
(select
distinct tmi.ID 会员ID
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-03-30 00:00:00' and t.`date` <= '2022-06-15 23:59:59'
and t.`data` like '%/src/pages/lovecar-package/repair-order/repair-order%')a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.COMPANY_NAME_CN "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.ID "会员ID",
       tmi.MEMBER_PHONE "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = "10041001" then "是" 
    when tam.IS_TAKE_CAR = "10041002" then "否" 
     end  "是否取车",
       case when tam.IS_GIVE_CAR = "10041001" then "是"
         when tam.IS_GIVE_CAR = "10041002" then "否"
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta.CREATED_AT "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >= '2022-03-30 00:00:00'
and ta.CREATED_AT <= '2022-06-15 23:59:59'
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID

-- 成功提交养修预约并进厂人数 需求3：小程序“养修预约”功能实际到店用户数
select COUNT(b.会员ID)成功提交养修预约并进厂人数 from
(select
distinct tmi.ID 会员ID
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-03-30 00:00:00' and t.`date` <= '2022-06-15 23:59:59'
and t.`data` like '%/src/pages/lovecar-package/repair-order/repair-order%')a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.COMPANY_NAME_CN "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.ID "会员ID",
       tmi.MEMBER_PHONE "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = "10041001" then "是" 
    when tam.IS_TAKE_CAR = "10041002" then "否" 
     end  "是否取车",
       case when tam.IS_GIVE_CAR = "10041001" then "是"
         when tam.IS_GIVE_CAR = "10041002" then "否"
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta.CREATED_AT "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >= '2022-03-30 00:00:00'
and ta.CREATED_AT < '2022-06-15'
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID
where b.养修状态 in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')