 -- 沃世界小程序会员绑了 XC40 ERCHARGE 车型和 C40 车型的会员的memberid和oneid
 -- 根据各种条件匹配微信公众号openid
select 
DISTINCT xx.会员ID,
xx.cust_id,
xx.车型
from 
 (
select
tmi.USER_ID,
IFNULL(tmi.REAL_NAME,tmi.MEMBER_NAME) "姓名",
tmi.MEMBER_PHONE "手机号",
tmi.cust_id,
tmi.ID "会员ID",
tmi.MEMBER_URL "会员头像",
case when tmi.IS_VEHICLE='1' then '绑定'
	else '未绑定' end '是否绑定车辆',
t.VIN,
tisd.dealer_code 经销商代码,
t.车型,
tr.REGION_NAME 所在地,
tc.CODE_CN_DESC "性别",
tmi.MEMBER_BIRTHDAY "生日",
tmi.MEMBER_HOBBY "爱好兴趣"
from `member`.tc_member_info tmi 
left join
(
# 车系
 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
 from (
 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
 from member.tc_member_vehicle v 
 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
 where v.IS_DELETED=0 
 ) v 
 left join vehicle.tm_vehicle t on v.vin=t.VIN
 left join basic_data.tm_model m on t.MODEL_ID=m.ID
 where v.rk=1 
) t on tmi.id=t.member_id 
left join dictionary.tc_code tc on tc.CODE_ID =tmi.MEMBER_SEX
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE = tr.REGION_CODE
left join vehicle.tt_invoice_statistics_dms tisd on t.VIN = tisd.vin 
where tmi.IS_DELETED =0 
and tmi.MEMBER_STATUS <>60341003 and t.车型 in ('全新纯电C40','XC40 RECHARGE')
)xx