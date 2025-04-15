



	select a.*,b.评论数
	from (SELECT tc.comment_id  id,
			tc.create_by 社区会员id,
			tmi.MEMBER_NAME 社区昵称,
			tmi.REAL_NAME 用户姓名,
			tmi.MEMBER_PHONE 手机号码,
			tc.comment_content 评论内容,
			tc.create_time 评论日期,
			tc.images 上传图片,
			case when tc.parent_id='0' then 1
			else  2 end '层级',
			tc.like_count 点赞数
	FROM community.tm_comment tc 
	left join `member`.tc_member_info tmi on tmi.id = tc.member_id 
	where tc.post_id in ('p24GW4GS7X')
-- 	and parent_id ='0'
	and tc.create_time BETWEEN '2023-01-27' and '2023-01-30 23:59:59'
	ORDER by tc.create_time ) a 
	left join (SELECT tc.parent_id ,
		count(*) 评论数
	FROM community.tm_comment tc 
	left join `member`.tc_member_info tmi on tmi.id = tc.member_id 
	where tc.post_id in ('p24GW4GS7X')
	and parent_id <>'0'
	and tc.create_time BETWEEN '2023-01-27' and '2023-01-30 23:59:59'
	group by 1) b on a.id = b.parent_id
	order by a.点赞数 desc