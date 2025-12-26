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

String cust_id = BriteRequest.getParameter(request, "cust_id");

if((cust_id == null) || ("".equals(cust_id)))
{
	cust_id = "0";
}

String type_id = BriteRequest.getParameter(request, "type_id");

if((type_id == null) || ("".equals(type_id)))
{
	type_id = String.valueOf(SystemUserActivityType.SYSTEM_ADMIN);
}

String redirectURL = BriteRequest.getParameter(request, "url");

if((redirectURL == null) || ("".equals(redirectURL)))
{
	redirectURL = "../session_expired.jsp";
}

ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;
String sSQL = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();
	
	sSQL = "INSERT INTO sadm_system_user_activity" + 
			" (system_user_id, type_id, cust_id, description)" + 
			" VALUES ('" + systemuser.s_system_user_id + "'," + 
			" '" + type_id + "'," + 
			" '" + cust_id + "'," + 
			" '" + redirectURL + "'" + 
			" )";
			
	stmt.executeUpdate(sSQL);
	
	response.sendRedirect(redirectURL);
	
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