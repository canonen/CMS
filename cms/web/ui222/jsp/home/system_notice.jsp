<%@ page

	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.imc.*,
		com.britemoon.cps.que.*,
		com.britemoon.cps.ctl.*,
		java.util.*,java.sql.*,
		java.net.*,java.text.DateFormat,
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
try
{
	String sClassAppend = "";
%>
<html>
<head>
<title>Previous System Announcements</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="JavaScript" src="../../js/scripts.js"></script>
<script language="JavaScript" src="../../js/tab_script.js"></script>
<script language="JavaScript">

	function showSystemNote(noteId)
	{
		if (noteId == "") return;
		var newWin;
        var url = 'system_note_info_get.jsp?win=true&note_id='+noteId;
        var windowName = 'system_note';
		var windowFeatures = 'depedent=yes, scrollbars=yes, resizable=yes, toolbar=no, location=no, menubar=no, height=500, width=650';
		//newWin = window.open(url, windowName, windowFeatures);
		location.href = url;
	}
	
</script>
</head>
<body>
<%
String sRequest = new String("<request><note_id></note_id></request>");
String sResponse = Service.communicate(ServiceType.SADM_SYSTEM_NOTE_INFO, cust.s_cust_id, sRequest);      
//System.out.println("xml=" + sResponse);
Element eRoot = XmlUtil.getRootElement(sResponse);        
if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
{
	String note_id = XmlUtil.getChildTextValue(eRoot, "note_id");			
	%>
	<table cellspacing="0" cellpadding="0" width="100%" border="0">
		<tr>
			<td class="listHeading" valign="center" nowrap align="left">
				Previous System Announcements
				<br><br>
				<table class="listTable" cellpadding="2" cellspacing="0" border="0" width="100%">
					<tr>
						<th align="left" valign="middle" width=100%>Subject</th>
						<th align="left" valign="middle" nowrap>Date</th>
					</tr>
				<%
				XmlElementList xelNotes = XmlUtil.getChildrenByName(eRoot, "PreviousNote");
				Element eNote = null;
				String sNoteId = "";
				String sSubject = "";
				String sDate = "";
				int nCount = xelNotes.getLength();
				if (nCount > 0)
				{
					%>
					<% 
					for (int n=0; n < nCount; n++)
					{
						eNote = (Element) xelNotes.item(n);
						sNoteId = XmlUtil.getChildTextValue(eNote, "note_id");
						sSubject = XmlUtil.getChildTextValue(eNote, "subject");
						sDate = XmlUtil.getChildTextValue(eNote, "modify_date");
						
						if (n % 2 != 0) sClassAppend = "_Alt";
						else sClassAppend = "";      
						%>
						<tr>
							<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width=100%><a href="javascript:showSystemNote('<%=sNoteId%>')"><%=sSubject%></a></td>
							<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" nowrap><%=sDate%></td>
						</tr>
						<%
					}
					%>
					</table>
					<%
				}
				else
				{
					%>
						<tr>
							<td class="listItem_Data" align="left" valign="middle" nowrap>There are currently no past system announcements.</td>
						</tr>
					<%
				}
				%>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>
</body>
</html>
<%
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex,"system_notice.jsp",out,1);	
}
%>
