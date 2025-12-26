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
<%@ include file="../../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);


String oldPass = BriteRequest.getParameter(request,"old_password");
String newPass = BriteRequest.getParameter(request,"new_password");
String sUserId = BriteRequest.getParameter(request,"user_id");

String sStatus = BriteRequest.getParameter(request,"status");

// === === ===

User chkU = new User(sUserId);
String confirmOldPass = chkU.s_password;
if (oldPass == null) oldPass = "";

if (oldPass.equals(confirmOldPass))
{
	User u = new User(sUserId);
	u.s_password = BriteRequest.getParameter(request,"password");
	u.saveWithSync();
}
else
{
	response.sendRedirect("pass_change.jsp?err=1&status=" + sStatus + "&user_id=" + sUserId);
	return;
}
// === === ===


%>

	

