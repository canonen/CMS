<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.rpt.*,
			java.sql.*,java.net.*,java.io.*,
			java.util.*,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ include file="functions.jsp"%>
<%! static Logger logger = null;%>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

    if(!can.bRead)
    {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    String	sCampID	= request.getParameter("Q");
    String	sCache 	= request.getParameter("Z");
    sCache = ("1".equals(sCache))?sCache:"0";

    boolean DURUM=false;
    String Link_TR="";
    String 	showTrackerRptTR="";


    ConnectionPool	cp		= null;
    Connection		conn	= null;
    Statement		stmt	= null;
    ResultSet		rs		= null;

    String reportName = "";
    String reportDate = "";

    String tReceived = "";
    String tRead = "";
    String tClicks = "";
    int readPerct =0;
    int clickPerct =0;

    String sLinkID =  "";
    String sCurCampID =  "";
    String sHref =  "";
    String sDistClicks = "";
    String sDistClickPct = "";
    String sTotClicks =  "";
    String sTotClickPct="";
    String sMbsReportDetailsUrl="";
    MbsRevenueReport mbsRevenueReport = new MbsRevenueReport();
    StringBuilder RETURN_TR = new StringBuilder();

    boolean displayPurchOnChart = false;
    try
    {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        int nPos = 0;
        int numRecs = 0;

        //Customize deliveryTracker report Feature (part of release 5.9)
        int showTrackerRpt = 0;
        boolean bFeat = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);
        if (bFeat)
        {
            int nCount = getSeedListCount(stmt,cust.s_cust_id, sCampID);
            if (nCount > 0)
                showTrackerRpt = 1;
        }
        // end release 5.9

        if ((sCampID != null))
        {
            String sSql =
                    " SELECT count(camp_id)" +
                            " FROM cque_campaign c with(nolock)" +
                            " WHERE c.cust_id = " + cust.s_cust_id +
                            " AND c.camp_id = " + sCampID;

            rs = stmt.executeQuery(sSql);
            if(rs.next()) numRecs = rs.getInt(1);
            rs.close();

            // === === ===

            sSql =
                    " SELECT count(*)" +
                            " FROM crpt_camp_pos with(nolock)" +
                            " WHERE camp_id IN ("+sCampID+")";

            rs = stmt.executeQuery(sSql);
            if ( rs.next() ) nPos = rs.getInt(1);
            rs.close();

            // === === ===

            sSql =
                    " EXEC usp_crpt_camp_list" +
                            "  @camp_id="+sCampID+
                            ", @cust_id="+cust.s_cust_id+
                            ", @cache=0";

            rs = stmt.executeQuery(sSql);

            while( rs.next() )
            {
                byte[] bVal = rs.getBytes("CampName");
                reportName = (bVal!=null?new String(bVal,"UTF-8"):"");
                reportDate = rs.getString("StartDate");
            }
            rs.close();
        }

        if ((sCampID == null) || ("".equals(sCampID)) || (numRecs < 1))
        {
            DURUM=true;
        }
        else
        {
            //  <!-- Main container start -->

            //	<!-- Revenue Report Start -->


            System.out.println("camp_idd2222 "+mbsRevenueReport.s_camp_id);
            boolean den = mbsRevenueReport.retrieve() > 0;
            System.out.println("RETRİEVEEE ::"+den);
            mbsRevenueReport.s_camp_id = sCampID;
            System.out.println("camp_idd333333 "+mbsRevenueReport.s_camp_id);
            System.out.println("displayPurchOnChart111 ::" +displayPurchOnChart);
            if(mbsRevenueReport.retrieve() > 0)
            {
                displayPurchOnChart = true;


                Service service = null;
                Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
                service = (Service) services.get(0);
                sMbsReportDetailsUrl =
                        "http://" + service.getURL().getHost() + "/rrcp/imc/rpt/mbs_revenue_report_details.jsp" +
                                "?cust_id=" + cust.s_cust_id + "&camp_id=" + sCampID;


                String campSummarySql = "select * from crpt_camp_summary with(nolock) where camp_id = " + sCampID;
                rs = stmt.executeQuery(campSummarySql);
                while(rs.next())
                {
                    tReceived = rs.getString(7);
                    tRead = rs.getString(8);
                    tClicks = rs.getString(10);
                }
                rs.close();

                String xmlData = "<graph baseFontSize='12' isSliced='1' decimalPrecision='0'>";
                if(displayPurchOnChart)
                {
                    //int purchAmount = Math.round(Integer.parseInt(mbsRevenueReport.s_total));
                    //String purchAmountStr = Integer.toString(purchAmount);
                    //xmlData += "<set name='Purchases' value='"+HtmlUtil.escape(purchAmountStr)+"' />";
                }

                xmlData += "<set name='Clicks' value='"+tClicks+"' /><set name='Reads' value='"+tRead+"' /><set name='Received' value='"+tReceived+"' /></graph>";

                readPerct = ((Integer.parseInt(tRead) * 100) / Integer.parseInt(tReceived));
                clickPerct = ((Integer.parseInt(tClicks) * 100) / Integer.parseInt(tReceived));

            }
            System.out.println("Retrieve Result: " + mbsRevenueReport.retrieve());
            System.out.println("Purchasers: " + mbsRevenueReport.s_purchasers);
            System.out.println("Delivered: " + mbsRevenueReport.s_delivered);
            System.out.println("Purchases: " + mbsRevenueReport.s_purchases);
            System.out.println("Total: " + mbsRevenueReport.s_total);
            System.out.println("displayPurchOnChart222 ::" +displayPurchOnChart);
            //	<!-- Revenue Report End -->



            int iCount = 0;
            String sClassAppend = "_other";

            String sSql =
                    " EXEC usp_crpt_camp_pos_list" +
                            " @camp_id = " + sCampID +
                            ",@cache = "+sCache;

            rs = stmt.executeQuery(sSql);

            while(rs.next())
            {
                if (iCount % 2 != 0) sClassAppend = "_other";
                else sClassAppend = "";

                iCount++;

                sLinkID = rs.getString(1);
                sCurCampID = rs.getString(2);
                sHref = rs.getString(3);
                sDistClicks = rs.getString(4);
                sDistClickPct = rs.getString(5);
                sTotClicks = rs.getString(6);
                sTotClickPct = rs.getString(7);



                String TR=	 "<tr> <td class='list_link'>"
                        +"	<a class='tablelink' href='report_track_connect.jsp?Q="+sCurCampID+"&amp;P="+sLinkID+"&amp;Z="+sCache+"'>"
                        + sHref
                        +"	</a>"
                        +"</td>"
                        +"	<td class='list_row'>"
                        +"	<b>"+sDistClicks+"</b> visits "
                        +"	<div style='position:relative;margin-top:5px;width:100%;height:25px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;'>"
                        +"		<div  style='background-color:#59C8E6 ;height:23px;width:"+sDistClickPct+"%'>"
                        +"						<span style='position:absolute;top:1;height:23px;right:2px;font-size:12px;'>"+sDistClickPct+"%</span> "
                        +"					</div>"
                        +"				</div>"
                        +"</td>	"
                        +"	<td class='list_row'> "
                        +"	<b>"+sTotClicks+"</b> visits  "
                        +"	<div style='position:relative;margin-top:5px;width:100%;height:25px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;'> "
                        +"				<div  style='background-color:#59C8E6 ;height:23px;width:"+sTotClickPct+"%'> "
                        +"					<span style='position:absolute;top:1;height:23px;right:2px;font-size:12px;'>"+sTotClickPct+"%</span> "
                        +"	</div>"
                        +"	</div>"
                        +"	</td>"
                        +"</tr>";

                RETURN_TR.append(TR);

            }
            rs.close();


            //	<!-- links end -->

            //<!-- Main container end -->


        }
    }
    catch (Exception ex) { throw ex; }
    finally
    {
        try
        {
            if( stmt  != null ) stmt.close();
            if( conn  != null ) cp.free(conn);
        }
        catch (SQLException ex) { }
    }
