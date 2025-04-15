

# 用户数据

-- 公众号车主关注取关
select a.time '日期',a.g '关注数',b.q '取关数'
from (
select DATE(o.create_time) time,count(1) g
from volvo_wechat_live.es_car_owners o
where IFNULL(o.create_time,o.subscribe_time) BETWEEN DATE_SUB(CURDATE(),INTERVAL 31 DAY) and CURDATE()
and o.subscribe_status=1
and o.unionid is not null and o.unionid<>''
and o.unionid in (
-- 全量车主unionid
	select DISTINCT a.allunionid unionid
	from (
	select -- IFNULL(c.union_id,u.unionid) unionid
	m.id,m.old_memberid,u.id,m.create_time,c.union_id,u.unionid,IFNULL(c.union_id,u.unionid) allunionid
	from  member.tc_member_info m 
	left join customer.tm_customer_info c on c.id=m.cust_id
	left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid
	where m.member_status<>60341003 and m.is_deleted=0 
	and m.is_vehicle=1 
	and m.create_time<=CURDATE() 
	order by c.union_id 
	) a
	where a.allunionid is not null and a.allunionid<>''
)GROUP BY 1 order by 1
)a
LEFT JOIN (
	select DATE(unsubscribe_time) time,count(1) q
	from volvo_wechat_live.es_car_owners o 
	where o.unsubscribe_time BETWEEN DATE_SUB(CURDATE(),INTERVAL 31 DAY) and CURDATE()
	and o.subscribe_status=0
	and o.unionid is not null and o.unionid<>''
	and o.unionid in (
	-- 全量车主unionid
		select DISTINCT a.allunionid unionid
		from (
		select -- IFNULL(c.union_id,u.unionid) unionid
		m.id,m.old_memberid,u.id,m.create_time,c.union_id,u.unionid,IFNULL(c.union_id,u.unionid) allunionid
		from  member.tc_member_info m 
		left join customer.tm_customer_info c on c.id=m.cust_id
		left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid
		where m.member_status<>60341003 and m.is_deleted=0 
		and m.is_vehicle=1 
		and m.create_time<=CURDATE() 
		order by c.union_id 
		) a
		where a.allunionid is not null and a.allunionid<>''
	)GROUP BY 1 order by 1
)b on a.time=b.time
order by 1 ;


# 各渠道引流

-- 其他渠道引流

select '本月' 类别
,count(m.is_vehicle) 留存总计
,count(case when m.is_vehicle=1 then m.id else null end ) 留存车主
,count(case when m.is_vehicle=0 then m.id else null end ) 留存粉丝
from member.tc_member_info m 
where m.is_deleted=0 and m.member_status<>60341003
-- and m.create_time between DATE_SUB(CURDATE(),INTERVAL 7 day) and CURDATE()
and m.create_time between '2022-10-01' and '2022-10-31 23:59:59'


select '累计' 类别
,count(m.is_vehicle) 留存总计
,count(case when m.is_vehicle=1 then m.id else null end ) 留存车主
,count(case when m.is_vehicle=0 then m.id else null end ) 留存粉丝
from member.tc_member_info m 
where m.is_deleted=0 and m.member_status<>60341003
and m.create_time between '2020-01-01' and '2022-10-31 23:59:59'
-- and m.create_time between '2020-01-01' and CURDATE()

-- 好友邀请
select '好友邀请累计' 类别
,count(m.is_vehicle) 留存总计
,count(case when m.is_vehicle=1 then m.id else null end ) 留存车主
,count(case when m.is_vehicle=0 then m.id else null end ) 留存粉丝
from volvo_cms.vehicle_drive_invite i 
left join member.tc_member_info m on i.relative_member_id=m.id 
where i.type=1 and i.deleted=0
and i.register_date BETWEEN '2020-01-01' and '2022-10-31 23:59:59'
-- and i.register_date BETWEEN '2020-01-01' and CURDATE()
and m.is_deleted=0 and m.member_status<>60341003;


