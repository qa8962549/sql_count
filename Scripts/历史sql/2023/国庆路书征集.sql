-- 国庆路书征集长图文   pageId":"h3c5XLUQ17     
-- 路书征集长图文头条：  UDAnN5Y2Ni

-- 注意审核时间，导致每次的发文周期内审核时间的变化，导致数量的不一致


select * from track.track t where t.usertag = '6631762' order by t.`date` desc
-- PV UV 车主数 粉丝数 游客数 点赞量 转发量 收藏量
select o.ref_id,c.title-- ,c.上线时间
				,sum(case when o.type='VIEW' then 1 else 0 end)  PV
				,count(distinct case when o.type='VIEW' then o.user_id else null end) UV
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=1 then o.user_id else null end) 车主数
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=0 then o.user_id else null end) 粉丝数
				,count(DISTINCT case when o.type='VIEW' and m.id is null then o.user_id else null end) 游客数
				,sum(case when o.type='SUPPORT' then 1 else 0 end) '点赞量'
				,SUM(CASE when o.type='SHARE' then 1 else 0 end) '转发量'
				,SUM(CASE when o.type='COLLECTION' then 1 else 0 end) '收藏量'
	from 'cms-center'.cms_operate_log o
	left join (
				#查询文章pageid
			select c.page_id
			,c.title 
			,c.publish_date 上线时间
			from `cms-center`.cms_content c 
			where c.deleted=0 
			union all 
			#查询活动pageid
			select a.page_id,a.active_name title,a.date_create 上线时间
			from activity.cms_active a 
			where a.is_deleted=0
			-- and a.modifier like '%Wedo%' 
			and a.page_id is not null and a.page_id<>''
	) c on o.ref_id=c.page_id
	left join (
			select mm.id,mm.user_id,mm.is_vehicle
			from (
			select m.user_id,max(m.id) mid
			from member.tc_member_info m 
			where m.is_deleted=0 and m.member_status<>60341003
			GROUP BY 1  ) m
			LEFT JOIN member.tc_member_info mm on mm.id=m.mid
	)m on m.user_id=o.user_id
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	and date_create <='2022-09-22 23:59:59' and date_create >='2022-09-15 00:00:00'
	and o.deleted = 0
	and o.ref_id='h3c5XLUQ17'  
	GROUP BY 1,2;
	
	
	
-- 评论条数
select
COUNT(teh.content) 留言条数
from comment.tt_evaluation_history teh 
where teh.object_id = 'h3c5XLUQ17'   -- 活动ID
and teh.create_time >= '2022-09-15'
and teh.create_time <= '2022-09-22 23:59:59'
and teh.is_deleted = 0
	
-- 拉新人数
select m.IS_VEHICLE 是否车主,
count(DISTINCT m.id) 拉新数
from 'cms-center'.cms_operate_log l
join member.tc_member_info m on l.user_id=m.user_id 
where l.date_create <='2022-09-22 23:59:59' and l.date_create >='2022-09-15 00:00:00' 
and l.ref_id='h3c5XLUQ17' and l.type ='VIEW' 
and m.create_time<date_add(l.date_create,INTERVAL 10 minute) and m.create_time>=DATE_sub(l.date_create,INTERVAL 10 MINUTE)
GROUP by 1;

-- 激活用户数
select '激活用户数' 类目
,count(DISTINCT case when a.IS_VEHICLE=1 then a.usertag else null end) 车主
,count(DISTINCT case when IFNULL(a.IS_VEHICLE,0)=0 then a.usertag else null end) 粉丝
from(
		-- 获取访问文章活动10分钟之前的最晚访问时间
		select t.usertag,b.ldate,b.is_vehicle,max(t.date) tdate
		from track.track t
		join (
			-- 获取访问文章活动的最早时间
			select m.is_vehicle,cast(l.user_id as varchar) user_id,min(date_create) ldate 
			from 'cms-center'.cms_operate_log l
			join member.tc_member_info m on l.user_id=m.user_id
			-- where l.date_create BETWEEN '2022-02-21' and '2022-03-20 23:59:59'  
			where l.date_create <='2022-09-22 23:59:59' and l.date_create >='2022-09-15 00:00:00'
			and l.ref_id='h3c5XLUQ17' 
			and l.type ='VIEW' 
			GROUP BY 1,2
		) b on b.user_id=t.usertag
		where t.date< DATE_SUB(b.ldate,INTERVAL 10  MINUTE)
		GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.ldate,INTERVAL 30 DAY) ; 



