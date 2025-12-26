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

String sErrors = BriteRequest.getParameter(request,"errors");
String sFolderId = BriteRequest.getParameter(request,"folder_id");

boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);

//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

// Connection
Image image = null;



//try	{

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
<FORM  METHOD="POST" NAME="FT" ENCTYPE="multipart/form-data" ACTION="image_save.jsp" TARGET="_self">
<INPUT type="hidden" name="access_map" value="<%=cust.s_cust_id%>">

<%
if(can.bWrite)
{
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="try_submit();">Upload ZIP file</a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>
<!--- Step 1 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Choose a Folder</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
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
						&nbsp;&nbsp;
						<a href="#" class="resourcebutton" onclick="goToFolder();">Go To Selected Folder</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 2 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Upload your ZIP file</td>
	</tr>
</table>
<br>
<!---- Step 2 Info----->
<table id="Tabs_Table2" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
                         <td align="left" valign="left" colspan="2">
                              <input type="checkbox" name="overwrite" checked="1"> Overwrite existing images.
                         </td>
                    </tr>
                    <tr>
					<td align="left" valign="middle" width="150">
                              Select your ZIP file: 
                         </td>
					<td align="left" valign="middle">
						<input type="file" name="zip_file" size="30" <%=(!bCanWrite)?"disabled":""%>>
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

	if (nChildCount > 0) {
%>
<!--- Step 3 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 3:</b> Set Access Rights</td>
	</tr>
</table>
<br>
<!---- Step 3 Info----->
<table id="Tabs_Table3" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block3_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650">
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
} catch(Exception ex) { 

	throw ex;

} finally {
	if ( stmt != null ) stmt.close();
	if ( conn  != null ) cp.free(conn); 
}
%>
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
     
     if(FT.zip_file.value == "") {
          alert('You must choose a ZIP file to upload.');
          return;
     }
     
	FT.submit();


	FT.submit();
}

function display_thumbnail () {
     if (FT.image_file.value != null) {
          //show it somehow
     }
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
//} catch(Exception ex) { 

//	ErrLog.put(this,ex, "Exception thrown while attempting to upload image.",out,1);

//}
%>