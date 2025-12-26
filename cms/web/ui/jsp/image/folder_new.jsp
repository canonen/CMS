<%@ page
	language="java"
	import="com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.net.*,
			org.apache.log4j.*"
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

/*  permission checks */
AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

String sParentId = BriteRequest.getParameter(request,"parent_id");
if (sParentId == null)
     sParentId = "";
String sFolderId = BriteRequest.getParameter(request,"folder_id");
int nFolderId = Integer.parseInt((sFolderId == null)?"0":sFolderId);
String sFolderName = BriteRequest.getParameter(request,"folder_name");
if (sFolderName == null)
     sFolderName = "";
String sErrors = BriteRequest.getParameter(request,"errors");
String sClone = BriteRequest.getParameter(request,"clone");
if (sClone == null)
     sClone = "";
String sPrevFolderName = "";
String sPrevFolderId = "";
if (sClone != null && sClone.equals("1")) {
     if (sFolderId != null) {
          ImgFolder prevFolder = new ImgFolder(sFolderId);
          sPrevFolderName = prevFolder.s_folder_name;
          sPrevFolderId = prevFolder.s_folder_id;
          sParentId = prevFolder.s_parent_id;
     }
}

String selFolderID = "";

if (sClone != null && sClone.equals("1")) {
	selFolderID = "";
} else {
	selFolderID = sFolderId;
}


boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);
/* *** */

//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);
/* *** */

// Connection
Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool	connectionPool= null;
Connection			srvConnection = null;
/* *** */


