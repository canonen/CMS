<%@ page
	language="java"
	import="javax.servlet.http.*,
			javax.servlet.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
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

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
 
boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);


String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;
     
String sErrors = BriteRequest.getParameter(request,"errors");
String sFolderId = BriteRequest.getParameter(request,"folder_id");


try	{

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT src="../../js/scripts.js"></SCRIPT>
<script language="javascript">
	
	function on(o)
	{
		o.runtimeStyle.backgroundColor = "#FFFFEE";
		o.runtimeStyle.borderColor = "#FFBB77";
	}

	function off(o)
	{
		o.runtimeStyle.backgroundColor = "";
		o.runtimeStyle.borderColor = "";
	}
	
	function takeAction(itemType, itemID)
	{
		if (itemID != "null")
		{
			var sElem = window.event.srcElement;
		
			if (sElem.tagName != "INPUT")
			{
				if (itemType == "folder" && itemID != "0")
				{
					location.href = "folder_details.jsp?folder_id=" + itemID;
				}
				
				if (itemType == "edit")
				{
					location.href = "image_new.jsp?image_id=" + itemID;
				}
			}
		}
	}
	
	function PreviewURL(freshurl)
	{
		var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,width=650,height=500';
		SmallWin = window.open(freshurl,'ImageLibrary',window_features);
	}
	
</script>
<style type="text/css">
	
	SELECT
	{
		width:100%;
	}
	
</style>
</HEAD>
<BODY topmargin="0" leftmargin="0" style="padding:0px;">
<%
if (sErrors != null)
{
	%>
	<font color="red">
	<%= sErrors %>
	</font>
	<%
}
if (sFolderId == null)
{
	throw new Exception("Cannot display folder details.  Folder ID not found.");
}
ImgFolder folder = new ImgFolder(sFolderId);
String sPath = folder.getPrettyPath();
%>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col width="155">
	<col>
	<tr height="25">
		<td align="left" valign="top" style="padding:0px;" colspan="2">
			<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%; height:100%;">
				<col width="70">
				<col>
				<col width="20">
				<col width="150">
				<tr>
					<td class="NonMenuBar" align="right" valign="middle">
						<b>Location:</b>
					</td>
					<td class="NonMenuBar" align="left" valign="middle">
						<select name="quick_folder_id" onchange="takeAction('folder', this.value);" size="1">
							<option selected value="0">&lt; --- --- --- Choose folder --- --- --- &gt;</option>
							<%
                                String sGlobalFolderId = ImageHostUtil.getGlobalRoot(cust.s_cust_id);
                                String sFolderHTML = ImageHostUtil.getFolderOptionsHTML(sGlobalFolderId,0,sFolderId,cust.s_cust_id);
                                String sRootFolderId = ImageHostUtil.getRoot(cust.s_cust_id);
                                sFolderHTML += ImageHostUtil.getFolderOptionsHTML(sRootFolderId,0,sFolderId,cust.s_cust_id);
							%>
							<%= sFolderHTML %>
						</select>
					</td>
					<td class="NonMenuBar" align="left" valign="middle">
						<img src="../../images/images_folder_up.gif" style="cursor:hand;" border="0" title="Up" onclick="takeAction('folder', '<%= folder.s_parent_id %>');">
					</td>
					<td class="NonMenuBar" align="right" valign="middle">
						<a href="image_list.jsp" class="subactionbutton"><< Back to Library</a>&nbsp;
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="25">
		<td align="left" valign="top" style="padding:0px;" colspan="2">
			<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%; height:100%;">
				<col width="70">
				<col>
				<tr>
					<td class="NonMenuBar">&nbsp;</td>
					<td class="NonMenuBar" align="left" valign="middle" nowrap>
						<%= sPath %>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="left" valign="top" class="NonSideBar">
			<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%; height:100%;">
				<tr height="15">
					<td><b>In This Folder:</b></td>
				</tr>
				<tr height="15">
					<td><hr size="1" width="100%" color="#000000"></td>
				</tr>
				<% if (bCanWrite) { %>
				<tr height="25">
					<td><a class="newbutton" href="folder_new.jsp?folder_id=<%= sFolderId %>">New Folder</a>&nbsp;&nbsp;</td>
				</tr>
				<tr height="25">
					<td><a class="newbutton" href="image_new.jsp?folder_id=<%= sFolderId %><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">New Image</a>&nbsp;&nbsp;</td>
				</tr>
				<tr height="25">
					<td><a class="newbutton" href="image_zip_upload.jsp?folder_id=<%= sFolderId %>">Upload Zip File</a>&nbsp;&nbsp;</td>
				</tr>
				<tr height="15">
					<td><hr size="1" width="100%" color="#000000"></td>
				</tr>
				<tr height="25">
					<td nowrap><a class="subactionbutton" href="folder_new.jsp?folder_id=<%= sFolderId %>&clone=1">Clone Folder</a>&nbsp;&nbsp;</td>
				</tr>
<%
//Only show Set Access if folder is global type, is not root global, and cust has children

// Connection
Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool		cp = null;
Connection			conn = null;
/* *** */


int nChildCount = -1;
try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("image_new.jsp");
	stmt = conn.createStatement();

	rs = stmt.executeQuery("EXEC usp_ccps_cust_tree_get @cust_id = " + cust.s_cust_id);
	while (rs.next()) {
		//only interested in last customer on chain
		nChildCount++;
	}
	rs.close();

	if ((nChildCount > 0) 
		&& (folder.s_type_id.equals(String.valueOf(ImageFolderType.GLOBAL))) 
		&& (folder.s_parent_id != null)){
%>
				<tr height="25">
					<td nowrap><a class="subactionbutton" href="folder_access.jsp?folder_id=<%= sFolderId %>">Set Folder Access</a>&nbsp;&nbsp;</td>
				</tr>
<%
	}
} catch(Exception ex) { 

	throw ex;

} finally {
	if ( stmt != null ) stmt.close();
	if ( conn  != null ) cp.free(conn); 
}
%>
				<tr height="15">
					<td><hr size="1" width="100%" color="#000000"></td>
				</tr>
				<% } 
				if (can.bDelete) { %>
				<tr height="25">
					<td><a class="deletebutton" href="#"onclick="if (confirm('Are you sure you want to delete all Selected items?'))delete_items()">Delete Checked Items</a>&nbsp;&nbsp;</td>
				</tr>
				<% } 
				if (ui.n_ui_type_id != UIType.HYATT_USER) { %>
				<tr height="15">
					<td><hr size="1" width="100%" color="#000000"></td>
				</tr>
				<tr height="25">
					<td nowrap><a class="resourcebutton" href="javascript:PreviewURL('folder_details_url.jsp?folder_id=<%= sFolderId %>');">URL Generator</a>&nbsp;&nbsp;</td>
				</tr>
				<% } %>
				<tr>
					<td>&nbsp;</td>
				</tr>
			</table>
		</td>
		<td align="left" valign="top">
			<div style="overflow:auto; height:100%; width:100%; padding:10px;">
				<FORM METHOD="POST" NAME="FT" ACTION="images_delete.jsp" TARGET="_self">
				<input type="hidden" name="parent_folder_id" value="<%=sFolderId%>">
					<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%;">
						<col width="20%">
						<col width="5%">
						<col width="20%">
						<col width="5%">
						<col width="20%">
						<col width="5%">
						<col width="20%">
						<col width="5%">
						<tr height="80">
					<%
					int iCount = -1;
					int iItems = 0;
					boolean bHasContents = false;

					//get and display subfolders
					folder.getSubFolders(cust.s_cust_id);
					
					if (folder.m_SubFolders != null && folder.m_SubFolders.size() > 0 )
					{
						bHasContents = true;
						Iterator itSubFolders = folder.m_SubFolders.iterator();
						
						while (itSubFolders.hasNext())
						{
							ImgFolder subFolder = (ImgFolder) itSubFolders.next();
							iCount++;
							iItems++;
							
							if (iCount >=4)
							{
								iCount = 0;
								%>
								</tr>
								<tr height="80">
								<%
							}
							%>
							<td align="center" valign="middle" class="image_item" title="<%= subFolder.s_folder_name %>" onmouseover="on(this);" onmouseout="off(this);" onclick="takeAction('folder', '<%= subFolder.s_folder_id %>');">
								<img src="../../images/images_folder_large.gif" border="0"><br>
								<nobr><%= subFolder.s_folder_name.replaceAll(" ", "") %><nobr/><br>
								<input type="checkbox" name="folders" value="<%=subFolder.s_folder_id%>">
							</td>
							<td align="center" valign="middle">&nbsp;</td>
							<%
						}
					}
					
					//get and display images
					folder.getImages(cust.s_cust_id);
					iItems = 0;
					
					if (folder.m_Images != null && folder.m_Images.size() > 0 )
					{
						bHasContents = true;
						Iterator itImages = folder.m_Images.iterator();
						
						while (itImages.hasNext())
						{
							Image image = (Image) itImages.next();
							iCount++;
							iItems++;
							
							if (iCount >=4)
							{
								iCount = 0;
								%>
								</tr>
								<tr height="80">
								<%
							}
							%>
							<td align="center" valign="middle" class="image_item" title="<%= image.s_image_name %>" onmouseover="on(this);" onmouseout="off(this);" onclick="takeAction('edit', '<%= image.s_image_id %>');">
								<img src="<%= image.s_url_path %>" border="0" class="menuImg"><br>
								<nobr><%= image.s_image_name.replaceAll(" ", "") %></nobr><br>
								<input type="checkbox" name="images" value="<%= image.s_image_id %>">
							</td>
							<td align="center" valign="middle">&nbsp;</td>
							<%
						}
					}
					
					if (bHasContents)
					{
						for (int x=iCount+1;x<4;++x)
						{
							%>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
							<%
						}
					}
					else
					{
						%>
						<td>No Contents</td>
						<td>&nbsp;</td>
						<%
					}
					%>
						</tr>
					</table>
				</form>
			</div>
		</td>
	</tr>
</table>


<SCRIPT LANGUAGE="JavaScript">

function GO(parm)
{	
	FT.submit();
}

function image_popup(url)
{
	windowName = '';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=400, width=400';
       	SmallWin = window.open(url, windowName, windowFeatures);
}

function delete_items()
{
     /* make sure there's at least 1 checkbox checked.  If so, submit is OK.
        get count of all folder checkboxes and count of all image checkboxes and send that. */
     FT.submit();
}
</SCRIPT>

</BODY>
</HTML>
<%
} catch(Exception ex) { 

	ErrLog.put(this, ex, "Problem producing Image list", out, 1);

}
%>
