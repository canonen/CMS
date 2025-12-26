<%@ page
        language="java"
        import="com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			javax.xml.parsers.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			java.io.*,
			org.w3c.dom.*,
			org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.*" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.CDL" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.io.StringReader" %>
<%@ page import="javax.xml.parsers.DocumentBuilder" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import="org.w3c.dom.Document" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="org.xml.sax.InputSource" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="sun.nio.ch.IOUtil" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
<%@ page import="org.xml.sax.SAXException" %>
<%@ page import="org.xml.sax.SAXParseException" %>
<%@ page import="org.apache.axis.ConfigurationException" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
<%@ page import="com.britemoon.cps.imc.Service" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>
<%!
    public class XmlParse{		//++++

        public String queueCount 	  = null;
        public String completedCount  = null;
        public String rejectCount	  = null;
        public String errorCount	  = null;
        public String iysErrorCount	  = null;
        public String recipient	      = null;
        public String type	          = null;
        public String source 		  = null;
        public String status	      = null;
        public String recipient_type  = null;
        public String consent_date	  = null;
        public String iys_create_date = null;
        public String status_id	      = null;
        public String iys_error_msg	  = null;



        public XmlParse(Element element){

            queueCount 	      =  Deger(element.getElementsByTagName("queueCount")).equals("null") ? null : Deger(element.getElementsByTagName("queueCount"));
            completedCount    =  Deger(element.getElementsByTagName("completedCount")).equals("null") ? null : Deger(element.getElementsByTagName("completedCount"));
            rejectCount	      =  Deger(element.getElementsByTagName("rejectCount")).equals("null") ? null : Deger(element.getElementsByTagName("rejectCount"));
            errorCount        =  Deger(element.getElementsByTagName("errorCount")).equals("null") ? null : Deger(element.getElementsByTagName("errorCount"));
            iysErrorCount     =  Deger(element.getElementsByTagName("iysErrorCount")).equals("null") ? null : Deger(element.getElementsByTagName("iysErrorCount"));
            recipient	      =  Deger(element.getElementsByTagName("recipient")).equals("null") ? null : Deger(element.getElementsByTagName("recipient"));
            type	          =  Deger(element.getElementsByTagName("type")).equals("null") ? null : Deger(element.getElementsByTagName("type"));
            source 		      =  Deger(element.getElementsByTagName("source")).equals("null") ? null : Deger(element.getElementsByTagName("source"));
            status	          =  Deger(element.getElementsByTagName("status")).equals("null") ? null : Deger(element.getElementsByTagName("status"));
            recipient_type	  =  Deger(element.getElementsByTagName("recipient_type")).equals("null") ? null : Deger(element.getElementsByTagName("recipient_type"));
            consent_date	  =  Deger(element.getElementsByTagName("consent_date")).equals("null") ? null : Deger(element.getElementsByTagName("consent_date"));
            iys_create_date	  =  Deger(element.getElementsByTagName("iys_create_date")).equals("null") ? null : Deger(element.getElementsByTagName("iys_create_date"));
            status_id	      =  Deger(element.getElementsByTagName("status_id")).equals("null") ? null : Deger(element.getElementsByTagName("status_id"));
            iys_error_msg	  =  Deger(element.getElementsByTagName("iys_error_msg")).equals("null") ? null : Deger(element.getElementsByTagName("iys_error_msg"));

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
            throws Exception{

        if(strText == null || strText.equals(""))
            return "";

        if(start < 0)
            start = 0;

        if( end > strText.length() )
            end = strText.length();

        if(start > end)
            throw new Exception("End index cannot be greater than start index");

        int maskLength = end - start;

        if(maskLength == 0)
            return strText;

        StringBuilder sbMaskString = new StringBuilder(maskLength);

        for(int i = 0; i < maskLength; i++){
            sbMaskString.append(maskChar);
        }

        return strText.substring(0, start)
                + sbMaskString.toString()
                + strText.substring(start + maskLength);
    }

    String maskEmailAddress(String strEmail, char maskChar)
            throws Exception{

        String[] parts = strEmail.split("@");

        //mask two part
        String strId = "";
        if(parts[1].length() < 4)
            strId = maskString(parts[1], 0, parts[1].length(), '*');
        else
            strId = maskString(parts[1], 0, parts[1].length()-3, '*');

        return parts[0] + "@" + strId;
    }
%>
<%
    Calendar calendar = Calendar.getInstance();
    calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);

    int current_year;
    int current_month;
    int current_month_cal;
    int current_day;
    //String last_week;

    current_year = calendar.get(Calendar.YEAR);
    current_month = calendar.get(Calendar.MONTH);
    current_month_cal = current_month + 1;
    calendar.add(Calendar.DATE,2);
    current_day = calendar.get(Calendar.DAY_OF_MONTH);
    //calendar.add(Calendar.DATE, -7);
    //Date lastWeekNotFormat = calendar.getTime();
    //last_week = new SimpleDateFormat("yyyy-MM-dd").format(lastWeekNotFormat);

    String today = current_year + "-" + current_month_cal + "-" + current_day;
    //String firstDate = last_week;

    JSONArray result;

    String sCustId = cust.s_cust_id;
    String date1 = (request.getParameter("date1") != null) ? request.getParameter("date1") : today;
    String date2 = (request.getParameter("date2") != null) ? request.getParameter("date2") : today;
    String date1ForCount = (request.getParameter("date1") != null) ? request.getParameter("date1") : "2020-05-01";



    Statement stmt = null;
    ConnectionPool cp = null;
    Connection conn = null;
    int queueCount = 0;
    int completedCount = 0;
    int rejectCount = 0;
    int errorCount = 0;
    int iysErrorCount = 0;

    try {

        cp = ConnectionPool.getInstance();


        conn = cp.getConnection(this);
        stmt = conn.createStatement();


        NodeList nodeList = null;

        StringWriter sw = new StringWriter();

        sw.write("<root>");
        sw.write("<ccps_dashboard>\r\n");
        sw.write("<cust_id><![CDATA[" + sCustId + "]]></cust_id>\r\n");
        sw.write("<date1><![CDATA[" + date1 + "]]></date1>\r\n");
        sw.write("<date2><![CDATA[" + date2 + "]]></date2>\r\n");
        sw.write("</ccps_dashboard>\r\n");
        sw.write("</root>");



        String sResponse = Service.communicate(126, sCustId, sw.toString());


        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document document = builder.parse(new InputSource(new ByteArrayInputStream(sResponse.getBytes("UTF-8"))));


        nodeList = document.getElementsByTagName("rrcp_dashboard_count_report");

        if(nodeList !=null) {
            XmlParse report = new XmlParse((Element) nodeList.item(0));

            queueCount      = Integer.parseInt(report.queueCount);
            completedCount  = Integer.parseInt(report.completedCount);
            rejectCount     = Integer.parseInt(report.rejectCount);
            errorCount      = Integer.parseInt(report.errorCount);
            iysErrorCount   = Integer.parseInt(report.iysErrorCount);
            System.out.println("Iys error for cust:" + sCustId + queueCount+completedCount+errorCount);

        }


        StringBuilder string = new StringBuilder("recipient, type, source, status, recipientType," +
                "consentDate, iysCreateDate, statusId, iysErrorMsg\n");


        nodeList = document.getElementsByTagName("rrcp_IysProcess_report");
        if(nodeList !=null) {
            for (int i = 0; i < nodeList.getLength(); i++) {

                XmlParse report = new XmlParse((Element) nodeList.item(i));

                String recipient        = report.recipient;
                String type             = report.type;
                String source           = report.source;
                String status           = report.status;
                String recipientType    = report.recipient_type;
                String consentDate      = report.consent_date;
                String iysCreateDate    = report.iys_create_date;
                int statusId            = report.status_id.equals("")? 0 : Integer.parseInt(report.status_id);
                String iysErrorMsg      = report.iys_error_msg;


                if(iysErrorMsg == null){
                    iysErrorMsg = "---";
                }
                if(iysCreateDate  == null ){
                    iysCreateDate = "---";
                }

                Map<Integer, String> statusMap = new HashMap<Integer, String>(6);

                statusMap.put(45, "Hatali Veri");
                statusMap.put(10, "Olusturuldu");
                statusMap.put(15, "Kuyrukta");
                statusMap.put(30, "Basarili");
                statusMap.put(40, "Hatali Veri");
                statusMap.put(70, "IYS Hatasi");
                String  maskEmailAddress =  maskEmailAddress(recipient,'@');

                string.append(maskEmailAddress).append(",").append(type).append(",").append(source).append(",").append(status)
                        .append(",").append(recipientType).append(",").append(consentDate).append(",").append(iysCreateDate)
                        .append(",").append(statusMap.get(statusId)).append(",").append(iysErrorMsg).append("\n");

            }
        }


        result = CDL.toJSONArray(string.toString());

        stmt.close();

    } catch (Exception ex) {
        System.out.println("Iys error for cust:" + sCustId + ex);
        throw ex;
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            logger.error("Could not clean db statement or connection for cust:" + sCustId, e);
        }
    }


