<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		java.sql.*,java.util.Vector,
		org.w3c.dom.*,org.apache.log4j.*"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

Statement 		stmt	= null;
ResultSet 		rs		= null; 
ConnectionPool 	cp		= null;
Connection 		conn	= null;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("custom_export_list.jsp");
	stmt = conn.createStatement();

	String		CUSTOMER_ID	= cust.s_cust_id;

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	String		sExpName	= "";
	String		sExpID		= "";

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Custom Exports&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th>Export name</th>
				</tr>
			<%
	  		rs = stmt.executeQuery(
				"SELECT cstm_exp_id, exp_name " +
				"FROM cexp_custom_export " +
				"WHERE cust_id = "+CUSTOMER_ID+" " +
				"ORDER BY exp_name");
			boolean isOne = false;
			
			String sClassAppend = "";
			int i = 0;
			
			while (rs.next())
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
				
				isOne = true;
				sExpID   = rs.getString(1);
				sExpName = new String(rs.getBytes(2),"ISO-8859-1");
				%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>"><a href="custom_export_new.jsp?exp_id=<%=sExpID%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>"> <%=sExpName%> </a></td>
				</tr>
				<%
			}
			rs.close();
			
			if (!isOne)
			{
				%>
				<tr>
					<td class="listItem_Title">You have no custom exports defined.</td>
				</tr>
				<%
			}
			%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</BODY>
<%

	}
	catch(Exception ex)
	{
		ErrLog.put(this,ex,"custom_export_list.jsp",out,1);
		return;
	}
	finally
	{
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>
</HTML>
