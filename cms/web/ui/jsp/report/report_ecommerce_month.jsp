<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			java.sql.*,
			java.util.Calendar,			
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<% if(logger == null) 	{ 	logger = Logger.getLogger(this.getClass().getName()); } %>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%
String sCustId = cust.s_cust_id;
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
		
Calendar calendar = Calendar.getInstance();  
        

int  current_year;
int  current_month;
int  current_month_cal;
int  current_day;

current_year = calendar.get(Calendar.YEAR); 
current_month = calendar.get(Calendar.MONTH); 
current_month_cal = current_month + 1;
current_day = calendar.get(Calendar.DAY_OF_MONTH); 
 
 

ConnectionPool	cp		= null;
Connection 		conn	= null;
Statement		stmt	= null;
ResultSet 		rs		= null;

StringBuilder ReportDay_Chart = new StringBuilder();
StringBuilder ReportMonth_Chart = new StringBuilder();
StringBuilder ReportPurchase_Chart = new StringBuilder();

String YearOption =null;

try{	

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	String sSql_day = "";

	
	if(d_startdate!=null){

		sSql_day = "SELECT DAY(date) DAY, SUM(amount_sum) FROM untt_mbs_order_date with(nolock)WHERE cust_id = "+sCustId+" AND date >='"+d_startdate+"' AND date<='"+d_enddate+"' GROUP BY DAY(date) ORDER BY 1 ;";
	
	}else{
		sSql_day = "SELECT DAY(date) DAY, SUM(amount_sum) FROM untt_mbs_order_date with(nolock)WHERE cust_id = "+sCustId+" AND MONTH(date)="+current_month_cal+" AND YEAR(date)="+current_year+" GROUP BY DAY(date) ORDER BY 1 ;";
	}
	
	rs = stmt.executeQuery(sSql_day);

	int iCount_D = 0;
	String sDay_D			=null;
	String sTotal_D			=null;
	String graph_cat_d 		= "";
	String graph_val1_d 	= "";
	String daily_rev 		="";


	while (rs.next())
	{		
		sDay_D 		= rs.getString(1);
		sTotal_D 	= rs.getString(2); 

	    ReportDay_Chart.append("['"+ sDay_D +"',"+sTotal_D+"],");
 		iCount_D++;			
	} 

	rs.close();

	 
	if(MonthlyGrowth==null){
		MonthlyGrowth = new Integer(current_year).toString();
	} 
	String sSql_UserYear= "select YEAR(date)  from untt_mbs_order_date with(nolock) \n" +
			"where cust_id = "+sCustId+" and  camp_id in (select camp_id from cque_campaign with(nolock) where cust_id = "+sCustId+" and type_id in (2,4)) and YEAR(date) is not null \n" +
			"GROUP BY YEAR(date) ORDER BY 1;";
	rs = stmt.executeQuery(sSql_UserYear);

	String select="";
	while (rs.next())
	{		
		String x=rs.getString(1);
		if(x.equals(MonthlyGrowth)){
		
		select="selected" ;
		}else{
			select="";
		}
	YearOption+="<option "+select +"  value='"+x+"'>"+x+"</option>";
			
	}  
	rs.close();





	String amountDate = "and date BETWEEN  '"+MonthlyGrowth+"-01-01' AND '"+MonthlyGrowth+"-12-31' ";
	
	
	String sSql = "";
	sSql = "select sum(amount_sum) as Total, CONVERT(VARCHAR(7), date, 111) as 'Date ' \n" +
			"from untt_mbs_order_date with(nolock) where cust_id = "+sCustId+" and  camp_id in (select camp_id from cque_campaign with(nolock) \n" +
			"where type_id in (2,4)) and cust_id = "+sCustId+"  and amount_sum is not null and date BETWEEN  '"+MonthlyGrowth+"-01-01' AND '"+MonthlyGrowth+"-12-31' " +
			"group by CONVERT(VARCHAR(7), date, 111) order by 2 ;" ;
	rs = stmt.executeQuery(sSql);

	int iCount = 0;
	String sDate		=null;
	String sTotal		=null;
	String graph_cat 	= "";
	String graph_val1 	= "";
	String m_xxx 	= "";

	while (rs.next())
	{		
		sDate 		= rs.getString(1);
		sTotal 		= rs.getString(2);
		
		graph_cat 	+= "{\"label\":\""+sTotal+"\"},";
		graph_val1 	+= "{\"value\":\""+sDate+"\"},";
	//	m_xxx += "{\"label\":\""+sTotal+"\",\"value\":\""+sDate+"\"},";
		
		ReportMonth_Chart.append("['"+ sTotal +"',"+sDate+"],");
		iCount++;			
	} 
	rs.close();
 
	String sSql_Week = "";
	sSql_Week ="SELECT sum(amount_sum) as 'Amount' , DATENAME(dw, date)  as 'days', DATEPART(dw, date) as 'Number' \n" +
			"FROM untt_mbs_order_date with(nolock) \n" +
			"WHERE amount_sum is not null and cust_id= "+sCustId+" and camp_id in (select camp_id from cque_campaign with(nolock) \n" +
			"where type_id in (2,4)and cust_id= "+sCustId+" )  GROUP BY DATENAME(dw, date), DATEPART(dw, date) ORDER BY 3 asc ; ";
	//sSql_Week = "select sum(_amount) as Total, CONVERT(VARCHAR(7), _order_date_time, 111) as 'Date ' from untt_mbs_order with(nolock) where _amount is not null group by CONVERT(VARCHAR(7), _order_date_time, 111) order by 1 ";
	rs = stmt.executeQuery(sSql_Week);

	int iCount2 = 0;
	String sDate_w		=null;
	String sTotal_w		=null;
	String graph_cat_w 	= "";
	String graph_val1_w 	= "";
	String xxx ="";

	while (rs.next()){		
		sDate_w 		= rs.getString(2);
		sTotal_w 		= rs.getString(1);
		
		//graph_cat_w 	+= "{\"label\":\""+sDate_w+"\"},";
		//graph_val1_w 	+= "{\"value\":\""+sTotal_w+"\"},";
	//	xxx += "{\"label\":\""+sDate_w+"\",\"value\":\""+sTotal_w+"\"},";
		ReportPurchase_Chart.append("['"+ sDate_w +"',"+sTotal_w+"],");
		iCount2++;			
	} 
	rs.close();

  
 }
