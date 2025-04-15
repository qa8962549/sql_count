--# 爱好表
select * from dictionary.tc_code tc where tc.IS_DELETED = 0
and tc.CODE_ID like '%6058100%'

-- 根据手机号匹配相关数据会员常用信息
select
distinct 
tmi.USER_ID,
-- IFNULL(tmi.REAL_NAME,tmi.MEMBER_NAME) "姓名",
tmi.MEMBER_PHONE "手机号",
tmi.ID,
-- tso.CUSTOMER_TEL 潜客手机号,
-- tso.DRAWER_TEL 开票人手机号,
-- YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4) 年龄,
-- case when (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))<=25 then '<=25'
-- 	when (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))>25 and (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))<=30 then '26-30'
-- 	when (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))>30 and (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))<=35 then '31-35'
-- 	when (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))>35 and (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))<=40 then '36-40'
-- 	when (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))>40 and (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))<=45 then '41-45'
-- 	when (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))>45 and (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))<=50 then '46-50'
-- 	when (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))>50 and (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))<=55 then '51-55'
-- 	when (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))>55 and (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))<=60 then '56-60'
-- 	when (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))>60 and (YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4))<=65 then '61-65'
-- else null end 年龄,
tmi.ID "会员ID",
-- case when tmi.IS_VEHICLE='1' then '绑定'
-- 	else '未绑定' end '是否绑定车辆',
t.VIN,
tisd.dealer_code 经销商代码,
tisd.first_invoice_date 开票时间,
DATEDIFF('DAY',t.CREATE_TIME，CURDATE()) 车龄 ,
-- tisd.certificate_no 身份证号码,
-- t.车型,
tr.REGION_NAME 所在地,
case when substring(tisd.certificate_no,17,1)%2=1 and length(tisd.certificate_no) =18 then "男" 
	when substring(tisd.certificate_no,17,1)%2=0 and length(tisd.certificate_no) =18 then "女"
--	end 性别2,
-- tc.CODE_CN_DESC "性别",
-- tmi.MEMBER_BIRTHDAY "生日",
t.vin,
YEAR(NOW())- SUBSTRING(tisd.certificate_no,7,4) 年龄
--CONCAT_WS(','
--,tc2.CODE_CN_DESC
--,tc3.CODE_CN_DESC
--,tc4.CODE_CN_DESC 
--,tc5.CODE_CN_DESC 
--,tc6.CODE_CN_DESC 
--,tc7.CODE_CN_DESC 
--,tc8.CODE_CN_DESC )爱好兴趣,
--tmi.MEMBER_HOBBY "爱好兴趣"
from `member`.tc_member_info tmi 
left join
	(
	--# 车系
	 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型,v.create_time
	 from (
	 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin,v.create_time
	 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
	 from member.tc_member_vehicle v 
	 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
	 where v.IS_DELETED=0 
	 ) v 
	 left join vehicle.tm_vehicle t on v.vin=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	--  where v.rk=1
) t on tmi.id=t.member_id
left join dictionary.tc_code tc on tc.CODE_ID =tmi.MEMBER_SEX
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE = tr.REGION_CODE
left join vehicle.tt_invoice_statistics_dms tisd on t.VIN = tisd.vin 
left join cyxdms_retail.tt_sales_order_vin x on t.VIN =x.SALES_VIN 
left join cyxdms_retail.tt_sales_orders tso on x.VI_NO = tso.SO_NO
--left join dictionary.tc_code tc2 on tc2.CODE_ID =TRIM(SUBSTRING_INDEX(tmi.MEMBER_HOBBY, ',', 1))
--left join dictionary.tc_code tc3 on tc3.CODE_ID =TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(MEMBER_HOBBY, ',', 2), ',', -1))
--left join dictionary.tc_code tc4 on tc4.CODE_ID =TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(MEMBER_HOBBY, ',', 3), ',', -1))
--left join dictionary.tc_code tc5 on tc5.CODE_ID =TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(MEMBER_HOBBY, ',', 4), ',', -1))
--left join dictionary.tc_code tc6 on tc6.CODE_ID =TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(MEMBER_HOBBY, ',', 5), ',', -1))
--left join dictionary.tc_code tc7 on tc7.CODE_ID =TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(MEMBER_HOBBY, ',', 6), ',', -1))
--left join dictionary.tc_code tc8 on tc8.CODE_ID =TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(MEMBER_HOBBY, ',', 7), ',', -1))
--left join dictionary.tc_code tc9 on tc9.CODE_ID =TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(MEMBER_HOBBY, ',', 8), ',', -1))
where tmi.IS_DELETED =0 
and tmi.MEMBER_STATUS <>60341003
and tmi.MEMBER_PHONE in ('13816541071',
'15068717476',
'15221818317',
'13912970763',
'18654323211',
'18602517551',
'18653711115',
'13320389699',
'18221965495',
'18851910596',
'13818481519',
'15721080115',
'13866779511',
'15021337104',
'18651335559',
'19121613221',
'18916333773',
'13761440689',
'15800581380',
'15689189807',
'13662038200',
'13404600333',
'13951947738',
'17671118999',
'18668920307',
'13968963601',
'13811998159',
'15046660299',
'13817237472',
'13880706380',
'13662017577',
'13801095026',
'18688131696',
'18220832882',
'13832282220',
'13299033107',
'13991318313',
'15850659820',
'13763021834',
'18690212060')

select d.vin,d.dealer_code,d.invoice_date from vehicle.tt_invoice_statistics_dms d
where d.IS_DELETED = 0
and d.vin in 
()
