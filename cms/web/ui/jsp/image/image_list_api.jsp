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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
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
boolean bCanWrite = can.bExecute;
JsonObject data= new JsonObject();
JsonArray array= new JsonArray();


String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;
     
String sErrors = BriteRequest.getParameter(request,"errors");


try	{

<script language="javascript">
	
	function toggleFolder(folderID, inLoop)
	{
		var folderRow = document.getElementById("folder_" + folderID);
		
		if (folderRow != window.undefined)
		{
			if (folderRow.style.display == "")
			{
				folderRow.style.display = "none";
			}
			else
			{
				folderRow.style.display = "";
			}
		}
	}
	
	function PreviewURL(freshurl)
	{
		var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,width=650,height=500';
		SmallWin = window.open(freshurl,'ImageLibrary',window_features);
	}
	
</script>

     // get the ID for the Root Folder.  If this customer has no root folder, create it.
     String sRootFolderId = null;
     sRootFolderId = ImageHostUtil.getRoot(cust.s_cust_id);
     if ((sRootFolderId == null) && (can.bWrite)) {
          sRootFolderId = ImageHostUtil.createRoot(cust.s_cust_id, user.s_user_id);
     }

     String sGlobalFolderId = null;
     sGlobalFolderId = ImageHostUtil.getGlobalRoot(cust.s_cust_id);
     if (sGlobalFolderId == null) {
          sGlobalFolderId = ImageHostUtil.createGlobalRoot(cust.s_cust_id, user.s_user_id);
     }

     
     ImgFolder rootFolder = new ImgFolder(sRootFolderId);
     ImgFolder globalFolder = new ImgFolder(sGlobalFolderId);

	data.put("global_id",ImageHostUtil.getImageListHTML(sGlobalFolderId, 0, cust.s_cust_id, user));
	data.put("folder_id",ImageHostUtil.getImageListHTML(sRootFolderId, 0, cust.s_cust_id, user));
	array.put(data);
	out.print(array);
			

<SCRIPT LANGUAGE="JavaScript">

var catName = FT.category_id[FT.category_id.selectedIndex].text;

cat_1.innerHTML = catName;

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
</SCRIPT>



} catch(Exception ex) { 

	logger.error("Problem producing Image list",ex);

}


%>

