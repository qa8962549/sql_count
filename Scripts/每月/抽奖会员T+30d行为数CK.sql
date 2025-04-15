
-- 抽奖活动人群在T+30d的行为数据统计
select 
    a.member_id 
    ,case when m.is_vehicle = '1' then '车主'
        when m.is_vehicle = '0' then '粉丝'
    end `当前是否车主`
    ,tl.level_name `会员等级`
    ,ifnull(e.num,0) `历史累计绑定vin数`
    ,m.member_c_num `当前累计成长值`
    ,x1.num `抽奖后30天内登录天数`
    ,ifnull(c.num,0) `抽奖后30天内任务数`
    ,ifnull(ft3.num_wenzhang,0) `抽奖后30天内社区发文章数`
    ,ifnull(ft3.num_dongtai,0) `抽奖后30天内社区发动态数`
    ,ifnull(ft2.pinglun,0) `抽奖后30天内社区发评论数`
    ,ifnull(ft1.dianzan,0) `抽奖后30天内点赞数`,
ifnull(ft4.PV,0) `抽奖后30天内浏览数`,
ifnull(ft5.zhuanfa,0) `抽奖后30天内转发数`,
ifnull(f.yangxiu,0) `抽奖后30天预约养修次数`,
ifnull(f2.shijia,0) `抽奖后30天预约试驾次数`,
ifnull(f3.yaoyue,0) `抽奖后30天邀约试驾邀请次数`,
ifnull(d.num_cash,0) `抽奖后30天内商城现金消费次数`,
ifnull(d.num_v,0) `抽奖后30天内商城V值消费次数`,
ifnull(d.sum_cash,0) `抽奖后30天内商城现金消费金额`,
ifnull(d.sum_v,0) `抽奖后30天内商城V值消费金额`
FROM (--42,780
    select
    a.member_id member_id
    ,m.cust_id cust_id
    from ods_voam.ods_voam_lottery_draw_log_d a
    left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.member_id) =toString(m.id)
    where 1=1
    and a.lottery_code='memberday-2409' and date(a.create_time) ='2024-09-25'
    group by 1,2
)a
left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.member_id)=toString(m.id) 
left join ods_memb.ods_memb_tc_level_cur tl on toString(m.level_id)= toString(tl.level_code) and tl.is_deleted =0 and tl.status =0
left join (
    select distinct_id,count(distinct e.date) num 
    from dwd_23.dwd_23_gio_tracking e
    where 1=1
    and event_time>='2024-10-26'
    and date>='2024-10-26'
    and date<'2024-11-25'
    and LENGTH(distinct_id)<=9
    group by distinct_id
)x1 on toString(x1.distinct_id) =toString(a.cust_id)
left join (-- 0点赞 1收藏
    select
     a.member_id ,
    count(case when a.like_type=0 then 1 end) dianzan,
    count(case when a.like_type=1 then 1 end) shoucang
    from ods_cmnt.ods_cmnt_tt_like_post_cur a
    left join ods_cmnt.ods_cmnt_tm_post_cur b on a.post_id =b.post_id 
    where a.is_deleted =0
    and a.create_time >='2024-10-26'
    and a.create_time <'2024-11-25'
    group by member_id
)ft1 on toString(ft1.member_id)=toString(a.member_id)
left join (-- 评论
        select 
        a.member_id ,
        count(1) pinglun
        from ods_cmnt.ods_cmnt_tm_comment_cur a
        where a.is_deleted=0
        and a.create_time >='2024-10-26'
        and a.create_time <'2024-11-25'
        group by member_id
)ft2 on toString(ft2.member_id)=toString(a.member_id)
left join (-- 发帖数量
    select 
    tp.member_id,
    count(case when tp.post_type=1001 then tp.post_id end ) num_dongtai,
    count(case when tp.post_type=1007 then tp.post_id end ) num_wenzhang
    from ods_cmnt.ods_cmnt_tm_post_cur tp
    where 1=1
    and tp.create_time >='2024-10-26'
    and tp.create_time <'2024-11-25'
    and tp.is_deleted =0
    group by member_id
)ft3 on toString(ft3.member_id)=toString(a.member_id)
left join (-- 帖子的PVUV
    select 
    a.member_id ,
    count(a.member_id) PV
    from ods_cmnt.ods_cmnt_tt_view_post_cur a
    where 1=1
    and a.create_time >='2024-10-26'
    and a.create_time <'2024-11-25'
    and a.is_deleted =0
    group by member_id
)ft4 on toString(ft4.member_id)=toString(a.member_id)
left join (
    select a.distinct_id ,
    count(1) zhuanfa
    from dwd_23.dwd_23_gio_tracking a
    where 1=1
    and event_time>='2024-10-26'
    and date>='2024-10-26'
    and date<'2024-11-25'
    and LENGTH(distinct_id)<9
    and (event ='Button_click' and btn_name in ('微信好友','朋友圈'))
    group by distinct_id
)ft5 on toString(ft5.distinct_id)=toString(a.cust_id)
left join (
    -- 绑车
    select x.member_id,
    count(distinct x.vin_code) num 
    from (
        select
        r.member_id,
        r.bind_date,
        r.vin_code
        from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
        where r.deleted = 0
        and r.member_id is not null 
        and r.member_id <>''
        and r.is_bind = 1   -- 绑车
        and r.bind_date<'2024-11-25'
    )x
    group by member_id
)e on e.member_id=a.member_id
left join (
    select t.member_id,
            COUNT(t.member_id) num
    FROM ods_memb.ods_memb_tt_member_score_record_cur t
    left join ods_memb.ods_memb_tc_member_info_cur b on toString(t.member_id) = toString(b.id) 
    WHERE 1=1
    and (t.event_type in ('60731011','60731003','60731013','60731041','60731052','60731049','60731055','60731006','60731050','60731051','60731056','60731054','60741230','60741231') or 
        t.event_desc in('完成App文章浏览（10秒）任务','完成App签到任务','完成App社区点赞任务','完成App文章加精任务','完成App文章被推荐任务','完成WOW商城每月首次下单任务')) -- 任务类型
    and t.create_time >= '2024-10-26' 
    and t.create_time < '2024-11-25'
    and t.is_deleted =0 
    and b.member_status<>'60341003'
    GROUP by member_id
)c on toString(c.member_id)=toString(a.member_id)
left join (
    select x.user_id,
    count(case when x.`支付方式` in ('纯现金支付','混合支付')then 1 else null end) num_cash,-- `抽奖后30天内商城现金消费次数`,
    count(case when x.`支付方式` ='纯V值支付' then 1 else null end) num_v,-- `抽奖后30天内商城V值消费次数`,
    sum(case when x.`支付方式` in ('纯现金支付','混合支付') then x.`实付金额` else 0 end) sum_cash,-- `抽奖后30天内商城现金消费金额`,
    sum(case when x.`支付方式` ='纯V值支付' then x.`实付金额` else 0 end) sum_v-- `抽奖后30天内商城V值消费金额`
    from 
        (select a.order_code `订单编号`
        ,b.product_id `商城兑换id`
        ,a.user_id as user_id
        ,a.user_name `会员姓名`
        ,b.spu_name `兑换商品`
        ,b.spu_id
        ,b.sku_id
        ,b.spu_bus_id
        ,b.sku_code
        ,b.sku_real_point `商品单价`
        ,b.fee/100 `总金额`
        ,b.coupon_fee/100 `优惠券抵扣金额`
        ,round(b.point_amount/3+b.pay_fee/100,2) `实付金额`
        ,b.pay_fee/100 `现金支付金额`
        ,b.point_amount `支付V值`
        ,b.sku_num `兑换数量`
        ,a.create_time `兑换时间`
        ,case 
            when b.pay_fee=0 then '纯V值支付'
            when b.point_amount=0 then '纯现金支付' else '混合支付' end `支付方式`
        ,f.name `分类`
        ,e.`退货状态` `退货状态`
        ,e.`退货数量` `退货数量`
        ,e.`退回V值` `退回V值`
        ,e.`退回时间` `退回时间`
        from ods_orde.ods_orde_tt_order_d a  -- 订单主表
        left join ods_orde.ods_orde_tt_order_product_d  b on a.order_code = b.order_code  -- 订单商品表
        left join (
            -- 清洗cust_id
            select m.*
            from 
                (-- 清洗cust_id
                select m.*,
                row_number() over(partition by m.cust_id order by m.create_time desc) rk
                from ods_memb.ods_memb_tc_member_info_cur m
                where m.member_status<>'60341003' and m.is_deleted=0
                and m.cust_id is not null 
                Settings allow_experimental_window_functions = 1
                ) m
            where m.rk=1) h on toString(a.user_id) = toString(h.id)   -- 会员表(获取会员信息)
        left join ods_good.ods_good_item_spu_d j on b.spu_id = j.id   -- 前台spu表(获取商品前台专区ID)
        left join ods_good.ods_good_front_category_d f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
        left join(
        --  #V值退款成功记录
            select so.order_code
            ,sp.product_id
            ,CASE 
                WHEN so.status ='51171001' THEN '待审核'
                WHEN so.status ='51171002' THEN '待退货入库'
                WHEN so.status ='51171003' THEN '待退款'
                WHEN so.status ='51171004' THEN '退款成功'
                WHEN so.status ='51171005' THEN '退款失败'
                WHEN so.status ='51171006' THEN '作废退货单' END as `退货状态`
            ,sum(sp.sales_return_num) `退货数量`
            ,sum(so.refund_point) `退回V值`
            ,max(so.create_time) `退回时间`
            from ods_orde.ods_orde_tt_sales_return_order_d so
            left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code=sp.refund_order_code 
            where so.is_deleted = 0 
            and so.status='51171004' -- 退款成功
            and sp.is_deleted=0
            GROUP BY order_code,product_id,`退货状态`
        ) e on a.order_code = e.order_code and b.product_id =e.product_id 
        where 1=1
        and toDate(a.create_time) >= '2024-10-26' 
        and toDate(a.create_time) < '2024-11-25'   -- 订单时间
        and a.is_deleted <> 1  -- 剔除逻辑删除订单
        and b.is_deleted <> 1
        and h.is_deleted <> 1
    --  and j.front_category_id is not null
        and a.type = 31011003  -- 筛选沃世界商城订单
        and a.separate_status = 10041002 -- 选择拆单状态否
        and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
        AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
        and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
        and e.order_code is null  -- 剔除退款订单
        order by a.create_time)x
        group by x.user_id
)d on toString(d.user_id) =toString(a.member_id )
left join ( -- 养修预约
    select ta.ONE_ID oneid,
    count(1) yangxiu
    from ods_cyap.ods_cyap_tt_appointment_d ta
    left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
    where 1=1
    and tam.IS_DELETED =0
    and ta.CREATED_AT >= '2024-10-26'
    and ta.CREATED_AT < '2024-11-25'
    and ta.DATA_SOURCE ='C'
    and ta.APPOINTMENT_TYPE =70691005
    group by oneid
)f on toString(f.oneid) =toString(a.cust_id )
left join (-- 预约试驾
    select ta.ONE_ID oneid,
    count(1) shijia
    from ods_cyap.ods_cyap_tt_appointment_d ta
    where 1=1
    and ta.CREATED_AT >= '2024-10-26'
    and ta.CREATED_AT < '2024-11-25'
    and ta.DATA_SOURCE ='C'
    and ta.APPOINTMENT_TYPE in (70691002,70691001)
    group by oneid
)f2 on toString(f2.oneid) =toString(a.cust_id )
left join (-- 邀约试驾 当月总留资量
    SELECT 
        t2.member_id as member_id,
        count(1) yaoyue
    FROM ods_invi.ods_invi_tm_invite_code_d t2
    left join ods_invi.ods_invi_tm_invite_record_d t1 on t1.invite_code = t2.code 
    left join ods_memb.ods_memb_tc_member_info_cur tmi on t2.member_id = tmi.id
    WHERE 1=1
    and t2.create_time >= '2024-10-26' 
    and t2.create_time < '2024-11-25'
    group by member_id
)f3 on toString(f3.member_id) =toString(a.member_id)


