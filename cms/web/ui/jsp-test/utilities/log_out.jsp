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
<%@ include file="validator.jsp" %>
<%@ include file="header.jsp" %>

<%

    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
    HttpSession scope = request.getSession(false);

    if (scope != null) {
        scope.invalidate();

    }
%>


