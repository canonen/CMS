<%@ page

	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
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
%>		
<HTML>

<HEAD>
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>
<table cellspacing="0" cellpadding="3" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="newbutton" href="program_type_edit.jsp">New Program Type</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Program Types used in Analytical Reporting&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th>Program Type Name</th>
				</tr>
		<%

		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null; 
		String sSQL = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
			stmt = conn.createStatement();

			sSQL =
				" SELECT program_type_id, program_type_name" +
				" FROM cque_camp_program_type" +
				" WHERE cust_id=" + cust.s_cust_id +
				" ORDER BY program_type_id";

			rs = stmt.executeQuery(sSQL);

			String sProgramTypeId = null;
			String sProgramTypeName = null;
			int i = 0;

			while(rs.next())
			{
						
				sProgramTypeId = rs.getString(1);
				sProgramTypeName = rs.getString(2);
				i++;
				%>
				<tr>
					<td class="listItem_Title<%=sProgramTypeId %>"><a href="program_type_edit.jsp?program_type_id=<%=sProgramTypeId%>"><%=sProgramTypeName%></a></td>
				</tr>
				
				<%
			}
			rs.close();
				
			if (i == 0)
			{
				%>
				<tr>
					<td class="listItem_Title">There are currently no Program Types</td>
				</tr>
				<%
			}
		}
		catch(Exception ex)
		{
			ex.printStackTrace(response.getWriter());
		}
		finally
		{
			if(conn!=null) cp.free(conn);
		}
		%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</BODY>
</HTML>