%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>DASHBOARD</title>
    <!-- Tell the browser to be responsive to screen width -->
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">

    <link rel="stylesheet" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">
    <link rel="stylesheet" href="assets/css/font-awesome.min.css">
    <%--    <link rel="stylesheet" href="plugins/fontawesome-free/css/all.min.css">--%>
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.12.0/css/all.css">
    <link rel="stylesheet" href="assets/css/ionicons.min.css">

    <link rel="stylesheet" href="assets/css/AdminLTE.css">
    <link rel="stylesheet" href="assets/css/AdminLTEUpdated.css">
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


</head>
<body class="hold-transition" style="background-color:#f1f1f1;">
<tr></tr>
<section class="content-header">
    <div class="box box-solid">
        <div class="box-header with-border">
            <div class="col-md-6"><h3>Dashboard <small>Control panel</small></h3></div>
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


<section style="margin-left:20px;margin-right:20px;">

    <div class="row">

        <div class="col-md-3 col-sm-6 col-xs-12">
            <div class="info-box">
                <span class="info-box-icon b_turkuaz"><i class="fa fa-paper-plane c_beyaz"></i></span>

                <div class="info-box-content">
                    <span class="info-box-text">KUYRUK</span>
                    <span class="info-box-number" id="total_order_info"><small><%=queueCount%> </small></span>
                </div>
            </div>
        </div>

        <div class="col-md-3 col-sm-6 col-xs-12">
            <div class="info-box">
                <span class="info-box-icon b_yesil"><i class="fa fa-check c_beyaz"></i></span>

                <div class="info-box-content">
                    <span class="info-box-text">ONAY</span>
                    <span class="info-box-number" id="total_order_info"><small><%=completedCount%> </small></span>
                </div>
            </div>
        </div>

        <div class="col-md-3 col-sm-6 col-xs-12">
            <div class="info-box">
                <span class="info-box-icon b_turuncu"><i class="fa fa-times c_beyaz"></i></span>

                <div class="info-box-content">
                    <span class="info-box-text">RET</span>
                    <span class="info-box-number" id="total_customer_info"><small><%=rejectCount%> </small></span>
                </div>
            </div>
        </div>

        <div class="col-md-3 col-sm-6 col-xs-12">
            <div class="info-box">
                <span class="info-box-icon b_kirmizi"><i class="fa fa-times-circle c_beyaz"></i></span>

                <div class="info-box-content">
                    <span class="info-box-text">HATALI VERI</span>
                    <span class="info-box-number" id="total_revenue_info"><small><%=errorCount%></small></span>
                </div>
            </div>
        </div>

        <div class="col-md-3 col-sm-6 col-xs-12">
            <div class="info-box">
                <span class="info-box-icon b_mor"><i class="fa fa-exclamation-circle c_beyaz"></i></span>

                <div class="info-box-content">
                    <span class="info-box-text">IYS HATA</span>
                    <span class="info-box-number" id="total_page_view_info"><small><%=iysErrorCount%></small></span>
                </div>
            </div>
        </div>
    </div>

