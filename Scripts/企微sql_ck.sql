--数据源rds-mssql-dcc-prod-shanghai
--导出签到商机ID和DCC线索ID的关系
select a.Id,b.Id lid,b.NewbieOpportunityId,a.CreationTime from QyWechatSignInRecord a with(nolock) join LeadsInfo b with(nolock) on a.LeadsId=b.Id

--实例都是dws-cluster-prod-newbie1 lto侧是根据企微导出的数据进行操作
--先根据D列及J列的经销商代码及手机号查询商机，如果没有就用O列的手机号，
--如果还没有就用V列的手机号匹配商机id   -- 这里和表格里描述不一致，V列和U列不一致，以哪个为准
select t.dealer_code,
       T.mobile,
       A.customer_business_id,
       created_at
  from customer_business.tt_customer_business a
  left join customer_business.tt_pontential_customer t on a.potential_customers_id=t.id and t.is_deleted=0
  where a.created_at >='2025-01-01'
-- where concat(t.dealer_code,t.mobile) in()

--再根据D列及I列经销商及扫码签到客户uninoid查询商机    取加微时间最晚的  这里的加微时间是哪个字段
select owner_code,
       union_id,
       customer_business_id
  from customer_business.tr_enterprise_wechat_customer
-- where concat(owner_code,union_id) in()

--根据商机id拉取AI列到AN列 其中当前进店次数要另外获取（我们的办法是看签到日期前这个商机id出现的次数）    取创建时间最晚的，这里的创建时间是哪个字段
  --- 是否首次进店sql 未提供
select
	a.customer_business_id,
	a.arrive_date "客流进店时间",
--	a.reception_consultant ,
	a.passenger_flow_type 是否首次,
	case when a.passenger_group='87671001' then '看车客户'
		when a.passenger_group='87671002' then '订单客户'
		else null end 客流类别,
--		是否首次     
	x.当前进店次数,
	consultant_info.employee_name 接待顾问
from
	cyx_passenger_flow.tt_passenger_flow_info a
left join (
select
tu.user_id,
te.employee_name
from authentication.tm_emp te
inner join authentication.tm_user tu on te.emp_id = tu.emp_id
) consultant_info on a.reception_consultant = consultant_info.user_id
left join (
	--进店次数
	select
		a.customer_business_id,
		count(1) as 当前进店次数
	from
		cyx_passenger_flow.tt_passenger_flow_info a
	where
		1 = 1
		and a.is_deleted = 0
	group by
		a.customer_business_id
	 )x on
	x.customer_business_id = a.customer_business_id
where
	created_at >= '2025-01-01'
	-- where customer_business_id in()

 是否首次 PASSENGER_FLOW_TYPE : 70031001（是），70031002（否）
 客流类别 passenger_group：87671001（看车客户），87671002（订单客户）
 
 --进店次数
 select 
  a.customer_business_id,
 count(1) as 次数
  FROM cyx_passenger_flow.tt_passenger_flow_info a
 where 1=1
 and a.is_deleted=0
 group by a.customer_business_id
 
  
  
  
--根据商机id导出Z列到AH列
select cb_tcb.customer_business_id "商机id",
consultant_info.employee_name "所属顾问",
cb_tcb.created_at "商机创建时间",
bd_tmo.model_name "意向车型",
tcfg.CONFIG_NAME "配置",
cb_tcs.clue_name "来源渠道",
a_ca.active_name "市场活动",
d_tc1.code_cn_desc "当前意向级别"
from customer_business.tt_customer_business cb_tcb
inner join (
select
tu.user_id,
te.employee_name
from authentication.tm_emp te
inner join authentication.tm_user tu on te.emp_id = tu.emp_id
) consultant_info on cb_tcb.CONSULTANT = consultant_info.user_id
inner join customer_business.tt_business_statistics cb_tbs on cb_tcb.customer_business_id = cb_tbs.customer_business_id -- 获取商机意向车型
left join customer_business.tt_clue_intent cb_tci on cb_tcb .customer_business_id = cb_tci.customer_business_id
and cb_tci.is_main_intent = 10041001 -- 获取意向车型名称
left join basic_data.tm_model bd_tmo on cb_tci.second_id = bd_tmo.id
left join basic_data.tm_config tcfg on cb_tci.FOURTH_ID=tcfg.id
left join customer_business.tm_clue_source cb_tcs on cb_tcb.clue_source_id = cb_tcs.id
left join activity.cms_active a_ca on cb_tcb.market_activity = a_ca.uid
left join dictionary.tc_code d_tc1 on cb_tcb.intent_level = d_tc1.code_id
where cb_tcb.created_at >='2025-01-01'
--cb_tcb.customer_business_id in ( )