try	{
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("folder_new.jsp");
	stmt = srvConnection.createStatement();

	/* Categories */
	String sSql  =
			" SELECT c.category_id, c.category_name" +
			" FROM ccps_category c" +
			" WHERE c.cust_id="+cust.s_cust_id;
	rs = stmt.executeQuery(sSql);

	String sCategoryId = null;
	String sCategoryName = null;
	String htmlCategories = "";

	while (rs.next()) {
		sCategoryId = rs.getString(1);
		sCategoryName = new String(rs.getBytes(2), "UTF-8");
		htmlCategories += "<OPTION value=\""+sCategoryId+"\""+(((sSelectedCategoryId!=null)&&(sSelectedCategoryId.equals(sCategoryId)))?" SELECTED":"")+">" +
				sCategoryName+ "</OPTION>";
	}
     rs.close();
     /* *** */

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
	
	function goToFolder()
	{
		var obj = document.getElementById("parent_id");
		var sFolderID = obj[obj.selectedIndex].value;
		
		if (sFolderID != "0")
		{
			location.href = "folder_details.jsp?folder_id=" + sFolderID;
		}
	}
	
</script>
</HEAD>
<BODY>
<% if (sErrors != null) {
%>
     <font color="red">
          <%=sErrors%>
     </font>
<%   }    %>
<FORM  METHOD="POST" NAME="FT" ACTION="folder_save.jsp" TARGET="_self">
<INPUT TYPE="hidden" NAME="categorytemp" VALUE="">
<INPUT type="hidden" name="clone" value="<%=sClone%>">
<INPUT type="hidden" name="prevParentId" value="<%=sParentId%>">
<INPUT type="hidden" name="prevFolderId" value="<%=sPrevFolderId%>">
<INPUT type="hidden" name="prevFolderName" value="<%=sPrevFolderName%>">
<INPUT type="hidden" name="access_map" value="<%=cust.s_cust_id%>">

<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
<%
if(can.bWrite)
{
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="try_submit();">
                    Save<% if (sClone != null && sClone.length()>0) { %> Clone <% } %>
                    </a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>
<!--- Step 1 Header----->
<table width="650" class="listTable" cellspacing="0" cellpadding="0">
	<tr>
		<th class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Name your Folder</th>
	</tr>

	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="" valign="top" align="center" width="650">
			<table class="" cellspacing="1" cellpadding="2" width="100%">
				<!--<tr<%=!canCat.bRead?" style=\"display:'none'\"":""%>>
					<td align="left" valign="middle" width="100">Categories: </td>
					<td align="left" valign="middle">
						<select multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="5" width="100">
							<%= htmlCategories %>
						</select>
						<%=(!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0")))
						?"<input type=hidden name=\"categories\" value=\""+sSelectedCategoryId+"\">"
						:""%>
					</td>
				</tr>//-->
				<tr>
					<td align="left" valign="middle" width="100">Choose Parent Folder: </td>
					<td align="left" valign="middle">
						<select NAME="parent_id" SIZE="1" onChange="showAccess();" <%=(!bCanWrite)?"disabled":""%>>
							<option selected value="0">&lt; --- --- --- Choose folder --- --- --- &gt;</option>
							<%
                                        String sGlobalFolderId = ImageHostUtil.getGlobalRoot(cust.s_cust_id);
                                        String sFolderHTML = ImageHostUtil.getFolderOptionsHTML(sGlobalFolderId,0,selFolderID,cust.s_cust_id);
                                        String sRootFolderId = ImageHostUtil.getRoot(cust.s_cust_id);
                                        sFolderHTML += ImageHostUtil.getFolderOptionsHTML(sRootFolderId,0,selFolderID,cust.s_cust_id);
							%>
							<%= sFolderHTML %>
						</select>
						&nbsp;&nbsp;
						<a href="#" class="resourcebutton" onclick="goToFolder();">Go To Selected Folder</a>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="100">Folder Name: </td>
					<td align="left" valign="middle">
						<input type="text" size="40" value="<%=sFolderName%>" name=folder_name maxlength="40" <%=(!bCanWrite)?"disabled":""%>>
					</td>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<div id="accessStep" style="display:none;">
<%
	int nChildCount = -1;
	rs = stmt.executeQuery("EXEC usp_ccps_cust_tree_get @cust_id = " + cust.s_cust_id);
	while (rs.next()) {
		//only interested in last customer on chain
		nChildCount++;
	}
	rs.close();

	if (nChildCount > 0) {
%>
<!--- Step 2 Header----->
<table width="650" class="listTable" cellspacing="0" cellpadding="0">
	<tr>
		<th class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Set Access Rights</th>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class="" valign="top" align="center" width="650">
			<table class="listTable" cellspacing="0" cellpadding="2" border="0" width="100%">
			<%= ImageHostUtil.getFolderCustAccessHTML(cust.s_cust_id, sFolderId) %>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<%
	}
%>
</div>

<SCRIPT LANGUAGE="JavaScript">

function try_submit () {
<%
	if (nChildCount > 0) {
%>
	FT.access_map.value = "<%=cust.s_cust_id%>";

	if (FT.parent_id[FT.parent_id.selectedIndex].type_id == <%=ImageFolderType.GLOBAL%>) {

		var cust_obj = FT.cust_access;
		for (var i=0; i < cust_obj.length; i++) {
			if (cust_obj[i].checked == true) FT.access_map.value += (";"+cust_obj[i].value);
		}
	}
<%
	}
%>
	if (FT.clone.value == "1") {
		if (FT.prevParentId.value == FT.parent_id.value && FT.prevFolderName.value == FT.folder_name.value) {
			alert('Cannot clone a folder to itself.  Either change the parent folder or the folder name.');
			return;
		}
	}

	if(FT.parent_id.value == "0") {
		alert('You must choose a parent folder.');
		return;
	}

	if(FT.folder_name.value == "") {
		alert('You must enter a folder name.');
		return;
	}
     
	FT.submit();
}

function showAccess()
{
	if (FT.parent_id[FT.parent_id.selectedIndex].type_id == <%=ImageFolderType.GLOBAL%>) 
		document.all.item("accessStep").style.display = "";
	else
		document.all.item("accessStep").style.display = "none";
}

showAccess();

function checkGlobal(i) {
	var cust_obj = FT.cust_access;
	if (i == 0) {
		if (cust_obj[0].checked == true) {
			for (var j=0; j < cust_obj.length; j++) {
				cust_obj[j].checked = true;
			}
		} else {
			for (var j=0; j < cust_obj.length; j++) {
				cust_obj[j].checked = false;
			}
		}
	} else {
		if (cust_obj[i].checked == false) { 
			cust_obj[0].checked = false;
		}
	}
}
</SCRIPT>

</BODY>
</HTML>
<%
} catch(Exception ex) { 

	throw ex;

} finally {
	if ( stmt != null ) stmt.close();
	if ( srvConnection  != null ) connectionPool.free(srvConnection); 
}
%>


























