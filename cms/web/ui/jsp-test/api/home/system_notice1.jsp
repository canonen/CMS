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
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>

<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
try
{
	String sClassAppend = "";

String sRequest = new String("<request><note_id></note_id></request>");
String sResponse = Service.communicate(ServiceType.SADM_SYSTEM_NOTE_INFO, cust.s_cust_id, sRequest);

Element eRoot = XmlUtil.getRootElement(sResponse);
JsonObject object = new JsonObject();
JsonArray array = new JsonArray();

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
					    object = new JsonObject();
						eNote = (Element) xelNotes.item(n);
						sNoteId = XmlUtil.getChildTextValue(eNote, "note_id");
						sSubject = XmlUtil.getChildTextValue(eNote, "subject");
						sDate = XmlUtil.getChildTextValue(eNote, "modify_date");

						object.put("noteId",sNoteId);
						object.put("subject",sSubject);
						object.put("date",sDate);

                        array.put(object);
					}
				}
        out.print(array);
}

}
catch(Exception ex)
{
	ErrLog.put(this,ex,"system_notice.jsp",out,1);
}
%>
