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

String sUserId = request.getParameter("user_id");
User u = new User(sUserId);

AccessMasks ams = new AccessMasks();
AccessMask am = null;
int iMask = 0;

for (Enumeration eTypeIds = request.getParameterNames(); eTypeIds.hasMoreElements();)
{
	am = new AccessMask();
	am.s_user_id = u.s_user_id;
	am.s_type_id = (String) eTypeIds.nextElement();

	if("user_id".equals(am.s_type_id)) continue;

	if((!"user_id".equals(am.s_type_id)) && (!"savnclose".equals(am.s_type_id)) && (!"crmid".equals(am.s_type_id)) && (!"crmserver".equals(am.s_type_id)) && (!"crmpage".equals(am.s_type_id)))
	{
		String[] sValues = request.getParameterValues(am.s_type_id);
		int l = ( sValues == null )?0:sValues.length;

		iMask = 0;
		for (int i = 0; i < l; i++)
		{
			iMask = iMask | Integer.parseInt(sValues[i]);
		}

		am.s_mask = String.valueOf(iMask);
		ams.add(am);
	}
}

ams.saveWithSync();

String s_crm_savnclose = request.getParameter("savnclose");
String s_crm_id = request.getParameter("crmid");
String s_crm_server = request.getParameter("crmserver");
String s_crm_page = request.getParameter("crmpage");

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
<form name="saveUser" id="saveUser" action="http://<%= s_crm_server %>/britemoon/settings/users/am.aspx" method="get">
<input type="hidden" name="id" id="hdn_crm_bizuser_id" value="<%= s_crm_id %>">
<input type="hidden" name="hdn_save_n_close" id="hdn_save_n_close" value="<%= s_crm_savnclose %>">
</form>
</body>
</html>