<%@ page
	language="java"
	import="com.britemoon.*,
		    com.britemoon.cps.*,
		    java.sql.*,java.net.*,
		    org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
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
 
// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;


boolean DURUM=false;

String	sCampID 	= request.getParameter("Q");
String	sLinkID 	= request.getParameter("P");
String	sCache	 	= request.getParameter("Z");
sCache = ("1".equals(sCache))?sCache:"0";

String sHref = null;
String sDistClicks = null;
String sTotClicks = null;
    
StringBuilder RETURN_TR = new StringBuilder();
StringBuilder RETURN_TR2 = new StringBuilder();
try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_list.jsp");
	stmt = conn.createStatement();

	
	int numRecs = 0;

	if ((sLinkID != null) && (sLinkID != ""))
	{
		rs = stmt.executeQuery("SELECT count(pos_link_id) FROM crpt_camp_pos p"
				+ " WHERE p.pos_link_id="+sLinkID+" and p.camp_id="+sCampID); 
		while(rs.next())
		{
			numRecs = rs.getInt(1);
		}

		rs.close();
	}

	

if ((sLinkID == null) || (sLinkID == "") || (numRecs < 1))
{
	 DURUM=true;
}
else
{

	rs = stmt.executeQuery("SELECT href, dist_clicks, tot_clicks"
			+ " FROM crpt_camp_pos"+(("1".equals(sCache))?"_cache":"")+" p"
			+ " WHERE p.pos_link_id="+sLinkID+" and p.camp_id="+sCampID);
				
	while(rs.next())
	{
		sHref = rs.getString(1);
		sDistClicks = rs.getString(2);
		sTotClicks = rs.getString(3);
	}

    rs.close();
  	 
	String sSql = "EXEC usp_crpt_camp_pos_connect_prev @pos_link_id = "+sLinkID+",@camp_id = "+sCampID+",@cache = "+sCache;

	rs = stmt.executeQuery(sSql);
	
	int iCount = 0;
	
	String sClassAppend = "_other";

	while(rs.next())
	{
		 
		iCount++;

		String sCurLinkID = rs.getString(1);
		String sCurHref = rs.getString(2);
		String sCurDistClicks = rs.getString(3);
		String sCurDistClickPct = rs.getString(4);
		String sCurTotClicks = rs.getString(5);
		String sCurTotClickPct = rs.getString(6);

		 

		String TR=	 "<tr> <td class='list_link'>"
										+"	<a class='tablelink' href='report_track_connect.jsp?Q="+sCampID+"&amp;P="+sCurLinkID+"&amp;Z="+sCache+"'>"
										+ sCurHref 
										+"	</a>"
										+"</td>"
										+"	<td class='list_row'>"
										+"	<b>"+sCurDistClicks+"</b> visits "
										+"	<div style='position:relative;margin-top:5px;width:100%;height:25px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;'>"
										+"		<div  style='background-color:#59C8E6 ;height:23px;width:"+sCurDistClickPct+"%'>"
										+"						<span style='position:absolute;top:1;height:23px;right:2px;font-size:12px;'>"+sCurDistClickPct+"%</span> "
										+"					</div>"
										+"				</div>"
										+"</td>	"
										+"	<td class='list_row'> "
										+"	<b>"+sCurTotClicks+"</b> visits  "
										+"	<div style='position:relative;margin-top:5px;width:100%;height:25px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;'> "
										+"				<div  style='background-color:#59C8E6 ;height:23px;width:"+sCurTotClickPct+"%'> "
										+"					<span style='position:absolute;top:1;height:23px;right:2px;font-size:12px;'>"+sCurTotClickPct+"%</span> "
										+"	</div>"
										+"	</div>"
										+"	</td>"
										+"</tr>";

		RETURN_TR.append(TR);

		 
	}
	rs.close(); 
	 
	sSql = "EXEC usp_crpt_camp_pos_connect_sub @pos_link_id = "+sLinkID+",@camp_id = "+sCampID+",@cache = "+sCache;

	rs = stmt.executeQuery(sSql);
	
	iCount = 0;

	while(rs.next())
	{
		 
		
		iCount++;
		
		String sCurLinkID = rs.getString(1);
		String sCurHref = rs.getString(2);
		String sCurDistClicks = rs.getString(3);
		String sCurDistClickPct = rs.getString(4);
		String sCurTotClicks = rs.getString(5);
		String sCurTotClickPct = rs.getString(6);
 

		String TR=	 "<tr> <td class='list_link'>"
										+"	<a class='tablelink' href='report_track_connect.jsp?Q="+sCampID+"&amp;P="+sCurLinkID+"&amp;Z="+sCache+"'>"
										+ sCurHref 
										+"	</a>"
										+"</td>"
										+"	<td class='list_row'>"
										+"	<b>"+sCurDistClicks+"</b> visits "
										+"	<div style='position:relative;margin-top:5px;width:100%;height:25px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;'>"
										+"		<div  style='background-color:#59C8E6 ;height:23px;width:"+sCurDistClickPct+"%'>"
										+"						<span style='position:absolute;top:1;height:23px;right:2px;font-size:12px;'>"+sCurDistClickPct+"%</span> "
										+"					</div>"
										+"				</div>"
										+"</td>	"
										+"	<td class='list_row'> "
										+"	<b>"+sCurTotClicks+"</b> visits  "
										+"	<div style='position:relative;margin-top:5px;width:100%;height:25px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;'> "
										+"				<div  style='background-color:#59C8E6 ;height:23px;width:"+sCurTotClickPct+"%'> "
										+"					<span style='position:absolute;top:1;height:23px;right:2px;font-size:12px;'>"+sCurTotClickPct+"%</span> "
										+"	</div>"
										+"	</div>"
										+"	</td>"
										+"</tr>";

		RETURN_TR2.append(TR);


		 
	}
	rs.close();
	 
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
  <title>Tracked Web Page Connections</title> 
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

<body class="hold-transition"  >
 <% if(DURUM){	%>	 
		
	<div class="wrapper" style="margin-left:20px;margin-right:20px;">
			<div class="row">
					<div class="col-md-4" ></div>			
					<div class="col-md-4" >
 							<div align="center" class="alert alert-warning alert-dismissible">
					 			<h4><i class="icon fa fa-warning"></i> Warning!</h4>
									No Campaign for that ID
							</div>
 	  				</div>
					<div class="col-md-4" ></div>
			</div>
		</div>
	<% }else{ %>
  
 <div class="wrapper" style="margin-top:10px;margin-left:20px;margin-right:20px;">
    
    <div class="row">
        <div class="col-md-12">
						 <table class="text-center">
                            <tbody> 
                                <tr>
                                    <td> 
										<a href="report_track.jsp?Q=<%= sCampID %>&Z=<%= sCache %>">
											<button type="button" class="btn btn-block btn-success">Back to Campaign Tracking Report</button>
										</a>
										 
                                    </td>
                                    
                                    </td>
                                </tr>
                            </tbody>
                        </table>
        </div>
    </div>
  
 </div>
 
 <section class="content">
       <div class="row">
        
          <div class="col-md-12" >
                <div class="box box-primary">
						<div class="box-header with-border">
							<h3 class="box-title"> Tracked Web Page Connections</h3>
							
						</div>
						 
						<div class="box-body">
							 <div class="row">
									<div class="col-md-12" >
									<div class="box box-primary">
											<div class="box-header with-border">
												<h3 class="box-title">Current Page</h3>
											 </div>
											 
											<div class="box-body">
														<table class="table no-margin table-striped " >
															<thead>
															<tr>
																<th width="40%">Page URL</th>
																<th width="30%">Distinct Visits</th>
																<th width="30%">Total Visits</th>
															</tr>
															</thead>
															<tbody>
															<tr>
																<td><%=sHref%></td>
																<td><%=sDistClicks%></td>	
															    <td><%=sTotClicks%></td>
																 
															</tr>
														    </tbody>
														 </table>
											</div>
									</div> 
							 </div> 
							 </div>
						</div>
						<div class="box-body">
							 <div class="row">
									<div class="col-md-6" >
									<div class="box box-primary">
											<div class="box-header with-border">
												<h3 class="box-title">Page Visited Prior to Current Page</h3>
											 </div>
											 
											<div class="box-body">
													<table id="example1" class="table no-margin table-striped " >
															<thead>
															<tr>
																<th width="40%">Page URL</th>
																<th width="30%">Distinct Visits</th>
																<th width="30%">Total Visits</th>
															</tr>
															</thead>
															<tbody>
															<%=RETURN_TR%>
														    </tbody>
														 </table>
											</div>
									</div> 
									
								</div>
								<div class="col-md-6" >
									<div class="box box-primary">
											<div class="box-header with-border">
												<h3 class="box-title">Page Visited After Current Page</h3>
											 </div>
											 
											<div class="box-body">
												 <table id="example2" class="table no-margin table-striped " >
															<thead>
															<tr>
																<th width="40%">Page URL</th>
																<th width="30%">Distinct Visits</th>
																<th width="30%">Total Visits</th>
															</tr>
															</thead>
															<tbody>
																<%=RETURN_TR2%>
														    </tbody>
														 </table>
											</div>
									</div> 
							  </div> 
						</div>
                </div> 
		 </div> 
		 
         
		 
		 
      </div><!-- /.row END -->

 </section>
 
 
 
 
 
 
 
 
 
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

<script>
		$(function () {
		 $('#example1').DataTable({

			 	'paging'      : true,
				'lengthChange': false,
				'searching'   : false,
				'ordering'    : false,
				'info'        : true,
				'autoWidth'   : false
		 })
		 $('#example2').DataTable({

			 	'paging'      : true,
				'lengthChange': false,
				'searching'   : false,
				'ordering'    : false,
				'info'        : true,
				'autoWidth'   : false
		 })
		   
		})
	  </script>
 <% } %>
</body>
</html>
















 