-- 公众号回复”在看“人数	
select
	to_char(ewrl.create_time,'YYYY-MM')
	,case when a.num =0 then'粉丝' when a.num >=1 then '车主' else '游客' end 
	,count(eco.id)
from volvo_wechat_live.es_wechat_reply_log ewrl
left join volvo_wechat_live.es_car_owners eco on ewrl.openid = eco.open_id
left join (
        select m.id 
        ,v.num
        ,IFNULL(c.union_id,u.unionid) allunionid
         from member.tc_member_info m 
         left join 
         (
         -- 包含亲友授权车主
         select v.member_id,sum(v.is_bind) num 
         from volvo_cms.vehicle_bind_relation v 
         group by 1 
         )v on m.id=v.member_id
        left join customer.tm_customer_info c on c.id=m.cust_id
        left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id::varchar=m.old_memberid
        where m.member_status<>60341003 
        and m.is_deleted=0
--        and allunionid !='1012330null'
--        and u.unionid is not null 
    ) a on a.allunionid = eco.unionid
where 1=1
and ewrl.create_time >= '2024-12-01'
and ewrl.create_time <'2025-01-01'
and ewrl.title = '在看'
group by 1,2
order by 1 desc,2 desc 

-- 车主节试驾预约人数  =有意向用户数= 经销商跟进数=下发数量=实际留资人数
select 
m.活动名称,
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
WHERE ta.CREATED_AT >= '2024-04-01'
AND ta.CREATED_AT < '2024-05-01'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code ='IBDMMARWSJGZHHYY2023VCCN'  -- 预约试驾 自动推送欢迎语 IBDMMARWSJGZHHYY2023VCCN
--and ca.active_code ='IBDMJULALLWCDWXC2023VCCN'  -- 预约试驾 菜单栏
--and ca.active_code ='IBCRMDECALL000152023VCCN'  -- 预约试驾   推文IBCRMAUGALL000102023VCCN
--and ca.active_code ='IBDMAPRWSJYYSJT12023VCCN'  -- 预约试驾2   IBDMAPRWSJYYSJT12023VCCN
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT)m
group by 1
order by 1

--养修预约
select cast(tam.MAINTAIN_ID as varchar) 养修预约ID,
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.COMPANY_NAME_CN "经销商名称",
       ta.ONE_ID "oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.ID 会员ID,
       tmi.MEMBER_PHONE "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = 10041001 then '是'
    when tam.IS_TAKE_CAR = 10041002 then '否'
     end  "是否取车",
       case when tam.IS_GIVE_CAR = 10041001 then '是'
         when tam.IS_GIVE_CAR = 10041002 then '否'
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta.CREATED_AT "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >= '2024-04-01'
AND ta.CREATED_AT < '2024-05-01'
and ta.DATA_SOURCE ='C'
and ta.APPOINTMENT_TYPE =70691005


-- 10分钟内成功提交养修预约人数  我是车主：车主服务
select COUNT(b.养修预约ID) 成功提交养修预约人数 from
(select
distinct tmi.ID 会员ID,
t.date
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2024-04-01' and t.`date` < '2024-05-01'
and json_extract_path_text(data::json,'tcode')='D78AF2415C7B40C08CF6A092E7D6F595' -- 试驾(同上)
)a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) 养修预约ID,
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.COMPANY_NAME_CN "经销商名称",
       ta.ONE_ID "oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.ID 会员ID,
       tmi.MEMBER_PHONE "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = 10041001 then '是'
    when tam.IS_TAKE_CAR = 10041002 then '否'
     end  "是否取车",
       case when tam.IS_GIVE_CAR = 10041001 then '是'
         when tam.IS_GIVE_CAR = 10041002 then '否'
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta.CREATED_AT "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >= '2024-04-01'
AND ta.CREATED_AT < '2024-05-01'
and ta.DATA_SOURCE ='C'
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID
where DATEDIFF(a.date,b.创建时间)*24*60<10


