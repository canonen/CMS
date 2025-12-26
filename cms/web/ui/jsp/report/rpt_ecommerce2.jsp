<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.rcp.*, 
			com.britemoon.rcp.imc.*,
			com.britemoon.rcp.que.*,
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
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%@ include file="../header.jsp" %>
<%
				
String sCustId = request.getParameter("cust_id");

String date1= request.getParameter("date1");
String date2= request.getParameter("date2");


Campaign camp = new Campaign();
camp.s_cust_id = sCustId;

 
	Statement		stmt	= null;
	ResultSet		rs		= null; 
	ConnectionPool	cp		= null;
	Connection		conn	= null;

	String sTotal_Clicks		=null;
	Double sTotal_Clicks_Int	=null;

	String sPurchases		=null;
	Double sTotal_Sales		=null;
	String zTotal_Sales		=null;

	String sTotal_Purchasers			=null;
	Double sTotal_Purchasers_Int		=null;

	Double sAverage_Sales		=null;
	String sCamp_Count			=null;

	Double sConversion_Rate; 
	
	String sConversion_Formated = null;
	
	Double nConversion; 
	String nConversion_Formated = null;
	
	String sAverage_Sales_Formated = null;
	
	
	StringBuilder Revotrack_TR = new StringBuilder();
	String SQL="";

