

select
distinct a.id spu_id,a.spu_bus_id,a.name 商品名称,c1.title 一级类目,c2.title 二级类目,c3.title 三级类目
FROM goods.item_spu a
left join goods.category c1 on a.category1_id = c1.id 
left join goods.category c2 on a.category2_id = c2.id
left join goods.category c3 on a.category3_id = c3.id
where a.item_type ='51121002'

select
distinct a.id spu_id,
a.spu_bus_id,
b.id sku_id,
b.coupon_id 卡券ID,
b.coupon_name 卡券名称,
a.name 商品名称,
c1.title 一级类目,
c2.title 二级类目,
c3.title 三级类目
FROM goods.item_spu a
left join goods.item_sku b on a.id = b.spu_id
left join goods.category c1 on a.category1_id = c1.id 
left join goods.category c2 on a.category2_id = c2.id
left join goods.category c3 on a.category3_id = c3.id
where b.coupon_id is not null  -- 这个不知道对不对