<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp" %>
<%
String sCustId = BriteRequest.getParameter(request, "cust_id");
String sMsgId = BriteRequest.getParameter(request, "msg_id");

UnsubMsg um = null;

if( sMsgId == null)
{
	um = new UnsubMsg();
	um.s_cust_id = sCustId;
}
else um = new UnsubMsg(sMsgId);
%>
<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
</HEAD>
<SCRIPT language="javascript">
function WinOpen(WinTxt, act)
{
	winprops = 'height=450,width=650,scrollbars=yes,resizable'
	msg=window.open('','msg',winprops);

	if (act=='1') msg.document.write('<textarea cols=65 rows=20 wrap=hard>' + WinTxt + '</textarea>');
	if (act=='2') msg.document.write(WinTxt);
	if (act=='3') msg.document.write(stripPRE(WinTxt));
	
	msg.document.title = "Unsubscribe Message Preview";
	msg.focus();
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

function doSave()
{
	if (FT.msg_name.value == null || FT.msg_name.value == "") {
		alert("Please enter a message name");
		return;
	}
	FT.submit()
}

</SCRIPT>
<BODY>

<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
	<col>
	<tr height="35">
		<td valign="top">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="doSave()">Save</a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
			<br>
		</td>
	</tr>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
				<col width="150">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Unsubscribe Message</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form name="FT" method="POST" action="unsub_msg_save.jsp">
						<table class="main layout" border="0" cellspacing="1" cellpadding="3" style="width:100%;">
							<col width="125">
							<co>
							<tr>
								<td>Cust ID</td>
								<td><input type="text" name="cust_id" size="5" style="width:100%;" readonly value="<%=um.s_cust_id%>"></td>
							</tr>
						<%
						if(um.s_msg_id != null)
						{
							%>
							<tr>
								<td>Message ID</td>
								<td><input type="text" name="msg_id" size="5" style="width:100%;" readonly value="<%=um.s_msg_id%>"></td>
							</tr>
							<%
						}
						%>
							<tr>
								<td>Message Name</td>
								<td><input type="text" name="msg_name" size="5" style="width:100%;" value="<%=(um.s_msg_name==null)?"":um.s_msg_name%>"></td>
							</tr>
							<tr>
								<td>Text<br><br>
									<a class="resourcebutton" href="#" onClick="WinOpen(document.all.text_msg.value, '1')">Preview</a></td>
								<td>
									<textarea rows="10" name="text_msg" cols="40" style="width:100%;"><%=(um.s_text_msg==null)?"":um.s_text_msg%></textarea>
								</td>
							</tr>
							<tr>
								<td>HTML<br><br>
									<a class="resourcebutton" href="#" onClick="WinOpen(document.all.html_msg.value, '2')">Preview</a></td>
								<td>
									<textarea rows="10" name="html_msg" cols="40" style="width:100%;"><%=(um.s_html_msg==null)?"":um.s_html_msg%></textarea>
								</td>
							</tr>
							<!-- Release 6.1: Remove AOL text input from Unsubscribe message creation and edit. -->

						</table>
						</form>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>
