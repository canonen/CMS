<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,java.net.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ 
page import="javax.servlet.http.HttpSession" 
%>


<%
	HttpSession scope = request.getSession(false);
	
	if (scope != null) {
		scope.invalidate();
		response.sendRedirect("/cms/ui/jsp/login.jsp");
	}
%>

