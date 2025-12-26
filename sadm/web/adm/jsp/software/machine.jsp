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
<%@ include file="../header.jsp" %>
<HTML>
<HEAD>
	<TITLE>Machine</TITLE>
	<%@ include file="../header.html" %>
	<LINK rel="stylesheet" href="../../css/style.css" type="text/css">
</HEAD>
<BODY>
<%
ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;
ResultSet	rs = null; 
String sSQL = null;

String sMachineID = BriteRequest.getParameter(request, "machine_id");

try
{
	String sMachineName = "";
	String sIPAddr = "";

	if (sMachineID != null)
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("machine.jsp");
		stmt = conn.createStatement();

		sSQL  = " SELECT machine_name, ip_address FROM sadm_machine WHERE machine_id = "+sMachineID;

	 	rs = stmt.executeQuery(sSQL);
	 	
		while(rs.next())
		{
			sMachineName = rs.getString(1);
			sIPAddr = rs.getString(2);
		}
		rs.close();
		stmt.close();
	}
	%>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
	<col>
	<tr height="35">
		<td valign="top">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="FT.submit()">Save</a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
			<br>
		</td>
	</tr>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:650;">
				<col width="150">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Machine</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form method="post" name="FT" action="machine_save.jsp">
						<input type="hidden" name="machine_id" value="<%=((sMachineID!=null)?sMachineID:"")%>">
						<table border="1" cellspacing="0" width="100%">
							<tr>
								<td width="125">Machine Name</td>
								<td><input type="text" name="machine_name" value="<%= sMachineName %>"></td>
							</t>
							<tr>
								<td width="125">IP Address</td>
								<td><input type="text" name="ip_addr" value="<%= sIPAddr %>"></td>
							</tr>
						</table>
						</form>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
<%
}
catch(Exception ex)
{
	out.print(sSQL);
	ex.printStackTrace(response.getWriter());
}
finally
{
	if(conn!=null) cp.free(conn);
}
%>
</BODY>
</HTML>
