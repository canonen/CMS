<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.adm.*,
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
 
ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null; 

boolean DURUM=false;
String ContentHTML="";
String Error="";

StringBuilder RETURN_Table = new StringBuilder();
	String reportName = "";
	String SubjectLine = "";
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	int nPos = 0;

	String reportDate = "";
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

			byte[] bVal2 = rs.getBytes("SubjectLine");
			SubjectLine = (bVal2!=null?new String(bVal2,"UTF-8"):"");

			reportDate = rs.getString("StartDate");
		}
		rs.close();
	}

	if ((sCampID == null) || ("".equals(sCampID)) || (numRecs < 1))
	{
		DURUM=true;
		Error="No Campaign for that ID";

	}else
	{
		
	 
		 
			String sSqlSinan ="";
			String Cont_ID="";
			int Link_ID=0;
			int Tot_Html_Clicks=0;
			String Link_Name ="";
			String Href ="";
			int  Toplam_Link_Sayisi=0;
			int  Toplam_Click_Sayisi=0;
			int  Ortalama=0;
		
		 
				sSqlSinan = 
				"select   l.cont_id as Cont_ID, c.tot_html_clicks as Tot_Html_Clicks, l.href as Href,"+
			 	"(select count(*) from crpt_camp_link where camp_id="+ sCampID +" and tot_html_clicks!=0) Count1,"+
				"(select SUM(tot_html_clicks) from crpt_camp_link where   camp_id="+sCampID+"  and  tot_html_clicks!=0) Count2 "+
				"from crpt_camp_link c , cjtk_link l "+ 
			 	"where c.link_id=l.link_id and c.camp_id="+sCampID+" and c.tot_html_clicks!=0";
			
		
					rs = stmt.executeQuery(sSqlSinan);
			 
					RETURN_Table.append("<table style='display:none'  width=100% class=listTable   id=sinan cellspacing=0 cellpadding=0>");	 
					while (rs.next()) {
					
						Cont_ID = rs.getString(1);
					 
					    RETURN_Table.append("<tr><td>" + rs.getInt("Tot_Html_Clicks") + "</td>");	
						RETURN_Table.append("<td>" + rs.getString("Href") + "</td> ");	
						RETURN_Table.append("<td>" + rs.getInt("Count1") + "</td> ");	
						RETURN_Table.append("<td>" + rs.getInt("Count2") + "</td> </tr>");	 
				 
						 
						 
					}

					RETURN_Table.append("</table>");
			 
					
					rs.close();
		 
			if (Cont_ID == null)
			{
				DURUM=true; 
				Error="Enter formula values above and then select preview type.";
				 
			}
		
			 
			Content cont = new Content();
			cont.s_cont_id = Cont_ID;
			if(cont.retrieve() < 1){ 
				
				DURUM=true; 
				Error="Raporu Update Edin.";
			 	
			}else{
					ContBody cont_body = new ContBody(Cont_ID);
				
					String htmlPart = cont_body.s_html_part;
			
					if(htmlPart == null) htmlPart = " ";
 
			 
					ContentHTML=htmlPart;
		 	}
		 
		
		
		
	 
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
  <title> Report HeatMap</title> 
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

<body class="hold-transition" style="background-color:none !important;"  >
 
   <% if(DURUM){	%>	 
		
	<div class="wrapper" style="margin-left:20px;margin-right:20px;">
			<div class="row">
					<div class="col-md-4" ></div>			
					<div class="col-md-4" >
 							<div align="center" class="alert alert-warning alert-dismissible">
					 			<h4 ><i class="icon fa fa-warning"></i> Warning!</h4>
									<%=Error%>
							</div>
 	  				</div>
					<div class="col-md-4" ></div>
			</div>
		</div>
	<% }else{ %>
 
  
 <div class="wrapper" style="margin-top:10px;margin-left:20px;margin-right:20px;">
    
    <div class="row">
        <div class="col-md-12">
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs" style="font-family: 'Source Sans Pro', sans-serif !important;font-weight: 400  !important;">
                  
					<li><a href="report_object.jsp?id=<%=sCampID%>" >Campaign Results</a></li>
                    <li><a href="report_cache_list.jsp?Q=<%=sCampID%>" >Demographic Or Time Report</a></li>
                    <li><a href="report_time.jsp?Q=<%=sCampID%>">Activity vs. Time Report</a></li>  
					<li><a href="report_track.jsp?Q=<%=sCampID%>"  >RevoTrack Results</a></li>
                    <li  class="active"><a href="javascript:void(null);" >HeatMap</a></li>  
                </ul>
            </div> 
        </div>
    </div>
  
 </div>
 
 <section class="content">
       <div class="row">
	      <div class="col-md-12">
		  	<%=RETURN_Table%>
		  </div>	
          <div class="col-md-12" >
                <div class="box box-primary">
							<div class="box-header with-border">
								<h3 class="box-title">HeatMap</h3>
								
							</div>
							 
							<div class="box-body"  style="font-family: 'Source Sans Pro', sans-serif !important;font-weight: 400  !important;">
							 
								<table>
									 
									<tr>
										<td>Campaign Name </td>
										<td>:<b><%= reportName %></b></td>
									</tr>
									<tr>
										<td>Subject Name </td>
										<td>:<b><%= SubjectLine %></b></td>
										 
									</tr>
								 	
								</table>
							</div>
                </div><!-- /.box box-primary -->
		 </div><!-- /.col-md-12 End -->
		 
         <div class="col-md-12" >
			<div class="box box-primary">
							<div class="box-header with-border">
								<h3 class="box-title">Report Summary</h3>
							</div>
							<div class="box-body">
								  <div class="row">
									 <div class="col-md-12" >
										
												 <div class="heatmap" id="report_heatmap_main" >

															  	<%=ContentHTML %> 

</div>	
													
									 </div>
								 </div>
							</div>
			</div><!-- /.box box-primary -->
		 </div><!-- /.col-md-12 End -->
		 
		 
      </div><!-- /.row END -->

 </section>
 

 
 
 
 
 
 <style>
	 
	body {background-color: #fff !important;  }

 </style>
 
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

<script type="text/javascript" src="heatmap-js/heatmap.js"></script> 

<script language="javascript">
	
	$( document ).ready(function() {
		heatMap()
	});
	
	$( window ).resize(function() {
		
		$('canvas' ).each(function(){
			var canvas=this;
			 canvas.remove();
		});
		
		$('.tooltip' ).each(function(){
			var tooltip=this;
			 tooltip.remove();
		});
		heatMap()
	});
	
	function heatMap(){
		 
	
		$('#mobile').remove();
		$('#coupon').remove();
	 	
		//var newHTML = $('#report_heatmap_main').clone().find("body").remove().end().html();
		
		//console.log(newHTML);
		//title.append('<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10">');
  
	var sayac=0;
	var toplam_clicks=0;
	var href;
	 
	var ContentHeight = document.getElementById('report_heatmap_main');
	      if(ContentHeight) {
		    var ContentHeight=document.getElementsByTagName("html")[0].scrollHeight
		   
	  }   
	
	$('#report_heatmap_main a' ).each(function(){	
	 
		
			var link=$(this);
			var href = $(this).attr('href');
			$(this).click(false);	 
			var Img=$(this).find('img').attr('src');
			
			if(Img){
				
			 var height = $(this).parent().find("img").height();	
			 var width = $(this).parent().find("img").width(); 
			 var imgposition =$(this).find("img").position();
			  
			 	  $('#sinan tr').each(function() {
				   		 
				   	   var urlKontrol = $(this).find("td").eq(1).text();
				   	   
				   	   
				   	  	if(urlKontrol==href){
				   	   	 
				   	   		var sayi = $(this).find("td").eq(0).text();
							var toplamadet = $(this).find("td").eq(2).text();
							var toplamclicks = $(this).find("td").eq(3).text();
							var ort=Math.round(toplamclicks/toplamadet);
							
							var yuzde=(sayi*100)/toplamclicks;

							var left_konum=Math.round(imgposition.left + (width/2)-30);
							var top_konum=Math.round(imgposition.top + (height/2)-18);
							
						    link.append('<div class="tooltipheatmap" style="padding:10px; font-size:14px;color:#fff;text-decoration:none; z-index: 10000001;position:absolute;left:'+left_konum+'px;top:'+top_konum+'px; ">%' + yuzde.toFixed(2) +' </div>');

							 
							var xx = h337.create({
								 element: document.getElementById("report_heatmap_main"),
								"height":ContentHeight,
								"radius":50,
								"visible":true										
							});

							var database = {max:ort,
								 data: [{x:imgposition.left + (width/2), y: imgposition.top + (height/2), count: sayi}]
								 };
													
							xx.store.setDataSet(database);
						 
				   	   	 	
						 
					}
				   });		

				 
				
			}
 	
		
	});
	 	
   
   
	
	}
	
   
  
</script>
 <%}%>
</body>
</html>






 




 