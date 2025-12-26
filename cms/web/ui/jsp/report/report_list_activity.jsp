<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.rcp.*,
			java.sql.*,
			java.io.*,
			java.util.*,
			com.britemoon.rcp.*,
			com.britemoon.rcp.que.*,
			java.util.Calendar,
			java.math.BigDecimal,
			org.apache.log4j.Logger,
			javax.mail.*,
			org.w3c.dom.*"
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
String sCustId =   cust.s_cust_id;
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
		ResultSet		rs		= null; 
 
 		String stotal_sent		= null;
		BigDecimal sread_prc		=null;
		BigDecimal sclick_prc		=null;
		BigDecimal sbback_prc		=null;

		StringBuilder Send_By_Day = new StringBuilder();
		StringBuilder Open = new StringBuilder();
		StringBuilder Click = new StringBuilder();

		StringBuilder Send_By_Mounth = new StringBuilder();
		StringBuilder Open_Mounth= new StringBuilder();
		StringBuilder Click_Mounth = new StringBuilder();

		StringBuilder Send_By_Years = new StringBuilder();
		StringBuilder Open_Years= new StringBuilder();
		StringBuilder Click_Years = new StringBuilder();

try{

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		String sSql_Send = "";
		
		sSql_Send = "SELECT sum(m.rque_count) ";
		sSql_Send += "FROM ccps_rque_message m WITH(NOLOCK) ";

		if(d_startdate!=null){	
		 	sSql_Send += "WHERE m.send_date >='"+d_startdate+"' AND m.send_date<='"+d_enddate+"' AND cust_id = " + sCustId ;

		}else{
			sSql_Send += "WHERE MONTH(m.send_date)="+current_month_cal+" AND YEAR(m.send_date)="+current_year+" AND cust_id = " + sCustId ;

		}

		rs= stmt.executeQuery(sSql_Send);

		while (rs.next())
		{
			stotal_sent 	= rs.getString(1);
		}
		rs.close();


		String sSql_Rate = "";
  		sSql_Rate = "SELECT ";
		sSql_Rate += "	 distinctReadPrc = avg(";
		sSql_Rate += "	CASE r.sent-r.bbacks";
		sSql_Rate += "	WHEN 0 THEN 0";
		sSql_Rate += "	ELSE convert(decimal(5,1),(r.dist_reads*100.0)/(r.sent-r.bbacks))";
		sSql_Rate += "	   END),";
		sSql_Rate += "	  distinctClickPrc =avg(";
		sSql_Rate += "	   CASE r.sent-r.bbacks";
		sSql_Rate += "		WHEN 0 THEN 0";
		sSql_Rate += "		ELSE convert(decimal(5,1),(r.dist_clicks*100.0)/(r.sent-r.bbacks))";
		sSql_Rate += "	   END),";

		sSql_Rate += "	BBackPrc =avg(";
		sSql_Rate += "	CASE Sent";
		sSql_Rate += "		WHEN 0 THEN 0";
		sSql_Rate += "		ELSE convert(decimal(5,1),(BBacks*100.0)/Sent)";
		sSql_Rate += "	END)";

		sSql_Rate += "	FROM ccps_rrpt_camp_summary_and_rque_campaign as r with(nolock) ";


		if(d_startdate!=null){
		  	sSql_Rate += " WHERE r.start_date >='"+d_startdate+"' AND r.start_date<= '"+d_enddate+"'  AND cust_id = " + sCustId; 
 		}
		else{
			sSql_Rate += " WHERE MONTH(r.start_date)="+current_month_cal+" AND YEAR(r.start_date)="+current_year+" AND cust_id = " + sCustId;
 		}

		rs = stmt.executeQuery(sSql_Rate);

		int icount_r = 0;


		while (rs.next())
		{
			sread_prc 	= rs.getBigDecimal(1);
			sclick_prc	= rs.getBigDecimal(2);
			sbback_prc	= rs.getBigDecimal(3);

			 if ( sread_prc == null )  {
				sread_prc=new BigDecimal("0.00");

			 }else{
				 sread_prc =   sread_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
				}

			 if ( sclick_prc == null )  {
				 sclick_prc=new BigDecimal("0.00");

				 }else{
					 sclick_prc =   sclick_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
				 }

			 if ( sbback_prc == null )  {
				 sbback_prc=new BigDecimal("0.00");

				 }else{
					 sbback_prc =   sbback_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
				 }
			
			sread_prc  = sread_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
			sclick_prc = sclick_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
			sbback_prc = sbback_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
  			icount_r++;			
		}
		rs.close();


		String sSql_day = "";
 		if(d_startdate!=null){
		
			sSql_day = "SELECT DAY(send_date) DAY, sum(rque_count) COUNT FROM ccps_rque_message with(nolock) WHERE send_date >='"+d_startdate+"' AND send_date<='"+d_enddate+"' AND cust_id = " + sCustId +" GROUP BY DAY(send_date) ORDER BY 1 ";
		
		}else{
			sSql_day = "SELECT DAY(send_date) DAY, sum(rque_count) COUNT FROM ccps_rque_message with(nolock) WHERE MONTH(send_date)="+current_month_cal+" AND YEAR(send_date)="+current_year+" AND cust_id = " + sCustId +"  GROUP BY DAY(send_date) ORDER BY 1 ";
		
		}
		 
		
		rs = stmt.executeQuery(sSql_day);

		int iCount_D = 0;
		String sDay_D			=null;
		String sTotal_D			=null;
		String graph_cat_d 		= "";
		String graph_val1_d 	= "";

		while (rs.next())
		{		
			sDay_D 		= rs.getString(1);
			sTotal_D 	= rs.getString(2);
			
			graph_cat_d 	+= "{\"label\":\""+sDay_D+"\"},";
			graph_val1_d 	+= "{\"value\":\""+sTotal_D+"\"},";
			Send_By_Day.append("['"+ sDay_D +"',"+sTotal_D+"],");
			iCount_D++;			
		} 
		rs.close();

		String sSql_openday = "";
		 

 		if(d_startdate!=null){
		 	
			sSql_openday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND click_time >='"+d_startdate+"' AND click_time<='"+d_enddate+"' AND cust_id = " + sCustId +" GROUP BY DAY(click_time) ORDER BY 1 ";
		 	
	    }else{
			
			sSql_openday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND MONTH(click_time)="+current_month_cal+" AND YEAR(click_time)=" + current_year + " AND cust_id = " + sCustId +" GROUP BY DAY(click_time) ORDER BY 1";
		
		}
		//sSql_openday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND MONTH(click_time)="+current_month_cal+" AND YEAR(click_time)="+current_year+" GROUP BY DAY(click_time) ORDER BY 1";
		rs= stmt.executeQuery(sSql_openday);

		
		int iCount_open = 0;
		String sTotal_open 	= "";
		String graph_value_open 	= "";

		while (rs.next())
		{		
			sDay_D 			= rs.getString(1);
			sTotal_open 	= rs.getString(2);

			graph_value_open 	+= "{\"value\":\""+sTotal_open+"\"},";
			Open.append("['"+ sDay_D +"',"+sTotal_open+"],");
			iCount_open++;			
		} 
		rs.close();

		String sSql_clickday = "";

		if(d_startdate!=null){
		 	
			sSql_clickday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND click_time >='"+d_startdate+"' AND click_time<='"+d_enddate+"' AND cust_id = " + sCustId +" GROUP BY DAY(click_time) ORDER BY 1 ";
		  	
	    }else{
			
			sSql_clickday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND MONTH(click_time)="+current_month_cal+" AND YEAR(click_time)="+current_year+" AND cust_id = " + sCustId +" GROUP BY DAY(click_time) ORDER BY 1";
		
		}
		//sSql_clickday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND MONTH(click_time)="+current_month_cal+" AND YEAR(click_time)="+current_year+" GROUP BY DAY(click_time) ORDER BY 1";
		rs= stmt.executeQuery(sSql_clickday);

		
		int iCount_click = 0;
		String sTotal_click 	= "";
		String graph_value_click 	= "";

		while (rs.next())
		{		
			 sDay_D 		= rs.getString(1);
			sTotal_click 	= rs.getString(2);
			
			//graph_cat_d 	+= "{\"label\":\""+sDay_D+"\"},";
			graph_value_click 	+= "{\"value\":\""+sTotal_click+"\"},";
			Click.append("['"+ sDay_D +"',"+sTotal_click+"],");
			iCount_click++;			
		} 
		rs.close();

		String sSql = "";


		sSql = "SELECT MONTH(send_date) MONTH, sum(rque_count) COUNT FROM ccps_rque_message with(nolock) WHERE YEAR(send_date)="+current_year+" AND cust_id = " + sCustId + " GROUP BY MONTH(send_date) ORDER BY 1 ";
		rs = stmt.executeQuery(sSql);

		int iCount = 0;
		String sDate		=null;
		String sTotal		=null;
		String graph_cat 	= "";
		String graph_val1 	= "";

		while (rs.next())
		{		
			sDate 		= rs.getString(1);
			sTotal 		= rs.getString(2);
			
			graph_cat 	+= "{\"label\":\""+sDate+"\"},";
			graph_val1 	+= "{\"value\":\""+sTotal+"\"},";
			Send_By_Mounth.append("['"+ sDate +"',"+sTotal+"],");
			iCount++;			
		} 
		rs.close();

		String sSql_open_month = "";

		sSql_open_month= "SELECT MONTH(click_time) MONTH, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND YEAR(click_time)="+current_year+" AND cust_id = " + sCustId +" GROUP BY MONTH(click_time) ORDER BY 1";
		rs = stmt.executeQuery(sSql_open_month);

		
		int iCount_open_month = 0;
		String sTotal_open_month 	= "";
		String graph_value_open_month 	= "";

		while (rs.next())
		{		
			sDay_D 				= rs.getString(1);
			sTotal_open_month 	= rs.getString(2);
			
			//graph_cat_d 	+= "{\"label\":\""+sDay_D+"\"},";
			graph_value_open_month 	+= "{\"value\":\""+sTotal_open_month+"\"},";
			Open_Mounth.append("['"+ sDay_D +"',"+sTotal_open_month+"],");

			iCount_open_month++;			
		} 
		rs.close();


		String sSql_click_month = "";

		sSql_click_month= "SELECT MONTH(click_time) MONTH, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND YEAR(click_time)="+current_year+" AND cust_id = " + sCustId +" GROUP BY MONTH(click_time) ORDER BY 1";
		rs = stmt.executeQuery(sSql_click_month);

		
		int iCount_click_month = 0;
		String sTotal_click_month 	= "";
		String graph_value_click_month 	= "";

		while (rs.next())
		{		
			sDay_D 				= rs.getString(1);
			sTotal_click_month 	= rs.getString(2);
			
			//graph_cat_d 	+= "{\"label\":\""+sDay_D+"\"},";
			graph_value_click_month 	+= "{\"value\":\""+sTotal_click_month+"\"},";
			Click_Mounth.append("['"+ sDay_D +"',"+sTotal_click_month+"],");
			iCount_click_month++;			
		} 

		rs.close();


		String sSql_Week = "";


		sSql_Week = "SELECT sum(rque_count) as Total_Recipient, YEAR(send_date) as R_Year FROM ccps_rque_message with(nolock)  WHERE cust_id = " + sCustId + " GROUP BY YEAR(send_date)  ORDER BY YEAR(send_date) ";
		//SELECT sum(_amount) as 'Amount', DATENAME(dw, _order_date_time)  as 'days', DATEPART(dw, _order_date_time) as 'Number' FROM untt_mbs_order with(nolock) GROUP BY DATENAME(dw, _order_date_time), DATEPART(dw, _order_date_time) ORDER BY 3 asc "; 
		//sSql_Week = "select sum(_amount) as Total, CONVERT(VARCHAR(7), _order_date_time, 111) as 'Date ' from untt_mbs_order with(nolock) where _amount is not null group by CONVERT(VARCHAR(7), _order_date_time, 111) order by 2 "; 

		rs = stmt.executeQuery(sSql_Week);

		int iCount2 = 0;
		String sDate_w		=null;
		String sTotal_w		=null;
		String graph_cat_w 	= "";
		String graph_val1_w 	= "";

		while (rs.next())
		{		
			sDate_w 		= rs.getString(1);
			sTotal_w 		= rs.getString(2);
			
			graph_cat_w 	+= "{\"label\":\""+sTotal_w+"\"},";
			graph_val1_w 	+= "{\"value\":\""+sDate_w+"\"},";
			Send_By_Years.append("['"+ sTotal_w +"',"+sDate_w+"],");
			iCount2++;			
		} 

		rs.close();

		String sSql_open_year = "";

		sSql_open_year= "SELECT YEAR(click_time) YEAR, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1  AND cust_id = " + sCustId + " GROUP BY YEAR(click_time) ORDER BY 1";
		rs = stmt.executeQuery(sSql_open_year);

		
		int iCount_open_year = 0;
		String sTotal_open_year 	= "";
		String graph_value_open_year 	= "";

		while (rs.next())
		{		
			sDay_D 				= rs.getString(1);
			sTotal_open_year 	= rs.getString(2);
			
			//graph_cat_d 	+= "{\"label\":\""+sDay_D+"\"},";
			graph_value_open_year 	+= "{\"value\":\""+sTotal_open_year+"\"},";
			Open_Years.append("['"+ sDay_D +"',"+sTotal_open_year+"],");
			iCount_open_year++;			
		} 

		rs.close();

		String sSql_click_year = "";

		sSql_click_year= "SELECT YEAR(click_time) YEAR, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND cust_id = " + sCustId +" GROUP BY YEAR(click_time) ORDER BY 1";
		rs = stmt.executeQuery(sSql_click_year);

		
		int iCount_click_year = 0;
		String sTotal_click_year 	= "";
		String graph_value_click_year 	= "";

		while (rs.next())
		{		
			sDay_D 				= rs.getString(1);
			sTotal_click_year 	= rs.getString(2);
			
			//graph_cat_d 	+= "{\"label\":\""+sDay_D+"\"},";
			graph_value_click_year 	+= "{\"value\":\""+sTotal_click_year+"\"},";
			Click_Years.append("['"+ sDay_D +"',"+sTotal_click_year+"],");
			iCount_click_year++;			
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
		if (stmt!=null) stmt.close();
		if (conn!=null) cp.free(conn);
	}
	catch (SQLException e)
	{
		logger.error("Could not clean db statement or connection", e);
	}
}
		
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
 
  <link rel="stylesheet" href="assets/css/skin-blue.min.css">
  <link rel="stylesheet" href="assets/css/DataTable/dataTables.bootstrap.min.css"> 
    <link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">
  <!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
