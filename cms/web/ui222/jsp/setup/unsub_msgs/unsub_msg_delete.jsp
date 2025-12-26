<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.adm.*,
		java.sql.*,java.util.Vector,
		org.w3c.dom.*,org.apache.log4j.*"
%>

<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>

<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.UNSUB_EDIT);

if(!can.bDelete)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

Statement 		stmt	= null;
ResultSet 		rs		= null; 
ConnectionPool 	cp		= null;
Connection 		conn	= null;

try 
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("unsub_msg_delete.jsp");
	stmt = conn.createStatement();

	String UnsubMsgId = request.getParameter("msg_id");

	UnsubMsg obj = null;
	obj = new UnsubMsg(UnsubMsgId);
	obj.delete();
%>
<HTML>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader><b class=sectionheader>Unsubscribe Message:</b> Deleted</td>
	</tr>
</table>
<br>
<!---- Info----->
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
						<p align="center">The selected Unsubscribe Message was deleted.</p>
						<p align="center"><a href="unsub_msg_list.jsp">Back to List</a></p>
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
	ErrLog.put(this,ex,"export_delete.jsp",out,1);
	return;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}

%>