-- 创建本地表  
CREATE TABLE if not exists ods_oper_crm.lzc_0620_l_si on cluster default_cluster
ENGINE = ReplicatedMergeTree
ORDER BY send_id  -- 根据主键排序
SETTINGS index_granularity = 8192
as
with send as  (
select 
	replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(send.id,'message',''),'questionnarie',''),'mms',''),'sms',''),'app_push','')
		,'instation_mini_program_',''),'instation_app_',''),'mini_program',''),'instation',''),'wechat_mp_template','') as send_sendid_new
	,arrayJoin(splitByChar(',',cast(case when send.context__touch_channel='wechat_mp_template' then 'public_account_template_message' else send.context__touch_channel end as varchar))) send_channel_new
	,send.id send_id
    ,send.oneid send_oneid
    ,send.version send_version
    ,send.userid send_userid
    ,send.objectid send_objectid
    ,send.placeid send_placeid
    ,send.sourceid send_sourceid
    ,send.context send_context
    ,send.label send_label
    ,send.event_ts send_event_ts
    ,send.publish_ts send_publish_ts
    ,send.collect_ts send_collect_ts
    ,send.publisher send_publisher
    ,send.source send_source
    ,send.extend send_extend
    ,send.eventid send_eventid
    ,send.pday send_pday
    ,send.event_date_ts send_event_date_ts
    ,send.context__event_time send_context__event_time
    ,send.context__individual_id send_context__individual_id
    ,send.context__oneid send_context__oneid
    ,send.context__individual_id_type send_context__individual_id_type
    ,send.context__message_id send_context__message_id
    ,send.context__send_time send_context__send_time
    ,send.context__touch_channel send_context__touch_channel
    ,send.context__content_type send_context__content_type
    ,send.context__materials_num send_context__materials_num
    ,send.context__status send_context__status
    ,send.context__erro_code send_context__erro_code
    ,send.context__erro_message send_context__erro_message
    ,send.context__message send_context__message
    ,send.context__task_id send_context__task_id
    ,send.context__task_name send_context__task_name
    ,send.context__business_type send_context__business_type
    ,send.context__content_model_id send_context__content_model_id
    ,send.context__content_model_name send_context__content_model_name
    ,send.context__jump_type send_context__jump_type
    ,send.context__original_url send_context__original_url
    ,send.context__original_url_id send_context__original_url_id
    ,send.context__original_url_name send_context__original_url_name
    ,send.context__link_content_type send_context__link_content_type
    ,send.userid__eventuserid send_userid__eventuserid
    ,send.context__touch_event_id send_context__touch_event_id
    ,send.context__questionnaire_request_id send_context__questionnaire_request_id
    ,send.context__batch_id send_context__batch_id
    ,send._etl_time send__etl_time
    ,send._data_inlh_date send__data_inlh_date
from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d send
)
,click as (
select 
	replace(replace(replace(replace(replace(replace(replace(replace(replace(click.context__send_event_id,'mms',''),'sms',''),'app_push','')
		,'instation_mini_program_',''),'instation_app_',''),'mini_program',''),'instation',''),'wechat_mp_template',''),'public_account_template_message','') as click_sendid_new
	,click.id click_id
    ,click.oneid click_oneid
    ,click.version click_version
    ,click.userid click_userid
    ,click.objectid click_objectid
    ,click.placeid click_placeid
    ,click.sourceid click_sourceid
    ,click.context click_context
    ,click.label click_label
    ,click.event_ts click_event_ts
    ,click.publish_ts click_publish_ts
    ,click.collect_ts click_collect_ts
    ,click.publisher click_publisher
    ,click.source click_source
    ,click.extend click_extend
    ,click.eventid click_eventid
    ,click.pday click_pday
    ,click.event_date_ts click_event_date_ts
    ,click.context__event_id click_context__event_id
    ,click.context__event_time click_context__event_time
    ,click.context__individual_id click_context__individual_id
    ,click.context__oneid click_context__oneid
    ,click.context__individual_id_type click_context__individual_id_type
    ,click.context__click_time click_context__click_time
    ,click.context__channel_type click_context__channel_type
    ,click.context__original_url click_context__original_url
    ,click.context__original_url_id click_context__original_url_id
    ,click.context__original_url_name click_context__original_url_name
    ,click.context__hash click_context__hash
    ,click.context__link_content_type click_context__link_content_type
    ,click.context__send_event_id click_context__send_event_id
    ,click.context__task_id click_context__task_id
    ,click.context__task_name click_context__task_name
    ,click.context__content_type click_context__content_type
    ,click.context__content_model_id click_context__content_model_id
    ,click.context__content_model_name click_context__content_model_name
    ,click.context__business_type click_context__business_type
    ,click.userid__eventuserid click_userid__eventuserid
from ods_cdp.ods_cdvo_event_flat_volvo_event_url_click_customer_profilebase_d click
) 
select *
from send
left join click on send.send_sendid_new=click.click_sendid_new and send.send_channel_new=click.click_context__channel_type