-------------------------------------------------------------
		WITH t1 AS(SELECT 
		    mpd.salebigareaname salebigareaname,
		    mpd.salesmallareaname salesmallareaname, 
		    mpd.companycode companycode,
		    arrayStringConcat(groupArray(wdiln.DepartmentLevelName), ',') AS depname,
		    wui.NameInfo NameInfo,
		    wui.UserId UserId,
		    wui.Id Id,
		    wui.Position Position,
		    wui.MiddleUserCode MiddleUserCode,
		    wui.MiddleUserId MiddleUserId,
		    row_number() OVER (PARTITION BY wui.UserId ORDER BY wui.Id) AS rn
		FROM ods_vdqw.ods_vdqw_workuserinfo_d AS wui
		LEFT JOIN ods_vdqw.ods_vdqw_workuserdepartment_d AS wud 
		    ON wui.Id = wud.WorkUserInfoId
		LEFT JOIN ods_vdqw.ods_vdqw_workdepartmentinfolevelname_d AS wdiln 
		    ON (wud.DepartmentId = wdiln.DepartmentId) AND (wdiln.LevelType = 1)
		LEFT JOIN ods_vdqw.ods_vdqw_workdepartmentinfolevel_d AS wdl 
		    ON wdl.TopDepartmentId = wud.DepartmentId
		LEFT JOIN ods_vdqw.ods_vdqw_middleplatformdeales_d AS mpd 
		    ON wui.DealerCode = mpd.companycode
		WHERE 
		    (wdl.DepartmentId IN (1)) 
		    AND (wdl.LevelType = 0)
		GROUP BY 
		    mpd.salebigareaname,
		    mpd.salesmallareaname,
		    mpd.companycode,
		    wui.NameInfo,
		    wui.UserId,
		    wui.Position,
		    wui.MiddleUserCode,
		    wui.MiddleUserId,
		    wui.Id  ,
		    wdiln.DepartmentLevelName -- ClickHouse要求GROUP BY必须包含所有非聚合字段
	),t2 AS(
    SELECT t1.Id,
           t1.salebigareaname,
           t1.salesmallareaname,
           t1.companycode,
           t1.depname,
           t1.NameInfo,
           t1.UserId,
           t1.Position,
           t1.MiddleUserCode,
           t1.MiddleUserId,
           t1.rn
      FROM t1
     WHERE t1.rn=1
    ),
       sign1 AS(
    SELECT tssi.dealer_code,
           tssi.union_id,
           tssi.mobile,
           tssi.sign_in_time,
           tssi.friend_type,
           tssi.work_user_info_id,
           tssi.user_id,
           tssi.nb_opportunity_id,
           tssi.id,
           CASE
             WHEN tssi.is_follow=1 THEN '是'
             ELSE '否'
           END AS is_follow
      FROM ods_vdqw.ods_vdqw_tt_store_sign_in_d tssi 
     WHERE tssi.sign_in_time>='2025-01-01'
       AND tssi.dealer_code<>'TDCC'
       AND tssi.work_user_info_id NOT IN(16923,14906)
    ),
       ExternalContact AS(
    SELECT ecu.ExternalContactUserId ExternalContactUserId,
           ecu.FollowUserId FollowUserId,
           ecu.CreationTime CreationTime,
           ecu.Status Status,
           ec.Unionid Unionid,
           t2.Id Id,
           t2.companycode companycode,
           arrayStringConcat(groupArray(ecum.Mobile), ',') AS Mobile
      FROM ods_vdqw.ods_vdqw_externalcontactuser_d ecu
      LEFT JOIN ods_vdqw.ods_vdqw_externalcontact_d ec ON ecu.ExternalContactUserId=ec.ExternalUserid
      LEFT JOIN ods_vdqw.ods_vdqw_externalcontactusermobile_d ecum ON ecum.ExternalContactUserId=ecu.Id
      LEFT JOIN t2 ON t2.UserId=ecu.FollowUserId
     GROUP BY ecu.ExternalContactUserId,
     ecu.FollowUserId,
     ecu.CreationTime,
     ecu.Status,
     ec.Unionid,
     t2.Id,
     t2.companycode
    ),aa AS(
    SELECT s.work_user_info_id,
           CASE
             WHEN ec.ExternalContactUserId IS NULL THEN '否'
             ELSE '是'
           END AS isfriend,
           ec.CreationTime,
           ec.Mobile,
           s.id,
           CASE
             WHEN ec.Status=0 THEN '是'
             ELSE '否'
           END AS isReallyContact
      FROM sign1 s
      LEFT JOIN ExternalContact ec ON ec.Id=s.work_user_info_id AND ec.Unionid=s.union_id AND s.dealer_code=ec.companycode
    ),
       final_result AS(
    SELECT s.id id,
           t2.NameInfo NameInfo,
           t2.Position Position,
           t2.MiddleUserCode MiddleUserCode,
           t2.MiddleUserId MiddleUserId,
           ec.CreationTime CreationTime,
           ec.Mobile Mobile,
           ec.companycode companycode,
           CASE
             WHEN ec.Status=0 THEN '是'
             ELSE '否'
           END AS isReallyContact,
           ROW_NUMBER() OVER(PARTITION BY s.id ORDER BY ec.CreationTime) as rn
      FROM sign1 s
      LEFT JOIN ExternalContact ec ON s.union_id=ec.Unionid AND ec.companycode=s.dealer_code
      LEFT JOIN t2 ON t2.UserId=ec.FollowUserId
    )
