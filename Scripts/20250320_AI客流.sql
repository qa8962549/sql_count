汇总sheet页里的“经销商及卫星店（18点前）”的A-H列如图（其中城市中心店和品牌体验店需要剔除）：
--数据源：rds-mysql-newbie-prod-sales-shanghai1
--cyx_passenger_flow
select
    date(tfai.snap_time) 进店日期,
    count(1) as 进店客流人数含未划拨,
    count(case when tfai.passenger_group='87671005' then tfai.id else null end) 非客人数,count(case when tfai.passenger_group='87671004' then tfai.id else null end) 工作人员人数,count(case when tfai.passenger_group='87671001' then tfai.id else null end) 看车客户人数,count(case when tfai.passenger_group='87671002' then tfai.id else null end) 订车客户人数,count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661001 then tfai.id end) 看车客户人数ai识别,count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661002 then tfai.id end) 看车客户人数人工补录
from cyx_passenger_flow.tt_passenger_flow_ai_info tfai
where tfai.snap_time >= '2025-03-18 00:00:00'and tfai.snap_time <'2025-03-18 18:00:00'
and tfai.is_deleted = 0
and hour(snap_time) <= 18
--剔除城市中心店及品牌体验店
and tfai.owner_code not in (
'CDAD02',
'CSFD01',
'NJGD01',
'NJFD01',
'QDAD01',
'XMED01',
'SYAD01',
'JNFD01',
'WHCD01',
'WZFD01',
'SUBD01',
'TJED01',
'HKAD01',
'NCCD01',
'TJDD01',
'SZFD02',
'BJPD02',
'SHKD01',
'GZJD01',
'GZHD01',
'SHOD01',
'GZKD01',
'SZFD01',
'BJRD01',
'CDAD01',
'SHID01',
'GZED01',
'SHFD01',
'GZBD01',
'HZHD01',
'SZHD01',
'CDED01',
'SZID01',
'SZED01',
'SZJD02',
'SZJD01',
'BJPD01',
'HZID01',
'CDFD01',
'SHND01',
'SHCD01',
'SHLD01',
'SHJD01',
'SHGD01',
'IHZD01',
'ICDD01',
'ISHD02',
'IGZD01',
'ISZD01',
'IBJD01',
'ISHD01',
'USD')
group by date(snap_time);

--汇总sheet页里的“经销商及卫星店（18点后）”的A-H列如图（其中城市中心店和品牌体验店需要剔除）： 
--数据源：rds-mysql-newbie-prod-sales-shanghai1
--cyx_passenger_flow
select
    date(tfai.snap_time) 进店日期,
    count(1) as 进店客流人数含未划拨,count(case when tfai.passenger_group='87671005' then tfai.id else null end) 非客人数,count(case when tfai.passenger_group='87671004' then tfai.id else null end) 工作人员人数,count(case when tfai.passenger_group='87671001' then tfai.id else null end) 看车客户人数,count(case when tfai.passenger_group='87671002' then tfai.id else null end) 订车客户人数,count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661001 then tfai.id end) 看车客户人数ai识别,count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661002 then tfai.id end) 看车客户人数人工补录
from cyx_passenger_flow.tt_passenger_flow_ai_info tfai
where tfai.snap_time >= '2025-03-18 00:00:00'and tfai.snap_time <'2025-03-19 00:00:00'
and tfai.is_deleted = 0
and hour(snap_time)>= 18
and tfai.owner_code not in (
'CDAD02',
'CSFD01',
'NJGD01',
'NJFD01',
'QDAD01',
'XMED01',
'SYAD01',
'JNFD01',
'WHCD01',
'WZFD01',
'SUBD01',
'TJED01',
'HKAD01',
'NCCD01',
'TJDD01',
'SZFD02',
'BJPD02',
'SHKD01',
'GZJD01',
'GZHD01',
'SHOD01',
'GZKD01',
'SZFD01',
'BJRD01',
'CDAD01',
'SHID01',
'GZED01',
'SHFD01',
'GZBD01',
'HZHD01',
'SZHD01',
'CDED01',
'SZID01',
'SZED01',
'SZJD02',
'SZJD01',
'BJPD01',
'HZID01',
'CDFD01',
'SHND01',
'SHCD01',
'SHLD01',
'SHJD01',
'SHGD01',
'IHZD01',
'ICDD01',
'ISHD02',
'IGZD01',
'ISZD01',
'IBJD01',
'ISHD01',
'USD')
group by date(snap_time)

--全网（含城市中心店&品牌体验店）18点前：
--数据源：rds-mysql-newbie-prod-sales-shanghai1
--cyx_passenger_flow
select
    date(tfai.snap_time) 进店日期,
    count(1) as 进店客流人数含未划拨,count(case when tfai.passenger_group='87671005' then tfai.id else null end) 非客人数,count(case when tfai.passenger_group='87671004' then tfai.id else null end) 工作人员人数,count(case when tfai.passenger_group='87671001' then tfai.id else null end) 看车客户人数,count(case when tfai.passenger_group='87671002' then tfai.id else null end) 订车客户人数,count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661001 then tfai.id end) 看车客户人数ai识别,count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661002 then tfai.id end) 看车客户人数人工补录
