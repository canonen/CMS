<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.rcp.*, 
			com.britemoon.rcp.imc.*,
			com.britemoon.rcp.que.*,
			java.sql.*,
			java.util.Calendar,
			java.io.*,
			org.apache.log4j.Logger,
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
  
<%

String sCustId = request.getParameter("cust_id");
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
current_month_cal = current_month ;
current_day = calendar.get(Calendar.DAY_OF_MONTH); 
 
 
	Statement				stmt	= null;
	ResultSet				rs		= null; 
	ConnectionPool	cp		= null;
	Connection			conn	= null;

	String NewUsers ="";

	String Labelday ="";
	String UnsubUser ="";

	String WeekUser ="";
  String WeekUnsub ="";
	String Labelweek ="";

	String YearUser ="";
	String YearUnsub ="";
	String Labelyear ="";

	String YearOption="";

try{
	cp = ConnectionPool.getInstance(sCustId);
	conn = cp.getConnection(this);
	stmt = conn.createStatement();
     System.out.println("SASSSSSSA");
	String sSql_day = "";


	if(d_startdate!=null){
	
		sSql_day = "SELECT DAY(create_date) DAY, COUNT(*) COUNT FROM rrcp_recipient with(nolock) WHERE create_date >='"+d_startdate+"' AND create_date<='"+d_enddate+"' GROUP BY DAY(create_date) ORDER BY 1 ";
	
	}else{
		sSql_day = "SELECT DAY(create_date) DAY, COUNT(*) COUNT FROM rrcp_recipient with(nolock) WHERE MONTH(create_date)='"+current_month_cal+"' AND YEAR(create_date)='"+current_year+"' GROUP BY DAY(create_date) ORDER BY 1 ";
	
	}
	  
	rs = stmt.executeQuery(sSql_day);

	int iCount_D = 0;
	String sDay_D		=null;
	String sTotal_D		=null;
	String graph_cat_d 	= "";
	String graph_val1_d 	= "";

 
	while (rs.next())
	{		
		sDay_D 		= rs.getString(1);
		sTotal_D 	= rs.getString(2);
		 
		NewUsers +="['"+ sDay_D +"',"+sTotal_D+"],";
		Labelday +="['"+ sDay_D +"',"+sDay_D+"],";
		iCount_D++;			
	} 
 	  
	rs.close();
	
	String sSql_unsubday = "";
 
 	if(d_startdate!=null){
	
		sSql_unsubday = "SELECT DAY(unsub_date) DAY, COUNT(*) COUNT FROM rrpt_recip_unsub with(nolock) WHERE unsub_date >='"+d_startdate+"' AND unsub_date<='"+d_enddate+"' GROUP BY DAY(unsub_date) ORDER BY 1 ";
	
	}else{
		sSql_unsubday = "SELECT DAY(unsub_date) DAY, COUNT(*) COUNT FROM rrpt_recip_unsub with(nolock) WHERE MONTH(unsub_date)="+current_month_cal+" AND YEAR(unsub_date)="+current_year+" GROUP BY DAY(unsub_date) ORDER BY 1";
	
	}
	 
	rs = stmt.executeQuery(sSql_unsubday);
 	
	int iCount_unsub = 0;
	String sTotal_unsub 	= "";
	String sTotal_day 	= ""; 
	String graph_value_unsub 	= "";

	while (rs.next())
	{		 
		sTotal_day 	= rs.getString(1);
		sTotal_unsub 	= rs.getString(2);
		 
		UnsubUser +="['"+ sTotal_day +"',"+sTotal_unsub+"],";
		iCount_unsub++;			
	} 
 
 rs.close();
 
int YearCount=1; 
 
 if(MonthlyGrowth==null){
	 MonthlyGrowth = new Integer(current_year).toString();
 }
	
String sSql_UserYear="SELECT YEAR(create_date)  FROM rrcp_recipient with(nolock)  GROUP BY YEAR(create_date) ORDER BY 1 ";
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
 

String sSql_User_Week = "";
   			sSql_User_Week="IF Object_ID('TempDB..#MONTH_RECIP') IS NOT NULL  DROP TABLE #MONTH_RECIP "
									+"CREATE TABLE #MONTH_RECIP(  MONTH VARCHAR (100),  COUNT VARCHAR (100) )   "  
									+" INSERT INTO #MONTH_RECIP "
									+" SELECT '01', count(*)  from  rrcp_recipient where MONTH(create_date)=01 and YEAR(create_date)="+MonthlyGrowth+" UNION ALL "
									+" SELECT '02', count(*)  from  rrcp_recipient where MONTH(create_date)=02 and YEAR(create_date)="+MonthlyGrowth+" UNION ALL "
									+" SELECT '03', count(*)  from  rrcp_recipient where MONTH(create_date)=03 and YEAR(create_date)="+MonthlyGrowth+" UNION ALL "
									+" SELECT '04', count(*)  from  rrcp_recipient where MONTH(create_date)=04 and YEAR(create_date)="+MonthlyGrowth+" UNION ALL "
									+" SELECT '05', count(*)  from  rrcp_recipient where MONTH(create_date)=05 and YEAR(create_date)="+MonthlyGrowth+" UNION ALL "
									+" SELECT '06', count(*)  from  rrcp_recipient where MONTH(create_date)=06 and YEAR(create_date)="+MonthlyGrowth+" UNION ALL "
									+" SELECT '07', count(*)  from  rrcp_recipient where MONTH(create_date)=07 and YEAR(create_date)="+MonthlyGrowth+" UNION ALL "
									+" SELECT '08', count(*)  from  rrcp_recipient where MONTH(create_date)=08 and YEAR(create_date)="+MonthlyGrowth+" UNION ALL " 
									+" SELECT '09', count(*)  from  rrcp_recipient where MONTH(create_date)=09 and YEAR(create_date)="+MonthlyGrowth+" UNION ALL "
									+" SELECT '10', count(*)  from  rrcp_recipient where MONTH(create_date)=10 and YEAR(create_date)="+MonthlyGrowth+" UNION ALL "
									+" SELECT '11', count(*)  from  rrcp_recipient where MONTH(create_date)=11 and YEAR(create_date)="+MonthlyGrowth+" UNION ALL "
									+" SELECT '12', count(*)  from  rrcp_recipient where MONTH(create_date)=12 and YEAR(create_date)="+MonthlyGrowth+" "
					+" SELECT * FROM #MONTH_RECIP";

String sSql_Unsub_Week = "";
					sSql_Unsub_Week= "	IF Object_ID('TempDB..#MONTH_UNSUB') IS NOT NULL  DROP TABLE #MONTH_UNSUB "
											+"CREATE TABLE #MONTH_UNSUB(  MONTH VARCHAR (100),  COUNT VARCHAR (100) )  "
											+"INSERT INTO #MONTH_UNSUB "
											+"SELECT '01', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=01 and YEAR(unsub_date)="+MonthlyGrowth+" UNION ALL "
											+"SELECT '02', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=02 and YEAR(unsub_date)="+MonthlyGrowth+" UNION ALL "
											+"SELECT '03', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=03 and YEAR(unsub_date)="+MonthlyGrowth+" UNION ALL "
											+"SELECT '04', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=04 and YEAR(unsub_date)="+MonthlyGrowth+" UNION ALL "
											+"SELECT '05', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=05 and YEAR(unsub_date)="+MonthlyGrowth+" UNION ALL "
											+"SELECT '06', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=06 and YEAR(unsub_date)="+MonthlyGrowth+" UNION ALL "
											+"SELECT '07', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=07 and YEAR(unsub_date)="+MonthlyGrowth+" UNION ALL "
											+"SELECT '08', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=08 and YEAR(unsub_date)="+MonthlyGrowth+" UNION ALL "
											+"SELECT '09', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=09 and YEAR(unsub_date)="+MonthlyGrowth+" UNION ALL "
											+"SELECT '10', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=10 and YEAR(unsub_date)="+MonthlyGrowth+" UNION ALL "
											+"SELECT '11', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=11 and YEAR(unsub_date)="+MonthlyGrowth+" UNION ALL "
											+"SELECT '12', count(*)  from  rrpt_recip_unsub where MONTH(unsub_date)=12 and YEAR(unsub_date)="+MonthlyGrowth+" " 
							+"SELECT * FROM #MONTH_UNSUB ";
		 
rs = stmt.executeQuery(sSql_User_Week);

int iCount2 = 0;
String sDate_w		=null;
String sTotal_w		=null;
String graph_cat_w 	= "";
String graph_val1_w 	= "";

while (rs.next())
{		
	sDate_w 		= rs.getString(1);
	sTotal_w 		= rs.getString(2);
	 
	WeekUser +="['"+ sDate_w +"',"+sTotal_w+"],";
 
	Labelweek +="['"+ sDate_w +"',"+sDate_w+"],";
	iCount2++;			
}  
rs.close();

rs = stmt.executeQuery(sSql_Unsub_Week);
while (rs.next())
{		
	sDate_w 		= rs.getString(1);
	sTotal_w 		= rs.getString(2);
	 
	WeekUnsub +="['"+sDate_w +"',"+sTotal_w+"],";
	iCount2++;			
} 
rs.close(); 


 
	
	String sSql_years = "SELECT COUNT(*) as Total_Recipient, YEAR(create_date) as R_Year FROM rrcp_recipient with(nolock) GROUP BY YEAR(create_date)  ORDER BY YEAR(create_date) ";	
		rs = stmt.executeQuery(sSql_years);
 
		while (rs.next()) {		
			sDate_w 		= rs.getString(1);
			sTotal_w 		= rs.getString(2);
			
			YearUser +="['"+ sTotal_w +"',"+sDate_w+"],";
		
			Labelyear +="['"+ sTotal_w +"',"+sTotal_w+"],";
			iCount2++;			
		}  
	rs.close();


	String 	sSql_unsub_years= "SELECT YEAR(unsub_date) YEAR, COUNT(*) COUNT FROM rrpt_recip_unsub with(nolock)  GROUP BY YEAR(unsub_date) ORDER BY 1";
	   rs = stmt.executeQuery(sSql_unsub_years);
 
		while (rs.next()) {		
			sDate_w 		= rs.getString(1);
			sTotal_w 		= rs.getString(2);
			
			YearUnsub +="['"+ sDate_w +"',"+sTotal_w+"],";
		 
			iCount2++;			
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
  <![endif]-->
 	 
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">
</head>
<body class="hold-transition">

<div class="wrapper" style="margin-left:20px;margin-right:20px;">
 	 
			<section class="content-header"><br/>
				<h1>
					Over-Time DB Size Visualizations
					<small> Chart below indicates database growth over time</small>
				</h1> 
					<br/><br/>
	 		</section>
 <div class="row">
 		<div class="col-md-6">
		 
					<div class="box box-primary">
								<div class="box-header">
										<h3 class="box-title">Daily Growth</h3> 
								</div>
								<div class="box-body">
												<form method="post" action="report_db_growth.jsp?cust_id=<%= sCustId%>">
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
									<div class="box-header">
											<h3 class="box-title">Monthly Growth</h3> 
									</div>
									<div class="box-body">
													<form method="post" action="report_db_growth.jsp?cust_id=<%= sCustId%>">
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
												 
														<div id="bar-chart-week" style=" width:80%;height: 300px;"></div>

													 
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
								<h3 class="box-title">Yearly Growth</h3>
								<small>** If the database is less than a uear old, there will be a graph </small>
							</div>
							<div class="box-body">
								<div id="bar-chart-years" style=" width:40%; height: 300px;"></div>
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

	 
	var d1=[<% out.print(NewUsers);%>];
	var d2=[<% out.print(UnsubUser);%>];
	var label=[<% out.print(Labelday);%>];
	  
   var css_id = "#bar-chart";
	 var data = [
        {label: 'User', data: d1},
        {label: 'Unsub', data: d2}, 
    ];
 
    var options = {
        grid  : {	hoverable  : true,borderWidth: 1,borderColor: '#f3f3f3',tickColor  : '#f3f3f3' },
				series: {	shadowSize: 0,  stack: 1,	lines: {show: false, 	steps: false}, bars: {show : true, barWidth: 0.5, align : 'center'	}	},
				xaxis: {ticks: label},	 
				colors: ["#84C446","#E66EAA"]
    };
 
    $.plot($(css_id), data, options); 
    $('<div class="tooltip-inner" id="bar-chart-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
    $('#bar-chart').bind('plothover', function (event, pos, item) {
	 
      if (item) {
       

 					var x = item.datapoint[0],
            y = item.datapoint[1],
						t = item.datapoint[2]
				if(t!=0){
						var sonuc=Math.abs(t-y);
						$('#bar-chart-tooltip').html(sonuc)
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)

				}else{

					$('#bar-chart-tooltip').html( y)
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)

				}	
      
      } else {
        $('#bar-chart-tooltip').hide()
      }

    })

	 

	 	var w1=[<% out.print(WeekUser);%>];
		var w2=[<% out.print(WeekUnsub);%>];
		var labelweek=[<% out.print(Labelweek);%>];
	  
   var cssweek = "#bar-chart-week";
	 var dataweek = [
        {labelweek: 'User', data: w1},
        {labelweek: 'Unsub', data: w2}, 
    ];

		var optionsweek = {
        grid  : {	hoverable  : true,borderWidth: 1,borderColor: '#f3f3f3',tickColor  : '#f3f3f3' },
				series: {	shadowSize: 0,  stack: 1,	lines: {show: false, 	steps: false}, bars: {show : true, barWidth: 0.5, align : 'center'	}	},
				xaxis: {ticks: labelweek},	 
				colors: ["#84C446","#E66EAA"]
    };
 
    $.plot($(cssweek), dataweek, optionsweek); 
    $('<div class="tooltip-inner" id="bar-chart-week-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
		 $('#bar-chart-week').bind('plothover', function (event, pos, item) {
	 
      if (item) {
        var x = item.datapoint[0],
            y = item.datapoint[1],
						t = item.datapoint[2]
				if(t!=0){
						var sonuc=Math.abs(t-y);
						$('#bar-chart-week-tooltip').html(sonuc )
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)

				}else{

				$('#bar-chart-week-tooltip').html( y)
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)

				}
        
      } else {
        $('#bar-chart-week-tooltip').hide()
      }

    })


		var y1=[<% out.print(YearUser);%>];
		var y2=[<% out.print(YearUnsub);%>];
		var labelyears=[<% out.print(Labelyear);%>];
	  
   var cssyears = "#bar-chart-years";
	 var datayears = [
        {labelyears: 'User', data: y1},
        {labelyears: 'Unsub', data: y2}, 
    ];

		var optionsyears = {
        grid  : {	hoverable  : true,borderWidth: 1,borderColor: '#f3f3f3',tickColor  : '#f3f3f3' },
				series: {	shadowSize: 0,  stack: 1,	lines: {show: false, 	steps: false}, bars: {show : true, barWidth: 0.5, align : 'center'	}	},
				xaxis: {ticks: labelyears},	 
				colors: ["#84C446","#E66EAA"]
    };
 
    $.plot($(cssyears), datayears, optionsyears); 
    $('<div class="tooltip-inner" id="bar-chart-years-tooltip"></div>').css({
      position: 'absolute',
      display : 'none',
      opacity : 0.8
    }).appendTo('body')
		 $('#bar-chart-years').bind('plothover', function (event, pos, item) {
	 
      if (item) {
        var x = item.datapoint[0],
            y = item.datapoint[1],
						t = item.datapoint[2]
				if(t!=0){
						var sonuc=Math.abs(t-y);
						$('#bar-chart-years-tooltip').html(sonuc )
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)

				}else{

				$('#bar-chart-years-tooltip').html( y)
          .css({ top: item.pageY + 5, left: item.pageX + 5 })
          .fadeIn(200)

				}
        
      } else {
        $('#bar-chart-years-tooltip').hide()
      }

    })
		  
  })
</script>
</body>
</html>