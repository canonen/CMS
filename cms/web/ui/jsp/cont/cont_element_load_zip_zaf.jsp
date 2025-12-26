<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.ctl.*,
		java.sql.*,java.io.*,
		java.util.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>

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

	//Is it the standard ui?
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

	String contID = request.getParameter("cont_id");
	if (!can.bWrite && contID == null)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;


String sErrors = BriteRequest.getParameter(request,"errors");

boolean bCanExecute = can.bExecute;
boolean bCanWrite = (can.bWrite || bCanExecute);

//UI Type
boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

// Connection
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
<BODY>
<FORM  METHOD="POST" NAME="FT" ENCTYPE="multipart/form-data" ACTION="cont_element_load_save.jsp" TARGET="_self">
<%
if(can.bWrite)
{
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="#" onClick="try_submit();">Upload ZIP &amp; Save</a>
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
			<table class="" cellspacing="1" cellpadding="2" width="100%">
				 <!-- <tr>
					<td align="left" valign="middle" width="100">Content Name:<br></td>
					<td align="left" valign="middle">
                                            <input type="text" name="contentName" size="50" maxlength="50">
					</td>
				</tr> -->
				<tr<%=!canCat.bRead?" style=\"display:'none'\"":""%>>
                                        <td>Categories</td>
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
			<table  cellspacing=1 cellpadding=2 width="100%">
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
		<th class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Select your ZIP file</th>
	</tr>

	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class="" valign="top" align="center" width="650">
			<table class="" cellspacing="1" cellpadding="2" width="100%">
                    <tr>
					<td align="left" valign="middle" width="150">
                              Select your ZIP file:
                         </td>
					<td align="left" valign="middle">
						<input type="file" name="zip_file" size="30" <%=(!bCanWrite)?"disabled":""%>>
					</td>
				</tr>
                    <tr>
                         <td align="left" valign="middle" colspan="2">
                         **NOTE:  The ZIP file should contain ONLY html, text or supported image files.
                         </td>
                    </tr>
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


//     sContentName = FT.contentName.value;
//     if (sContentName == "")
//     {
//          alert("You must name your content.");
//          return;
//     }

     if(FT.zip_file.value == "") {
          alert('You must select a ZIP file to upload.');
          return;
     }
     

	FT.submit();
}
/*
function switchLinkTrackingOptions() {
     var dDiv1 = document.getElementById("linkTrackingOptions1");
     var dDiv2 = document.getElementById("linkTrackingOptions2");
     var dDiv3 = document.getElementById("linkTrackingOptions3");

     if (FT.auto_link_scan.checked) {
          dDiv1.style.display = "";
          dDiv2.style.display = "";
          dDiv3.style.display = "";
          FT.use_anchor_name.checked = true;
          FT.use_link_renaming.checked = true;
          FT.replace_scanned_links.checked = true;
     } else {
          dDiv1.style.display = "none";
          dDiv2.style.display = "none";
          dDiv3.style.display = "none";
          FT.use_anchor_name.checked = false;
          FT.use_link_renaming.checked = false;
          FT.replace_scanned_links.checked = false;
     }

} */


</SCRIPT>

</BODY>
</HTML>
<%
} catch(Exception ex) { 

	ErrLog.put(this,ex, "Exception thrown while attempting to upload image.",out,1);

} finally {
	if ( stmt != null ) stmt.close ();	
	if ( conn != null ) cp.free(conn);
}

%>


