0  <![endif]-->
 	 
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">

  <style>
	#chartLegend table { margin-left: auto;margin-right: auto; }  
	#chartLegend { text-align:center; }  
	
	#chartLegend-mounth table { margin-left: auto;margin-right: auto; }  
	#chartLegend-mounth { text-align:center; }  

	#chartLegend-all table { margin-left: auto;margin-right: auto; }  
	#chartLegend-all { text-align:center; }  
	.ui-datepicker-calendar { display: none !important; }
 </style>
</head>
<body class="hold-transition">

<div class="wrapper" style="margin-left:20px;margin-right:20px;">
 	 
				<section class="content-header">
				<h1> Message Activity
					<small>Message Activity analytics provides a view of the activity and delivery data of list messages sent during the selected time frame. You can view the activity of an entire email campaign, an individual message, or click through to user level analytics</small>
				</h1>
				 
				</section>
	
		 <br/>
			<div class="row">
						<div class="col-md-3">
						<!-- small box -->
							<div class="small-box b_gri c_beyaz">
							<div class="inner">
							<h3><% out.print(stotal_sent); %></h3>

							<p>SENT</p>
							</div>
							<div class="icon">
							<i class="ion ion-android-mail"></i>
							</div>
							<a href="#" class="small-box-footer"> </a>
						</div>
						</div>
						<!-- ./col -->
						<div class="col-md-3">
						<!-- small box -->
						<div class="small-box b_mavi c_beyaz">
							<div class="inner">
							<h3>% <% out.print(sread_prc); %><sup style="font-size: 20px"></sup></h3>

							<p>OPEN</p>
							</div>
							<div class="icon">
							<i class="ion ion-android-desktop"></i>
							</div>
							<a href="#" class="small-box-footer"> </a>
						</div>
						</div>
						<!-- ./col -->
						<div class="col-md-3">
						<!-- small box -->
						<div class="small-box b_yesil c_beyaz">
							<div class="inner">
							<h3>% <% out.print(sclick_prc); %></h3>

							<p>CLICK</p>
							</div>
							<div class="icon">
							<i class="fa fa-bar-chart"></i>
							</div>
						 	<a href="#" class="small-box-footer"> </a>
						</div>
						</div>
						<!-- ./col -->
						<div class="col-md-3">
						<!-- small box -->
						<div class="small-box b_turuncu c_beyaz">
							<div class="inner">
							<h3>% <% out.print(sbback_prc); %></h3>

							<p>BBACK</p>
							</div>
							<div class="icon">
							<i class="fa fa-user-times"></i>
							</div>
						 	<a href="#" class="small-box-footer"> </a>
						</div>
						</div>
						<!-- ./col -->
						 
      			</div>
	 