%>


<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title> Report Track</title>
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
    <link rel="stylesheet" href="assets/css/bootstrap.min.css">

    <link rel="stylesheet" href="assets/css/font-awesome.min.css">

    <link rel="stylesheet" href="assets/css/ionicons.min.css">

    <link rel="stylesheet" href="assets/css/AdminLTE.css">
    <link rel="stylesheet" href="assets/css/Style.css">

    <link rel="stylesheet" href="assets/css/skin-blue.min.css">
    <link rel="stylesheet" href="assets/css/DataTable/dataTables.bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->

    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">

    <script type="text/javascript">

        function pop_up_win(url) {
            windowName = 'report_results_window';
            windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=600, width=700';
            ReportWin = window.open(url, windowName, windowFeatures);
        }
    </script>
    <style>
        td.list_row {
            font-size: 11px;
            color: #454545;

        }
        td.list_link {  padding-top:15px !important; }

        .tablelink{
            font-size: 12px;
            padding-top:8px;
            color: #59C8E6;
            text-decoration: none;
            font-weight:bold;
            line-height:24px;
        }
        .tablelink:hover{
            text-decoration: underline;
            color: #59C8E6;

        }

    </style>
</head>

<body class="hold-transition">
<% if(DURUM){	%>

<div class="wrapper" style="margin-left:20px;margin-right:20px;">
    <div class="row">
        <div class="col-md-4" ></div>
        <div class="col-md-4" >
            <div align="center" class="alert alert-warning alert-dismissible">
                <h4><i class="icon fa fa-warning"></i> Warning!</h4>
                No Campaign for that ID
            </div>
        </div>
        <div class="col-md-4" ></div>
    </div>
</div>
<% }else{ %>

<div class="wrapper" style="margin-left:20px;margin-right:20px;">

    <div class="row">
        <div class="col-md-12">
            <div class="nav-tabs-custom" style="margin-bottom:5px">
                <ul class="nav nav-tabs">
                    <li><a href="report_object.jsp?id=<%=sCampID%>" >Campaign Results</a></li>
                    <li><a href="report_cache_list.jsp?Q=<%=sCampID%>" >Demographic Or Time Report</a></li>
                    <li><a href="report_time.jsp?Q=<%=sCampID%>">Activity vs. Time Report</a></li>
                    <li class="active"><a href="javascript:void(null);"  >RevoTrack Results</a></li>
                    <li><a href="report_heatmap.jsp?Q=<%=sCampID%>" >HeatMap</a></li>
                </ul>
            </div>
        </div>
    </div>

</div>

<section class="content">
    <div class="row">

        <div class="col-md-12" >
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Report</h3>

                </div>

                <div class="box-body">
                    <%=reportName%>
                </div>
            </div><!-- /.box box-primary -->
        </div><!-- /.col-md-12 End -->
            <% if (displayPurchOnChart) {%>
        <div class="col-md-4" >
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Revenue Summary</h3>
                </div>
                <div class="box-body" style="background-color:#f1f1f1">
                    <div class="row">

                        <div class="col-md-12" >
                            <table class="table table-bordered  " style="background-color:#fff">
                                <tbody>
                                <tr>
                                    <td width="30%" >Received</td>
                                    <td width="30%" align="right" ><b><%=tReceived%></b></td>
                                    <td width="30%">
                                        <div class="progress progress-xs">
                                            <div class="progress-bar b_mor" style="width: 100%"></div>
                                        </div>
                                    </td>
                                    <td width="10%"><span class="label b_mor">100%</span></td>
                                </tr>
                                <tr>
                                    <td>Read</td>
                                    <td  align="right" ><b><%=tRead%></b></td>
                                    <td>
                                        <div class="progress progress-xs">
                                            <div class="progress-bar b_mavi" style="width: <%=readPerct+0.1%>%"></div>
                                        </div>
                                    </td>
                                    <td><span class="label b_mavi"><%=readPerct+0.1%>%</span></td>
                                </tr>
                                <tr>
                                    <td>Click</td>
                                    <td align="right" ><b><%=tClicks%></b></td>
                                    <td>
                                        <div class="progress progress-xs">
                                            <div class="progress-bar b_yesil" style="width: <%=clickPerct+0.1%>%"></div>
                                        </div>
                                    </td>
                                    <td><span class="label b_yesil"><%=clickPerct+0.1%>%</span></td>
                                </tr>
                                <tr>
                                    <td>Purchasers</td>
                                    <td align="right" >
                                        <b>

                                            <a href="javascript:pop_up_win('<%=sMbsReportDetailsUrl%>');" class="c_turuncu" style="text-decoration:underline">
                                                <%=HtmlUtil.escape(mbsRevenueReport.s_purchasers)%>
                                            </a>
                                        </b></td>
                                    <td>
                                        <div class="progress progress-xs">

                                            <div class="progress-bar b_turuncu" style="width:<%=HtmlUtil.escape(mbsRevenueReport.s_delivered)%>%"></div>
                                        </div>
                                    </td>
                                    <td><span class="label b_turuncu"><%=HtmlUtil.escape(mbsRevenueReport.s_delivered)%></span></td>
                                </tr>

                                <tr>
                                    <td>Purchases</td>
                                    <td align="right" ><b><%=HtmlUtil.escape(mbsRevenueReport.s_purchases)%></b></td>
                                    <td> </td>
                                    <td> </td>
                                </tr>
                                <tr>
                                    <td>Revenue</td>
                                    <td align="right" >
                                        <b>
                                            <a href="javascript:pop_up_win('<%=sMbsReportDetailsUrl%>');" style="color:black;text-decoration:underline" >
                                                <%=HtmlUtil.escape(mbsRevenueReport.s_total)%>
                                            </a>
                                        </b>
                                    </td>
                                    <td> </td>
                                    <td> </td>
                                </tr>
                                </tbody></table>

                        </div>
                        <div class="col-md-12" >

                            <table class="table table-bordered" style="background-color:#fff">
                                <tbody>
                                <tr>
                                    <td>
                                        <div id="chart-container">FusionCharts XT will load here!</div>
                                    </td>

                                </tr>

                                </tbody>
                            </table>
                        </div>


                    </div>
                </div>
            </div><!-- /.box box-primary -->
        </div><!-- /.col-md-4 End -->

        <div class="col-md-8" >
            <%	}else{%>
            <div class="col-md-12" >
                <%} %>
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title">Tracked Web Pages</h3>
                    </div>
                    <div class="box-body" style="background-color:#f1f1f1">
                        <div class="col-md-12" style="background-color:#fff;padding:10px;" >

                            <table id="example1" class="table no-margin table-striped" >
                                <thead>
                                <tr>
                                    <th width="40%">Page URL</th>
                                    <th width="30%">Distinct Visits</th>
                                    <th width="30%">Total Visits</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%=RETURN_TR%>

                                </tbody>

                            </table>

                        </div>

                    </div>
                </div><!-- /.box box-primary -->
            </div><!-- /.col-md-8 End -->


        </div><!-- /.row END -->

</section>



<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/bootstrap.min.js"></script>
<script src="assets/js/adminlte.min.js"></script>
<!-- FastClick -->
<script src="assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="assets/js/demo.js"></script>

<script src="assets/js/DataTable/jquery.dataTables.min.js"></script>
<script src="assets/js/DataTable/dataTables.bootstrap.min.js"></script>
<script src="assets/js/DataTable/jquery.slimscroll.min.js"></script>
<script type="text/javascript" src="assets/js/FushionCharts/fusioncharts.js"></script>
<script type="text/javascript" src="assets/js/FushionCharts/fusioncharts.theme.fint.js?cacheBust=56"></script>

<script>
    $(function () {
        $('#example1').DataTable({

            'paging'      : true,
            'lengthChange': false,
            'searching'   : false,
            'ordering'    : false,
            'info'        : true,
            'autoWidth'   : false
        })

    })
</script>

<script type="text/javascript">
    FusionCharts.ready(function () {
        var conversionChart = new FusionCharts({
            type: 'funnel',
            renderAt: 'chart-container',
            width: '100%',
            dataFormat: 'json',
            dataSource: {
                "chart": {

                    "decimals": "1",
                    "is2D": "1",
                    "streamlinedData": "0",
                    "showLegend": "1",
                    "showLabels": "0",
                    "theme": "fint",
                    "palettecolors":"59C8E6,84C446,FAA926",
                    "isHollow": "1"

                },
                "data": [  {
                    "label": "Read",
                    "value": "<%=tRead%>"
                }, {
                    "label": "Clicks",
                    "value": "<%=tClicks%>"
                }, {
                    "label": "Purchase",
                    "value": "<%=HtmlUtil.escape(mbsRevenueReport.s_purchasers)%>"
                }
                ]
            }
        });

        conversionChart.render();
    });
</script>
<%}%>
</body>
</html>
