-- 渠道 PV UV
select 
	case when t.`data` like '%765D093A84D5448BB9A685377AC4DB5C%' then '01 首页banner'
	when t.`data` like '%1FFFC7B0A8B7498A84B5985F3FEFDD70%' then '02 沃的活动banner'
	when t.`data` like '%419EF9D8E1454DB880BF9B5CA843CB46%' then '03 首页弹窗'
	when t.`data` like '%9DE8487D656C441DA79E612E9DB4F58B%' then '04 首页头条'	
    when t.`data` like '%5EA92464302D4244BF6212BF97DA10F2%' then '05 月历订阅消息'
	when t.`data` like '%C9F1E8336AC64BF8AF9C04CD39E35053%' then '06 公众号推文引流'	
	when t.`data` like '%50CA05DA3CE347748C516DD364AC3FC8%' then '07 短信1'	
	when t.`data` like '%6DC37963AC314E9990056E837986FE15%' then '08 短信2'	
	when t.`data` like '%8F4AC33534214ACD8877C9A3C3044490%' then '09 朋友圈'	
	when t.`data` like '%B9CB0AE1B59E4668BF29EB8CD084EF67%' then '10 征集图文btn-专区首页'	
    else null end 分类,
-- tmi.IS_VEHICLE 是否车主,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-09-15 00:00:00' and t.`date` <= '2022-09-22 23:59:59'
group by 1
order by 1



-- 路书征集长图文——头条
-- PV UV 车主数 粉丝数 游客数 点赞量 转发量 收藏量
select o.ref_id,c.title-- ,c.上线时间
				,sum(case when o.type='VIEW' then 1 else 0 end)  PV
				,count(distinct case when o.type='VIEW' then o.user_id else null end) UV
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=1 then o.user_id else null end) 车主数
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=0 then o.user_id else null end) 粉丝数
				,count(DISTINCT case when o.type='VIEW' and m.id is null then o.user_id else null end) 游客数
				,sum(case when o.type='SUPPORT' then 1 else 0 end) '点赞量'
				,SUM(CASE when o.type='SHARE' then 1 else 0 end) '转发量'
				,SUM(CASE when o.type='COLLECTION' then 1 else 0 end) '收藏量'
	from 'cms-center'.cms_operate_log o
	left join (
				#查询文章pageid
			select c.page_id
			,c.title 
			,c.publish_date 上线时间
			from `cms-center`.cms_content c 
			where c.deleted=0 
			union all 
			#查询活动pageid
			select a.page_id,a.active_name title,a.date_create 上线时间
			from activity.cms_active a 
			where a.is_deleted=0
			-- and a.modifier like '%Wedo%' 
			and a.page_id is not null and a.page_id<>''
	) c on o.ref_id=c.page_id
	left join (
			select mm.id,mm.user_id,mm.is_vehicle
			from (
			select m.user_id,max(m.id) mid
			from member.tc_member_info m 
			where m.is_deleted=0 and m.member_status<>60341003
			GROUP BY 1  ) m
			LEFT JOIN member.tc_member_info mm on mm.id=m.mid
	)m on m.user_id=o.user_id
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	and date_create <='2022-09-22 23:59:59' and date_create >='2022-09-15 00:00:00'
	and o.deleted = 0
	and o.ref_id='UDAnN5Y2Ni'  
	GROUP BY 1,2;
	
	
	
