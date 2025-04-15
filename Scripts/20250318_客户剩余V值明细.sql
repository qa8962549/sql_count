--拉取所有会员的memberid和目前的V值余额
--匹配该会员最近一次进店信息
--1）       作为送修人回厂，非P非S单（不考虑车）
--
--2）       这个memberid绑定的车（包含亲友授权），对应的订单经销商
--
--3）       售前到店（客流表）
--
--4）       以上三个场景按照1  2 3的优先级排序取值，多辆车不用处理，取这个人最新的进店信息即可
select m.id,
       m.member_v_num,
       x.code `最近一次进店经销商`,
       x.t `最近一次进店时间`,
       x.`最近一次进店场景` `最近一次进店场景`,
       case when x2.`下单时间`<'2000-01-01' then null else x2.`下单时间` end as `最后一次商城消费V值的时间`
from ods_memb.ods_memb_tc_member_info_cur m
left join (
    select x.*
    from (
             select x.id,
                    x.code,
                    x.t,
                    x.`最近一次进店场景`,
                    -- 使用优先级逻辑，回厂优先级最高，购车订单进店次之，客流表到店最低
                    row_number() over (partition by x.id order by case when x.`最近一次进店场景` = '回厂' then 1
                                                                      when x.`最近一次进店场景` = '购车订单进店' then 2
                                                                      when x.`最近一次进店场景` = '客流表到店' then 3
                                                                      else 4 end, x.t desc) rk
             from (
                      --售后回厂
                      select
                              m.id,
                              o.code,
                              toDateTime(o.t) t,
                              '回厂' `最近一次进店场景`
                      from ods_memb.ods_memb_tc_member_info_cur m
                               join (
                                 -- 作为送修人回厂，非P非S单（不考虑车）
                                 select
                                         o.DELIVERER_MOBILE,
                                         o.OWNER_CODE code,
                                         o.RO_CREATE_DATE t,
                                         row_number() over (partition by o.DELIVERER_MOBILE order by o.RO_CREATE_DATE desc) rk
                                 from ods_cyre.ods_cyre_tt_repair_order_d o
                                 where 1 = 1
                                   and o.IS_DELETED = 0
                                   and o.REPAIR_TYPE_CODE not in ('P', 'S')
                                   and o.RO_STATUS = '80491003'    -- 已结算工单
--                                 and o.RO_CREATE_DATE >= today() - interval '1 year' -- 近一年
--                                 and o.RO_CREATE_DATE < today()
                                 ) o on o.DELIVERER_MOBILE = m.member_phone and o.rk = 1
                      where 1 = 1
                        and m.member_status <> '60341003'
                        and m.is_deleted = '0'
                     union all
                      -- 购车订单到店
	                 select x.id,
		                 x.company_code,
		                 x.t,
		                 x.`最近一次进店场景`
		                 from 
		                 (
							select
	                              distinct m.id id,
	                              o.company_code company_code,
	                              toDateTime(o.created_at) t,
	                              row_number() over (partition by m.id order by o.created_at desc) rk,
	                              '购车订单进店' `最近一次进店场景`
	                      from ods_memb.ods_memb_tc_member_info_cur m
	                               join ods_vocm.ods_vocm_vehicle_bind_relation_cur v on m.id::String = v.member_id::String
	                               join ods_cydr.ods_cydr_tt_sales_order_vin_cur b on v.vin_code = b.sales_vin and b.is_deleted = 0
	                               join ods_cydr.ods_cydr_tt_sales_orders_cur o on o.so_no = b.vi_no and b.is_deleted = 0
	                      where 1 = 1
	                        and v.member_id is not null
	                        and v.deleted = 0
	                        and v.is_bind = 1   -- 绑车
	                        and o.so_status in ('14041003', '14041008', '14041001', '14041002') -- 有效订单
	                        and o.business_type <> 14031002 -- 剔除退车
	                        and m.member_status <> '60341003'
	                        and m.is_deleted = '0'
	                       )x where x.rk=1
                     union all
                      -- 2、客流表到店
                      select m.id,
                             x.owner_code,
                             toDateTime(x.t) t,
                             '客流表到店' `最近一次进店场景`
                      from ods_memb.ods_memb_tc_member_info_cur m
                               join (
                                 select f.mobile_phone phone,
                                        toDateTime(left(f.arrive_date, 19)) t,
                                        f.owner_code,
                                        row_number() over (partition by f.mobile_phone order by (toDateTime(left(f.arrive_date, 19))) desc) rk
                                 from ods_cypf.ods_cypf_tt_passenger_flow_info_cur f
                                 where 1 = 1
                                   and f.is_deleted = 0
                                   and f.arrive_date >= '2000-01-01' -- 剔除空值
                                 ) x on m.member_phone = x.phone and x.rk = 1
                      where m.member_status <> '60341003'
                        and m.is_deleted = '0'
                  ) x
         ) x where x.rk = 1
    ) x on x.id::String = m.id::String
         left join
     (-- 1、商城订单明细(CK)
         select
                 a.user_id `下单人会员ID`,
                 a.create_time `下单时间`,
                 row_number() over (partition by a.user_id order by a.create_time desc) rk
         from ods_orde.ods_orde_tt_order_d a    -- 订单表
                  left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code and b.is_deleted <> 1   -- 订单商品表
         where 1 = 1
           and a.is_deleted <> 1
           and b.is_deleted <> 1
           and a.type = '31011003'  -- 订单类型：沃世界商城订单
           and a.separate_status = '10041002' -- 拆单状态：否
           and a.status not in ('51031001', '51031007') -- 订单状态:剔除预创建和创建失败订单
           and (a.close_reason not in ('51091001', '51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
           and (b.spu_type in (51121001, 51121004, 51121006, 51121007) or (b.spu_type in (51121002, 51121003) and a.status <> 51031006)) -- 剔除虚拟商品已关闭订单
           and b.point_amount > 0 --支付V值
     ) x2 on x2.`下单人会员ID` = m.id::String and x2.rk = 1
where m.member_status <> '60341003'
  and m.is_deleted = '0';