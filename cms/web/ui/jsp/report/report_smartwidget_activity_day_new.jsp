<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			java.sql.*,
			java.util.Calendar,
			java.io.*,
			org.apache.log4j.Logger,
			java.text.DateFormat,
			org.json.JSONObject,
			org.w3c.dom.*"
		contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.Vector" %>
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

	System.out.println("--------------SMARTWIDGETREPORT----------");
	String sCustId= cust.s_cust_id;

	Service service = null;
	Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, sCustId);
	service = (Service) services.get(0);
	String rcpLink = service.getURL().getHost();
	String popupId = request.getParameter("popup_id");

	Campaign camp = new Campaign();
	camp.s_cust_id = sCustId;


	String	d_startdate = null;
	String	d_enddate = null;

	String tarih_aralik  = request.getParameter("tarih_aralik");
	String MonthlyGrowth = request.getParameter("MonthlyGrowth");

	if(tarih_aralik!=null){
		String[] parts = tarih_aralik.split("-");
		d_startdate = parts[0];
		d_enddate = parts[1];
	}

	Statement		stmt= null;
	ResultSet		rs= null;
	ConnectionPool	cp= null;
	Connection		conn= null;

%>

<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<title>Daily Growth</title>
	<meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
	<link rel="stylesheet" href="assets/css/bootstrap.min.css">

	<link rel="stylesheet" href="assets/css/font-awesome.min.css">

	<link rel="stylesheet" href="assets/css/ionicons.min.css">

	<link rel="stylesheet" href="assets/css/AdminLTE.css">
	<link rel="stylesheet" href="assets/css/Style.css">

	<link rel="stylesheet" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" type="text/css">
	<link rel="stylesheet" href="https://cdn.datatables.net/rowreorder/1.2.6/css/rowReorder.dataTables.min.css" type="text/css">

	<link rel="stylesheet" href="assets/css/skin-blue.min.css">



	<link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">
	<!--[if lt IE 9]>
	<script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
	<script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
	<![endif]-->

	<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">
</head>
<body class="hold-transition">

