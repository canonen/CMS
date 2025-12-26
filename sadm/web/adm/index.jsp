<%@ page
	language="java"
	import="com.britemoon.*, com.britemoon.sas.*, java.net.*, java.io.*, java.sql.*, java.util.*, java.util.*, java.sql.*, org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%

	String requireLogin = Registry.getKey("sas_require_login");
	
	if ("1".equals(requireLogin))
	{
		response.sendRedirect("jsp/login.jsp");
	}
	else
	{
		response.sendRedirect("jsp/login2.jsp?partner=Revotas&login=kulland&password=test");
	}

%>