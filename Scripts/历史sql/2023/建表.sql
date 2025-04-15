DROP TABLE ods_oper_crm.ods_oper_crm_baoke_l_si

-- 创建本地表  
CREATE TABLE if not exists ods_oper_crm.ods_oper_crm_baoke_l_si on cluster default_cluster
(
    `id` String,
    `scene` String,
    `phone` Int32,
    `created_time` timestamp
)
ENGINE = ReplicatedMergeTree
ORDER BY id  -- 根据主键排序
SETTINGS index_granularity = 8192;

-- 创建分布式表
CREATE TABLE if not exists ods_oper_crm.ods_oper_crm_baoke_d_si on cluster default_cluster
(
    `id` String,
    `scene` String,
    `phone` Int32,
    `created_time` timestamp
)
ENGINE = Distributed('default_cluster', 'ods_oper_crm', 'ods_oper_crm_baoke_l_si', rand());
-- 括号内参数依次为：cluster集群名（表示服务器集群配置），数据库名，本地表名，在读写时会根据rand()随机函数的取值来决定数据写⼊哪个分⽚(分片key)