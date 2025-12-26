<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.util.Date,java.io.*,
			org.apache.log4j.*"
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

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
  
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

String sCampID = request.getParameter("Q");
String sCacheIDC = request.getParameter("C");

Boolean DURUM=false;
 
StringBuilder RETURN_TR = new StringBuilder();

int showTrackerRpt = 0;
int nPos = 0;
try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_cache_list.jsp");
	stmt = conn.createStatement();

	int numRecs = 0;
	if ((sCampID != null) && (sCampID != "")) {
		rs = stmt.executeQuery("SELECT count(camp_id) FROM cque_campaign c"
				+ " WHERE c.cust_id="+cust.s_cust_id+" and c.camp_id="+sCampID); 
		while(rs.next()) {
			numRecs = rs.getInt(1);
		}
		rs.close();
	}

	//Customize deliveryTracker report Feature (part of release 5.9)
	
	boolean bFeat = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);
	if (bFeat)
	{
 		int nCount = getSeedListCount(stmt,cust.s_cust_id, sCampID);
		if (nCount > 0)
			showTrackerRpt = 1;
	}
	// end release 5.9
	
	if ((sCampID == null) || (sCampID == "") || (numRecs < 1))
	{
		 DURUM=true;
	}
	else
	{
		String sTime = null;
		rs = stmt.executeQuery("SELECT CONVERT(varchar(25), getdate(), 0)");
		if (rs.next()) sTime = rs.getString(1);
		rs.close();
		sTime = (sTime == null)?"":sTime;


		boolean bCacheExists = false;
		rs = stmt.executeQuery("SELECT count(*) FROM crpt_camp_summary_cache WHERE camp_id = "+sCampID);
		
		if (rs.next())
		{
			int nCnt = rs.getInt(1);
			bCacheExists = (nCnt > 0);
		}
		rs.close();
		//KU 2004-02-20
		
		String reportName = "";
		String reportDate = "";
		byte[] bVal = new byte[255];
		
		rs = stmt.executeQuery("SELECT count(*) FROM crpt_camp_pos WHERE camp_id IN ("+sCampID+")");
		
		if (rs.next())
		{
			nPos = rs.getInt(1);
		}
		rs.close();
		
		rs = stmt.executeQuery("Exec usp_crpt_camp_list @camp_id="+sCampID+", @cust_id="+cust.s_cust_id+", @cache=0");
		
		while( rs.next() )
		{
			bVal = rs.getBytes("CampName");
			reportName = (bVal!=null?new String(bVal,"UTF-8"):"");
			reportDate = rs.getString("StartDate");
		}
		rs.close();
	 
		String sSQL = "";
			
		if ("1".equals(user.s_recip_owner))
			{
				sSQL = "SELECT distinct cache_id, convert(varchar(30),c.cache_start_date,100), convert(varchar(30),c.cache_end_date,100),"
						+ " c.user_id, c.attr_id, a.display_name, c.attr_value1, c.attr_value2, o.sql_name, f.filter_name, convert(varchar(30),c.last_update_date,100), s.display_name"
						+ " FROM crpt_camp_summary_cache c"
						+ " LEFT OUTER JOIN ccps_cust_attr a ON a.attr_id = c.attr_id AND a.cust_id = " +  cust.s_cust_id
						+ " LEFT OUTER JOIN ctgt_compare_operation o ON o.operation_id = c.attr_operator"
						+ " LEFT OUTER JOIN ctgt_filter f ON f.filter_id = c.filter_id"
						+ " LEFT OUTER JOIN crpt_report_status s ON s.status_id = ISNULL(c.last_status_id, 20)"
						+ " WHERE c.camp_id = " + sCampID
						+ " AND c.user_id = " + user.s_user_id;
						/*
						+ " AND c.cache_id NOT IN (" 
						+ " SELECT cache_id FROM crpt_camp_summary_cache"
						+ " WHERE camp_id = " + sCampID
						+ " AND cache_start_date IS NULL"
						+ " AND cache_end_date IS NULL"
						+ " AND attr_id IS NULL"
						+ " AND attr_value1 IS NULL"
						+ " AND attr_value2 IS NULL"
						+ " AND attr_operator IS NULL"
						+ " AND user_id = " + user.s_user_id
						+ " )";
						*/
			}
			else
			{
				sSQL = "SELECT distinct cache_id, convert(varchar(30),c.cache_start_date,100), convert(varchar(30),c.cache_end_date,100),"
						+ " c.user_id, c.attr_id, a.display_name, c.attr_value1, c.attr_value2, o.sql_name, f.filter_name, convert(varchar(30),c.last_update_date,100), s.display_name"
						+ " FROM crpt_camp_summary_cache c"
						+ " LEFT OUTER JOIN ccps_cust_attr a ON a.attr_id = c.attr_id AND a.cust_id = " +  cust.s_cust_id
						+ " LEFT OUTER JOIN ctgt_compare_operation o ON o.operation_id = c.attr_operator"
						+ " LEFT OUTER JOIN ctgt_filter f ON f.filter_id = c.filter_id"
						+ " LEFT OUTER JOIN crpt_report_status s ON s.status_id = ISNULL(c.last_status_id, 20)"
						+ " WHERE c.camp_id = " + sCampID;
			}
			
			rs = stmt.executeQuery(sSQL);
			
			String sCacheID = null;
			String sStartDate = null;
			String sEndDate = null;
			String sAttrID = null;
			String sAttrName = null;
			String sAttrValue1 = "";
			String sAttrValue2 = "";
			String sAttrOperator = null;
			String sUserID = null;
			String sFilterName = null;
			String sLastUpdateDate = null;
			String sLastStatus = null;
			boolean canUpdate = false;
			int iCount = 0;

			String sClassAppend = "";
			boolean isOwningReport = false;

			while( rs.next() )
			{
				if (iCount % 2 != 0) sClassAppend = "contentRows";
				else sClassAppend = "";
				
				sCacheID = rs.getString(1);
				sStartDate = rs.getString(2);
				sEndDate = rs.getString(3);
				sUserID = rs.getString(4);
				sAttrID = rs.getString(5);
				
				bVal = rs.getBytes(6);
				sAttrName=(bVal!=null?new String(bVal,"UTF-8"):"--None Selected--");
				
				bVal = rs.getBytes(7);
				sAttrValue1=(bVal!=null?new String(bVal,"UTF-8"):"");
				
				bVal = rs.getBytes(8);
				sAttrValue2=(bVal!=null?new String(bVal,"UTF-8"):"");
				
				sAttrOperator = rs.getString(9);
				sFilterName = rs.getString(10);
				sLastUpdateDate = rs.getString(11);
				sLastStatus = rs.getString(12);
				
				isOwningReport = false;
				
				if ((sStartDate == null) && (sEndDate == null) && (sAttrID == null)) { isOwningReport = true; }
				
				sStartDate = (sStartDate != null)?sStartDate:"--None Selected--";
				sEndDate = (sEndDate != null)?sEndDate:"--None Selected--";
				sUserID = (!"0".equals(sUserID))?"Yes":"No";
				sAttrID = (sAttrID != null)?sAttrID:"--None Selected--";
				sAttrOperator = (sAttrOperator != null)?sAttrOperator:"";

				String sCriteria = sFilterName;
				String sCriteriaNew=null;
				if (sCriteria == null)
				{
					sCriteria = sAttrName + "&nbsp;" + sAttrOperator + "&nbsp;" + sAttrValue1 + "&nbsp;" + sAttrValue2;
					
				}

				byte[] datasCriteria = sCriteria.getBytes();
    			sCriteriaNew = new String(datasCriteria, "UTF-8");
				
				canUpdate = false;
				if (sLastStatus != null && sLastStatus.equals("Completed")) {
					canUpdate = true;
				}
				//Page logic
				iCount++;
				String UCheck="";
				String Uedit="";

				if (canUpdate) {   
						UCheck = "<input type='checkbox' name='UCheck' value='"+ sCacheID +"'>";
						Uedit  ="<a href='report_cache_edit.jsp?Q="+sCampID +"&C="+ sCacheID +"' class='subactionbutton'>Edit</a> ";
				}else {
						UCheck="&nbsp;";
						Uedit="&nbsp;";
				}  
		
				String TR = "<tr>"	
							+"		<td> <a style='display:block;text-align:center;color:#FFFFFF;text-decoration:none;padding:2px;background-color:#009AD9;' href='report_object.jsp?act=VIEW&id="+ sCampID +"&Z=1&C="+ sCacheID +"'>View</a></td> "
							+" 		<td><input type='checkbox' name='CCheck' value='"+ sCacheID +"'></td>" 
							+"		<td>"+ sStartDate +"</td> "
							+"		<td>"+ sEndDate +"</td> "
							+"		<td>"+ sCriteriaNew +"</td> "
							+"		<td>"+ sUserID +"</td> "
							+"		<td>"+ UCheck  +"</td> "
							+"		<td>"+ sLastUpdateDate +"</td> "
							+"		<td>"+ sLastStatus +"</td>"
							+"		<td>"+ Uedit +"</td> "
							+"	</tr> ";
				 
				RETURN_TR.append(TR);
			}

			if (iCount == 0)
			{
			  	RETURN_TR.append("<tr><td colspan='10'>There are currently no Demographic or Time Reports.</td></tr>");
		    }
			rs.close();
		 
	}

 
} catch(Exception ex) { 
	ErrLog.put(this, ex, "Report Error.",out,1);
} finally {

	try { 	
		if( stmt != null ) stmt.close(); 
	} catch (Exception ex2) {}
	if( conn != null ) cp.free(conn); 
}
%>


