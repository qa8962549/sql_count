-- 活动主页UV
select weekz,count(distinct distinct_id) as UV
from
(-- 活动主页UV
	select distinct
	concat(year(date)::varchar,'-',toWeek(`date`,1)::varchar) as weekz
--	,case when (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') then 'App'
--		when ($lib in('MiniProgram') or channel ='Mini') then 'Mini' end as channel1 
	,distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where LENGTH(a.distinct_id)<9 -- 会员
	and `date` >='2023-11-02'
    and `date`>=left((now()+ interval '-6 week')::varchar,10)-- 近6个礼拜
	and `date` <='{end_time}'
	and event='Page_view'
	and ((`$title` ='试驾享好礼' AND `date` <'2023-12-23') or (page_title='试驾享好礼'  AND `date` >='2023-12-23'))
	and ($lib in('MiniProgram') or channel ='Mini')
)
group by weekz
order by weekz	
	

with base as (
	select
		ta.ONE_ID `客户oneid`
		,ta.user_member_id `试驾memberID`
		,tmi.member_phone `注册手机号`
		,tmi.is_vehicle `是否车主`
		,ta.APPOINTMENT_ID `预约id`
		,ta.CREATED_AT `预约创建时间`
		,tm.model_name `预约车型`
		,ta.INVITATIONS_DATE `预计到店时间`
		,if(date(ta.ARRIVAL_DATE)='1970-01-01',null,ta.ARRIVAL_DATE) `实际到店日期`
		,ta.CHANNEL_ID `活动id`
		,ca.active_name `活动名称`
		,ta.CUSTOMER_NAME `客户姓名`
		,ta.CUSTOMER_PHONE `客户手机号`
		,delear.ORG_NAME_big `大区`
		,delear.ORG_NAME_small `小区`
		,ta.OWNER_CODE `经销商code`
		,case when (tp.DRIVE_STATUS = 20211001 or tp.DRIVE_STATUS = 20211004) then  '待试驾'
	     	when tp.DRIVE_STATUS = 20211003  then  '已试驾'
	     	when tp.DRIVE_STATUS = 20211002  then  '已取消'
	        else null end `试驾最终状态`
		,if(date(tp.DRIVE_S_AT)='1970-01-01',null,tp.DRIVE_S_AT) `试驾开始时间`
		,if(date(tp.DRIVE_E_AT)='1970-01-01',null,tp.DRIVE_E_AT) `试驾结束时间`
	    ,CASE WHEN tad.STATUS=70711001 THEN '待试驾'
	         WHEN tad.STATUS=70711002 THEN '已试驾'
	         WHEN tad.STATUS=70711003 THEN '已取消'
	         END `试驾状态`
	    ,if(date(tad.DRIVE_S_AT)='1970-01-01',null,tad.DRIVE_S_AT) `试驾开始时间tad`
	    ,if(date(tad.DRIVE_E_AT)='1970-01-01',null,tad.DRIVE_E_AT) `试驾结束时间tad`
		,case when ca.active_name like '%App%'  then 'App'
			when ca.active_name like '%小程序%' or ca.active_name like '%沃世界%' then '小程序' 
			else null end `预约渠道`
		,tc.CODE_CN_DESC `预约单状态`
		,toString(tad.ITEM_ID) `试驾工单id`
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join (
		select *
		from ods_cyap.ods_cyap_tt_appointment_drive_d
		where IS_DELETED  =0
	) tad on tad.APPOINTMENT_ID =ta.APPOINTMENT_ID
	left join (
		select *
		from ods_drse.ods_drse_tt_testdrive_plan_d
		where IS_DELETED = 0
	) tp on tad.ITEM_ID = tp.ITEM_ID
	left join (
		select *
		from ods_memb.ods_memb_tc_member_info_cur
		where is_deleted =0
	) tmi on toString(tmi.id) =ta.user_member_id 
	left join ods_bada.ods_bada_tm_model_cur tm on toString(tm.id)=tad.THIRD_ID
	left join ods_actv.ods_actv_cms_active_d ca on ca.uid =ta.CHANNEL_ID 
	left join (
	    select 
	        tm.id `经销商表ID`,
	        tm.org_id`经销商组织ID`,
	        tm.company_code  company_code,
	        tg2.ID `大区组织ID`,
	        tg2.ORG_NAME ORG_NAME_big,
	        tg1.ID `小区组织ID`,
	        tg1.ORG_NAME ORG_NAME_small,
	        tm.company_name_cn COMPANY_NAME_CN ,
	        tm.group_company_name GROUP_COMPANY_NAME
	    from ods_orga.ods_orga_tm_company_cur tm
	    inner JOIN ods_orga.ods_orga_tr_org_d tr1 ON tr1.org_id= tm.org_id
	    inner JOIN (
	    	select * from ods_orga.ods_orga_tm_org_d where ORG_TYPE = 15061007
	    ) tg1 ON tg1.ID = tr1.parent_org_id 
	    inner JOIN ods_orga.ods_orga_tr_org_d tr2 ON tr2.org_id = tr1.parent_org_id
	    inner JOIN (
	    	select * from ods_orga.ods_orga_tm_org_d where ORG_TYPE = 15061005 
	    ) tg2 ON tg2.ID = tr2.parent_org_id
	    where tm.is_deleted = 0 AND tm.company_type= 15061003 
	) delear on delear.company_code=ta.OWNER_CODE 
	left join ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =ta.IS_ARRIVED 
	where ta.APPOINTMENT_TYPE =70691002
	and ta.DATA_SOURCE ='C'
	and date(ta.CREATED_AT) between '2024-03-08' and '2024-03-14'
 )
SELECT base.*,if(events.APPOINTMENT_ID is null,'否','是') `是否预约前访问活动页`
	,if(date(drow.create_time)='1970-01-01',null,drow.create_time) `抽中预约V值时间`
	,case when date(drow.create_time)<>'1970-01-01' and cast(drow.create_time as timestamp)<cast(base.`预约创建时间` as timestamp) then '是' end `是否抽奖后预约`
from base 
	left join (
	--访问过活动主页的oneid
	select ad.APPOINTMENT_ID
	from (
		select distinct_id,cast(`time` as timestamp) view_time
		from ods_rawd.ods_rawd_events_d_di
		where date(`date`) between '2024-03-08' and '2024-03-14'
	--	and event ='Page_entry'
		and activity_name='2024年3月平台活动'
		and length(distinct_id)<9
	) events
	inner join (
	select ta.ONE_ID,ta.APPOINTMENT_ID,ta.CREATED_AT
	from ods_cyap.ods_cyap_tt_appointment_d ta
	where ta.APPOINTMENT_TYPE =70691002
	and ta.DATA_SOURCE ='C'
	and date(ta.CREATED_AT) between '2024-03-08' and '2024-03-14'
	) ad on toString(ad.ONE_ID)=events.distinct_id
	where events.view_time<ad.CREATED_AT--筛选预约前访问过活动页的用户
	group by ad.APPOINTMENT_ID
) events on events.APPOINTMENT_ID=base.`预约id`
left join (
	select ldl.member_id,ldl.create_time
	from ods_voam.ods_voam_lottery_draw_log_d ldl
	where date(ldl.create_time) between '2024-03-08' and '2024-03-14'
	and ldl.lottery_code like '%2024_03_platform'
	and ldl.prize_code='KVOaXsJpVW'
) drow on drow.member_id = base.`试驾memberID`