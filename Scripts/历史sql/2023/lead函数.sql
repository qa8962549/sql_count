SELECT a.user_id ,
a.create_time  ,
lead(a.create_time,1) over(partition by a.user_id order by a.create_time) nt
from `order`.tt_order a
where a.create_time is not null