select
a.member_id,
a.nick_name 姓名,
case when d.is_vehicle =1 then '是' 
     when d.is_vehicle =0 then '否' 
     end as 是否车主,
case when d.level_id=1 then '银卡'
     when d.level_id=2 then '金卡'
     when d.level_id=3 then '白金卡'
     when d.level_id=4 then '黑卡'
     end as 会员等级,
d.MEMBER_PHONE 沃世界注册手机号,
case when a.have_win = '1' then '中奖'
    when a.have_win = '0' then '未中奖'
    end 是否中奖,
a.create_time 抽奖时间,
b.prize_name 中奖奖品,
b.prize_level_nick_name 奖品等级,
a.lottery_code ,
a.lottery_play_code,
lpi.lottery_play_name 奖池名称
from volvo_online_activity_module.lottery_draw_log a
left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code and b.is_deleted =0
left join volvo_online_activity_module.lottery_play_init lpi on lpi.lottery_play_code =a.lottery_play_code 
left join `member`.tc_member_info d on a.member_id = d.ID
where 1=1
and date(a.create_time) ='2024-11-25'
and a.lottery_code='memberday-2411'
and a.have_win = 1   -- 中奖
order by a.create_time


select 
	id
	,lottery_play_code 
	,prize_name 奖品名称
	,prize_type 奖品类型
	,prize_level_nick_name 奖品等级
	,full_number `奖品总数(-1表示不限量)`
	,if(win_rate=0,null,win_rate/1000000) as 中奖率