-- 欢迎语PVUV
--	#获取点击注册和预约试驾用户unionid(注册tcode存在第一次点击没有埋点)
	select 
	case 
				when json_extract_path_text(data::json,'tcode')='B797939E29824BE0AB10A44A4874FDC7' then '1注册会员' -- 注册tcode如有变化修改这里
				when json_extract_path_text(data::json,'tcode')='3A3579491DCF472CB46AAB44CC9AF480' then '2车主服务' -- 服务tcode如有变化修改这里
				when json_extract_path_text(data::json,'tcode')='0D8BC33E236E4CD59EAED84A09D4976C' then '3我是粉丝：爱车首页' -- 试驾tcode如有变化修改这里
				when json_extract_path_text(data::json,'tcode')='DD22EAEA1102428582534ACC27F7FC65' then '4关于EX90：小程序ex90专区' -- 即刻参与tcode如有变化修改这里
				when json_extract_path_text(data::json,'tcode')='CFDBFA6BC2B24DA1861C0825E361F10A' then '5邀你试驾卡片' -- 邀你试驾卡片tcode如有变化修改这里
				else null end click
	,count(case when tmi.IS_VEHICLE=1 then t.usertag else null end) 车主PV
	,count(case when tmi.IS_VEHICLE=0 then t.usertag else null end) 粉丝PV
	,count(case when tmi.IS_VEHICLE is null then t.usertag else null end) 游客PV
	,count(distinct case when tmi.IS_VEHICLE=1 then t.usertag else null end) 车主UV
	,count(distinct case when tmi.IS_VEHICLE=0 then t.usertag else null end) 粉丝UV
	,count(distinct case when tmi.IS_VEHICLE is null then t.usertag else null end) 游客UV
	from track.track t 
	left join `member`.tc_member_info tmi on CAST(tmi.user_id AS VARCHAR)=t.usertag
--	left join authentication.tm_user u on CAST(u.user_id AS VARCHAR)=t.usertag
--	left join authentication.tm_emp e on e.emp_id=u.emp_id
	where DATE(t.date)>='2023-06-01' and DATE(t.date)<'2024-04-01' 
-- 	where t.date BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
	and (json_extract_path_text(data::json,'tcode')='B797939E29824BE0AB10A44A4874FDC7' -- 试驾(同上)
	or json_extract_path_text(data::json,'tcode')='3A3579491DCF472CB46AAB44CC9AF480' -- 注册(同上)
	or json_extract_path_text(data::json,'tcode')='0D8BC33E236E4CD59EAED84A09D4976C' -- 服务(同上2022.3.7新增)
	or json_extract_path_text(data::json,'tcode')='DD22EAEA1102428582534ACC27F7FC65' -- 4即刻参与
	or json_extract_path_text(data::json,'tcode')='CFDBFA6BC2B24DA1861C0825E361F10A' -- 5邀你试驾卡片
	) 
	group by 1
	order by 1 
	
-- 拉新
select 
case 			when json_extract_path_text(data::json,'tcode')='B797939E29824BE0AB10A44A4874FDC7' then '1注册会员' -- 注册tcode如有变化修改这里
				when json_extract_path_text(data::json,'tcode')='3A3579491DCF472CB46AAB44CC9AF480' then '2车主服务' -- 服务tcode如有变化修改这里
				when json_extract_path_text(data::json,'tcode')='0D8BC33E236E4CD59EAED84A09D4976C' then '3我是粉丝：爱车首页' -- 试驾tcode如有变化修改这里
				when json_extract_path_text(data::json,'tcode')='DD22EAEA1102428582534ACC27F7FC65' then '4关于EX90：小程序ex90专区' -- 即刻参与tcode如有变化修改这里
				when json_extract_path_text(data::json,'tcode')='CFDBFA6BC2B24DA1861C0825E361F10A' then '5邀你试驾卡片' -- 邀你试驾卡片tcode如有变化修改这里
				else null end click
