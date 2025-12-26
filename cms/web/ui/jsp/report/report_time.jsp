<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.net.*,java.io.*,java.text.*,java.util.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../validator.jsp"%>
<%@ include file="functions.jsp"%>
	
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

//CY 08042013
//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

boolean durum=true;
String graph_cat 	= "";
String graph_val1 	= "";
String graph_val2 	= "";
String graph_val3 	= "";
String graph_val4 	= "";

String reportName = "";

String dgraph_cat 	= "";
String dgraph_val1 	= "";
String dgraph_val2 	= "";
String dgraph_val3 	= "";

int dCount=0;
String	CampID="";
int showTrackerRpt = 0;
int nPos = 0;

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_list.jsp");
	stmt = conn.createStatement();

	CampID= request.getParameter("Q");
	int		numRecs		= 0;

	String sId			= null;
	String sDate		= null;
	String sSent		= null;
	String sReads		= null;
	String sClicks		= null;
	String sUnsubs		= null;
	String sReadPct		= null;
	String sClickPct	= null;
	String sUnsubPct	= null;



String reads2="";
String clicks2="";
String unsub2="";





String reportDate = "";
byte[] bVal = new byte[255];
	
//Customize deliveryTracter report Feature (part of release 5.9)
	
	boolean bFeat = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);
	if (bFeat)
	{
 		int nCount = getSeedListCount(stmt,cust.s_cust_id, CampID);
		if (nCount > 0)
			showTrackerRpt = 1;
	}
// end (part of release 5.9)
	
if ((CampID != null) && (CampID != ""))
{
	rs = stmt.executeQuery("SELECT count(camp_id) FROM cque_campaign c"
			+ " WHERE c.cust_id="+cust.s_cust_id+" and c.camp_id="+CampID);
			
	while(rs.next())
	{
		numRecs = rs.getInt(1);
	}
	
	rs.close();
	
	//KU 2004-02-20
	rs = stmt.executeQuery("SELECT count(*) FROM crpt_camp_pos WHERE camp_id IN ("+CampID+")");
	
	if ( rs.next() )
	{
		nPos = rs.getInt(1);
	}
	rs.close();
	
	rs = stmt.executeQuery("Exec usp_crpt_camp_list @camp_id="+CampID+", @cust_id="+cust.s_cust_id+", @cache=0");
	
	while( rs.next() )
	{
		bVal = rs.getBytes("CampName");
		reportName = (bVal!=null?new String(bVal,"UTF-8"):"");
		reportDate = rs.getString("StartDate");
	}
	rs.close();
}

