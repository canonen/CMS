<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.io.*,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
    JsonObject data= new JsonObject();
    JsonArray array= new JsonArray();

    if(!can.bWrite)
    {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

out.println("wsdadsad");    // === === ===



    ConnectionPool cp	= null;
    Connection conn		= null;


    // === === ===

    String sRedirectURL = null;


%>