<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Revotas Report</title> 
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

<body class="hold-transition" onload="Disable()">
 
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
 
<form name="FT" id="FT" method="post" action="report_object.jsp">
<input type="hidden" name="CampID" value="<%= sCampID %>"/>	
<input type="hidden" name="CompList" value=""/>
<input type="hidden" name="UpdList" value=""/>	

 <div class="wrapper" style="margin-left:20px;margin-right:20px;">
   <div class="row">
	   <div class="col-md-6">
				 <div class="box-body pad table-responsive">
                        <table class="text-center">
                            <tbody> 
                                <tr>
                                    <td>
                                    <a  href="report_cache_edit.jsp?Q=<%= sCampID %>&C=0">
                                        <button type="button" class="btn btn-block btn-success">New Demographic or Time Report</button>
                                    </a>
                                    </td>
                                    <td width="5"> </td>
                                    <td>
										<a  href="javascript:void(null)"  onclick="PrepSubmit('1');" >
											<button id="Compare" type="button" class="btn btn-block btn-warning">Compare Reports </button>
										</a>
                                    </td>
									<td width="5"> </td>
                                    <td>
									<a href="javascript:void(null)"  onclick="PrepSubmit('2');">
										<button  id="Update"  type="button" class="btn btn-block btn-warning">Update Reports</button>
									</a>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
				</div>
	   </div>
	   <div class="col-md-5"></div>
	   <div class="col-md-1">
			 <div class="box-body">
                        <table class="text-center">
                            <tbody> 
                                <tr>
                                     <td>
											<a  href="javascript:void(null)"  onclick="PrepSubmit('3');">
												<button type="button" class="btn btn-block btn-warning">Refresh List</button>
											</a>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
				</div>
			 </div>
		 
			 
	 </div>
 
    <div class="row">
        <div class="col-md-12">
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs">
                    <li ><a href="report_object.jsp?id=<%=sCampID%>" >Campaign Results</a></li>
                    <li class="active" class=""><a href="javascript:void(null);" >Demographic Or Time Report</a></li>
                    <li ><a href="report_time.jsp?Q=<%=sCampID%>"  >Activity vs. Time Report</a></li> 
					
						<!--  added the tag to show Delivery tracker tab (part of release 5.9) -->
						<% if (showTrackerRpt == 1) { %>
							<a href="eTrackerReport.jsp?Q=<%=sCampID%>"><span>Delivery Tracking</span></a>
						<%}%>
					<!--  END (part of release 5.9) -->
	
					<% if (nPos > 0) { %>
						<a href="report_track.jsp?Q=<%=sCampID%>"><span>RevoTrack Results</span></a>
					<% } %>	
		
 
					
                    <li class=""><a href="report_heatmap.jsp?Q=<%=sCampID%>" >HeatMap</a></li> 
                </ul>
            </div> 
        </div>
    </div>
 
 </div>

