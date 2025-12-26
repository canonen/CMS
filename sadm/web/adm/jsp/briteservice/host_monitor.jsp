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
<%

SystemAccessPermission canCust = systemuser.getAccessPermission(SystemObjectType.CUSTOMER);
if (!canCust.bRead){
	response.sendRedirect("../access_denied.jsp");
	return;
}

SystemAccessPermission canCustUser = systemuser.getAccessPermission(SystemObjectType.CUSTOMER_USER);
SystemAccessPermission canServ = systemuser.getAccessPermission(SystemObjectType.SERVER);

boolean isSuperUser = (systemuser.s_super_user_flag != null && systemuser.s_super_user_flag.equals("1"));

String hmURL = Registry.getKey("host_monitor_url");
//hmURL = "http://www.revotas.com/briteservice/hostmonitor/index.htm";

%>
<html>
<head>
<title>Revotas </title>
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<link rel="stylesheet" href="briteservice.css" type="text/css">
<script language="javascript" src="briteservice.js"></script>
</head>
<body>
	<table cellspacing="0" cellpadding="0" width="100%">
		<tr>
			<td>
				<% if (hmURL != null && hmURL.length() > 0) { %>
				<iframe width="100%" height="600" align="left" frameborder="0" marginheight="0" marginwidth="0" src="<%=hmURL%>"></iframe>
				<% } 
				   else { 
				%>
				Host Monitor URL not defined
				<% } %>
			</td>
		</tr>
	</table>
</body>
</html>


