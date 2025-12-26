<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			org.apache.log4j.*"
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
	conn = cp.getConnection("super_camp_save.jsp");
	stmt = conn.createStatement();

	String superCampID = request.getParameter("super_camp_id");
	String superLinkID = request.getParameter("super_link_id");
	String superLinkName = request.getParameter("super_link_name");

	String sLinkIDs = request.getParameter("super_links");
	
	String sSelectedCategoryId = request.getParameter("category_id");

	String sSql;
	if ((superLinkID == null) || (superLinkID.equals("null"))) {
		//New Super Link
		sSql = "SELECT isnull(max(super_link_id), 0)+1 FROM crpt_super_link WHERE super_camp_id = "+superCampID;
		rs = stmt.executeQuery(sSql);
		if (rs.next()) {
			superLinkID = rs.getString(1);
		}
		
		sSql = "INSERT crpt_super_link (super_camp_id, super_link_id, super_link_name) VALUES (?,?,?)";
		pstmt = conn.prepareStatement(sSql);
		pstmt.setString(1, superCampID);
		pstmt.setString(2, superLinkID);
		pstmt.setBytes(3, superLinkName.getBytes("ISO-8859-1"));
		pstmt.executeUpdate();
		
		//Insert rows into crpt_super_link
		sSql = "INSERT crpt_super_link_link (super_camp_id, super_link_id, link_id) VALUES ("+superCampID+","+superLinkID+",?)";
		String linkIDs[] = sLinkIDs.split(",");
		for (int i=0; i<linkIDs.length; i++) {
			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1, linkIDs[i]);
			pstmt.executeUpdate();
		}

	} else {
		//Update Super Link
		sSql = "UPDATE crpt_super_link SET super_link_name = ? " +
			   "WHERE super_link_id = "+superLinkID+" AND super_camp_id = "+superCampID;
		pstmt = conn.prepareStatement(sSql);
		pstmt.setBytes(1, superLinkName.getBytes("ISO-8859-1"));
		pstmt.executeUpdate();

		//Delete existing mappings
		stmt.executeUpdate("DELETE crpt_super_link_link WHERE super_camp_id = "+superCampID+" AND super_link_id = "+superLinkID);
		
		//Insert rows into crpt_super_link_link
		sSql = "INSERT crpt_super_link_link (super_camp_id, super_link_id, link_id) VALUES ("+superCampID+","+superLinkID+",?)";
		String linkIDs[] = sLinkIDs.split(",");
		for (int i=0; i<linkIDs.length; i++) {
			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1, linkIDs[i]);
			pstmt.executeUpdate();
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
		<td class=sectionheader>&nbsp;<b class=sectionheader>Super Campaign:</b> Link Saved</td>
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
						<b>The super campaign link was saved.</b>
						<P align="center"><a href="super_camp_report_list.jsp<%=(sSelectedCategoryId!=null)?"?CategoryID="+sSelectedCategoryId:""%>">Back to List</a></P>
						<P align="center"><a href="super_camp_object.jsp?super_camp_id=<%= superCampID %><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">Back to Edit</a></P>
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
	ErrLog.put(this,ex,"super_link_save.jsp",out,1);
	return;
} finally {
	if (stmt != null) stmt.close();
	if (pstmt != null) pstmt.close();
	if (conn != null) cp.free(conn);
}

%>
