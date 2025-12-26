<%@ page
	language="java"
	import="com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.*,
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

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

String sFolderId = BriteRequest.getParameter(request,"folder_id");
String sImageId = BriteRequest.getParameter(request,"image_id");
String sErrors = BriteRequest.getParameter(request,"errors");

boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);

//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

// Connection
Image image = null;
ImgFolder folder = null;

String tabWidth = "650";
if (sImageId!=null&&sImageId.length()!=0) tabWidth = "100%";



try	{

	if (sImageId != null && sImageId.length() != 0)
	{
		//Load image info
		image = new Image(sImageId);
		if (sFolderId == null)
			sFolderId = image.s_folder_id;
		
		folder = new ImgFolder(sFolderId);
	}
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
	
	function goToFolder()
	{
		var obj = document.getElementById("folder_id");
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

<FORM  METHOD="POST" NAME="FT" ENCTYPE="multipart/form-data" ACTION="image_save.jsp" TARGET="_self">

<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>

<%=(sImageId!=null&&sImageId.length()!=0)?"<INPUT type=\"hidden\" name=\"image_id\" value=\""+sImageId+"\">":""%>

<%
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

	if(can.bWrite)
	{
%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
<%
		if ( (sImageId != null) 
			&& (sImageId.length() != 0) 
			&& (nChildCount > 0)
			&& (folder.s_type_id.equals(String.valueOf(ImageFolderType.GLOBAL)))) {
%>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="javascript:submitImages(0);">Save</a>
			</td>
<%
		}
%>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="javascript:submitImages(1);">Save &amp; Upload</a>
			</td>
		</tr>
	</table>
	<br>
<%
	}
%>
<INPUT TYPE="hidden" NAME="num_files" value="0">
<INPUT type="hidden" name="access_map" value="<%=cust.s_cust_id%>">

<% if (sImageId!=null&&sImageId.length()!=0) { %>
<table cellspacing="0" cellpadding="0" border="0" width="95%">
	<tr>
		<td align="left" valign="top" width="50%">
<% } %>

<!--- Step 1 Header----->
<table width="<%= tabWidth %>" class="listTable" cellspacing="0" cellpadding="0">
	<tr>
		<th class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Choose a Folder</th>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="" valign="top" align="center" width="100%">
			<table class="" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100">Choose a Folder: </td>
					<td align="left" valign="middle">
						<select name="folder_id" size="1" onChange="showAccess();" <%=(!bCanWrite)?"disabled":""%>>
							<option selected value="0">&lt; --- --- --- Choose folder --- --- --- &gt;</option>
							<%
                                String sGlobalFolderId = ImageHostUtil.getGlobalRoot(cust.s_cust_id);
                                String sFolderHTML = ImageHostUtil.getFolderOptionsHTML(sGlobalFolderId,0,sFolderId,cust.s_cust_id);
                                String sRootFolderId = ImageHostUtil.getRoot(cust.s_cust_id);
                                sFolderHTML += ImageHostUtil.getFolderOptionsHTML(sRootFolderId,0,sFolderId,cust.s_cust_id);
							%>
							<%= sFolderHTML %>
						</select>
						<br><br>
						<a href="#" class="resourcebutton" onclick="goToFolder();">Go To Selected Folder</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br>

<!--- Step 2 Header----->
<table width="<%= tabWidth %>" class="listTable" cellspacing="0" cellpadding="0">
	<tr>
		<th class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Upload your Image</th>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class="" valign="top" align="center" width="100%">
			<table class="" cellspacing="1" cellpadding="2" width="100%" id="fileTable">
				<tr>
					<td align="left" valign="middle" width="100">Select Image: </td>
					<td align="left" valign="middle">
						<input onchange="display_thumbnail()" type="file" name="image_file" size="20" style="width:100%;" <%=(!bCanWrite)?"disabled":""%>>
					</td>
                    <td width="75" align="right" valign="middle"<%=(sImageId!=null&&sImageId.length()!=0)?" style=\"display:none;\"":""%>>
						<a href="javascript:addFileInput();" class="subactionbutton">More Files</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<div id="accessStep" style="display:none;">
<%
	if (nChildCount > 0) {
%>
<!--- Step 3 Header----->
<table width="<%= tabWidth %>" class="listTable" cellspacing="0" cellpadding="0">
	<tr>
		<th class="sectionheader">&nbsp;<b class="sectionheader">Step 3:</b> Set Access Rights</th>
	</tr>
	<tbody class="EditBlock" id="block3_Step1">
	<tr>
		<td class="" valign="top" align="center" width="100%">
			<table class="listTable" cellspacing="0" cellpadding="2" border="0" width="100%">
<%
		String sAccessHtml = "";
		if (sImageId!=null&&sImageId.length()!=0) { 
			sAccessHtml = ImageHostUtil.getImageCustAccessHTML(cust.s_cust_id, sImageId);
		} else {
			sAccessHtml = ImageHostUtil.getFolderCustAccessHTML(cust.s_cust_id, sFolderId);
		}
%>
			<%= sAccessHtml %>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<%
	}
} catch(Exception ex) { 

	throw ex;

} finally {
	if ( stmt != null ) stmt.close();
	if ( conn  != null ) cp.free(conn); 
}
%>
</div>


<% if (sImageId!=null&&sImageId.length()!=0) { %>
		</td>
		<td>&nbsp;&nbsp;&nbsp;</td>
		<td align="left" valign="top" width="50%">
			<!--- Info Header----->
			<table width="100%" class="main" cellspacing="0" cellpadding="0">
				<tr>
					<td class="sectionheader">&nbsp;<b class="sectionheader">Information:</b> Preview &amp; URL</td>
				</tr>
			</table>
			<br>
			<!---- Info----->
			<table id="Tabs_Table0" cellspacing="0" cellpadding="0" width="100%" border="0">
				<tr>
					<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr>
					<td class="fillTabbuffer" valign="top" align="left" width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class="EditBlock" id="block0_Step1">
				<tr>
					<td class="fillTab" valign="top" align="center" width="100%">
						<table class="main" cellspacing="1" cellpadding="2" width="100%">
							<tr>
								<td align="left" valign="middle" width="100">Image URL: </td>
								<td align="left" valign="middle">
									<input type="text" size="40" value="<%=HtmlUtil.escape(ImageHostUtil.getMirrorPath(image.s_cust_id, image.s_url_path))%>" name="image_url">
								</td>
							</tr>
							<tr>
								<td align="left" valign="middle" width="100">Preview: </td>
								<td align="left" valign="middle">
									<img src="<%=HtmlUtil.escape(image.s_url_path) %>" border="0">
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
			<br><br>
		</td>
	</tr>
</table>
<% } %>

<div style="display:none;" id="hiddenInputs">
</div>


<SCRIPT LANGUAGE="JavaScript">

function try_submit () {
<%
	if (nChildCount > 0) {
%>
	FT.access_map.value = "<%=cust.s_cust_id%>";

	if (FT.folder_id[FT.folder_id.selectedIndex].type_id == <%=ImageFolderType.GLOBAL%>) {

		var cust_obj = FT.cust_access;
		for (var i=0; i < cust_obj.length; i++) {
			if (cust_obj[i].checked == true) FT.access_map.value += (";"+cust_obj[i].value);
		}
	}
<%
	}
%>

	if(FT.folder_id.value == "0") {
		alert('You must choose a parent folder.');
		return;
	}
     
	FT.submit();
}

	function submitImages(act)
	{
<%
	if (nChildCount > 0) {
%>
		FT.access_map.value = "<%=cust.s_cust_id%>";

		if (FT.folder_id[FT.folder_id.selectedIndex].type_id == <%=ImageFolderType.GLOBAL%>) {

			var cust_obj = FT.cust_access;
			for (var i=0; i < cust_obj.length; i++) {
				if (cust_obj[i].checked == true) FT.access_map.value += (";"+cust_obj[i].value);
			}
		}
<%
	}
%>
		if (act == 0) {
			location.href = "image_access_save.jsp?image_id="+FT.image_id.value+"&access_map="+FT.access_map.value;
		} else {
			var tTable = document.getElementById("fileTable");
	          var fFolder = "";
	          var fpFile = "";
			var y = 1;

	          fFolder = FT.folder_id.value;
			if (fFolder == "0")
			{
				alert("You must choose a folder into which the file(s) will be uploaded.");
				return;
			}

			fpFile = tTable.rows[0].cells[1].children[0].value;
			if (fpFile == "")
			{
				alert("You must choose a file to upload.");
				return;
			}
			

			for (i=0; i<tTable.rows.length; i++)
			{
				tTable.rows[i].cells[1].children[0].name = "image_file" + i;
	               if (tTable.rows[i].cells[1].children[0].value == "") {
	                    alert("You must select a file for every open file input.  Either choose a file, or remove the file input by clicking the 'X'");
	                    return;
	               }
				y++
			}
			
			FT.num_files.value = (y - 1);
			FT.submit();
		}
	}


function display_thumbnail () {
     if (FT.image_file.value != null) {
          //show it somehow
     }
}

	function addFileInput()
	{
		var tTable = document.getElementById("fileTable");
		var oRow, oCell;
		
		oRow = tTable.insertRow();
		oCell = oRow.insertCell();
		oCell.width = "100";
		oCell.innerHTML = "Select Image:";
		
		oCell = oRow.insertCell();
		oCell.align = "left";
		oCell.vAlign = "middle";
		oCell.innerHTML = "<input type=\"file\" name=\"image_file\" tabindex=\"" + (oRow.rowIndex + 1) + "\" size=\"20\" value=\"\" style=\"width:100%;\" >";
		
		oCell = oRow.insertCell();
		oCell.align = "right";
		oCell.vAlign = "middle";
		oCell.width = "75";
		oCell.innerHTML = "<a href=\"#\" onclick=\"removeFileInput();\" class=\"subactionbutton\">X</a>"
	}
	
	function removeFileInput()
	{
		var srcElem = window.event.srcElement;
		var trElem = srcElem;
		var tTable = document.getElementById("fileTable");
		
		while (trElem.tagName != "TR")
		{
			trElem = trElem.parentElement;
		}
		
		tTable.deleteRow(trElem.rowIndex);
		
	}

function showAccess()
{
	if (FT.folder_id[FT.folder_id.selectedIndex].type_id == <%=ImageFolderType.GLOBAL%>) 
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

	ErrLog.put(this,ex, "Exception thrown while attempting to upload image.",out,1);

}
%>


























