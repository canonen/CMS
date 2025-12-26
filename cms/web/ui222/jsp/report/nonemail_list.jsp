<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.ctl.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
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

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

%>
<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<SCRIPT src="../../js/scripts.js"></SCRIPT>
</HEAD>
<BODY>
<%
if(can.bWrite)
{
	%>
	<table cellpadding="4" cellspacing="0" border="0" width="525">
		<tr>
			<td vAlign="middle" align="left">
				<a class="newbutton" href="nonemail_new.jsp">New</a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>
<TABLE class="listTable" width="650" cellpadding="2" cellspacing="0">
	<TR>
		<TH>Campaign</TH>
		<TH>Recipients</TH>
		<TH>Import Date</TH>
		<TH>Import User</TH>
		<TH>Delete</TH>
	</TR>
<%
ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);

	try
	{
		sSql = "EXEC usp_crpt_nonemail_import_list_get @cust_id=?";

		pstmt = conn.prepareStatement(sSql);

		pstmt.setString(1, cust.s_cust_id);
		
		rs = pstmt.executeQuery();
		
		String sImportID = null;
		String sCampName = null;
		String sNumRecips = null;
		String sImportDate = null;
		String sImportUser = null;
		
		int iCount = 0;
		
		String sClassAppend = "_Alt";

		while (rs.next())
		{
			if (iCount % 2 != 0)
			{
				sClassAppend = "_Alt";
			}
			else
			{
				sClassAppend = "";
			}
			
			iCount++;
			
			sImportID = rs.getString(1);
			sCampName = rs.getString(2);
			sNumRecips = rs.getString(3);
			sImportDate = rs.getString(4);
			sImportUser = rs.getString(5);
			%>
			<TR>
				<TD class="listItem_Data<%= sClassAppend %>"><%=sCampName%>&nbsp;</TD>
				<TD class="listItem_Data<%= sClassAppend %>"><%=(sNumRecips==null)?"":sNumRecips%>&nbsp;</TD>
				<TD class="listItem_Title<%= sClassAppend %>"><%=sImportDate%>&nbsp;</TD>
				<TD class="listItem_Data<%= sClassAppend %>"><%=sImportUser%>&nbsp;</TD>
				<TD class="listItem_Data<%= sClassAppend %>"><a href="nonemail_delete.jsp?import_id=<%=sImportID%>">Delete</a>&nbsp;</TD>
			</TR>
			<%
		}
		rs.close();
	}
	catch(SQLException sqlex)
	{
		throw sqlex;
	}
	finally
	{
		if(pstmt != null) pstmt.close();
	}
}
catch(Exception ex)
{
	ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
}
finally
{
	if(conn != null) cp.free(conn);
}
%>
</TABLE>

<SCRIPT>
</SCRIPT>
</BODY>
</HTML>

