<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
			    com.britemoon.cps.*,
                java.sql.*,
                org.apache.log4j.Logger"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.w3c.dom.NodeList" %>
<%@ page import="org.w3c.dom.Element" %>
<%@ page import="org.w3c.dom.Node" %>
<%@ page import="javax.xml.parsers.DocumentBuilder" %>
<%@ page import="org.w3c.dom.Document" %>
<%@ page import="java.io.StringWriter" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import="org.xml.sax.InputSource" %>
<%@ page import="java.io.ByteArrayInputStream" %>
<%@ page import="com.britemoon.cps.imc.*" %>
<%@ page import="com.britemoon.cps.imc.Service" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>

<%!
    public class XmlParse{		//++++

        public String orderId 	    = null;
        public String email         = null;
        public String productId	    = null;
        public String productName	= null;
        public String link	        = null;
        public String qty	        = null;
        public String sumAmt	    = null;
        public String source 		= null;
        public String rvsSource	    = null;
        public String rvsMedium     = null;
        public String insertDate	= null;


        public XmlParse(Element element){

            orderId 	    =  Deger(element.getElementsByTagName("orderId")).equals("null") ? null : Deger(element.getElementsByTagName("orderId"));
            email           =  Deger(element.getElementsByTagName("email")).equals("null") ? null : Deger(element.getElementsByTagName("email"));
            productId	    =  Deger(element.getElementsByTagName("productId")).equals("null") ? null : Deger(element.getElementsByTagName("productId"));
            productName     =  Deger(element.getElementsByTagName("productName")).equals("null") ? null : Deger(element.getElementsByTagName("productName"));
            link            =  Deger(element.getElementsByTagName("link")).equals("null") ? null : Deger(element.getElementsByTagName("link"));
            qty	            =  Deger(element.getElementsByTagName("qty")).equals("null") ? "0" : Deger(element.getElementsByTagName("qty"));
            sumAmt	        =  Deger(element.getElementsByTagName("sumAmt")).equals("null") ? "0" : Deger(element.getElementsByTagName("sumAmt"));
            source 		    =  Deger(element.getElementsByTagName("source")).equals("null") ? null : Deger(element.getElementsByTagName("source"));
            rvsSource	    =  Deger(element.getElementsByTagName("rvsSource")).equals("null") ? null : Deger(element.getElementsByTagName("rvsSource"));
            rvsMedium	    =  Deger(element.getElementsByTagName("rvsMedium")).equals("null") ? null : Deger(element.getElementsByTagName("rvsMedium"));
            insertDate	    =  Deger(element.getElementsByTagName("insertDate")).equals("null") ? null : Deger(element.getElementsByTagName("insertDate"));

        }


        public String Deger(NodeList g1){

            String deger=null;

            if(g1.getLength()>0){
                Element g1_Element		= (Element)g1.item(0);
                NodeList text_g1 		= g1_Element.getChildNodes();
                if(text_g1.item(0) != null ){
                    deger					=((Node)text_g1.item(0)).getNodeValue().trim();
                }
            }

            return MysqlRealScapeString(deger)  ;
        }

        public String MysqlRealScapeString(String str){
            String data = "";
            if (str != null && str.length() > 0) {
                str = str.replace("\\", "\\\\");
                str = str.replace("'", "");
                str = str.replace("\0", "\\0");
                str = str.replace("\n", "\\n");
                str = str.replace("\r", "\\r");
                str = str.replace("\"", "\\\"");
                str = str.replace("\\x1a", "\\Z");
                data = str;
            }
            return data;
        }
    }
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>

