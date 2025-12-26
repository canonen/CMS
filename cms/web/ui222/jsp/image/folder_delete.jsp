<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
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

AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

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
	conn = cp.getConnection("folder_delete.jsp");
	stmt = conn.createStatement();

	String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
	String sFolderId = BriteRequest.getParameter(request, "folder_id");

	if (sFolderId == null)
		throw new Exception("NO Folder ID for Folder Delete.");
	ImgFolder folder = new ImgFolder(sFolderId);

	folder.hide(cust.s_cust_id);
%>
<HTML>

<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Folder:</b> Deleted</td>
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
						<b>The folder was deleted.</b>
						<br><br>
						<a href="image_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to List</a>
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
	ErrLog.put(this,ex,"folder_delete.jsp",out,1);
	return;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}

%>
