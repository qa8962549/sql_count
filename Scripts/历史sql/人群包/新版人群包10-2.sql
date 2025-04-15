-- 车主：近30天将有大额过期积分，12月1号即将过期V值总和大于等于1,500 V值的人
select c.*
from 
	(
	select 
	x.member_id
	,m.REAL_NAME 姓名
	,m.MEMBER_PHONE 手机
	,m.MEMBER_V_NUM 余额
	,m.IS_VEHICLE 
	,if(cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)>m.MEMBER_V_NUM,
			m.MEMBER_V_NUM,
			cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)) 过期V值
	from 
		(
		select a.MEMBER_ID
		,sum(case when a.RECORD_TYPE=0 then a.INTEGRAL else 0 end) ff  -- 累计发放
		,sum(case when a.RECORD_TYPE=0 and date_format(a.CREATE_TIME,'%Y%m') = DATE_FORMAT(DATE_SUB(curdate(),interval 24 month),'%Y%m') then a.INTEGRAL else 0 end) ff0-- 当月发放
		,sum(case when a.RECORD_TYPE=1 then a.INTEGRAL else 0 end) xx-- 累计消耗
		from `member`.tt_member_flow_record a
		where a.is_deleted=0
		group by 1
	)x join `member`.tc_member_info m on m.id=x.MEMBER_ID 
	where m.MEMBER_V_NUM <> 0
	and m.is_deleted = 0
	and m.member_status <> 60341003 
	and x.MEMBER_ID =4308006
	group by 1,2,3
	order by 6 desc 
)c
where c.is_vehicle = '1'
and c.过期V值>=1500
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'

-- 粉丝：近30天将有大额过期积分，12月1号即将过期V值总和大于等于1,500 V值的人
select c.*
from 
	(
	select 
	x.member_id
	,m.REAL_NAME 姓名
	,m.MEMBER_PHONE 手机
	,m.MEMBER_V_NUM 余额
	,m.IS_VEHICLE 
	,if(cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)>m.MEMBER_V_NUM,
			m.MEMBER_V_NUM,
			cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)) 过期V值
	from 
		(
		select a.MEMBER_ID
		,sum(case when a.RECORD_TYPE=0 then a.INTEGRAL else 0 end) ff  -- 累计发放
		,sum(case when a.RECORD_TYPE=0 and date_format(a.CREATE_TIME,'%Y%m') = DATE_FORMAT(DATE_SUB(curdate(),interval 24 month),'%Y%m') then a.INTEGRAL else 0 end) ff0-- 当月发放
		,sum(case when a.RECORD_TYPE=1 then a.INTEGRAL else 0 end) xx-- 累计消耗
		from `member`.tt_member_flow_record a
		where a.is_deleted=0
		group by 1
	)x join `member`.tc_member_info m on m.id=x.MEMBER_ID 
	where m.MEMBER_V_NUM <> 0
	and m.is_deleted = 0
	and m.member_status <> 60341003 
	group by 1,2,3
	order by 6 desc 
)c
where c.is_vehicle = '0'
and c.过期V值>=1500
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'

-- 近30天将有小额过期积分， 12月1号即将过期V值总和小于1,500 V值的人，且当前V值余额小于等于50且大于1V值
select c.*
from 
	(
	select 
	x.member_id
	,m.REAL_NAME 姓名
	,m.MEMBER_PHONE 手机
	,m.MEMBER_V_NUM 余额
	,m.IS_VEHICLE 
	,if(cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)>m.MEMBER_V_NUM,
			m.MEMBER_V_NUM,
			cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)) 过期V值
	from 
		(
		select a.MEMBER_ID
		,sum(case when a.RECORD_TYPE=0 then a.INTEGRAL else 0 end) ff  -- 累计发放
		,sum(case when a.RECORD_TYPE=0 and date_format(a.CREATE_TIME,'%Y%m') = DATE_FORMAT(DATE_SUB(curdate(),interval 24 month),'%Y%m') then a.INTEGRAL else 0 end) ff0-- 当月发放
		,sum(case when a.RECORD_TYPE=1 then a.INTEGRAL else 0 end) xx-- 累计消耗
		from `member`.tt_member_flow_record a
		where a.is_deleted=0
		group by 1
	)x join `member`.tc_member_info m on m.id=x.MEMBER_ID 
	where m.MEMBER_V_NUM <> 0
	and m.is_deleted = 0
	and m.member_status <> 60341003 
	group by 1,2,3
	order by 6 desc 
)c
where c.过期V值<1500 and c.过期V值 <>0
and c.余额<=50 
and c.余额>=1
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'

