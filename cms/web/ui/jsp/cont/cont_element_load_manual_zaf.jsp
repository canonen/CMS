<%@ page
	language="java"
	import="com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.adm.*,
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
AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

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

boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);

boolean bCanImageWrite = false;
// featureid 110 = image library
if (CustFeature.exists(cust.s_cust_id,110)) {
	bCanImageWrite = true;
}

//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

Image image = null;
String htmlCategories = CategortiesControl.toHtmlOptions(cust.s_cust_id, sSelectedCategoryId);

String contStatus="",sendType="",contHTML="",contText="";
String unsubID="",unsubPosition="",textFlag="",htmlFlag="",aolFlag="";

String htmlTracking = "";
String htmlPersonals = "";
String htmlStatuses = "";
String htmlCharsets = "";
String htmlCurPers = "";
String jsPersonals = "";
String jsSubmitPers = "";
String htmlLogicBlocks = "";
String htmlUnsubs = "";
String htmlUnsubContent = "";
String textUnsubContent = "";
String aolUnsubContent = "";
String jsUnsubs = "";

ConnectionPool cp	= null;
Connection conn		= null;
Statement stmt		= null;
ResultSet rs		= null;

String sSql = null;
byte[] b = null;
try
{
     cp = ConnectionPool.getInstance();
     conn = cp.getConnection("cont_load_manual.jsp");
     stmt = conn.createStatement();

     //Charsets
     String tmpCharsetID = "";
     rs = stmt.executeQuery("SELECT charset_id, display_name FROM ccnt_charset");
     while (rs.next())
     {
          tmpCharsetID = rs.getString(1);			
          if (sendType.equals(tmpCharsetID))
               htmlCharsets += "<option selected value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";
          else
               htmlCharsets += "<option value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";			
     }
     rs.close();


%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY onload="FT.contentName.focus()">
<% if (sErrors != null) {
%>
     <font color="red">
          <%=sErrors%>
     </font>
<%   }    %>

<FORM  METHOD="POST" NAME="FT" ENCTYPE="multipart/form-data" ACTION="cont_element_load_save.jsp" TARGET="_self">

<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>

<INPUT TYPE="hidden" NAME="num_files" value="0">

<%
if(can.bWrite)
{
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="javascript:loadContent();">Load &amp; Save</a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>
<!--- Step 1 Header----->
<table width="700" class="listTable" cellspacing="0" cellpadding="0">
	<tr>
		<th colspan=3 class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Name Your Content</th>
	</tr>
	<tr>
		<td class=Tab_ON id=tab1_Step1 width=150 onclick="toggleTabs('tab1_Step','block1_Step',1,2,'Tab_ON','Tab_OFF');" valign=center nowrap align=middle><b>General Information</b></td>
		<td class=Tab_OFF id=tab1_Step2 width=150 onclick="toggleTabs('tab1_Step','block1_Step',2,2,'Tab_ON','Tab_OFF');" valign=center nowrap align=middle><b>Content Information</b></td>
		<td class=Tab_OFF valign=center nowrap align=middle width=350><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="" valign="top" align="center" width="650" colspan="3">
			<table class="" cellspacing="1" cellpadding="2" width="100%" border="0">
				<tr>
					<td align="left" valign="middle" width="100">Content Name:<br> <font color="red">(required)</font></td>
					<td align="left" valign="middle">
                              <input type="text" name="contentName" size="50" maxlength="50">
					</td>
				</tr>
				<tr<%=!canCat.bRead?" style=\"display:'none'\"":""%>><td>Categories</td>
					<td colspan="2" width="625">
						<SELECT multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="5" width="100">
							<%= htmlCategories %>
						</SELECT>
						<%=(!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0")))
						?"<INPUT type=hidden name=\"categories\" value=\""+sSelectedCategoryId+"\">"
						:""%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block1_Step2" style="display:none;">
	<tr>
		<td valign=top align=center width=650 height="160" colspan=3>
			<table cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td width="150">Send Type</td>
					<td width="475">
						<!-- Send type list-->
						<select name=SendTypes size=1>
							<%= htmlCharsets %>
						</select>
					</td>
				</tr>

			</table>
		</td>
	</tr>
	</tbody>
</table>
<br>

<!--- Step 2 Header----->
<table width="700" class="listTable" cellspacing="0" cellpadding="0">
	<tr>
		<th class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Select Your Files</th>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class="" valign="top" align="center" width="650">
			<table class="" cellspacing="1" cellpadding="2" width="100%" id="textFileTable">
				<tr>
					<td align="left" valign="middle" width="100">Select Text File:<br> <font color="red">(required)</font></td>
					<td align="left" valign="middle">
						<input type="file" name="cont_text_file" size="65" <%=(!bCanWrite)?"disabled":""%>>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block2_Step2">
	<tr>
		<td class="" valign="top" align="center" width="650">
			<table class="" cellspacing="1" cellpadding="2" width="100%" id="HTMLFileTable">
				<tr>
					<td align="left" valign="middle" width="100">Select HTML File:</td>
					<td align="left" valign="middle">
						<input type="file" name="cont_html_file" size="65" <%=(!bCanWrite)?"disabled":""%>>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class="EditBlock" id="block3_Step2">
	<tr>
		<td class="" valign="top" align="center" width="650">
			<table class="" cellspacing="1" cellpadding="2" width="100%" id="imageFileTable">
<%
if (bCanImageWrite) {
%>
				<tr>
					<td align="left" valign="middle" width="100">Select Image File:</td>
					<td align="left" valign="middle">
						<input type="file" name="cont_image_file" size="65" <%=(!bCanWrite)?"disabled":""%>>
					</td>
                         <td align="right" valign="middle">
						<a href="javascript:addFileInput();" class="subactionbutton">More Images</a>
					</td>
				</tr>
<%
}
%>
			</table>
		</td>
	</tr>
	</tbody>
</table>

<br><br>
</form>

<script language="javascript" src="../../js/tab_script.js"></script>
<SCRIPT LANGUAGE="JavaScript">
<%@ include file="../../js/scripts.js" %>

function try_submit () {

//	FT.categorytemp.value = "";
//	for(i = 0; i < FT.categories.length; ++i ) {
//		if (FT.categories.options[i].selected == true)
//			FT.categorytemp.value += FT.categories.options[i].value + ((i == FT.categories.length - 1) ? "" : ",");
//	}
	FT.submit();
}

	function isValidTextFile(filename)
	{
        var FILENAME = filename.toUpperCase();
        var len = FILENAME.length;
        if (len >= 4) {
			if (FILENAME.substring(len-4,len) == ".TXT") return true;
		}
        if (len >= 5) {
			if (FILENAME.substring(len-5,len) == ".TEXT") return true;
        }
		return false;
	}

	function isValidHtmlFile(filename)
	{
        var FILENAME = filename.toUpperCase();
        var len = FILENAME.length;
        if (len >= 4) {
			if (FILENAME.substring(len-4,len) == ".HTM") return true;
		}
        if (len >= 5) {
			if (FILENAME.substring(len-5,len) == ".HTML") return true;
        }
		return false;
	}

	function loadContent()
	{
		var tImageTable = document.getElementById("imageFileTable");
          var sContentName = "";
          var fTextFile = "";
          var fHtmlFile = "";
          var fImageFile = "";
		var y = 1;

          sContentName = FT.contentName.value;
		if (sContentName == "")
		{
			alert("You must name your content.");
			return;
		}

		fTextFile = FT.cont_text_file.value;
		if (fTextFile == "")
		{
			alert("You must select a text file to upload.");
			return;
		}
        if (!isValidTextFile(fTextFile)) {
			alert("The text file must end with .txt or .text");
			return;
		}

		fHtmlFile = FT.cont_html_file.value;
		if (fHtmlFile != "")
		{
			if (!isValidHtmlFile(fHtmlFile)) {
				alert("The html file must end with .htm or .html");
				return;
			}
		}		
        
		for (i=0; i<tImageTable.rows.length; i++)
		{
			tImageTable.rows[i].cells[1].children[0].name = "cont_image_file" + i;
               if (i > 0 && tImageTable.rows[i].cells[1].children[0].value == "") {
                    alert("You must select a file for every open image file input.  Either choose a file, or remove the image file input by clicking the 'X'");
                    return;
               }
			y++
		}
		
		FT.num_files.value = (y - 1);
		FT.submit();
	}


	function addFileInput()
	{
		var tTable = document.getElementById("imageFileTable");
		var oRow, oCell;
		
		oRow = tTable.insertRow();
		oCell = oRow.insertCell();
		oCell.vAlign = "middle";
		oCell.width = "100";
		oCell.innerHTML = "Select Image File:";
		
		oCell = oRow.insertCell();
		oCell.align = "left";
		oCell.vAlign = "middle";
		oCell.innerHTML = "<input type=\"file\" name=\"cont_image_file\" tabindex=\"" + (oRow.rowIndex + 1) + "\" size=\"65\" value=\"\" >";
		
		oCell = oRow.insertCell();
		oCell.align = "right";
		oCell.vAlign = "middle";
		oCell.innerHTML = "<a href=\"#\" onclick=\"removeFileInput();\" class=\"subactionbutton\">X</a>"
	}
	
	function removeFileInput()
	{
		var srcElem = window.event.srcElement;
		var trElem = srcElem;
		var tTable = document.getElementById("imageFileTable");
		
		while (trElem.tagName != "TR")
		{
			trElem = trElem.parentElement;
		}
		
		tTable.deleteRow(trElem.rowIndex);
		
	}

</SCRIPT>

</BODY>
</HTML>
<%
} catch(Exception ex) { 

	ErrLog.put(this,ex, "Exception thrown while attempting to upload content.",out,1);

} finally {
	if ( stmt != null ) stmt.close ();	
	if ( conn != null ) cp.free(conn);
}

%>


