<%!
    String maskString(String strText, int start, int end, char maskChar)
            throws Exception {

        if (strText == null || strText.equals(""))
            return "";

        if (start < 0)
            start = 0;

        if (end > strText.length())
            end = strText.length();

        if (start > end)
            throw new Exception("End index cannot be greater than start index");

        int maskLength = end - start;

        if (maskLength == 0)
            return strText;

        StringBuilder sbMaskString = new StringBuilder(maskLength);

        for (int i = 0; i < maskLength; i++) {
            sbMaskString.append(maskChar);
        }

        return strText.substring(0, start)
                + sbMaskString.toString()
                + strText.substring(start + maskLength);
    }

    String maskEmailAddress(String strEmail, char maskChar) throws Exception {

        String[] parts = strEmail.split("@");

        //mask two part
        String strId = "";
        if (parts[1].length() < 4)
            strId = maskString(parts[1], 0, parts[1].length(), '*');
        else
            strId = maskString(parts[1], 0, parts[1].length() - 3, '*');

        return parts[0] + "@" + strId;
    }
%>

<%

    String sCustId = cust.s_cust_id;
    Service service = null;
    Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, sCustId);
    service = (Service) services.get(0);
    String rcpUrl = service.getURL().getHost();
    List<JSONObject> resultList = new ArrayList();

    Calendar calendar = Calendar.getInstance();
    calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);

    int current_year;
    int current_month;
    int current_month_cal;
    int current_day;
    String last_week;


    calendar.add(Calendar.DATE, +4);
    current_year = calendar.get(Calendar.YEAR);
    current_month = calendar.get(Calendar.MONTH);
    current_month_cal = current_month + 1;
    current_day = calendar.get(Calendar.DAY_OF_MONTH);
    calendar.add(Calendar.DATE, -6);
    Date lastWeekNotFormat = calendar.getTime();
    last_week = new SimpleDateFormat("yyyy-MM-dd").format(lastWeekNotFormat);

    String today = current_year + "-" + current_month_cal + "-" + current_day;
    String firstDate = last_week;

    String date1 = (request.getParameter("date1") != null) ? request.getParameter("date1") : firstDate;
    String date2 = (request.getParameter("date2") != null) ? request.getParameter("date2") : today;

    Statement stmt = null;
    ConnectionPool cp = null;
    Connection conn = null;
    double totalQty = 0;
    double totalAmt = 0;



    System.out.println("sales_performance loading...");
    try {


        cp = ConnectionPool.getInstance();


        conn = cp.getConnection(this);
        stmt = conn.createStatement();


        NodeList nodeList = null;

        StringWriter sw = new StringWriter();

        sw.write("<root>");
        sw.write("<ccps_sales_performance>\r\n");
        sw.write("<cust_id><![CDATA[" + sCustId + "]]></cust_id>\r\n");
        sw.write("<date1><![CDATA[" + date1 + "]]></date1>\r\n");
        sw.write("<date2><![CDATA[" + date2 + "]]></date2>\r\n");
        sw.write("</ccps_sales_performance>\r\n");
        sw.write("</root>");


        String sResponse = Service.communicate(127, sCustId, sw.toString());


        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document document = builder.parse(new InputSource(new ByteArrayInputStream(sResponse.getBytes("UTF-8"))));




        nodeList = document.getElementsByTagName("rrcp_sales_performance_report");
        if(nodeList !=null) {
            for (int i = 0; i < nodeList.getLength(); i++) {

                XmlParse report = new XmlParse((Element) nodeList.item(i));

                String orderId      = report.orderId;
                String email        = report.email;
                String productId    = report.productId;
                String productName  = report.productName;
                String link         = report.link;
                double qty          = Double.parseDouble(report.qty);
                double sumAmt       = Double.parseDouble(report.sumAmt);
                String source       = report.source;
                String rvsSource    = report.rvsSource;
                String rvsMedium    = report.rvsMedium;
                String insertDate   = report.insertDate;


                if (!email.equals("")) {
                    email = maskEmailAddress(email, '@');
                }

                totalQty += qty;
                totalAmt += sumAmt;

                JSONObject jsonObject = new JSONObject();
                jsonObject.put("orderId", orderId);
                jsonObject.put("email", email);
                jsonObject.put("productId", productId);
                jsonObject.put("productName", productName);
                jsonObject.put("link", link);
                jsonObject.put("qty", qty);
                jsonObject.put("sumAmt", sumAmt);
                jsonObject.put("insertDate", insertDate);
                jsonObject.put("source", source);
                jsonObject.put("rvsSource", rvsSource);
                jsonObject.put("rvsMedium", rvsMedium);
                resultList.add(jsonObject);
            }
        }

        stmt.close();


    } catch (Exception ex) {
        System.out.println("sales_performance error for cust:"+sCustId+ex);
     } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            logger.error("Could not clean db statement or connection", e);
        }
    }

