<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>

<%@ include file="../../header.jsp" %>
<%@ include file="../../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.USER);
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);


if(!can.bDelete)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
JsonObject data = new JsonObject();

String sUserId = request.getParameter("user_id");
if (sUserId == null) {  // Can't proceed without a user ID, so error out.
     throw new Exception("\nError during User Delete. No UserId was passed from User Edit page (user_edit.jsp)\n");
}

User u = null;
try {
     u = new User(sUserId);
} catch (Exception e) {
     u = null;
     if (sUserId == null) sUserId = "Unknown";
     throw new Exception ("\nError during User Delete. User not found in database. User ID:" +  sUserId +"\n" );
}
if (u != null) {
     u.s_status_id = String.valueOf(UserStatus.DELETED);
     try {
          u.saveWithSync();
     } catch (Exception e) {
          throw new Exception("Error during Save/Synchronization of User during User Delete.",e);
     }
}



						 if (u != null)
						{
							if (u.s_user_name != null)
							{

								data.put("UserName", u.s_user_name);
								out.println(data);

							}
						}
						%>
