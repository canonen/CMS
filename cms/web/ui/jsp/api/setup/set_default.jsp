<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>

<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CATEGORY);

if(!((user.s_cust_id).equals(cust.s_cust_id) && can.bExecute))
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}


String sCategoryID = request.getParameter("category_id");
UserUiSettings uus = new UserUiSettings(user.s_user_id);

JsonObject message = new JsonObject();

try{
	if((sCategoryID == null)||("0".equals(sCategoryID)))
	{
		uus.s_cust_id = null;
		uus.s_category_id = null;
	}
	else uus.s_category_id = sCategoryID;

	uus.save();
	ui.s_category_id = uus.s_category_id;
	message.put("message: ", "Set successfully!");
}catch (Exception ex){
	message.put("error: ", ex.getMessage());
}
out.print(message);
%>