-- 近30天将有小额过期积分， 12月1号即将过期V值总和小于1,500 V值的人，且当前V值余额大于50V值
select c.*
from 
	(
	select 
	x.member_id
	,m.REAL_NAME 姓名
	,m.MEMBER_PHONE 手机
	,m.MEMBER_V_NUM 余额
	,m.IS_VEHICLE 
	,if(cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)>m.MEMBER_V_NUM,
			m.MEMBER_V_NUM,
			cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)) 过期V值
	from 
		(
		select a.MEMBER_ID
		,sum(case when a.RECORD_TYPE=0 then a.INTEGRAL else 0 end) ff  -- 累计发放
		,sum(case when a.RECORD_TYPE=0 and date_format(a.CREATE_TIME,'%Y%m') = DATE_FORMAT(DATE_SUB(curdate(),interval 24 month),'%Y%m') then a.INTEGRAL else 0 end) ff0-- 当月发放
		,sum(case when a.RECORD_TYPE=1 then a.INTEGRAL else 0 end) xx-- 累计消耗
		from `member`.tt_member_flow_record a
		where a.is_deleted=0
		group by 1
	)x join `member`.tc_member_info m on m.id=x.MEMBER_ID 
	where m.MEMBER_V_NUM <> 0
	and m.is_deleted = 0
	and m.member_status <> 60341003 
	group by 1,2,3
	order by 6 desc 
)c
where c.过期V值<1500 and c.过期V值 <>0
and c.余额>50 
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'

-- 车主：近60天将有大额过期积分，12月1号即将过期V值总和大于等于1,500 V值的人
select c.*
from 
	(
	select 
	x.member_id
	,m.REAL_NAME 姓名
	,m.MEMBER_PHONE 手机
	,m.MEMBER_V_NUM 余额
	,m.IS_VEHICLE 
	,if(cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)>m.MEMBER_V_NUM,
			m.MEMBER_V_NUM,
			cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)) 过期V值
	from 
		(
		select a.MEMBER_ID
		,sum(case when a.RECORD_TYPE=0 then a.INTEGRAL else 0 end) ff  -- 累计发放
		,sum(case when a.RECORD_TYPE=0 and date_format(a.CREATE_TIME,'%Y%m') = DATE_FORMAT(DATE_SUB(curdate(),interval 23 month),'%Y%m') then a.INTEGRAL else 0 end) ff0-- 当月发放
		,sum(case when a.RECORD_TYPE=1 then a.INTEGRAL else 0 end) xx-- 累计消耗
		from `member`.tt_member_flow_record a
		where a.is_deleted=0
		group by 1
	)x join `member`.tc_member_info m on m.id=x.MEMBER_ID 
	where m.MEMBER_V_NUM <> 0
	and m.is_deleted = 0
	and m.member_status <> 60341003 
	group by 1,2,3
	order by 6 desc 
)c
where c.is_vehicle = '1'
and c.过期V值>=1500
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'

-- 粉丝：近60天将有大额过期积分，12月1号即将过期V值总和大于等于1,500 V值的人
select c.*
from 
	(
	select 
	x.member_id
	,m.REAL_NAME 姓名
	,m.MEMBER_PHONE 手机
	,m.MEMBER_V_NUM 余额
	,m.IS_VEHICLE 
	,if(cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)>m.MEMBER_V_NUM,
			m.MEMBER_V_NUM,
			cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)) 过期V值
	from 
		(
		select a.MEMBER_ID
		,sum(case when a.RECORD_TYPE=0 then a.INTEGRAL else 0 end) ff  -- 累计发放
		,sum(case when a.RECORD_TYPE=0 and date_format(a.CREATE_TIME,'%Y%m') = DATE_FORMAT(DATE_SUB(curdate(),interval 23 month),'%Y%m') then a.INTEGRAL else 0 end) ff0-- 当月发放
		,sum(case when a.RECORD_TYPE=1 then a.INTEGRAL else 0 end) xx-- 累计消耗
		from `member`.tt_member_flow_record a
		where a.is_deleted=0
		group by 1
	)x join `member`.tc_member_info m on m.id=x.MEMBER_ID 
	where m.MEMBER_V_NUM <> 0
	and m.is_deleted = 0
	and m.member_status <> 60341003 
	group by 1,2,3
	order by 6 desc 
)c
where c.is_vehicle = '0'
and c.过期V值>=1500
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'

