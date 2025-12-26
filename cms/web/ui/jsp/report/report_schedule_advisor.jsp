<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.rcp.*, 
			com.britemoon.rcp.que.*, 
			java.io.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*, 
			javax.mail.*, 
			org.apache.log4j.Logger,
			com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			com.britemoon.rcp.imc.*,
			java.util.Calendar"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%


String sCustId =  cust.s_cust_id;

Campaign camp = new Campaign(); 
camp.s_cust_id = sCustId; 

 
			ConnectionPool	cp		= null;
			Connection 		conn	= null;
			Statement		stmt	= null;
			ResultSet 		rs		=null;
StringBuilder ReportDay_TR = new StringBuilder();
StringBuilder ReportDay_Chart = new StringBuilder();

StringBuilder Report_TR = new StringBuilder();
StringBuilder ReportOpen_Chart = new StringBuilder();
StringBuilder ReportClick_Chart = new StringBuilder();


try {

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();
 
    String sSql_ard	 = "select opens2,days,days_num from ccps_schedule_advisor_day_report where cust_id = " + sCustId + " order by days_num";
	rs = stmt.executeQuery(sSql_ard);

			  
	String Opens			=""; 
	String Days				="";
	String Days_Num			="";


	while (rs.next())
	{
		Opens 		= rs.getString(1);
		Days		= rs.getString(2);
		Days_Num	= rs.getString(3);

		ReportDay_TR.append("<tr><td>"+Opens+"</td><td>"+Days+"</td><td>"+Days_Num+"</td></tr>");
		ReportDay_Chart.append("['"+ Days +"',"+Opens+"],");

	}

	rs.close();

	String sSql ="select hours,opens1,clicks,pct from ccps_schedule_advisor_report where cust_id = " + sCustId + " order by hours";
	rs = stmt.executeQuery(sSql);

	String Hours				="";
	String Open					="";
	String Clicks				="";
	String Pct					="";

	while (rs.next())
	{
		Hours 		= rs.getString(1);
		Open		= rs.getString(2);
		Clicks	= rs.getString(3);
		Pct	= rs.getString(4);

		Report_TR.append("<tr><td>"+Hours+"</td><td>"+Open+"</td><td>"+Clicks+"</td><td>"+Pct+"</td></tr>");
		ReportOpen_Chart.append("['"+ Hours +"',"+Open+"],");
		ReportClick_Chart.append("['"+ Hours +"',"+Clicks+"],");

	}

}
catch(Exception ex)
{ 
	logger.error("Exception: ", ex);
	ex.printStackTrace(new PrintWriter(out));
}
finally
{
	if (stmt!=null) stmt.close();
	if (conn != null) cp.free(conn);
}
		  
%>
 
   <!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Campaign Schedule Advisor</title> 
  <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
  <link rel="stylesheet" href="assets/css/bootstrap.min.css">
 
  <link rel="stylesheet" href="assets/css/font-awesome.min.css">
 
  <link rel="stylesheet" href="assets/css/ionicons.min.css">
 
  <link rel="stylesheet" href="assets/css/AdminLTE.css">
  <link rel="stylesheet" href="assets/css/Style.css">
 
  <link rel="stylesheet" href="assets/css/skin-blue.min.css">
  <link rel="stylesheet" href="assets/css/DataTable/dataTables.bootstrap.min.css">
 
  <!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->

  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">
</head>
<body class="hold-transition">
 
 <div class="wrapper" style="margin-left:20px;margin-right:20px;">
 	 
				<section class="content-header">
				<h1>
					Campaign Schedule Advisor
					<small>Best Open/Click times for your Campaigns</small>
				</h1>
				 
				</section>
	
		 <br/>
			<div class="row">
						<div class="col-md-4">
							<div class="box box-primary">	
										<div class="box-header with-border">
										<i class="fa fa-bar-chart-o"></i>

										<h3 class="box-title">Best Day of the Week to Schedule</h3>
 										</div>
										<div class="box-body">
												<table id="example2" class="table table-bordered table-hover">
													<thead>
													<tr>
														<th>Opens</th>
														<th>Days</th>
														<th>Days Num</th>
													</tr>
													</thead>
													<tbody>
														<% out.print(ReportDay_TR); %>
													</tbody>
												</table>
										</div>
							</div> <!-- box end !-->
						</div> 	<!-- md-4 end !-->
						<div class="col-md-8">
						 
								<div class="box box-primary">
									<div class="box-header with-border">
										<i class="fa fa-bar-chart-o"></i>

										<h3 class="box-title">Best Day of the Week to Schedule</h3>
 									</div>
									<div class="box-body">
										<div id="bar-chart" style="width:90%;height: 300px;"></div>
									</div>
									<!-- /.box-body-->
								</div>


						</div>
			</div>


			<div class="row">
						<div class="col-md-4">
							<div class="box box-primary">	
										<div class="box-header with-border">
										<i class="fa fa-bar-chart-o"></i>

										<h3 class="box-title">Best Time of the Day to Schedule</h3>
 										</div>
										<div class="box-body">
												<table id="Report_TR" class="table table-bordered table-hover">
													<thead>
													<tr>
														<th>Hours</th>
														<th>Opens</th>
														<th>Clicks</th>
														<th>Pct</th>
													</tr>
													</thead>
													<tbody>
														<% out.print(Report_TR); %>
													</tbody>
												</table>
										</div>
							</div> <!-- box end !-->
						</div> 	<!-- md-4 end !-->
						<div class="col-md-8">
						 
								<div class="box box-primary">
									<div class="box-header with-border">
										<i class="fa fa-bar-chart-o"></i>

										<h3 class="box-title">Best Time of the Day to Schedule</h3>
 									</div>
									<div class="box-body">
										   <div id="line-chart" style="height: 300px;"></div>
									</div>

									<div class="box-header">
										   <h3 class="box-title">Find Your Best Sending Times</h3>
									</div>
									<div class="box-body">
										   <p>Pinpointing the best day and time to send a campaign is difficult because ideal sending times vary between industries and lists, and may also depend on the segment of a list you're sending to. </p>
									</div>
									<!-- /.box-body-->
								</div>


						</div>
			</div>
	 