<div class="wrapper" style="margin-left:20px;margin-right:20px;">

	<section class="content-header"><br/>
		<h1>
			Over-Time Smart Widget Utilization Visualizations
			<small> Chart below indicates smart widget utilization over time</small>
		</h1>
		<br/><br/>
	</section>

	<div class="row">
		<div class="col-12 col-sm-6 col-md-3">
			<div class="info-box">
				<span style="color:white;background-color: rgb(252,167,42) !important" class="info-box-icon bg-info elevation-2"><i class="fa fa-eye"></i></span>

				<div class="info-box-content">
					<span class="info-box-text">Total View</span>
					<span class="info-box-number" id="total-view">0</span>
				</div>
				<!-- /.info-box-content -->
			</div>
			<!-- /.info-box -->
		</div>

		<div class="col-12 col-sm-6 col-md-3">
			<div class="info-box">
				<span style="color:white;background-color: rgb(131,196,70) !important" class="info-box-icon bg-info elevation-2"><i class="fa fa-mouse-pointer"></i></span>

				<div class="info-box-content">
					<span class="info-box-text">Total Click</span>
					<span class="info-box-number" id="total-click">0</span>
				</div>
				<!-- /.info-box-content -->
			</div>
			<!-- /.info-box -->
		</div>

		<div class="col-12 col-sm-6 col-md-3">
			<div class="info-box">
				<span style="color:white;background-color: rgb(98,197,226) !important" class="info-box-icon bg-info elevation-2"><i class="fa fa-handshake-o"></i></span>

				<div class="info-box-content">
					<span class="info-box-text">Total Submit</span>
					<span class="info-box-number" id="total-submit">0</span>
				</div>
				<!-- /.info-box-content -->
			</div>
			<!-- /.info-box -->
		</div>

		<div class="col-12 col-sm-6 col-md-3">
			<div class="info-box">
				<span style="color:white;background-color: rgb(227,113,175) !important" class="info-box-icon bg-info elevation-2"><i class="fa fa-money"></i></span>

				<div class="info-box-content">
					<span class="info-box-text">Total Revenue</span>
					<span class="info-box-number" id="total-revenue">0</span>
				</div>
				<!-- /.info-box-content -->
			</div>
			<!-- /.info-box -->
		</div>


	</div>
	<div class="row">
		<div class="col-md-12">

			<div class="box box-primary">
				<div class="box-header">
					<h3 class="box-title">Daily Growth</h3>
				</div>
				Widgets:
				<select id="graph_list">
					<option value="total_numbers">Total Numbers</option>
				</select>
				<div id="graph-div" class="box-body">
					<form method="post" action="report_smartwidget_activity_day_new.jsp?cust_id=<%= sCustId%>&popup_id=<%=popupId%>">
						<div class="row">
							<div class="col-xs-6">
								<div class="form-group">
									<div class="input-group">
										<div class="input-group-addon">
											<i class="fa fa-calendar"></i>
										</div>
										<input type="text" name="tarih_aralik" class="form-control pull-right" id="tarih_aralik">
									</div>
								</div>
							</div>
							<div class="col-xs-4">
								<button type="submit" class="btn btn-primary">Submit</button>
							</div>

						</div>

					</form>
					<div id="smart-widget-graph" style="width: 98%; height: 300px;"></div>
					<div id="chartLegend-all"></div>
				</div>
			</div>

		</div>
		<!-- col-md-6 END !-->
	</div>
	<!-- row END !-->

	<div class="row">
		<div class="col-md-12">
			<div class="box box-primary">
				<div class="box-header">
					<h3 class="box-title">Statistics</h3>
				</div>
				<div class="box-body">
					<table class="listTable" id="example" width="100%" cellpadding="2" cellspacing="0">
						<thead>
						<th width="18%"  valign="middle" nowrap>Widget Name</th>
						<th width="14%"  valign="middle" nowrap>Type</th>
						<th width="6%"  valign="middle" nowrap>View</th>
						<th width="6%"  valign="middle" nowrap>Click</th>
						<th width="6%"  valign="middle" nowrap>Click (%)</th>
						<th width="6%"  valign="middle" nowrap>Submit</th>
						<th width="6%"  valign="middle" nowrap>Submit (%)</th>
						<th width="6%"  valign="middle" nowrap>Revenue</th>
						<th width="6%"  valign="middle" nowrap>Enabled</th>
						<th width="13%"  valign="middle" nowrap>Modify Date</th>
						<th width="13%"  valign="middle" nowrap>Create Date</th>
						</thead>
						<tbody id="report-list"></tbody>
					</table>
				</div>
			</div>
		</div>
		<!-- col-md-12 END !-->

	</div>
	<!-- row END !-->

</div>
<!-- wrapper END !-->

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
<script src="assets/js/Flot/jquery.flot.stack.js"></script>
<script src="assets/js/Flot/jquery.flot.time.js"></script>

<script src="assets/js/DataTable/jquery.slimscroll.min.js"></script>

<script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/rowreorder/1.2.6/js/dataTables.rowReorder.min.js"></script>


<script src="assets/js/daterangepicker/moment.min.js"></script>
<script src="assets/js/daterangepicker/daterangepicker.js"></script>