try{

	cp = ConnectionPool.getInstance(sCustId);
	conn = cp.getConnection("rpt_ecommerce.jsp");
	stmt = conn.createStatement();
  
	if(date1==null){
		
	 
		SQL=      " IF OBJECT_ID('tempdb..#camp_id') IS NOT NULL DROP TABLE #camp_id " 
	 		//	 +"	SELECT camp_id into #camp_id FROM rrpt_camp_summary WHERE camp_id in  "
			//	 +"		(   "
				 +"		 SELECT camp_id  into #camp_id  FROM rque_campaign with(nolock) " 
				 +"			WHERE type_id in (2,4) and camp_id in  ( "
				 +"			 		SELECT DISTINCT _camp_id  FROM untt_mbs_order with(nolock) WHERE _amount is not null "  
			//	 +"				 ) " 
				 +"		)  " ;
	}else{
		
		SQL=      " IF OBJECT_ID('tempdb..#camp_id') IS NOT NULL DROP TABLE #camp_id " 
	 		//	 +"	SELECT camp_id into #camp_id FROM rrpt_camp_summary WHERE camp_id in  "
			//	 +"		(   "
	 			 +" 		SELECT camp_id into #camp_id FROM rque_campaign with(nolock) " 
				 +"			WHERE type_id in (2,4) and camp_id in ( "
				 +"				SELECT DISTINCT _camp_id FROM untt_mbs_order with(nolock) WHERE _amount is not null "  
				 +" 				and  _order_date_time BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59' "  
			//	 +"			) " 
				 +"		)  " ;
	 }
 
	
	stmt.executeUpdate(SQL);
	  
	
	SQL =    " IF OBJECT_ID('tempdb..#temp_activity') IS NOT NULL DROP TABLE #temp_activity " 
			+" SELECT camp_id,recip_id,click_time into #temp_activity FROM rjtk_link_activity with(nolock) WHERE camp_id in "
			+" ( SELECT * FROM #camp_id ) "
			+" and type_id = 2";
		if(date1!=null){
			SQL+=" and click_time BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59'   " ; 
		}
		
 
	 stmt.executeUpdate(SQL);		
	 
	SQL = "SELECT count(recip_id) FROM  #temp_activity ";
	 
	rs = stmt.executeQuery(SQL);
 	while(rs.next()){
		sTotal_Clicks 		= rs.getString(1);
		sTotal_Clicks_Int	= rs.getDouble(1);
	}
	rs.close();
	
	if(date1==null){
		 
		SQL=   " SELECT  count( _recipient) as purchases, CAST(ROUND(sum(_amount), 2) AS MONEY) "
			  +" FROM untt_mbs_order with(nolock) "
			  +" WHERE _amount is not null"
			  +" AND _order_id is not null"
			  +" AND _camp_id in (select * from #camp_id) ";
		
	}else{
	 
		SQL=       " SELECT  count( _recipient) as purchases, CAST(ROUND(sum(_amount), 2) AS MONEY) "
				  +" FROM untt_mbs_order  with(nolock) "
				  +" WHERE _amount is not null"
				  +" AND _order_id is not null"
				  +" AND  _camp_id in (select * from #camp_id)"
			 	  +" AND  _order_date_time BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59' " ;
	}
	rs = stmt.executeQuery(SQL);
	while(rs.next()){
		sPurchases 			= rs.getString(1);
		sTotal_Sales		= rs.getDouble(2);				
	}
	rs.close();
	
	
	if(date1==null){
		SQL=	 " SELECT  count(distinct _recipient) as purchases "  
				+" FROM untt_mbs_order " 
				+" WHERE _amount is not null" 
				+" AND _order_id is not null"
				+" AND _camp_id in (select * from #camp_id)";
	}else{
		 
		SQL=	"  SELECT  count(distinct _recipient) as purchases "  
				+" FROM untt_mbs_order " 
				+" WHERE _amount is not null"
				+" AND _order_id is not null"
				+" AND  _camp_id in (select * from #camp_id)"
			 	+" AND  _order_date_time BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59' " ;
	}
	
	rs = stmt.executeQuery(SQL);
	while(rs.next()){

		sTotal_Purchasers 		= rs.getString(1);
		sTotal_Purchasers_Int 	= rs.getDouble(1);
	}
	rs.close();
	
	int iPurchases = Integer.parseInt(sPurchases);
	sAverage_Sales= sTotal_Sales / iPurchases ;
	sAverage_Sales_Formated = String.format("%.2f", sAverage_Sales);
	  
	SQL="select count(camp_id) FROM #camp_id";
	 
	rs = stmt.executeQuery(SQL);
	while(rs.next()){
		sCamp_Count 		= rs.getString(1);
	}
	rs.close();
	
	sConversion_Rate = (100 * sTotal_Purchasers_Int)/sTotal_Clicks_Int;
	sConversion_Formated= String.format("%.2f", sConversion_Rate);
 
	Locale turkish = new Locale("tr", "TR");
	NumberFormat turkishFormat = NumberFormat.getCurrencyInstance(turkish);
	zTotal_Sales = turkishFormat.format(sTotal_Sales);
 
	if(date1==null){
		SQL= "SELECT cc.camp_name,COUNT(mbs._recipient) as purchasers ,COUNT(DISTINCT mbs._recipient) as purchases ,SUM(mbs._amount) total ,  "
			+"	mbs._camp_id, rs.start_date, " 
			+"  (select CASE WHEN COUNT(*)>0 THEN COUNT(*) ELSE 1 END  from #temp_activity  where  camp_id=mbs._camp_id)  as clicks ,"
		//	+" (select   count(camp_id)   from #temp_activity  where  camp_id=mbs._camp_id ) as clicks, "
			+"	cc.type_id,rcs.queue_daily_flag,cc.camp_code  "
			+" FROM untt_mbs_order as mbs with(nolock) "
			+"	INNER JOIN rque_campaign cc with(nolock) on mbs._camp_id=cc.camp_id  "
			+"	INNER JOIN rque_schedule rs with(nolock) on mbs._camp_id=rs.camp_id  "
			+"	INNER JOIN rque_camp_send_param rcs  with(nolock) on mbs._camp_id=rcs.camp_id  " 
			 
			+"WHERE "
			+"	mbs._amount is not null "
			+"      and mbs._order_id is not null"
			+"	and mbs._order_id is not null "
			+"	and cc.type_id in (2,4) "
			 
			+" GROUP BY  mbs._camp_id,cc.camp_name,rs.start_date,rcs.queue_daily_flag,cc.type_id,cc.camp_code  "
			+" ORDER by  mbs._camp_id desc";
		    
		 
	}else{
		
		SQL= "SELECT cc.camp_name,COUNT(mbs._recipient) as purchasers ,COUNT(DISTINCT mbs._recipient) as purchases ,SUM(mbs._amount) total ,  "
				+"	mbs._camp_id, rs.start_date, " 
			 +"  (select CASE WHEN COUNT(*)>0 THEN COUNT(*) ELSE 1 END  from #temp_activity  where  camp_id=mbs._camp_id)  as clicks ,"
				//	+" (select count(camp_id) from #temp_activity where camp_id=mbs._camp_id ) as clicks, "
				+"	cc.type_id,rcs.queue_daily_flag,cc.camp_code  "
				
				+" FROM untt_mbs_order as mbs with(nolock) "
				+"	INNER JOIN rque_campaign cc with(nolock) on mbs._camp_id=cc.camp_id  "
				+"	INNER JOIN rque_schedule rs with(nolock) on mbs._camp_id=rs.camp_id  "
				+"	INNER JOIN rque_camp_send_param rcs  with(nolock) on mbs._camp_id=rcs.camp_id  " 
				+" WHERE "
				+"	mbs._amount is not null "
				+"	and mbs._order_id is not null "
				+"	and mbs._order_id is not null "
				+"	and cc.type_id in (2,4) "
				+"	and mbs._camp_id in ( select * from #camp_id ) " 
				+" AND  mbs._order_date_time BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59'"
				+" GROUP BY  mbs._camp_id,cc.camp_name,rs.start_date,rcs.queue_daily_flag,cc.type_id,cc.camp_code  "
				+" ORDER by  mbs._camp_id desc";
 	 
	 	  
	}
	 
	rs = stmt.executeQuery(SQL);
	int iCount = 0;
	String sClassAppend = "_other";


	String sCamp_Name			=null;
	String sCamp_Purchasers		=null;
	String sCamp_Purchases		=null;
	BigDecimal sCamp_Sales		=null;
	String zCamp_Sales			=null;
	String sCamp_ID				=null;
	String zCamp_Start_Date		=null;
	String sClicks				=null;
	String sConversion			=null;
	String sType_ID				=null;
	String sDaily_Flag			=null;
	String sDisplay_Type		=null;
	String sCamp_Code			=null;
	
	
	ResultSetMetaData rsmd = rs.getMetaData();
	int nColumns = rsmd.getColumnCount();

				while(rs.next()){
					if (iCount % 2 != 0) sClassAppend = "_other";
					else sClassAppend = "";
					iCount++;
					
					sCamp_Name 	 				= new String(rs.getBytes(1),"UTF-8");
					sCamp_Purchasers 			= rs.getString(2);
					sCamp_Purchases 			= rs.getString(3);
					
				 	sCamp_Sales	 				= rs.getBigDecimal(4);
				 	if(rs.getString(4)==null){
				 		sCamp_Sales=new BigDecimal("0.00");
					}
				 	
					sCamp_Sales 				= sCamp_Sales.setScale(2, BigDecimal.ROUND_HALF_UP);
					zCamp_Sales					= turkishFormat.format(sCamp_Sales);
				 
					
					sCamp_ID	 			= rs.getString(5);
					zCamp_Start_Date	 	= rs.getString(6);
					sClicks	 				= rs.getString(7);
				//	sConversion	 			= rs.getString(8);
					sType_ID	 			= rs.getString(8);
					sDaily_Flag	 			= rs.getString(9);
					sCamp_Code	 			= rs.getString(10);
					
					int intPurchases = Integer.parseInt(sCamp_Purchases);
					int intClicks = Integer.parseInt(sClicks);
					
					nConversion=(100.0 * intPurchases) /  intClicks;
					nConversion_Formated= String.format("%.2f", nConversion);
					
					if(sCamp_Code ==null){
						//out.print("ssss");
						sCamp_Code ="-";
					}

					
					if(sType_ID.equals("4")) {
						//out.print("ssss");
						sDisplay_Type ="Automated";
					}

					if(sType_ID.equals("2")) {
						sDisplay_Type ="Standard";
					}					
					
					
					//if(sType_ID.equals("2") && sDaily_Flag.equals("1")) {
					if (sType_ID.equals("2") ){
						if(sDaily_Flag !=null){
							sDisplay_Type ="Check Daily";
						}
					}	
					 				
					String t="<tr>"
							+" <td class='list_row"+ sClassAppend +"'>"
							+" <a href='http://cms.revotas.com/cms/ui/jsp/index.jsp?tab=Camp&sec=1&url=report%2Freport_object.jsp%3Fact%3DVIEW%26id%3D"+ sCamp_ID+"' target='_parent'>"+sCamp_Name+"</a>"
							+" </td>"
							+" <td class='list_row"+ sClassAppend +"'>"+sDisplay_Type +"</td>"
							+" <td class='list_row"+ sClassAppend +"'>"+sCamp_Code +"</td>"
							+" <td class='list_row"+ sClassAppend +"'>"+sClicks+"</td>"
							+" <td class='list_row"+ sClassAppend+"'>"+ sCamp_Purchases  +"</td>"
							+" <td class='list_row"+ sClassAppend +"'>"+ sCamp_Purchasers +"</td>"
							+" <td class='list_row"+ sClassAppend +"'>"+ nConversion_Formated +"</td>"
							+" <td class='list_row"+ sClassAppend +"'>"+ zCamp_Sales+"</td>"
							+" <td class='list_row"+ sClassAppend +"'>"+ zCamp_Start_Date +"</td>"
						+"</tr>";	

					Revotrack_TR.append(t);
					 					
				}
				rs.close();				
		 	
				
			SQL= "DROP TABLE #temp_activity  DROP TABLE #camp_id";
		 	stmt.executeUpdate(SQL);
				

 }