-- 评论条数
select
COUNT(teh.content) 留言条数
from comment.tt_evaluation_history teh 
where teh.object_id = 'UDAnN5Y2Ni'   -- 活动ID
and teh.create_time >= '2022-09-15'
and teh.create_time <= '2022-09-22 23:59:59'
and teh.is_deleted = 0
	
-- 拉新人数
select m.IS_VEHICLE 是否车主,
count(DISTINCT m.id) 拉新数
from 'cms-center'.cms_operate_log l
join member.tc_member_info m on l.user_id=m.user_id 
where l.date_create <='2022-09-22 23:59:59' and l.date_create >='2022-09-15 00:00:00' 
and l.ref_id='UDAnN5Y2Ni' and l.type ='VIEW' 
and m.create_time<date_add(l.date_create,INTERVAL 10 minute) and m.create_time>=DATE_sub(l.date_create,INTERVAL 10 MINUTE)
GROUP by 1;






-- 路书专区数据 PV
select 
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV 
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-09-15'
and t.`date` <= '2022-09-22 23:59:59'
and (json_extract(t.`data`,'$.embeddedpoint')='别赶路_首页_onload_' or json_extract(t.`data`,'$.embeddedpoint')='别赶路_首页_click_金刚位_22uq3PAv5W')


-- 路书专区数据 UV  去重后






-- 在亲子假日主题专用户路书 发布、提交数量
SELECT 审核状态,
count(*)
FROM (
select
a.title 路书标题,
e.name 亲子假日主题,
a.create_time 提交时间,
a.member_id 会员ID,
a.view_num 浏览量，
a.audit_status,
a.member_id 会员ID,
b.MEMBER_PHONE 沃世界手机号,
case when a.audit_status = 0 then '未审核'
	when a.audit_status = 1 then '审核中'
	when a.audit_status = 2 then '审核通过'
	when a.audit_status = 3 then '审核失败'
	end 审核状态
-- a.title 路书标题,
-- a.nick_name 用户昵称,
-- b.REAL_NAME 姓名,
-- a.view_num 浏览量,
-- c.我想去人数,
-- d.我去过人数,
-- f.话题名称,
-- a.preface 路书介绍,
-- a.cover 封面,
-- a.poster 海报,
-- a.start_point 出发地,
-- a.end_point 目的地,
-- e.name 类型,
-- a.create_time 提交时间,
-- a.update_time 最终提交时间,
-- a.audit_time 审核时间
from volvo_online_activity.dont_hurry_road_book a
left join `member`.tc_member_info b on a.member_id = b.ID and b.MEMBER_STATUS <> 60341003 and b.IS_DELETED = 0
left join
(select
e.id,
e.name
from volvo_online_activity.dont_hurry_road_theme e)e on a.theme_id = e.id
join (select
f.road_book_id,
f.label_name 话题名称
from volvo_online_activity.dont_hurry_road_book_tag f 
-- where f.label_name = '带着Volvo去旅行'
)f on a.id = f.road_book_id
where a.create_time >= '2022-09-12'        -- 提交时间
and a.create_time <= '2022-10-23 23:59:59'     -- 提交时间
-- and a.audit_time >= '2022-09-15'       -- 审核时间
-- and a.audit_time <= '2022-09-22 23:59:59'   -- 审核时间
-- and a.audit_status = 2    -- 审核通过
and a.is_delete = 0   -- 逻辑删除
-- and e.name = '亲子假日'
group by 1，3
order by a.create_time) d
GROUP by d.审核状态





-- 路书专区发布详细数据
select
a.title 路书标题,
a.start_point 出发地,
a.end_point 目的地,
e.name 主题分类,
a.create_time 提交时间,
b.MEMBER_PHONE 沃世界手机号,
a.nick_name 用户昵称,
a.member_id 会员ID,
a.view_num 浏览量,
c.我想去人数,
d.我去过人数

