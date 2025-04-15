
-- 我要卖车 button
select 
distinct memberid 
from dwd_23.dwd_23_gio_tracking 
where event ='Button_click'
--and page_title ='购车'
and btn_name ='我要卖车'
and event_time >=today() - INTERVAL 3 MONTH
and toDate(date) >=today() - INTERVAL 3 MONTH
and toDate(date) <today()
and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
and LENGTH(distinct_id)<9
--and memberid is not null 

SELECT distinct x.memberid
from 
(
--内容数据
	select 
	distinct 
	p.member_id::String memberid
	from ods_cmnt.ods_cmnt_tm_post_cur p 
	left join
		(-- 发帖内容、图片
			select
				t.post_id,
				REPLACE(replaceRegexpAll(replaceRegexpAll(arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'text' THEN t.`内容` ELSE NULL END), ';'), '<.*?>', ''),'#(.*?)#', ''),' ','') `发帖内容`,
				lengthUTF8(REPLACE(replaceRegexpAll(replaceRegexpAll(arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'text' THEN t.`内容` ELSE NULL END), ';'), '<.*?>', ''),'#(.*?)#', ''),' ','')) `发帖字数`,
				arrayStringConcat(groupArray(CASE WHEN t.`类型` = 'image' THEN t.`内容` ELSE NULL END), ';') AS `发帖图片链接`,
				count(case when t.`类型`='image' then t.`内容` else null end) as `发帖图片数量`
			from(
				select 
					tpm.post_id
					,tpm.create_time
					,visitParamExtractString(tpm.node_content, 'nodeType') `类型`
					,visitParamExtractString(tpm.node_content, 'nodeContent') `内容`
				from (
				select
					tpm.post_id
					,tpm.create_time
					,arrayJoin(splitByString('},{',cast(tpm.node_content as String)) ) as node_content
				from ods_cmnt.ods_cmnt_tt_post_material_cur tpm
				where 1=1
--				and tpm.create_time between '2024-07-19 15:00:00' and '2024-07-28 23:59:59'
				and tpm.is_deleted = 0) tpm 
			) as t
			group by t.post_id
		) pm on p.post_id = pm.post_id
	where 1=1
	and toDate(p.create_time) >=today() - INTERVAL 3 MONTH
	and toDate(p.create_time)<today()
	and (pm.`发帖内容` like '%外地旅游%' or pm.`发帖内容` like '%租车%')
	and p.is_deleted =0
union all 
-- 评论
	select distinct member_id::String 
	from ods_cmnt.ods_cmnt_tm_comment_cur a
	where a.is_deleted <>1
	and toDate(a.create_time) >=today() - INTERVAL 3 MONTH
	and toDate(a.create_time) <today()
	and (comment_content like '%外地旅游%' or comment_content like '%租车%')
)x