if ((CampID == null) || (CampID == "") || (numRecs < 1))
{ durum=false;}
else
{

						rs = stmt.executeQuery("SELECT  hour_id+1, convert(char(16),hour_date,120), " +
												"sent, reads, convert(decimal(5,1),round(100*read_pct,1)), " +
												"clicks, convert(decimal(5,1),round(100*click_pct,1)), " +
												"unsubs, convert(decimal(5,1),round(100*unsub_pct,1)) " +
												"FROM crpt_camp_hour WHERE camp_id = "+CampID+
												" ORDER BY hour_id");
						
						int iCount 			= 0;

			
							while(rs.next()){
							
							sId 		= rs.getString(1);
							sDate 		= rs.getString(2);
							sSent 		= rs.getString(3);
							sReads 		= rs.getString(4);
							sReadPct 	= rs.getString(5);
							sClicks 	= rs.getString(6);
							sClickPct 	= rs.getString(7);
							sUnsubs 	= rs.getString(8);
							sUnsubPct 	= rs.getString(9);
							
							String sDateTime	= sDate.substring(11, 16);
							String sDateDate	= sDate.substring(0, 10);
							
							String sDateStr = sDate;
							sDate = sDateDate + "<br>" + sDateTime + "<br>Sent: " + sSent; 
							
							graph_cat 	+= "{\"label\":\""+sDate+"\"},";
							graph_val1 	+= "{\"value\":\""+sReads+"\"},";
							graph_val2 	+= "{\"value\":\""+sClicks+"\"},";
							graph_val3 	+= "{\"value\":\""+sUnsubs+"\"},";
							graph_val4 	+= "{\"value\":\""+sSent+"\"},";
			
							iCount++;			
						}
			
						int graph_catCount 	= graph_cat.length();
						int graph_val1Count = graph_val1.length();
						int graph_val2Count = graph_val2.length();
						int graph_val3Count = graph_val3.length();
						int graph_val4Count = graph_val4.length();
						
						graph_cat 	= graph_cat.substring(0, graph_catCount - 1);
						graph_val1 	= graph_val1.substring(0, graph_val1Count - 1);
						graph_val2 	= graph_val2.substring(0, graph_val2Count - 1);
						graph_val3 	= graph_val3.substring(0, graph_val3Count - 1);
						graph_val4 	= graph_val4.substring(0, graph_val4Count - 1);
						
						rs.close();
						
						 
					rs = stmt.executeQuery("SELECT  day_id+1, convert(char(10),day_date,120), " +
							"sent, reads, convert(decimal(5,1),round(100*read_pct,1)), " +
							"clicks, convert(decimal(5,1),round(100*click_pct,1)), " +
							"unsubs, convert(decimal(5,1),round(100*unsub_pct,1)) "+
							"FROM crpt_camp_day WHERE camp_id = "+CampID+
							" ORDER BY day_id");
					
                  
                          while(rs.next()){
						
						sId 		= rs.getString(1);
						sDate 		= rs.getString(2);
						sSent 		= rs.getString(3);
						sReads 		= rs.getString(4);
						sReadPct 	= rs.getString(5);
						sClicks 	= rs.getString(6);
						sClickPct 	= rs.getString(7);
						sUnsubs 	= rs.getString(8);
						sUnsubPct 	= rs.getString(9);
		
						dgraph_cat 		+= "{\"label\":\""+sDate+"\"},";
						
						dgraph_val1 	+= "{\"value\":\""+sReads+"\"},";
						dgraph_val2 	+= "{\"value\":\""+sClicks+"\"},";
						dgraph_val3 	+= "{\"value\":\""+sUnsubs+"\"},";
		
						dCount++;			
					} 
		
					int dgraph_catCount 	= dgraph_cat.length();
					int dgraph_val1Count 	= dgraph_val1.length();
					int dgraph_val2Count 	= dgraph_val2.length();
					int dgraph_val3Count 	= dgraph_val3.length();
					
					dgraph_cat 		= dgraph_cat.substring(0, dgraph_catCount - 1);
					dgraph_val1 	= dgraph_val1.substring(0, dgraph_val1Count - 1);
					dgraph_val2 	= dgraph_val2.substring(0, dgraph_val2Count - 1);
					dgraph_val3 	= dgraph_val3.substring(0, dgraph_val3Count - 1);
				
		
	
			
					 
}
} catch (Exception ex) {
	ErrLog.put(this, ex, "Error: "+ex.getMessage(),out,1);	
} finally {
	try {
		if( stmt  != null ) stmt.close(); 
		if( conn  != null ) cp.free(conn);
	} catch (SQLException ex) { } 
}
%>


<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Revotas Report</title> 
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
</head>
<body class="hold-transition">
<% if(!durum){%>
	     
	     <div class="row">
	      <div class="col-sm-4"></div>
	      
	       <div class="col-sm-4">
	       	<div align="center"  class="alert alert-warning alert-dismissible">
               
                <h4><i class="icon fa fa-warning"></i> Warning!</h4>
                    No Campaign for that ID
              </div>	
	       </div>
	     
	       <div class="col-sm-4"></div>
	     </div>
	     
		
<%} else{ %>

          <!-- Custom Tabs -->
          <div class="nav-tabs-custom">
            <ul class="nav nav-tabs">
            <%if (bStandardUI) { %>
              <li class=""><a href="report_object.jsp?id=<%=CampID%>" >Campaign Results</a></li>
              <li class="active"><a href="javascript:void(null);"  >Activity vs. Time Report</a></li>
              <%}%>
              <%if (!bStandardUI) { %>
              <li class=""><a href="report_object.jsp?id=<%=CampID%>" >Campaign Results</a></li>
              <li class=""><a href="report_cache_list.jsp?Q=<%=CampID%>" >Demographic Or Time Report</a></li>
              <li class="active"><a href="javascript:void(null);"  >Activity vs. Time Report</a></li>
              
              <%}%>
              
              <% if(showTrackerRpt == 1){ %>
                <li class=""><a href="eTrackerReport.jsp?Q=<%=CampID%>" >Delivery Tracking</a></li>
              
              <% }%>
              <% if(nPos > 0){%>
              <li class=""><a href="report_track.jsp?Q=<%=CampID%>&#38;Z=0" >RevoTrack Results</a></li>
              <%}%>
            
              <li class=""><a href="report_heatmap.jsp?Q=<%=CampID%>" >HeatMap</a></li> 
            </ul>
            
          </div> 
          
          
      
 	
<div class="wrapper" style="margin-left:20px;margin-right:20px;">
 	 

 	 
			<section class="content-header"><br/>
				<h1>
					Report:
					<small> <% out.print(reportName); %></small>
				</h1> 
					<br/><br/>
	 		</section>
 

 <div class="row">
 		<div class="col-md-12">
						<div class="box box-primary">
							<div class="box-header">
								<h3 class="box-title">Activity By Hour: (For the first week of the Campaign)</h3>
								
							</div>
							<div class="box-body">
								 <div id="chart-container">Activity By Hour Reports load here!</div>
							</div> 
						</div>
		 </div>
		 <!-- col-md-12 END !-->
 	 
 </div>
<!-- row END !-->

 
<div class="row">
 		<div class="col-md-12">
						<div class="box box-primary">
							<div class="box-header">
								<h3 class="box-title">Activity By Day</h3>
								
							</div>
							<div class="box-body">
						
								<div id="chart-container2">Activity By Day Reports load here!</div>
							</div> 
						</div>
		 </div>
		 <!-- col-md-12 END !-->
 	 
 </div>
<!-- row END !--> 
</div>


<!-- wrapper END !-->

 
<%}  %>