-- distinct
-- a.member_id 会员ID,
-- 
-- case when a.audit_status = 0 then '未审核'
-- 	when a.audit_status = 1 then '审核中'
-- 	when a.audit_status = 2 then '审核通过'
-- 	when a.audit_status = 3 then '审核失败'
-- 	end 审核状态,
-- a.title 路书标题,
-- 
-- b.REAL_NAME 姓名,
-- a.view_num 浏览量,
-- c.我想去人数,
-- d.我去过人数,
-- f.话题名称,
-- a.preface 路书介绍,
-- a.cover 封面,
-- a.poster 海报,


-- e.name 类型,
-- a.create_time 提交时间,
-- a.update_time 最终提交时间,
-- a.audit_time 审核时间
from volvo_online_activity.dont_hurry_road_book a
left join `member`.tc_member_info b on a.member_id = b.ID and b.MEMBER_STATUS <> 60341003 and b.IS_DELETED = 0
left join 
(select
c.road_book_id,
COUNT(c.vote_member_id)我想去人数
from volvo_online_activity.dont_hurry_road_book_like c
where c.is_delete = 0
and c.type = 1 -- 我想去
group by 1)c on a.id = c.road_book_id
left join
(select
d.road_book_id,
COUNT(d.vote_member_id)我去过人数
from volvo_online_activity.dont_hurry_road_book_like d
where d.is_delete = 0
and d.type = 2 -- 我去过
group by 1)d on a.id = d.road_book_id
left join
(select
e.id,
e.name
from volvo_online_activity.dont_hurry_road_theme e)e on a.theme_id = e.id
join (select
f.road_book_id,
f.label_name 话题名称
from volvo_online_activity.dont_hurry_road_book_tag f 
-- where f.label_name = '带着Volvo去旅行'
)f on a.id = f.road_book_id
where a.create_time >= '2022-09-15'        -- 提交时间
and a.create_time <= '2022-09-22 23:59:59'     -- 提交时间
-- and a.audit_time >= '2022-08-01'       -- 审核时间
-- and a.audit_time <= '2022-08-07 23:59:59'   -- 审核时间
and a.audit_status = 2    -- 审核通过
and a.is_delete = 0   -- 逻辑删除
-- and e.name = '亲子假日'
group by 1
order by a.create_time



-- 试驾数据需求

-- 点击预约试驾按钮
select 
case 
    when json_extract(t.`data`,'$.path')='/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Flovecar-package%2Fappointment%2Fappointment%3Fchid%3D9AG4069TDC%26chcode%3DIBDMSEPXC6YLXHJS2022VCCN%26chtype%3D1' then '05 前往预约试驾'
    else null end 分类,
-- tmi.IS_VEHICLE 是否车主,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-09-15 00:00:00' and t.`date` <= '2022-09-22 23:59:59'
group by 1
order by 1


-- 车主节试驾预约人数  =有意向用户数= 经销商跟进数=下发数量=实际留资人数
select 
-- DATE_FORMAT(m.预约时间,'%Y-%m-%d')日期,
m.车型,
COUNT(distinct m.客户ID)预约试驾人数 from
(SELECT
DISTINCT ta.APPOINTMENT_ID 预约ID,
ta.CREATED_AT 预约时间,
ta.ARRIVAL_DATE 实际到店日期,
ca.active_name 活动名称,
ta.one_id 客户ID,
ta.customer_name 姓名,
ta.customer_phone 手机号,
h.大区,
h.小区,
ta.OWNER_CODE 经销商,
tc2.COMPANY_NAME_CN 经销商名称,
CASE tad.status
	WHEN 70711001 THEN '待试驾'
    WHEN 70711002 THEN '已试驾' 
    WHEN 70711003 THEN '已取消'
    END 试驾状态,
tm.model_name 车型,
tad.drive_s_at 试驾开始时间,
tad.drive_e_at 试驾结束时间
FROM cyx_appointment.tt_appointment ta
LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
LEFT JOIN organization.tm_company tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
LEFT JOIN cyxdms_retail.tt_sales_orders tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID
left join basic_data.tm_model tm on tad.SECOND_ID = tm.SERIES_ID
left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.MODEL_NAME 
LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS
LEFT JOIN (
    select 
        DISTINCT
        tm.COMPANY_CODE,
        tg2.ORG_NAME 大区,
        tg1.ORG_NAME 小区
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
    ORDER BY tm.COMPANY_CODE ASC) h on h.COMPANY_CODE = ta.owner_code
WHERE ta.CREATED_AT >= '2022-09-15'
AND ta.CREATED_AT <= '2022-09-22 23:59:59'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code = 'IBDMSEPXC6YLXHJS2022VCCN'   -- 国庆路书
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT)m
group by 1
order by 1



