<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.imc.*,
			java.util.*,java.util.Date,
			java.text.DateFormat,
			java.sql.*,java.net.*,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp" %>

<%! static Logger logger = null; %>
<%
        if(logger == null)
        {
            logger = Logger.getLogger(this.getClass().getName());
        }

        AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
        boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

        if(!can.bWrite)
        {
            response.sendRedirect("../access_denied.jsp");
            return;
        }

        System.out.println("Hadi bakalım");

%>

