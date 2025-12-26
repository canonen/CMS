<%@ page
	language="java"
	import="com.britemoon.cps.imc.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.*"
	import="org.w3c.dom.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.util.Date"
	import="java.io.*"
	import="org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ include file="functions.jsp"%>

<%! static Logger logger = null;%>
<%
	if (logger == null) {
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%
	String pv_test_type_id = BriteRequest.getParameter(request,"pv_test_type_id");
	String pv_iq = BriteRequest.getParameter(request,"pv_iq");
/*
	if (pv_test_type_id.equals("1")) pv_iq = "000154-000287-000000-000015-976210"; 
	if (pv_test_type_id.equals("2")) pv_iq = "000154-000149-000000-000016-176183"; 
	if (pv_test_type_id.equals("3")) pv_iq = "000154-000149-000000-000016-176183"; 
*/
	if (pv_iq == null || pv_iq.length() == 0) {
		response.sendRedirect("../access_denied.jsp");
		return;
	}
%>

<html>
	<head>
		<title>Viewing PV report</title>
<% 
	Statement		stmt	= null;
	ResultSet		rs		= null; 
	ConnectionPool	cp		= null;
	Connection		conn	= null;
		
	try	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("pv_report_iframe.jsp");
		stmt = conn.createStatement();
		
		String pvClientId = getPV_ClientId(cust.s_cust_id, stmt);

		Vector services = null;
		if (pv_test_type_id.equals("3")) {
			services = Services.getByCust(ServiceType.CXCS_PV_DESIGN_REPORT, cust.s_cust_id);
		}
		else if  (pv_test_type_id.equals("2")) {
			services = Services.getByCust(ServiceType.CXCS_PV_CONTENT_SCORE_REPORT, cust.s_cust_id);
		}
		else {
			services = Services.getByCust(ServiceType.CXCS_PV_DELIVERY_REPORT, cust.s_cust_id);
		}
		Service service = (Service) services.get(0);
		
		String frmAction = service.getURL().toString() + "?action=Run+Report&iframe=1&session=1&X-PVIQ=";
		frmAction = frmAction + pv_iq;	
%>
	</head>
	<body>
		<form name='frmUserCode' id='frmUserCode' method='post' action='<%=HtmlUtil.getPVBaseAction(frmAction)%>'>
		    <%=HtmlUtil.generatePVHiddenInputs(frmAction)%>
			<input type=hidden value='<%=user.s_pv_login%>' name=username>
			<input type=hidden value='<%=pvClientId%>' name=clientid>
			<input type=hidden value='<%=user.s_pv_password%>' name=password>
			<input type=hidden value='LOGIN' name=submitbutton>
		</form>
		<script language="javascript">
		<!--
		document.frmUserCode.submit();
		-->
		</script>
	</body>
</html>
<%
	}
	catch (Exception ex)	{ 
		ErrLog.put(this, ex, "PV error: ",out,1);
	}
	finally	{
		if( stmt != null ) stmt.close();
		if( conn != null ){ cp.free(conn); }
	}
%>
