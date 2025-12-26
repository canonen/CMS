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
			<a class="newbutton" href="from_address_edit.jsp">New From Address</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			From Addresses&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th>From address</th>
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
				" SELECT from_address_id, prefix, domain" +
				" FROM ccps_from_address" +
				" WHERE cust_id=" + cust.s_cust_id +
				" ORDER BY prefix";

			rs = stmt.executeQuery(sSQL);

			String sFromAddressId = null;
			String sPrefix = null;
			String sDomain = null;
				
			String sClassAppend = "";
			int i = 0;

			while(rs.next())
			{
				if (i % 2 != 0)
				{
					sClassAppend = "_Alt";
				}
				else
				{
					sClassAppend = "";
				}
				i++;
				
				sFromAddressId = rs.getString(1);
				sPrefix = rs.getString(2);
				sDomain = rs.getString(3);
				%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>"><a href="from_address_edit.jsp?from_address_id=<%=sFromAddressId%>"><%=sPrefix%>@<%=sDomain%></a></td>
				</tr>
				<%
			}
			rs.close();
				
			if (i == 0)
			{
				%>
				<tr>
					<td class="listItem_Title">There are currently no From Addresses</td>
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
