<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
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

if(!can.bDelete)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}


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


%>
<HTML>
<HEAD>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<%@ include file="../../header.html" %>
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=500 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>User:</b> Deleted</td>
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
						The User<br>
						<% if (u != null)
						{
							if (u.s_user_name != null)
							{
								%>
								'<%= HtmlUtil.escape(u.s_user_name) %>'
								<br>
								<%
							}
						}
						%>
						has been deleted.
						<BR>
						<A href="user_list.jsp">Back to list</A>
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