SELECT 
 toDate(s.sign_in_time) AS `扫码签到日期（年月日）`,
--FORMAT(s.sign_in_time,'yyyy-MM-dd') AS `扫码签到日期（年月日）`,
       t.salebigareaname as `大区`,
       t.salesmallareaname as `小区`,
       t.companycode as `经销商代码`,
       t.NameInfo AS `签到码所属成员姓名`,
       t.Position AS `签到码所属成员职位（企微角色）`,
       t.MiddleUserCode AS `签到码所属成员NB账号`,
       t.MiddleUserId AS `签到码所属成员NB userid`,
       s.union_id AS `扫码签到客户uninoid`,
       s.mobile AS `扫码签到客户手机号`,
       s.is_follow AS `扫码签到手机号是否有DCC跟进顾问`,
       s.sign_in_time AS `扫码签到时间（年月日时分秒）`,
       a.isfriend AS `该客户与签到码所属成员是否好友关系`,
       a.CreationTime AS `添加好友时间（年月日时分秒）`,
       a.Mobile AS `客户手机号1`,
       a.isReallyContact AS `客户当前与签到码所属顾问是否有效好友关系`,
       fr.NameInfo AS `该客户在当前门店内最早添加企微好友的成员姓名`,
       fr.Position AS `该客户最早添加的成员职位`,
       fr.MiddleUserCode AS `该客户最早添加的成员NB账号`,
       fr.MiddleUserId AS `该客户最早添加的成员NB userid`,
       fr.CreationTime AS `该客户最早添加成员好友时间`,
       fr.Mobile AS `客户手机号2`,
       fr.companycode `最早添加成员门店代码`,
       fr.isReallyContact `该客户与最早添加成员当前是否有效好友关系`,
       s.nb_opportunity_id
  FROM sign1 s
  LEFT JOIN t2 t ON s.work_user_info_id=t.Id
  LEFT JOIN aa a ON s.id=a.id AND a.work_user_info_id=s.work_user_info_id
  LEFT JOIN final_result fr ON fr.id=s.id AND fr.rn=1
 ORDER BY `扫码签到日期（年月日）`
