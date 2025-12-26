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

     //Unsubscribes
     unsubID = "-1";
     unsubPosition = "1";
     String tmpUnsubID = "";
		
     sSql = 
          " SELECT msg_id, ISNULL(msg_name,''), ISNULL(html_msg,''), ISNULL(text_msg,''), ISNULL(aol_msg,'') " +
          " FROM ccps_unsub_msg WHERE cust_id = "+cust.s_cust_id;
							   
     rs = stmt.executeQuery(sSql);
     while (rs.next())
     {
          tmpUnsubID = rs.getString(1);
          if (unsubID.equals(tmpUnsubID))
          {
               htmlUnsubs += "<option selected value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";
          }
          else
          {
               htmlUnsubs += "<option value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";
          }
			
          htmlUnsubContent +=
               "<textarea style=display:none name=UnsubContentHTML"+tmpUnsubID+">"+
               new String(rs.getBytes(3),"UTF-8")+"</textarea>\n";
				
          textUnsubContent +=
               "<textarea style=display:none name=UnsubContentText"+tmpUnsubID+">"+
               new String(rs.getBytes(4),"UTF-8")+"</textarea>\n";
				
          aolUnsubContent +=
               "<textarea style=display:none name=UnsubContentAOL"+tmpUnsubID+">"+
               new String(rs.getBytes(5),"UTF-8")+"</textarea>\n";

          jsUnsubs += "if (document.all.unsubID.value == "+tmpUnsubID+") {\n" +
                         "	if (act=='1') unTxt = document.all.UnsubContentText"+tmpUnsubID+".value;\n" +
                         "	if (act=='2') unTxt = document.all.UnsubContentHTML"+tmpUnsubID+".value;\n" +
                         "	if (act=='3') unTxt = document.all.UnsubContentAOL"+tmpUnsubID+".value;\n" +
                         "}\n";
     }
     rs.close();

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
<FORM  METHOD="POST" NAME="FT" ENCTYPE="multipart/form-data" ACTION="cont_load_save.jsp" TARGET="_self">
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
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Name Your Content</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class=EditTabOn id=tab1_Step1 width=150 onclick="switchSteps('Tabs_Table1', 'tab1_Step1', 'block1_Step1');" valign=center nowrap align=middle>General Information</td>
		<td class=EditTabOff id=tab1_Step2 width=150 onclick="switchSteps('Tabs_Table1', 'tab1_Step2', 'block1_Step2');" valign=center nowrap align=middle>Content Information</td>
		<td class=EmptyTab valign=center nowrap align=middle width=350><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650" colspan="3">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="100">Content Name:<br><font color="red">(required)</font></td>
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
		<td class=fillTab valign=top align=center width=650 height="160" colspan=3>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td width="150">Send Type</td>
					<td width="475">
						<!-- Send type list-->
						<select name=SendTypes size=1>
							<%= htmlCharsets %>
						</select>
					</td>
				</tr>
				<tr>
					<td width="150">Unsubscribe Message</td>
					<td width="475">
						<select name=unsubID size=1>
							<%= htmlUnsubs %>
						</select>
					</td>
				</tr>
				<tr>
					<td width="150">Position of Unsubscribe Message</td>
					<td width="475">
						<select name=unsubPos size=1>
							<option <%= (unsubPosition.equals("1")?"selected":"") %> value=1>Bottom</option>
							<option <%= (unsubPosition.equals("0")?"selected":"") %> value=0>Top</option>
							<option <%= (unsubPosition.equals("-1")?"selected":"") %> value=-1>Top and Bottom</option>
						</select>
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
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Select your ZIP file</td>
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
<!--- Step 3 Header----->
<br><br>
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 3:</b> Select Link Scanning Options</td>
	</tr>
</table>
<br>
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
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td>
						<table class="main" cellspacing="0" cellpadding="2" width="100%">
							<tr>
								<td align="left" valign="middle" width="22"><input onclick="switchLinkTrackingOptions()" type="checkbox" name="auto_link_scan" value = "1" checked></td>
								<td align="left" colspan="2" valign="middle">Auto Scan for Links?</td>
							</tr>
							<tr id="linkTrackingOptions1">
								<td align="left" valign="middle">&nbsp;&nbsp;&nbsp;</td>
								<td align="left" valign="middle">
									<input type="checkbox" name="use_anchor_name" value = "1" checked>
									</td>
									<td align="left" valign="middle">
										Set link name from anchor name<br>
										(Example: <span style="font-family:Verdana; font-size:8pt;">&lt;a href=&quot;http://www.mycompany.com&quot; name=&quot;My Company Home&quot;&gt;link&lt;/a&gt;</span><br>
										will be named &quot;My Company Home&quot;)
								</td>
							</tr>
							<tr id="linkTrackingOptions2">
								<td align="left" valign="middle">&nbsp;&nbsp;&nbsp;</td>
								<td align="left" valign="middle">
									<input type="checkbox" name="use_link_renaming" value = "1" checked>
									</td>
								<td align="left" valign="middle">
										Set link name from Auto Link Names
								</td>
							</tr>
							<tr id="linkTrackingOptions3">
								<td align="left" valign="middle">&nbsp;&nbsp;&nbsp;</td>
								<td align="left" valign="middle">
									<input type="checkbox" name="replace_scanned_links" value = "1" checked>
									</td>
								<td align="left" valign="middle">
										Replace all previously scanned links
								</td>
							</tr>
						</table>
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


     sContentName = FT.contentName.value;
     if (sContentName == "")
     {
          alert("You must name your content.");
          return;
     }

     if(FT.zip_file.value == "") {
          alert('You must select a ZIP file to upload.');
          return;
     }
     

	FT.submit();
}

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

}


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


























