<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	
	import="java.text.SimpleDateFormat"	
	import="java.util.Calendar.*"
	import="java.util.Date"
    import="java.text.DateFormat"

%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>

<%

	ConnectionPool cp = null;
	Connection conn = null;
	PreparedStatement pstmt = null;
	String sSql = "";

	try
	{			
	
			int id = Integer.parseInt(request.getParameter("id"));			
			cp = ConnectionPool.getInstance();	
			conn = cp.getConnection(this);			
			sSql = "update mail_pmta_ip_config set status = 0 where id = ?";
			pstmt = conn.prepareStatement(sSql);			
			pstmt.setInt(1, id);
			pstmt.executeUpdate();
			
			response.sendRedirect("http://cms.revotas.com/sadm/adm/jsp/pmta_ip_config/index.jsp");
			return;
				
	 }
	 catch(Exception e) {
		e.printStackTrace();
	 }
	 finally
	 {
		if(pstmt != null) pstmt.close();
		if (conn != null) cp.free(conn);		 
	 }
%>