-- 会员ID绑定最新车辆信息，这里rk=1取的是最新绑定
 select v.member_id,
 v.vin,
 a.CREATE_TIME 订单创建时间,
 a.first_invoice_date 开票时间,
 b.MEMBER_V_NUM 当前剩余V值,
 a.dealer_code 开票经销商,
 tc.PROVINCE_NAME 经销商所在城市
--  ifnull(m.MODEL_NAME,v.model_name)车型
 from (
 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin,v.create_time
 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
 from member.tc_member_vehicle v 
 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
 where v.IS_DELETED=0 
 ) v 
 left join vehicle.tm_vehicle t on v.vin=t.VIN
 left join basic_data.tm_model m on t.MODEL_ID=m.ID
 left join vehicle.tt_invoice_statistics_dms a on a.vin =v.vin
 left join `member`.tc_member_info b on b.id=v.member_id
 left join organization.tm_company tc on tc.COMPANY_CODE = a.dealer_code 
 where v.rk=1 and v.VEHICLE_CODE='536ED'