-- 本周渠道引流
select a.qr_code_id
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 then a.unionid else null end  ) 留存总计
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 and a.vehicle=1 then a.unionid else null end  ) 留存车主
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 and a.vehicle=0 then a.unionid else null end  ) 留存粉丝
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=0 then a.unionid else null end  ) 取关总计
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=0 and a.vehicle=1 then a.unionid else null end  ) 取关车主
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=0 and a.vehicle=0 then a.unionid else null end  ) 取关粉丝
,count(DISTINCT case when a.eventtype='subscribe' then a.unionid else null end  ) 新增总计
-- ,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 then a.unionid else null end  )+count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=0 then a.unionid else null end  )
,count(DISTINCT case when a.eventtype='subscribe' and a.vehicle=1 then a.unionid else null end  ) 新增车主
,count(DISTINCT case when a.eventtype='subscribe' and a.vehicle=0 then a.unionid else null end  ) 新增粉丝
,count(DISTINCT case when a.eventtype='scan' then a.unionid else null end ) 已关注扫码
,concat( cast(round(count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 then a.unionid else null end  )/count(DISTINCT case when a.eventtype='subscribe' then a.unionid else null end),3)*100 as varchar),'%') 留存率
,round(sum( case when a.eventtype='subscribe' then a.gtime else null end )/count(DISTINCT case when a.eventtype='subscribe' then a.unionid else null end  ),2) 平均留存时长
from (
	select 
	q.qr_code_id
	,q.open_id 微信openid
	,q.eventtype
	,o.unionid
	,o.status
	,o.subscribe_status 关注状态
	,q.create_time 扫码时间
	,o.create_time 关注时间
	,o.unsubscribe_time 取关时间
	,c.cid
	,m.mID
	,IFNULL(m.IS_VEHICLE,0) vehicle
	,TIMESTAMPDIFF(DAY,q.create_time,if(o.subscribe_status=1,CURDATE(),o.unsubscribe_time)) gtime
	from volvo_wechat_live.es_qr_code_logs q
	left join volvo_wechat_live.es_car_owners o on q.open_id=o.open_id
	left join (select c.union_id,max(c.id) cid from customer.tm_customer_info c where c.is_deleted=0 GROUP BY 1) c on c.union_id=o.unionid
	left join (
						select a.*,m.is_vehicle
						from (select m.cust_id,max(m.id) mid from member.tc_member_info m where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003 GROUP BY 1 ) a
						LEFT JOIN member.tc_member_info m on a.mid=m.id
						) m on c.cid=m.CUST_ID 
-- 	where q.create_time BETWEEN '2022-10-01' and '2022-10-31 23:59:59'
	where q.create_time BETWEEN DATE_SUB(CURDATE(),INTERVAL 31 DAY) and CURDATE()
	and o.unionid is not null and o.unionid<>''
	and q.qr_code_id in (
	392,488,587,683,783,892,981,1072,
	393,489,588,684,784,893,982,1074,
	394,490,589,685,785,895,984,1075,
	395,491,590,686,786,896,985,1076,
	398,492,591,688,787,897,983,1077,1464,
	399,493,592,689,788,898,988,1078,1465,
	400,494,594,690,789,899,989,1080,1466,
	401,495,593,692,790,900,990,1081,1467,
	402,496,595,693,791,903,991,1082,1468,
	403,497,596,694,792,901,992,1083,1469,
	404,500,597,695,793,902,993,1085,1470,
	405,501,598,696,794,904,994,1090,1471,
	406,504,599,697,795,905,995,1392,1472,
	407,505,600,698,796,906,998,1393,1474,
	408,507,601,700,797,907,996,1395,1475,
	414,508,602,701,798,908,999,1397,1476,
	415,509,603,702,812,909,1001,1398,1477,
	416,510,604,703,800,910,1002,1399,1478,
	417,511,605,705,801,911,1003,1401,1479,
	418,512,606,706,802,912,1000,1402,1489,
	419,513,647,707,803,913,1004,1403,1490,
	420,514,621,709,804,915,1005,1404,1491,
	421,515,622,710,805,916,1006,1405,1492,
	422,516,623,712,806,917,1007,1406,1500,
	423,517,629,713,807,918,1008,1408,1502,
	424,518,630,714,810,919,1009,1409,1503,
	425,519,631,715,814,920,1010,1410,1508,
	426,520,648,716,815,921,1011,1411,1509,
	427,521,649,717,817,922,1012,1412,1510,
	428,522,633,718,818,923,1014,1413,1511,
	429,523,659,719,819,924,1015,1414,1512,
	430,525,632,720,820,925,1016,1415,1513,
	431,526,650,721,822,926,1017,1416,1514,
	432,527,651,722,823,927,1018,1417,1515,
	433,528,652,723,824,928,1019,1418,1802,
	435,529,653,724,825,929,1020,1419,1804,
	436,530,608,725,826,936,1021,1420,1805,
	437,531,609,726,827,931,1022,1421,1806,
	438,532,612,728,828,932,1025,1422,1807,
	439,533,614,729,830,933,1026,1423,1808,
	440,534,615,730,831,934,1027,1424,1809,
	443,535,616,734,832,937,1028,1425,1810,
	445,536,617,735,835,939,1029,1426,1811,
	446,537,618,736,834,940,1030,1427,1812,
	447,538,619,737,837,941,1031,1428,1813,
	448,541,620,738,838,942,1032,1429,1814,
	449,542,628,739,839,943,1034,1430,1816,
	450,543,627,740,840,944,1035,1431,1817,
	451,546,626,741,841,945,1037,1432,1818,
	452,547,634,742,842,946,1036,1433,1819,
	453,550,635,743,843,947,1038,1434,1820,
	454,551,636,744,845,948,1042,1435,1822,
	455,552,637,745,846,949,1045,1436,1823,
	456,554,638,746,847,950,1044,1437,1824,
	457,556,639,747,848,951,1043,1438,1825,
	460,557,640,749,849,952,1046,1439,1826,
	461,558,642,750,851,953,1047,1440,1828,
	462,559,646,751,852,954,1048,1441,1829,
	463,560,654,752,853,955,1049,1442,1830,
	464,561,656,753,854,956,1050,1443,1831,
	466,562,655,754,874,959,1051,1444,1832,
	467,563,657,755,875,960,1052,1445,1833,
	468,565,660,756,862,961,1054,1446,1835,
	469,566,662,757,865,962,1055,1447,1838,
	470,567,663,758,876,963,1056,1448,1839,
	471,573,665,760,877,964,1057,1449,1840,
	472,574,666,763,878,965,1058,1450,1842,
	473,577,667,765,879,967,1059,1451,1843,
	474,572,668,766,880,968,1060,1452,1844,
	475,568,669,764,881,969,1061,1453,1845,
	476,569,670,773,882,970,1062,1454,1846,
	477,570,671,774,883,971,1063,1455,1850,
	478,571,672,775,884,972,1064,1456,1851,
	480,578,673,776,885,973,1065,1457,1852,
	481,579,675,777,886,974,1066,1458,1853,
	482,581,676,778,887,975,1067,1459,1854,
	483,582,677,779,888,976,1068,1460,1855,
	484,583,678,813,889,977,1069,1461,1856,
	485,584,679,781,890,978,1070,1462,1857,
	486,586,680,782,891,980,1071,1463,1858,
  1859,1860,1861,1862,1863,1864,1865,1868,
	1869,1870,1871,1872,1873,1874,1875,1876,1879,
	1880,1881,1882,1883,1884,1885,1886,1887,
	1888,1889,1890,1891,1892,1893,1894,1895,1896,
	1897,1898,1900,1902,1903,1904,1905,1906,1907,1908,1909,
	1910,1911,1912,1914,1917,1918,1919,1920,1922,1923,1924,1925,
	1926,1927,1928,1929,1930,1931,1932,1933,1934,
	1935,1936,1937,1938,1939,1940,1941,1942,1943,
	1971,1972,1973,1974,1975,1976,1977,1979,1980,1981,1982,1983,1984,
	1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,
	1999,2000,2001,2002,2003,2004,2005,2006,
2007,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,
2019,2020,2021,2022,2023,2024,2025,2026,2027,2028,2029,2030,2031,
2032,2033,2034,2035,2036,2038,2040,2042,2043,2044,2045,
2046,2048,2049,2050,2051,2052,2053,2054,2055,2056,2057,2059,2060,
2060,2061,2062,2063,2064,2065,2066,2067,2068,2069,
2070,2072,2073,2074,2075,2076,2077,
2078,2079,2080,2081,2082,2083,2084,2085,2089,2090,
2095,2098,2099,2100,2101,2102,2103,
2106,2107,2108,2109,2110,2112,2113,2114,
2115,2116,2117,2118,2119,2120,
2123,2124,2126,2128,2129,2130,2131,
2132,2135,2136,2137,2138,2139,2146,2148,2149,2150,2151,2152,2153,2154,2156,2157,2158,2159,2160,2161,2162,2163,
2165,
2168,2167,2169,2170,2175,
2176,2177,2178,2179,2180,2181,2182,2183,2184,2185,2186,2187,2188,2189,2190,2191,2192,2193,2194,2195,
2196,2197,2198,2199,2200,2201,2202,2203,
2204,2205,2206,2207,2208,2209,2210,2211,2212,2213,2214,2215,
2217,2218,2219,2220,2221,2222,2223,2224,2225,2226,2227,2228,2229,
2230,2231,2232,2233,2234,2235,
2236,2237,2238,2239,2240,2241,
2243,2244,2245,2246,2247,2248,2249,2250,
2253,2254,2256,2257,2258,2259,2260,2261,2263,2264,2265,
2266,2267,2268,2269,2270,2271,2272,2273,2274,2275,2276,2279,2280,2281,2282,2283,2284,2285,2286,2287,2289,2290,2291,2292,2293,2294,2295,2296,2297,2298,2299,
2300,2301,2302,
2303,2304,2305,2306,2307,2308,2309,
2310,2311,2312,2313,2314,2315,2316,2317,2319,2320,2321,2322,2323,2324,2325,2326,2327,2328,
2329,2330,2331,2333,2334,2335,2336,2337,2338,2339,2341,2343,2344,2345,2347,2348,2349,2350,2351,2352
)
)a 
GROUP BY 1 order by 8 DESC;