<script>

	function numberToFixed(number,toFixed) {
		number=number.toString();
		var indexOfDot = number.indexOf('.');
		if(indexOfDot !== -1) {
			if(toFixed==0) {
				number = number.substring(0,indexOfDot);
			} else {
				number = number.split('').filter((e,i)=>{
					return (indexOfDot+toFixed)>=i;
				}).join('');
				var decimalCount = number.length - indexOfDot - 1;
				if(toFixed>decimalCount)number=number.concat(Array.apply(null, Array(toFixed-decimalCount)).map(Number.prototype.valueOf,0).join(''));
			}
		} else if(toFixed>0) {
			number=number.concat(['.']);
			number=number.concat(Array.apply(null, Array(toFixed)).map(Number.prototype.valueOf,0).join(''));
		}
		return number;
	}

	function formatCurrency(number,currencyConfig) {
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
			if(indexOfComma === -1 || indexOfDot === -1)thousandSeparator = '';
			var decimalCount = currencyConfig.format.length - currencyConfig.format.indexOf(decimalSeparator) - 1;
			number = numberToFixed(number,decimalCount);
			var parts = number.split('.').length === 2 ? number.split('.') : number.split(',');
			var normalPart = parts[0];
			var decimalPart = parts[1] ? parts[1] : '';

			normalPart = normalPart.split('').reverse().map((e,i,arr)=>{
				if((i+1)%3===0 && arr.length>(i+1))return thousandSeparator+e;
				else return e;
			}).reverse().join('');
			var currency = normalPart + (decimalPart ? (decimalSeparator + decimalPart) : '');
			if(currencyConfig.language === 'EN') currency = currencyConfig.currency + currency;
			else if(currencyConfig.language === 'TR') currency = currency + ' ' + currencyConfig.currency;
			return currency;
		} catch(e) {
			return originalNumber;
		}

	}

	var currencyConfig = null;

	var currencyFetched = fetch('https://<%=rcpLink%>/rrcp/imc/currency/get_currency_config.jsp?cust_id=<%=sCustId%>').then(resp=>resp.json()).then(resp=>{
		currencyConfig = resp.filter(c=>c.active==1)[0];
	});


	var popupStatistics = {};
	var popupList = {};
	var custId = '<%=sCustId%>';
	var popupId = '<%=popupId%>';
	<%

    try{
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sSql_day = "";

        if(d_startdate!=null){

            sSql_day = "select CONVERT(VARCHAR(10), activity_date, 120) DAY, count(*), popup_id, form_id, type_name, activity, impression, revenue from ccps_smart_widget_activity_day with(nolock) WHERE "+"cust_id="+sCustId+" AND activity_date >='"+d_startdate+"' AND activity_date<='"+d_enddate+"' GROUP BY CONVERT(VARCHAR(10), activity_date, 120), popup_id, form_id, type_name, activity, impression, revenue ORDER BY 1";
            System.out.println("SQL_DAY:"+sSql_day);


        }else{

            sSql_day = "select CONVERT(VARCHAR(10), activity_date, 120) DAY, count(*), popup_id, form_id, type_name, activity, impression, revenue from ccps_smart_widget_activity_day with(nolock) WHERE "+"cust_id="+sCustId+" AND activity_date >= DATEADD(day, -30, getdate()) GROUP BY CONVERT(VARCHAR(10), activity_date, 120), popup_id, form_id, type_name, activity, impression, revenue ORDER BY 1";
            System.out.println("SQL_DAY:"+sSql_day);
        }

        rs = stmt.executeQuery(sSql_day);

        while (rs.next())
        {
        String day = rs.getString(1);
        String count = rs.getString(2);
        String popup_id = rs.getString(3);
        String form_id = rs.getString(4);
        String type_name = rs.getString(5);
        String activity_count = rs.getString(6);
        String impression = rs.getString(7);
        String revenue = rs.getString(8);
        %>
	var type_name = <%=type_name%>;
	if(!popupStatistics['<%=popup_id%>']) popupStatistics['<%=popup_id%>'] = {};
	if(!popupStatistics['<%=popup_id%>'].days) popupStatistics['<%=popup_id%>'].days = {};
	if(!popupStatistics['<%=popup_id%>'].days['<%=day%>']) popupStatistics['<%=popup_id%>'].days['<%=day%>'] = ({day: '<%=day%>', revenue: 0, view: 0, click: 0, submit: 0, form_id: '<%=form_id%>'});
	popupStatistics['<%=popup_id%>'].days['<%=day%>'].view += <%=impression%>;
	popupStatistics['<%=popup_id%>'].days['<%=day%>'].revenue += <%=revenue%>;
	if(type_name == 1)
		popupStatistics['<%=popup_id%>'].days['<%=day%>'].click += <%=activity_count%>;
	else if(type_name == 2)
		popupStatistics['<%=popup_id%>'].days['<%=day%>'].submit += <%=activity_count%>;
	<%
	}

 rs.close();

 String sql = "select popup_id, popup_name, config_param, form_id, create_date, modify_date from c_smart_widget_config where cust_id="+sCustId;
 System.out.println("SQL':"+sql);

 rs = stmt.executeQuery(sql);

 while(rs.next()) {
		String popup_id = rs.getString(1);
		String popup_name = rs.getString(2);
		JSONObject configParam = new JSONObject(rs.getString(3));
		String form_id = rs.getString(4);
		String create_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(5));
		String modify_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(6));
		%>
	if(!popupStatistics['<%=popup_id%>'])popupStatistics['<%=popup_id%>']={};
	popupStatistics['<%=popup_id%>'].popupType = '<%=configParam.getString("type")%>';
	popupStatistics['<%=popup_id%>'].popupEnabled = '<%=configParam.getBoolean("enabled")%>';
	popupStatistics['<%=popup_id%>'].popupName = `<%=popup_name%>`;
	popupStatistics['<%=popup_id%>'].formId = '<%=form_id%>';
	popupStatistics['<%=popup_id%>'].createDate = '<%=create_date%>';
	popupStatistics['<%=popup_id%>'].modifyDate = '<%=modify_date%>';
	<%
}
rs.close();

}
catch(Exception ex)
{
ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
}
finally
{
try
{
    if (stmt != null) stmt.close();
    if (conn != null) cp.free(conn);
}
catch (SQLException e)
{
    logger.error("Could not clean db statement or connection", e);
}
}