,count(DISTINCT m.id)拉新人数
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.is_vehicle = 0  -- 排除车主
where DATE(t.date)>='2024-04-01' 
and DATE(t.date)<'2024-05-01' 
and (json_extract_path_text(data::json,'tcode')='B797939E29824BE0AB10A44A4874FDC7' -- 试驾(同上)
	or json_extract_path_text(data::json,'tcode')='3A3579491DCF472CB46AAB44CC9AF480' -- 注册(同上)
 	or json_extract_path_text(data::json,'tcode')='0D8BC33E236E4CD59EAED84A09D4976C' -- 服务(同上2022.3.7新增)
	or json_extract_path_text(data::json,'tcode')='DD22EAEA1102428582534ACC27F7FC65' -- 4即刻参与
	or json_extract_path_text(data::json,'tcode')='CFDBFA6BC2B24DA1861C0825E361F10A' -- 5邀你试驾卡片
	)
and m.create_time>=date_sub(t.date,interval '10' MINUTE) 
and m.create_time<=DATE_ADD(t.date,INTERVAL '10' MINUTE)
group by 1
order by 1





-- 推送PVUV
--	#获取点击注册和预约试驾用户unionid(注册tcode存在第一次点击没有埋点)
	select 
	case when json_extract_path_text(data::json,'tcode')='9A2F20E259AE4406B211231A2803252F' then '01仅点击“订阅”' 
				when json_extract_path_text(data::json,'tcode')='674486403E7E41369CEE064C6266453D' then '02点击”订阅“及“预约试驾”' 
				when json_extract_path_text(data::json,'tcode')='80B28F4F7F9748D1B98BD8EF03239C61' then '03点击“订阅”及“注册会员”'
				when json_extract_path_text(data::json,'tcode')='A2F308AB7FDC478F949F193FAE1BD87F' then '04点击“订阅”及“注册会员”，“预约试驾”'
				when json_extract_path_text(data::json,'tcode')='BD883F0B816A418BBDCB4EA4C0FAA714' then '05点击“订阅”及“车主服务”' 
				when json_extract_path_text(data::json,'tcode')='1505AC9426D24B80A77641B0781C8F4E' then '06 1点击“订阅”及“爱车首页”'
				when json_extract_path_text(data::json,'tcode')='6FDC7FD7706A401F8B623E65D86E0407' then '07仅点击“订阅”' 
				when json_extract_path_text(data::json,'tcode')='EC8A4E4EB36E417B82834041A503A986' then '08点击”订阅“及“预约试驾”' 
				when json_extract_path_text(data::json,'tcode')='F7F4F1EC63B14927A4CA7FC1B55272BC' then '09点击“订阅”及“注册会员”'
				when json_extract_path_text(data::json,'tcode')='7908B702C94F4EF9BDE5E09BFFE2891B' then '10点击“订阅”及“注册会员”，“预约试驾”'
				when json_extract_path_text(data::json,'tcode')='AF27CA8FD72C45FBACAC1C37A3615BEC' then '11点击“订阅”及“车主服务”' 
				when json_extract_path_text(data::json,'tcode')='E206CC89A15846D5BE09D0218E024585' then '12点击“订阅”及“注册会员”，“车主服务”' 
				else null end click
	,count(case when tmi.IS_VEHICLE=1 then t.usertag else null end) 车主PV
	,count(case when tmi.IS_VEHICLE=0 then t.usertag else null end) 粉丝PV
	,count(case when tmi.IS_VEHICLE is null then t.usertag else null end) 游客PV
	,count(distinct case when tmi.IS_VEHICLE=1 then t.usertag else null end) 车主UV
	,count(distinct case when tmi.IS_VEHICLE=0 then t.usertag else null end) 粉丝UV
	,count(distinct case when tmi.IS_VEHICLE is null then t.usertag else null end) 游客UV
	from track.track t 
	left join `member`.tc_member_info tmi on CAST(tmi.user_id AS VARCHAR)=t.usertag
	left join authentication.tm_user u on CAST(u.user_id AS VARCHAR)=t.usertag
	left join authentication.tm_emp e on e.emp_id=u.emp_id
	where DATE(t.date)>='2024-04-01' and DATE(t.date)<'2024-05-01' 
