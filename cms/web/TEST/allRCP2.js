(async function() {
//Butun cust tablolarında

//All customers
    var custList = await fetch('http://cms.revotas.com/cms/ui/jsp/getRcp/getAllCustomers.jsp').then(resp=>resp.json());

//single customer

//var custList = [1016,1017];

    custList = custList.filter((a,b) => custList.indexOf(a) === b);

    var sql = [];

sql.push(`
CREATE PROCEDURE [dbo].[zcs_webpush_dashboard_save] @cust_id int
AS

    
PRINT convert(varchar,getdate(),120)+' -->> Start Insert rrcp_webpush_recipient_day'

DECLARE @unsub_count int
DECLARE @sub_count int
DECLARE @day varchar(255)


SELECT @unsub_count  =   count(create_date)
FROM rque_push_recipient    where status_id = 210   and convert(varchar, create_date, 1) = convert(varchar, getdate(), 1)
GROUP BY convert(varchar, create_date, 1) ,status_id
ORDER BY 1

SELECT @sub_count  =   count(create_date)
FROM rque_push_recipient    where status_id = 110   and convert(varchar, create_date, 1) = convert(varchar, getdate(), 1)
GROUP BY convert(varchar, create_date, 1) ,status_id
ORDER BY 1

SELECT @day =  convert(varchar, create_date, 1)
FROM rque_push_recipient as r where convert(varchar, create_date, 1) = convert(varchar, getdate(), 1)
GROUP BY convert(varchar, create_date, 1) ,status_id
ORDER BY 1
    IF(@unsub_count > 0 or @sub_count > 0 )
BEGIN
INSERT INTO rrcp_webpush_recipient_day (cust_id,sub_count, unsub_count,day) values (@cust_id,@sub_count, @unsub_count,@day)
    PRINT convert(varchar,getdate(),120)+' -->> Finish Insert rrcp_webpush_recipient_day'
END
ELSE
BEGIN
PRINT convert(varchar,getdate(),120)+' -->> Finish Not Insert rrcp_webpush_recipient_day count is null'
END

-----------
    
PRINT convert(varchar,getdate(),120)+' -->> Start Insert rrcp_webpush_device_type'
truncate table rrcp_webpush_device_type
create table #unsub_device(
                              device varchar(255),
                              total int
)

    INSERT #unsub_device  exec [dbo].[zcs_webpush_device] 210
DECLARE @unsub_tablet int
DECLARE @unsub_mobile int
DECLARE @unsub_desktop int

SET @unsub_tablet = (Select total from #unsub_device where device = 'Tablet')
SET @unsub_mobile = (Select total from #unsub_device where device = 'Mobile')
SET @unsub_desktop = (Select total from #unsub_device where device = 'Desktop')

create table #sub_device(
                            device varchar(255),
                            total int
)

    INSERT #sub_device  exec [dbo].[zcs_webpush_device] 110
DECLARE @sub_tablet int
DECLARE @sub_mobile int
DECLARE @sub_desktop int

SET @sub_tablet = (Select total from #sub_device where device = 'Tablet')
SET @sub_mobile = (Select total from #sub_device where device = 'Mobile')
SET @sub_desktop = (Select total from #sub_device where device = 'Desktop')

insert into  rrcp_webpush_device_type(cust_id,device,active_count, passive_count) VALUES (@cust_id, 'Tablet',  @sub_tablet,  @unsub_tablet)
insert into  rrcp_webpush_device_type(cust_id,device,active_count, passive_count) VALUES (@cust_id, 'Mobile',  @sub_mobile,  @unsub_mobile)
insert into  rrcp_webpush_device_type(cust_id,device,active_count, passive_count) VALUES (@cust_id, 'Desktop',  @sub_desktop,  @unsub_desktop)
drop table #unsub_device
drop table #sub_device

    PRINT convert(varchar,getdate(),120)+' -->> Finish Insert rrcp_webpush_device_type'


-----------


    PRINT convert(varchar,getdate(),120)+' -->> Start Insert rrcp_webpush_browser'
    truncate table rrcp_webpush_browser
create table #sub_browser(
                             browser varchar(255),
                             total int
)

    INSERT #sub_browser  exec [dbo].[zcs_webpush_mobile] 110
DECLARE @sub_opera int
DECLARE @sub_edge int
DECLARE @sub_firefox int
DECLARE @sub_chrome int
DECLARE @sub_safari int
DECLARE @sub_unknown int

SET @sub_opera  = (Select total from #sub_browser where browser = 'Opera')
SET @sub_edge = (Select total from #sub_browser where browser = 'Edge')
SET @sub_firefox = (Select total from #sub_browser where browser = 'Firefox')
SET @sub_chrome = (Select total from #sub_browser where browser = 'Chrome')
SET @sub_safari = (Select total from #sub_browser where browser = 'Safari')
SET @sub_unknown = (Select total from #sub_browser where browser = 'Unknown')

create table #unsub_browser(
                               browser varchar(255),
                               total int
)
    INSERT #unsub_browser  exec [dbo].[zcs_webpush_mobile] 210
DECLARE @unsub_opera int
DECLARE @unsub_edge int
DECLARE @unsub_firefox int
DECLARE @unsub_chrome int
DECLARE @unsub_safari int
DECLARE @unsub_unknown int

SET @unsub_opera  = (Select total from #unsub_browser where browser = 'Opera')
SET @unsub_edge = (Select total from #unsub_browser where browser = 'Edge')
SET @unsub_firefox = (Select total from #unsub_browser where browser = 'Firefox')
SET @unsub_chrome = (Select total from #unsub_browser where browser = 'Chrome')
SET @unsub_safari = (Select total from #unsub_browser where browser = 'Safari')
SET @unsub_unknown = (Select total from #unsub_browser where browser = 'Unknown')


insert into  rrcp_webpush_browser(cust_id,browser,active_count, passive_count) VALUES (@cust_id, 'Opera',  @sub_opera,  @unsub_opera)
insert into  rrcp_webpush_browser(cust_id,browser,active_count, passive_count) VALUES (@cust_id, 'Edge',  @sub_edge,  @unsub_edge)
insert into  rrcp_webpush_browser(cust_id,browser,active_count, passive_count) VALUES (@cust_id, 'Firefox',  @sub_firefox,  @unsub_firefox)
insert into  rrcp_webpush_browser(cust_id,browser,active_count, passive_count) VALUES (@cust_id, 'Chrome',  @sub_chrome,  @unsub_chrome)
insert into  rrcp_webpush_browser(cust_id,browser,active_count, passive_count) VALUES (@cust_id, 'Safari',  @sub_safari,  @unsub_safari)
insert into  rrcp_webpush_browser(cust_id,browser,active_count, passive_count) VALUES (@cust_id, 'Unknown',  @sub_unknown,  @unsub_unknown)

drop table #unsub_browser
drop table #sub_browser

    PRINT convert(varchar,getdate(),120)+' -->> Finish Insert rrcp_webpush_browser'


-------


    PRINT convert(varchar,getdate(),120)+' -->> Start Insert rrcp_webpush_geo'
    truncate table rrcp_webpush_geo
    insert into rrcp_webpush_geo select cust_id, city ,region, COUNT(*) count from rque_push_recipient
                                 where status_id=110 and city is not null
                                 GROUP BY city,region, cust_id
                                 ORDER BY 4 desc
                                     PRINT convert(varchar,getdate(),120)+' -->> Finish Insert rrcp_webpush_geo'


-------





`); //Bu kısıma sql yazılıyor Go vs kaldırılacak orijinal sql olacak.

    var type = 'update';

    for(var id of custList) {
        var rcp = await fetch('http://cms.revotas.com/cms/ui/jsp/getRcp/getRcp.jsp?cust_id='+id).then(function(rcp) {return rcp.text();});
        if(rcp.includes('rcp') && (!rcp.includes(4) && !rcp.includes(5))) {
            for(var sqlString of sql) {
                try {
                    await fetch('http://'+rcp.trim()+'/rrcp/imc/execCode/exec_code.jsp?cust_id='+id+'&type='+type, {
                        mode: 'no-cors',
                        method: 'POST',
                        headers: {
                            'Content-Type':'application/json'
                        },
                        body: sqlString
                    });
                } catch(e) {
                    console.warn(e);
                }
            }
        }
    }

})();