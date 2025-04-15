select a.company_short_name_cn 经销商简称,
a.company_name_cn 经销商全称,
a.company_code code,
a.id,
a.valid_status ,
a.status ,
b.code_cn_desc,
b1.code_cn_desc 
from organization.tm_company a
left join dictionary.tc_code b on a.status =b.code_id 
left join dictionary.tc_code b1 on a.company_type =b1.code_id 
where a.company_short_name_cn in 
	(select x.company_short_name_cn
	from (
		select a.company_short_name_cn ,
		count(1) tt
		from organization.tm_company a
		where a.is_deleted =0
		group by 1
		order by 2 desc )x 
	where x.tt>=2)
and a.company_type ='15061003'
and a.STATUS in ('16031002','16031005')
order by 1