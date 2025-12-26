<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,java.io.*,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<%
String sAttrId = request.getParameter("attr_id");

String msg = "Content Field deleted.";
if (sAttrId != null) {
	// Connection
	Statement			stmt	= null;
	PreparedStatement	pstmt	= null;
	ResultSet			rs		= null; 
	ConnectionPool		cp 		= null;
	Connection			conn 	= null;
	try	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("cont_attrs_delete.jsp");
		stmt = conn.createStatement();
		
		String sSql;
		
		// check if other customer use this content field
		rs = stmt.executeQuery("SELECT 1 FROM ccps_cont_attr_value WHERE cust_id != " + cust.s_cust_id + " AND attr_id = " + sAttrId);
		if (rs.next()) {
			rs.close();
			stmt.executeUpdate("DELETE ccps_cont_attr_value WHERE cust_id = " + cust.s_cust_id + " AND attr_id = " + sAttrId);
			msg = "This Content Field is used by other customers, only Content Field value for this customer is deleted.";
		}
		else {
			rs.close();
			try {
				stmt.executeUpdate("DELETE ccps_cont_attr_value WHERE cust_id = " + cust.s_cust_id + " AND attr_id = " + sAttrId);
				stmt.executeUpdate("DELETE ccps_cont_attr WHERE cust_id = " + cust.s_cust_id + " AND  attr_id = " + sAttrId);
				msg = "Content Field deleted";
			}
			catch (SQLException e) {
				msg = "Unable to delete Content Field due to database error";
			}
		}
	}
	catch(Exception ex) { throw ex; }
	finally{
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
}

// === === ===

%>

<HTML>
<HEAD>
	<BASE target="_self">
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
	    <td class=sectionheader>&nbsp;<b class=sectionheader>Content Field Delete</td>
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
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p align="center"><b><%=msg%></b></p>
						<p align="center"><a href="cont_attr_list.jsp">Back to List</a></p>
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
