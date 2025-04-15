-- button
select case when json_extract(t.`data`,'$.path') = '/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Flovecar-package%2Fappointment%2Fappointment%3Fchid%3DX7P7VN93XC%26chcode%3DIBDMMAYV60YYSJIA2022VCCN%26chtype%3D1%26seriesCode%3D225' 
then '01'
	when json_extract(t.`data`,'$.path') = '/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Flovecar-package%2Fappointment%2Fappointment%3Fchid%3D8RTHAFQ0RD%26chcode%3DIBDMMAYXC9ZSMFBY2022VCCN%26chtype%3D1%26seriesCode%3D256' 
then '02'
	when json_extract(t.`data`,'$.path') = '/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Flovecar-package%2Fappointment%2Fappointment%3Fchid%3D3K103S3DA4%26chcode%3DIBDMMAYXC6ZSMFBY2022VCCN%26chtype%3D1%26seriesCode%3D246' 
then '03'
else null end 分类,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-04-1'
group by 1
order by 1