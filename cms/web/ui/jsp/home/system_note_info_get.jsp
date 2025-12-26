<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.hom.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
//check if in pop up or not
String inWin = request.getParameter("win");
if (inWin == null) inWin = "false";
	
%>
<html>
<head>
<title>Previous System Announcement</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="JavaScript" src="../../js/scripts.js"></script>
<script language="JavaScript" src="../../js/tab_script.js"></script>
<script language="JavaScript">
	
	function loadSysAnnounce()
	{
		var newWin;
        var url = "system_notice.jsp";
        var windowName = "system_announcements";
		var windowFeatures = "depedent=yes, scrollbars=no, resizable=yes, toolbar=no, location=no, menubar=no, height=400, width=550";
		newWin = window.open(url, windowName, windowFeatures);
	}
	
	function loadSysNote(note_id)
	{
		var newWin;
        var url = "system_note_info_get.jsp?win=true&note_id=" + note_id;
        var windowName = "system_announcements";
		var windowFeatures = "depedent=yes, scrollbars=no, resizable=yes, toolbar=no, location=no, menubar=no, height=400, width=550";
		newWin = window.open(url, windowName, windowFeatures);
	}
	
</script>
<style>
body {
margin:0;
}
</style>
</head>
<body<% if ("false".equals(inWin)) { %> leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" style="padding:0px;"<% } %>>
<%
String sNoteId = request.getParameter("note_id");

if (sNoteId != null)
{
	String sRequest = new String("<request><note_id>"+sNoteId+"</note_id></request>");
	String sResponse = Service.communicate(ServiceType.SADM_SYSTEM_NOTE_INFO, cust.s_cust_id, sRequest);      
	
	Element eRoot = XmlUtil.getRootElement(sResponse);        
	
	if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
	{
		String s_note_id = XmlUtil.getChildTextValue(eRoot, "note_id");
		String s_modify_date = XmlUtil.getChildTextValue(eRoot, "modify_date");
		String s_subject = XmlUtil.getChildTextValue(eRoot, "subject");
		String s_body = XmlUtil.getChildCDataValue(eRoot, "body");
		%>
		<table cellspacing="0" cellpadding="0" width="100%" border="0">
			<tr>
				<td valign="center" nowrap align="left">
					<table cellspacing="0" cellpadding="0" border="0" class="listTable" style="width:100%;">
						
						<tr>
							<th class="SystemMenuBar" align="left" valign="middle">
								System Announcement
							</th>
						</tr>
						<tr>
							<td align="left" valign="middle"><div style="font-weight:bold;color:#21759B"><nobr><%= s_subject %></nobr></div></td>
						</tr>
						<tr>
							<td align="left" valign="top" style="padding-top:0;">
								<div class="scrollbox">
									<%= s_body %>
								</div>
							</td>
						</tr>
						<tr height="25">
					<%
					if ("false".equals(inWin))
					{
						%>
							<td align="left" valign="bottom" colspan=2>
								<a href="javascript:loadSysNote('<%= sNoteId %>');" class="button_res">Read More</a>
								<a href="javascript:loadSysAnnounce();" class="button_res">Past Announcements</a>
							</td>
							
						<%
					}
					else
					{
						%>
							<td align="right" valign="bottom">
								&nbsp;<a href="javascript:loadSysAnnounce();" class="button_res">Past Announcements</a>&nbsp;
							</td>
						<%
					}
					%>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<%
	}
}
else
{
	%>
		<table cellspacing="0" cellpadding="0" width="100%" height="100%" border="0">
			<tr>
				<td colspan="2">There are currently no system notices</td>
			</tr>
		</table>
	<%
}
%>
</body>
</html>