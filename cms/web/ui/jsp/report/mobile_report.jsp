<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			java.sql.*,
			java.util.Calendar,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
		contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<%
	String sCustId = cust.s_cust_id;
	Campaign camp = new Campaign();
	camp.s_cust_id = sCustId;

	// Get Connection
	Statement		stmt	= null;
	ResultSet		rs		= null;
	ConnectionPool	cp		= null;
	Connection		conn	= null;

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	//Mobil ve Desktop goruntulenmelerini getirir
	rs = stmt.executeQuery("select total_reads,desktop_reads,mobil_reads from z_rrpt_mobile_summary with(nolock) where cust_id ="+cust.s_cust_id);

	String sTotal_Reads =null;
	String sDesktop_Reads =null;
	String sMobil_Reads =null;

	while(rs.next()){
		sTotal_Reads 		= rs.getString(1);
		sDesktop_Reads 		= rs.getString(2);
		sMobil_Reads 		= rs.getString(3);
	}
	rs.close();

	//Cihazlardan gelen raporlar
	rs = stmt.executeQuery("select mobile_client,mobile_count,mobile_pct from z_mobile_reporting with(nolock) where cust_id ="+cust.s_cust_id);

	String sMobile_Client =null;
	String sMobile_Count =null;
	String sMobile_Pct =null;
	String xxx ="";
	String table_format ="";
	while(rs.next()){
		sMobile_Client 		= rs.getString(1);
		sMobile_Count 		= rs.getString(2);
		sMobile_Pct 		= rs.getString(3);


		table_format +="<tr><td>"+sMobile_Client+"</td><td>"+sMobile_Count+"</td><td>"+sMobile_Pct+"</td></tr>";
		xxx +="['"+ sMobile_Client +"',"+sMobile_Count+"],";

	}
	rs.close();

%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<title>Mobile Reporting </title>
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
			Mobile Client Reporting
			<small>The stats are based on all opens and clicks since the beginning of your campaigns.</small>
		</h1>

	</section>

	<br/>
	<div class="row">
		<div class="col-md-4">
			<!-- small box -->
			<div class="small-box b_turuncu c_beyaz">
				<div class="inner">
					<h3><% out.print(sTotal_Reads); %></h3>

					<p>TOTAL READS</p>
				</div>
				<div class="icon">
					<i class="ion ion-android-mail"></i>
				</div>
				<a href="#" class="small-box-footer"> </a>
			</div>
		</div>
		<!-- ./col -->
		<div class="col-md-4">
			<!-- small box -->
			<div class="small-box b_mavi c_beyaz">
				<div class="inner">
					<h3><% out.print(sDesktop_Reads); %><sup style="font-size: 20px"></sup></h3>

					<p>DESKTOP</p>
				</div>
				<div class="icon">
					<i class="ion ion-android-desktop"></i>
				</div>
				<a href="#" class="small-box-footer"> </a>
			</div>
		</div>
		<!-- ./col -->
		<div class="col-md-4">
			<!-- small box -->
			<div class="small-box b_yesil c_beyaz">
				<div class="inner">
					<h3><% out.print(sMobil_Reads); %></h3>

					<p>MOBILE</p>
				</div>
				<div class="icon">
					<i class="ion ion-android-phone-portrait"></i>
				</div>
				<a href="#" class="small-box-footer"> </a>
			</div>
		</div>
		<!-- ./col -->

	</div>

</div>
<div class="wrapper" style="margin-left:20px;margin-right:20px;">

	<div class="row">
		<div class="col-md-6">
			<div class="box box-primary">
				<div class="box-header with-border">
					<i class="fa fa-bar-chart-o"></i>

					<h3 class="box-title">Mobil Reporting</h3>

				</div>
				<div class="box-body">
					<div id="donut-chart" style="height: 300px; padding: 0px; position: relative;">
						<canvas class="flot-base" width="786" height="300" style="direction: ltr; position: absolute; left: 0px; top: 0px; width: 786.5px; height: 300px;"></canvas>
						<canvas class="flot-overlay" width="786" height="300" style="direction: ltr; position: absolute; left: 0px; top: 0px; width: 786.5px; height: 300px;"></canvas>
						<span class="pieLabel" id="pieLabel0" style="position: absolute; top: 71px; left: 451.852px;">
												<div style="font-size:13px; text-align:center; padding:2px; color: #fff; font-weight: 600;">Series2<br>30%</div></span>
						<span class="pieLabel" id="pieLabel1" style="position: absolute; top: 211px; left: 429.852px;">
												<div style="font-size:13px; text-align:center; padding:2px; color: #fff; font-weight: 600;">Series3<br>20%</div></span>
						<span class="pieLabel" id="pieLabel2" style="position: absolute; top: 130px; left: 270.852px;">
												<div style="font-size:13px; text-align:center; padding:2px; color: #fff; font-weight: 600;">Series4<br>50%</div></span></div>
				</div>
				<!-- /.box-body-->
			</div>

		</div>

		<div class="col-md-6">
			<!-- Bar chart -->
			<div class="box box-primary">
				<div class="box-header with-border">
					<i class="fa fa-bar-chart-o"></i>

					<h3 class="box-title">Bar Chart</h3>


				</div>
				<div class="box-body">
					<div id="bar-chart" style="height: 300px;"></div>
				</div>
				<!-- /.box-body-->
			</div>


		</div>
	</div>


</div>

</div>

<div class="wrapper" style="margin-left:20px;margin-right:20px;">
	<div class="row">
		<div class="col-xs-12">
			<div class="box box-primary">
				<div class="box-header">


					<div class="box-body">
						<table id="example2" class="table table-bordered table-hover">
							<thead>
							<tr>
								<th>Mobile Client</th>
								<th>	Count</th>
								<th>Percentage</th>
							</tr>
							</thead>
							<tbody>

							<% out.print(table_format); %>
							</tbody>

						</table>
					</div>

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
		})
	</script>




	<script>
		$(function () {

			var bar_data = {
				data : [
					<% out.print(xxx); %>
				],
				color: '#84C446'
			}
			$.plot('#bar-chart', [bar_data], {
				grid  : {
					hoverable  : true,
					borderWidth: 1,
					borderColor: '#f3f3f3',
					tickColor  : '#f3f3f3'
				},
				series: {
					shadowSize: 0,
					bars: {
						show    : true,
						barWidth: 0.5,
						align   : 'center'
					}
				},
				xaxis : {
					mode      : 'categories',
					tickLength: 0,
					show: true
				},
				yaxis : {
					show: true
				}

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
             * DONUT CHART
             * -----------
             */



			var donutData = [
				{ label: 'Desktop', data:<% out.print(sDesktop_Reads); %>, color: '#59C8E6' },
				{ label: 'Mobile', data: <% out.print(sMobil_Reads); %> , color: '#84C446' }
			]
			$.plot('#donut-chart', donutData, {
				series: {
					pie: {
						show       : true,
						radius     : 1,
						innerRadius: 0.5,
						label      : {
							show     : true,
							radius   : 2 / 3,
							formatter: labelFormatter,
							threshold: 0.1
						}

					}
				},
				legend: {
					show: false
				}
			})
			/*
             * END DONUT CHART
             */
			/*
                * Custom Label formatter
                * ----------------------
              */
			function labelFormatter(label, series) {
				return '<div style="font-size:13px; text-align:center; padding:2px; color: #fff; font-weight: 600;">'
						+ label
						+ '<br>'
						+ Math.round(series.percent) + '%</div>'
			}



		})
	</script>

</body>
</html>