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

} catch(Exception ex) {
	ErrLog.put(this,ex,"folder_delete.jsp",out,1);
	return;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
%>