%>
	var totalPopup = {};

	totalPopup.totalView = 0;
	totalPopup.totalRevenue = 0;
	totalPopup.totalSubmit = 0;
	totalPopup.totalClick = 0;
	totalPopup.viewData = [];
	totalPopup.revenueData = [];
	totalPopup.submitData = [];
	totalPopup.submitPercentData = [];
	totalPopup.clickData = [];
	totalPopup.clickPercentData = [];

	var viewDataDay = {};
	var revenueDataDay = {};
	var clickDataDay = {};
	var clickPercentDataDay = {};
	var submitDataDay = {};
	var submitPercentDataDay = {};

	for(popupKey in popupStatistics) {
		var popup = popupStatistics[popupKey];
		popup.viewData = [];
		popup.revenueData = [];
		popup.submitData = [];
		popup.submitPercentData = [];
		popup.clickData = [];
		popup.clickPercentData = [];

		popup.totalView = 0;
		popup.totalRevenue = 0;
		popup.totalSubmit = 0;
		popup.totalSubmitPercent = 0;
		popup.totalClick = 0;
		popup.totalClickPercent = 0;
		if(!popup.popupName) {
			delete popupStatistics[popupKey];
		}
		else if(popup.days) {
			for(key in popup.days) {
				var day = popup.days[key];
				if(day.view) {
					popup.viewData.push([new Date(day.day),day.view]);
					popup.totalView += parseInt(day.view);
					totalPopup.totalView += parseInt(day.view);
					if(!viewDataDay[day.day])viewDataDay[day.day]=0;
					viewDataDay[day.day] += day.view;
				}
				if(day.click) {
					popup.clickData.push([new Date(day.day),day.click]);
					popup.totalClick += parseInt(day.click);
					totalPopup.totalClick += parseInt(day.click);
					if(!clickDataDay[day.day])clickDataDay[day.day]=0;
					clickDataDay[day.day] += day.click;
				}
				if(day.submit) {
					popup.submitData.push([new Date(day.day),day.submit]);
					popup.totalSubmit += parseInt(day.submit);
					totalPopup.totalSubmit += parseInt(day.submit);
					if(!submitDataDay[day.day])submitDataDay[day.day]=0;
					submitDataDay[day.day] += day.submit;
				}
				if(day.revenue) {
					popup.revenueData.push([new Date(day.day),day.revenue]);
					popup.totalRevenue += parseInt(day.revenue);
					totalPopup.totalRevenue += parseInt(day.revenue);
					if(!revenueDataDay[day.day])revenueDataDay[day.day]=0;
					revenueDataDay[day.day] += parseInt(day.revenue);
				}
				if(day.view && day.click) {
					var clickPercent = day.view > 0 ? ((day.click/day.view) * 100).toFixed(2) : 0;
					popup.clickPercentData.push([new Date(day.day),clickPercent]);
					if(!clickPercentDataDay[day.day])clickPercentDataDay[day.day]=0;
					clickPercentDataDay[day.day] += parseFloat(((day.click/day.view) * 100).toFixed(2));
				}
				if(day.view && day.submit) {
					var submitPercent = day.view > 0 ? ((day.submit/day.view) * 100).toFixed(2) : 0;
					popup.submitPercentData.push([new Date(day.day),submitPercent]);
					if(!submitPercentDataDay[day.day])submitPercentDataDay[day.day]=0;
					submitPercentDataDay[day.day] += parseFloat(((day.submit/day.view) * 100).toFixed(2));
				}
			}
			popup.totalClickPercent += popup.totalView>0 ? parseFloat(((popup.totalClick/popup.totalView) * 100)) : 0;
			popup.totalSubmitPercent += popup.totalView>0 ? parseFloat(((popup.totalSubmit/popup.totalView) * 100)) : 0;
			popup.totalClickPercent = popup.totalClickPercent.toFixed(2);
			popup.totalSubmitPercent = popup.totalSubmitPercent.toFixed(2);

			var newOption = document.createElement('option');
			newOption.value = popupKey;
			newOption.text = popup.popupName;
			document.getElementById('graph_list').appendChild(newOption);
		}
	}
	for(key in viewDataDay) {
		totalPopup.viewData.push([new Date(key), viewDataDay[key]]);
	}
	for(key in revenueDataDay) {
		totalPopup.revenueData.push([new Date(key), revenueDataDay[key]]);
	}
	for(key in clickDataDay) {
		totalPopup.clickData.push([new Date(key), clickDataDay[key]]);
	}
	for(key in clickPercentDataDay) {
		totalPopup.clickPercentData.push([new Date(key), parseFloat(clickPercentDataDay[key].toFixed(2))]);
	}
	for(key in submitDataDay) {
		totalPopup.submitData.push([new Date(key), submitDataDay[key]]);
	}
	for(key in submitPercentDataDay) {
		totalPopup.submitPercentData.push([new Date(key), parseFloat(submitPercentDataDay[key].toFixed(2))]);
	}

	totalPopup.viewData.sort((a,b)=>{return a[0].getTime()-b[0].getTime()});
	totalPopup.revenueData.sort((a,b)=>{return a[0].getTime()-b[0].getTime()});
	totalPopup.clickData.sort((a,b)=>{return a[0].getTime()-b[0].getTime()});
	totalPopup.clickPercentData.sort((a,b)=>{return a[0].getTime()-b[0].getTime()});
	totalPopup.submitData.sort((a,b)=>{return a[0].getTime()-b[0].getTime()});
	totalPopup.submitPercentData.sort((a,b)=>{return a[0].getTime()-b[0].getTime()});


	document.getElementById('total-view').innerText = totalPopup.totalView;
	document.getElementById('total-click').innerText = totalPopup.totalClick;
	document.getElementById('total-submit').innerText = totalPopup.totalSubmit;
	currencyFetched.then(()=>{
		document.getElementById('total-revenue').innerText = formatCurrency(totalPopup.totalRevenue, currencyConfig);
	});


	if(popupId!='null')document.getElementById('graph_list').value = popupId;

	document.getElementById('graph_list').addEventListener('change',function(e) {
		window.location = 'report_smartwidget_activity_day_new.jsp?popup_id=' + e.target.value;
	});

