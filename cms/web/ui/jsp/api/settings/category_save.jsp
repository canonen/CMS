<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.Logger"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CATEGORY);
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
if(!can.bWrite)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

Category category = new Category();

category.s_cust_id = cust.s_cust_id;
category.s_category_id = BriteRequest.getParameter(request,"category_id");
category.s_category_name = BriteRequest.getParameter(request,"category_name");
category.s_category_descrip = BriteRequest.getParameter(request,"category_description");
  category.save();

%>