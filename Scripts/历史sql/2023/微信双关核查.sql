

SELECT
    m.vin_code vin,
    CASE
        WHEN (m.invoice != '' AND m.date_create < m.bind_date) THEN date(m.date_create)
        -- WHEN m.invoice != '' THEN date(m.date_create)
        ELSE date(m.bind_date) 
    END AS bdtime,
    date(c.new_time) subscribe_time
FROM
    (SELECT
        a.vin_code,
        a.bind_date,
        c.date_create,
        c.invoice,
        row_number () OVER ( partition BY a.vin_code ORDER BY a.bind_date DESC, c.date_create) AS rk 
    FROM
        volvo_cms.vehicle_bind_relation a
        LEFT JOIN volvo_cms.vehicle_owner_auth_detail c ON a.vin_code = c.vin_code AND a.member_id = c.user_uid AND c.deleted = 0 
    WHERE
        a.deleted = 0 
        AND a.is_owner = 1 
        AND a.is_bind = 1 ) m 
left join 
    (select
        a.vin,
        ifnull(eco.subscribe_time,eco.create_time) new_time
    from
        (select tmv.VIN ,m.id mid,IFNULL(c.union_id,u.unionid) allunionid
         from(select b.vin,b.member_id
              from(select tmv.vin,tmv.member_id,
                          row_number() over(partition by tmv.vin order by tmv.create_time desc) as rk
                  from member.tc_member_vehicle tmv
                  where tmv.is_deleted = 0) b
              where b.rk = 1) tmv
        left join member.tc_member_info m on tmv.MEMBER_ID = m.ID 
        left join customer.tm_customer_info c on c.id=m.cust_id
        left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid
        where m.member_status<>60341003 and m.is_deleted=0 
        and tmv.vin='YV1LF06E6N1834574'
        ) a
    left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
    -- 状态为关注
    where eco.subscribe_status = 1) c on m.vin_code = c.vin
WHERE
    m.rk=1
  and m.vin_code in ('YV1LF06E6N1834574'
)
    
 
    
 select 
    tisd.dealer_code 开票经销商,
    YEAR(tisd.first_invoice_date) 年,
    month(tisd.first_invoice_date) 月,
    tisd.vin 车架号,
    tisd.resource 发票来源,
    tisd.salesType 'Vista销售类型',
    date_format(tisd.first_invoice_date,'%Y-%m-%d') '开票时间'
from vehicle.tt_invoice_statistics_dms tisd 
where tisd.first_invoice_date >= '2021-11-01'
and tisd.IS_DELETED = 0
and tisd.vin in ('YV1LF06E6N1834574'
)

select *
from volvo_cms.vehicle_bind_relation a
where a.vin_code in ('YV1LF06E6N1834574'
)

select a.member_id ID,
tmi.MEMBER_NAME 昵称,
tmi.REAL_NAME 姓名,
a.dealer_code ,
a.vin_code ,
a.phone ,
a.event_type ,
x.开票时间,
a.operate_date 
from volvo_cms.vehicle_bind_record a
left join `member`.tc_member_info tmi  on tmi.id=a.member_id 
left join (select 
    tisd.dealer_code 开票经销商,
    YEAR(tisd.first_invoice_date) 年,
    month(tisd.first_invoice_date) 月,
    tisd.vin 车架号,
    tisd.resource 发票来源,
    tisd.salesType 'Vista销售类型',
    date_format(tisd.first_invoice_date,'%Y-%m-%d') '开票时间'
from vehicle.tt_invoice_statistics_dms tisd 
where tisd.first_invoice_date >= '2021-11-01'
and tisd.IS_DELETED = 0
)x on x.车架号=a.vin_code
where a.vin_code in ('YV1LF06E6N1834574'
)
order by 5,9



select
tcc.business_id,
a.PROVINCE_NAME 省份,
a.CITY_NAME 城市,
tcb.OWNER_CODE 经销商代码,
tcc.name 客户姓名,
tcc.mobile 客户电话,
tm.MODEL_NAME 线索意向车型,
tcc.create_time 
FROM customer.tt_clue_clean tcc  -- *-------------------------------------线索表(线索、潜客、小程序关联相关)
left join customer_business.tt_customer_business tcb -- *-----------------商机表 
  on tcc.business_id= tcb.CUSTOMER_BUSINESS_ID -- ----------------商机ID
  -- -----------------------------------------------------inner join 内链接(交集)
inner join (
SELECT a.company_code,a.CITY_NAME,a.PROVINCE_NAME 
FROM organization.tm_company a -- *-----------------------------------经销商库   company_code 经销商代码
WHERE a.CITY_NAME REGEXP '昆明市'
)a on a.COMPANY_CODE = tcb.OWNER_CODE -- --------------------------经销商代码
-- left join activity.cms_active c on tcc.campaign_id = c.uid -- ---------------------------------------------活动表 --活动ID
-- left join customer_business.tm_clue_source d on d.ID = c.active_channel -- 商机库.活动的来源渠道表   活动渠道的代码
left join basic_data.tm_model tm on tcc.model_id = tm.id -- 基础库.车辆信息表--车型ID tcc.model_id ----1027
where tcc.create_time >= '2021-09-01 00:00:00' 
and tcc.create_time < '2022-09-01 00:00:00' 
and tcb.NEW_ACTION_TIME < '2022-03-01 00:00:00'
and tcc.`clue_status` not in (70001012,70001013) 
and tcc.name = '王发春'
-- GROUP BY tcc.mobile;