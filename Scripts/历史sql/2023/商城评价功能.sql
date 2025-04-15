-- 1、评价功能整体使用率
select 
round(count(x.id)/count(a.id),4)
from 
(SELECT a.id
from goods.tm_comment a
where a.is_deleted =0
and a.create_time <'2023-01-01'
order by 1)a
left join 
(
SELECT a.id
from goods.tm_comment a
left join goods.tt_comment_picture b on a.id =b.comment_id 
where a.is_deleted =0
and a.create_time <'2023-01-01'
and a.content <>''
order by 1
union 
SELECT a.id
from goods.tm_comment a
left join goods.tt_comment_picture b on a.id =b.comment_id 
where a.is_deleted =0
and a.create_time <'2023-01-01'
and b.picture_url is not null 
order by 1
)x on a.id=x.id

-- 2、各星级评价比例
SELECT 
DATE_FORMAT(a.create_time,'%Y-%m'),
count(case when a.star=1 then 1 end) 1星,
count(case when a.star=2 then 1 end) 2星,
count(case when a.star=3 then 1 end) 3星,
count(case when a.star=4 then 1 end) 4星,
count(case when a.star=5 then 1 end) 5星
from goods.tm_comment a
where a.is_deleted =0
and a.create_time <'2023-01-01'
and a.create_time >='2022-09-01'
group by 1
order by 1

-- 商品评价明细评价类型，30031001-普通评价，30031002-评价追评，30031003-评价回复
select a.create_time 评价时间
,case when a.comment_type='30031001' then '普通评价'
when a.comment_type='30031002' then '评价追评' 
when a.comment_type='30031003' then '评价回复' 
end 评价渠道
-- ,a.comment_type 评价类型
-- ,a.spu_id 
,m.REAL_NAME 用户昵称
,m.ID 
,m.MEMBER_PHONE 手机号
,a.object_type 业务类型
,case when a.channel_source='31211001' then 'APP'
when a.channel_source='31211002' then '小程序' end 评价渠道
,s.name 评价商品
,a.sku_num 商品数量
,a.order_code 订单号
,a.star 主维度评分
,''评价标题
,a.content 评价内容
from goods.tm_comment a
left join `member`.tc_member_info m on a.member_id =m.id and m.IS_DELETED =0 and m.STATUS <>'60341003'
left join goods.item_spu s on s.id =a.spu_id 
where a.is_deleted =0
and a.create_time <'2023-06-01'
and a.create_time >='2023-05-01'


select a.MEMBER_PHONE,
a.ID memberid,
a.CUST_ID 
from `member`.tc_member_info a
where a.MEMBER_STATUS <> 60341003 and a.IS_DELETED = 0
and left(a.MEMBER_PHONE,1)='1' and LENGTH(a.MEMBER_PHONE)=11