-- 	where t.date BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
-- 	and (json_extract_path_text(data::json,'tcode')='5308C69D582E4055889030729D45EBFF' -- 官方直售
-- 	or json_extract_path_text(data::json,'tcode')='27638C2A67FF4276BC70B9AD9E15C42D' -- 探索车型
-- 	or json_extract_path_text(data::json,'tcode')='64F9E51207DC459AA366091BD6828914' -- 金融方案
-- 	or json_extract_path_text(data::json,'tcode')='D6D3ED45342845E5ABAF5E158CDBE0B8' -- 查找经销商
-- 	or json_extract_path_text(data::json,'tcode')='F7C7ECAFD6794B39B03A79CE044EE9DB' -- 沃世界主场
-- 	or json_extract_path_text(data::json,'tcode')='7E760D98634C46929998A74EBFA65D11' -- 沃商城
-- 	or json_extract(t.data,'$.embeddedpoint')='home_club_ONLOAD' -- 车主俱乐部
-- 	or json_extract_path_text(data::json,'tcode')='C81E633060C54184A83D562D0F18B9AC' -- 推荐购
-- 	or json_extract_path_text(data::json,'tcode')='D78AF2415C7B40C08CF6A092E7D6F595' -- 养修预约
-- 	or json_extract_path_text(data::json,'tcode')='测一下埋点' -- 沃家客服
-- 	or json_extract_path_text(data::json,'tcode')='54F0EB9BAA9F447D95CA3F9EB4F1CCC5' -- 上门取送车
-- 	or json_extract_path_text(data::json,'tcode')='E476E8CAADE34F36B6C212663F78D16F' -- 充电桩安装
-- 	) 
	group by 1
	order by 1 

-- 推送预约试驾
select 
case when json_extract_path_text(data::json,'tcode')='A2F308AB7FDC478F949F193FAE1BD87F' then '04点击“订阅”及“注册会员”，“预约试驾””' 
				when json_extract_path_text(data::json,'tcode')='674486403E7E41369CEE064C6266453D' then '02点击”订阅“及“预约试驾”' 
				when json_extract_path_text(data::json,'tcode')='EC8A4E4EB36E417B82834041A503A986' then '08点击”订阅“及“预约试驾”' 
				when json_extract_path_text(data::json,'tcode')='7908B702C94F4EF9BDE5E09BFFE2891B' then '10点击“订阅”及“注册会员”，“预约试驾””'
	else null end click
