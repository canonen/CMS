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
	<TITLE>Machine List</TITLE>
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
						<a class="newbutton" href="machine.jsp">New Machine</a>&nbsp;&nbsp;&nbsp;
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
				<tr height="22">
					<th nowrap>Machine Name</th>
					<th nowrap>IP Address</th>
					<th nowrap>Module Instances</th>
				</tr>
		<%
		ConnectionPool 	cp = null;
		Connection 	conn = null;
		Connection 	conn2 = null;
		Statement	stmt = null;
		Statement	stmt2 = null;
		ResultSet	rs = null; 
		ResultSet	rs2 = null;
		String 		sSQL = null;

		try
		{
			String sMachineID = null;
			String sMachineName = null;
			String sIPAddr = null;
			String sModInstID = null;
			String sModName = null;

			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("machine_list.jsp");
			stmt = conn.createStatement();
			conn2 = cp.getConnection("machine_list.jsp 2");
			stmt2 = conn2.createStatement();

			sSQL  = " SELECT machine_id, machine_name, ip_address FROM sadm_machine ORDER BY ip_address";

 			rs = stmt.executeQuery(sSQL);
						
			int iCount = 0;
			String sClassAppend = "";
			
			while(rs.next())
			{
				if (iCount % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";
				
				++iCount;
				
				sMachineID = rs.getString(1);
				sMachineName = rs.getString(2);
				sIPAddr = rs.getString(3);
				%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>"><a href="machine.jsp?machine_id=<%= sMachineID %>"><%= sMachineName %></a></td>
					<td class="listItem_Data<%= sClassAppend %>"><%= sIPAddr %></td>
					<td class="listItem_Data<%= sClassAppend %>">
						<%
						sSQL =
							" SELECT i.mod_inst_id, m.mod_name FROM sadm_mod_inst i, sadm_module m" +
							" WHERE i.mod_id = m.mod_id AND i.machine_id = "+sMachineID;
							
						rs2 = stmt2.executeQuery(sSQL);
						
						sModInstID = null;
						
						while(rs2.next())
						{
							sModInstID = rs2.getString(1);
							sModName = rs2.getString(2);
							%>
							<a href="mod_inst.jsp?mod_inst_id=<%=sModInstID%>"><%=sModName%>(<%=sModInstID%>)</a><BR>
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
						<a class="resourcebutton" href="mod_inst.jsp?machine_id=<%= sMachineID %>">Add</a>
					</td>
				</tr>	
				<%
			}
			rs.close();
			stmt.close();
			stmt2.close();
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
			</table>
			</div>
		</td>
	</tr>
</table>
</BODY>
</HTML>