<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/bootstrap.min.js"></script>
<script src="assets/js/adminlte.min.js"></script>
 <!-- FastClick -->
<script src="assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="assets/js/demo.js"></script>
<script src="assets/js/FushionCharts/fusioncharts.js"></script>

<script src="assets/js/FushionCharts/fusioncharts.theme.fint.js"></script>

<script type="text/javascript">

    FusionCharts.ready(function(){
    var fusioncharts = new FusionCharts({
    type: 'scrollColumn2d',
    renderAt: 'chart-container',
    width: '98%',
    height: '300',
    dataFormat: 'json',
    dataSource: {
        "chart": {
           
            "numberPrefix": "",
            "plotFillAlpha": "80",

            //Cosmetics
            "paletteColors": "#0075c2,#1aaf5d",
            "baseFontColor": "#333333",
            "baseFont": "Helvetica Neue,Arial",
            "captionFontSize": "14",
            "subcaptionFontSize": "14",
            "subcaptionFontBold": "0",
            "showBorder": "0",
            "bgColor": "#ffffff",
            "showShadow": "0",
            "canvasBgColor": "#ffffff",
            "canvasBorderAlpha": "0",
            "divlineAlpha": "100",
            "divlineColor": "#999999",
            "divlineThickness": "1",
            "divLineIsDashed": "1",
            "divLineDashLen": "1",
            "divLineGapLen": "1",
            "usePlotGradientColor": "0",
            "showplotborder": "0",
            "valueFontColor": "#ffffff",
            "placeValuesInside": "1",
            "showHoverEffect": "1",
            "rotateValues": "1",
            "showXAxisLine": "1",
            "xAxisLineThickness": "1",
            "xAxisLineColor": "#999999",
            "showAlternateHGridColor": "0",
            "legendBgAlpha": "0",
            "legendBorderAlpha": "0",
            "legendShadow": "0",
            "legendItemFontSize": "10",
            "legendItemFontColor": "#666666",
            
            
        },
        "categories": [{
            "category": [ <% out.print(graph_cat); %> ] 
        }],
        "dataset": [{
            "seriesname": "Reads",
            "color": "4169e1",
            "data": [<% out.print(graph_val1); %>  ]
        }, {
            "seriesname": "Clicks",
            "color": "228b22",
            "data": [<% out.print(graph_val2); %>  ]
        }, {
            "seriesname": "Unsub",
            "color": "FF0000",
            "data": [ <% out.print(graph_val3); %> ]
        }]

    }
}
);
    fusioncharts.render();
    });
</script>

<script type="text/javascript">
    FusionCharts.ready(function(){
    var fusioncharts = new FusionCharts({

    type: 'msbar2d',
    renderAt: 'chart-container2',
    width: '98%',
    height: "<%=120+dCount*50%>",
    dataFormat: 'json',
    dataSource: {
        "chart": {
          
            "paletteColors": "#0075c2,#1aaf5d",
            "bgColor": "#ffffff",
            "showBorder": "0",
            "showHoverEffect": "1",
            "showCanvasBorder": "0",
            "usePlotGradientColor": "0",
            "plotBorderAlpha": "10",
            "legendBorderAlpha": "0",
            "legendShadow": "0",
            "placevaluesInside": "1",
            "valueFontColor": "#ffffff",
            "showXAxisLine": "1",
            "xAxisLineColor": "#999999",
            "divlineColor": "#999999",
            "divLineIsDashed": "1",
            "showAlternateVGridColor": "0",
            "subcaptionFontBold": "0",
            "subcaptionFontSize": "14"
        },
        "categories": [{
        	"category": [ <% out.print(dgraph_cat); %> ] 
        }],
        "dataset": [{
                "seriesname": "Reads",
                "color": "4169e1",
                "data": [<% out.print(dgraph_val1); %>  ]
                
            },
            {
                "seriesname": "Clicks",
                "color": "228b22",
                "data":[<% out.print(dgraph_val2); %>  ]
            },
            {
                "seriesname": "Unsub",
                "color": "FF0000",
                "data":[<% out.print(dgraph_val3); %>  ]
            }
        ]
   
    }
});
    fusioncharts.render();
    });
</script>

</body>
</html>

