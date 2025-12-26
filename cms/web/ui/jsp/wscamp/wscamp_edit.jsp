<%@ page
	language="java"
	import="com.britemoon.cps.*,
			com.britemoon.*,
			java.util.zip.*,
			com.britemoon.cps.xcs.*,
			com.britemoon.cps.xcs.dts.*,
			com.jscape.inet.sftp.*,
			com.jscape.inet.ssh.util.SshParameters,
			com.jscape.inet.http.Http,
			com.jscape.inet.http.HttpResponse,
			com.jscape.inet.http.HttpRequest,	
			com.jscape.inet.sftp.*,
			com.jscape.inet.ssh.util.SshParameters,
			java.io.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			java.text.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);
canTGPreview = false;
boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);

//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);
boolean showStep1 = false;
boolean showStep2 = false;
boolean enableStep1 = false;
boolean enableStep2 = false;

// Connection
ConnectionPool	cp   = null;
Connection		conn = null;
Statement		stmt = null;
ResultSet       rs   = null;
String          sql  = null;
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	String sWsCampId = request.getParameter("ws_camp_id");
	if (sWsCampId != null && sWsCampId.length() > 0) {
		showStep1 = true;
		sql =
			"SELECT wc.ws_camp_id" +
			"  FROM cxcs_ws_campaign wc" +
			" WHERE wc.cust_id="+cust.s_cust_id +
			"   AND wc.ws_camp_id = " + sWsCampId;
		rs = stmt.executeQuery(sql);
		if (rs.next()) {
			showStep2 = true;
		}
		else {
			enableStep1 = true;
		}
		rs.close();		
	}
	else {
		sWsCampId = "";
		showStep1 = true;
		enableStep1 = true;	
	}
	
	String sCampName = "";
	String sSubject = "";
	String sFromName = "";
	String sStartDate = "";
	String sClickSeal = "";

	
	if (showStep2) {
		// get ws camp info
		sql =
			"SELECT c.camp_name, mh.subject_html, mh.from_name, s.start_date, wc.ws_seal_id" +
			"  FROM cxcs_ws_campaign wc" +
			"  LEFT JOIN cque_campaign c on c.camp_id = wc.camp_id" +
			"  LEFT JOIN cque_msg_header mh on mh.camp_id = wc.camp_id" +
			"  LEFT JOIN cque_schedule s on s.camp_id = wc.camp_id" +
			" WHERE wc.cust_id="+cust.s_cust_id +
			"   AND wc.ws_camp_id = " + sWsCampId;
		rs = stmt.executeQuery(sql);
		if (rs.next()) {
			sCampName = rs.getString(1);
			sSubject =  rs.getString(2);
			sFromName =  rs.getString(3);
			sStartDate =  rs.getString(4);
			sClickSeal = rs.getString(5);
		}
		rs.close();
		logger.info("sClickSeal = " + sClickSeal);
	}

	CustResource res = new CustResource(cust.s_cust_id, String.valueOf(CustResourceType.SFTP));
	
	String sFileNameMask = request.getParameter("ws_file_name_mask");
	logger.info("filename mask = " + sFileNameMask);
	if (sFileNameMask == null || sFileNameMask.equals("")) {
		sFileNameMask = res.s_str_value; // default filename mask for this customer
	}
	String sFileName = "";

	// retrieve log info
	String sCampId = null;
	String sListFileName = null;
	String sUnsubFileName = null;
	String sWsImportId = null;
	String sWsFilterId = null;
	String sWsStatusId = null;
	String sErrorMsg = null;
	if (showStep2) {
		sql =
			" SELECT w.camp_id, w.list_file_name, w.clickseal_file_name, w.import_id, w.filter_id, w.status_id, w.error_msg " +
			"   FROM cxcs_ws_campaign w, " +
			"        cque_campaign c " +
			"  WHERE w.camp_id = c.camp_id" +
			"    AND w.ws_camp_id = " + sWsCampId;
		rs = stmt.executeQuery(sql);			
		if (rs.next()) {
			sCampId = rs.getString(1);
			sListFileName = rs.getString(2);
			sUnsubFileName = rs.getString(3);
			sWsImportId = rs.getString(4);
			sWsFilterId = rs.getString(5);
			sWsStatusId = rs.getString(6);
			sErrorMsg = rs.getString(7);
		}
		rs.close();
		
		if (sWsStatusId.equals("1") || sWsStatusId.equals("9")) {
			enableStep2 = true;
		}
	}
	else if (sWsCampId != null && sWsCampId.length() > 0) {
		sql =
			" SELECT w.camp_id" +
			"   FROM cxcs_ws_campaign w" +
			"  WHERE w.ws_camp_id = " + sWsCampId;
		rs = stmt.executeQuery(sql);			
		if (rs.next()) {
			sCampId = rs.getString(1);
		}
		rs.close();
	}
	
	String sWsStatus = "";
	if (sWsStatusId == null ) {
		sWsStatusId = "1";
	}
	if (sWsStatusId.equals("1")) sWsStatus = "Draft";
	else if (sWsStatusId.equals("2")) sWsStatus = "Ready to process";
	else if (sWsStatusId.equals("3")) sWsStatus = "Preparing";
	else if (sWsStatusId.equals("4")) sWsStatus = "Importing";
	else if (sWsStatusId.equals("5")) sWsStatus = "Targeting";
	else if (sWsStatusId.equals("9")) sWsStatus = "Error";
	else if (sWsStatusId.equals("10")) sWsStatus = "Complete";
	
	String sImportId = null;
	String sImportName = null;
	String sImportDate = null;
	String sImportCount = null;
	if (showStep2) {
		sql =
			"SELECT imp.import_id, imp.import_name, imp.import_date, imps.tot_recips" +
			"  FROM cxcs_ws_campaign wc" +
			"  LEFT JOIN cupd_import imp on imp.import_id = wc.import_id" +
			"  LEFT JOIN cupd_import_statistics imps on imps.import_id = wc.import_id" +
			" WHERE wc.cust_id=" + cust.s_cust_id +
			"   AND wc.ws_camp_id = " + sWsCampId;
		rs = stmt.executeQuery(sql);
		if (rs.next()) {
			sImportId = rs.getString(1);
			sImportName = rs.getString(2);
			sImportDate =  rs.getString(3);
			sImportCount =  rs.getString(4);
		}
		rs.close();
	}
	
	String sFilterId = null;
	String sFilterName = null;
	String sFilterDate = null;
	String sFilterCount = null;
	if (showStep2) {
		sql =
			"SELECT f.filter_id, f.filter_name, fs.finish_date, fs.recip_qty" +
			"  FROM cxcs_ws_campaign wc" +
			"  LEFT JOIN ctgt_filter f on f.filter_id = wc.filter_id" +
			"  LEFT JOIN ctgt_filter_statistic fs on fs.filter_id = wc.filter_id" +
			" WHERE wc.cust_id=" + cust.s_cust_id +
			"   AND wc.ws_camp_id = " + sWsCampId;
		rs = stmt.executeQuery(sql);
		if (rs.next()) {
			sFilterId = rs.getString(1);
			sFilterName = rs.getString(2);
			sFilterDate =  rs.getString(3);
			sFilterCount =  rs.getString(4);
		}
		rs.close();
	}

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
<script language="javascript" src="../../js/tab_script.js" type="text/javascript"></script>
<SCRIPT LANGUAGE="JavaScript">
function try_submit (step)
{
	if (step == 1) {
		if (FT.ws_camp_id.value == null && FT.ws_camp_id.value == "") {		
			alert("Please enter a Web Service ID");
			return;
		}
	}
	if (step == 2) {
		FT.action = "wscamp_confirm_import.jsp";
		if (FT.ws_local_file_name.value == null || FT.ws_local_file_name.value == "") {
			if (FT.ws_file_name.value == null || FT.ws_file_name.value == "") {
				alert("Please choose a file to import");
				return;
			}
		}
		else {
			FT.encoding = "multipart/form-data";
		} 
	}
	if (step == 3) {
		FT.action = "wscamp_edit.jsp";
	}
	FT.submit();
}

