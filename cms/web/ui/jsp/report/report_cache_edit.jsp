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

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

String sCampID = request.getParameter("Q");
String sCacheID = request.getParameter("C");

Boolean DURUM=false;
int showTrackerRpt = 0;
int nPos = 0;
String reportName = "";

String sCacheStartDate = null;
String sCacheEndDate = null;
String sCacheFilterID = null;
String sCacheAttrID = null;
String sCacheAttrValue1 = null;
String sCacheAttrValue2 = null;
String sCacheAttrOperator = null;
String sCacheUserID = null;
String sTime = null;

StringBuilder FILTER_OPTION = new StringBuilder();
StringBuilder FILTERLIST_OPTION = new StringBuilder();
StringBuilder FILTERLOGIC_OPTION = new StringBuilder();
StringBuilder FILTERATTR_OPTION = new StringBuilder();


try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_cache_edit.jsp");
	stmt = conn.createStatement();

	int numRecs = 0;
	if ((sCampID != null) && (sCampID != "")) {
		rs = stmt.executeQuery("SELECT count(camp_id) FROM cque_campaign c"
				+ " WHERE c.cust_id="+cust.s_cust_id+" and c.camp_id="+sCampID); 
		while(rs.next()) {
			numRecs = rs.getInt(1);
		}
	}

	rs.close();
	
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
		
		rs = stmt.executeQuery("SELECT CONVERT(varchar(25), getdate(), 0)");
		if (rs.next()) sTime = rs.getString(1);
		rs.close();
		sTime = (sTime == null)?"":sTime;


		boolean bCacheExists = false;
		rs = stmt.executeQuery("SELECT count(*) FROM crpt_camp_summary_cache WHERE camp_id = "+sCampID+" AND cache_id = "+sCacheID);
		
		if (rs.next())
		{
			int nCnt = rs.getInt(1);
			bCacheExists = (nCnt > 0);
		}
		rs.close();
	
		
		if (bCacheExists)
		{
			rs = stmt.executeQuery("SELECT CONVERT(varchar(25), cache_start_date, 0), CONVERT(varchar(25), cache_end_date, 0),"
					+ " attr_id, attr_value1, attr_value2, attr_operator, user_id, filter_id"
					+ " FROM crpt_camp_summary_cache WHERE camp_id = "+sCampID+" AND cache_id = "+sCacheID);
					
			if (rs.next())
			{
				sCacheStartDate = rs.getString(1);
				sCacheEndDate = rs.getString(2);
				sCacheAttrID = rs.getString(3);
				
				byte[] bval = rs.getBytes(4);
				sCacheAttrValue1 = (bval == null)?null:new String(bval,"UTF-8");
				
				bval = rs.getBytes(5);
				sCacheAttrValue2 = (bval == null)?null:new String(bval,"UTF-8");
				
				sCacheAttrOperator = rs.getString(6);
				sCacheUserID = rs.getString(7);
				sCacheFilterID = rs.getString(8);
			}
		}
		
		sCacheStartDate = (sCacheStartDate != null)?sCacheStartDate:"";
		sCacheEndDate = (sCacheEndDate != null)?sCacheEndDate:"";
		sCacheAttrID = (sCacheAttrID != null)?sCacheAttrID:"";
		sCacheAttrValue1 = (sCacheAttrValue1 != null)?sCacheAttrValue1:"";
		sCacheAttrValue2 = (sCacheAttrValue2 != null)?sCacheAttrValue2:"";
		sCacheAttrOperator = (sCacheAttrOperator != null)?sCacheAttrOperator:"";
		sCacheUserID = (sCacheUserID != null)?sCacheUserID:"0";
		sCacheFilterID = (sCacheFilterID != null)?sCacheFilterID:"";
		
		//KU 2004-02-20
		
		
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


		String sql = "EXEC usp_ctgt_filter_list_get_report @cust_id= " + cust.s_cust_id +  ", @category_id=null, @start_record=null, @page_size=null, @orderby='name'";
		 
		rs = stmt.executeQuery(sql);
		String sFilterID, sFilterName;
		while (rs.next()) {
				sFilterID = rs.getString(1);
				sFilterName = rs.getString(2);
 				String select;
				if(sFilterID.equals(sCacheFilterID)){
					select="selected";
				}else{
					select="";
				}
				String x=	"<OPTION value='"+ sFilterID +"' "+select+">"+sFilterName+"</OPTION>" ;
				FILTER_OPTION.append(x);
	 	}
		rs.close();

		 						
		sql = "EXEC usp_ctgt_filter_list_get_orderby @cust_id= " + cust.s_cust_id +  ", @category_id=null, @start_record=null, @page_size=null, @orderby='name'";
	 
		rs = stmt.executeQuery(sql);
		while (rs.next()) {
			sFilterID = rs.getString(1);
			sFilterName = rs.getString(2);

			byte[] data = sFilterName.getBytes();
    		String sFilterNameNew = new String(data, "UTF-8");
			String select;
			if(sFilterID.equals(sCacheFilterID)){select="selected";	}else{	select="";	}

			String x=	"<OPTION value='"+ sFilterID +"' "+select+">"+sFilterNameNew+"</OPTION>" ;
			FILTERLIST_OPTION.append(x);
		}
	
		rs.close();
		 

	
		sql = "EXEC usp_ctgt_filter_list_get_logic @cust_id= " + cust.s_cust_id +  ", @category_id=null, @start_record=null, @page_size=null, @orderby='name'";
		rs = stmt.executeQuery(sql);
		while (rs.next()) {
			sFilterID = rs.getString(1);
			sFilterName = rs.getString(2);

			byte[] data = sFilterName.getBytes();
			String sFilterNameNew = new String(data, "UTF-8");
			String select;
			if(sFilterID.equals(sCacheFilterID)){select="selected";	}else{	select="";	}

			String x="<OPTION value='"+ sFilterID +"' "+select+">"+sFilterNameNew+"</OPTION>" ;
			FILTERLOGIC_OPTION.append(x);
		} 
		rs.close();

		rs = stmt.executeQuery("SELECT attr_id, display_name FROM ccps_cust_attr WHERE cust_id = "+cust.s_cust_id+" AND display_seq IS NOT NULL ORDER BY display_seq");
			String sAttrID, sAttrName;
			while (rs.next()) {
				sAttrID = rs.getString(1);
				sAttrName = rs.getString(2);

				byte[] data = sAttrName.getBytes();
				String sAttrNameNew = new String(data, "UTF-8");

				String select;
				if(sAttrID.equals(sCacheAttrID)){select="selected";	}else{	select="";	}
				String x="<OPTION value='"+ sAttrID +"' "+select+">"+sAttrNameNew+"</OPTION>" ;

				FILTERATTR_OPTION.append(x);
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
  <title>Demographic Or Time Report</title> 
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

 
 <% if(DURUM){	%>	 
	<body class="hold-transition">	
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
 
 <body class="hold-transition" ONLOAD="getYears(document.all,0);getYears(document.all,1);SetDateTime(document.all);setRecipFlag(document.FT.at);setUserOpt(document.FT.sd3);">

<form method="post" name="FT" action="report_cache_update.jsp"  target="_self">
	<INPUT TYPE="hidden" NAME="camp_id"	value="<%=sCampID%>">
	<INPUT TYPE="hidden" NAME="cache_id"	value="<%=sCacheID%>">
	<INPUT TYPE="hidden" NAME="start_date" value="<%=sCacheStartDate%>">
	<INPUT TYPE="hidden" NAME="end_date" value="<%=sCacheEndDate%>">
	<INPUT TYPE="hidden" NAME="current_time" value="<%=sTime%>">
	<INPUT TYPE="hidden" NAME="recip_flag" value="0">
	<INPUT TYPE="hidden" NAME="filter_id" value="<%=sCacheFilterID%>">

 <div class="wrapper" style="margin-left:20px;margin-right:20px;">
   <div class="row">
	   <div class="col-md-6">
			<div class="box-body pad table-responsive">
					<table class="text-center">
						<tbody> 
							<tr>
								<td>
									<a href="report_cache_list.jsp?Q=<%= sCampID %>&C=<%=sCacheID%>">
										<button type="button" class="btn btn-block btn-success"> <i class="fa fa-fw fa-angle-double-left"></i> Return to Demographic or Time Reports</button>
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
                    <li ><a href="report_object.jsp?id=" >Campaign Results</a></li>
                    <li class="active" class=""><a href="javascript:void(null);" >Demographic Or Time Report</a></li>
                    <li ><a href="report_time.jsp?Q=<%=sCampID%>"  >Activity vs. Time Report</a></li> 
					
				 	<!--  added the tag to show Delivery tracker tab (part of release 5.9) -->
						<% if (showTrackerRpt == 1) { %>
							 <li class=""><<a href="eTrackerReport.jsp?Q=<%=sCampID%>">Delivery Tracking</a></li>
						<%}%>
					<!--  END (part of release 5.9) -->
					
						<% if (nPos > 0) { %>
							<li class=""><a href="report_track.jsp?Q=<%=sCampID%>">Activity vs. Time Report</a></li>
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
						<div class="box" style="border-top:1px solid #f4f4f4;">
							<div class="box-header with-border" >
								<h3 class="box-title"> <%= reportName %> :    </h3>
								<span class="text-muted" > Use the below options to create a Demographic Or Time Report which will break down your campaign results based on the below criteria.</span> 
							 </div>
							<div class="box-body" >
								 <table class="table table-bordered">
									<tbody>
									<td align="center"><b>On/Off</b></td>
									<td><b>Description</b></td>
									<td></td>
								    <tr>
										<td align="center"> 
											<input  name="sd1" type="checkbox" onclick="setDateFlag(this,0,this.form.start_date);">
								 		</td>
										<td>Include activity that occured on or after this Start Date:</td>
										<td>
											<div class="col-md-2">
												<select class="form-control" name="year" onchange="populate(this.form,this.form.month[0].selectedIndex,0);"></select>
											</div>
											<div class="col-md-2">
												<select class="form-control" name="month" onchange="populate(this.form,this.selectedIndex,0);"></select>
											</div>
											<div class="col-md-2">
												<select class="form-control" name="day"></select>
											</div>
											<div class="col-md-2">
												<select class="form-control" name="time"></select>
											</div>
										</td>
									</tr>
									<tr>
										<td align="center"><input name="sd2" type="checkbox" onclick="setDateFlag(this,1,this.form.end_date);"></td>
										<td>Include activity that occured on or before this End Date:</td>
										<td>
											<div class="col-md-2">
												<select class="form-control" name="year"  onchange="populate(this.form,this.form.month[1].selectedIndex,1);"></select>
											</div>
											<div class="col-md-2">
											<select class="form-control" name="month" onchange="populate(this.form,this.selectedIndex,1);"></select>
											</div>
											<div class="col-md-2">
											<select class="form-control" name="day"></select>
											</div>
											<div class="col-md-2">
											<select class="form-control" name="time"></select>
											</div>
										</td>
									</tr>
									<tr>
										<td align="center"><input name="at" type="checkbox" onclick="setRecipFlag(this);" <%=(sCacheAttrValue1.length()>0 || sCacheFilterID.length() > 0)?" checked":""%>></td>
										<td valign="middle">Only activities generated by recipients of the selected option:</td>
										<td>
													<table class="table table-bordered">
													<tr>
														<td>
															<div class="form-group">
																<div class="radio">
																	<label>
																	<input type="radio" name="recip_option" id="recip_option_2" value="2" onClick="setRecipOpt2(this);">
																			Report Filter
																	</label>
																</div>
																
															</div>
																										
														</td>
														<td>
															 
															<div class="form-group">
															<SELECT name="report_filter_id" class="form-control">
																<OPTION value="">---- Choose report filter -----</OPTION>
														 		<%=FILTER_OPTION%>
															</SELECT>
															</div>
														</td>
													</tr>
													<tr>
														<td>
														 	<div class="form-group">
																<div class="radio">
																	<label>
																	<input type="radio" name="recip_option" id="recip_option_3" value="3" onClick="setRecipOpt3(this);">
																			Target Group
																	</label>
																</div>
															</div>
														</td>
														
														
														<td>
														<div class="form-group">
															<SELECT name="target_group_id" class="form-control">
																<OPTION value="">---- Choose target group -----</OPTION>
																<%=FILTERLIST_OPTION%>
															</SELECT>
														</div>
														</td>
													</tr>
													<tr>
														<td>

															<div class="form-group">
																<div class="radio">
																	<label>
																	<input type="radio" name="recip_option" id="recip_option_4" value="4" onClick="setRecipOpt4(this);">
																			Logic Element
																	</label>
																</div>
																
															</div>

															 
														</td>
														<td>
														<div class="form-group">
															<SELECT name="logic_element_id" class="form-control">
																<OPTION value="">---- Choose logic element -----</OPTION>
																<%=FILTERLOGIC_OPTION%>
															</SELECT>
														</div>
														</td>
													</tr>
													<tr>
														<td>

															<div class="form-group">
																<div class="radio">
																	<label>
																	<input type="radio" name="recip_option" id="recip_option_1" value="1" onClick="setRecipOpt1(this);">
																			Attribute
																	</label>
																</div>
																
															</div>

															 
														</td>
														<td>	<div class="form-group">
																<div class="col-md-3 no-padding">
																		<SELECT name="attr_id" class="form-control">
																			<OPTION value="">---- Choose attribute -----</OPTION>
						
																			<%=FILTERATTR_OPTION%>
																		</SELECT>
																 
																</div>
																<div class="col-md-2">
																	<select name="attr_operator" onchange="doOperationChange(this)" class="form-control">
																		<%= CompareOperation.toHtmlOptions(sCacheAttrOperator) %>
																	</select>
															 	</div>
																<div class="col-md-3">
																	<INPUT class="form-control" type="text" name="attr_value1" value="<%= sCacheAttrValue1 %>">
																</div>
																<%
																boolean bShowValue2 = (String.valueOf(CompareOperation.BETWEEN).equals(sCacheAttrOperator));
																%>
																<div class="col-md-3">
																	<INPUT  class="form-control" type="text" name="attr_value2"<%= ((bShowValue2)?"":" style=\"display: none\"") %> value="<%= sCacheAttrValue2 %>">
																</div>
																</div>
														</td>
													</tr>
													<tr>
														<td colspan="2">* NOTE: The use of single quotes is required around values - i.e. <font color="red">'Johnson'</font> <b>not</b> <font color="red">Johnson</font></td>
													</tr>
													<tr>
														<td colspan="2">Date format: MM/DD/YYYY</td>
													</tr>
												</table>
										
										
										
										</td>
									</tr>
						 			<tr>
										<td align="center" >
											<input name="sd3" type="checkbox" onclick="setUserOpt(this);"<%=(!sCacheUserID.equals("0"))?" checked":""%>>
										</td>
										<td   nowrap>
											Include only recipients owned by me: 
										</td>
										<td>

										    <div class="col-md-2">
												<select class="form-control" name="user_id">
													<option value="<%= user.s_user_id %>"<%=(!sCacheUserID.equals("0"))?" selected":""%>>Yes</option>
													<option value=""<%=(sCacheUserID.equals("0"))?" selected":""%>>No</option>
												</select>
											</div>
											 
										</td>
									</tr>
									<tr>
										<td colspan="3" align="center">
										<a class=buttons-action href="#" onClick="trySubmit();">
											<button type="button" class="btn  btn-success">	Create/Update Report</button>
										</a>
										</td>
									</tr>
									<tr>
										<td colspan="3">&nbsp;</td>
									</tr>
							 
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
 
  
<SCRIPT LANGUAGE="JavaScript">

function isIE () {
	var myNav = navigator.userAgent.toLowerCase();
	return (myNav.indexOf('msie') != -1) ? parseInt(myNav.split('msie')[1]) : false;
 }
 var TARAYICI=0;
if(isIE () == 7){TARAYICI++}
var tarih = new Date();	
 

// Calculate number of days // İE Kontolü yapılıyor
function populate(objForm,selectIndex,Ind) {
 
 
	if (TARAYICI != 0) {
	   timeA = new Date(objForm.year(Ind).options[objForm.year(Ind).selectedIndex].text, objForm.month(Ind).options[objForm.month(Ind).selectedIndex].value,1);
	  
 	} else {
        timeA = new Date(objForm.year[Ind].options[objForm.year[Ind].selectedIndex].text, objForm.month[Ind].options[objForm.month[Ind].selectedIndex].value,1);
	} 
 
	timeDifference = timeA - 86400000;
 
	timeB = new Date(timeDifference);
 
	var daysInMonth = timeB.getDate();

	if (TARAYICI != 0) {
	
	   for (var i = 0; i < objForm.day(Ind).length; i++) objForm.day(Ind).options[0] = null;
	   for (var i = 0; i < daysInMonth; i++) objForm.day(Ind).options[i] = new Option(i+1);
	   objForm.day(Ind).options[0].selected = true;
 	
	} else {
	   
	   for (var i = 0; i < objForm.day[Ind].length; i++) objForm.day[Ind].options[0] = null;
	   for (var i = 0; i < daysInMonth; i++) objForm.day[Ind].options[i] = new Option(i+1);
	   objForm.day[Ind].options[0].selected = true;
       
	} 
   
}
// Fill time   // İE Kontolü yapılıyor
function getTime(objForm,Ind) {
 
	var timeT = new Array("Midnight","1:00 AM","2:00 AM","3:00 AM","4:00 AM","5:00 AM",
                     "6:00 AM","7:00 AM","8:00 AM","9:00 AM","10:00 AM","11:00 AM", 
		"Noon","1:00 PM","2:00 PM","3:00 PM","4:00 PM","5:00 PM",
                     "6:00 PM","7:00 PM","8:00 PM","9:00 PM","10:00 PM","11:00 PM")
	  
	if (TARAYICI != 0){
	   	for (var i = 0; i < timeT.length; i++) {
			objForm.time(Ind).options[i] = new Option(timeT[i]);
			objForm.time(Ind).options[i].value = i;
		}
 	} else {
        for (var i = 0; i < timeT.length; i++) {
			objForm.time[Ind].options[i] = new Option(timeT[i]);
			objForm.time[Ind].options[i].value = i;
		}
	} 


}
// Fill month  // İE Kontolü yapılıyor
function getMonths(objForm,Ind) {
	 
	var months = new Array("January","February","March","April","May","June","July","August","September","October","November","December")
	 
	timeC = new Date(Date.parse(objForm.current_time.value));
	 

	for (var i = 0; i < months.length; i++) {
		if (TARAYICI != 0) {
			objForm.month(Ind).options[i] = new Option(months[i]);
			objForm.month(Ind).options[i].value = i+1;
		}else{
			objForm.month[Ind].options[i] = new Option(months[i]);
			objForm.month[Ind].options[i].value = i+1;
		}
		
	}

	if (TARAYICI != 0) {
			objForm.month(Ind).options[timeC.getMonth()].selected=true;
	}else{
			objForm.month[Ind].options[tarih.getMonth()].selected=true;
	}
	
}
// Fill years: 5 years with current in middle // İE Kontolü yapılıyor
function getYears(objForm, Ind) {
 
 	if (TARAYICI != 0) {
	    timeC = new Date(Date.parse(objForm.current_time.value));
	    currYear = timeC.getFullYear();
		
		for (var i = -2; i < 3; i++) {
			objForm.year(Ind).options[i+2] = new Option(currYear + i);
			objForm.year(Ind).options[i+2].value = currYear + i;
		}
		objForm.year(Ind).options[3].selected=true;

	} else {
         		currYear=tarih.getFullYear();

		for (var i = -2; i < 3; i++) {
		 	objForm.year[Ind].options[i+2] = new Option(currYear + i);
			objForm.year[Ind].options[i+2].value = currYear + i;
 		}
		 objForm.year[Ind].options[3].selected=true;
	} 
	  
	 
	getMonths(objForm,Ind);
	populate(objForm,1,Ind);
 
	if (TARAYICI != 0) {
		objForm.day(Ind).options[timeC.getDate()-1].selected = true;
		getTime(objForm,Ind);
		objForm.time(Ind).options[timeC.getHours()].selected = true;
	} else {
		objForm.day[Ind].options[tarih.getDate()-1].selected = true;
		getTime(objForm,Ind);
		objForm.time[Ind].options[tarih.getHours()].selected = true;
	} 
 
 	
	 
 	
}
// İE Kontolü yapılıyor
function GetDateTime(objForm) {

	var TARAYICI=0;
	if(isIE () == 7){TARAYICI++} 	

	if (TARAYICI != 0) {
		
		if (objForm.sd1.checked == true) {
				var dateStart = objForm.month(0).options[objForm.month(0).selectedIndex].text + " " +
				objForm.day(0).options[objForm.day(0).selectedIndex].text + " " +
				objForm.year(0).options[objForm.year(0).selectedIndex].value + " " +
				objForm.time(0).options[objForm.time(0).selectedIndex].value + ":00";
				document.all.start_date.value = dateStart;
		}

		if (objForm.sd2.checked == true) {
				var dateEnd = objForm.month(1).options[objForm.month(1).selectedIndex].text + " " +
				objForm.day(1).options[objForm.day(1).selectedIndex].text + " " +
				objForm.year(1).options[objForm.year(1).selectedIndex].value + " " +
				objForm.time(1).options[objForm.time(1).selectedIndex].value + ":00";
				document.all.end_date.value = dateEnd;
		}


 	} else {
        
		if (objForm.sd1.checked == true) {
				var dateStart = objForm.month[0].options[objForm.month[0].selectedIndex].text + " " +
				objForm.day[0].options[objForm.day[0].selectedIndex].text + " " +
				objForm.year[0].options[objForm.year[0].selectedIndex].value + " " +
				objForm.time[0].options[objForm.time[0].selectedIndex].value + ":00";
				document.all.start_date.value = dateStart;
		}

		if (objForm.sd2.checked == true) {
				var dateEnd = objForm.month[1].options[objForm.month[1].selectedIndex].text + " " +
				objForm.day[1].options[objForm.day[1].selectedIndex].text + " " +
				objForm.year[1].options[objForm.year[1].selectedIndex].value + " " +
				objForm.time[1].options[objForm.time[1].selectedIndex].value + ":00";
				document.all.end_date.value = dateEnd;
		}


	} 


	
}

function TarihParcala(current_time){

	var current_time = current_time.split(" ");
	return current_time;
}

function ReturnTarih(current_time,saat){

	if (typeof saat === 'undefined') {
	     	saat = null;
 	 }
 
	var months = new Array("January","February","March","April","May","June","July","August","September","October","November","December")
	var current_time_parts = TarihParcala(current_time);

	var cAy =current_time_parts[0];
	var cGun =current_time_parts[1];
	var cYil =current_time_parts[2];
	var cMonths = months.indexOf(cAy);
	if(saat==null){
		var NewtimeC = new Date(cYil,cMonths,cGun);
	}else{
		var s=saat.split(":");
		var NewtimeC = new Date(cYil,cMonths,cGun,s[0],s[1]);
	}
	
	
	return NewtimeC;
}

function SetDateTime(objForm) {
 
	var timeC = ReturnTarih(objForm.current_time.value);
	//var timeC = new Date(Date.parse(objForm.current_time.value));
	 
	//var dateStart = new Date(Date.parse(objForm.start_date.value));
	var dateStart = ReturnTarih(objForm.start_date.value);
 	 
	if(objForm.start_date.value == "") {
	//	dateStart = new Date(Date.parse(objForm.current_time.value));
		dateStart =ReturnTarih(objForm.current_time.value);
	 
	} else {
		objForm.sd1.checked=true;
	}

	var Tarih=new Date();
	  
	if( dateStart.getFullYear() - timeC.getFullYear() >= -2 ) {
		if(TARAYICI!=0){
			objForm.month(0).options[dateStart.getMonth()].selected = true;
			populate(objForm,dateStart.getMonth(),0)
			objForm.day(0).options[dateStart.getDate()-1].selected = true;
			objForm.year(0).options[dateStart.getFullYear()-timeC.getFullYear()+2].selected = true;
			objForm.time(0).options[dateStart.getHours()].selected = true;
		}else{
			objForm.month[0].options[dateStart.getMonth()].selected = true;
			populate(objForm,dateStart.getMonth(),0)
			objForm.day[0].options[dateStart.getDate()-1].selected = true;
			objForm.year[0].options[dateStart.getFullYear()-timeC.getFullYear()+2].selected = true;
			objForm.time[0].options[Tarih.getHours()].selected = true;

		}
		
		
	}
	setDateFlag(objForm.sd1,0,objForm.start_date)
 
	var dateEnd = ReturnTarih(objForm.end_date.value);

	if(objForm.end_date.value == "") {
	//	dateEnd = new Date(Date.parse(objForm.current_time.value));
		dateEnd =ReturnTarih(objForm.current_time.value);
	} else {
		objForm.sd2.checked=true;
	}
	if( dateEnd.getFullYear() - timeC.getFullYear() >= -2 ) {
		if (TARAYICI != 0) {
			objForm.month(1).options[dateEnd.getMonth()].selected = true;
			populate(objForm,dateEnd.getMonth(),1)
			objForm.day(1).options[dateEnd.getDate()-1].selected = true;
			objForm.year(1).options[dateEnd.getFullYear()-timeC.getFullYear()+2].selected = true;
			objForm.time(1).options[dateEnd.getHours()].selected = true;
		}else{

			objForm.month[1].options[dateEnd.getMonth()].selected = true;
			populate(objForm,dateEnd.getMonth(),1)
			objForm.day[1].options[dateEnd.getDate()-1].selected = true;
			objForm.year[1].options[dateEnd.getFullYear()-timeC.getFullYear()+2].selected = true;
			objForm.time[1].options[Tarih.getHours()].selected = true;

		}
	} 
	setDateFlag(objForm.sd2,1,objForm.end_date)
	 
}
// İE Kontolü yapılıyor
function setDateFlag(obj1,ind,obj2) {
	 
   

	if (TARAYICI != 0) {

		if (obj1.checked == true) {
				FT.month(ind).disabled = false;
				FT.day(ind).disabled = false;
				FT.year(ind).disabled = false;
				FT.time(ind).disabled = false;
				obj2.value = FT.month(ind).options[FT.month(ind).selectedIndex].text + " " +
				FT.day(ind).options[FT.day(ind).selectedIndex].text + " " +
				FT.year(ind).options[FT.year(ind).selectedIndex].value +
				FT.time(ind).options[FT.time(ind).selectedIndex].value + ":00";
	    } else {
				FT.month(ind).disabled = true;
				FT.day(ind).disabled = true;
				FT.year(ind).disabled = true;
				FT.time(ind).disabled = true;
				obj2.value = "";
 		}


 	} else {

		 if (obj1.checked == true) {
				FT.month[ind].disabled = false;
				FT.day[ind].disabled = false;
				FT.year[ind].disabled = false;
				FT.time[ind].disabled = false;
				obj2.value = FT.month[ind].options[FT.month[ind].selectedIndex].text + " " +
				FT.day[ind].options[FT.day[ind].selectedIndex].text + " " +
				FT.year[ind].options[FT.year[ind].selectedIndex].value +
				FT.time[ind].options[FT.time[ind].selectedIndex].value + ":00";
	    } else {
				FT.month[ind].disabled = true;
				FT.day[ind].disabled = true;
				FT.year[ind].disabled = true;
				FT.time[ind].disabled = true;
				obj2.value = "";
 		}
       
	} 


	
}
// Düzenleme yapılmadı
function setRecipFlag(obj1) {
	 
	if (obj1.checked == true) {
		FT.recip_option_1.disabled = false;
		FT.recip_option_2.disabled = false;
		FT.recip_option_3.disabled = false;
		FT.recip_option_4.disabled = false;
		FT.report_filter_id.disabled = false;
		FT.target_group_id.disabled = false;
		FT.logic_element_id.disabled = false;
		FT.attr_id.disabled = false;
		FT.attr_operator.disabled = false;
		FT.attr_value1.disabled = false;
		FT.attr_value2.disabled = false;
		if (FT.report_filter_id.selectedIndex > 0) FT.recip_option_2.checked = true;
		if (FT.target_group_id.selectedIndex > 0) FT.recip_option_3.checked = true;
		if (FT.logic_element_id.selectedIndex > 0) FT.recip_option_4.checked = true;
		if (FT.attr_id.selectedIndex > 0) FT.recip_option_1.checked = true;
		if (!(FT.recip_option_1.checked || FT.recip_option_2.checked || FT.recip_option_3.checked || FT.recip_option_4.checked)) {
			FT.recip_option_2.checked = true;
		}		
		if (FT.recip_option_1.checked) {
			FT.recip_flag.value = FT.recip_option_1.value;
			FT.report_filter_id.disabled = true;
			FT.target_group_id.disabled = true;
			FT.logic_element_id.disabled = true;
		}
		if (FT.recip_option_2.checked) {
			FT.recip_flag.value = FT.recip_option_2.value;
			FT.target_group_id.disabled = true;
			FT.logic_element_id.disabled = true;
			FT.attr_id.disabled = true;
			FT.attr_operator.disabled = true;
			FT.attr_value1.disabled = true;
			FT.attr_value2.disabled = true;
		}
		if (FT.recip_option_3.checked) {
			FT.recip_flag.value = FT.recip_option_3.value;
			FT.report_filter_id.disabled = true;
			FT.logic_element_id.disabled = true;
			FT.attr_id.disabled = true;
			FT.attr_operator.disabled = true;
			FT.attr_value1.disabled = true;
			FT.attr_value2.disabled = true;
		}
		if (FT.recip_option_4.checked) {
			FT.recip_flag.value = FT.recip_option_4.value;
			FT.report_filter_id.disabled = true;
			FT.target_group_id.disabled = true;
			FT.attr_id.disabled = true;
			FT.attr_operator.disabled = true;
			FT.attr_value1.disabled = true;
			FT.attr_value2.disabled = true;
		}
	} else {
		FT.recip_option_1.disabled = true;
		FT.recip_option_2.disabled = true;
		FT.recip_option_3.disabled = true;
		FT.recip_option_4.disabled = true;
		FT.report_filter_id.disabled = true;
		FT.target_group_id.disabled = true;
		FT.logic_element_id.disabled = true;
		FT.attr_id.disabled = true;
		FT.attr_operator.disabled = true;
		FT.attr_value1.disabled = true;
		FT.attr_value2.disabled = true;
		FT.recip_flag.value = 0;
		FT.recip_option_1.checked = false;
		FT.recip_option_2.checked = false;
		FT.recip_option_3.checked = false;
		FT.recip_option_4.checked = false;
	}
}
// Düzenleme yapılmadı
function setRecipOpt1(obj) {
	if (obj.checked == true) {
		FT.attr_id.disabled = false;
		FT.attr_operator.disabled = false;
		FT.attr_value1.disabled = false;
		FT.attr_value2.disabled = false;
		FT.recip_flag.value = FT.recip_option_1.value;
		FT.report_filter_id.disabled = true;
		FT.target_group_id.disabled = true;
		FT.logic_element_id.disabled = true;
	}
}
// Düzenleme yapılmadı
function setRecipOpt2(obj) {
	if (obj.checked == true) {
		FT.report_filter_id.disabled = false;
		FT.recip_flag.value = FT.recip_option_2.value;
		FT.target_group_id.disabled = true;
		FT.logic_element_id.disabled = true;
		FT.attr_id.disabled = true;
		FT.attr_operator.disabled = true;
		FT.attr_value1.disabled = true;
		FT.attr_value2.disabled = true;
	}
}
// Düzenleme yapılmadı
function setRecipOpt3(obj) {
	if (obj.checked == true) {
		FT.target_group_id.disabled = false;
		FT.recip_flag.value = FT.recip_option_3.value;
		FT.report_filter_id.disabled = true;
		FT.logic_element_id.disabled = true;
		FT.attr_id.disabled = true;
		FT.attr_operator.disabled = true;
		FT.attr_value1.disabled = true;
		FT.attr_value2.disabled = true;
	}
}
// Düzenleme yapılmadı
function setRecipOpt4(obj) {
	if (obj.checked == true) {
		FT.logic_element_id.disabled = false;
		FT.recip_flag.value = FT.recip_option_4.value;
		FT.report_filter_id.disabled = true;
		FT.target_group_id.disabled = true;
		FT.attr_id.disabled = true;
		FT.attr_operator.disabled = true;
		FT.attr_value1.disabled = true;
		FT.attr_value2.disabled = true;
	}
}
// Düzenleme yapılmadı		
function setUserOpt(obj1) {
	<% if ("1".equals(user.s_recip_owner)) { %>
	FT.user_id[0].selected = true;
	obj1.disabled = true;
	FT.user_id.disabled = true;
	<% } else { %>
	if (obj1.checked == true) {
		FT.user_id.disabled = false;
	} else {
		FT.user_id.disabled = true;
	}
	<% } %>
}
// Düzenleme yapılmadı
function doOperationChange(obj)
{
	if(obj.value == 70)
	{
		FT.attr_value2.style.display = ""; // 70 = CompareOperation.BETWEEN
	}
	else
	{
		FT.attr_value2.value = "";
		FT.attr_value2.style.display = "none";
	}
}

function trySubmit()
{
	if (FT.sd1.checked == false &&  FT.sd2.checked == false  && FT.at.checked == false) {
		alert ("You must select a criteria"); return 0;
	}
	
	if (FT.recip_option_1.checked) FT.recip_flag.value = FT.recip_option_1.value;
	if (FT.recip_option_2.checked) FT.recip_flag.value = FT.recip_option_2.value;
	if (FT.recip_option_3.checked) FT.recip_flag.value = FT.recip_option_3.value;
	if (FT.recip_option_4.checked) FT.recip_flag.value = FT.recip_option_4.value;

	FT.attr_value1.value = FT.attr_value1.value.replace(/(^\s*)|(\s*$)/g, '');
	FT.attr_value2.value = FT.attr_value2.value.replace(/(^\s*)|(\s*$)/g, '');

	if (FT.at.checked && FT.recip_flag.value == 1 && FT.attr_value1.value == "") {
		alert ("You must include an Attribute value");	FT.attr_value1.focus();	return 0;
	}

	if (FT.at.checked && FT.recip_flag.value == 2 && FT.report_filter_id.value == "") {
		alert ("You must select a report filter");	FT.report_filter_id.focus();	return 0;
	}
	
	if (FT.at.checked && FT.recip_flag.value == 3 && FT.target_group_id.value == "") {
		alert ("You must select a target group");	FT.target_group_id.focus();	return 0;
	}

	if (FT.at.checked && FT.recip_flag.value == 4 && FT.logic_element_id.value == "") {
		alert ("You must select a logic element");	FT.logic_element_id.focus();	return 0;
	}

	if (FT.recip_flag.value == 0) {
		FT.attr_value1.value = "";
		FT.attr_value2.value = "";
		FT.attr_id.value = "";
		FT.attr_operator.value = "";
		FT.filter_id.value = "";
	}
	if (FT.recip_flag.value == 1) {
		FT.filter_id.value = "";
	}
	if (FT.recip_flag.value == 2) {
		FT.attr_value1.value = "";
		FT.attr_value2.value = "";
		FT.attr_id.value = "";
		FT.attr_operator.value = "";
		FT.filter_id.value = FT.report_filter_id.value;
	}
	if (FT.recip_flag.value == 3) {
		FT.attr_value1.value = "";
		FT.attr_value2.value = "";
		FT.attr_id.value = "";
		FT.attr_operator.value = "";
		FT.filter_id.value = FT.target_group_id.value;
	}
	if (FT.recip_flag.value == 4) {
		FT.attr_value1.value = "";
		FT.attr_value2.value = "";
		FT.attr_id.value = "";
		FT.attr_operator.value = "";
		FT.filter_id.value = FT.logic_element_id.value;
	}
	GetDateTime(document.all); 
 

	var startsaat   = TarihParcala(FT.start_date.value);
	var dateStr 	= ReturnTarih(FT.start_date.value,startsaat[3]); 
	var endsaat		= TarihParcala(FT.end_date.value);
 	var dateEnd 	= ReturnTarih(FT.start_date.value,endsaat[3]); 
 
	if (dateEnd < dateStr) { alert("The <End Date> specified is before the <Start Date> ..."); return false; }
  
	<% if ("1".equals(user.s_recip_owner)) { %>
	FT.user_id.disabled = false;
	<% } %>

	 FT.submit();
}

</SCRIPT>
 <% }  %>
</body>
</html>

 