</script>

<script>
	var plot_statistics;
	function togglePlot(el, seriesIdx) {
		if(el.style.border) {
			el.style.border = ''
		} else {
			el.style.border = '1px solid black';
		}
		var previousPoint2 = plot_statistics.getData();
		previousPoint2[seriesIdx].points.show = !previousPoint2[seriesIdx].points.show;
		previousPoint2[seriesIdx].lines.show = !previousPoint2[seriesIdx].lines.show;
		plot_statistics.setData(previousPoint2);
		plot_statistics.draw();
	}


	(async function () {
		await currencyFetched;

		$('#tarih_aralik').daterangepicker({
			ranges: {
				'Today': [moment(), moment()],
				'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
				'Last 7 Days': [moment().subtract(6, 'days'), moment()],
				'Last 30 Days': [moment().subtract(29, 'days'), moment()],
				'This Month': [moment().startOf('month'), moment().endOf('month')],
				'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
			},
			startDate: moment().subtract(29, 'days'),
			endDate: moment(),
			locale: {format: 'YYYY/MM/DD'}
		})


		var popup_Id = document.getElementById('graph_list').value;
		var popup = popup_Id !== 'total_numbers' ? popupStatistics[popup_Id] : {
			viewData: totalPopup.viewData,
			revenueData : totalPopup.revenueData,
			clickData: totalPopup.clickData,
			clickPercentData: totalPopup.clickPercentData,
			submitData: totalPopup.submitData,
			submitPercentData: totalPopup.submitPercentData
		};
		var viewData = {
			label : "View",
			data : popup.viewData,
			color : 'rgb(252,167,42)',
			idx: 0
		}

		var revenueData = {
			label : "Revenue",
			data : popup.revenueData,
			color : 'rgb(227,113,175)',
			idx: 1
		}

		var clickData = {
			label : "Click",
			data : popup.clickData,
			color : 'rgb(131,196,70)',
			idx: 2
		}

		var clickPercentData = {
			label : "Click Percent",
			data : popup.clickPercentData,
			color : '#ff2700',
			idx: 3
		}

		var submitData = {
			label : "Submit",
			data : popup.submitData,
			color : 'rgb(98,197,226)',
			idx: 4
		}

		var submitPercentData = {
			label : "Submit Percent",
			data : popup.submitPercentData,
			color : '#daff11',
			idx: 5
		}

		plot_statistics = $.plot('#smart-widget-graph', [ viewData, revenueData, clickData, clickPercentData, submitData, submitPercentData ], {
			grid : {
				hoverable : true,
				borderColor : '#f3f3f3',
				borderWidth : 1,
				tickColor : '#f3f3f3'
			},
			series : {
				shadowSize : 0,
				lines : {
					show : true
				},
				points : {
					show : true
				}
			},
			legend : {
				noColumns : 3,
				container : $("#chartLegend-all"),
				labelFormatter: function(label, series){
					return '<a href="#" style="border: 1px solid" onClick="togglePlot(this,'+series.idx+'); return false;">'+label+'</a>';
				}
			},
			lines : {
				fill : true
			},
			yaxis : {
				show : true
			},
			xaxis : {
				mode: 'time',
				timeformat: "%d-%m-%Y",
				show : true,
				tickSize : 1,
				tickDecimals : 0
			}
		})

		$('<div class="tooltip-inner" id="line-open-click-send-tooltip"></div>')
				.css({
					position : 'absolute',
					display : 'none',
					opacity : 0.8
				}).appendTo('body')
		$('#smart-widget-graph').bind('plothover',
				function(event, pos, item) {

					if (item) {
						var x = item.datapoint[0], y = item.datapoint[1]
						$('#line-open-click-send-tooltip').html(
								item.series.label + ' of ' + (new Date(x).toLocaleDateString()) + ' = ' + y)
								.css({
									top : item.pageY + 5,
									left : item.pageX + 5
								}).fadeIn(200)
					} else {
						$('#line-open-click-send-tooltip').hide()
					}

				})

		var counter=0;
		var tr = '';
		for(popupKey in popupStatistics) {
			var popupTemp = popupStatistics[popupKey];
			tr += '<tr id="tr_id_'+counter+'">';
			tr += '<td class="list_row" nowrap><a href="http://cms.revotas.com/cms/ui/smartwidgets/newui/main.jsp?cust_id=<%=sCustId%>&popup_id='+popupKey+'">'+popupTemp.popupName+'</a></td>';
			tr += '<td class="list_row" nowrap>'+popupTemp.popupType+'</td>';
			tr += '<td class="list_row" nowrap>'+popupTemp.totalView+'</td>';
			tr += '<td class="list_row" nowrap>'+popupTemp.totalClick+'</td>';
			tr += '<td class="list_row" nowrap>'+popupTemp.totalClickPercent+' %</td>';
			tr += '<td class="list_row" nowrap>'+popupTemp.totalSubmit+'</td>';
			tr += '<td class="list_row" nowrap>'+popupTemp.totalSubmitPercent+' %</td>';
			tr += '<td class="list_row" nowrap>'+formatCurrency(popupTemp.totalRevenue,currencyConfig)+'</td>';
			tr += '<td class="list_row" nowrap>'+popupTemp.popupEnabled+'</td>';
			tr += '<td class="list_row" nowrap>'+popupTemp.modifyDate+'</td>';
			tr += '<td class="list_row" nowrap>'+popupTemp.createDate+'</td>';
			tr += '</tr>';
			counter++;
		}
		document.getElementById('report-list').innerHTML = tr;


		$("#example thead tr").prepend('<th>#</td>');
		var count = $("#example tbody tr").length-1;
		$("#example tbody tr").each(function(i, tr) {
			$(tr).attr('id', 'id'+i);
			$(tr).prepend('<td style="cursor:move;">'+parseInt(i+1)+'</td>');
		});

		$("#example").dataTable( {
			"sPaginationType": "full_numbers",
			rowReorder: {
				selector: 'td:first-child'
			}
		} );


	})();
</script>
</body>
</html>