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

if(!can.bDelete)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// Connection
Statement			stmt	= null;
PreparedStatement	pstmt	= null;
ResultSet			rs		= null; 
ConnectionPool		cp 		= null;
Connection			conn 	= null;

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("cont_block_delete.jsp");
        conn.setAutoCommit(false);
	stmt = conn.createStatement();

	String sSelectedCategoryId = request.getParameter("category_id");

	String contID = request.getParameter("cont_id");
	
	String sSql;
	if (contID != null) {
		//Make sure this customer owns this content block
		rs = stmt.executeQuery("SELECT 1 FROM ccnt_content " +
						       "WHERE cust_id = "+cust.s_cust_id+" AND cont_id = "+contID);
		if (rs.next()) {
			try {

				//Delete paragraph
				stmt.executeUpdate("DELETE ccnt_cont_body WHERE cont_id = "+contID);

				//Delete content send params
				stmt.executeUpdate("DELETE ccnt_cont_send_param WHERE cont_id = "+contID);

				//Delete content edit info
				stmt.executeUpdate("DELETE ccnt_cont_edit_info WHERE cont_id = "+contID);

				//Delete content block
				stmt.executeUpdate("DELETE ccnt_content WHERE cont_id = "+contID);

				conn.commit();
			} catch (SQLException e) {
				//Could not delete, probably dependency
				conn.rollback();
				
				throw new Exception("Could not delete.  Content Element is being used.");
			}
		}
	}
	%>
<HTML>
<HEAD>
<title>Content Element: Delete</title>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Content Element:</b> Deleted</td>
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
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<b>The content element was deleted.</b>
						<P align="center"><a href="cont_block_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to List</a></P>
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
	ErrLog.put(this,ex,"cont_block_delete.jsp",out,1);
	return;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) {
            conn.setAutoCommit(true);
            cp.free(conn);
        }
}

%>