,COUNT(distinct m.客户ID)预约试驾人数 from
(select
	distinct tmi.ID 会员ID,
	tmi.CUST_ID ,
	t.data,
	t.date
	from track.track t 
	join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` >= '2024-04-01' and t.`date` < '2024-05-01'
	and json_extract_path_text(data::json,'tcode') in('E1A1A70EE69448F3BE58EFDC489BD2BC','F69253E787C74838AB6013C2B989C800','BA88FB570B15497899E608A0D8D87EA7'
	'394CDADDBDE4458492CB75E25951A914','BFFA629FD262415A9D8B425035B6C118','9557FC288E994D18A609D119FE5A3921') -- 试驾(同上)
)t
join
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
	WHERE ta.CREATED_AT >= '2024-04-01'
	AND ta.CREATED_AT < '2024-05-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	-- and ca.active_code in('IBDMSEPWSJGZHHYY2021VCCN','IBDMMARWSJGZHHYY2023VCCN')   -- 预约试驾
	and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
	order by ta.CREATED_AT)m on m.客户ID=t.CUST_ID
group by 1
order by 1
	

-- 菜单栏PVUV
--	#获取点击注册和预约试驾用户unionid(注册tcode存在第一次点击没有埋点)
	select 
	case when json_extract_path_text(data::json,'tcode')='5308C69D582E4055889030729D45EBFF' then '01官方直售' 
				when json_extract_path_text(data::json,'tcode')='27638C2A67FF4276BC70B9AD9E15C42D' then '02探索车型' 
				when json_extract_path_text(data::json,'tcode')='64F9E51207DC459AA366091BD6828914' then '03金融方案'
				when json_extract_path_text(data::json,'tcode')='D6D3ED45342845E5ABAF5E158CDBE0B8' then '04查找经销商'
				when json_extract_path_text(data::json,'tcode')='F7C7ECAFD6794B39B03A79CE044EE9DB' then '05沃世界主场' 
				when json_extract_path_text(data::json,'tcode')='7E760D98634C46929998A74EBFA65D11' then '06沃商城'
				when json_extract_path_text(data::json,'embeddedpoint')='home_club_ONLOAD' then '07车主俱乐部' 
				when json_extract_path_text(data::json,'tcode')='C81E633060C54184A83D562D0F18B9AC' then '08推荐购' 
				when json_extract_path_text(data::json,'tcode')='C81E633060C54184A83D562D0F18B9AC' then '08b下载APP' 
				when json_extract_path_text(data::json,'tcode')='D78AF2415C7B40C08CF6A092E7D6F595' then '09养修预约'
				when json_extract_path_text(data::json,'tcode')='测一下埋点' then '10沃家客服'
				when json_extract_path_text(data::json,'tcode')='54F0EB9BAA9F447D95CA3F9EB4F1CCC5' then '11上门取送车' 
				when json_extract_path_text(data::json,'tcode')='E476E8CAADE34F36B6C212663F78D16F' then '12充电桩安装' 
				when json_extract_path_text(data::json,'tcode')='A86084FB9F4441569A37825A5AA8F744' then '13官方回购' 
				else null end click
	,count(case when tmi.IS_VEHICLE=1 then t.usertag else null end) 车主PV
	,count(case when tmi.IS_VEHICLE=0 then t.usertag else null end) 粉丝PV
	,count(case when tmi.IS_VEHICLE is null then t.usertag else null end) 游客PV
	,count(distinct case when tmi.IS_VEHICLE=1 then t.usertag else null end) 车主UV
	,count(distinct case when tmi.IS_VEHICLE=0 then t.usertag else null end) 粉丝UV
	,count(distinct case when tmi.IS_VEHICLE is null then t.usertag else null end) 游客PV
	from track.track t 
	left join `member`.tc_member_info tmi on CAST(tmi.user_id AS VARCHAR)=t.usertag
	left join authentication.tm_user u on CAST(u.user_id AS VARCHAR)=t.usertag
	left join authentication.tm_emp e on e.emp_id=u.emp_id
	where DATE(t.date)>='2024-04-01' and DATE(t.date)<'2024-05-01' 
-- 	where t.date BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
	and (json_extract_path_text(data::json,'tcode')='5308C69D582E4055889030729D45EBFF' -- 官方直售
	or json_extract_path_text(data::json,'tcode')='27638C2A67FF4276BC70B9AD9E15C42D' -- 探索车型
	or json_extract_path_text(data::json,'tcode')='64F9E51207DC459AA366091BD6828914' -- 金融方案
	or json_extract_path_text(data::json,'tcode')='D6D3ED45342845E5ABAF5E158CDBE0B8' -- 查找经销商
	or json_extract_path_text(data::json,'tcode')='F7C7ECAFD6794B39B03A79CE044EE9DB' -- 沃世界主场
	or json_extract_path_text(data::json,'tcode')='7E760D98634C46929998A74EBFA65D11' -- 沃商城
	or json_extract_path_text(data::json,'embeddedpoint')='home_club_ONLOAD' -- 车主俱乐部
	or json_extract_path_text(data::json,'tcode')='C81E633060C54184A83D562D0F18B9AC' -- 推荐购
	or json_extract_path_text(data::json,'tcode')='D78AF2415C7B40C08CF6A092E7D6F595' -- 养修预约
	or json_extract_path_text(data::json,'tcode')='测一下埋点' -- 沃家客服
	or json_extract_path_text(data::json,'tcode')='54F0EB9BAA9F447D95CA3F9EB4F1CCC5' -- 上门取送车
	or json_extract_path_text(data::json,'tcode')='E476E8CAADE34F36B6C212663F78D16F' -- 充电桩安装
	or json_extract_path_text(data::json,'tcode')='A86084FB9F4441569A37825A5AA8F744' -- 13官方回购
	) 
	group by 1
	order by 1 
	
-- 推文
-- 欢迎语PVUV
--	#获取点击注册和预约试驾用户unionid(注册tcode存在第一次点击没有埋点)
	select 
	case 
				when json_extract_path_text(data::json,'tcode')='3428537E1A5749E197098DCC2E7C924A' then '小程序卡片' -- 注册tcode如有变化修改这里
				when json_extract_path_text(data::json,'tcode')='BAB9DA6818364949A822DC4C35B65555' then '热门活动卡片' -- 服务tcode如有变化修改这里
				else null end click
	,count(case when tmi.IS_VEHICLE=1 then t.usertag else null end) 车主PV
	,count(case when tmi.IS_VEHICLE=0 then t.usertag else null end) 粉丝PV
	,count(case when tmi.IS_VEHICLE is null then t.usertag else null end) 游客PV
	,count(distinct case when tmi.IS_VEHICLE=1 then t.usertag else null end) 车主UV
	,count(distinct case when tmi.IS_VEHICLE=0 then t.usertag else null end) 粉丝UV
	,count(distinct case when tmi.IS_VEHICLE is null then t.usertag else null end) 游客UV
	from track.track t 
	left join `member`.tc_member_info tmi on CAST(tmi.user_id AS VARCHAR)=t.usertag
	left join authentication.tm_user u on CAST(u.user_id AS VARCHAR)=t.usertag
	left join authentication.tm_emp e on e.emp_id=u.emp_id
	where DATE(t.date)>='2024-04-01' and DATE(t.date)<'2024-05-01' 
-- 	where t.date BETWEEN DATE_SUB(CURDATE(),INTERVAL 1 DAY) and CURDATE()
	and (json_extract_path_text(data::json,'tcode')='3428537E1A5749E197098DCC2E7C924A' -- 试驾(同上)
	or json_extract_path_text(data::json,'tcode')='BAB9DA6818364949A822DC4C35B65555' -- 注册(同上)
	) 
	group by 1
	order by 1 
	
-- 车主节试驾预约人数  =有意向用户数= 经销商跟进数=下发数量=实际留资人数
select 
m.活动名称,
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
WHERE ta.CREATED_AT >= '2024-04-01'
AND ta.CREATED_AT < '2024-05-01'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ca.active_code ='IBDMAPRWSJYYSJT12023VCCN'  -- 预约试驾
and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891')   -- 剔除测试信息
order by ta.CREATED_AT)m
group by 1
order by 1


-- 文章明细	 
select o.ref_id,c.title-- ,c.上线时间
				,count(case when o.type='VIEW' and m.is_vehicle=1 then o.user_id else null end) 车主数PV
				,count(case when o.type='VIEW' and m.is_vehicle=0 then o.user_id else null end) 粉丝数PV
				,count(case when o.type='VIEW' and m.id is null then o.user_id else null end) 游客数PV	
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=1 then o.user_id else null end) 车主数UV
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=0 then o.user_id else null end) 粉丝数UV
				,count(DISTINCT case when o.type='VIEW' and m.id is null then o.user_id else null end) 游客数UV
	from cms_center.cms_operate_log o
	left join (
--				#查询文章pageid
			select c.page_id
			,c.title 
			,c.publish_date 上线时间
			from cms_center.cms_content c 
			where c.deleted=0 
			union all 
--			#查询活动pageid
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
	and date_create <'2024-05-01' and date_create >='2024-04-01'
	and o.ref_id='5MA37wkS6u' 
	GROUP BY 1,2;

   

    
