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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
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
	JsonObject data =new JsonObject();
	JsonArray array = new JsonArray();
	String sClassAppend = "";

String sRequest = new String("<request><note_id></note_id></request>");
String sResponse = Service.communicate(ServiceType.SADM_SYSTEM_NOTE_INFO, cust.s_cust_id, sRequest);      
//System.out.println("xml=" + sResponse);
Element eRoot = XmlUtil.getRootElement(sResponse);        
if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
{
	String note_id = XmlUtil.getChildTextValue(eRoot, "note_id");
	XmlElementList xelNotes = XmlUtil.getChildrenByName(eRoot, "PreviousNote");
	Element eNote = null;
	String sNoteId = "";
	String sSubject = "";
	String sDate = "";
	int nCount = xelNotes.getLength();
	if (nCount > 0)
	{
		for (int n=0; n < nCount; n++)
	{
		eNote = (Element) xelNotes.item(n);
		sNoteId = XmlUtil.getChildTextValue(eNote, "note_id");
		sSubject = XmlUtil.getChildTextValue(eNote, "subject");
		sDate = XmlUtil.getChildTextValue(eNote, "modify_date");

		if (n % 2 != 0) sClassAppend = "_Alt";
		else sClassAppend = "";
		data.put("sNoteId",sNoteId);
		data.put("sSubject",sSubject);
		data.put("sDate",sDate);
	}}else
		{
			String noPastSystemAnnouncementsMessage="There are currently no past system announcements";
			data.put("no past system announcements message",noPastSystemAnnouncementsMessage);
		}

	}
	array.put(data);
	out.println(array);
}catch(Exception ex)
{
	ErrLog.put(this,ex,"system_notice.jsp",out,1);
};
%>