catch(Exception ex){	ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);}
finally{
	try	{if (stmt != null) stmt.close();if (conn != null) cp.free(conn);}
	catch (SQLException e)	{logger.error("Could not clean db statement or connection", e);	}
}%>


 <!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Revenue Time Reporting</title> 
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

<div class="wrapper" style="margin-left:20px;margin-right:20px;">
 	 
			<section class="content-header"><br/>
				<h1>
					Revenue Time Reporting
					<small>The stats are based on all revenue generated from Revotrack</small>
				</h1> 
					<br/><br/>
	 		</section>
 <div class="row">
 		<div class="col-md-6">
		 
					<div class="box box-primary">
								<div class="box-header">
										<h3 class="box-title">Daily Revenue</h3> 
										<small>Daily Revenue generated from Revotrack</small>
								</div>
								<div class="box-body">
												<form method="post" action="report_ecommerce_month.jsp">
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
												<div id="bar-chart" style="width:90%;height: 300px;"></div> 
								</div> 
					</div>
		 
		</div>
		<!-- col-md-6 END !-->
 		<div class="col-md-6">
		 
							<div class="box box-primary">
									<div class="box-header" >
											<h3 class="box-title">Revenue By Month</h3> 
											<small>Revenue generated from Revotrack last month</small>
									</div>
									<div class="box-body"  >
											<form method="post" action="report_ecommerce_month.jsp">
														<div class="row">
																			<div class="col-xs-6">
																						<div class="form-group">
																									<div class="input-group">
																												<div class="input-group-addon">
																													<i class="fa fa-calendar"></i>
																												</div>
																											<select name="MonthlyGrowth" class="form-control"><% out.println(YearOption);%></select>
																																									
																									</div>
																						</div>
																			</div>
																			<div class="col-xs-4">
																						<button type="submit" class="btn btn-primary">Submit</button>
																			</div>
														
														</div>
													
											 </form>

												<div id="bar-chart-month" style=" height: 300px;"></div>
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
								<h3 class="box-title">Best day to purchase</h3>
								<small>Revenue generated from Revotrack by week. Graph below will display which day of the week generated most revenue </small>
							</div>
							<div class="box-body">
								<div id="bar-chart-purchase" style=" width:40%; height: 300px;"></div>
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