</div>
 

 
  
<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/bootstrap.min.js"></script>
<script src="assets/js/adminlte.min.js"></script>
 <!-- FastClick -->
<script src="assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="assets/js/demo.js"></script>
<!-- FLOT CHARTS -->
<script src="assets/js/Flot/jquery.flot.js"></script>
<!-- FLOT RESIZE PLUGIN - allows the chart to redraw when the window is resized -->
<script src="assets/js/Flot/jquery.flot.resize.js"></script>
<!-- FLOT PIE PLUGIN - also used to draw donut charts -->
<script src="assets/js/Flot/jquery.flot.pie.js"></script>
<!-- FLOT CATEGORIES PLUGIN - Used to draw bar charts -->
<script src="assets/js/Flot/jquery.flot.categories.js"></script>

<script src="assets/js/DataTable/jquery.dataTables.min.js"></script>
<script src="assets/js/DataTable/dataTables.bootstrap.min.js"></script>
<script src="assets/js/DataTable/jquery.slimscroll.min.js"></script>
 


<!-- page script -->
<script>
  $(function () {
   
    $('#example2').DataTable({
 
      'paging'      : false,
      'lengthChange': false,
      'searching'   : false,
      'ordering'    : true,
      'info'        : false,
      'autoWidth'   : false
    })
	 $('#Report_TR').DataTable({
 
      'paging'      : true,
      'lengthChange': false,
      'searching'   : false,
      'ordering'    : true,
      'info'        : false,
      'autoWidth'   : false
    })
  })
</script>


	 

<script>
  $(function () {
     
	  var bar_data = {  data : [ <% out.print(ReportDay_Chart); %> ],  color: '#84C446'  }
    $.plot('#bar-chart', [bar_data], {
      grid  : {hoverable  : true, borderWidth: 1,borderColor: '#f3f3f3', tickColor  : '#f3f3f3'},
      series: {	shadowSize: 0, bars: {show    : true, barWidth: 0.5,align   : 'center' }  },
      xaxis : { mode      : 'categories', tickLength: 0,show: true },
	  yaxis : { show: true}
    })

	 

	 //Initialize tooltip on hover
    $('<div class="tooltip-inner" id="bar-chart-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
    $('#bar-chart').bind('plothover', function (event, pos, item) {
	 
      if (item) {
        var x = item.datapoint[0],
            y = item.datapoint[1]

        $('#bar-chart-tooltip').html( y)
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)
      } else {
        $('#bar-chart-tooltip').hide()
      }

    })
    /* END BAR CHART */
  


   /*
     * LINE CHART
     * ----------
     */
    //LINE randomly generated data

    var open =  [<% out.print(ReportOpen_Chart);%>]  
    var click =  [<% out.print(ReportClick_Chart);%>]
    var line_data1 = {
	  label: "Open",
      data : open,
      color: '#3c8dbc'
    }
    var line_data2 = {
	  label: "Click",	
      data : click,
      color: '#84C446'
    }
    $.plot('#line-chart', [line_data1, line_data2], {
      grid  : {
        hoverable  : true,
        borderColor: '#f3f3f3',
        borderWidth: 1,
        tickColor  : '#f3f3f3'
      },
      series: {
        shadowSize: 0,
        lines     : {
          show: true
        },
        points    : {
          show: true
        }
      },
      lines : {
        fill : false,
        color: ['#3c8dbc', '#f56954']
      },
      yaxis : {
        show: true
      },
      xaxis : {
        show: true
      }
    })
    //Initialize tooltip on hover
    $('<div class="tooltip-inner" id="line-chart-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
    $('#line-chart').bind('plothover', function (event, pos, item) {

      if (item) {
        var x = item.datapoint[0],
            y = item.datapoint[1]

        $('#line-chart-tooltip').html(item.series.label + ' of ' + x + ' = ' + y)
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)
      } else {
        $('#line-chart-tooltip').hide()
      }

    })
    /* END LINE CHART */


  })

 
</script>








</body>
</html>