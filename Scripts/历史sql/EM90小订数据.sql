-- 修改成CK可执行
select t1.SO_NO
,t1.SO_NO_ID
,t1.SALE_TYPE
,t1.SO_STATUS
,t1.IS_DEPOSIT
,t1.OWNER_CODE
,t1.DELIVERY_OWNER_CODE
,t1.SALES_DIST_NAME_CN
,t1.SALES_AREA_NAME_CN
,toDate(t2.cancel_time) data_date
from ods_oper_crm.booking_order_snapshot t1
inner join 
(
    select *
    from (
        select t1.so_no as so_no
        ,t1.so_no_id as so_no_id
        ,t2.sale_type as sale_type
        ,t1.so_status so_status
        ,t1.is_deposit is_deposit
        ,t1.owner_code owner_code
        ,t1.record_version record_version
        ,t1.updated_at updated_at
        ,t2.cancel_time cancel_time
        ,t2.delivery_owner_code delivery_owner_code
        ,t9.SECOND_ID SECOND_ID
        ,row_number() over (PARTITION BY t1.so_no ORDER BY t1.updated_at DESC,t1.record_version desc,t1._etl_time desc) AS rn
        from ods_cydr.ods_cydr_tt_sales_orders_cur t1
       global LEFT JOIN 
        (
            select t1.vi_no,t1.delivery_owner_code,t1.cancel_time,t1.sale_type
            from 
            (
                select t1.vi_no
                ,t1.delivery_owner_code
                ,t1.cancel_time
                ,t1.sale_type,
                row_number() over (PARTITION BY t1.vi_no ORDER BY t1.updated_at DESC,t1.record_version desc,t1._etl_time desc) AS rn
                from ods_cydr.ods_cydr_tt_sales_order_vin_cur t1
                where t1.cancel_time > '2023-10-01'
                Settings allow_experimental_window_functions = 1
            ) t1
            where t1.rn = 1
        ) t2 ON t1.so_no = t2.vi_no
        LEFT JOIN ods_cydr.ods_cydr_tt_sales_order_detail_d t9 ON t1.so_no_id = t9.SO_NO_ID
        where t1.is_deleted = 0
        and t9.SECOND_ID = '1111'
        Settings allow_experimental_window_functions = 1
    ) t1
    WHERE t1.sale_type = 20131010
    and t1.so_status = 14041009
    and t1.is_deposit = 10041002
    and t1.owner_code = 'VVD'
    and t1.rn = 1
) t2 on t1.SO_NO_ID = t2.so_no_id

-- 创建本地表  
CREATE TABLE if not exists ods_oper_crm.ods_oper_crm_cyh_em90_booking_snapshot_l_si on cluster default
(
    `SO_NO` String,
    `SO_NO_ID` UInt64,
    `SALE_TYPE` Int32,
    `SO_STATUS` Int32,
    `IS_DEPOSIT` Int32,
    `OWNER_CODE` String,
    `DELIVERY_OWNER_CODE` String,
    `RECEIVE_DATE` String,
    `SALES_DIST_NAME_CN` String,
    `SALES_AREA_NAME_CN` String
)
ENGINE = ReplicatedMergeTree
ORDER BY SO_NO  -- 根据主键排序
SETTINGS index_granularity = 8192;

-- 创建分布式表
CREATE TABLE if not exists ods_oper_crm.ods_oper_crm_cyh_em90_booking_snapshot_d_si on cluster default
(
    `SO_NO` String,
    `SO_NO_ID` UInt64,
    `SALE_TYPE` Int32,
    `SO_STATUS` Int32,
    `IS_DEPOSIT` Int32,
    `OWNER_CODE` String,
    `DELIVERY_OWNER_CODE` String,
    `RECEIVE_DATE` String,
    `SALES_DIST_NAME_CN` String,
    `SALES_AREA_NAME_CN` String
)
ENGINE = Distributed('default', 'ods_oper_crm', 'ods_oper_crm_cyh_em90_booking_snapshot_l_si', rand());
-- 括号内参数依次为：cluster集群名（表示服务器集群配置），数据库名，本地表名，在读写时会根据rand()随机函数的取值来决定数据写⼊哪个分⽚(分片key)


-- 建库表sql

CREATE TABLE ods_oper_crm.booking_order_snapshot on cluster default
(

    `SO_NO` String,

    `SO_NO_ID` UInt64,

    `SALE_TYPE` Int32,

    `SO_STATUS` Int32,

    `IS_DEPOSIT` Int32,

    `OWNER_CODE` String,

    `DELIVERY_OWNER_CODE` String,

    `RECEIVE_DATE` String,

    `SALES_DIST_NAME_CN` String,

    `SALES_AREA_NAME_CN` String
)
ENGINE = Log;

CREATE TABLE ods_oper_crm.VolvoDealersContactList_20240101_base on cluster default
(

    `大区` String,

    `小区` String,

    `集团` String,

    `经销商类型` String,

    `经销商状态` String,

    `经销商代码` String,

    `区域经理` String,

    `经销商名称` String,

    `姓名` String,

    `网络学院账号` String,

    `邮箱` String,

    `手机号` UInt64,

    `岗位1` String,

    `注册到岗时间` String,

    `岗位2` String
)
ENGINE = Log;

CREATE TABLE ods_oper_crm.VolvoDealersContactList_20240101_manage on cluster default
(

    `大区` String,

    `小区` String,

    `集团` String,

    `经销商类型` String,

    `经销商状态` String,

    `经销商代码` String,

    `区域经理` String,

    `经销商名称` String,

    `姓名` String,

    `网络学院账号` String,

    `邮箱` String,

    `手机号` UInt64,

    `岗位1` String,

    `注册到岗时间` String,

    `岗位2` String
)
ENGINE = Log;