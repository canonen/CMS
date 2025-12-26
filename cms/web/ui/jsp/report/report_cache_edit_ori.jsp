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
%>
<HTML>
<HEAD>
	<link rel="stylesheet" type="text/css" href="http://www.revotas.com/v5/samplereport/reset.css" />
	<link rel="stylesheet" type="text/css" href="http://www.revotas.com/v5/samplereport/style.css" />
	<style type="text/css">
	 	#newdemograph td, #newdemographinner td {
	 		vertical-align:middle;
	 	}
	 	select {
	 		font-size:11px;
	 		font-family:Tahoma;
	 		padding:2px;
	 		border:1px solid #CCCCCC;
	 	}
 	</style>
</HEAD>

<%

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

String sCampID = request.getParameter("Q");
String sCacheID = request.getParameter("C");

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
	int showTrackerRpt = 0;
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
		%>
		<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
			<tr>
				<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
			</tr>
			<tr>
				<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
			</tr>
			<tbody class=EditBlock id=block1_Step1>
			<tr>
				<td class=fillTab valign=top align=center width=650>
					<table class=main cellspacing=1 cellpadding=2 width="100%">
						<tr>
							<td align="center" valign="middle" style="padding:10px;">
								<b>No Campaign for that ID</b>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			</tbody>
		</table>
		<br><br>
		<%	
	}
	else
	{
		String sTime = null;
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

		String sCacheStartDate = null;
		String sCacheEndDate = null;
		String sCacheFilterID = null;
		String sCacheAttrID = null;
		String sCacheAttrValue1 = null;
		String sCacheAttrValue2 = null;
		String sCacheAttrOperator = null;
		String sCacheUserID = null;
		
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
		int nPos = 0;
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
		
		%>
<BODY ONLOAD="getYears(document.all,0);getYears(document.all,1);SetDateTime(document.all);setRecipFlag(document.FT.at);setUserOpt(document.FT.sd3);">
<form method="post" name="FT" action="report_cache_update.jsp"  target="_self">
	<INPUT TYPE="hidden" NAME="camp_id"	value="<%=sCampID%>">
	<INPUT TYPE="hidden" NAME="cache_id"	value="<%=sCacheID%>">
	<INPUT TYPE="hidden" NAME="start_date" value="<%=sCacheStartDate%>">
	<INPUT TYPE="hidden" NAME="end_date" value="<%=sCacheEndDate%>">
	<INPUT TYPE="hidden" NAME="current_time" value="<%=sTime%>">
	<INPUT TYPE="hidden" NAME="recip_flag" value="0">
	<INPUT TYPE="hidden" NAME="filter_id" value="<%=sCacheFilterID%>">
<div class="wrapper">

Report:</b> <%= reportName %>

	<!-- start header tabs -->
	<div class="sectionTopHeader">
		<a href="report_redirect.jsp?act=VIEW&id=<%=sCampID%>"><span>Campaign Results</span></a>	
		<a href="javascript:void(null)" class="activeTab"><span>Demographic Or Time Report</span></a>
		<a href="report_time.jsp?Q=<%=sCampID%>"><span>Activity vs. Time Report</span></a>	
		
		<!--  added the tag to show Delivery tracker tab (part of release 5.9) -->
			<% if (showTrackerRpt == 1) { %>
				<a href="eTrackerReport.jsp?Q=<%=sCampID%>"><span>Delivery Tracking</span></a>
			<%}%>
		<!--  END (part of release 5.9) -->
		
			<% if (nPos > 0) { %>
				<a href="report_track.jsp?Q=<%=sCampID%>"><span>Activity vs. Time Report</span></a>
			<% } %>			
		<br class="clearfix" />
	</div>
	<!-- end header tabs -->
	
	<div class="sectionBox">
		<div class="topLinksContainer">
			<a href="report_cache_list.jsp?Q=<%= sCampID %>&C=<%=sCacheID%>" class="topLinks">Return to Demographic or Time Reports</a>
			<div class="clearfix"></div>
		</div>

		<div>
			<table class="sectionContainerTbl" width="96%" cellspacing="0" cellpadding="0" border="0">
				<tr>
					<td>
						<table id="newdemograph" class="borderTbl" width="100%" cellspacing="0" cellpadding="0" border="0">
							<tr>
								<td colspan="3">Use the below options to create a Demographic Or Time Report which will break down your campaign results based on the below criteria.</td>
							</tr>
							<tr>
								<td width="15"><input name="sd1" type="checkbox" onclick="setDateFlag(this,0,this.form.start_date);"></td>
								<td width="350">Include activity that occured on or after this Start Date:</td>
								<td>
									<select name="year"  onchange="populate(this.form,this.form.month(0).selectedIndex,0);"></select>
									<select name="month" onchange="populate(this.form,this.selectedIndex,0);"></select>
									<select name="day"></select>
									<select name="time"></select>
								</td>
							</tr>
							<tr>
								<td><input name="sd2" type="checkbox" onclick="setDateFlag(this,1,this.form.end_date);"></td>
								<td>Include activity that occured on or before this End Date:</td>
								<td>
									<select name="year"  onchange="populate(this.form,this.form.month(1).selectedIndex,1);"></select>
									<select name="month" onchange="populate(this.form,this.selectedIndex,1);"></select>
									<select name="day"></select>
									<select name="time"></select>
								</td>
							</tr>
							<tr>
								<td><input name="at" type="checkbox" onclick="setRecipFlag(this);" <%=(sCacheAttrValue1.length()>0 || sCacheFilterID.length() > 0)?" checked":""%>></td>
								<td>Only activities generated by recipients of the selected option:</td>
								<td>
									<table cellpadding="0" cellspacing="0" border="0" id="newdemographinner">
										<tr>
											<td><INPUT type="radio" name="recip_option" id="recip_option_2" value="2" onClick="setRecipOpt2(this);">Report Filter</td>
											<td>
												<SELECT name="report_filter_id">
													<OPTION value="">---- Choose report filter -----</OPTION>
												<%
													String sql = "EXEC usp_ctgt_filter_list_get_report @cust_id= " + cust.s_cust_id +  ", @category_id=null, @start_record=null, @page_size=null, @orderby='name'";
													rs = stmt.executeQuery(sql);
													String sFilterID, sFilterName;
													while (rs.next()) {
														sFilterID = rs.getString(1);
														sFilterName = rs.getString(2);
												%>
													<OPTION value="<%=sFilterID%>"<%=sFilterID.equals(sCacheFilterID)?" selected":""%>><%= sFilterName %></OPTION>
												<% }%>
												</SELECT>
											</td>
										</tr>
										<tr>
											<td><INPUT type="radio" name="recip_option" id="recip_option_3" value="3" onClick="setRecipOpt3(this);">Target Group</td>
											<td>
												<SELECT name="target_group_id">
													<OPTION value="">---- Choose target group -----</OPTION>
												<%						
													sql = "EXEC usp_ctgt_filter_list_get_orderby @cust_id= " + cust.s_cust_id +  ", @category_id=null, @start_record=null, @page_size=null, @orderby='name'";
													rs = stmt.executeQuery(sql);
													while (rs.next()) {
														sFilterID = rs.getString(1);
														sFilterName = rs.getString(2);
												%>
													<OPTION value="<%=sFilterID%>"<%=sFilterID.equals(sCacheFilterID)?" selected":""%>><%= sFilterName %></OPTION>
												<% } %>
												</SELECT>
											</td>
										</tr>
										<tr>
											<td>
												<INPUT type="radio" name="recip_option" id="recip_option_4" value="4" onClick="setRecipOpt4(this);">Logic Element
											</td>
											<td>
												<SELECT name="logic_element_id">
													<OPTION value="">---- Choose logic element -----</OPTION>
												<%
													sql = "EXEC usp_ctgt_filter_list_get_logic @cust_id= " + cust.s_cust_id +  ", @category_id=null, @start_record=null, @page_size=null, @orderby='name'";
													rs = stmt.executeQuery(sql);
													while (rs.next()) {
														sFilterID = rs.getString(1);
														sFilterName = rs.getString(2);
												%>
													<OPTION value="<%=sFilterID%>"<%=sFilterID.equals(sCacheFilterID)?" selected":""%>><%= sFilterName %></OPTION>
												<%	} %>
												</SELECT>
											</td>
										</tr>
										<tr>
											<td>
												<INPUT type="radio" name="recip_option" id="recip_option_1" value="1" onClick="setRecipOpt1(this);">Attribute
											</td>
											<td>
													<SELECT name="attr_id">
														<OPTION value="">---- Choose attribute -----</OPTION>
													<%
														rs = stmt.executeQuery("SELECT attr_id, display_name FROM ccps_cust_attr WHERE cust_id = "+cust.s_cust_id+" AND display_seq IS NOT NULL ORDER BY display_seq");
														String sAttrID, sAttrName;
														while (rs.next()) {
															sAttrID = rs.getString(1);
															sAttrName = rs.getString(2);
													%>
														<OPTION value="<%=sAttrID%>"<%=sAttrID.equals(sCacheAttrID)?" selected":""%>><%= sAttrName %></OPTION>
													<% } %>
													</SELECT>
													&nbsp;&nbsp;
													<select name="attr_operator" onchange="doOperationChange(this)">
														<%= CompareOperation.toHtmlOptions(sCacheAttrOperator) %>
													</select>
													&nbsp;&nbsp;
													<INPUT type="text" name="attr_value1" value="<%= sCacheAttrValue1 %>">
													&nbsp;&nbsp;
													<%
													boolean bShowValue2 = (String.valueOf(CompareOperation.BETWEEN).equals(sCacheAttrOperator));
													%>
													<INPUT type="text" name="attr_value2"<%= ((bShowValue2)?"":" style=\"display: none\"") %> value="<%= sCacheAttrValue2 %>">
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
								<td valign="middle">
									<input name="sd3" type="checkbox" onclick="setUserOpt(this);"<%=(!sCacheUserID.equals("0"))?" checked":""%>>
								</td>
								<td width="250" nowrap>
									Include only recipients owned by me: 
								</td>
								<td >
									<select name="user_id">
										<option value="<%= user.s_user_id %>"<%=(!sCacheUserID.equals("0"))?" selected":""%>>Yes</option>
										<option value=""<%=(sCacheUserID.equals("0"))?" selected":""%>>No</option>
									</select>
								</td>
							</tr>
							<tr>
								<td colspan="3" align="center"><a style="background-color:#308908;color:#FFFFFF;padding:5px;text-decoration:none;" href="#" onClick="trySubmit();">Create/Update Report</a></td>
							</tr>
							<tr>
								<td colspan="3">&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</div>
	</div>
</div>
</form>

<SCRIPT LANGUAGE="JavaScript">
// Calculate number of days
function populate(objForm,selectIndex,Ind) {
	timeA = new Date(objForm.year(Ind).options[objForm.year(Ind).selectedIndex].text, objForm.month(Ind).options[objForm.month(Ind).selectedIndex].value,1);
	timeDifference = timeA - 86400000;
	timeB = new Date(timeDifference);
	var daysInMonth = timeB.getDate();
	for (var i = 0; i < objForm.day(Ind).length; i++) objForm.day(Ind).options[0] = null;
	for (var i = 0; i < daysInMonth; i++) objForm.day(Ind).options[i] = new Option(i+1);
	objForm.day(Ind).options[0].selected = true;
}
// Fill time
function getTime(objForm,Ind) {
var timeT = new Array("Midnight","1:00 AM","2:00 AM","3:00 AM","4:00 AM","5:00 AM",
                     "6:00 AM","7:00 AM","8:00 AM","9:00 AM","10:00 AM","11:00 AM", 
		"Noon","1:00 PM","2:00 PM","3:00 PM","4:00 PM","5:00 PM",
                     "6:00 PM","7:00 PM","8:00 PM","9:00 PM","10:00 PM","11:00 PM")
	for (var i = 0; i < timeT.length; i++) {
		objForm.time(Ind).options[i] = new Option(timeT[i]);
		objForm.time(Ind).options[i].value = i;
	}
}
// Fill month
function getMonths(objForm,Ind) {
var months = new Array("January","February","March","April","May","June","July","August","September","October","November","December")
	timeC = new Date(Date.parse(objForm.current_time.value));

	for (var i = 0; i < months.length; i++) {
		objForm.month(Ind).options[i] = new Option(months[i]);
		objForm.month(Ind).options[i].value = i+1;
	}
	objForm.month(Ind).options[timeC.getMonth()].selected=true;
}
// Fill years: 5 years with current in middle
function getYears(objForm, Ind) {
	timeC = new Date(Date.parse(objForm.current_time.value));
	currYear = timeC.getFullYear();
	for (var i = -2; i < 3; i++) {
		objForm.year(Ind).options[i+2] = new Option(currYear + i);
		objForm.year(Ind).options[i+2].value = currYear + i;
	}
	objForm.year(Ind).options[3].selected=true;
	getMonths(objForm,Ind);
	populate(objForm,1,Ind);
	objForm.day(Ind).options[timeC.getDate()-1].selected = true;
	getTime(objForm,Ind);
	objForm.time(Ind).options[timeC.getHours()].selected = true;
}

function GetDateTime(objForm) {
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
}

function SetDateTime(objForm) {
	var timeC = new Date(Date.parse(objForm.current_time.value));
		
	var dateStart = new Date(Date.parse(objForm.start_date.value));
	if(objForm.start_date.value == "") {
		dateStart = new Date(Date.parse(objForm.current_time.value));
	} else {
		objForm.sd1.checked=true;
	}
	if( dateStart.getFullYear() - timeC.getFullYear() >= -2 ) {
		objForm.month(0).options[dateStart.getMonth()].selected = true;
		populate(objForm,dateStart.getMonth(),0)
		objForm.day(0).options[dateStart.getDate()-1].selected = true;
		objForm.year(0).options[dateStart.getFullYear()-timeC.getFullYear()+2].selected = true;
		objForm.time(0).options[dateStart.getHours()].selected = true;
	}
	setDateFlag(objForm.sd1,0,objForm.start_date)

	var dateEnd = new Date(Date.parse(objForm.end_date.value));
	if(objForm.end_date.value == "") {
		dateEnd = new Date(Date.parse(objForm.current_time.value));
	} else {
		objForm.sd2.checked=true;
	}
	if( dateEnd.getFullYear() - timeC.getFullYear() >= -2 ) {
		objForm.month(1).options[dateEnd.getMonth()].selected = true;
		populate(objForm,dateEnd.getMonth(),1)
		objForm.day(1).options[dateEnd.getDate()-1].selected = true;
		objForm.year(1).options[dateEnd.getFullYear()-timeC.getFullYear()+2].selected = true;
		objForm.time(1).options[dateEnd.getHours()].selected = true;
	} 
	setDateFlag(objForm.sd2,1,objForm.end_date)
}

function setDateFlag(obj1,ind,obj2) {
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
}

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

	var dateStr = new Date(Date.parse(FT.start_date.value));
	var dateEnd = new Date(Date.parse(FT.end_date.value));
	if (dateEnd < dateStr) { alert("The <End Date> specified is before the <Start Date> ..."); return false; }

	<% if ("1".equals(user.s_recip_owner)) { %>
	FT.user_id.disabled = false;
	<% } %>

	FT.submit();
}

</SCRIPT>
</BODY>

<%
	}

%>
</HTML>
<%
} catch(Exception ex) { 
	ErrLog.put(this, ex, "Report Error.",out,1);
} finally {

	try { 	
		if( stmt != null ) stmt.close(); 
	} catch (Exception ex2) {}
	if( conn != null ) cp.free(conn); 
}
%>
