-- 夏服留资明细
SELECT a.member_name 姓名,
a.phone 手机,
a.city 城市, 
a.dealer_name 经销商名称
from volvo_online_activity.season_user_info a
where a.delete_flag =0
and a.create_date >='2022-08-05'
and a.create_date <='2022-08-07 12:00:00'