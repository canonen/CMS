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
}

</script>
</head>
<body onload="saveData();">
<form name="saveUser" id="saveUser" action="http://<%= s_crm_server %>/britemoon/Users_Save.aspx" method="post">
<input type="hidden" name="hdnCRM_UserID" id="hdnCRM_UserID" value="<%= s_crm_id %>">
<input type="hidden" name="hdnCRM_BizUnitID" id="hdnCRM_BizUnitID" value="<%= s_crm_bizunit_id %>">
<input type="hidden" name="hdnCRM_UserName" id="hdnCRM_UserName" value="<%= s_crm_user_name %>">
<input type="hidden" name="hdnCRM_FirstName" id="hdnCRM_FirstName" value="<%= s_crm_first_name %>">
<input type="hidden" name="hdnCRM_LastName" id="hdnCRM_LastName" value="<%= s_crm_last_name %>">
<input type="hidden" name="hdnCRM_Phone" id="hdnCRM_Phone" value="<%= u.s_phone %>">
<input type="hidden" name="hdnCRM_Email" id="hdnCRM_Email" value="<%= u.s_email %>">
<input type="hidden" name="hdnCRM_Position" id="hdnCRM_Position" value="<%= u.s_position %>">
<input type="hidden" name="hdnBritemoon_UserName" id="hdnBritemoon_UserName" value="<%= u.s_login_name %>">
<input type="hidden" name="hdnBritemoon_Password" id="hdnBritemoon_Password" value="<%= u.s_password %>">
<input type="hidden" name="hdnBritemoon_StatusID" id="hdnBritemoon_StatusID" value="<%= u.s_status_id %>">
<input type="hidden" name="hdnBritemoon_UITypeID" id="hdnBritemoon_UITypeID" value="<%= uus.s_ui_type_id %>">
<input type="hidden" name="hdnBritemoon_UserID" id="hdnBritemoon_UserID" value="<%= u.s_user_id %>">
<input type="hidden" name="hdnBritemoon_CategoryID" id="hdnBritemoon_CategoryID" value="<%= uus.s_category_id %>">
<input type="hidden" name="hdnAutoLogIn" id="hdnAutoLogIn" value="<%= s_crm_autologin %>">
<input type="hidden" name="hdnAllowLogIn" id="hdnAllowLogIn" value="<%= s_crm_allowlogin %>">
<input type="hidden" name="hdnSubmitItem" id="hdnSubmitItem" value="submitchanges">
<input type="hidden" name="hdnSaveNClose" id="hdnSaveNClose" value="<%= s_crm_savnclose %>">
<input type="hidden" name="hdnReturnDetails" id="hdnReturnDetails" value="<%= s_crm_return %>">
</form>
</body>
</html>