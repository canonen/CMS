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
boolean bCanWrite = can.bExecute;


String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;
     
String sErrors = BriteRequest.getParameter(request,"errors");


try	{

%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">

<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT src="../../js/scripts.js"></SCRIPT>
<style type="text/css">
	
	TABLE.layout TD
	{
		padding: 0px;
	}
	
</style>
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
</HEAD>

<BODY>
<div class="page_header"><fmt:message key="header_img_lib"/></div>
<div class="page_desc"><fmt:message key="header_imb_lib_desc"/></div>


<% if (sErrors != null) {
%>
     <font color="red">
          <%=sErrors%>
     </font>
<%   }    %>

<table cellpadding="3" cellspacing="0" border="0" width="95%">
	<tr>
		<% if (bCanWrite) { %>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="image_new.jsp?<%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>"><fmt:message key="button_img_lib"/></a>&nbsp;&nbsp;&nbsp;
		</td>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="folder_new.jsp"><fmt:message key="button_img_folder"/></a>&nbsp;&nbsp;&nbsp;
		</td>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="image_zip_upload.jsp"><fmt:message key="button_img_upload_zip"/></a>&nbsp;&nbsp;&nbsp;
		</td>
		<% } 
		if (ui.n_ui_type_id != UIType.HYATT_USER) { %>
		<td valign="middle" align="left" nowrap>
			&nbsp;&nbsp;&nbsp;<a class="resourcebutton" href="javascript:PreviewURL('folder_details_url.jsp');"><fmt:message key="button_img_url_gen"/></a>&nbsp;&nbsp;&nbsp;
		</td>
		<% } %>
		<td nowrap valign="middle" align="right" width="100%">
			<table class="filterList" cellspacing="1" cellpadding="0" border="0" style="display:none;">
				<tr>
					<td align="right" valign="middle" nowrap><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
					<td align="right" valign="middle" nowrap>&nbsp;Category: <span id="cat_1"></span>&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<div id="filterBox" style="display:none;">
	<FORM  METHOD="GET" NAME="FT" ACTION="image_list.jsp" style="display:inline;">
	<table class="listTable" cellspacing="0" cellpadding="2" border="0">
		<tr>
			<th valign="middle" align="left" colspan="2">Filter the Images</th>
			<th valign="top" align="right" style="cursor:hand;" onclick="filterReveal(30);">&nbsp;<b>X</b>&nbsp;</th>
		</tr>
		<tr<%= !canCat.bRead?" style=\"display:none\"":"" %>>
			<td valign="middle" align="right">Category:&nbsp;</td>
			<td valign="middle" align="left"><%= CategortiesControl.toHtml(cust.s_cust_id, canCat.bExecute, sSelectedCategoryId, "") %></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td valign="middle" align="center" colspan="2"><a class="subactionbutton" href="#" onClick="filterReveal(30);GO(0);" TARGET="_self">Filter</a></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
	</table>
	</FORM>
</div>
<br>

<%
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

     
//     ImgFolder rootFolder = new ImgFolder(sRootFolderId);
//     ImgFolder globalFolder = new ImgFolder(sGlobalFolderId);

	String sFolderHTML = "";
		sFolderHTML += "<table cellspacing=0 cellpadding=2 border=0 style=\"width: 95%;\" id=\"folderTable\" class=\"listTable layout\">\n";
			sFolderHTML += "<col width=20>\n";
			sFolderHTML += "<col width=22>\n";
			sFolderHTML += "<col>\n";
			sFolderHTML += "<col width=70>\n";
			sFolderHTML += "<col width=70>\n";
			sFolderHTML += "<col width=110>\n";
			sFolderHTML += "<col width=60>\n";
			sFolderHTML += "<col width=55>\n";
			sFolderHTML += "<tr height=22>\n";
				sFolderHTML += "<th colspan=3>&nbsp;</th>\n";
				sFolderHTML += "<th>Contents</th>\n";
				sFolderHTML += "<th>Bytes</th>\n";
				sFolderHTML += "<th>Date Modified</th>\n";
				sFolderHTML += "<th colspan=2>&nbsp;</th>\n";
			sFolderHTML += "</tr>\n";
			sFolderHTML += ImageHostUtil.getImageListHTML(sGlobalFolderId, 0, cust.s_cust_id, user);
			sFolderHTML += ImageHostUtil.getImageListHTML(sRootFolderId, 0, cust.s_cust_id, user);
			sFolderHTML += "</table>\n";

%>


<%= sFolderHTML %>

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

</body>
</fmt:bundle>
</HTML>
<%
} catch(Exception ex) { 

	logger.error("Problem producing Image list",ex);

}
%>
