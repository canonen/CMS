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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%

if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
	JsonObject data =new JsonObject();
	JsonArray array = new JsonArray();
//check if in pop up or not
String inWin = request.getParameter("win");
if (inWin == null) inWin = "false";

	String sNoteId = request.getParameter("note_id");
	System.out.println(sNoteId);

	if (sNoteId != null) {
		String sRequest = new String("<request><note_id>" + sNoteId + "</note_id></request>");
		String sResponse = Service.communicate(ServiceType.SADM_SYSTEM_NOTE_INFO, cust.s_cust_id, sRequest);
		System.out.println(sResponse);
		Element eRoot = XmlUtil.getRootElement(sResponse);
		System.out.println(eRoot);
		

	if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR")) {
		String s_note_id = XmlUtil.getChildTextValue(eRoot, "note_id");
		String s_modify_date = XmlUtil.getChildTextValue(eRoot, "modify_date");
		String s_modify_date_format = s_modify_date.substring(0, 11);
		String s_subject = XmlUtil.getChildTextValue(eRoot, "subject");
		String s_body = XmlUtil.getChildCDataValue(eRoot, "body");
		data.put("s_subject", s_subject);
		data.put("s_body", s_body);
		data.put("sNoteId", sNoteId);
		data.put("s_modify_date", s_modify_date_format);

	}}else
	{
		String noPastSystemAnnouncementsMessage="There are currently no past system announcements";
		data.put("no past system announcements message",noPastSystemAnnouncementsMessage);
	}
		array.put(data);
		out.println(array);
	
%>