from cyx_passenger_flow.tt_passenger_flow_ai_info tfai
where tfai.snap_time >= '2025-03-18 00:00:00'and tfai.snap_time <'2025-03-18 18:00:00'
and tfai.is_deleted = 0
and hour(snap_time) <= 18
group by date(snap_time)

--全网（含城市中心店&品牌体验店）18点前：
--数据源：rds-mysql-newbie-prod-sales-shanghai1
--cyx_passenger_flow
select
    date(tfai.snap_time) 进店日期,
    count(1) as 进店客流人数含未划拨,count(case when tfai.passenger_group='87671005' then tfai.id else null end) 非客人数,count(case when tfai.passenger_group='87671004' then tfai.id else null end) 工作人员人数,count(case when tfai.passenger_group='87671001' then tfai.id else null end) 看车客户人数,count(case when tfai.passenger_group='87671002' then tfai.id else null end) 订车客户人数,count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661001 then tfai.id end) 看车客户人数ai识别,count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661002 then tfai.id end) 看车客户人数人工补录
from cyx_passenger_flow.tt_passenger_flow_ai_info tfai
where tfai.snap_time >= '2025-03-18 00:00:00'and tfai.snap_time <'2025-03-19 00:00:00'
and tfai.is_deleted = 0
and hour(snap_time)>= 18
group by date(snap_time)


--明细sheet页里18点前的（需增加18点前这个字段）：
select
    date(tfai.snap_time) 进店日期,
    tfai.owner_code 进店经销商,
    '18点前' 时间,
    count(1) as 进店客流人数含未划拨,
    count(case when tfai.passenger_group='87671005' then tfai.id else null end) 非客人数,
    count(case when tfai.passenger_group='87671004' then tfai.id else null end) 工作人员人数,
    count(case when tfai.passenger_group='87671001' then tfai.id else null end) 看车客户人数,
    count(case when tfai.passenger_group='87671002' then tfai.id else null end) 订车客户人数,
    count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661001 then tfai.id end) 看车客户人数ai识别,
    count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661002 then tfai.id end) 看车客户人数人工补录
from cyx_passenger_flow.tt_passenger_flow_ai_info tfai
where tfai.snap_time >= '2025-03-18 00:00:00'and tfai.snap_time <'2025-03-18 18:00:00'
and tfai.is_deleted = 0
and hour(snap_time) <= 18
group by date(snap_time),tfai.owner_code

--明细sheet页里18点后的（需增加18点后这个字段）：
select
    date(tfai.snap_time) 进店日期,
    tfai.owner_code 进店经销商,
    '18点后' 时间,
    count(1) as 进店客流人数含未划拨,count(case when tfai.passenger_group='87671005' then tfai.id else null end) 非客人数,count(case when tfai.passenger_group='87671004' then tfai.id else null end) 工作人员人数,count(case when tfai.passenger_group='87671001' then tfai.id else null end) 看车客户人数,count(case when tfai.passenger_group='87671002' then tfai.id else null end) 订车客户人数,count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661001 then tfai.id end) 看车客户人数ai识别,count(distinct case when tfai.passenger_group=87671001 and tfai.data_sources=87661002 then tfai.id end) 看车客户人数人工补录
from cyx_passenger_flow.tt_passenger_flow_ai_info tfai
where tfai.snap_time >= '2025-03-18 00:00:00'and tfai.snap_time <'2025-03-19 00:00:00'
and tfai.is_deleted = 0
and hour(snap_time) >= 18
group by date(snap_time),tfai.owner_code


其中黄色列均为函数计算而得
再将#DIV/0! 替换为空值
在原报表样例的基础上新增每天的前一天的部分（进店日期为2024-01-01至发送日期的前一天）



--test
--明细sheet页里18点后的（需增加18点后这个字段）：
select
    count(1) as 进店客流人数含未划拨,
    count(case when hour(snap_time) >= 18 then 1 else null end ) as `18点前进店客流人数含未划拨`,
    count(case when hour(snap_time) <= 18 then 1 else null end ) as `18后进店客流人数含未划拨`,
    count(case when hour(snap_time) = 18 then 1 else null end ) as `18前进店客流人数含未划拨`
    from cyx_passenger_flow.tt_passenger_flow_ai_info tfai
where tfai.snap_time >= '2025-03-26 00:00:00'
and tfai.snap_time <'2025-03-27 00:00:00'
and tfai.is_deleted = 0
--and hour(snap_time) >= 18



select
    hour(snap_time),
    date(tfai.snap_time) 进店日期,
    tfai.snap_time
from cyx_passenger_flow.tt_passenger_flow_ai_info tfai
where tfai.snap_time >= '2025-03-18 00:00:00'and tfai.snap_time <'2025-03-18 18:00:00'
and tfai.is_deleted = 0
and hour(snap_time) <= 18
order by 1 desc 



--明细sheet页里18点后的（需增加18点后这个字段）：
select
    hour(snap_time),
    date(tfai.snap_time) 进店日期,
    tfai.snap_time
    from cyx_passenger_flow.tt_passenger_flow_ai_info tfai
where tfai.snap_time >= '2025-03-18 00:00:00'and tfai.snap_time <'2025-03-19 00:00:00'
and tfai.is_deleted = 0
and hour(snap_time) >= 18
order by 1  