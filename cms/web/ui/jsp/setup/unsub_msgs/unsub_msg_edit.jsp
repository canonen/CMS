<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.adm.*"
	import="com.britemoon.cps.ctm.WebUtils"
	import="java.sql.*,java.io.*"
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
	AccessPermission can = user.getAccessPermission(ObjectType.UNSUB_EDIT);

	if(!can.bRead)
	{
		response.sendRedirect("../../access_denied.jsp");
		return;
	}

	String UnsubMsgID = request.getParameter("msg_id");	
	if (!can.bWrite && UnsubMsgID == null)
	{
		response.sendRedirect("../../access_denied.jsp");
		return;
	}

	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs		= null;
	String msgName="";
	String UnsubMsgHTML="";
	String UnsubMsgText="";
	String firstPers="";
	
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

		if (UnsubMsgID!=null)
		{
			UnsubMsg unSubObj = new UnsubMsg(UnsubMsgID);	
			
			msgName = unSubObj.s_msg_name;
			UnsubMsgHTML = unSubObj.s_html_msg;
			UnsubMsgText = unSubObj.s_text_msg;
			
			if (UnsubMsgHTML == null) UnsubMsgHTML = "";			
			if (UnsubMsgText == null) UnsubMsgText = "";

		} else {
			msgName = "New Message";
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
			String allConts = UnsubMsgText + UnsubMsgHTML;
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
		ErrLog.put(this,ex,"unsub_msg_new.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>
<html>
<head>
<title>Unsubscribe Message</title>
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
	if(FT.UnSubMessageText.innerText.length == 0) {
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
	
	var vtext = FT.UnSubMessageText.value;
	var vhtml = FT.UnSubMessageHTML.value;
	
	if(vtext != null && vtext.length != 0) {
		FT.UnSubMessageText.value = replacePers(vtext,attrName,newDefault);
	}
	if(vhtml != null && vhtml.length != 0) {
		FT.UnSubMessageHTML.value = replacePers(vhtml,attrName,newDefault);
	}
}

</SCRIPT>
<script language="javascript" src="../../../js/tab_script.js"></script>

<body<%= (!can.bWrite)?" onload='disable_forms()'":" " %>>
<form name="FT" method="post" action="unsub_msg_save.jsp">

<!--- Unsubscribe Message Help Code -- Do Not Remove //-->
<DIV id="TipLayer" style="visibility:hidden;position:absolute;z-index:1000;top:-100"></DIV>
<SCRIPT language="JavaScript1.2" src="../../../js/help_style.js" type="text/javascript"></SCRIPT>
<!--- Unsubscribe Message Help Code -- Do Not Remove //-->

<!-- Unsubmessage ID -->
<input type=hidden name="UnsubmsgID" value="<%= UnsubMsgID %>">
<input type=hidden name="UnsubMsgText" value="">
<input type=hidden name="UnsubMsgHTML" value="">

<!-- Unsubscription Text default 
        <xsl:element name="input">
        <xsl:attribute name="type">hidden</xsl:attribute>
        <xsl:attribute name="name">UnsubMsgText</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/UnsubMsgText"/></xsl:attribute>
        </xsl:element>

<!-- Unsubscription HTML default 
        <xsl:element name="input">
        <xsl:attribute name="type">hidden</xsl:attribute>
        <xsl:attribute name="name">UnsubMsgHTML</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="ContentInfo/UnsubMsgHTML"/></xsl:attribute>
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
	if (UnsubMsgID != null)
	{
	%>
		<%
		if (can.bDelete)
		{
		%>
		<td vAlign="middle" align="left">
			<a class="deletebutton" href="#" onclick="if( confirm('Are you sure?') ) location.href='unsub_msg_delete.jsp?msg_id=<%= UnsubMsgID %>';">Delete</a>
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
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Name Your Message</td>
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
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Personalize Your Message</td>
	</tr>
</table>
<br>
<!---- Step 2 Info----->
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EditTabOn id=tab2_Step1 width=150 onclick="switchSteps('Tabs_Table2', 'tab2_Step1', 'block2_Step1');" valign=center nowrap align=middle>Available Options</td>
		<td class=EditTabOff id=tab2_Step2 width=150 onclick="switchSteps('Tabs_Table2', 'tab2_Step2', 'block2_Step2');" valign=center nowrap align=middle>Current Personalization</td>
		<td class=EmptyTab valign=center nowrap align=middle width=350><img height=2 src="../../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=3><img height=2 src="../../../images/blank.gif" width=1></td>
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
		<td class=fillTab valign=top align=left width=650 colspan=3>
			<table class="main" width="100%" cellpadding="2" cellspacing="1">
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
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 3:</b> Enter Your Message</td>
	</tr>
	<tr>
		<td align="center">
			Link to a Revotas-hosted form: <a class="resourcebutton" href="javascript:PreviewURL('../../form/form_list_url.jsp?unsubmsgID=true')">Generate Form URL</a>
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
						<br>Enter Unsubscribe Text Message Here<br>
						<textarea rows="11" name="UnSubMessageText" cols="60" style="width: 505; height: 231"><%= WebUtils.convertToByteSymbolSequence(UnsubMsgText) %></textarea>
						<br><br>
						<a class="subactionbutton" href="javascript:WinOpen(FT.UnSubMessageText.value, FT.UnsubMsgText.value, '1')">Preview Text</a>
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
						<br>Enter Unsubscribe HTML Message Here<br>
						<textarea rows="11" name="UnSubMessageHTML" cols="60" style="width: 505; height: 231"><%= WebUtils.convertToByteSymbolSequence(UnsubMsgHTML) %></textarea>
						<br><br>
						<a class="subactionbutton" href="javascript:WinOpen(FT.UnSubMessageHTML.value, FT.UnsubMsgHTML.value, '2')">Preview HTML</a>
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