-- 订单转化数

select 
    a.SO_NO_ID 销售订单ID,
    a.SO_NO 销售订单号,
    a.COMPANY_CODE 公司代码,
    h.COMPANY_NAME_CN 经销商名称,
    h.GROUP_COMPANY_NAME 集团,
    h.ORG_NAME_big 大区,
    h.ORG_NAME_small 小区,
    a.OWNER_CODE 经销商代码,
    a.CREATED_AT 订单日期,
    a.SHEET_CREATE_DATE 开单日期,
    cast(a.CUSTOMER_BUSINESS_ID as varchar) 商机id ,
    a.CUSTOMER_NAME 客户姓名,
    a.DRAWER_NAME 开票人姓名,
    a.CONTACT_NAME 联系人姓名,
    a.CUSTOMER_TEL 潜客电话,
    a.DRAWER_TEL 开票人电话,
    a.PURCHASE_PHONE 下单人手机号,
    g.CODE_CN_DESC 订单状态,
    case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
    i.CODE_CN_DESC BUSINESS_TYPE,
    a.smmOrderId 订单id_smm,
    a.smmCustId 潜客id_smm,
    a.CUSTOMER_ID ,
    a.CUSTOMER_NO ,
    a.CUSTOMER_ACTIVITY_ID 活动代码id,
    c.CLUE_NAME 来源渠道,
    b.active_code 市场活动代码,
    b.active_name 市场活动名称,
    d.SALES_VIN 车架号,
    f.model_name 车型,
    j.CODE_CN_DESC 线索客户类型,
    k.CODE_CN_DESC 客户性别,
    l.CODE_CN_DESC 交车状态,
    n.CODE_CN_DESC 订单购买类型,
    a.VEHICLE_RETURN_DATE 退车完成日期,
    m.CODE_CN_DESC 退车状态,
    a.RETURN_REASON 退单原因,
    a.RETURN_REMARK 退单备注,
    a.IS_DELETED
from cyxdms_retail.tt_sales_orders a 
left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
left join customer_business.tm_clue_source c on c.ID = b.active_channel
left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
left join basic_data.tm_model f on f.id = e.SECOND_ID
left join dictionary.tc_code g on g.code_id = a.SO_STATUS
left join (
    select 
        tm.id 经销商表ID,
        tm.ORG_ID 经销商组织ID,
        tm.COMPANY_CODE ,
        tL2.ID 大区组织ID,
        tL2.ORG_NAME ORG_NAME_big,
        tg1.ID 小区组织ID,
        tg1.ORG_NAME ORG_NAME_small,
        tm.COMPANY_NAME_CN ,
        tm.GROUP_COMPANY_NAME
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	) h on h.COMPANY_CODE = a.COMPANY_CODE
 left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
 left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
 left join dictionary.tc_code k on k.code_id = a.GENDER
 left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
 left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
where a.BUSINESS_TYPE<>14031002
and a.IS_DELETED = 0
and a.CREATED_AT BETWEEN '2022-09-15' AND '2022-09-22 23:59:59'
and b.active_code = 'IBDMSEPXC6YLXHJS2022VCCN'
order by a.CREATED_AT