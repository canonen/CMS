<%@ page
	language="java"
	import="com.oreilly.servlet.multipart.*,
			com.oreilly.servlet.multipart.Part,
			com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.io.*,java.util.*,
			java.sql.*,javax.servlet.http.*,
			javax.servlet.*,org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

Statement stmt = null;
PreparedStatement prepStmt = null;
ResultSet rs = null; 
ConnectionPool connectionPool = null;
Connection srvConnection = null;
String sSql = null;

//try	{	
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("folder_save.jsp");
	stmt = srvConnection.createStatement();

	String sCategories = BriteRequest.getParameter(request,"categorytemp");
	String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");

	String sFolderName = BriteRequest.getParameter(request,"folder_name");
	sFolderName = sFolderName.replace(' ','_');
	
	String sFolderId = BriteRequest.getParameter(request,"folder_id");
	String sParentId = BriteRequest.getParameter(request,"parent_id");
	String sClone = BriteRequest.getParameter(request,"clone");
     if (sClone == null)
          sClone = "0";
	String sPrevFolderId = BriteRequest.getParameter(request,"prevFolderId");
	
	String sAccessCusts = BriteRequest.getParameter(request,"access_map");
	String[] sAccessMap = sAccessCusts.split(";");

	if (sParentId == null || sParentId.length() == 0 || sParentId.equals("null"))
		throw new Exception("No Parent Folder ID parameter found...cannot save folder");

     /* check for duplicate folder path */
     boolean bDuplicateFolder = false;
     String sExistingFolderId = null;
     sExistingFolderId = ImageHostUtil.getFolderIdFromName(cust.s_cust_id, sParentId, sFolderName);
     if (sExistingFolderId != null ) {            //&& sFolderId != null && !sExistingFolderId.equalsIgnoreCase(sFolderId))
          bDuplicateFolder = true;
          String sErrors = "ERROR--Duplicate folder path.  Could not save folder.";
          response.sendRedirect("folder_new.jsp?parent_id=" + sParentId + "&folder_name=" + sFolderName + "&errors="+ sErrors);
     } else {
     /*  ***  */
          /* Save or Create folder */
          if (sClone == null || sClone.equals("0")) {
               sFolderId = ImageHostUtil.createFolder(cust.s_cust_id, sFolderName, sParentId, user.s_user_id, sAccessMap);
          } else if (sClone.equals("1")) {
               sFolderId = ImageHostUtil.cloneFolder(sPrevFolderId, sFolderName, sParentId, user.s_user_id, cust.s_cust_id, sAccessMap);
          }
     }

/*
	//------------------------- Categories -------
	logger.info("categories = "+sCategories);
	String[] sCatsArray = sCategories.split(",");

	int l = ( sCatsArray == null )?0:sCatsArray.length;

	if (sCategories.trim().equals("")) l = 0;

	if ( l > 0) {
		sSql  = " INSERT ccps_object_category (cust_id,  object_id, type_id, category_id)";
		sSql += " VALUES (?, ?, ?, ?)";

		for(int i=0; i<l ;i++) {
			prepStmt = srvConnection.prepareStatement(sSql);
			prepStmt.setString(1, cust.s_cust_id);
			prepStmt.setString(2, sImageID);
			prepStmt.setString(3, String.valueOf(ObjectType.IMAGE));
			prepStmt.setString(4, sCatsArray[i]);
			prepStmt.executeUpdate();
		}
	}
*/
%>
<HTML>

<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Folder:</b> Saved</td>
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
						<b>The folder was created.</b>
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

//} catch (Exception ex) {
//	ErrLog.put(this, ex, "Error in folder_save", out, 1);
//} finally {
	if ( prepStmt != null ) prepStmt.close ();	
	if ( stmt != null ) stmt.close ();	
	if ( srvConnection != null ) connectionPool.free(srvConnection);
//}

%>