<div class="wrapper" style="margin-left:20px;margin-right:20px;">
	  <div class="row">
						
			 <div class="col-md-12" >
                <div class="box box-primary">
                     
                    <div class="box-body" >
                        <table class="table table-striped" border="0" cellspacing="0" width="100%" cellpadding="0">
							<tbody>
							<tr>
								<th></th>
								<th>Compare</th>
								<th>Start Date</th>
								<th>End Date</th>
								<th>Criteria</th>
								<th>User Owned</th>
								<th>Update</th>
								<th>Update Date</th>
								<th>Update Status</th>
								<th></th>	
								
							</tr>
							 <% out.println(RETURN_TR) ; %> 
							</tbody>
						</table>      
                  
                    </div><!-- /.box-body -->
                </div><!-- /.box box-primary -->
			</div>
	  
	  </div>
   </div>
  



</form>

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
 
 
 <SCRIPT language="javascript">
	
	function Disable(){

		if(	FT.CCheck == undefined){
		  	document.getElementById("Compare").disabled = true;
 			document.getElementById("Update").disabled = true;
		}
			
	}	
	

	function PrepSubmit(Act)
	{
		var CampId = FT.CampID.value;
	 
		var CacheId='';
		FT.UpdList.value = '';
		FT.CompList.value = '';
		var numChecks = 0;

		if (Act == '1')
		{ 
			if (FT.CCheck.length == undefined)
			{
				if (FT.CCheck.checked)
				{
					FT.CompList.value += FT.CCheck.value + ",";
					if (CacheId !='') CacheId += ',';
					CacheId += FT.CCheck.value;
					numChecks++;
				}
			}
			else
			{
				for (i=0; i < FT.CCheck.length; i++)
				{
					if (FT.CCheck[i].checked)
					{
						FT.CompList.value += FT.CCheck[i].value + ",";
						if (CacheId !='') CacheId += ',';
						CacheId += FT.CCheck[i].value;
						numChecks++;
					}
				}
			}

			if (CacheId != '')
			{
				FT.action += "?act=VIEW&id=" + CampId + "&Z=1&C=" + CacheId;
				FT.submit();
			}
			else
			{
				alert("Choose at least one report to compare.");
			}
		}
		else if (Act == '2')
		{
			if (FT.UCheck.length == undefined)
			{
				if (FT.UCheck.checked)
				{
					FT.UpdList.value += FT.UCheck.value + ",";
					if (CacheId !='') CacheId += ',';
					CacheId += FT.UCheck.value;
					numChecks++;
				}
			}
			else
			{
				for (i=0; i < FT.UCheck.length; i++)
				{
					if (FT.UCheck[i].checked)
					{
						FT.UpdList.value += FT.UCheck[i].value + ",";
						if (CacheId !='') CacheId += ',';
						CacheId += FT.UCheck[i].value;
						numChecks++;
					}
				}
			}
			
			if (CacheId != '')
			{
				FT.action = "report_cache_update.jsp?get_cache_info=1&camp_id=" + CampId+ "&cache_id=" + CacheId;
				FT.submit();
				return;
			}
			else
			{
				alert("Choose at least one report to update.");
			}
		}
		else if (Act == '3')
		{
			FT.action = "report_cache_list.jsp?Q=" + CampId;
			FT.submit();
			return;
		}
	}
</SCRIPT>
 <% }  %>
</body>
</html>
















 