<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,java.io.*,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<%
int numLinks		= Integer.parseInt(request.getParameter("num_links"));
LinkRenaming link	= null;
int count			= 0;

for (int i = 1; i <= numLinks; i++)
{
	count++;
	
	link = new LinkRenaming();

	link.s_link_id = BriteRequest.getParameter(request, "link_id"+i);
	link.s_cust_id = cust.s_cust_id;
	link.s_link_name = BriteRequest.getParameter(request, "link_name"+i);
	link.s_link_type_id = BriteRequest.getParameter(request, "link_type_id"+i);
	link.s_link_definition = BriteRequest.getParameter(request, "link_definition"+i);
	
	link.save();
}

// === === ===

%>

<HTML>
<HEAD>
	<BASE target="_self">
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Auto Link Name:</b> Saved</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p align="center"><b>The Auto Link Name was saved.</b></p>
						<p align="center"><a href="link_renaming_list.jsp">Back to List</a></p>
						<p align="center"><a href="link_renaming_edit.jsp?link_id=<%= link.s_link_id %>">Back to Edit</a></p>
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
