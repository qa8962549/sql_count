SELECT WEEkday('2023-02-10')
union
select WEEKDAY('2023-02-08')
union
select WEEKDAY('2023-02-06')


-- 2022年12月 小程序和APP去重月活
select 
day(time) tt
,count(distinct distinct_id)
from ods_rawd.ods_rawd_events_l_di
where 1=1
and $lib in('iOS','Android','MiniProgram')  -- app
--and $lib in('iOS','Android')  -- app
--and event in('$AppStart','$AppInstall','$AppStartPassively','$AppDeepLinkLaunch','Page_view','Button_click')
and time between '2022-12-01' and '2023-01-01' 
and length(distinct_id)<9
and distinct_id not like '%#%'
group by tt
--and left($app_version,1)='5'

select 
day(time)
,count(distinct distinct_id)
from events
where 1=1
and $lib in('iOS','Android','MiniProgram')  -- app
--and $lib in('iOS','Android')  -- app
--and event in('$AppStart','$AppInstall','$AppStartPassively','$AppDeepLinkLaunch','Page_view','Button_click')
and time between '2022-12-01' and '2023-01-01' 
and length(distinct_id)<9
and distinct_id not like '%#%'
group by 1 
order by 1