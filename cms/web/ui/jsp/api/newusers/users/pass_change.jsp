<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.wfl.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
JsonObject data = new JsonObject();
JsonArray array = new JsonArray();
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

String sStatus = request.getParameter("status");
if (sStatus == null) sStatus = "1";

String sErr = request.getParameter("err");
if (sErr == null) sErr = "0";

String sUserId = request.getParameter("user_id");

User u = null;
UserUiSettings uus = null;

u = new User(sUserId);
uus = new UserUiSettings(sUserId);

String sRemainingDays = u.remainingPassDays();
if (sRemainingDays == null) sRemainingDays = "0";


data.put("userID", u.s_user_id);
data.put("status",sStatus);

if ("1".equals(sStatus)){
data.put("sRemainingDays",sRemainingDays);


}
out.println(data);
%>
