CREATE PROCEDURE [dbo].[z_rec_buy_also]
AS
BEGIN
BEGIN TRANSACTION
BEGIN TRY
create table #temp_product
(
    product_id          varchar(20),
    count               int,
    rec_product_id      varchar(20),
    name                varchar(255),
    product_price       varchar(20),
    product_sales_price varchar(20),
    link                varchar(MAX),
                image_link          varchar(MAX),
                create_date         datetime
            )

create table #temp_order
(
    product_id          varchar(20),
    userid              varchar(255),

)


DECLARE @ID VARCHAR(20)
            DECLARE @ID2 VARCHAR(20)


            DECLARE MY_CURSOR CURSOR
                LOCAL STATIC READ_ONLY FORWARD_ONLY
                FOR
SELECT product_id
from z_rec_products with (nolock )
where product_status != 'INACTIVE'


insert into #temp_order
select product_id,userid from rque_cust_order with(nolock) where insert_date > getdate() - 180 and product_id!= ''



    OPEN MY_CURSOR
    FETCH NEXT FROM MY_CURSOR INTO @ID
    WHILE @@FETCH_STATUS = 0
BEGIN



insert into #temp_product(product_id, count, rec_product_id, name, product_price, product_sales_price, link,
                          image_link, create_date)
select top 10 @ID,
       count(*)                   as count,
                                  #temp_order.product_id as rec_product_id,
                                  z_rec_products.product_name,
                                  z_rec_products.product_price,
                                  z_rec_products.product_sales_price,
                                  z_rec_products.link,
                                  z_rec_products.image_link,
                                  getdate()
from #temp_order
    inner join z_rec_products with (nolock) on z_rec_products.product_id = #temp_order.product_id
where z_rec_products.product_status != 'INACTIVE'
  and #temp_order.product_id is not null
  and @ID != #temp_order.product_id
  and #temp_order.userid in (SELECT userid FROM #temp_order where product_id = @ID)
group by #temp_order.product_id, z_rec_products.product_name, #temp_order.product_id,
    z_rec_products.product_price, z_rec_products.product_sales_price, z_rec_products.link,
    z_rec_products.image_link
order by 2 desc


DECLARE MY_CURSOR2 CURSOR FOR
SELECT rec_product_id from #temp_product where product_id = @ID

    OPEN MY_CURSOR2
                    FETCH NEXT FROM MY_CURSOR2 INTO @ID2
    WHILE @@FETCH_STATUS = 0
BEGIN


insert into z_product_buy_also_temp (product_id, count, rec_product_id, json_data, create_date)
select @ID,
       (select count from #temp_product where product_id = @ID and rec_product_id = @ID2),
       @ID2,
       (select '[' + STUFF((
                               select ',{"p_id":' + t1.rec_product_id
                                          + ',"name":"' + t1.name + '"'
                                          + ',"product_price":"' + t1.product_price + '"'
                                          + ',"product_sales_price":"' + t1.product_sales_price + '"'
                                          + ',"link":"' + t1.link + '"'
                                          + ',"image_link":"' + t1.image_link + '"'
                                          + '}'

                               from #temp_product t1
                               WHERE t1.product_id = @ID
                                 and t1.rec_product_id = @ID2
                               for xml path(''), type
           ).value('.', 'varchar(max)'), 1, 1, '') + ']'
                   as x),
       (select create_date from #temp_product where product_id = @ID and rec_product_id = @ID2)





    FETCH NEXT FROM MY_CURSOR2 INTO @ID2
END

CLOSE MY_CURSOR2
    DEALLOCATE MY_CURSOR2

                    FETCH NEXT FROM MY_CURSOR INTO @ID
END

DROP TABLE #temp_product
    CLOSE MY_CURSOR
    DEALLOCATE MY_CURSOR




    EXEC sp_rename 'z_product_buy_also', 'z_product_buy_also_useless'
    EXEC sp_rename 'z_product_buy_also_temp', 'z_product_buy_also'
    EXEC sp_rename 'z_product_buy_also_useless', 'z_product_buy_also_temp'
    TRUNCATE TABLE z_product_buy_also_temp

    COMMIT
END TRY BEGIN CATCH
            ROLLBACK
END CATCH

END