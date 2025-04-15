--参考代码
select var_page_title,
count(distinct b.usr_merged_gio_id) uv,
count(1) pv
--event_key,gio_id,user,$platform,var_channel,var_page_title,var_content_id,var_car_type,var_view_duration,var_view_advance,client_time
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on toString(a.gio_id)=toString(b.gio_id)
where 1=1
and event_time>='2024-08-16'
and client_time>='2024-08-16'
and client_time<'2024-09-19'
and event_key ='Page_entry'
and ($platform in('MinP') or var_channel='Mini')
and var_promotion_channel_sub_type='volvo_world'
and var_promotion_methods='sun_code'
and var_promotion_activity='202312_shared_airport'
and var_promotion_supplement='1'
group by 1

--参考代码2
select var_page_title,
count(distinct b.usr_merged_gio_id) uv,
count(1) pv
--event_key,gio_id,user,$platform,var_channel,var_page_title,var_content_id,var_car_type,var_view_duration,var_view_advance,client_time
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on toString(a.gio_id)=toString(b.gio_id)
where 1=1
and event_time>='2024-08-16'
and client_time>='2024-08-16'
and client_time<'2024-09-19'
and event_key ='Page_entry'
and ($platform in('MinP') or var_channel='Mini')
and var_promotion_channel_sub_type='volvo_world'
and var_promotion_methods='sun_code'
and var_promotion_activity='202312_beijing_airport'
and var_promotion_supplement='1'
group by 1