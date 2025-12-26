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
String chkCPS = BriteRequest.getParameter(request, "chkCPS");
String chkRCP = BriteRequest.getParameter(request, "chkRCP");

SystemAccessPermission canCustUser = systemuser.getAccessPermission(SystemObjectType.CUSTOMER_USER);
SystemAccessPermission canServ = systemuser.getAccessPermission(SystemObjectType.SERVER);
boolean isSuperUser = (systemuser.s_super_user_flag != null && systemuser.s_super_user_flag.equals("1"));

ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;
ResultSet	rs = null; 
String sSQL = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	if ( cust_id != null && camp_id != null && 
		 ( (chkCPS != null && cps_status_id != null) || (chkRCP != null && rcp_status_id != null) ) )
	{		
		String sModInstId = null; 
		Vector services = null;
		Service service = null;
		String sRequest = null;
		String sResponse = null;
		if ((chkCPS != null && cps_status_id != null)) {
			sModInstId = getModInstID(stmt, cust_id, "CCPS");
			//System.out.println("CPS for cust " + cust_id + " => " + sModInstId);
			services = Services.get(ServiceType.CQUE_CAMP_STATUS_SET, sModInstId, cust_id);
			service = (Service) services.get(0);
			try	{
				sRequest = "<request>" +
				   		   "  <cust_id>" + cust_id + "</cust_id>" +
				           "  <camp_id>" + camp_id + "</camp_id>" +
				           "  <status_id>" + cps_status_id + "</status_id>" +
				           "</request>";
				service.connect();
				service.send(sRequest);
				sResponse = service.receive();
			}
			catch(Exception e) {}
			finally { service.disconnect();}
		}
		if ((chkRCP != null && rcp_status_id != null)) {
			sModInstId = getModInstID(stmt, cust_id, "RRCP");
			//System.out.println("RCP for cust " + cust_id + " => " + sModInstId);
			services = Services.get(ServiceType.RQUE_CAMP_STATUS_SET, sModInstId, cust_id);
			service = (Service) services.get(0);
			try	{
				sRequest = "<request>" +
				     	   "  <cust_id>" + cust_id + "</cust_id>" +
				           "  <camp_id>" + camp_id + "</camp_id>" +
				           "  <status_id>" + rcp_status_id + "</status_id>" +
				           "</request>";
				service.connect();
				service.send(sRequest);
				sResponse = service.receive();
			}
			catch(Exception e) {}
			finally { service.disconnect();}
		}
		if(stmt!=null) stmt.close();
		if(conn!=null) cp.free(conn);	
	}
%>
<html>
<head>
<title>BriteService Set Camp Status</title>
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<link rel="stylesheet" href="briteservice.css" type="text/css">
<script language="javascript" src="briteservice.js"></script>
<script language="javascript">
	document.onreadystatechange=updateAndClose;
	function updateAndClose()
	{	
		if (document.readyState == "complete") {
			opener.refreshCust();
			close();
		}
	}
</script>
</head>
<body>
</body>
</html>
<%
}
catch(Exception ex)
{
	ex.printStackTrace(response.getWriter());
}
finally
{
	if(conn!=null) cp.free(conn);
}
%>