<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
// Connection
ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null; 

ui.setSessionProperty("content_scrape_section", "2");

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("scrape_format_list.jsp");
	stmt = conn.createStatement();

	String format_id, format_name, modified_date, scrape_name;
%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="SpecialTabOff" width="50%" onclick="location.href = 'scrape_list.jsp';" valign="center" nowrap align="middle">Content Scrapes</td>
		<td class="SpecialTabOn" width="50%" onclick="location.href = 'scrape_format_list.jsp';" valign="center" nowrap align="middle">Scrape Formats</td>
	</tr>
</table>
<br>
<%
if(can.bWrite)
{
	%>
<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="newbutton" href="scrape_format_edit.jsp">New Scrape Format</a>
		</td>
	</tr>
</table>
<br>
<%
}
%>
<FORM  METHOD="POST" NAME="FT" ACTION="">
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Scrape Formats&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th>Format Name</th>
					<th>Modified Date</th>
					<th>Scrape</th>
					<th>Action</th>
				</tr>
			<%
			String sSql = "EXEC usp_ccnt_scrape_format_list_get " +cust.s_cust_id;
									
			rs = stmt.executeQuery(sSql);
				
			String sClassAppend = "";
			int i = 0;

			while( rs.next() )
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
				
				format_id = rs.getString(1);
				format_name = new String(rs.getBytes(2),"UTF-8");
				modified_date = new String(rs.getBytes(3),"UTF-8");
				scrape_name = new String(rs.getBytes(4),"UTF-8");

				%>
				<tr>
					<td class="listItem_Data<%= sClassAppend %>"><a HREF="scrape_format_edit.jsp?format_id=<%= format_id %>"><%= format_name %></a></td>
					<td class="listItem_Title<%= sClassAppend %>"><%= modified_date %></td>
					<td class="listItem_Data<%= sClassAppend %>"><%= scrape_name %></td>
					<td class="listItem_Data<%= sClassAppend %>"><a HREF="generate_content.jsp?format_id=<%= format_id %>">Generate Logic Block</a></td>
				</tr>
				<%
			}
			rs.close();
				
			if (i == 0)
			{
				%>
				<tr>
					<td class="listItem_Data" colspan="2">There are currently no scrape formats</td>
				</tr>
				<%
			}
			%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</FORM>
</BODY>
</HTML>
<%
}
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (conn  != null) cp.free(conn); 
}
%>
