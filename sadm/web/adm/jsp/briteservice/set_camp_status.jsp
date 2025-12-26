<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*" 
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*" 
	import="org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ include file="functions.jsp"%>
<%

String cust_id = BriteRequest.getParameter(request, "cust_id");
if ((cust_id == null) || ("".equals(cust_id))) {
	cust_id = "0";
}

String camp_id = BriteRequest.getParameter(request, "camp_id");
if ((camp_id == null) || ("".equals(camp_id))) {
	camp_id = "";
}

SystemAccessPermission canCust = systemuser.getAccessPermission(SystemObjectType.CUSTOMER);
if (!canCust.bRead){
	response.sendRedirect("../access_denied.jsp");
	return;
}

String cps_status_id = BriteRequest.getParameter(request, "cps_status_id");
String rcp_status_id = BriteRequest.getParameter(request, "rcp_status_id");
if (cps_status_id == null || cps_status_id.equals("null")) cps_status_id = "";
if (rcp_status_id == null || rcp_status_id.equals("null")) rcp_status_id = "";

SystemAccessPermission canCustUser = systemuser.getAccessPermission(SystemObjectType.CUSTOMER_USER);
SystemAccessPermission canServ = systemuser.getAccessPermission(SystemObjectType.SERVER);
boolean isSuperUser = (systemuser.s_super_user_flag != null && systemuser.s_super_user_flag.equals("1"));

%>
<html>
<head>
<title>BriteService Set Camp Status</title>
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<link rel="stylesheet" href="briteservice.css" type="text/css">
<script language="javascript" src="briteservice.js"></script>
<script language="javascript">
	document.onreadystatechange=fnUpdate;
	function fnUpdate()
	{	
		if (document.readyState == "complete") {
			setDDL(document.getElementById("chkCPS"), 'cps');
			setDDL(document.getElementById("chkRCP"), 'rcp')
		}
	}
	
	function save()
	{	
		FT.submit();
	}
	
	function setDDL(obj, module)
	{
		if (obj.checked == true) {
			document.getElementById(module + "_status_id").style.display = "";
		}
		else {
			document.getElementById(module + "_status_id").style.display = "none";
		}
		
		if ((document.getElementById("chkCPS").checked == false) && (document.getElementById("chkRCP").checked == false)) {
			document.getElementById("cmdOk").disabled = true;
		}
		else {
			document.getElementById("cmdOk").disabled = false;
		}
	}

	function cancel()
	{
		opener.refreshCust();
		close();
	}
	
</script>
</head>
<body>
<FORM  METHOD="GET" NAME="FT" ACTION="set_camp_status_save.jsp">
<table style="width:100%; height:100%;" cellspacing="0" cellpadding="0">
	<tr>
		<td colspan="2" align="center">Assigning Status for Campaign <%= camp_id %></td>
		<input type="hidden" name="cust_id" id="cust_id" value="<%= cust_id %>">
		<input type="hidden" name="camp_id" id="camp_id" value="<%= camp_id %>">
	</tr>
	<tr>
		<td colspan="2" style="height:100%;">
			Choose to set the status' of the selected campaigns on the CPS and/or the RCP:<br><br>
			<input type="checkbox" name="chkCPS" id="chkCPS" class="nobord" <%= (cps_status_id.length() > 0 ?"checked":"") %> onclick="setDDL(this, 'cps');" />
			<label for="chkCPS">&nbsp;Set CPS Status</label>&nbsp;&nbsp;
			<select name="cps_status_id" id="cps_status_id">
				<option value="0"  <%= (cps_status_id.equals("0")?"selected":"") %> >Draft</option>
				<option value="10" <%= (cps_status_id.equals("10")?"selected":"") %> >Sent To RCP</option>
				<option value="15" <%= (cps_status_id.equals("15")?"selected":"") %> >Recipient List Created</option>
				<option value="20" <%= (cps_status_id.equals("20")?"selected":"") %> >Waiting To Be Queued</option>
				<option value="30" <%= (cps_status_id.equals("30")?"selected":"") %> >Queued</option>
				<option value="40" <%= (cps_status_id.equals("40")?"selected":"") %> >Links Setup</option>
				<option value="50" <%= (cps_status_id.equals("50")?"selected":"") %> >Ready To Send</option>
				<option value="55" <%= (cps_status_id.equals("55")?"selected":"") %> >Being Processed</option>
				<option value="57" <%= (cps_status_id.equals("57")?"selected":"") %> >Waiting</option>
				<option value="60" <%= (cps_status_id.equals("60")?"selected":"") %> >Done</option>
				<option value="70" <%= (cps_status_id.equals("70")?"selected":"") %> >Error</option>
				<option value="80" <%= (cps_status_id.equals("80")?"selected":"") %> >Cancelled</option>
				<option value="90" <%= (cps_status_id.equals("90")?"selected":"") %> >Deleted</option>
			</select>
			<br><br>
			<input type="checkbox" name="chkRCP" id="chkRCP" class="nobord" <%= (rcp_status_id.length() > 0 ?"checked":"") %> onclick="setDDL(this, 'rcp');" />
			<label for="chkRCP">&nbsp;Set RCP Status</label>&nbsp;&nbsp;
			<select name="rcp_status_id" id="rcp_status_id">
				<option value="0"  <%= (rcp_status_id.equals("0")?"selected":"") %> >Draft</option>
				<option value="10" <%= (rcp_status_id.equals("10")?"selected":"") %> >Sent To RCP</option>
				<option value="15" <%= (rcp_status_id.equals("15")?"selected":"") %> >Recipient List Created</option>
				<option value="20" <%= (rcp_status_id.equals("20")?"selected":"") %> >Waiting To Be Queued</option>
				<option value="30" <%= (rcp_status_id.equals("30")?"selected":"") %> >Queued</option>
				<option value="40" <%= (rcp_status_id.equals("40")?"selected":"") %> >Links Setup</option>
				<option value="50" <%= (rcp_status_id.equals("50")?"selected":"") %> >Ready To Send</option>
				<option value="55" <%= (rcp_status_id.equals("55")?"selected":"") %> >Being Processed</option>
				<option value="57" <%= (rcp_status_id.equals("57")?"selected":"") %> >Waiting</option>
				<option value="60" <%= (rcp_status_id.equals("60")?"selected":"") %> >Done</option>
				<option value="70" <%= (rcp_status_id.equals("70")?"selected":"") %> >Error</option>
				<option value="80" <%= (rcp_status_id.equals("80")?"selected":"") %> >Cancelled</option>
			</select>
		</td>
	</tr>
	<tr>
		<td align="right">
			<button id="cmdOk" onclick="save();">OK</button>&nbsp;
			<button id="cmdCancel" onclick="cancel();">Cancel</button>
		</td>
	</tr>
</table>
</FORM>
</body>
</html>

%>