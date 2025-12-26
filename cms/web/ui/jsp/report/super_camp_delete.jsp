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


// Connection
Statement			stmt	= null;
PreparedStatement	pstmt	= null;
ResultSet			rs		= null; 
ConnectionPool		cp 		= null;
Connection			conn 	= null;

try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("super_camp_delete.jsp");
	stmt = conn.createStatement();

	String superCampID = request.getParameter("super_camp_id");
	
	String sSql;
	if (superCampID != null) {
		//Make sure this customer owns this super camp
		rs = stmt.executeQuery("SELECT 1 FROM cque_super_camp " +
						       "WHERE cust_id = "+cust.s_cust_id+" AND super_camp_id = "+superCampID);
		if (rs.next()) {
			//Delete existing mappings
			stmt.executeUpdate("DELETE crpt_super_link_link WHERE super_camp_id = "+superCampID);

			//Delete existing mappings
			stmt.executeUpdate("DELETE crpt_super_link WHERE super_camp_id = "+superCampID);

			//Delete existing mappings
			stmt.executeUpdate("DELETE cque_super_camp_camp WHERE super_camp_id = "+superCampID);

			//Delete super camp
			stmt.executeUpdate("DELETE cque_super_camp WHERE super_camp_id = "+superCampID);
		}
	}
%>
<HTML>
<HEAD>
	<LINK rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Super Campaign:</b> Deleted</td>
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
						<b>The super campaign was deleted.</b>
						<P align="center"><a href="super_camp_report_list.jsp">Back to List</a></P>
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
	ErrLog.put(this,ex,"super_camp_delete.jsp",out,1);
	return;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}

%>