</section>

</div>


<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<%--<!-- FLOT CHARTS -->--%>
<%--<script src="assets/js/Flot/jquery.flot.js"></script>--%>
<%--<!-- FLOT RESIZE PLUGIN - allows the chart to redraw when the window is resized -->--%>
<%--<script src="assets/js/Flot/jquery.flot.resize.js"></script>--%>
<%--<!-- FLOT PIE PLUGIN - also used to draw donut charts -->--%>
<%--<script src="assets/js/Flot/jquery.flot.pie.js"></script>--%>
<%--<!-- FLOT CATEGORIES PLUGIN - Used to draw bar charts -->--%>
<%--<script src="assets/js/Flot/jquery.flot.categories.js"></script>--%>


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


<script src="assets/js/Flot2/jquery.flot.js"></script>
<!-- FLOT RESIZE PLUGIN - allows the chart to redraw when the window is resized -->
<script src="assets/js/Flot2/jquery.flot.resize.min.js"></script>
<!-- FLOT PIE PLUGIN - also used to draw donut charts -->
<script src="assets/js/Flot2/jquery.flot.pie.min.js"></script>

<link href="https://unpkg.com/bootstrap-table@1.18.0/dist/bootstrap-table.min.css" rel="stylesheet">

<script src="https://unpkg.com/tableexport.jquery.plugin/tableExport.min.js"></script>
<script src="https://unpkg.com/bootstrap-table@1.18.0/dist/bootstrap-table.min.js"></script>
<script src="https://unpkg.com/bootstrap-table@1.18.0/dist/bootstrap-table-locale-all.min.js"></script>
<script src="https://unpkg.com/bootstrap-table@1.18.0/dist/extensions/export/bootstrap-table-export.min.js"></script>

