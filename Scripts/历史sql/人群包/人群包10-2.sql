-- 9-2 人群包 拆分
-- 1、车主：近30天将有大额过期积分，12月1号即将过期V值总和大于等于1,500 V值的人
			select c.*
            from (select
					a.MEMBER_ID,
					b.real_name 姓名,
					b.member_phone 手机,
					b.member_v_num V值余额,
					b.is_vehicle,
					sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
					case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2' else '1' end 区间
			from `member`.tt_member_score_record a
			join `member`.tc_member_info b on a.MEMBER_ID = b.id
			where a.IS_DELETED=0
					and a.CREATE_TIME<='2020-11-30 23:59:59'
					and a.CREATE_TIME>='2020-11-01'
					and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
					AND b.is_deleted = 0
					AND b.member_status <> 60341003
			GROUP BY 1,3
			ORDER BY 6 DESC)c
            where c.is_vehicle = '1'
            and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'
            and c.区间= '1'

            
        
-- 粉丝：近30天将有大额过期积分，12月1号即将过期V值总和大于等于1,500 V值的人
			select c.*
            from (
            select
					a.MEMBER_ID,
					b.real_name 姓名,
					b.member_phone 手机,
					b.member_v_num V值余额,
					b.is_vehicle,
					sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
					sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL-c.INTEGRAL) 未使用V值2,
					case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2' else '1' end 区间
			from `member`.tt_member_score_record a
			join `member`.tc_member_info b on a.MEMBER_ID = b.id
			left join `member`.tt_member_flow_record c on a.ID =c.SCORE_ID and c.EVENT_DESC ='V值过期'
			where a.IS_DELETED=0
					and a.CREATE_TIME<='2020-11-30 23:59:59'
					and a.CREATE_TIME>='2020-11-01'
					and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
					AND b.is_deleted = 0
					AND b.member_status <> 60341003
			GROUP BY 1,3
			ORDER BY 6 desc )c
            where c.is_vehicle = '0'
            and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'
            and c.区间= '1'
--             and c.V值余额<c.未使用V值

            
-- 3、近30天将有小额过期积分， 12月1号即将过期V值总和小于1,500 V值的人，且当前V值余额小于等于50V值
select c.*
            from (select
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
					and a.CREATE_TIME<='2020-11-30 23:59:59'
					and a.CREATE_TIME>='2020-11-01'
					and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
					AND b.is_deleted = 0
					AND b.member_status <> 60341003
			GROUP BY 1,2,3,4,5
			ORDER BY 6 DESC)c
            where c.区间= '2'
            and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'
            and c.V值余额 <= 50
--             and c.V值余额<>0
--             and c.V值余额<c.未使用V值
            order by 6
            

-- 4、近30天将有小额过期积分， 12月1号即将过期V值总和小于1,500 V值的人，且当前V值余额大于50V值
select c.*
            from (select
					a.MEMBER_ID,
					b.real_name 姓名,
					b.member_phone 手机,
					b.member_v_num V值余额,
					b.is_vehicle,
					sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
					case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2'
					else '1' end 区间
--    	 				sum(case when a.record_type=1 then -a.INTEGRAL 
--    	 						when a.record_type=0 then a.INTEGRAL else 0 end)
			from `member`.tt_member_score_record a
			join `member`.tc_member_info b on a.MEMBER_ID = b.id
			where a.IS_DELETED=0
					and a.CREATE_TIME<='2020-11-30 23:59:59'
					and a.CREATE_TIME>='2020-11-01'
					and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
					AND b.is_deleted = 0
					AND b.member_status <> 60341003
			GROUP BY 1,2,3,4,5
			ORDER BY 6 DESC)c
            where c.区间= '2'
            and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'
            and c.V值余额 > 50
--             and c.V值余额<c.未使用V值


-- 5、车主：近60天将有大额过期积分，11月1号即将过期V值总和大于等于1,500 V值的人
select c.*
from (select
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
		and a.CREATE_TIME<='2020-12-31 23:59:59'
		and a.CREATE_TIME>='2020-12-01'
		and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
		AND b.is_deleted = 0
		AND b.member_status <> 60341003
GROUP BY 1,2,3,4,5
ORDER BY 6 DESC)c
where c.is_vehicle = '1'
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'
and c.区间= '1'
-- and c.V值余额<c.未使用V值


-- 6、粉丝：近60天将有大额过期积分，11月1号即将过期V值总和大于等于1,500 V值的人
select c.*
from (select
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
		and a.CREATE_TIME<='2020-12-31 23:59:59'
		and a.CREATE_TIME>='2020-12-01'
		and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
		AND b.is_deleted = 0
		AND b.member_status <> 60341003
GROUP BY 1,2,3,4,5
ORDER BY 6 DESC)c
where c.is_vehicle = '0'
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'
and c.区间= '1'
-- and c.V值余额<c.未使用V值

-- 7、近60天将有小额过期积分， 11月1号即将过期V值总和小于1,500 V值的人，且当前V值余额小于等于50V值
select c.*
            from (select
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
					and a.CREATE_TIME<='2020-12-31 23:59:59'
					and a.CREATE_TIME>='2020-12-01'
					and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
					AND b.is_deleted = 0
					AND b.member_status <> 60341003
			GROUP BY 1,2,3,4,5
			ORDER BY 6 DESC)c
            where c.区间= '2'
            and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'
            and c.V值余额 <= 50
--             and c.V值余额<c.未使用V值

-- 8、近60天将有小额过期积分， 11月1号即将过期V值总和小于1,500 V值的人，且当前V值余额大于50V值
select c.*
            from (select
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
					and a.CREATE_TIME<='2020-12-30 23:59:59'
					and a.CREATE_TIME>='2020-12-01'
					and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
					AND b.is_deleted = 0
					AND b.member_status <> 60341003
			GROUP BY 1,2,3,4,5
			ORDER BY 6 DESC)c
            where c.区间= '2'
            and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'
            and c.V值余额 >50
--             and c.V值余额<c.未使用V值

            
           