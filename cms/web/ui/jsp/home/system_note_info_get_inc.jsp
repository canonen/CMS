<%

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
		
		<table cellpadding="0" cellspacing="0" width="100%" class="welcome-boxes">
			<tr bgcolor="#696969">
				<th>Announcement</th>
			</tr>
			<tr>
				<td>
					<div><%= s_subject %></div>
					<div><%= s_body %></div>
				</td>
			</tr>
			<tr>
				<td>
					<a href="javascript:loadSysNote('<%= sNoteId %>');" class="button_res">Read More</a>
					<a href="javascript:loadSysAnnounce();" class="button_res">Past Announcements</a>
				</td>
			</tr>
		</table>
								
		<%
	}
}
else
{
	%>
		<table cellpadding="0" cellspacing="0" width="100%" class="welcome-boxes">
			<tr bgcolor="#696969">
				<th>Announcement</th>
			</tr>
			<tr>
				<td>There are currently no system notices</td>
			</tr>
		</table>
	<%
}
%>