-- 10-8-1
select DISTINCT a.phone
from volvo_online_activity.golf_member_record a
where a.deleted =0
and code='2021_golf_activity'
and length(a.phone)=11