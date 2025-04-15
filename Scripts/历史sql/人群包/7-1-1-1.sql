-- 7-1-1 近30天将有大额过期积分，7月1号即将过期V值总和大于等于1,500 V值的人

# 2022年7月人群包

select c.*
from 
	(
	select a.*
	,case when b.手机 is not null then 1 else null end 重复
		from (
			### 8月过期V值
			select
					a.MEMBER_ID,
					b.real_name 姓名,
					b.member_phone 手机,
					b.member_v_num V值余额,
					b.is_vehicle,
					sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
					case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2'
					else '1' end 区间
			from `member`.tt_member_score_record a
			join `member`.tc_member_info b on a.MEMBER_ID = b.id
			where a.IS_DELETED=0
					and a.CREATE_TIME<='2020-07-31 23:59:59'
					and a.CREATE_TIME>='2020-07-01'
					and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
					AND b.is_deleted = 0
					AND b.member_status = 60341001
			GROUP BY 1,2,3,4,5
			ORDER BY 6 DESC
			union all 
			### 9月过期V值
			select
					a.MEMBER_ID,
					b.real_name 姓名,
					b.member_phone 手机,
					b.member_v_num V值余额,
					b.is_vehicle,
					sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
					case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '4'
					else '3' end 区间
			from `member`.tt_member_score_record a
			join `member`.tc_member_info b on a.MEMBER_ID = b.id
			where a.IS_DELETED=0
					and a.CREATE_TIME<='2020-08-31 23:59:59'
					and a.CREATE_TIME>='2020-08-01'
					and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
					AND b.is_deleted = 0
					AND b.member_status = 60341001
					and b.id not in (
						select a.member_id
						from (
								select a.MEMBER_ID,
								b.real_name 姓名,
								b.member_phone 手机,
								b.member_v_num V值余额,
								b.is_vehicle,
								sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
								case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2'
								else '1' end 区间
								from `member`.tt_member_score_record a
								join `member`.tc_member_info b on a.MEMBER_ID = b.id
								where a.IS_DELETED=0
								and a.CREATE_TIME<='2020-07-31 23:59:59'
								and a.CREATE_TIME>='2020-07-01'
								and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
								AND b.is_deleted = 0
								AND b.member_status = 60341001
								GROUP BY 1,2,3,4,5
								ORDER BY 6 DESC
								) a 
			)
			GROUP BY 1,2,3,4,5
			ORDER BY 6 DESC 
		) a 
	left join 
		(
			### 手机号重复会员ID
			select a.手机,count(1)
			from(
			select
					a.MEMBER_ID,
					b.real_name 姓名,
					b.member_phone 手机,
					b.member_v_num V值余额,
					b.is_vehicle,
					sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
					case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2'
					else '1' end 区间
			from `member`.tt_member_score_record a
			join `member`.tc_member_info b on a.MEMBER_ID = b.id
			where a.IS_DELETED=0
					and a.CREATE_TIME<='2020-08-31 23:59:59'
					and a.CREATE_TIME>='2020-07-01'
					and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
					AND b.is_deleted = 0
					AND b.member_status = 60341001
			GROUP BY 1,2,3,4,5
			ORDER BY 6 DESC
			) a 
			group by 1 
			having count(1)>1 
		) b on a.手机=b.手机
	order by 8 desc,3
	) c 
where c.重复 is null 
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'
and c.区间=1


# 2022年8月人群包

select c.*
from (
select a.*
,case when b.手机 is not null then 1 else null end 重复
from (
	### 9月即将过期V值
	select
			a.MEMBER_ID,
			b.real_name 姓名,
			b.member_phone 手机,
			b.member_v_num V值余额,
			b.is_vehicle,
			sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
			case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2'
			else '1' end 区间
	from `member`.tt_member_score_record a
	join `member`.tc_member_info b on a.MEMBER_ID = b.id
	where a.IS_DELETED=0
			and a.CREATE_TIME<='2020-08-31 23:59:59'
			and a.CREATE_TIME>='2020-08-01'
			and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
			AND b.is_deleted = 0
			AND b.member_status = 60341001
	GROUP BY 1,2,3,4,5
	ORDER BY 6 DESC
	union all 
	### 10月即将过期V值
	select
			a.MEMBER_ID,
			b.real_name 姓名,
			b.member_phone 手机,
			b.member_v_num V值余额,
			b.is_vehicle,
			sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
			case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '4'
			else '3' end 区间
	from `member`.tt_member_score_record a
	join `member`.tc_member_info b on a.MEMBER_ID = b.id
	where a.IS_DELETED=0
			and a.CREATE_TIME<='2020-09-30 23:59:59'
			and a.CREATE_TIME>='2020-09-01'
			and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
			AND b.is_deleted = 0
			AND b.member_status = 60341001
			and b.id not in (
				select a.member_id
				from (
						select a.MEMBER_ID,
						b.real_name 姓名,
						b.member_phone 手机,
						b.member_v_num V值余额,
						b.is_vehicle,
						sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
						case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2'
						else '1' end 区间
						from `member`.tt_member_score_record a
						join `member`.tc_member_info b on a.MEMBER_ID = b.id
						where a.IS_DELETED=0
						and a.CREATE_TIME<='2020-08-31 23:59:59'
						and a.CREATE_TIME>='2020-08-01'
						and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
						AND b.is_deleted = 0
						AND b.member_status = 60341001
						GROUP BY 1,2,3,4,5
						ORDER BY 6 DESC
				) a 
	)
	GROUP BY 1,2,3,4,5
	ORDER BY 6 DESC 
) a 
left join (
	### 手机号重复会员ID
	select a.手机,count(1)
	from(
	select
			a.MEMBER_ID,
			b.real_name 姓名,
			b.member_phone 手机,
			b.member_v_num V值余额,
			b.is_vehicle,
			sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
			case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2'
			else '1' end 区间
	from `member`.tt_member_score_record a
	join `member`.tc_member_info b on a.MEMBER_ID = b.id
	where a.IS_DELETED=0
			and a.CREATE_TIME<='2020-09-30 23:59:59'
			and a.CREATE_TIME>='2020-08-01'
			and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
			AND b.is_deleted = 0
			AND b.member_status = 60341001
	GROUP BY 1,2,3,4,5
	ORDER BY 6 DESC
	) a 
	group by 1 
	having count(1)>1 
) b on a.手机=b.手机
order by 8 desc,3
) c 
where c.重复 is null 
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'
and c.区间=1