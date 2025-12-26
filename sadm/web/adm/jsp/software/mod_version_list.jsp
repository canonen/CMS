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
	<TITLE>Module Version List</TITLE>
	<%@ include file="../header.html" %>
	<LINK rel="stylesheet" href="../../css/style.css" type="text/css">
</HEAD>
<BODY>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
	<tr height="35">
		<td valign="middle">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="newbutton" href="mod_version.jsp">New Module Version</a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
			<br>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<div style="width:100%; height:100%; overflow:auto;">
			<table class="listTable layout" style="width:100%; height:100%;" cellspacing="0" cellpadding="2" border="0">
				<col>
				<col>
				<col>
				<col>
				<tr height="22">
					<th nowrap>Module</th>
					<th nowrap>Version</th>
					<th nowrap>Services</th>
					<th nowrap>Machine Instances</th>
				</tr>
<%
ConnectionPool cp = null;
Connection 	conn = null;
Statement	stmt = null;
ResultSet	rs = null; 
Connection 	conn2 = null;
Statement	stmt2 = null;
ResultSet	rs2 = null; 
String sSQL = null;

try
{
	String sModID = null;
	String sModName = null;
	String sVersion = null;
	String sServTypeID = null;
	String sServTypeName = null;
	String sModInstID = null;
	String sMachineName = null;
	String sMachineID = null;

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("mod_version_list.jsp");
	stmt = conn.createStatement();
	conn2 = cp.getConnection("mod_version_list.jsp 2");
	stmt2 = conn2.createStatement();

	sSQL =
		" SELECT v.mod_id, m.mod_name, v.version" +
		" FROM sadm_module m, sadm_mod_version v" +
		" WHERE m.mod_id = v.mod_id" +
		" ORDER BY v.mod_id, v.version";

 	rs = stmt.executeQuery(sSQL);
				
	int iCount = 0;
	String sClassAppend = "";
 	
	while(rs.next())
	{
		if (iCount % 2 != 0) sClassAppend = "_Alt";
		else sClassAppend = "";
		
		++iCount;
		
		sModID = rs.getString(1);
		sModName = rs.getString(2);
		sVersion = rs.getString(3);
		%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>"><%=sModName%></td>
					<td class="listItem_Data<%= sClassAppend %>"><a href="mod_version.jsp?mod_id=<%=sModID%>&version=<%=sVersion%>"><%=sVersion%></a></td>
					<td class="listItem_Data<%= sClassAppend %>">
						<%
						sSQL =
							" SELECT s.service_type_id, t.type_name" +
							" FROM sadm_mod_version_service s, sadm_service_type t" +
							" WHERE s.service_type_id = t.type_id" +
							" AND s.mod_id = " + sModID +
							" AND s.version = " + sVersion;

						rs2 = stmt2.executeQuery(sSQL);
						
						sServTypeID = null;
						
						while(rs2.next())
						{
							sServTypeID = rs2.getString(1);
							sServTypeName = rs2.getString(2);
							%>
							<a href="mod_version_service.jsp?mod_id=<%=sModID%>&version=<%=sVersion%>&service_type_id=<%=sServTypeID%>"><%=sServTypeName%></a><br>
							<%
						}
						rs2.close();
						
						if (sServTypeID != null)
						{
							%>
						<br>
							<%
						}
						%>
						<a class="resourcebutton" href="mod_version_service.jsp?mod_id=<%=sModID%>&version=<%=sVersion%>">Add</a>
					</td>
					<td class="listItem_Data<%= sClassAppend %>">
						<%
						sSQL =
							" SELECT i.mod_inst_id, m.machine_name" +
							" FROM sadm_mod_inst i, sadm_machine m" +
							" WHERE i.machine_id = m.machine_id" +
							" AND i.mod_id = " + sModID;
							
						rs2 = stmt2.executeQuery(sSQL);
						
						sModInstID = null;
						
						while(rs2.next())
						{
							sModInstID = rs2.getString(1);
							sMachineName = rs2.getString(2);
							%>
							<a href="mod_inst.jsp?mod_inst_id=<%=sModInstID%>"><%=sMachineName%>(<%=sModInstID%>)</a><BR>
							<%
						}
						rs2.close();
						
						if (sModInstID != null)
						{
							%>
						<br>
							<%
						}
						%>
						<a class="resourcebutton" href="mod_inst.jsp?mod_id=<%=sModID%>&version=<%=sVersion%>">Add</a>
				</td>
			</tr>
		<%
	}
	rs.close();
	stmt.close();
	stmt2.close();
	%>
			</table>
			</div>
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
	if(conn2!=null) cp.free(conn2);
}
%>
</BODY>
</HTML>