<style>
    .select,
    #locale {
        width: 100%;
    }
    .like {
        margin-right: 10px;
    }
    #table{
        background-color: white ;
    }
    .fixed-table-toolbar{
        background-color: white ;
    }
    .bootstrap-table{
        margin-left: 20px;
        margin-right: 20px;
    }
</style>
<table
        id="table"
        data-toolbar="#toolbar"
        data-search="true"
        data-show-refresh="true"
        data-show-toggle="true"
        data-show-fullscreen="true"
        data-show-columns="true"
        data-show-columns-toggle-all="true"
        data-detail-view="false"
        data-show-export="false"
        data-click-to-select="true"
        data-detail-formatter="detailFormatter"
        data-minimum-count-columns="2"
        data-show-pagination-switch="false"
        data-pagination="true"
        data-id-field="id"
        data-page-size = "50"
        data-page-list="[50, 100, 500]"
        data-show-footer="true"
        data-url="false">
</table>

<script>
    var $table = $('#table')
    var $remove = $('#remove')
    var selections = []

    function getIdSelections() {
        return $.map($table.bootstrapTable('getSelections'), function (row) {
            return row.id
        })
    }

    function responseHandler(res) {
        $.each(res.rows, function (i, row) {
            row.state = $.inArray(row.id, selections) !== -1
        })
        return res
    }

    function detailFormatter(index, row) {
        var html = []
        $.each(row, function (key, value) {
            html.push('<p><b>' + key + ':</b> ' + value + '</p>')
        })
        return html.join('')
    }

    function operateFormatter(value, row, index) {
        return [
            '<a class="like" href="javascript:void(0)" title="Like">',
            '<i class="fa fa-heart"></i>',
            '</a>  ',
            '<a class="remove" href="javascript:void(0)" title="Remove">',
            '<i class="fa fa-trash"></i>',
            '</a>'
        ].join('')
    }

    window.operateEvents = {
        'click .like': function (e, value, row, index) {
            alert('You click like action, row: ' + JSON.stringify(row))
        },
        'click .remove': function (e, value, row, index) {
            $table.bootstrapTable('remove', {
                field: 'id',
                values: [row.id]
            })
        }
    }

    function totalTextFormatter(data) {
        return 'Total'
    }

    function totalNameFormatter(data) {
        return data.length
    }

    function totalPriceFormatter(data) {
        var field = this.field
        return '$' + data.map(function (row) {
            return +row[field].substring(1)
        }).reduce(function (sum, i) {
            return sum + i
        }, 0)
    }

    function initTable() {

        $table.bootstrapTable('destroy').bootstrapTable({
            locale: 'tr-TR',
            columns: [
                [{
                    title: 'Alici',
                    field: 'recipient',
                    rowspan: 1,
                    align: 'left',
                    valign: 'middle',
                    sortable: true,
                },{
                    title: 'Tip',
                    field: 'type',
                    rowspan: 1,
                    align: 'center',
                    valign: 'middle',
                    sortable: true,
                }, {
                    title: 'Kaynak',
                    field: 'source',
                    rowspan: 1,
                    align: 'center',
                    valign: 'middle',
                    sortable: true,
                }, {
                    title: 'Izin Durumu',
                    field: 'status',
                    rowspan: 1,
                    align: 'center',
                    valign: 'middle',
                    sortable: true,
                },{
                    title: 'Alici Tipi',
                    field: 'recipientType',
                    rowspan: 1,
                    align: 'center',
                    valign: 'middle',
                    sortable: true,
                }, {
                    title: 'Izin Tarihi',
                    field: 'consentDate',
                    rowspan: 1,
                    align: 'center',
                    valign: 'middle',
                    sortable: true,
                },{
                    title: 'Iys Izin Tarihi',
                    field: 'iysCreateDate',
                    rowspan: 1,
                    align: 'center',
                    valign: 'middle',
                    sortable: true,
                },{
                    title: 'Veri Durumu',
                    field: 'statusId',
                    rowspan: 1,
                    align: 'center',
                    valign: 'middle',
                    sortable: true,
                    footerFormatter: totalTextFormatter
                },{
                    title: 'Hata Mesaji',
                    field: 'iysErrorMsg',
                    rowspan: 1,
                    align: 'center',
                    valign: 'left',
                    sortable: true,
                    footerFormatter: totalNameFormatter
                }],
            ],
            data: <%=result%>,
            height: 550
        })


        $table.on('check.bs.table uncheck.bs.table ' +
            'check-all.bs.table uncheck-all.bs.table',
            function () {
                $remove.prop('disabled', !$table.bootstrapTable('getSelections').length)

                // save your data, here just save the current page
                selections = getIdSelections()
                // push or splice the selections if you want to save all data selections
            })
        $table.on('all.bs.table', function (e, name, args) {
            //console.log(name, args)
        })
        $remove.click(function () {
            var ids = getIdSelections()
            $table.bootstrapTable('remove', {
                field: 'id',
                values: ids
            })
            $remove.prop('disabled', true)
        })
    }

    $(function() {
        initTable()

        $('#locale').change(initTable)
    })

    var queryString = window.location.search;
    var urlParams = new URLSearchParams(queryString);

    var date1 = urlParams.get('date1')
    var date2 = urlParams.get('date2')

    if (date1 == null){
        var today = new Date();

        var dateObj = new Date();
        var month = dateObj.getUTCMonth() + 1; //months from 1-12
        var day = dateObj.getUTCDate();
        //var lastWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 6);
        //var frmLastWeek = moment(today).format('YYYY-MM-DD');
        var frmToday = moment(today).format('YYYY-MM-DD');

        //var lastWeek = dateObj.getDate() - 6;
        var year = dateObj.getUTCFullYear();

        newdate = year + "-" + month + "-" + day;
        date1 = frmToday;
        date2 = newdate;
    }

    $('#daterange-btn span').html(date1+ " - " + date2);
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
            location.href = "report_Iys_dashboard.jsp?date1=" + date1 + "&date2=" +date2;
           /* $.ajax({
                type: "GET",
                url: "dashboard.jsp?date1=" + date1 + "&date2=" + date2 + "&cust_id=" +<%=sCustId%>,
                success: function (msg) {
                    location.href = "dashboard.jsp?cust_id=" + <%=sCustId%> + "&date1=" + date1 + "&date2=" +date2;

                },
                error: function (err){
                    console.log(err)
                }
            });
*/

        }
    );
    //$('#daterange-btn span').html('Last 7 Days');
    //$('#daterange').daterangepicker({ startDate: date1, endDate: date2 });
</script>


</body>
</html>

