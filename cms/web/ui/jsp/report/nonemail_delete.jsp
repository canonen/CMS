<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

String sImportID = request.getParameter("import_id");

if (!can.bDelete)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// Connection
Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool	connectionPool= null;
Connection			srvConnection = null;

String sDetailXML = "";

try	{
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("nonemail_delete.jsp");
	stmt = srvConnection.createStatement();

	stmt.executeUpdate("DELETE crpt_nonemail_import"
			+ " WHERE cust_id = "+cust.s_cust_id+" AND import_id = "+sImportID);

%>
<HTML>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Non email Import:</b> Deleted</td>
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
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<b>Non-email Import Deleted.</b>
						<P align="center"><a href="nonemail_list.jsp">Back to List</a></P>
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
<%

} catch(Exception ex) { 

	ErrLog.put(this,ex,"Problem with Delete "+sDetailXML,out,1);

} finally {
	if ( stmt != null ) stmt.close();
	if ( srvConnection != null ) connectionPool.free(srvConnection); 
}
%>
</BODY></HTML>





