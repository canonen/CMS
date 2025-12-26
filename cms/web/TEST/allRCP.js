(async function() {
//Butun cust tablolarında

//All customers
    var custList = await fetch('http://cms.revotas.com/cms/ui/jsp/getRcp/getAllCustomers.jsp').then(resp=>resp.json());

//single customer

    //var custList = [1016,1017];

    custList = custList.filter((a,b) => custList.indexOf(a) === b);

    var sql = [];

sql.push(`create table rrcp_webpush_dashboard_reporting_log
(
start_date datetime,
end_date datetime,
status int
)
create table rrcp_webpush_recipient_day(
id int IDENTITY(1,1),
cust_id int,
sub_count int,
unsub_count int,
day datetime,
post_time datetime
)

create table rrcp_webpush_device_type(
cust_id int,
device varchar(255),
active_count int,
passive_count int,
)

create table rrcp_webpush_browser(
cust_id int,
browser varchar(255),
active_count int,
passive_count int
)

create table rrcp_webpush_geo(
cust_id int,
city varchar(255),
region varchar(255),
count int
)`); //Bu kısıma sql yazılıyor Go vs kaldırılacak orijinal sql olacak.

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