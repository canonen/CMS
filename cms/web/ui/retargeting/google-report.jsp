<%
String refreshToken = request.getParameter("refresh_token");
String clientCustomerId = request.getParameter("client_customer_id");
String listName = request.getParameter("list_name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <link rel="stylesheet" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/font-awesome.min.css">
    <link rel="stylesheet" href="assets/css/ionicons.min.css">
    <link rel="stylesheet" href="assets/css/AdminLTE.css">
    <link rel="stylesheet" href="assets/css/Style.css">
    <link rel="stylesheet" href="assets/css/skin-blue.min.css">
    <link rel="stylesheet" href="assets/css/DataTable/dataTables.bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">
    <style>
#chartLegend table {
	margin-left: auto;
	margin-right: auto;
}

#chartLegend {
	text-align: center;
}

#chartLegend-mounth table {
	margin-left: auto;
	margin-right: auto;
}

#chartLegend-mounth {
	text-align: center;
}

#chartLegend-all table {
	margin-left: auto;
	margin-right: auto;
}

#chartLegend-all {
	text-align: center;
}

.ui-datepicker-calendar {
	display: none !important;
}
</style>
<script>
var refreshToken = '<%=refreshToken%>';
var clientCustomerId = '<%=clientCustomerId%>';
var listName = '<%=listName%>';
var reportData;
</script>
</head>
<body>
  <div class="box-header" style="margin-left: 10px;">
		<h3 class="box-title">
			<b>CRM Ads</b>
		</h3>
	</div>

	<div class="wrapper" style="margin-left: 20px; margin-right: 20px;">
		<div class="row">

			<div class="col-md-12">

				<div class="box box-primary">
					<div class="box-header">
						<h3 class="box-title" id="audience-name">e</h3>

				</div>
				
	<div class="panel panel-default">	
	<br>	
				<div class="row" style="padding-left: 10px">	
					<div class="col-xs-4">
					<label>Campaign Select</label> 
					<div class="form-group"> 
					<select style="margin-left: 5px" id="campaign-list">
					
					</select>
					</div>
					</div>
					<div class="col-xs-4">
					<label>Date Range</label>
						<div class="form-group">
						<div class="input-group">
						 <div class="input-group-addon">
							<i class="fa fa-calendar"></i>
							</div>
						
						<input type="text" name="date_range" class="form-control pull-right" id="date_range">
							</div>
						</div>
					</div>
				</div>
				</div>


				</div>
				

			</div>
			<!-- md-12 END !-->

		</div>
		<div class="panel panel-default">	
		<div class="row">
		    <div class="col-md-3">
                <div class="row">
                    <div class="col-md-12">
                        <span style="float:left;">Impressions</span>
                        <span style="float:right;font-weight: 700;" id="impressions"></span>
                    </div>   
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <span style="float:left;">Revenue</span>
                        <span style="float:right;font-weight: 700;" id="revenueperconv"></span>
                    </div>   
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <span style="float:left;">Cost</span>
                        <span style="float:right;font-weight: 700;" id="cost"></span>
                    </div>   
                </div>
		    </div>
		    <div class="col-md-3">
		        <div class="row">
                    <div class="col-md-6">
                        <div id="donut-chart1" style="height:150px;"></div>
                    </div>   
                    <div class="col-md-6">
                        <div>Clicks</div>
                        <span id="clicks"></span>
                    </div>
                </div>
		    </div>
		    <div class="col-md-3">
		        <div class="row">
                    <div class="col-md-6">
                        <div id="donut-chart2" style="height:150px;"></div>
                    </div>   
                    <div class="col-md-6">
                        <div>Conversions</div>
                        <span id="conversions"></span>
                    </div>
                </div>
		    </div>
		    <div class="col-md-3">
		        <div class="col-md-12">
                       <div class="row">
                       <div class="col-md-12">
                        <span style="float:left;">ROI</span>
                        <span style="float:right;font-weight: 700;" id="roi"></span>
                        </div>
                        </div>
                        <div class="row">
                       <div class="col-md-12">
                        <span style="float:left;">CPM</span>
                        <span style="float:right;font-weight: 700;" id="averagecpm"></span>
                        </div>
                        </div>
                        <div class="row">
                       <div class="col-md-12">
                        <span style="float:left;">CPC</span>
                        <span style="float:right;font-weight: 700;" id="averagecpc"></span>
                        </div>
                        </div>
                        <div class="row">
                       <div class="col-md-12">
                        <span style="float:left;">Cost per conv</span>
                        <span style="float:right;font-weight: 700;" id="costperconv"></span>
                        </div>
                        </div>
                    </div>  
		    </div>
		</div>
        </div>
		<div class="row">
        <div class="col-md-12">
		    <div class="box-body">
					<div id="line-open-click-send" style="width: 98%; height: 300px;"></div>
					<div id="chartLegend-all"></div>
				</div>
            </div>
		</div>
		<!-- row END !-->
	</div>
	<!-- wrapper END !-->
    
    
    
    <script src="assets/js/jquery.min.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script src="assets/js/adminlte.min.js"></script>
    <script src="assets/js/fastclick.js"></script>
    <script src="assets/js/demo.js"></script>
    <script src="assets/js/Flot/jquery.flot.js"></script>
    <script src="assets/js/Flot/jquery.flot.resize.js"></script>
    <script src="assets/js/Flot/jquery.flot.pie.js"></script>
    <script src="assets/js/Flot/jquery.flot.categories.js"></script>
    <script src="assets/js/Flot/jquery.flot.time.js"></script>
    <script src="assets/js/DataTable/jquery.dataTables.min.js"></script>
    <script src="assets/js/DataTable/dataTables.bootstrap.min.js"></script>
    <script src="assets/js/DataTable/jquery.slimscroll.min.js"></script>
    <script src="assets/js/daterangepicker/moment.min.js"></script>
    <script src="assets/js/daterangepicker/daterangepicker.js"></script>
    <script src="assets/google-chart.js"></script>
    
    
</body>
</html>