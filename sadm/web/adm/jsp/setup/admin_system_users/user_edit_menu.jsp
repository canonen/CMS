<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp" %>

<%
	String sUserId = BriteRequest.getParameter(request, "system_user_id");
	SystemUser user = new SystemUser(sUserId);
	sUserId = user.s_system_user_id;
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../../css/style.css">
</HEAD>
<BODY>
<a class="resourcebutton" href="user_list.jsp" target="detail"><< Return to System Users</a>
<br><br>
<table cellspacing="0" cellpadding="0" width="100%" border="0">
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100% colspan=2><img height=2 src="../../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab>
			<table width=100% class=main border="0" cellspacing="1" cellpadding="2">
				<tr>
					<td align="left" valign="middle" class="pageheader"><%=(sUserId==null)?"New":user.s_first_name + " " + user.s_last_name + " (" + user.s_system_user_id + ")"%></td>
				</tr>
				<tr>
					<td align="left" valign="middle" style="padding:10px;">
						<table border="0" cellspacing="0" cellpadding="2">
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>1</td>
								<td><a target="main_02" href="user_edit.jsp?<%= (sUserId==null)?"":"system_user_id=" + sUserId %>">General Info</a></td>
							</tr>
						<% if (sUserId != null) { %>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>2</td>
								<td><a target="main_02" href="access_masks.jsp?system_user_id=<%= sUserId %>">Access Rights</a></td>
							</tr>
						<% } %>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br><br>
</BODY>
</HTML>