function showCampCounts(ws_camp_id, camp_id)
{
	_oPop = window.open("wscamp_stat_details.jsp?a='stats'&camp_id=" + camp_id +"&ws_camp_id=" + ws_camp_id, "CampCounts", "resizable=yes, directories=0, location=0, menubar=0, scrollbars=1, status=0, toolbar=0, height=350, width=450");
}

</SCRIPT>
</HEAD>
<BODY>
	<FORM  METHOD="POST" name="FT" ACTION="wscamp_confirm.jsp" TARGET="_self">
		<table width=650 cellspacing="0" cellpadding="4" border="0"  style="display:<%= (showStep2?"inline":"none") %>">
			<tr>
				<td align="left" valign="middle" width="80%">
					<a class="deletebutton" href="#" onClick="if( confirm('Are you sure?') ) location.href='wscamp_delete.jsp?ws_camp_id=<%=sWsCampId%>&camp_id=<%=sCampId%>'" TARGET="_self">Delete</a>
				</td>
				<td>
					<a class="resourcebutton" href="#"  onclick="try_submit(3);">Refresh</a>
				</td>
			</tr>
		</table>
		<br><br>
		<table width=650 class=main cellspacing=0 cellpadding=0>
			<tr>
				<td class=sectionheader >&nbsp; <b class=sectionheader>Step 1:</b> Enter Web Service ID</td>
			</tr>
		<table>
		<br>
		<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
			<tr>
				<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
			</tr>
			<tr>
				<td class=fillTab valign=top align=center width=650 colspan=3>
					<table class=main cellspacing=1 cellpadding=2 width="100%">
						<tr>
							<td width="150">Web Service ID</td>
							<td>
								<input type="hidden" name="camp_id" value="<%= (sCampId==null)?"":sCampId%>">
								<input type="text" name="ws_camp_id" size="20" MAXLENGTH="20" <%=(!enableStep1)?"disabled":""%> value="<%= sWsCampId %>">
							</td>
						</tr>																									
						<tr style="display:<%= (enableStep1?"inline":"none") %>">
							<td colspan="2" valign="middle" align="center" style="padding:10px;">
							<a class="actionbutton" href="#" onclick="try_submit(1);" id="startButton">Retrieve and Setup Campaign >></a>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<br><br>
		<table width=650 class=main cellspacing=0 cellpadding=0 style="display:<%= (showStep2?"inline":"none") %>">
			<tr>
				<td class=sectionheader >&nbsp; <b class=sectionheader>Step 2:</b> Choose Import File</td>
			</tr>
		<table>
		<br>
		<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0 style="display:<%= (showStep2?"inline":"none") %>"> 
			<tr>
				<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
			</tr>
			<tr>
				<td class=fillTab valign=top align=center width=650 colspan=3>
					<table class=main cellspacing=1 cellpadding=2 width="100%">
						<tr>
							<td width="150">Click Seal ID</td>
							<td>
							<input type="hidden" name="camp_id" value="<%= (sCampId==null)?"":sCampId%>">
							<input type="hidden" name="ws_camp_id" value="<%=HtmlUtil.escape(sWsCampId)%>" >
							<input type="text" name="ws_seal_id" size="40" maxlength="40" <%=(!enableStep2)?"disabled":""%> value="<%=HtmlUtil.escape(sClickSeal)%>" >
							</td>
						</tr>
						<% if (!enableStep2) { %>
						<tr>
							<td width="150">List File Name</td>
							<td><%=HtmlUtil.escape(sListFileName)%></td>
						</tr>
						<% } else { %>
						<tr>
							<td width="150"><input type="radio" name="r1" checked onClick="r1.checked=true; r2.checked=false;">Remote List File</td>
							<td>
								filename filter:
								<input type="text" name="ws_file_name_mask" size="40"  value="<%=HtmlUtil.escape(sFileNameMask)%>">
								&nbsp;
								<a class="resourcebutton" href="#"  onclick="try_submit(3);">Refresh File List</a>
								<br>
								<select name="ws_file_name" size="1"  onClick="r1.checked=true; r2.checked=false;">
								<option value="">-----  Choose List File  -----</option>
								<%=WsCampUtil.getSftpFileNameOptionsHtml(res, sFileNameMask, sFileName)%>
								</select>
							</td>
						</tr>	
						<tr>
							<td width="150"><input type="radio" name="r2" onClick="r2.checked=true; r1.checked=false;">Local List File</td>
							<td>
								<input type="file" name="ws_local_file_name" size="60" onClick="r2.checked=true; r1.checked=false;">
							</td>
						</tr>																											
						<tr>
							<td colspan="2" valign="middle" align="center" style="padding:10px;">
								<a class="actionbutton" href="#" onclick="try_submit(2);" id="startButton">Download and Setup Target Group >></a>
							</td>
						</tr>
						<%} %>
					</table>
				</td>
			</tr>
		</table>
		<br><br>
		<table width=650 class=main cellspacing=0 cellpadding=0 style="display:<%= (showStep2?"inline":"none") %>">
			<tr>
				<td class=sectionheader >&nbsp; <b class=sectionheader>Log:</b> Campaign Information</td>
			</tr>
		<table>
		<br>
		<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0 style="display:<%= (showStep2?"inline":"none") %>">
			<tr>
				<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
			</tr>
			<tr>
				<td class=fillTab valign=top align=center width=650 colspan=3>
					<table class=main cellspacing=1 cellpadding=2 width="100%">
						<tr>
							<td width="150">Campaign Name</td>
							<td>
							   <%=HtmlUtil.escape(sCampName)%>
							   &nbsp;&nbsp;
							   <a href="javascript:showCampCounts('<%= sWsCampId %>','<%= sCampId %>');" class="resourcebutton">View Sent Counts</a>
							</td>
							
						<tr>
							<td width="150">Subject</td>
							<td><%= sSubject %></td>
						</tr>
						<tr>
							<td width="150">From Name</td>
							<td><%= sFromName %></td>
						</tr>
						<tr>
							<td width="150">Start Date</td>
							<td><%= (sStartDate == null)?"NOW":HtmlUtil.escape(sStartDate) %> </td>
						</tr>
					</table>
					<br>
					<table class=main cellspacing=1 cellpadding=2 width="100%">													
						<tr>
							<td width="150">Import Name</td>
							<td><%=HtmlUtil.escape(sImportName)%></td>
						</tr>
						<tr>
							<td width="150">Import Date</td>
							<td><%=HtmlUtil.escape(sImportDate)%></td>
						</tr>
						<tr>
							<td width="150">Import Count</td>
							<td><%=HtmlUtil.escape(sImportCount)%></td>
						</tr>
					</table>
					<br>
					<table class=main cellspacing=1 cellpadding=2 width="100%">
						<tr>
							<td width="150">Target Group</td>
							<td><%=HtmlUtil.escape(sFilterName)%></td>
						</tr>
						<tr>
							<td width="150">Target Group Date</td>
							<td><%=HtmlUtil.escape(sFilterDate)%></td>
						</tr>
						<tr>
							<td width="150">Target Group Count</td>
							<td><%=HtmlUtil.escape(sFilterCount)%></td>
						</tr>
					</table>
					<br>
					<table class=main cellspacing=1 cellpadding=2 width="100%">						
						<tr>
							<td width="150">WS Camp Status</td>
							<td><%=HtmlUtil.escape(sWsStatus)%></td>
						</tr>	
						<tr>
							<td width="150">WS Camp Error Message</td>
							<td><%=HtmlUtil.escape(sErrorMsg)%></td>
						</tr>							
					</table>
				</td>
			</tr>
		</table>
	</FORM>	
</BODY>
</HTML>

<%
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex, "Problem with WS Campaign.",out,1);
}
finally
{
	if ( stmt != null ) stmt.close();
	if ( conn  != null ) cp.free(conn); 
}
%>

<%@ include file="../camp/camp_edit/functions.jsp"%>
<%@ include file="../camp/camp_edit/calendar.jsp"%>