<script src="assets/js/DataTable/jquery.dataTables.min.js"></script>
<script src="assets/js/DataTable/dataTables.bootstrap.min.js"></script>
<script src="assets/js/DataTable/jquery.slimscroll.min.js"></script>


<script src="assets/js/daterangepicker/moment.min.js"></script>
<script src="assets/js/daterangepicker/daterangepicker.js"></script>
<script>
  $(function () {
    
	 $('#tarih_aralik').daterangepicker({	locale: {format: 'YYYY/MM/DD'},})
 


	var bar_data = {  data : [ <% out.print(ReportDay_Chart); %> ],  color: '#84C446'  }
    $.plot('#bar-chart', [bar_data], {
      grid  : {hoverable  : true, borderWidth: 1,borderColor: '#f3f3f3', tickColor  : '#f3f3f3'},
      series: {	shadowSize: 0, bars: {
								  	show    : true,
									barWidth: 0.5,
									align   : 'center' 
									}
									  },
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
            y = item.datapoint[1].toFixed(2)

        $('#bar-chart-tooltip').html(y+" TL")
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)
      } else {
        $('#bar-chart-tooltip').hide()
      }

    })
    /* END BAR CHART */


	var bar_data = {  data : [ <% out.print(ReportMonth_Chart); %> ],  color: '#84C446'  }
    $.plot('#bar-chart-month', [bar_data], {
      grid  : {hoverable  : true, borderWidth: 1,borderColor: '#f3f3f3', tickColor  : '#f3f3f3'},
      series: {	shadowSize: 0, bars: {show    : true, barWidth: 0.5,align   : 'center' }  },
      xaxis : { mode      : 'categories', tickLength: 0,show: true},
	  yaxis : { show: true}
    })

	 

	 //Initialize tooltip on hover
    $('<div class="tooltip-inner" id="bar-chart-month-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
    $('#bar-chart-month').bind('plothover', function (event, pos, item) {
	 
      if (item) {
		  console.log(item);
        var x = item.datapoint[0],
            y = item.datapoint[1].toFixed(2)

        $('#bar-chart-month-tooltip').html(y+" TL")
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)
      } else {
        $('#bar-chart-month-tooltip').hide()
      }

    })
    /* END BAR CHART */


	var bar_data = {  data : [ <% out.print(ReportPurchase_Chart); %> ],  color: '#84C446'  }
    $.plot('#bar-chart-purchase', [bar_data], {
      grid  : {hoverable  : true, borderWidth: 1,borderColor: '#f3f3f3', tickColor  : '#f3f3f3'},
      series: {	shadowSize: 0, bars: {show    : true, barWidth: 0.5,align   : 'center' }  },
      xaxis : { mode      : 'categories', tickLength: 0,show: true },
	  yaxis : { show: true}
    })

	 

	 //Initialize tooltip on hover
    $('<div class="tooltip-inner" id="bar-chart-purchase-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
    $('#bar-chart-purchase').bind('plothover', function (event, pos, item) {
	 
      if (item) {
        var x = item.datapoint[0],
            y = item.datapoint[1].toFixed(2)

        $('#bar-chart-purchase-tooltip').html(y+" TL")
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)
      } else {
        $('#bar-chart-purchase-tooltip').hide()
      }

    })
    /* END BAR CHART */


  })
</script>
</body>
</html>