-- 近60天将有小额过期积分， 12月1号即将过期V值总和小于1,500 V值的人，且当前V值余额小于等于50且大于1V值
select c.*
from 
	(
	select 
	x.member_id
	,m.REAL_NAME 姓名
	,m.MEMBER_PHONE 手机
	,m.MEMBER_V_NUM 余额
	,m.IS_VEHICLE 
	,if(cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)>m.MEMBER_V_NUM,
			m.MEMBER_V_NUM,
			cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)) 过期V值
	from 
		(
		select a.MEMBER_ID
		,sum(case when a.RECORD_TYPE=0 then a.INTEGRAL else 0 end) ff  -- 累计发放
		,sum(case when a.RECORD_TYPE=0 and date_format(a.CREATE_TIME,'%Y%m') = DATE_FORMAT(DATE_SUB(curdate(),interval 23 month),'%Y%m') then a.INTEGRAL else 0 end) ff0-- 当月发放
		,sum(case when a.RECORD_TYPE=1 then a.INTEGRAL else 0 end) xx-- 累计消耗
		from `member`.tt_member_flow_record a
		where a.is_deleted=0
		group by 1
	)x join `member`.tc_member_info m on m.id=x.MEMBER_ID 
	where m.MEMBER_V_NUM <> 0
	and m.is_deleted = 0
	and m.member_status <> 60341003 
	group by 1,2,3
	order by 6 desc 
)c
where c.过期V值<1500 and c.过期V值 <>0
and c.余额<=50 
and c.余额>=1
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'

-- 近60天将有小额过期积分， 12月1号即将过期V值总和小于1,500 V值的人，且当前V值余额大于50V值
select c.*
from 
	(
	select 
	x.member_id
	,m.REAL_NAME 姓名
	,m.MEMBER_PHONE 手机
	,m.MEMBER_V_NUM 余额
	,m.IS_VEHICLE 
	,if(cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)>m.MEMBER_V_NUM,
			m.MEMBER_V_NUM,
			cast(sum(case when x.ff-x.xx >= x.ff0 then x.ff0
			when x.ff-x.xx <=0 then 0
			else x.ff-x.xx end) as int)) 过期V值
	from 
		(
		select a.MEMBER_ID
		,sum(case when a.RECORD_TYPE=0 then a.INTEGRAL else 0 end) ff  -- 累计发放
		,sum(case when a.RECORD_TYPE=0 and date_format(a.CREATE_TIME,'%Y%m') = DATE_FORMAT(DATE_SUB(curdate(),interval 23 month),'%Y%m') then a.INTEGRAL else 0 end) ff0-- 当月发放
		,sum(case when a.RECORD_TYPE=1 then a.INTEGRAL else 0 end) xx-- 累计消耗
		from `member`.tt_member_flow_record a
		where a.is_deleted=0
		group by 1
	)x join `member`.tc_member_info m on m.id=x.MEMBER_ID 
	where m.MEMBER_V_NUM <> 0
	and m.is_deleted = 0
	and m.member_status <> 60341003 
-- 	and x.MEMBER_ID =4308006
	group by 1,2,3
	order by 6 desc 
)c
where c.过期V值<1500 and c.过期V值 <>0
and c.余额>50 
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'


第1个月预测值
截止T-24月累计发放V值 - 截止T月累计消耗V值 - 截止T月累计过期V值 得到的结果为预测过期V值
结果会做下列判断：
如果结果 >= T-24月当月发放V值，则过期V值为T-24月当月发放V值 （因为过期的V值不会大于发放的V值）
如果结果 <= 0，则过期V值为0 （因为过期V值不会小于0）

T月为当前月

第2个月预测值
截止T-23月累计发放V值 - 截止T月累计消耗V值 - （截止T月累计过期V值+第1个月预测过期V值） 得到的结果为预测过期V值
结果同样做以上判断

-- 累计消耗V值
			 SELECT member_id
					,SUM(CASE WHEN record_type = 1 THEN integral ELSE 0 END)        					AS tot_out	-- 累计消耗
			   FROM (SELECT *
							,ROW_NUMBER() OVER(PARTITION BY id ORDER BY a.CREATE_TIME DESC)  						AS rn 
					   FROM member.tt_member_flow_record a
					  WHERE is_deleted = 0
					)
			  WHERE event_type <> '60741032'	-- V值过期
				AND create_time < CURDATE() 
				AND rn = 1 
			  GROUP BY member_id


select f.ID,f.MEMBER_ID,m.MEMBER_PHONE,f.EVENT_DESC,f.RECORD_TYPE,f.INTEGRAL,f.CREATE_TIME
from member.tt_member_flow_record f 
join member.tc_member_info m on f.MEMBER_ID=m.ID
where m.MEMBER_PHONE ='13735447923'
order by 2,7