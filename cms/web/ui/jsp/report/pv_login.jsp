<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.rpt.*,
			java.util.*,java.net.*,java.io.*,
			java.sql.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ include file="functions.jsp"%>
<%! static Logger logger = null; %>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	boolean bFeat = false;
	bFeat = ui.getFeatureAccess(Feature.PV_LOGIN);
	if (!bFeat){
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	AccessPermission can = user.getAccessPermission(ObjectType.PV_DELIVERY_TRACKER);
	
	if(!can.bRead || !can.bExecute)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	Vector services = Services.getByCust(ServiceType.CXCS_PV_LOGIN, cust.s_cust_id);		
	Service service = (Service) services.get(0);

	String sPVActionURL = service.getURL().toString() + "?action=Run+Report";
	String sPVuserId = user.s_pv_login;
	String sPVpassword = user.s_pv_password;
		
	// Connection
	Statement		stmt	= null;
	ConnectionPool	cp		= null;
	Connection		conn	= null;
	String sPVclientid = null;
	
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("pv_login.jsp");
		stmt = conn.createStatement();
		sPVclientid = getPV_ClientId(cust.s_cust_id, stmt);
%>
<%@ include file="pv_login.inc"%>

<%
	}
	catch(Exception ex)	{ 
		ErrLog.put(this, ex, "PV Login error.",out,1);
	}
	finally	{
		if( stmt != null ) stmt.close(); 
		if( conn != null ){ cp.free(conn); }
	}
%>
