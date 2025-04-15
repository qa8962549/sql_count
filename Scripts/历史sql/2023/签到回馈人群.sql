#连续签到100天及以上人数
select 
m.MEMBER_NAME 昵称,
m.MEMBER_PHONE 手机号,
m.ID 会员ID,
m.REAL_NAME 姓名,
x.收货地址 沃世界留资地址
from (
select d.member_id,max(d.次数) 连续签到次数
	from (
	select c.member_id,c.最早登录时间,count(1) 次数
	from (
		select b.member_id,b.日期,DATE_SUB(b.日期,b.rank) 最早登录时间
		from (
			# 日期降序排序
			select a.MEMBER_ID
			,a.`日期`
			,row_number() over(PARTITION by a.MEMBER_ID order by a.`日期` ) rank
			from (
			select DISTINCT i.MEMBER_ID,DATE(i.CREATE_TIME) 日期
			from mine.sign_info i 
			join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
			where i.is_delete=0 and i.create_time <= '2022-12-31 23:59:59'
			) a 
		) b
	) c GROUP BY 1,2 order by 3 desc 
) d GROUP BY 1 HAVING max(d.次数)>=100 order by 2 desc 
) a 
left join member.tc_member_info m on a.member_id=m.id
left join 
	(
	select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
	(
	select 
	tma.MEMBER_ID,
	tma.CONSIGNEE_NAME 收货人姓名,
	tma.CONSIGNEE_PHONE 收货人手机号,
	CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址,
	row_number() over(partition by tma.member_address order by tma.create_time desc) rk
	from `member`.tc_member_address tma
	left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
	left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
	left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
	where tma.IS_DELETED = 0
	and tma.IS_DEFAULT = 1   -- 默认收货地址
	)c where c.rk = 1
)x on x.MEMBER_ID=a.member_id 

# 累计签到200天去重
select
m.MEMBER_NAME 昵称,
m.MEMBER_PHONE 手机号,
m.ID 会员ID,
m.REAL_NAME 姓名,
x.收货地址 沃世界留资地址
from (
	select a.MEMBER_ID,a.IS_VEHICLE,count(1)
		from (
		select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
		from mine.sign_info i 
		join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
		where i.is_delete=0 
		and i.create_time <= '2022-12-31 23:59:59'
	) a 
	GROUP BY 1,2 
	HAVING count(1)>=200
	order by 2 desc 
) a 
left join member.tc_member_info m on a.member_id=m.id
left join 
	(
	select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
	(
	select 
	tma.MEMBER_ID,
	tma.CONSIGNEE_NAME 收货人姓名,
	tma.CONSIGNEE_PHONE 收货人手机号,
	CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址,
	row_number() over(partition by tma.member_address order by tma.create_time desc) rk
	from `member`.tc_member_address tma
	left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
	left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
	left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
	where tma.IS_DELETED = 0
	and tma.IS_DEFAULT = 1   -- 默认收货地址
	)c where c.rk = 1
)x on x.MEMBER_ID=a.member_id 

# 筛选签到累计300天及以上的活跃用户且仅中18V值的活跃用户
select
DISTINCT 
m.MEMBER_NAME 昵称,
m.MEMBER_PHONE 手机号,
m.ID 会员ID,
m.REAL_NAME 姓名,
x.收货地址 沃世界留资地址,
a.tt 签到天数,
b.prize_name
from 
		(### 实物奖品中奖明细
		select 
		DISTINCT l.member_id,
		l.prize_name
		from mine.sign_lottery_log l 
		where l.is_delete=0 
		and l.have_win=1
		and l.create_time >= '2022-01-10'
		and l.create_time <= '2022-12-31 23:59:59'
		and l.prize_name='18V值'
		)b 
	join 
(
	select a.MEMBER_ID,a.IS_VEHICLE,count(1) tt
		from (
		select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
		from mine.sign_info i 
		join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
		where i.is_delete=0 
		and i.create_time <= '2022-12-31 23:59:59'
	) a 
	GROUP BY 1,2 
	HAVING count(1)>=300
	order by 2 desc 
	) a on a.MEMBER_ID=b.MEMBER_ID
