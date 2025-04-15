select r.EVENT_TYPE 事件代码,r.EVENT_DESC V值事件,min(r.INTEGRAL) 发放最小额度,MAX(r.INTEGRAL) 发放最大额度,GROUP_CONCAT(DISTINCT r.INTEGRAL) 历史发放额度值,count(1) 累计发放次数,sum(r.INTEGRAL) 累计发放V值数,min(r.CREATE_TIME) 最早发放时间,max(r.CREATE_TIME) 最晚发放时间
from member.tt_member_flow_record r
where r.RECORD_TYPE=0
and r.create_time >='2020-01-01'
and r.IS_DELETED=0
GROUP BY 1,2 order by 4 desc ;