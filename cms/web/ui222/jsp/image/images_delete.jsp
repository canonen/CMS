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

ConnectionPool		cp 		= null;
Connection			conn 	= null;
String sImageId = null;
String sFolderId = null;
String sParentFolderId = null;
Vector vFolderDeletes = new Vector();
Vector vImageDeletes = new Vector();

try	{

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("images_delete.jsp");

	sParentFolderId = BriteRequest.getParameter(request,"parent_folder_id");

	String[] sFolders = BriteRequest.getParameterValues(request,"folders");

	if (sFolders != null) {
		for (int i=0; i < sFolders.length;i++) {
			sFolderId = sFolders[i];

			if (sFolderId == null) {
				String sError = "<td>&nbsp;</td><td>Folder</td><td><font color=red>Error</font></td><td>Missing folder ID";
				vFolderDeletes.add(sError);
				continue;
			}
			ImgFolder folder = new ImgFolder(sFolderId);
			folder.hide(cust.s_cust_id);

			vFolderDeletes.add("<td>" + folder.s_folder_name + "</td><td>Folder</td><td>Deleted</td><td>--</td>");

		}
	}

	String[] sImages = BriteRequest.getParameterValues(request,"images");
	if (sImages != null) {
		for (int i=0; i < sImages.length;i++) {
			sImageId = sImages[i];

			if (sImageId == null){
				String sError = "<td>&nbsp;</td><td>Image</td><td><font color=red>Error</font></td><td>Missing image ID";
				vImageDeletes.add(sError);
				continue;
			}
			Image img = new Image(sImageId);
			img.hide(cust.s_cust_id);

			vImageDeletes.add("<td>" + img.s_image_name + "</td><td>Image</td><td>Deleted</td><td>--</td>");
		}
	}

%>
<HTML>

<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Delete:</b> &nbsp;</td>
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
						<table cellspacing="0" cellpadding="3" border="0" class="listTable layout" style="width:100%;">
							<col width="40%">
							<col width="50">
							<col width="75">
							<col width="60%">
							<tr>
								<th>File Name</th>
								<th>Type</th>
								<th>Status</th>
								<th>Message</th>
							</tr>
							<%
							int itemCount = 0;
							
							if (vFolderDeletes != null && vFolderDeletes.size() > 0)
							{
								Iterator itFolderDeletes = vFolderDeletes.iterator();
								String sTmp = null;
								
								while (itFolderDeletes.hasNext())
								{
									sTmp = (String)itFolderDeletes.next();
									%>
									<tr>
										<%=sTmp%>
									</tr>
									<%
									itemCount++;
								}
							}
							%>
							
							<%
							if (vImageDeletes != null && vImageDeletes.size() > 0)
							{
								Iterator itImageDeletes = vImageDeletes.iterator();
								String sTmp = null;
								
								while (itImageDeletes.hasNext())
								{
									sTmp = (String)itImageDeletes.next();
									%>
									<tr>
										<%=sTmp%>
									</tr>
									<%
									itemCount++;
								}
							}
							
							if (itemCount == 0)
							{
								%>
								<tr>
									<td colspan="4">No images or folders were deleted.</td>
								</tr>
								<%
							}
							%>
						</table>
						<br><br>
						<a href="folder_details.jsp?folder_id=<%= sParentFolderId %>">Back to Folder Details</a>
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
	ErrLog.put(this,ex,"images_delete.jsp",out,1);
	return;
} finally {
	if (conn != null) cp.free(conn);
}
%>
