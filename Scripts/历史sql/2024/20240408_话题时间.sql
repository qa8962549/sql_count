-- 此刻发帖明细
select x.topic_name,
count(x.会员ID)
from 
	(
	select 
	distinct 
	a.member_id 会员ID,
	a.post_id ,
	bb.topic_id ,
	tt.topic_name ,
	row_number ()over(partition by a.member_id order by a.create_time) rk,
	a.create_time 发帖日期
	from community.tm_post a
	left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
	left join community.tm_topic tt on bb.topic_id =tt.topic_id 
	left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
	where a.is_deleted =0
	--and bb.topic_id is not null 
)x where x.rk=1

-- 此刻发帖 2023年总发帖人数（去重），2023年总发帖量
	select 
	tt.topic_name ,
	count(distinct a.member_id) "2023年总发帖人数（去重）",
	count(a.post_id) "2023年总发帖量"
	from community.tm_post a
	left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
	left join community.tm_topic tt on bb.topic_id =tt.topic_id 
	left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
	where a.is_deleted =0
	and a.create_time>='2023-01-01'
	and a.create_time<'2024-01-01'
--	and bb.topic_id is not null 
	and tt.topic_name in ('#让时间被看见#',
'#圣诞节趣玩____#',
'#窝窝镜头日记#',
'#沃的书单#',
'#ENJOY VOLVO LIFE#',
'#沃的用车笔记#',
'#别赶路 去感受路#',
'#一日车评人#',
'#冬日限定快乐#',
'#俱在一起WOW#',
'#用车小百科#',
'#小红花不怕晒#',
'#我的开箱惊喜#',
'#WO的小时光#',
'#525车主节 聚在一起#',
'#沃尔沃会员日#',
'#一起趣过年#',
'#新车主体验#',
'#WO的夏天，WO说了算#',
'#我家过节不一般#',
'#你问沃答#',
'#欢趣元宵节#',
'#WOW的美好新春#',
'#沃们的夏日之旅#',
'#EX90，沃的Tech心声#',
'#沃的舒适车生活#',
'#沃的第一篇此刻#',
'#WO是生活探索家#',
'#我的夏日畅想#',
'#每日签到，好运贵在坚持#',
'#独乐不如“粽”乐#',
'#初五迎财神#',
'#沃尔沃成长树计划#',
'#感恩生活的小确幸#',
'#我的100件环保小事#',
'#年度好物，我有推荐#',
'#沃讲堂#',
'#一张封神#',
'#兔年相荐，你沃同行#',
'#喜提新车#',
'#充电攻略#',
'#爱上夏天的100个理由#',
'#爱车春日大秀#',
'#我的艺术灵感#',
'#遇鉴沃尔沃EM90#',
'#WO的夏天 未完待续#',
'#生活的风景线，是_____#',
'#WO最爱的夏日度假#',
'#邂逅夏日心动时刻#',
'#前方高能 伙力全开#',
'#一荐倾心，你沃同行#',
'#Hej Volvo Life#',
'#WO设计了一夏#',
'#与爱心计划同行#',
'#我爱经典传统味#',
'#我的消暑清单#',
'#WO感恩有你#',
'#沃尔沃EM90全球首发｜共赴新境#',
'#北欧式生活的一天#',
'#从此刻到每一刻#',
'#沃尔沃AED道路使者联盟#',
'#沃的探店笔记#',
'#春节用车，我有话说#',
'#爱车装备 沃有体验#',
'#释放宝贝创造力#',
'# WO的夏天最OK#',
'#晒出沃的会员权益#',
'#沃的2022年度报告#',
'#沃的亲子时光#',
'#我家创造力小天才#',
'#今天国庆，带娃去_____#',
'#我与沃尔沃EM90的来电瞬间#',
'#看见「她」的光芒#',
'#心奇迹 新未来#',
'#沃的驾驶好习惯#',
'#种草夏日好物#',
'#合伙人福利社#',
'#沃尔沃EM90首发探秘体验官#',
'#一起来晒“沃”的低碳足迹#',
'#WO的「境」像人生#',
'#生活的好食光，是_____#',
'#心动情人节#',
'#我爱创新潮流味#',
'#车品问答#',
'#用车小百科投稿#',
'#把秋天装进照片里#',
'#生活的乌托邦，是_____#',
'#捣蛋鬼计划#',
'#沃们的第一个100天#',
'#沃的好物种草清单#',
'#沃的解暑妙招#',
'#今天你磕到了吗#',
'#花式show圣诞#',
'#母亲节快乐#',
'#一句话回到学生时代#',
'#沃是代言人#',
'#沃尔沃品牌充电站#',
'#爸爸的闪光时刻#',
'#童心不泯，我是天真的大孩子#',
'#向世界重新SAY Hej#',
'#养车问答#',
'#生活的向善力，是_____#',
'#城市俱乐部点亮中#',
'#沃的下一辆电车#',
'#EX90，你电到我了#',
'#打卡合伙人好店#',
'#525车主节 聚个idea#',
'#运动暴汗，我是酷爽户外派#',
'#选择电车的N个理由#',
'#仪表盘问答#',
'#WO是小小____家#',
'#生活的竞技场，是_____#',
'#看见守护的力量#',
'#当“沃”遇见高尔夫#',
'#心有所系，我是有爱的“新”家长#',
'#525“沃”有话说#',
'#弯道百科全书#',
'#空调西瓜，我是舒适宅家派#',
'#525相聚比“V” #',
'#春节长途用车问答#',
'#沃的公益之旅#',
'#沃尔沃EX90首批见证官#',
'#沃的夏日爱车装备#',
'#沃尔沃EM90海外圈粉#',
'#纯电试驾官#',
'#守护蓝星计划#',
'#525比“心”发射#',
'#沃要推荐合伙人#',
'#沃的公益闪光时刻#',
'#沃讲堂投稿#',
'#FUN肆聊球赛#',
'#亲子议题3000问#',
'#525车主达人秀#',
'#平淡是真，我是坚定务实派#',
'#怦然心动，我是浪漫制造家#',
'#原厂装备 沃有体验#',
'#附件加装问答#',
'#灯光问答#',
'#高温行车问答#',
'#志愿者课堂精彩瞬间#',
'品牌资讯',
'爱心计划',
'20分贝',
'合伙人福利社',
'大咖聊EX90',
'旅行家心选路线合集',
'车主故事',
'沃讲堂',
'玩转社区',
'ENJOY VOLVO LIFE',
'沃之美学',
'官方资讯',
'信息娱乐',
'方向盘',
'充电专区',
'好物研究所-有点东西',
'车主品牌大使',
'充电补能',
'灯光',
'拍出封神大片',
'二手车研习社')
	
-- 此刻发帖 2023年总发帖人数（去重）
	select 
	count(distinct a.member_id) "2023年总发帖人数（去重）"
	from community.tm_post a
	left join community.tr_topic_post_link bb on a.post_id =bb.post_id 
	left join community.tm_topic tt on bb.topic_id =tt.topic_id 
	left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
	where a.is_deleted =0
	and a.create_time>='2023-01-01'
	and a.create_time<'2024-01-01'
--	and bb.topic_id is not null 
and tt.topic_name in ()