</div>

<div class="wrapper" style="margin-left:20px;margin-right:20px;">
 	  
 <div class="row">
 		<div class="col-md-12">
		 
					<div class="box box-primary">
								<div class="box-header">
									 <h3 class="box-title"><b>Daily Activity</b></h3> 
								</div>
								<div class="box-body">
												<form method="post" action="report_list_activity.jsp?cust_id=<%= sCustId%>">
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
													<div class="row">
														<div class="col-md-6">
														<div class="box-header">
															<h3 class="box-title">Send By Day</h3> 
														</div>
														
															<div id="line-send-day" style="height: 300px;"></div> 
														</div>
														<div class="col-md-6" >
																<div class="box-header">
																	<h3 class="box-title">Open/Click by Day</h3> 
																</div>
																<div id="line-open-click" style=" width:98%; height: 300px;"></div> 
																<div   id="chartLegend"></div>
															 
														</div>
													
													</div>
												</form>
												
								</div> 
					</div>
		 
		</div>
		  <!-- md-12 END !-->

		  <div class="col-md-12">
		 
					<div class="box box-primary">
								<div class="box-header">
									 <h3 class="box-title"><b>Monthly Activity</b></h3> 
								</div>
								<div class="box-body">
											 
													 
													<div class="row">
														<div class="col-md-6">
														<div class="box-header">
															<h3 class="box-title">Send By Mounth</h3> 
														</div>
														 	<div id="line-send-mounth" style="height: 300px;"></div> 
														</div>
														<div class="col-md-6" >
																<div class="box-header">
																	<h3 class="box-title">Open/Click by Mounth</h3> 
																</div>
																<div id="line-open-click-mounth" style="width:98%; height: 300px;"></div> 
																<div id="chartLegend-mounth"></div>
															 
														</div>
													
													</div>
											 
												
								</div> 
					</div>
		 
		</div>
		  <!-- md-12 END !-->

		    <div class="col-md-12">
		 
					<div class="box box-primary">
								<div class="box-header">
									 <h3 class="box-title"><b>Yearly Activity</b></h3> 
									 <small>** If the database is less than a uear old, there will be a graph </small>
								</div>
								<div class="box-body">
									  <div id="line-open-click-send" style="width:98%;height: 300px;"></div> 
									  <div id="chartLegend-all"></div> 
							 	</div> 
					</div>
		 
		</div>
		  <!-- md-12 END !-->
		  
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

		var searchMinDate = "-2y";
        var searchMaxDate = "-1m"; 
        if ((new Date()).getDate() <= 5) {
            searchMaxDate = "-2m";
        }
 



	/*
     * Send DATA
     * ----------
     */ 

    var Send =  [<% out.print(Send_By_Day);%>]   
    var Send_data = {  label: "Send Massages",   data : Send,   color: '#D32F2F' }
     
    $.plot('#line-send-day', [Send_data], {
      grid  : { hoverable  : true,  borderColor: '#f3f3f3',    borderWidth: 1,   tickColor  : '#f3f3f3'  },
      series: { shadowSize: 0,lines : {show: true}, points: { show: true }},
      yaxis : {show: true  },   xaxis : {show: true,tickSize:1, tickDecimals:0 }
    })
    //Initialize tooltip on hover
    $('<div class="tooltip-inner" id="line-send-day-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
    $('#line-send-day').bind('plothover', function (event, pos, item) {

      if (item) {
        var x = item.datapoint[0],
            y = item.datapoint[1]

        $('#line-send-day-tooltip').html(item.series.label + ' of ' + x + ' = ' + y)
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)
      } else {
        $('#line-send-day-tooltip').hide()
      }

    })
    /* END LINE CHART */
  

	/*
     * Open Send DATA
     * ----------
     */ 

    var Open =  [<% out.print(Open);%>]  
	var Click =  [<% out.print(Click);%>]   
    var Open_Data = { label: "Open",   data : Open,  color: '#84C446'  }
	var Click_Data = { label: "Click",  data : Click,  color: '#3c8dbc' }
     
    $.plot('#line-open-click', [Open_Data,Click_Data], {
      grid  : {hoverable  : true,   borderColor: '#f3f3f3',   borderWidth: 1,   tickColor  : '#f3f3f3'  },
      series: {shadowSize: 0,lines: {  show: true  }, points: {show: true  } },
	  legend: {noColumns: 2,  container: $("#chartLegend")	},  
	  lines : {fill : false, color: ['#3c8dbc', '#f56954']      },
      yaxis : {show: true  },
      xaxis : {show: true,tickSize:1, tickDecimals:0 }
    })
    //Initialize tooltip on hover
    $('<div class="tooltip-inner" id="line-open-click-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
    $('#line-open-click').bind('plothover', function (event, pos, item) {

      if (item) {
        var x = item.datapoint[0],
            y = item.datapoint[1]

        $('#line-open-click-tooltip').html(item.series.label + ' of ' + x + ' = ' + y)
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)
      } else {
        $('#line-open-click-tooltip').hide()
      }

    })
    /* END LINE CHART */


	/*
     * Mounth Send DATA
     * ----------
     */ 

    var MounthSend =  [<% out.print(Send_By_Mounth);%>]   
    var MounthSend_data = {  label: "Send Massages",   data : MounthSend,   color: '#D32F2F' }
     
    $.plot('#line-send-mounth', [MounthSend_data], {
      grid  : { hoverable  : true,  borderColor: '#f3f3f3',    borderWidth: 1,   tickColor  : '#f3f3f3'  },
      series: { shadowSize: 0,lines : {show: true}, points: { show: true }},
      yaxis : {show: true  },   xaxis : {show: true,tickSize:1, tickDecimals:0}
    })
    //Initialize tooltip on hover
    $('<div class="tooltip-inner" id="line-send-mounth-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
    $('#line-send-mounth').bind('plothover', function (event, pos, item) {

      if (item) {
        var x = item.datapoint[0],
            y = item.datapoint[1]

        $('#line-send-mounth-tooltip').html(item.series.label + ' of ' + x + ' = ' + y)
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)
      } else {
        $('#line-send-mounth-tooltip').hide()
      }

    })
    /* END LINE CHART */

	/*
     * Open Click Mounth DATA
     * ----------
     */ 

    var Open_Mounth =  [<% out.print(Open_Mounth);%>]  
	var Click_Mounth =  [<% out.print(Click_Mounth);%>]   
    var Open_Mounth_Data = { label: "Open",   data : Open_Mounth,  color: '#84C446'  }
	var Click_Mounth_Data = { label: "Click",  data : Click_Mounth,  color: '#3c8dbc' }
     
    $.plot('#line-open-click-mounth', [Open_Mounth_Data,Click_Mounth_Data], {
      grid  : {hoverable  : true,   borderColor: '#f3f3f3',   borderWidth: 1,   tickColor  : '#f3f3f3'  },
      series: {shadowSize: 0,lines: {  show: true  }, points: {show: true  } },
	  legend: {noColumns: 2,  container: $("#chartLegend-mounth")	},  
	  lines : {fill : false, color: ['#3c8dbc', '#f56954']      },
      yaxis : {show: true  },
      xaxis : {show: true, tickSize:1, tickDecimals:0 }
    })
    //Initialize tooltip on hover
    $('<div class="tooltip-inner" id="line-open-click-mounth-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
    $('#line-open-click-mounth').bind('plothover', function (event, pos, item) {

      if (item) {
        var x = item.datapoint[0],
            y = item.datapoint[1]

        $('#line-open-click-mounth-tooltip').html(item.series.label + ' of ' + x + ' = ' + y)
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)
      } else {
        $('#line-open-click-mounth-tooltip').hide()
      }

    })
    /* END LINE CHART */
  
	/*
     * Year Open, Click , Send DATA
     * ----------
     */ 
	var YearsSend =  [<% out.print(Send_By_Years);%>]  
    var Open_Years =  [<% out.print(Open_Years);%>]  
	var Click_Years =  [<% out.print(Click_Years);%>]   

	var Send_Years_Data = { label: "Send",   data : YearsSend,  color: '#D32F2F'  }
    var Open_Years_Data = { label: "Open",   data : Open_Years,  color: '#84C446'  }
	var Click_Years_Data = { label: "Click",  data : Click_Years,  color: '#3c8dbc' }
     
    $.plot('#line-open-click-send', [Send_Years_Data,Open_Years_Data,Click_Years_Data], {
      grid  : {hoverable  : true,   borderColor: '#f3f3f3',   borderWidth: 1,   tickColor  : '#f3f3f3'  },
      series: {shadowSize: 0, lines: {  show: true  }, points: {show: true }},
	  legend: {noColumns: 3,  container: $("#chartLegend-all")	},  
	  lines : {fill : false },
      yaxis : {show: true },
      xaxis : {show: true, tickSize:1, tickDecimals:0 }
    })
    //Initialize tooltip on hover
    $('<div class="tooltip-inner" id="line-open-click-send-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
    $('#line-open-click-send').bind('plothover', function (event, pos, item) {

      if (item) {
        var x = item.datapoint[0],
            y = item.datapoint[1]

        $('#line-open-click-send-tooltip').html(item.series.label + ' of ' + x + ' = ' + y)
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)
      } else {
        $('#line-open-click-send-tooltip').hide()
      }

    })
    /* END LINE CHART */

		  
  })
</script>
</body>
</html>