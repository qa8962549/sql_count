SELECT  a.OWNER_CODE,a.`RO_NO` ,
	     a.LABOUR_CODE '工时代码',
	     a.LABOUR_NAME '工时名称',
	     a.LABOUR_PRICE '工时单价',
	     a.LABOUR_AMOUNT '工时费'
from 	    tt_ro_labour a
where   a.IS_DELETED=0 and concat(a.OWNER_CODE,a.RO_NO) in (select count(vin) from `dms_manage`.tt_common_temp_data where `tmp2`  = '220901')