left join member.tc_member_info m on a.member_id=m.id
left join 
	(
	select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
	(
	select 
	tma.MEMBER_ID,
	tma.CONSIGNEE_NAME 收货人姓名,
	tma.CONSIGNEE_PHONE 收货人手机号,
	CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址,
	row_number() over(partition by tma.member_address order by tma.create_time desc) rk
	from `member`.tc_member_address tma
	left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
	left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
	left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
	where tma.IS_DELETED = 0
	and tma.IS_DEFAULT = 1   -- 默认收货地址
	)c where c.rk = 1
)x on x.MEMBER_ID=a.member_id 

-- "筛选签到累计200天及以上的活跃用户且未中过奖共计390名"
select
DISTINCT 
m.MEMBER_NAME 昵称,
m.MEMBER_PHONE 手机号,
m.ID 会员ID,
m.REAL_NAME 姓名,
x.收货地址 沃世界留资地址
from 
	(### 未中奖
	select 
	l.member_id
	from mine.sign_lottery_log l 
	where l.is_delete=0 
	and l.create_time >= '2022-01-10'
	and l.create_time <= '2022-12-31 23:59:59'
	group by 1
	HAVING sum(l.have_win)='0'
	)b 
join 
(
	select a.MEMBER_ID,a.IS_VEHICLE,count(1)
		from (
		select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
		from mine.sign_info i 
		join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
		where i.is_delete=0 
		and i.create_time <= '2022-12-31 23:59:59'
	) a 
	GROUP BY 1,2 
	HAVING count(1)>=200
	order by 2 desc 
) a on a.MEMBER_ID=b.MEMBER_ID
left join member.tc_member_info m on a.member_id=m.id
left join 
	(
	select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
	(
	select 
	tma.MEMBER_ID,
	tma.CONSIGNEE_NAME 收货人姓名,
	tma.CONSIGNEE_PHONE 收货人手机号,
	CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址,
	row_number() over(partition by tma.member_address order by tma.create_time desc) rk
	from `member`.tc_member_address tma
	left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
	left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
	left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
	where tma.IS_DELETED = 0
	and tma.IS_DEFAULT = 1   -- 默认收货地址
	)c where c.rk = 1
)x on x.MEMBER_ID=a.member_id 

#筛选连续签到100天及以上的活跃用户且未中过奖
select 
m.MEMBER_NAME 昵称,
m.MEMBER_PHONE 手机号,
m.ID 会员ID,
m.REAL_NAME 姓名,
x.收货地址 沃世界留资地址
from 
	(### 未中奖
	select 
	l.member_id
	from mine.sign_lottery_log l 
	where l.is_delete=0 
	and l.create_time >= '2022-01-10'
	and l.create_time <= '2022-12-31 23:59:59'
	group by 1
	HAVING sum(l.have_win)='0'
	)b
join 
(
select d.member_id,max(d.次数) 连续签到次数
	from (
	select c.member_id,c.最早登录时间,count(1) 次数
	from (
		select b.member_id,b.日期,DATE_SUB(b.日期,b.rank) 最早登录时间
		from (
			# 日期降序排序
			select a.MEMBER_ID
			,a.`日期`
			,row_number() over(PARTITION by a.MEMBER_ID order by a.`日期` ) rank
			from (
			select DISTINCT i.MEMBER_ID,DATE(i.CREATE_TIME) 日期
			from mine.sign_info i 
			join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
			where i.is_delete=0 and i.create_time <= '2022-12-31 23:59:59'
			) a 
		) b
	) c GROUP BY 1,2 order by 3 desc 
) d GROUP BY 1 HAVING max(d.次数)>=100 order by 2 desc 
) a on a.member_id=b.member_id
left join member.tc_member_info m on a.member_id=m.id
left join 
	(
	select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
	(
	select 
	tma.MEMBER_ID,
	tma.CONSIGNEE_NAME 收货人姓名,
	tma.CONSIGNEE_PHONE 收货人手机号,
	CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址,
	row_number() over(partition by tma.member_address order by tma.create_time desc) rk
	from `member`.tc_member_address tma
	left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
	left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
	left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
	where tma.IS_DELETED = 0
	and tma.IS_DEFAULT = 1   -- 默认收货地址
	)c where c.rk = 1
)x on x.MEMBER_ID=a.member_id 