%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>SALES | PERFORMANCE</title>
    <!-- Tell the browser to be responsive to screen width -->
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">

    <link rel="stylesheet" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">
    <link rel="stylesheet" href="assets/css/font-awesome.min.css">
    <link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">

    <link rel="stylesheet" href="assets/css/ionicons.min.css">

    <link rel="stylesheet" href="assets/css/AdminLTE.css">
    <link rel="stylesheet" href="assets/css/Style.css">
    <link rel="stylesheet" href="assets/css/DataTable/dataTables.bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/skin-blue.min.css">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->

    <!-- Google Font -->
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">

    <style>
        .table_status {
            font-size: 12px;
            line-height: 32px;
            text-align: center;
        }

        td {
            font-size: 12px;
            vertical-align: middle !important;
            border: 1px solid #f2f2f2 !important;
        }

        th {
            font-size: 12px;
            background-color: #f2f2f2;
            border: 1px solid #ddd !important;
            vertical-align: middle !important;
        }
    </style>
</head>
<body class="hold-transition" style="background-color:#f1f1f1;">

<section class="content-header">
    <div class="box box-solid">
        <div class="box-header with-border">
            <div class="col-md-6"><h3>SALES | PERFORMANCE</h3></div>
            <div class="col-md-6">
                <div class="pull-right">
                    <div class="col-md-6">
                        <button type="button" class="btn bg-olive margin" onClick="window.location.reload()"><i
                                class="fa fa-refresh"></i> Refresh
                        </button>
                    </div>
                    <div class="col-md-6">
                        <button type="button" class="btn margin pull-right" id="daterange-btn">
                            <span><i class="fa fa-calendar"></i> Date Range </span><i class="fa fa-caret-down"></i>
                        </button>
                    </div>
                </div>
            </div>


        </div>
    </div>

</section>


<section class="content" style="margin-left:20px;margin-right:20px;">

    <div class="row">
        <div class="col-md-3 col-sm-6 col-xs-12">
            <div class="info-box">
                <span class="info-box-icon b_turuncu"><i class="glyphicon glyphicon-send c_beyaz"></i></span>

                <div class="info-box-content">
                    <span class="info-box-text">Total Quantity</span>
                    <span class="info-box-number"><%=totalQty%><small> </small></span>
                </div>
                <!-- /.info-box-content -->
            </div>
            <!-- /.info-box -->
        </div>
        <!-- /.col -->
        <div class="col-md-3 col-sm-6 col-xs-12">
            <div class="info-box ">
                <span class="info-box-icon b_yesil"><i class="glyphicon glyphicon-transfer c_beyaz"></i></span>

                <div class="info-box-content ">
                    <span class="info-box-text">Total Amount</span>
                    <span class="info-box-number" id="sales_total_amt"><%=totalAmt%></span>
                </div>
                <!-- /.info-box-content -->
            </div>
            <!-- /.info-box -->
        </div>
        <!-- /.col -->

        <!-- fix for small devices only -->
        <div class="clearfix visible-sm-block"></div>


    </div>

    <div class="row">

        <!-- fix for small devices only -->
        <div class="clearfix visible-sm-block"></div>

    </div>


    <div class="row">
        <div class="box">

            <div class="box-body">
                <table id="example1" class="table table-bordered table-striped table-hover">
                    <thead>
                    <tr>
                        <th>Order Id</th>
                        <th>Email</th>
                        <th>Product Id</th>
                        <th>Product Name</th>
                        <th>quantity</th>
                        <th>total amount</th>
                        <th>date</th>
                        <th>source</th>
                        <th>rvs source</th>
                        <th>rvs medium</th>
                    </tr>
                    </thead>
                    <tbody id="table_tr">
                    <%--<%=TABLE_TR%>--%>
                    </tbody>

                </table>

            </div>
        </div>
    </div>
