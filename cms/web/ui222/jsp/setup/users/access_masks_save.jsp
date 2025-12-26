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
%>

<%
String sUserId = request.getParameter("user_id");
String sSaveAndRequestApproval = request.getParameter("save_and_request_approval");
User u = new User(sUserId);

AccessMasks ams = new AccessMasks();
AccessMask am = null;
int iMask = 0;
String sTypeId = null;

for (Enumeration eTypeIds = request.getParameterNames(); eTypeIds.hasMoreElements();)
{
     sTypeId = (String)eTypeIds.nextElement();
     if (sTypeId.equals("disposition_id")) continue;
     if (sTypeId.equals("object_type")) continue;
     if (sTypeId.equals("object_id")) continue;
     if (sTypeId.equals("aprvl_request_id")) continue;
     if (sTypeId.equals("save_and_request_approval")) continue;

	am = new AccessMask();
	am.s_user_id = u.s_user_id;
	am.s_type_id = sTypeId;

	if("user_id".equals(am.s_type_id)) continue;


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

ams.saveWithSync();

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
<table width=500 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Access Rights:</b> Saved</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=500 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=500><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=500><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=500>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
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
