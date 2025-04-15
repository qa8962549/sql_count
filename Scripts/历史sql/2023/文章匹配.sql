-- 1、文章快速匹配

="'"&A1&"',"


-- 2、匹配文章前面的属性
-- 注意：品牌资讯（品牌新闻、品牌视频）、热门探索、车主故事
select c.page_id
,c.title 标题
,d2.code_cn_desc 所在板块
,d.code_cn_desc 子版块
,c.real_module_code
,case c.state 
 when 'DRAFT' then '草稿'
 when 'WAIT_PUBLISH' then '待上架'
 when 'PUBLISH' then '已上架'
 when 'INVALID' then '已下架' else c.state end 内容状态
,d3.code_cn_desc 审批状态
,c.product_date 生产时间
,c.publish_date 上架时间
,c.serial_number 排序
from `cms-center`.cms_content c 
left join dictionary.tc_code d on c.category_code=d.code_id
left join dictionary.tc_code d2 on c.module_code=d2.code_id
left join dictionary.tc_code d3 on c.audit_state=d3.code_id
where c.deleted=0  
and (c.share_title<>'嗯嗯嗯' or c.share_title is null )
-- and d2.code_cn_desc='车主故事'--  and d.code_cn_desc='品牌新闻'
and c.title in
(
'沃尔沃心选路线丨山水青城',
'沃世界「特邀发言官」惊喜上线，玩转专区惊喜有你！',
'沃尔沃心选路线丨佛国胜境',
'沃讲堂｜关于出行buff，还得看“沃”',
'全新纯电C40｜给生活来点“黑科技”？',
'XC60焕新上场，展全域实力',
'沃尔沃XC90 & S90直播季，福利开局！',
'沃尔沃新款S60极夜黑限量版，焕黑登场！',
'【一起露营吧！】与沃一路 繁花似锦',
'新款XC60丨全能担当，尽情出发',
'现实和理想，情怀和真爱。#525车主节',
'#525车主节#瓦罐车——露营的最佳搭档',
'今天，聊一个「敏感」话题',
'坚持17年建筑工程，归来时写就精彩人生',
'沃尔沃心选路线丨山水青城',
'沃尔沃全新纯电C40｜《论高段位选手的天秀实力》',
'《欧洲杯熬夜指南》',
'一起挑战 飞驰人生',
'「运动模式」一键出发',
'探索美好 永不止步',
'赛道基因 放胆炫技',
'寻找勐巴拉娜西'
)
order by 8 desc