catch(Exception ex){	ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);}
finally{
	try	{if (stmt != null) stmt.close();if (conn != null) cp.free(conn);}
	catch (SQLException e)	{logger.error("Could not clean db statement or connection", e);	}
}
 
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Revotrack</title> 
  <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
  <link rel="stylesheet" href="assets/css/bootstrap.min.css">
 
  <link rel="stylesheet" href="assets/css/font-awesome.min.css">
 
  <link rel="stylesheet" href="assets/css/ionicons.min.css">
 
   <link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">  
 
  <link rel="stylesheet" href="assets/css/AdminLTE.css">
  <link rel="stylesheet" href="assets/css/Style.css">
 
  <link rel="stylesheet" href="assets/css/skin-blue.min.css">
  <link rel="stylesheet" href="assets/css/DataTable/dataTables.bootstrap.min.css">
 
  <!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->

  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">
  
  <style>
  .rltv{ 	position:relative;  }
  .test{
  	position:absolute;
  	top:25px;
  	right:15px;
  }
  
  .daterangepicker {  right:19px !important; }
  </style>
</head>
<body class="hold-transition">
 
 <div class="wrapper" style="margin-left:20px;margin-right:20px;">
 	 
				<section class="content-header">
				<h1>
					Revotrack
					<small>The stats are based on all revenue generated from Revotrack</small>
				</h1>
				 
				</section>
	
		 <br/>
			<div class="row">
						<div class="col-md-12 text-center rltv">
							<h1><b><% out.print(zTotal_Sales); %></b></h1>
							 
									<div class="test input-group">
									    <button type="button" class="btn btn-default pull-right" id="daterange-btn" >
												<span><i class="fa fa-calendar"></i> Date range </span><i class="fa fa-caret-down"></i>
										  </button>
									</div>
 							<br/>
						
						</div>
						<div class="col-md-4">
						<!-- small box -->
							<div class="small-box b_gri c_beyaz">
							<div class="inner">
							<h3><% out.print(sCamp_Count); %></h3>

							<p>CAMPAIGN COUNT</p>
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
							<h3><%  out.print(sTotal_Clicks); %><sup style="font-size: 20px"></sup></h3>

							<p>CLICKS</p>
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
							<h3><%   out.print(sPurchases ); %></h3>

							<p>ORDERS</p>
							</div>
							<div class="icon">
							<i class="fa  fa-shopping-cart"></i>
							</div>
						 	<a href="#" class="small-box-footer"> </a>
						</div>
						</div>
						<!-- ./col -->
						 
      			</div>

				<div class="row">
						<div class="col-md-4">
						<!-- small box -->
							<div class="small-box b_turuncu c_beyaz">
							<div class="inner">
							<h3><% out.print(sTotal_Purchasers); %></h3>

							<p>CUSTOMERS</p>
							</div>
							<div class="icon">
							<i class="fa fa-users"></i>
							</div>
							<a href="#" class="small-box-footer"> </a>
						</div>
						</div>
						<!-- ./col -->
						<div class="col-md-4">
						<!-- small box -->
						<div class="small-box b_pembe c_beyaz">
							<div class="inner">
							<h3><%  out.print(sConversion_Formated); %><sup style="font-size: 20px"></sup></h3>

							<p>CONVERSION</p>
							</div>
							<div class="icon">
							<i class="fa fa-area-chart"></i>
							</div>
							<a href="#" class="small-box-footer"> </a>
						</div>
						</div>
						<!-- ./col -->
						<div class="col-md-4">
						<!-- small box -->
						<div class="small-box b_mor c_beyaz">
							<div class="inner">
								<h3><%   out.print(sAverage_Sales_Formated ); %></h3>
 								<p>AVERAGE SALES</p>
							</div>
							<div class="icon">
							<i class="fa fa-signal"></i>
							</div>
						 	<a href="#" class="small-box-footer"> </a>
						</div>
						</div>
						<!-- ./col -->
						 
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
														<th>Campaign Name</th>
														<th>Campaign Type</th>
														<th>Auto</th>
														<th>Clicks</th>
														<th>Customers</th>
														<th>Orders</th>
														<th>Conversion</th>
														<th>Sales</th>
														<th>Start Date</th>
												 	</tr>
													</thead>
													<tbody>
												 		<% out.print(Revotrack_TR); %>
													</tbody>
													
												</table>
											</div>
           
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
<script src="assets/js/Flot/jquery.flot.pie.js"></script> 
<script src="assets/js/Flot/jquery.flot.categories.js"></script>

