<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.imc.*"
	import="com.britemoon.cps.cnt.*"
	import="com.britemoon.cps.ctm.WebUtils"
	import="java.sql.*,java.io.*"
	import="java.util.Vector"
	import="javax.servlet.*"
	import="javax.servlet.http.*"
	import="org.xml.sax.*"
	import="javax.xml.transform.*"
	import="javax.xml.transform.stream.*"
	import="org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%!
	static Logger logger = null;
%>
<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

	if(!can.bRead)
	{
		response.sendRedirect("../../access_denied.jsp");
		return;
	}

	String WebviewMsgID = request.getParameter("msg_id");	
	if (!can.bWrite && WebviewMsgID == null)
	{
		response.sendRedirect("../../access_denied.jsp");
		return;
	}

	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs		= null;
	String msgName="";
	String WebviewMsgHTML="";
	String WebviewMsgText="";
	String firstPers="";
	String sGenericWebviewURL = "";
	
	String htmlPersonals = "";
	String htmlCurPers = "";
	String jsPersonals = "";
	String jsSubmitPers = "";
	
	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		boolean isDisable = false;
		boolean isInUse = false;

		if (WebviewMsgID!=null)
		{
			WebviewMsg webviewObj = new WebviewMsg(WebviewMsgID);	
			
			msgName = webviewObj.s_msg_name;
			WebviewMsgHTML = webviewObj.s_html_msg;
			WebviewMsgText = webviewObj.s_text_msg;
			
			if (WebviewMsgHTML == null) WebviewMsgHTML = "";			
			if (WebviewMsgText == null) WebviewMsgText = "";

		} else {
			msgName = "New Message";
		}

		// generic webview URL
		String sVanityDomain = "";	
		String sSql = 
			" SELECT TOP 1 v.domain " +
			"   FROM cadm_vanity_domain v, cadm_mod_inst m " +
			"  WHERE m.mod_inst_id = v.mod_inst_id" +
			"    AND m.mod_id = " + Module.ASBS +
			"    AND v.cust_id = " + cust.s_cust_id;
		stmt = conn.createStatement();
		rs = stmt.executeQuery(sSql);
		if (rs.next()) {
			sVanityDomain = rs.getString(1);
		}
		rs.close();
		
		Vector vSvcs = Services.getByCust(120, cust.s_cust_id);
		com.britemoon.cps.imc.Service svc = (com.britemoon.cps.imc.Service) vSvcs.lastElement();
		
		String sParams = "?C=!*CampaignID;*!&R=!*RecipID;*!&K=!*recip_key;*!";
		if (sVanityDomain != null && sVanityDomain.length() > 0) {
			sGenericWebviewURL = svc.s_protocol + "://" + sVanityDomain + ":" + svc.s_port + "/" + svc.s_path + sParams;
		}
		else {
			sGenericWebviewURL = svc.getURL().toString() + sParams;
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
			String allConts = WebviewMsgText + WebviewMsgHTML;
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
		
	} catch(Exception ex)	{
		ErrLog.put(this,ex,"webview_msg_new.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>
<html>
<head>
<title>Webview Message</title>
<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<SCRIPT LANGUAGE="JAVASCRIPT">
<%@ include file="../../../js/scripts.js" %>

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
	
	var vtext = FT.WebviewMessageText.value;
	var vhtml = FT.WebviewMessageHTML.value;
	
	if(vtext != null && vtext.length != 0) {
		FT.WebviewMessageText.value = replacePers(vtext,attrName,newDefault);
	}
	if(vhtml != null && vhtml.length != 0) {
		FT.WebviewMessageHTML.value = replacePers(vhtml,attrName,newDefault);
	}
}

function copyURL()
{
	var theURL;
	var theSelect;
	var theRange;
		
	FT.GenericWebviewURL.focus();
	FT.GenericWebviewURL.select();

	theSelect = document.selection;
	theRange = theSelect.createRange();
	if (theRange.text.length > 0)
	{
		theRange.execCommand("Copy");
		document.selection.empty();
		alert("The url has been copied.  Paste the Webview url in the appropriate section of your HTML or Text.");
	}
}

</SCRIPT>
<script language="javascript" src="../../../js/tab_script.js"></script>

<body<%= (!can.bWrite)?" onload='disable_forms()'":" " %>>
<form name="FT" method="post" action="webview_msg_save.jsp">

<!--- Webview Message Help Code -- Do Not Remove //-->
<DIV id="TipLayer" style="visibility:hidden;position:absolute;z-index:1000;top:-100"></DIV>
<SCRIPT language="JavaScript1.2" src="../../../js/help_style.js" type="text/javascript"></SCRIPT>
<!--- Webview Message Help Code -- Do Not Remove //-->

<!-- Webview ID -->
<input type=hidden name="WebviewmsgID" value="<%= WebviewMsgID %>">
<input type=hidden name="WebviewMsgText" value="">
<input type=hidden name="WebviewMsgHTML" value="">

<!-- Webview Text default 
        <xsl:element name="input">
        <xsl:attribute name="type">hidden</xsl:attribute>
        <xsl:attribute name="name">WebviewMsgText</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/WebviewMsgText"/></xsl:attribute>
        </xsl:element>

<!-- Webview HTML default 
        <xsl:element name="input">
        <xsl:attribute name="type">hidden</xsl:attribute>
        <xsl:attribute name="name">WebviewMsgHTML</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/WebviewMsgHTML"/></xsl:attribute>
        </xsl:element>

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
	if (WebviewMsgID != null)
	{
	%>
		<%
		if (can.bDelete)
		{
		%>
		<td vAlign="middle" align="left">
			<a class="deletebutton" href="#" onclick="if( confirm('Are you sure?') ) location.href='webview_msg_delete.jsp?msg_id=<%= WebviewMsgID %>';">Delete</a>
		</td>
		<%
		}
	}
	%>
	</tr>
</table>
<br>
	<%
}
%>

