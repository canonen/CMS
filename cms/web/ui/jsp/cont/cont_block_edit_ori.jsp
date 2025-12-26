<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="java.sql.*,java.io.*"
	import="javax.servlet.*"
	import="javax.servlet.http.*"
	import="org.xml.sax.*"
	import="javax.xml.transform.*"
	import="javax.xml.transform.stream.*"
	import="org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%!
	static Logger logger = null;
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

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

	String contID = request.getParameter("cont_id");	
	if (!can.bWrite && contID == null)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	
	ui.setSessionProperty("dynamic_elements_section", "2");

	String logicID = request.getParameter("logic_id");
	String parentContID = request.getParameter("parent_cont_id");	

	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs		= null;
	String contName="",contStatus="",sendType="",contHTML="",contText="",contAOL="";
	String creator="",creationDate="",editor="",modifyDate="",firstPers="";

	String htmlPersonals = "";
	String htmlStatuses = "";
	String htmlCharsets = "";
	String htmlCurPers = "";
	String jsPersonals = "";
	String jsSubmitPers = "";
	String htmlCategories = "";
	
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		boolean isDisable = false;
		boolean isInUse = false;

		if (contID!=null) {
			rs = stmt.executeQuery("Exec dbo.usp_ccnt_info_get "+contID);
			if (rs.next()) {
				contName = new String(rs.getBytes("Name"),"UTF-8");
				contStatus = rs.getString("Status");
				sendType = rs.getString("SendType");
				contHTML = new String(rs.getBytes("HTML"),"UTF-8");
				contText = new String(rs.getBytes("Text"),"UTF-8");
				contAOL = new String(rs.getBytes("AOL"),"UTF-8");
				creator = rs.getString("creator");
				creationDate = rs.getString("create_date");
				editor = rs.getString("modifier");
				modifyDate = rs.getString("modify_date");
			}
			rs.close();
			if (contHTML == null) contHTML = "";
			if (contAOL == null) contAOL = "";
			if (contText == null) contText = "";

		} else {
			contName = "New Content Block";
		}

		//Personalization
		String attrName,attrDisplayName,tmp,defaultValue,attrID;
		int i,j;
		rs = stmt.executeQuery(""+
			"SELECT c.attr_id, a.attr_name, c.display_name " +
			"FROM ccps_cust_attr c, ccps_attribute a " +
			"WHERE c.cust_id = "+cust.s_cust_id+" AND c.display_seq IS NOT NULL " +
			"AND c.attr_id = a.attr_id " +
			"ORDER BY display_seq");
		while (rs.next()) {
			attrID = rs.getString(1);
			attrName = rs.getString(2);
			attrDisplayName = new String(rs.getBytes(3),"UTF-8");
			if (firstPers.length() == 0) firstPers = attrName;
			htmlPersonals += "<option value="+attrName+">"+attrDisplayName+"</option>\n";
			
			//Scan the contents for Personalization
			String allConts = contText + contHTML + contAOL;
			if (allConts != null && allConts.length() != 0) {
				i = allConts.indexOf("!*"+attrName+";");
				if (i != -1) {
					tmp = allConts.substring(i);
					j = tmp.indexOf("*!");
					if (j != -1) {
						defaultValue = tmp.substring(3+attrName.length(),j);
						htmlCurPers += "<tr><td>"+attrDisplayName+"</td>\n" +
									   "<td><input type=text name=curDefault"+attrID+" value=\""+defaultValue+"\">\n";
						jsPersonals += "if (attrID == "+attrID+") {\n" +
									   "	newDefault = FT.curDefault"+attrID+".value;\n" +
									   "	attrName = '"+attrName+"';\n}\n";
						jsSubmitPers += "scanContentForPers("+attrID+");\n";
					}
				}
			}
		}
		if (htmlCurPers.length() == 0) htmlCurPers = "<tr><td colspan=2>None</td></tr>\n";
		
		//Statuses
		String tmpStatusID = "";
		rs = stmt.executeQuery("SELECT status_id, status_name FROM ccnt_cont_status WHERE status_id not in (15,25)");
		while (rs.next()) {
			tmpStatusID = rs.getString(1);
			if (contStatus.equals(tmpStatusID)) {
				htmlStatuses += "<option selected value="+tmpStatusID+">"+rs.getString(2)+"</option>\n";
			} else {
				htmlStatuses += "<option value="+tmpStatusID+">"+rs.getString(2)+"</option>\n";
			}
		}
		
		//Charsets
		String tmpCharsetID = "";
		rs = stmt.executeQuery("SELECT charset_id, display_name FROM ccnt_charset");
		while (rs.next()) {
			tmpCharsetID = rs.getString(1);			
			if (sendType.equals(tmpCharsetID)) {
				htmlCharsets += "<option selected value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";
			} else {
				htmlCharsets += "<option value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";			
			}
		}
		
		//Categories
		String sSql =
			" SELECT c.category_id, c.category_name, oc.object_id" +
			" FROM ccps_category c" +
				" LEFT OUTER JOIN ccps_object_category oc" +
				" ON (c.category_id = oc.category_id" +
					" AND c.cust_id = oc.cust_id" +
					" AND oc.object_id="+contID+
					" AND oc.type_id="+ObjectType.CONTENT+")" +
			" WHERE c.cust_id="+cust.s_cust_id;

		rs = stmt.executeQuery(sSql);

		String sCategoryId = null;
		String sCategoryName = null;
		String sObjectId = null;
			
		while (rs.next()) {
			sCategoryId = rs.getString(1);
			sCategoryName = new String(rs.getBytes(2), "UTF-8");
			sObjectId = rs.getString(3);

			htmlCategories += "<OPTION value=\""+sCategoryId+"\" "+(((sObjectId!=null)||((sSelectedCategoryId!=null)&&(sSelectedCategoryId.equals(sCategoryId))))?"selected":"")+">" +
					sCategoryName+
				"</OPTION>";
		}
		
	} catch(Exception ex)	{
		ErrLog.put(this,ex,"cont_block_edit.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>
<html>
<head>
<title>Content Element</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<SCRIPT LANGUAGE="JAVASCRIPT">
<%@ include file="../../js/scripts.js" %>

var dblclick = 0;

//function EmptyAndSave(){
//  FT.DefaultValue.value = '';
//  SaveDefault();
//}


 function PreviewURL(freshurl)
        {
            SmallWin = window.open(freshurl, 'Filter','scrollbars=yes,resizable=yes,toolbar=no,height=250,width=650');

            
        }

// Position after click
function ShowBack(Mask){

	for (var i = 0; i < FT.PerzFields.length; i++){
		if(FT.PerzFields.options[i].value == Mask){
			FT.PerzFields.selectedIndex = i;
			FT.DefaultValue.value=FT.PerzDefaults.options[i].text;
			FT.MergeSymbol.value='!*' + Mask + '*!';
			return;
		}
	}
}

function WinOpen(WinTxt, unTxt, act){
var winl = (screen.width - 600) / 2;
var wint = (screen.height - 400) / 2;

// center & show (600x800)
	winprops = 'height=400,width=600,top='+wint+',left='+winl+',scrollbars=yes,resizable'
	msg=window.open('','msg',winprops);

	if (WinTxt == '')
	{	
		msg.document.write(unTxt);
		msg.document.close();
		return;
	}

	if (act=='1') msg.document.write('<textarea cols=65 rows=20 wrap=hard>' + WinTxt + '</textarea><br><br><br>' + unTxt);
	if (act=='2') msg.document.write(WinTxt + '<br><br><br>' + unTxt);
	if (act=='3') msg.document.write(stripPRE(WinTxt + '<br><br><br>' + unTxt));
	msg.document.close();
}

function stripPRE( inString ) {
	var outString = inString;
	while ( outString.indexOf( '<PRE>' ) > - 1 )
		outString = outString.replace( '<PRE>', '' );
	while ( outString.indexOf( '</PRE>' ) > - 1 )
		outString = outString.replace( '</PRE>', '' );
	while ( outString.indexOf( '<pre>' ) > - 1 )
		outString = outString.replace( '<pre>', '' );
	while ( outString.indexOf( '</pre>' ) > - 1 )
		outString = outString.replace( '</pre>', '' );
	return outString;
}

function SubmitPrepare(Act){
// Check the text
	if(FT.ContentText.innerText.length == 0) {
		alert("You have to enter something to the Text field");
		return;
	}

// Check for double click
	if (dblclick < 1) {

		dblclick++;
	}

	if (Act == '3') {
		<%= jsSubmitPers %>
	}
	
	FT.ActionSave.value = Act;

	FT.submit();
}
function UnicodeConvert(oldText){
var newText="";
//   for(var i=0; i<oldText.length; i++){
//      newText += "&#" + oldText.charCodeAt(i).toString() + ";";
//      newText += oldText.charCodeAt(i).toString() + ";";
//   }
return oldText;
}

function replacePers(vtext,attrName,newDefault) {
	tmp = vtext;
	i = tmp.indexOf('!*'+attrName+';');
	offset = 0;
	while (i != -1) {
		tmp = tmp.substring(i);
		j = tmp.indexOf('*!');
		if (j != -1) {
			vtext = vtext.substring(0,offset+i+3+attrName.length)+newDefault+tmp.substring(j);

			offset += attrName.length+newDefault.length+3+i;
			tmp = tmp.substring(j);
			i = tmp.indexOf('!*'+attrName+';');
		} else {
			i = -1;
		}
	}
	return vtext;
}

//Search each content for personalization symbols - '!*attr_name;default value*!'
function scanContentForPers(attrID) {
	var newDefault;
	var attrName;
	<%= jsPersonals %>
	
	var vtext = FT.ContentText.value;
	var vhtml = FT.ContentHTML.value;
	var vaol = FT.ContentAOL.value;
	
	if(vtext != null && vtext.length != 0) {
		FT.ContentText.value = replacePers(vtext,attrName,newDefault);
	}
	if(vhtml != null && vhtml.length != 0) {
		FT.ContentHTML.value = replacePers(vhtml,attrName,newDefault);
	}
	if(vaol != null && vaol.length != 0) {
		FT.ContentAOL.value = replacePers(vaol,attrName,newDefault);
	}

}

</SCRIPT>
<script language="javascript" src="../../js/tab_script.js"></script>

<body<%= (!can.bWrite)?" onload='disable_forms()'":" " %>>
<form name="FT" method="post" action="cont_block_save.jsp">
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>

<!--- Context Help Code -- Do Not Remove //-->
<DIV id="TipLayer" style="visibility:hidden;position:absolute;z-index:1000;top:-100"></DIV>
<SCRIPT language="JavaScript1.2" src="../../js/help_style.js" type="text/javascript"></SCRIPT>
<!--- Context Help Code -- Do Not Remove //-->

<!-- Content ID -->
<input type=hidden name="contentID" value="<%= contID %>">
<input type=hidden name="logicID" value="<%=(logicID!=null)?logicID:""%>">
<input type=hidden name="parentContID" value="<%=(parentContID!=null)?parentContID:""%>"/>

<input type=hidden name=UnsubContentText value="">
<input type=hidden name=UnsubContentHTML value="">
<input type=hidden name=UnsubContentAOL value="">

<!-- Unsubscription Text default 
        <xsl:element name="input">
        <xsl:attribute name="type">hidden</xsl:attribute>
        <xsl:attribute name="name">UnsubContentText</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/UnsubContentText"/></xsl:attribute>
        </xsl:element>

<!-- Unsubscription HTML default 
        <xsl:element name="input">
        <xsl:attribute name="type">hidden</xsl:attribute>
        <xsl:attribute name="name">UnsubContentHTML</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/UnsubContentHTML"/></xsl:attribute>
        </xsl:element>

<!-- Unsubscription AOL default 
        <xsl:element name="input">
        <xsl:attribute name="type">hidden</xsl:attribute>
        <xsl:attribute name="name">UnsubContentAOL</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/UnsubContentAOL"/></xsl:attribute>
        </xsl:element>
-->

<!-- Subscribe URL default
        <xsl:element name="input">
        <xsl:attribute name="type">hidden</xsl:attribute>
        <xsl:attribute name="name">SubscribeURL</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/SubscribeURL"/></xsl:attribute>
        </xsl:element>
-->

<input type="hidden" name="ActionSave" value="0"/>

<%
if (can.bWrite)
{
	%>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="javascript:SubmitPrepare('1')">Save</a>
		</td>
	<%
	if (contID != null)
	{
	%>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="SubmitPrepare('2')">Clone</a>
		</td>
		<%
		if(ui.getUIMode() != ui.SINGLE_CUSTOMER)
		{
			%>				
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="SubmitPrepare('4')">Clone to Destination</a>
		</td>
			<%
		}
		
		if (can.bDelete)
		{
			%>
		<td vAlign="middle" align="left">
			<a class="deletebutton" href="#" onclick="if( confirm('Are you sure?') ) location.href='cont_block_delete.jsp?cont_id=<%= contID %>';">Delete</a>
		</td>
			<%
		}
	}
	else
	{
	%>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="SubmitPrepare('0')">Save &amp; Next</a>
		</td>
	<%
	}
	%>
	</tr>
</table>
<br>
	<%
}
%>

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Name Your Content Element</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650 colspan=3>
			<table class=main cellspacing=1 cellpadding=1 width="100%">
				<tr>
					<td width="150">Content Element Name</td>
					<td width="475">
						<input type="text" name="ContentName" width="100%" size="56" Value="<%= contName %>">
					</td>
					<td width="150">Status</td>
					<td width="475">
						<!-- Status list -->
						<select name=Statuses size=1>
							<%= htmlStatuses %>
						</select>
					</td>
				</tr>
				<tr>
					<td width="150">Send Type</td>
					<td width="475" colspan="3">
						<!-- Send type list-->
						<select name=SendTypes size=1>
							<%= htmlCharsets %>
						</select>
					</td>
				</tr>
				<tr<%=!canCat.bRead?" style=\"display:'none'\"":""%>>
					<td width="150"> Categories</td>
					<TD width="475" colspan=3 align="left">
						<SELECT multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="6" width="50%">
							<%= htmlCategories %>
						</SELECT>
						<%=(!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0")))
						?"<INPUT type=hidden name=\"categories\" value=\""+sSelectedCategoryId+"\">"
						:""%>
					</TD>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 2 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Personalize Your Content Element</td>
	</tr>
</table>
<br>
<!---- Step 2 Info----->
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EditTabOn id=tab2_Step1 width=150 onclick="switchSteps('Tabs_Table2', 'tab2_Step1', 'block2_Step1');" valign=center nowrap align=middle>Available Options</td>
		<td class=EditTabOff id=tab2_Step2 width=150 onclick="switchSteps('Tabs_Table2', 'tab2_Step2', 'block2_Step2');" valign=center nowrap align=middle>Current Personalization</td>
		<td class=EmptyTab valign=center nowrap align=middle width=350><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab valign=top align=left width=650 colspan=3>
			<table class="main" cellpadding="2" cellspacing="1" width="100%">
				<tr>
					<td width="100%" align="left" valign="middle">
						Personalization Field:<br>
						<select name=PerzFields size=1 onchange="FT.MergeSymbol.value='!*'+this.value+';'+FT.DefaultValue.value+'*!';">
							<%= htmlPersonals %>		
						</select>
					</td>
					<td align="right"><a class="resourcebutton" href="javascript:void(0);" onMouseOver="stm(Text[0],Style[0])" onmouseout="htm()">[?]</a></td>
				</tr>
				<tr>
					<td width="100%" align="left" valign="middle" colspan="2">
						Default Value:<br>
						<!-- Default value -->
						<input type=text name="DefaultValue" size=22 onkeyup="FT.MergeSymbol.value='!*'+FT.PerzFields.options[FT.PerzFields.selectedIndex].value+';'+this.value+'*!';">
					</td>
				</tr>
				<tr>
					<td width="100%" align="left" valign="middle" colspan="2">
						Merge Symbol:<br>
						<!-- PickUp value -->
						<input type=text name=MergeSymbol size=34 disabled value="!*<%= firstPers %>;*!"><br>
						(copy and paste this into your content)
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class=EditBlock id=block2_Step2 style="display:none;">
	<tr>
		<td class=fillTab valign=top align=left width=650 colspan=3>
			<table class="main" width="100%" cellpadding="2" cellspacing="1">
				<tr>
					<td valign="middle" width="100%">
					<a class="subactionbutton" href="#"	onclick="SubmitPrepare('3')">Update and Scan</a>
					</td>
					<td align="right"><a class="resourcebutton" href="javascript:void(0);" onMouseOver="stm(Text[4],Style[0])" onmouseout="htm()">[?]</a></td>
				</tr>
				<tr>
					<td width="625" valign="middle" colspan="2">
						<table width="625">
							<tr>
								<td valign="middle">Field</td>
								<td valign="middle">Default Value</td>			
							</tr>
							<tr>
								<%= htmlCurPers %>
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

<!----Step 3 Header ---->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 3:</b> Enter Your Content</td>
	</tr>
	<tr>
		<td align="center">
			Link to a Revotas-hosted form: <a class="resourcebutton" href="javascript:PreviewURL('../form/form_list_url.jsp')">Generate Form URL</a>
		</td>
	</tr>
</table><br>
<!---Step 3 Info------->
<table id="Tabs_Table3" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EditTabOn id=tab3_Step1 width=200 onclick="switchSteps('Tabs_Table3', 'tab3_Step1', 'block3_Step1');" valign=center nowrap align=middle>Text</td>
		<td class=EditTabOff id=tab3_Step2 width=200 onclick="switchSteps('Tabs_Table3', 'tab3_Step2', 'block3_Step2');" valign=center nowrap align=middle>HTML</td>
		<td class=EditTabOff id=tab3_Step3 style="display:none;" width=150 onclick="switchSteps('Tabs_Table3', 'tab3_Step3', 'block3_Step3');" valign=center nowrap align=middle>AOL</td>
		<td class=EmptyTab valign=center nowrap align=middle width=250><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=4><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block3_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650 colspan=4>
			<table class=main cellspacing=1 cellpadding=2 width=100%>
				<tr>
					<td align="center">
						<br>Enter Text EMail Content Here<br>
						<textarea rows="11" name="ContentText" cols="60" style="width: 505; height: 231"><%= WebUtils.convertToByteSymbolSequence(contText) %></textarea>
						<br><br>
						<a class="subactionbutton" href="javascript:WinOpen(FT.ContentText.value, FT.UnsubContentText.value, '1')">Preview Text</a>
						<br>
						<br>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class=EditBlock id=block3_Step2 style="display:none;">
	<tr>
		<td class=fillTab valign=top align=center width=650 colspan=4>
			<table class=main cellspacing=1 cellpadding=2 width=100%>
				<tr>
					<td width="625" align="center">
						<br>Enter HTML EMail Content Here<br>
						<textarea rows="11" name="ContentHTML" cols="60" style="width: 505; height: 231"><%= WebUtils.convertToByteSymbolSequence(contHTML) %></textarea>
						<br><br>
						<a class="subactionbutton" href="javascript:WinOpen(FT.ContentHTML.value, FT.UnsubContentHTML.value, '2')">Preview HTML</a>
						<br>
						<br>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class=EditBlock id=block3_Step3 style="display:none;">
	<tr>
		<td class=fillTab valign=top align=center width=650 colspan=4>
			<table class=main cellspacing=1 cellpadding=2 width=100%>
				<tr>
					<td width="625" align="center">
						<br>Enter AOL EMail Content Here<br>
						<textarea rows="11" name="ContentAOL" cols="60" style="width: 505; height: 231"><%= WebUtils.convertToByteSymbolSequence(contAOL) %></textarea>
						<br><br>
						<a class="subactionbutton" href="javascript:WinOpen(FT.ContentAOL.value, FT.UnsubContentAOL.value, '3')">Preview AOL</a>
						<br>
						<br>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!-- History Info -->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>History</b></td>
	</tr>
</table>
<br>
<table class="main" cellspacing="1" cellpadding="3" width="650" border="0">
	<tr>
		<td class="CampHeader"><b>Created by</b></td>
		<td><%= creator %></td>
		<td class="CampHeader"><b>Last Modified by</b></td>
		<td><%= editor %></td>
	</tr>
	<tr>
		<td class="CampHeader"><b>Creation date</b></td>
		<td><%= creationDate %></td>
		<td class="CampHeader"><b>Last Modify date</b></td>
		<td><%= modifyDate %></td>
	</tr>
</table>
<br><br>
</body>
</html>
