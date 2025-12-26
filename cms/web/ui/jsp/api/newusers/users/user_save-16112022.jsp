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
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.USER);

if(!can.bWrite)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

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
u.s_recip_owner = BriteRequest.getParameter(request,"recip_owner");
// added for release 5.9 , pviq changes 
u.s_pv_login = BriteRequest.getParameter(request,"pv_login");
u.s_pv_password = BriteRequest.getParameter(request,"pv_password");

String sSaveAndRequestApproval = BriteRequest.getParameter(request,"save_and_request_approval");

// === === ===

UserUiSettings uus = new UserUiSettings();

uus.s_user_id = BriteRequest.getParameter(request,"user_id");
uus.s_cust_id = BriteRequest.getParameter(request,"cust_id");
uus.s_category_id = BriteRequest.getParameter(request,"category_id");
uus.s_ui_type_id = BriteRequest.getParameter(request,"ui_type_id");	
uus.s_recip_view_count = BriteRequest.getParameter(request,"recip_view_count");	
uus.s_default_page_size = BriteRequest.getParameter(request,"default_page_size");		

if(uus.s_cust_id == null) uus.s_category_id = null;
if(uus.s_category_id == null) uus.s_cust_id = null;

u.m_UserUiSettings = uus;

// === === ===

u.saveWithSync();

// === === ===

if(bIsUserNew)
{
	response.sendRedirect("access_masks.jsp?isnew=true&user_id=" + u.s_user_id);
	return;
}

if (sSaveAndRequestApproval.equals("1")) {
     u.retrieve();
     String sRedirUrl = "../../workflow/approval_request_edit.jsp?object_type=" + ObjectType.USER+ "&object_id=" + u.s_user_id;
     response.sendRedirect(sRedirUrl);
     return;
}

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=500 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>User:</b> Saved</th>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td valign=top align=center width=500>
			<table cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<A href="user_list.jsp">Back to list</A>
						<BR><BR>
						<A href="user_edit.jsp?user_id=<%=u.s_user_id%>">Back to edit General Info</A>
						<BR><BR>
						<A href="access_masks.jsp?user_id=<%=u.s_user_id%>">Back to edit Access Rights</A>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>