</section>

<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/bootstrap.min.js"></script>
<script src="assets/js/adminlte.min.js"></script>
<!-- FastClick -->
<script src="assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="assets/js/demo.js"></script>

<script src="assets/js/daterangepicker/moment.min.js"></script>
<script src="assets/js/daterangepicker/daterangepicker.js"></script>

<script type="text/javascript" src="assets/js/FushionCharts/fusioncharts.js"></script>
<script type="text/javascript" src="assets/js/FushionCharts/fusioncharts.theme.fint.js"></script>

<!-- DataTables -->
<script src="assets/js/DataTable/jquery.dataTables.min.js"></script>
<script src="assets/js/DataTable/dataTables.bootstrap.min.js"></script>
<script>

    var resultList = <%=resultList%>;

    var currencyFetched = null;
    var currencyFetchFailed = null;
    var filtersFetched = null;
    var filtersFetchFailed = null;
    var currencyConfigs = null;
    var rcpLink = '<%=rcpUrl%>';

    var currencyPromise = new Promise((resolve, reject) => {
        currencyFetched = resolve;
        currencyFetchFailed = reject;
    });
    var filtersPromise = new Promise((resolve, reject) => {
        filtersFetched = resolve;
        filtersFetchFailed = reject;
    });

    Promise.all([currencyPromise, filtersPromise]).then(() => {
        document.getElementById('save_button').removeAttribute('disabled');
    }).catch(() => {
        alert('An error occurred while loading configurations!');
        location.reload();
    });

    fetch('https://' + rcpLink + '/rrcp/imc/currency/get_currency_config.jsp?cust_id=<%=sCustId%>')
        .then(resp => resp.json())
        .then(async resp => {
            currencyConfigs = resp;
            currencyFetched();
            await currencyPromise;
            var totalAmt =
            <%=totalAmt%>
            var totalAmtDom = document.getElementById('sales_total_amt')
            totalAmtDom.innerText = formatCurrency(totalAmt, currencyConfigs.filter(config => config.active == 1)[0]);

            var tableTr = document.getElementById("table_tr")
            var newEntry;
            resultList.forEach((item) => {
                newEntry = document.createElement('tr');
                newEntry.innerHTML =
                    '<td>' + item.orderId + '</td>' +
                    '<td>' + item.email + '</td>' +
                    '<td>' + item.productId + '</td>' +
                    '<td><a href=' + item.link + ' target=_blank> ' + item.productName + '</a></td>' +
                    '<td>' + item.qty + '</td>' +
                    '<td>' + formatCurrency(item.sumAmt, currencyConfigs.filter(config => config.active == 1)[0]) + '</td>' +
                    '<td>' + item.insertDate + '</td>' +
                    '<td>' + item.source + '</td>' +
                    '<td>' + item.rvsSource + '</td>' +
                    '<td>' + item.rvsMedium + '</td>';

                tableTr.appendChild(newEntry)
            })
            $(function () {


                $('#example1').DataTable({
                    'paging': true,
                    'lengthChange': true,
                    'searching': true,
                    'ordering': true,
                    'info': true,
                    'autoWidth': true
                })
            })

        }).catch((err) => {
        console.log(err)
        currencyFetchFailed();
    });

    var queryString = window.location.search;
    var urlParams = new URLSearchParams(queryString);

    var date1 = urlParams.get('date1')
    var date2 = urlParams.get('date2')

    if (date1 == null) {
        var today = new Date();

        var dateObj = new Date();
        var month = dateObj.getUTCMonth() + 1; //months from 1-12
        var day = dateObj.getUTCDate();
        var lastWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 6);
        var frmLastWeek = moment(lastWeek).format('YYYY-MM-DD');

        //var lastWeek = dateObj.getDate() - 6;
        var year = dateObj.getUTCFullYear();

        newdate = year + "-" + month + "-" + day;
        date1 = frmLastWeek;
        date2 = newdate;
    }

    $('#daterange-btn span').html(date1 + " - " + date2);
    $('#daterange-btn').daterangepicker(
        {
            ranges: {
                'Today': [moment(), moment()],
                'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
                'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                'Last 30 Days': [moment().subtract(29, 'days'), moment()],
                'This Month': [moment().startOf('month'), moment().endOf('month')],
                'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
            },
            startDate: moment(date1),
            endDate: moment(date2)

        },
        function (start, end) {
            $('#daterange-btn span').html(start.format('YYYY-MM-D') + ' - ' + end.format('YYYY-MM-D'))
            var date1 = start.format('YYYY-MM-D');
            var date2 = end.format('YYYY-MM-D');
            location.href = "sales_performance.jsp?date1=" + date1 + "&date2=" + date2;
            /* $.ajax({
                            type: "GET",
                            url: "sales_performance.jsp?date1=" + date1 + "&date2=" + date2",
                           success: function (msg) {
                               location.href = "sales_performance.jsp?date1=" + date1 + "&date2=" +date2;

                           },
                           error: function (err){
                               console.log(err)
                           }
                       });
           */

        }
    );

    function numberToFixed(number, toFixed) {
        number = number.toString();
        var indexOfDot = number.indexOf('.');
        if (indexOfDot !== -1) {
            if (toFixed == 0) {
                number = number.substring(0, indexOfDot);
            } else {
                number = number.split('').filter((e, i) => {
                    return (indexOfDot + toFixed) >= i;
                }).join('');
                var decimalCount = number.length - indexOfDot - 1;
                if (toFixed > decimalCount) number = number.concat(Array.apply(null, Array(toFixed - decimalCount)).map(Number.prototype.valueOf, 0).join(''));
            }
        } else if (toFixed > 0) {
            number = number.concat(['.']);
            number = number.concat(Array.apply(null, Array(toFixed)).map(Number.prototype.valueOf, 0).join(''));
        }
        return number;
    }

    function formatCurrency(number, currencyConfig) {
        var originalNumber = number;
        try {
            number = number.toString();
            number = number.replace(/[^0-9.,]/g, '');
            number = number.split(',').join('.');
            number = parseFloat(number);
            var indexOfComma = currencyConfig.format.indexOf(',');
            var indexOfDot = currencyConfig.format.indexOf('.');
            var thousandSeparator = indexOfComma < indexOfDot ? ',' : '.';
            var decimalSeparator = indexOfComma < indexOfDot ? '.' : ',';
            if (indexOfComma === -1 || indexOfDot === -1) thousandSeparator = '';
            var decimalCount = currencyConfig.format.length - currencyConfig.format.indexOf(decimalSeparator) - 1;
            number = numberToFixed(number, decimalCount);
            var parts = number.split('.').length === 2 ? number.split('.') : number.split(',');
            var normalPart = parts[0];
            var decimalPart = parts[1] ? parts[1] : '';

            normalPart = normalPart.split('').reverse().map((e, i, arr) => {
                if ((i + 1) % 3 === 0 && arr.length > (i + 1)) return thousandSeparator + e;
                else return e;
            }).reverse().join('');
            var currency = normalPart + (decimalPart ? (decimalSeparator + decimalPart) : '');
            if (currencyConfig.language === 'EN') currency = currencyConfig.currency + currency;
            else if (currencyConfig.language === 'TR') currency = currency + ' ' + currencyConfig.currency;
            return currency;
        } catch (e) {
            return originalNumber;
        }

    }

</script>

</body>
</html>