<script src="assets/js/daterangepicker/moment.min.js"></script>
<script src="assets/js/daterangepicker/daterangepicker.js"></script>

<script src="assets/js/DataTable/jquery.dataTables.min.js"></script>
<script src="assets/js/DataTable/dataTables.bootstrap.min.js"></script>
<script src="assets/js/DataTable/jquery.slimscroll.min.js"></script>
 


<!-- page script -->
<script>

	function post(path, params, method) {
	    method = method || "GET"; // Set method to post by default if not specified.
	
	    // The rest of this code assumes you are not using a library.
	    // It can be made less wordy if you use one.
	    var form = document.createElement("form");
	    form.setAttribute("method", method);
	    form.setAttribute("action", path);
	
	    for(var key in params) {
	        if(params.hasOwnProperty(key)) {
	            var hiddenField = document.createElement("input");
	            hiddenField.setAttribute("type", "hidden");
	            hiddenField.setAttribute("name", key);
	            hiddenField.setAttribute("value", params[key]);
	 			form.appendChild(hiddenField);
	        }
	    }
	
	    document.body.appendChild(form);
	    form.submit();
	}

  $(function () {
	   
	  	<%if(date1!=null) {%>
		  	var start   = moment('<%=date1%>');
			var end 	= moment('<%=date2%>'); 
	  	<%}else{%>
	  		var start   = moment();
			var end 	= moment().endOf('year');
		<%}%>
			  	
		 	$('#daterange-btn').daterangepicker(
			 {
			  ranges   : {
		          'ALL'       	: [moment(), moment().endOf('year')],
		          'Today'       : [moment(), moment()],
		          'Yesterday'   : [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
		          'Last 7 Days' : [moment().subtract(6, 'days'), moment()],
		          'Last 30 Days': [moment().subtract(29, 'days'), moment()],
		          'This Month'  : [moment().startOf('month'), moment().endOf('month')],
		          'Last Month'  : [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
		        },
	         	  startDate: 	start,
	       		  endDate  :	end
		      },
		      function (start, end,label) {
		         	if(label=='ALL'){
		 				 post('rpt_ecommerce.jsp', {'cust_id':'<%=sCustId%>'});
		 			}else{
		 				 $('#daterange-btn span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'))
		 		   		 var date1=start.format('YYYY-MM-D');
			 			 var date2=end.format('YYYY-MM-D');	
			 			 post('rpt_ecommerce.jsp', {'cust_id':'<%=sCustId%>','date1':date1,'date2':date2});
		 			 }
		 	  	
		 	   }
				
		    )
		   
	  
 	 	 
  jQuery.extend( jQuery.fn.dataTableExt.oSort, {
      "currency-pre": function ( a ) {
  		a=a.replace(/\./g, '').replace(/\,/g, '');
          a = (a==="-") ? 0 : a.replace( /[^\d\-\.]/g, "" );
          return parseFloat( a );
      },
      "currency-asc": function ( a, b ) {
          return a - b;
      },
      "currency-desc": function ( a, b ) {
          return b - a;
      }
} );
  
  
   
    $('#example2').DataTable({
 	"lengthMenu": [[10, 25, 50,100, -1], [10, 25, 50,100, "All"]],
      'paging'      : true,
      'lengthChange': true,
      'searching'   : true,
      'ordering'    : true,
      'info'        : true,
      'autoWidth'   : true,
      'columnDefs' : [
      		   { targets: 7, type: 'currency' }
		  ]
    })
  })
</script>


</body>
</html>