<!--- Step 1 Header----->
<table width=700 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th>&nbsp;<b class=sectionheader>Step 1:</b> Name Your Message</th>
	</tr>
	<tr>
		<td valign=top align=center width=650 colspan=3>
			<table cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<td width="150">Message Name</td>
					<td width="475">
						<input type="text" name="MessageName" width="80%" size="56" Value="<%= msgName %>">
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 2 Header----->
<table width=700 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th colspan=3>&nbsp;<b class=sectionheader>Step 2:</b> Personalize Your Message</th>
	</tr>
	<tr>
		<td class=Tab_ON id=tab2_Step1 width=150 onclick="toggleTabs('tab2_Step','block2_Step',1,2,'Tab_ON','Tab_OFF');" valign=center nowrap align=middle>Available Options</td>
		<td class=Tab_OFF id=tab2_Step2 width=150 onclick="toggleTabs('tab2_Step','block2_Step',2,2,'Tab_ON','Tab_OFF');" valign=center nowrap align=middle>Current Personalization</td>
		<td class=Tab_OFF valign=center nowrap align=middle width=350><img height=2 src="../../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td valign=top align=left width=650 colspan=3>
			<table class="" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td width="100%" align="left" valign="middle">
						Personalization Field:<br>
						<select name=PerzFields size=1 onchange="FT.MergeSymbol.value='!*'+this.value+';'+FT.DefaultValue.value+'*!';">
							<%= htmlPersonals %>		
						</select>
					</td>
					<td align="right"><a class="resourcebutton" href="javascript:void(0);" onMouseOver="stm(Text[5],Style[0])" onmouseout="htm()">[?]</a></td>
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
						(copy and paste this into your message)
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class=EditBlock id=block2_Step2 style="display:none;">
	<tr>
		<td valign=top align=left width=650 colspan=3>
			<table class="" width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td valign="middle" width="100%">
					<a class="subactionbutton" href="#"	onclick="SubmitPrepare('3')">Update and Scan</a>
					</td>
					<td align="right"><a class="resourcebutton" href="javascript:void(0);" onMouseOver="stm(Text[6],Style[0])" onmouseout="htm()">[?]</a></td>
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
<table width=700 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th colspan=4>&nbsp;<b class=sectionheader>Step 3:</b> Enter Your Message</th>
	</tr>
	<tr>
		<td align="left" colspan=4>
			Generic Webview URL: <br>
			<!-- PickUp value -->
			<input type=text name=GenericWebviewURL size=100 value="<%= sGenericWebviewURL %>"><br>
			(copy and paste this into your message) &nbsp; &nbsp; <a class="resourcebutton" href="javascript:copyURL();">Copy URL</a>
		</td>
	</tr>
	<tr style="background-color:#F2F2F2">
		<td class=Tab_ON id=tab3_Step1 width=200 onclick="toggleTabs('tab3_Step','block3_Step',1,3,'Tab_ON','Tab_OFF');" valign=center nowrap align=middle>Text</td>
		<td class=Tab_OFF id=tab3_Step2 width=200 onclick="toggleTabs('tab3_Step','block3_Step',2,3,'Tab_ON','Tab_OFF');" valign=center nowrap align=middle>HTML</td>
		<td class=Tab_OFF id=tab3_Step3 style="display:none;" width=150 onclick="toggleTabs('tab3_Step','block3_Step',3,3,'Tab_ON','Tab_OFF');" valign=center nowrap align=middle>AOL</td>
		<td class=Tab_OFF valign=center nowrap align=middle width=250><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block3_Step1>
	<tr>
		<td valign=top align=center width=650 colspan=4>
			<table cellspacing=0 cellpadding=0 width=100%>
				<tr>
					<td align="center">
						<br>Enter Webview Text Message Here<br>
						<textarea rows="11" name="WebviewMessageText" cols="60" style="width: 505; height: 231"><%= WebUtils.convertToByteSymbolSequence(WebviewMsgText) %></textarea>
						<br><br>
						<a class="subactionbutton" href="javascript:WinOpen(FT.WebviewMessageText.value, FT.WebviewMsgText.value, '1')">Preview Text</a>
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
		<td valign=top align=center width=650 colspan=4>
			<table  cellspacing=0 cellpadding=0 width=100%>
				<tr>
					<td width="625" align="center">
						<br>Enter Webview HTML Message Here<br>
						<textarea rows="11" name="WebviewMessageHTML" cols="60" style="width: 505; height: 231"><%= WebUtils.convertToByteSymbolSequence(WebviewMsgHTML) %></textarea>
						<br><br>
						<a class="subactionbutton" href="javascript:WinOpen(FT.WebviewMessageHTML.value, FT.WebviewMsgHTML.value, '2')">Preview HTML</a>
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

</body>
</html>
