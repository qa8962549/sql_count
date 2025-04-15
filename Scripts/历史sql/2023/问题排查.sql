-- 近60天是否登入小程序
 select distinct m.id,'是' 近60天是否登入小程序,m.CUST_ID 
 from track.track t 
 left join `member`.tc_member_info m on cast(m.USER_ID as varchar)=t.usertag  
 where t.`date` >='2022-12-13'
 and t.`date` <'2023-02-13'
 

-- 会员ID绑定最新车辆信息，这里rk=1取的是最新绑定
 select v.member_id,
 tm.cust_id,
 v.vin,
 v.create_time 绑车时间,
 b.first_invoice_date VIN开票时间,
 ifnull(m.MODEL_NAME,v.model_name)车型,
 b.config_year 车型年款,
 z.CONFIG_NAME 
 from (
 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin,v.create_time
 ,row_number() over(PARTITION by v.vin order by v.create_time desc) rk
 from member.tc_member_vehicle v 
 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
 where v.IS_DELETED=0 
 ) v 
 left join vehicle.tm_vehicle t on v.vin=t.VIN
 left join basic_data.tm_model m on t.MODEL_ID=m.ID
 left join `member`.tc_member_info tm on tm.id=v.member_id
 left join vehicle.tt_invoice_statistics_dms b on v.vin=b.vin 
 left join basic_data.tm_config z on b.config_id = z.ID
 where v.rk=1
--  and v.vin='LYVDF40A5FB714802'
 
-- CUST-ID
 select distinct m.id,m.CUST_ID 
 from `member`.tc_member_info m 