-- 创建分布式表
CREATE TABLE if not exists ods_oper_crm.lzc_0620_d_si on cluster default_cluster
ENGINE = Distributed('default_cluster', 'ods_oper_crm', 'lzc_0620_l_si', rand());
-- 括号内参数依次为：cluster集群名（表示服务器集群配置），数据库名，本地表名，在读写时会根据rand()随机函数的取值来决定数据写⼊哪个分⽚(分片key)
as
with send as  (
select 
	replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(send.id,'message',''),'questionnarie',''),'mms',''),'sms',''),'app_push','')
		,'instation_mini_program_',''),'instation_app_',''),'mini_program',''),'instation',''),'wechat_mp_template','') as send_sendid_new
	,arrayJoin(splitByChar(',',cast(case when send.context__touch_channel='wechat_mp_template' then 'public_account_template_message' else send.context__touch_channel end as varchar))) send_channel_new
	,send.id send_id
    ,send.oneid send_oneid
    ,send.version send_version
    ,send.userid send_userid
    ,send.objectid send_objectid
    ,send.placeid send_placeid
    ,send.sourceid send_sourceid
    ,send.context send_context
    ,send.label send_label
    ,send.event_ts send_event_ts
    ,send.publish_ts send_publish_ts
    ,send.collect_ts send_collect_ts
    ,send.publisher send_publisher
    ,send.source send_source
    ,send.extend send_extend
    ,send.eventid send_eventid
    ,send.pday send_pday
    ,send.event_date_ts send_event_date_ts
    ,send.context__event_time send_context__event_time
    ,send.context__individual_id send_context__individual_id
    ,send.context__oneid send_context__oneid
    ,send.context__individual_id_type send_context__individual_id_type
    ,send.context__message_id send_context__message_id
    ,send.context__send_time send_context__send_time
    ,send.context__touch_channel send_context__touch_channel
    ,send.context__content_type send_context__content_type
    ,send.context__materials_num send_context__materials_num
    ,send.context__status send_context__status
    ,send.context__erro_code send_context__erro_code
    ,send.context__erro_message send_context__erro_message
    ,send.context__message send_context__message
    ,send.context__task_id send_context__task_id
    ,send.context__task_name send_context__task_name
    ,send.context__business_type send_context__business_type
    ,send.context__content_model_id send_context__content_model_id
    ,send.context__content_model_name send_context__content_model_name
    ,send.context__jump_type send_context__jump_type
    ,send.context__original_url send_context__original_url
    ,send.context__original_url_id send_context__original_url_id
    ,send.context__original_url_name send_context__original_url_name
    ,send.context__link_content_type send_context__link_content_type
    ,send.userid__eventuserid send_userid__eventuserid
    ,send.context__touch_event_id send_context__touch_event_id
    ,send.context__questionnaire_request_id send_context__questionnaire_request_id
    ,send.context__batch_id send_context__batch_id
    ,send._etl_time send__etl_time
    ,send._data_inlh_date send__data_inlh_date
from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d send
)
,click as (
select 
	replace(replace(replace(replace(replace(replace(replace(replace(replace(click.context__send_event_id,'mms',''),'sms',''),'app_push','')
		,'instation_mini_program_',''),'instation_app_',''),'mini_program',''),'instation',''),'wechat_mp_template',''),'public_account_template_message','') as click_sendid_new
	,click.id click_id
    ,click.oneid click_oneid
    ,click.version click_version
    ,click.userid click_userid
    ,click.objectid click_objectid
    ,click.placeid click_placeid
    ,click.sourceid click_sourceid
    ,click.context click_context
    ,click.label click_label
    ,click.event_ts click_event_ts
    ,click.publish_ts click_publish_ts
    ,click.collect_ts click_collect_ts
    ,click.publisher click_publisher
    ,click.source click_source
    ,click.extend click_extend
    ,click.eventid click_eventid
    ,click.pday click_pday
    ,click.event_date_ts click_event_date_ts
    ,click.context__event_id click_context__event_id
    ,click.context__event_time click_context__event_time
    ,click.context__individual_id click_context__individual_id
    ,click.context__oneid click_context__oneid
    ,click.context__individual_id_type click_context__individual_id_type
    ,click.context__click_time click_context__click_time
    ,click.context__channel_type click_context__channel_type
    ,click.context__original_url click_context__original_url
    ,click.context__original_url_id click_context__original_url_id
    ,click.context__original_url_name click_context__original_url_name
    ,click.context__hash click_context__hash
    ,click.context__link_content_type click_context__link_content_type
    ,click.context__send_event_id click_context__send_event_id
    ,click.context__task_id click_context__task_id
    ,click.context__task_name click_context__task_name
    ,click.context__content_type click_context__content_type
    ,click.context__content_model_id click_context__content_model_id
    ,click.context__content_model_name click_context__content_model_name
    ,click.context__business_type click_context__business_type
    ,click.userid__eventuserid click_userid__eventuserid
from ods_cdp.ods_cdvo_event_flat_volvo_event_url_click_customer_profilebase_d click
) 
select *
from send
left join click on send.send_sendid_new=click.click_sendid_new and send.send_channel_new=click.click_context__channel_type