from volvo_online_activity_module.lottery_play_pool lpp 
where 1=1
and lottery_play_code like 'memberday-2411%'
and is_deleted =0
order by id

--表1 中奖名单 领取卡券/权益ID
SELECT  
    a.member_id 
    ,d.member_name 姓名
    ,case when d.is_vehicle =1 then '是' 
     when d.is_vehicle =0 then '否' 
     end as 是否车主
    ,case when d.level_id=1 then '银卡'
         when d.level_id=2 then '金卡'
         when d.level_id=3 then '白金卡'
         when d.level_id=4 then '黑卡'
     end as 会员等级
    ,rights_config_id `领取卡券/权益ID`
    ,CONCAT(c.rights_name,c.rights_sketch) `权益名称/卡券名称`
    ,'领取权益' `类型`
FROM member_rights.tt_member_get_record a
left join member_rights.tc_member_rights_config b on a.rights_config_id = b.id 
LEFT JOIN member_rights.tm_member_rights c on b.rights_id = c.id 
LEFT JOIN `member`.tc_member_info d on a.member_id = d.ID
WHERE a.is_deleted=0
and date(a.create_time) = '2024-11-25'
union all
select
    tcd.member_id 
    ,d.member_name 姓名
    ,case when d.is_vehicle =1 then '是' 
     when d.is_vehicle =0 then '否' 
     end as 是否车主
    ,case when d.level_id=1 then '银卡'
         when d.level_id=2 then '金卡'
         when d.level_id=3 then '白金卡'
         when d.level_id=4 then '黑卡'
     end as 会员等级
     ,tcd.coupon_id `领取卡券/权益ID`
     ,tci.coupon_name `权益名称/卡券名称`
     ,'领取卡券' `类型`
