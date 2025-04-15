根据批次号查询模板消息推送情况：
1、批次号业务提供；

2、打开跳板机，选择 ecs-world-ecs2-prod-sha10.36.62.6 这个机器，使用自己的账号密码登录；

3、连接SQL Server数据库；

数据库地址：rm-uf647s1ruq111186t.sqlserver.rds.aliyuncs.com
端口：1433
Database：WedoManagementDb
用户ID：vwadmin
密码：8v9MMT5094tiXRDB

4、查询SQL
字段：LotId 批次号，SendState 发送状态，0未发送，1成功，2失败。


select top 1000 * from [dbo].[WeChatTemplateMessageUsers] where LotId='L-20211122144615230-4' and SendState=1 order by id desc   -----成功

select top 1000 * from [dbo].[WeChatTemplateMessageUsers] where  LotId='L-20211122144615230-4' and  SendState=2 order by id desc  ----失败

select top 1000 * from [dbo].[WeChatTemplateMessageUsers] where LotId='L-20211109172907716-4'and  SendState=0 order by id desc    ---未发送


