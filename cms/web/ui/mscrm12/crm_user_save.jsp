<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.adm.*, 
			java.io.*,
			java.sql.*,
			java.util.*,
			org.apache.log4j.*"
%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
response.setHeader("Expires", "0");
response.setHeader("Pragma", "no-cache");
response.setHeader("Cache-Control", "no-store, no-cache, max-age=0");
response.setContentType("text/html;charset=UTF-8");

// === === ===

User u = new User();

u.s_user_id = BriteRequest.getParameter(request,"user_id");

boolean bIsUserNew = (u.s_user_id == null);

u.s_user_name = BriteRequest.getParameter(request,"user_name");
u.s_last_name = BriteRequest.getParameter(request,"last_name");	
u.s_cust_id = BriteRequest.getParameter(request,"cust_id");
u.s_login_name = BriteRequest.getParameter(request,"login_name");
u.s_password = BriteRequest.getParameter(request,"password");
u.s_position = BriteRequest.getParameter(request,"position");
u.s_phone = BriteRequest.getParameter(request,"phone");
u.s_email = BriteRequest.getParameter(request,"email");
u.s_descrip = BriteRequest.getParameter(request,"descrip");
u.s_status_id = BriteRequest.getParameter(request,"status_id");

// === === ===

UserUiSettings uus = new UserUiSettings();

uus.s_user_id = BriteRequest.getParameter(request,"user_id");
uus.s_cust_id = BriteRequest.getParameter(request,"cust_id");
uus.s_category_id = BriteRequest.getParameter(request,"category_id");
uus.s_ui_type_id = BriteRequest.getParameter(request,"ui_type_id");		

if(uus.s_cust_id == null) uus.s_category_id = null;
if(uus.s_category_id == null) uus.s_cust_id = null;

u.m_UserUiSettings = uus;

// === === ===

u.saveWithSync();

// === === ===

String s_crm_savnclose = BriteRequest.getParameter(request,"savnclose");
String s_crm_autologin = BriteRequest.getParameter(request,"autologin");
String s_crm_allowlogin = BriteRequest.getParameter(request,"allowlogin");
String s_crm_bizunit_id = BriteRequest.getParameter(request,"bizunitid");
String s_crm_user_name = BriteRequest.getParameter(request,"crmusername");
String s_crm_first_name = BriteRequest.getParameter(request,"crmfirstname");
String s_crm_last_name = BriteRequest.getParameter(request,"crmlastname");
String s_crm_id = BriteRequest.getParameter(request,"crmid");
String s_crm_server = BriteRequest.getParameter(request,"crmserver");
String s_crm_return = BriteRequest.getParameter(request,"crmreturn");

// === === ===
%>
<html>
<head>															   
<title>User Saved</title>
<script language="JavaScript">

function saveData()
{
	var SaveFrm = document.saveUser;
	SaveFrm.submit();
	//var obj;
	
	//for (i=0; i < document.getElementsByTagName("INPUT").length; i++)
	//{
	//	obj = document.getElementsByTagName("INPUT")[i];
	//	alert(obj.name + ".value = " + obj.value);
	//}
}

</script>
</head>
<body onload="saveData();">
<form name="saveUser" id="saveUser" action="http://<%= s_crm_server %>/britemoon/settings/users/save.aspx" method="post">
<input type="hidden" name="hdn_crm_bizuser_id" id="hdn_crm_bizuser_id" value="<%= s_crm_id %>">
<input type="hidden" name="hdn_crm_bizunit_id" id="hdn_crm_bizunit_id" value="<%= s_crm_bizunit_id %>">
<input type="hidden" name="hdn_crm_user_name" id="hdn_crm_user_name" value="<%= s_crm_user_name %>">
<input type="hidden" name="hdn_crm_first_name" id="hdn_crm_first_name" value="<%= s_crm_first_name %>">
<input type="hidden" name="hdn_crm_last_name" id="hdn_crm_last_name" value="<%= s_crm_last_name %>">
<input type="hidden" name="hdn_crm_phone" id="hdn_crm_phone" value="<%= u.s_phone %>">
<input type="hidden" name="hdn_crm_email" id="hdn_crm_email" value="<%= u.s_email %>">
<input type="hidden" name="hdn_crm_position" id="hdn_crm_position" value="<%= u.s_position %>">
<input type="hidden" name="hdn_britemoon_user_name" id="hdn_britemoon_user_name" value="<%= u.s_login_name %>">
<input type="hidden" name="hdn_britemoon_password" id="hdn_britemoon_password" value="<%= u.s_password %>">
<input type="hidden" name="hdn_britemoon_status_id" id="hdn_britemoon_status_id" value="<%= u.s_status_id %>">
<input type="hidden" name="hdn_britemoon_uitype_id" id="hdn_britemoon_uitype_id" value="<%= uus.s_ui_type_id %>">
<input type="hidden" name="hdn_britemoon_user_id" id="hdn_britemoon_user_id" value="<%= u.s_user_id %>">
<input type="hidden" name="hdn_britemoon_category_id" id="hdn_britemoon_category_id" value="<%= uus.s_category_id %>">
<input type="hidden" name="hdn_britemoon_auto_login" id="hdn_britemoon_auto_login" value="<%= s_crm_autologin %>">
<input type="hidden" name="hdn_britemoon_allow_login" id="hdn_britemoon_allow_login" value="<%= s_crm_allowlogin %>">
<input type="hidden" name="hdn_submit_item" id="hdn_submit_item" value="submitchanges">
<input type="hidden" name="hdn_save_n_close" id="hdn_save_n_close" value="<%= s_crm_savnclose %>">
<input type="hidden" name="hdnReturnDetails" id="hdnReturnDetails" value="<%= s_crm_return %>">
</form>
</body>
</html>