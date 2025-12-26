<%@ page
	language="java"
	import="com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.*,java.util.*,
			java.sql.*,java.net.*,
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
ImgFolder parent = new ImgFolder(sParentId);

String sImageId = BriteRequest.getParameter(request,"image_id");
int nImageId = Integer.parseInt((sImageId == null)?"0":sImageId);
String sErrors = BriteRequest.getParameter(request,"errors");

Image image = new Image(sImageId);

boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);
/* *** */

//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);
/* *** */

// Connection
Statement			stmt = null;
ResultSet			rs = null; 
ConnectionPool		cp = null;
Connection			conn = null;
/* *** */


try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("image_access.jsp");
	stmt = conn.createStatement();

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
	
</script>
</HEAD>
<BODY>
<% if (sErrors != null) {
%>
     <font color="red">
          <%=sErrors%>
     </font>
<%   }    %>
<FORM  METHOD="POST" NAME="FT" ACTION="image_access_save.jsp" TARGET="_self">
<INPUT TYPE="hidden" NAME="categorytemp" VALUE="">
<INPUT type="hidden" name="image_id" value="<%=sImageId%>">
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
                    Save
                    </a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>
<%
	int nChildCount = -1;
	rs = stmt.executeQuery("EXEC usp_ccps_cust_tree_get @cust_id = " + cust.s_cust_id);
	while (rs.next()) {
		//only interested in last customer on chain
		nChildCount++;
	}
	rs.close();

	if ((nChildCount > 0) && (parent.s_type_id.equals(String.valueOf(ImageFolderType.GLOBAL)))){
%>
<!--- Step 1 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Set Access Rights for Image <%=image.s_image_name%></td>
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
			<table class="listTable" cellspacing="0" cellpadding="2" border="0" width="100%">
			<%= ImageHostUtil.getImageCustAccessHTML(cust.s_cust_id, sImageId) %>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<%
	}
%>

<SCRIPT LANGUAGE="JavaScript">

function try_submit () {
<%
	if ((nChildCount > 0) && (parent.s_type_id.equals(String.valueOf(ImageFolderType.GLOBAL)))){
%>
	FT.access_map.value = "<%=cust.s_cust_id%>";

	var cust_obj = FT.cust_access;
	for (var i=0; i < cust_obj.length; i++) {
		if (cust_obj[i].checked == true) FT.access_map.value += (";"+cust_obj[i].value);
	}
<%
	}
%>     
	FT.submit();
}

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
	if ( conn  != null ) cp.free(conn); 
}
%>


























