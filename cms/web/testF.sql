SET ANSI_NULLS, QUOTED_IDENTIFIER ON;
GO

BEGIN

select count(*) as x, product_id
into #t
from rque_cust_order with(nolock)
where insert_date > getdate()-7
group by  product_id
having count(*) > 5
order by 1 desc

create table #topseller(
                           x int,
                           cat_id varchar(255) default '',
                           product_id varchar(255) default '',
                           product_name varchar(255) default '',
                           product_price varchar(255) default '',
                           product_sales_price varchar(255) default '',
                           product_link varchar(255) default '',
                           product_image_link varchar(255) default '',
                           row_num int
)

    insert into #topseller (x, cat_id, product_id, product_name, product_price, product_sales_price, product_link, product_image_link, row_num)
select
    #t.x, z.top_category_id, z.product_id,  z.product_name, z.product_price, z.product_sales_price, z.link, z.image_link
     ,RowNum=row_number() over (partition by top_category_id order by #t.x desc)
from z_rec_products z with(nolock), #t
where z.product_id=#t.product_id
  and z.product_status !='INACTIVE'
order by 1 desc

insert into #topseller (x, cat_id, product_id, product_name, product_price, product_sales_price, product_link, product_image_link, row_num)
select
    #t.x, z.category_id_2, z.product_id,  z.product_name, z.product_price, z.product_sales_price, z.link, z.image_link
     ,RowNum=row_number() over (partition by category_id_2 order by #t.x desc)
from z_rec_products z with(nolock), #t
where z.product_id=#t.product_id
  and z.product_status !='INACTIVE'
order by 1 desc

insert into #topseller (x, cat_id, product_id, product_name, product_price, product_sales_price, product_link, product_image_link, row_num)
select
    #t.x, z.category_id_3, z.product_id,  z.product_name, z.product_price, z.product_sales_price, z.link, z.image_link
     ,RowNum=row_number() over (partition by category_id_3 order by #t.x desc)
from z_rec_products z with(nolock), #t
where z.product_id=#t.product_id
  and z.product_status !='INACTIVE'
order by 1 desc

insert into #topseller (x, cat_id, product_id, product_name, product_price, product_sales_price, product_link, product_image_link, row_num)
select
    #t.x, z.category_id_4, z.product_id, z.product_name, z.product_price, z.product_sales_price, z.link, z.image_link
     ,RowNum=row_number() over (partition by category_id_4 order by #t.x desc)
from z_rec_products z with(nolock), #t
where z.product_id=#t.product_id
  and z.product_status !='INACTIVE'
order by 1 desc


    truncate table z_product_topseller

insert into z_product_topseller (cust_id, product_id, cat_id, json_data)
select   '878', product_id, cat_id,
         (select
                  '[' + STUFF((
                                  select
                                          ',{"p_id":' + cast(product_id as varchar(max))
                                          + ',"category_id":"' + cat_id + '"'
                                          + ',"name":"' + product_name + '"'
                                          + ',"product_price":"' + product_price + '"'
                                          + ',"product_sales_price":"' + product_sales_price + '"'
                                          + ',"link":"' + product_link + '"'
                                          + ',"image_link":"' + product_image_link + '"'
                                          +'}'

                                  from #topseller t1
                                  WHERE t2.product_id = t1.product_id
                                  for xml path(''), type
                  ).value('.', 'varchar(max)'), 1, 1, '') + ']'
                  as x)
from #topseller t2
--where row_num=1

--select * from #topseller order by x desc
--select * from #topseller where row_num=1 order by x desc

drop table #topseller
drop table #t

END