<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.*,
			org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    if(!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
%>

<%
    String sLinkId = request.getParameter("link_id");

    LinkRenaming link = new LinkRenaming();

    if (sLinkId != null) {
        link.s_link_id = sLinkId;
        int nRetrieve = link.retrieve();
        if ((nRetrieve > 0) && !(cust.s_cust_id.equals(link.s_cust_id))) link = new LinkRenaming();
         String sLinkId = request.getParameter("link_id");
String linkName = HtmlUtil.escape(link.s_link_name);
String linkTypeId = link.s_link_type_id;

// Construct a JSONObject with the extracted data
JSONObject jsonObject = new JSONObject();
jsonObject.put("link_id", sLinkId);
jsonObject.put("link_name", linkName);
jsonObject.put("link_type_id", linkTypeId);
    }

%>