--  历史渠道引流(2020-01-01)
select a.qr_code_id
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 then a.unionid else null end  ) 留存总计
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 and a.vehicle=1 then a.unionid else null end  ) 留存车主
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 and a.vehicle=0 then a.unionid else null end  ) 留存粉丝
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=0 then a.unionid else null end  ) 取关总计
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=0 and a.vehicle=1 then a.unionid else null end  ) 取关车主
,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=0 and a.vehicle=0 then a.unionid else null end  ) 取关粉丝
,count(DISTINCT case when a.eventtype='subscribe' then a.unionid else null end  ) 新增总计
-- ,count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 then a.unionid else null end  )+count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=0 then a.unionid else null end  )
,count(DISTINCT case when a.eventtype='subscribe' and a.vehicle=1 then a.unionid else null end  ) 新增车主
,count(DISTINCT case when a.eventtype='subscribe' and a.vehicle=0 then a.unionid else null end  ) 新增粉丝
,count(DISTINCT case when a.eventtype='scan' then a.unionid else null end ) 已关注扫码
,concat( cast(round(count(DISTINCT case when a.eventtype='subscribe' and a.`关注状态`=1 then a.unionid else null end  )/count(DISTINCT case when a.eventtype='subscribe' then a.unionid else null end),3)*100 as varchar),'%') 留存率
,round(sum( case when a.eventtype='subscribe' then a.gtime else null end )/count(DISTINCT case when a.eventtype='subscribe' then a.unionid else null end  ),2) 平均留存时长
from (
	select 
	q.qr_code_id
	,q.open_id 微信openid
	,q.eventtype
	,o.unionid
	,o.status
	,o.subscribe_status 关注状态
	,q.create_time 扫码时间
	,o.create_time 关注时间
	,o.unsubscribe_time 取关时间
	,c.cid
	,m.mID
	,IFNULL(m.IS_VEHICLE,0) vehicle
	,TIMESTAMPDIFF(DAY,q.create_time,if(o.subscribe_status=1,CURDATE(),o.unsubscribe_time)) gtime
	from volvo_wechat_live.es_qr_code_logs q
	left join volvo_wechat_live.es_car_owners o on q.open_id=o.open_id
	left join (select c.union_id,max(c.id) cid from customer.tm_customer_info c where c.is_deleted=0 GROUP BY 1) c on c.union_id=o.unionid
	left join (
						select a.*,m.is_vehicle
						from (select m.cust_id,max(m.id) mid from member.tc_member_info m where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003 GROUP BY 1 ) a
						LEFT JOIN member.tc_member_info m on a.mid=m.id
						) m on c.cid=m.CUST_ID 
	where q.create_time BETWEEN '2020-01-01' and '2022-10-31 23:59:59'
	and o.unionid is not null and o.unionid<>''
	and q.qr_code_id in (
	392,488,587,683,783,892,981,1072,
	393,489,588,684,784,893,982,1074,
	394,490,589,685,785,895,984,1075,
	395,491,590,686,786,896,985,1076,
	398,492,591,688,787,897,983,1077,1464,
	399,493,592,689,788,898,988,1078,1465,
	400,494,594,690,789,899,989,1080,1466,
	401,495,593,692,790,900,990,1081,1467,
	402,496,595,693,791,903,991,1082,1468,
	403,497,596,694,792,901,992,1083,1469,
	404,500,597,695,793,902,993,1085,1470,
	405,501,598,696,794,904,994,1090,1471,
	406,504,599,697,795,905,995,1392,1472,
	407,505,600,698,796,906,998,1393,1474,
	408,507,601,700,797,907,996,1395,1475,
	414,508,602,701,798,908,999,1397,1476,
	415,509,603,702,812,909,1001,1398,1477,
	416,510,604,703,800,910,1002,1399,1478,
	417,511,605,705,801,911,1003,1401,1479,
	418,512,606,706,802,912,1000,1402,1489,
	419,513,647,707,803,913,1004,1403,1490,
	420,514,621,709,804,915,1005,1404,1491,
	421,515,622,710,805,916,1006,1405,1492,
	422,516,623,712,806,917,1007,1406,1500,
	423,517,629,713,807,918,1008,1408,1502,
	424,518,630,714,810,919,1009,1409,1503,
	425,519,631,715,814,920,1010,1410,1508,
	426,520,648,716,815,921,1011,1411,1509,
	427,521,649,717,817,922,1012,1412,1510,
	428,522,633,718,818,923,1014,1413,1511,
	429,523,659,719,819,924,1015,1414,1512,
	430,525,632,720,820,925,1016,1415,1513,
	431,526,650,721,822,926,1017,1416,1514,
	432,527,651,722,823,927,1018,1417,1515,
	433,528,652,723,824,928,1019,1418,1802,
	435,529,653,724,825,929,1020,1419,1804,
	436,530,608,725,826,936,1021,1420,1805,
	437,531,609,726,827,931,1022,1421,1806,
	438,532,612,728,828,932,1025,1422,1807,
	439,533,614,729,830,933,1026,1423,1808,
	440,534,615,730,831,934,1027,1424,1809,
	443,535,616,734,832,937,1028,1425,1810,
	445,536,617,735,835,939,1029,1426,1811,
	446,537,618,736,834,940,1030,1427,1812,
	447,538,619,737,837,941,1031,1428,1813,
	448,541,620,738,838,942,1032,1429,1814,
	449,542,628,739,839,943,1034,1430,1816,
	450,543,627,740,840,944,1035,1431,1817,
	451,546,626,741,841,945,1037,1432,1818,
	452,547,634,742,842,946,1036,1433,1819,
	453,550,635,743,843,947,1038,1434,1820,
	454,551,636,744,845,948,1042,1435,1822,
	455,552,637,745,846,949,1045,1436,1823,
	456,554,638,746,847,950,1044,1437,1824,
	457,556,639,747,848,951,1043,1438,1825,
	460,557,640,749,849,952,1046,1439,1826,
	461,558,642,750,851,953,1047,1440,1828,
	462,559,646,751,852,954,1048,1441,1829,
	463,560,654,752,853,955,1049,1442,1830,
	464,561,656,753,854,956,1050,1443,1831,
	466,562,655,754,874,959,1051,1444,1832,
	467,563,657,755,875,960,1052,1445,1833,
	468,565,660,756,862,961,1054,1446,1835,
	469,566,662,757,865,962,1055,1447,1838,
	470,567,663,758,876,963,1056,1448,1839,
	471,573,665,760,877,964,1057,1449,1840,
	472,574,666,763,878,965,1058,1450,1842,
	473,577,667,765,879,967,1059,1451,1843,
	474,572,668,766,880,968,1060,1452,1844,
	475,568,669,764,881,969,1061,1453,1845,
	476,569,670,773,882,970,1062,1454,1846,
	477,570,671,774,883,971,1063,1455,1850,
	478,571,672,775,884,972,1064,1456,1851,
	480,578,673,776,885,973,1065,1457,1852,
	481,579,675,777,886,974,1066,1458,1853,
	482,581,676,778,887,975,1067,1459,1854,
	483,582,677,779,888,976,1068,1460,1855,
	484,583,678,813,889,977,1069,1461,1856,
	485,584,679,781,890,978,1070,1462,1857,
	486,586,680,782,891,980,1071,1463,1858,
  1859,1860,1861,1862,1863,1864,1865,1868,
	1869,1870,1871,1872,1873,1874,1875,1876,1879,
	1880,1881,1882,1883,1884,1885,1886,1887,
	1888,1889,1890,1891,1892,1893,1894,1895,1896,
	1897,1898,1900,1902,1903,1904,1905,1906,1907,1908,1909,
	1910,1911,1912,1914,1917,1918,1919,1920,1922,1923,1924,1925,
	1926,1927,1928,1929,1930,1931,1932,1933,1934,
	1935,1936,1937,1938,1939,1940,1941,1942,1943,
	1971,1972,1973,1974,1975,1976,1977,1979,1980,1981,1982,1983,1984,
	1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,
	1999,2000,2001,2002,2003,2004,2005,2006,
2007,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,
2019,2020,2021,2022,2023,2024,2025,2026,2027,2028,2029,2030,2031,
2032,2033,2034,2035,2036,2038,2040,2042,2043,2044,2045,
2046,2048,2049,2050,2051,2052,2053,2054,2055,2056,2057,2059,2060,
2060,2061,2062,2063,2064,2065,2066,2067,2068,2069,
2070,2072,2073,2074,2075,2076,2077,
2078,2079,2080,2081,2082,2083,2084,2085,2089,2090,
2095,2098,2099,2100,2101,2102,2103,
2106,2107,2108,2109,2110,2112,2113,2114,
2115,2116,2117,2118,2119,2120,
2123,2124,2126,2128,2129,2130,2131,
2132,2135,2136,2137,2138,2139,2146,2148,2149,2150,2151,2152,2153,2154,2156,2157,2158,2159,2160,2161,2162,2163,
2165,
2168,2167,2169,2170,2175,
2176,2177,2178,2179,2180,2181,2182,2183,2184,2185,2186,2187,2188,2189,2190,2191,2192,2193,2194,2195,
2196,2197,2198,2199,2200,2201,2202,2203,
2204,2205,2206,2207,2208,2209,2210,2211,2212,2213,2214,2215,
2217,2218,2219,2220,2221,2222,2223,2224,2225,2226,2227,2228,2229,
2230,2231,2232,2233,2234,2235,
2236,2237,2238,2239,2240,2241,
2243,2244,2245,2246,2247,2248,2249,2250,
2253,2254,2256,2257,2258,2259,2260,2261,2263,2264,2265,
2266,2267,2268,2269,2270,2271,2272,2273,2274,2275,2276,2279,2280,2281,2282,2283,2284,2285,2286,2287,2289,2290,2291,2292,2293,2294,2295,2296,2297,2298,2299,
2300,2301,2302,
2303,2304,2305,2306,2307,2308,2309,
2310,2311,2312,2313,2314,2315,2316,2317,2319,2320,2321,2322,2323,2324,2325,2326,2327,2328,
2329,2330,2331,2333,2334,2335,2336,2337,2338,2339,2341,2343,2344,2345,2347,2348,2349,2350,2351,2352
)
)a 
GROUP BY 1 order by 8 DESC;

