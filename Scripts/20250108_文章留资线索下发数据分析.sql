--	litecrm关联NB
select 
distinct 
a.id,
tso.phone_num,
if(x.media_id is not null ,'是','否') `是否下发NB`,
if(tso.phone_num is not null ,'是','否') `是否有订单`,
tso.`市场活动名称（归属渠道）`,
dateDiff('day',a2.last_create_time, a.create_time) `距离上次留资间隔天数`
from (
-- litcrm
	select 
	distinct id id,
		customer_mobile,
		create_time
	  from ods_vced.ods_vced_tm_leads_collection_pool_d tlcp 
	  where delete_flag='0'
	  and create_time>='2024-01-01'
	  )a
left join (
-- litcrm 上一次留资时间
	select 
	distinct a.id id,
		a.customer_mobile,
		a.create_time,
		max(a1.create_time) last_create_time
	  from ods_vced.ods_vced_tm_leads_collection_pool_d a 
	  left join ods_vced.ods_vced_tm_leads_collection_pool_d a1 on a.customer_mobile=a1.customer_mobile
	  where delete_flag='0'
	  and create_time>='2024-01-01'
	  and a.customer_mobile is not null 
	  and a1.create_time<a.create_time
	  and a.id='166020139761877154'
	  group by 1,2,3
	  )a2 on a2.customer_mobile=a.customer_mobile and a2.create_time=a.create_time
left join 
	(
	-- NB
		select 
		distinct 
		media_id media_id
		from ods_cust.ods_cust_tt_clue_clean_cur tcc
		where 1=1
		and media_id is not null 
		and is_deleted=0
	)x on x.media_id=a.id
left join 
	(
	select phone_num,
	 groupArray(`市场活动名称（归属渠道）`)`市场活动名称（归属渠道）`
	from 
	(
	-- 180天内订单
		select 
		DISTINCT 
		tso.phone_num phone_num,
		tso.`市场活动名称（归属渠道）` `市场活动名称（归属渠道）`
		from (
		--litecrm 
		select id,
				customer_mobile,
				create_time
			  from ods_vced.ods_vced_tm_leads_collection_pool_d tlcp 
			  where delete_flag='0'
			  and create_time>='2024-01-01'
			  and customer_mobile='18932444331'
			  )a
		left join 
			(
			-- NB
				select 
				distinct 
				media_id media_id
				from ods_cust.ods_cust_tt_clue_clean_cur tcc
				where 1=1
				and media_id is not null 
				and is_deleted=0
			)x on x.media_id=a.id
		left join 
			(
		--	是否有订单 市场活动名称（归属渠道）
			select
			distinct tso.phone_num phone_num,
			tso.created_at created_at,
--			tso.customer_business_id customer_business_id,
--			ROW_NUMBER ()over(PARTITION by tso.phone_num order by created_at )rk,
			cms_active.active_name`市场活动名称（归属渠道）`
			from
			(
				select
				o.customer_tel phone_num,
				o.created_at,
				so_status,
				is_deleted,
				customer_business_id
				from  ods_cydr.ods_cydr_tt_sales_orders_cur o 
				UNION ALL  
				select
				o.drawer_tel phone_num,
				o.created_at,
				so_status,
				is_deleted,
				customer_business_id
				from ods_cydr.ods_cydr_tt_sales_orders_cur o 
				UNION ALL  
				select
				o.purchase_phone phone_num,
				o.created_at,
				so_status,
				is_deleted,
				customer_business_id
				from ods_cydr.ods_cydr_tt_sales_orders_cur o 
			) tso
			left join ods_cubu.ods_cubu_tt_customer_business_cur tcb on tso.customer_business_id=tcb.customer_business_id
			left join ods_actv.ods_actv_cms_active_d cms_active on cms_active.uid = tcb.market_activity
			where length(phone_num) = '11'
			and left(phone_num,1) = '1'
			and phone_num='18932444331'
			and tso.so_status in (14041002,14041003,14041008,14041001)
			and tso.is_deleted = 0 
			)tso on a.customer_mobile = tso.phone_num 
			where toDateTime(tso.created_at)<toDateTime(a.create_time) + INTERVAL 180 DAY
			and toDateTime(tso.created_at)>=toDateTime(a.create_time)
		)x group by 1 
	)tso on a.customer_mobile = tso.phone_num 