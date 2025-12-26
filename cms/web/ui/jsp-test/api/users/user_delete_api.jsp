<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../utilities/header.jsp" %>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%

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
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
response.setHeader("Access-Control-Allow-Origin", "*");
out.print("success");

%>