# 小程序活跃度

-- 小程序活跃用户数 - 小程序粉丝数车主数在日报上面拿

SELECT tmi.is_vehicle,count(DISTINCT tmi.id) 数量
FROM track.track t 
JOIN MEMBER.tc_member_info tmi ON cast(tmi.USER_ID AS varchar) = t.usertag
WHERE t.date between '2022-10-01' AND '2022-10-31 23:59:59'
-- WHERE t.date between DATE_SUB(CURDATE(),INTERVAL 7 DAY) AND CURDATE()
    AND t.date > tmi.member_time
    AND tmi.IS_DELETED = 0 
    AND tmi.MEMBER_STATUS <> 60341003
GROUP BY 1
with rollup;




-- 本周
select date(t.`date`) "日期",
   count(distinct case when t.typeid="XWSJPC_CMSHOME_BTWB_C" and t.`data` like "%推荐tab%" then t.usertag else null end) "推荐UV"，
   count(distinct case when t.typeid="XWSJPC_CMSHOME_BTWB_C" and t.`data` like "%俱乐部tab%" then t.usertag else null end) "俱乐部UV",
   count(distinct case when t.typeid="XWSJPC_CMSHOME_BTWB_C" and t.`data` like "%活动tab%" then t.usertag else null end) "活动UV",
   count(distinct case when t.typeid="XWSJPC_CMSHOME_BTWB_C" and t.`data` like "%头条tab%" then t.usertag else null end) "动态UV",
   -- count(distinct case when t.typeid="XWSJPC_CMSHOME_BTWB_C" and t.`data` like "%专题tab%" then t.usertag else null end) "专题UV",
   count(distinct case when t.typeid="XWSJPC_CMSHOME_BTWB_C" and t.`data` like "%探索tab%" then t.usertag else null end) "探索UV",
   count(distinct case when t.typeid="XWSJXCX_HOME_V" then t.usertag else null end) "首页UV",
   count(distinct case when t.typeid="XWSJXCX_MALL_HOMEPAGE_V" then t.usertag else null end) "商城UV",
   count(distinct case when (t.typeid="XWSJXCX_OWNER_V" or t.typeid="XWSJXCX_CUSTOMER_V") then t.usertag else null end) "爱车UV",
   count(distinct case when t.typeid="XWSJXCX_PERSONEL_V" then t.usertag else null end) "我的UV"
from track.track t 
where t.date between '2022-10-01' and '2022-10-31 23:59:59'
-- where t.`date` BETWEEN DATE_SUB(CURDATE(),INTERVAL 8 DAY) and CURDATE()
group by 1
order by 1;






# 俱乐部&动态
select DATE(t.date)
,count(DISTINCT case when json_extract(t.data,'$.embeddedpoint')='俱乐部_首页_点击：' then t.usertag else null end) 俱乐部
,count(DISTINCT case when json_extract(t.data,'$.embeddedpoint')='动态_首页_点击：' then t.usertag else null end) 动态
from track.track t 
where t.date between '2022-10-01' and '2022-10-31 23:59:59'
and t.typeid='NEWBIE_HOME_TRACK'
and json_extract(t.data,'$.embeddedpoint') in ('动态_首页_点击：','俱乐部_首页_点击：')
GROUP BY 1 order by 1 ;








