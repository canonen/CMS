<%@ page language="java"
         import="java.net.*,
	   		com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
            com.britemoon.*,
			com.britemoon.rcp.*,
			com.britemoon.rcp.imc.*,
			com.britemoon.rcp.que.*,
			java.sql.*,
			java.io.*,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
         contentType="text/html;charset=UTF-8"%>
<%! static Logger logger = null;%>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%
    String custid=cust.s_cust_id;

    if(custid==null)
        return;

// Get Connection
    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection connm = null;
    boolean committed = false;

    StringBuilder TABLE_TR = new StringBuilder();

    try {
        cp = ConnectionPool.getInstance();
        connm = cp.getConnection(this);
        connm.setAutoCommit(false); // Select için şart değil ama genel standart

        String query = "SELECT task_name, start_date, finish_date, record_count, status FROM ccps_attribute_xml_summary WHERE cust_id = ? ORDER BY finish_date DESC";
        PreparedStatement pstmt = connm.prepareStatement(query);
        pstmt.setString(1, custid);
        rs = pstmt.executeQuery();

        for (int i = 0; rs.next(); i++) {
            String tr = "<tr id=" + i + ">"
                    + "<td width='120px;'>" + rs.getString(1) + "</td>"
                    + "<td width='40px;'>" + rs.getString(2) + "</td>"
                    + "<td width='40px;'>" + rs.getString(3) + "</td>"
                    + "<td width='40px;'>" + rs.getString(4) + "</td>"
                    + "<td width='40px;'>" + rs.getString(5) + "</td>"
                    + "</tr>";
            TABLE_TR.append(tr);
        }
        committed = true;

    } catch (Exception e) {
        logger.error("XML Parse History hatası", e);
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
        } catch (SQLException ignore) {}

        if (connm != null && cp != null) {
            try {
                if (committed) {
                    cp.free(connm); // başarılıysa iade
                } else {
                    connm.close(); // başarısızsa iade etmeden kapat
                }
            } catch (Exception e) {
                logger.warn("Connection kapanırken hata", e);
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>XML Parse History</title>
    <!-- Tell the browser to be responsive to screen width -->
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">

    <link rel="stylesheet" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">
    <link rel="stylesheet" href="assets/css/font-awesome.min.css">

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
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">

    <style>
        .table_status{
            font-size: 12px;
            line-height:32px;
            text-align: center;
            color: #59C8E6 ;
        }
        td{font-size: 12px;
            vertical-align:middle !important;
            border:1px solid #f2f2f2 !important;
        }

        th{   font-size: 12px;
            background-color:#f2f2f2 ;
            border:1px solid #ddd !important;
            vertical-align:middle !important;
        }
    </style>
</head>
<body class="hold-transition" style="background-color:#f1f1f1;">

<section class="content-header" >
    <div class="box box-solid">
        <div class="box-header with-border">
            <div class="col-md-6"><h3>XML Parsing History</h3></div>


        </div>
    </div>

</section>


<section class="content" style="margin-left:20px ;margin-right:20px;">





    <div class="row"  >
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Task List </h3>
            </div>
            <div class="box-body">
                <table id="example1" class="table table-bordered table-striped table-hover" >
                    <thead>
                    <tr>
                        <th>Task Name</th>
                        <th>Start Date</th>
                        <th>Finish Date</th>
                        <th>Record Count</th>
                        <th>Status</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%=TABLE_TR%>
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

    $(document).on("click",".refresh", function(e) {
        e.preventDefault();
        location.reload();
    });
    $(function () {


        $('#example1').DataTable({
            'paging'      : true,
            'lengthChange': true,
            'searching'   : true,
            'ordering'    : true,
            'info'        : true,
            'autoWidth'   : false,
            "order": [[ 2, "desc" ]]


        })
    })

</script>

</body>
</html>

