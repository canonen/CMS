<%
	response.setContentType("*/*");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin","https://cms.revotas.com:3001");
	response.setHeader("Access-Control-Allow-Credentials", "true");
	response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
%>


<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,java.net.*,
			org.apache.log4j.*"
%>
<%@
        page import="javax.servlet.http.HttpSession"
%>
<%

    HttpSession scope = request.getSession(false);

    if (scope != null) {
        scope.invalidate();

    }
%>