from coupon.tt_coupon_detail tcd
left join `member`.tc_member_info d on d.id=tcd.member_id
left join coupon.tt_coupon_info tci on tci.id =tcd.coupon_id
where 1=1
and tcd.coupon_id in (8050,8051,8052,8053,8054)--会员日里卡券id
and date(tcd.get_date) = '2024-11-25'
and tcd.is_deleted =0





---------------------------------------以下sql不用

--表2 权益价值明细（单个价值和数量）
SELECT  
    distinct rights_config_id `领取卡券/权益ID`
    ,CONCAT(c.rights_name,c.rights_sketch) `权益名称/卡券名称`
    ,'-1'`权益库存数量`
FROM member_rights.tt_member_get_record a
left join member_rights.tc_member_rights_config b on a.rights_config_id = b.id 
LEFT JOIN member_rights.tm_member_rights c on b.rights_id = c.id 
LEFT JOIN `member`.tc_member_info d on a.member_id = d.ID
WHERE a.is_deleted=0
and date(a.create_time) = '2024-11-25'

union all
select
distinct 
     tcd.coupon_id `领取卡券/权益ID`
     ,tci.coupon_name `权益名称/卡券名称`
     ,case when exist_limit=31101002 then '-1' else total_get end `权益库存数量`
     ,coupon_value/100 `权益价值(元)`
from coupon.tt_coupon_detail tcd
left join `member`.tc_member_info d on d.id=tcd.member_id
left join coupon.tt_coupon_info tci on tci.id =tcd.coupon_id
where 1=1
and tcd.coupon_id in (8050,8051,8052,8053,8054)--会员日里卡券id
and date(tcd.get_date) = '2024-11-25'
and tcd.is_deleted =0
