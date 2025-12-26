<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.net.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
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

AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT);
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sFrom	= "";
sFrom			= request.getParameter("from");

if ((sFrom == null) || ("".equals(sFrom)))
{
	sFrom = "";
}

String sRequestXML = "";
String sListXML = "";

try
{
	String	sRecipID	= request.getParameter("recip_id");

	String sFields = " recip_id, email_821, pnmgiven, pnmfamily";
	String sAttrList = "1,6,18,16";

	sRequestXML += "<RecipRequest>\r\n";
	sRequestXML += "<action>EdtDetail</action>\r\n";
	sRequestXML += "<cust_id>"+cust.s_cust_id+"</cust_id>\r\n";
	sRequestXML += "<recip_id>"+sRecipID+"</recip_id>\r\n";	
	sRequestXML += "<num_recips>1</num_recips>\r\n";
	sRequestXML += "<attr_list>"+sAttrList+"</attr_list>\r\n";
	sRequestXML += "</RecipRequest>\r\n";
	
	sListXML = Service.communicate(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id, sRequestXML);
%>
<%
Element eRecipList = XmlUtil.getRootElement(sListXML);
int nTotRecips = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_recips"));
int nTotReturned = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_returned"));

XmlElementList xelRecips = XmlUtil.getChildrenByName(eRecipList, "recipient");

JsonObject data = new JsonObject();

JsonArray dataArray = new JsonArray();
JsonArray dataArray1 = new JsonArray();


Element eRecip = null;
String 	sEmail821 = "";
String 	sPNmGiven = "";
String 	sPNmFamily = "";


if (xelRecips.getLength() > 0)
{
	eRecip = (Element)xelRecips.item(0);
	sRecipID = XmlUtil.getChildCDataValue(eRecip,"recip_id");
	sEmail821 = XmlUtil.getChildCDataValue(eRecip,"email_821");
	sPNmGiven = XmlUtil.getChildCDataValue(eRecip,"pnmgiven");
	if (sPNmGiven == null)	sPNmGiven = "";
	sPNmFamily = XmlUtil.getChildCDataValue(eRecip,"pnmfamily");
	if (sPNmFamily == null)	sPNmFamily = "";
	data.put("recip_id",sRecipID);
	data.put("email_821",sEmail821);
	data.put("pnmgiven",sPNmGiven);
	data.put("pnmfamily",sPNmFamily);
	dataArray.put(data);

	String sMsgID = "";
	String sCampID = "";
	String sSendDate = "";
	String sSendDateTxt = "";
	String iReceived = "";
	String iBBack = "";
	String iUnsub = "";
	String iOpen = "";
	String iClick = "";
	String iVisit = "";
	String iSubs = "";
									
	String sOriginCampID = "";
	String sSampleID = "";
	String sTypeID = "";
	String sCampName = "";
	String sFromName = "";
	String sFromAddress = "";
	String sContentID = "";
	String sContentName = "";
	String sFilterID = "";
	String sFilterName = "";
	String sResponseForwarding = "";
	String sSubjectLine = "";
									
	String sEventID = "";
	String sEventName = "";
	String sEventTypeID = "";
	String sEventTypeName = "";
	String sEventDate = "";
	String sEventSourceID = "";
									
	String sClassAppend = "";

											
	String sRequest = new String("<request><action>camp</action><recip_id>" + sRecipID + "</recip_id><cust_id>" + cust.s_cust_id + "</cust_id><msg_id></msg_id></request>");
									
	String sResponse = Service.communicate(ServiceType.CCPS_RECIP_HISTORY_GET, cust.s_cust_id, sRequest);
	Element eRoot = XmlUtil.getRootElement(sResponse);

	if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
	{
		XmlElementList xelEvents = null;
		Element eEvent = null;
		int nCount = 0;
										
		XmlElementList xelCamps = XmlUtil.getChildrenByName(eRoot, "message");
		Element eCamp = null;
		int tCount = xelCamps.getLength();
									
		if (tCount > 0)
		{
			for (int t=0; t < tCount; t++)
			{
				data = new JsonObject();
				if (t % 2 != 0) sClassAppend = "_other";
				else sClassAppend = "";
												
				sMsgID = "";
				sCampID = "";
				sSendDate = "";
				sSendDateTxt = "";
				iReceived = "";
				iBBack = "";
				iUnsub = "";
				iOpen = "";
				iClick = "";
				iVisit = "";
				iSubs = "";
												
				sOriginCampID = "";
				sSampleID = "";
				sTypeID = "";
				sCampName = "";
				sFromName = "";
				sFromAddress = "";
				sContentID = "";
				sContentName = "";
				sFilterID = "";
				sFilterName = "";
				sResponseForwarding = "";
				sSubjectLine = "";
												
				eCamp = (Element) xelCamps.item(t);
												
				sMsgID 		= XmlUtil.getChildTextValue(eCamp, "msg_id");
				sCampID 	= XmlUtil.getChildTextValue(eCamp, "camp_id");
				sSendDate 	= XmlUtil.getChildCDataValue(eCamp, "send_date");
				sSendDateTxt = XmlUtil.getChildCDataValue(eCamp, "send_date_txt");
				iReceived 	= XmlUtil.getChildTextValue(eCamp, "received");
				iBBack 		= XmlUtil.getChildTextValue(eCamp, "bback");
				iUnsub 		= XmlUtil.getChildTextValue(eCamp, "unsub");
				iOpen 		= XmlUtil.getChildTextValue(eCamp, "read_qty");
				iClick 		= XmlUtil.getChildTextValue(eCamp, "click_qty");
				iVisit 		= XmlUtil.getChildTextValue(eCamp, "visit_qty");
				iSubs 		= XmlUtil.getChildTextValue(eCamp, "sub_qty");
												
				sOriginCampID 			= XmlUtil.getChildTextValue(eCamp, "origin_camp_id");
				sSampleID 				= XmlUtil.getChildTextValue(eCamp, "sample_id");
				sTypeID 				= XmlUtil.getChildTextValue(eCamp, "type_id");
				sCampName 				= XmlUtil.getChildCDataValue(eCamp, "camp_name");
				sFromName 				= XmlUtil.getChildCDataValue(eCamp, "from_name");
				sFromAddress 			= XmlUtil.getChildCDataValue(eCamp, "from_address");
				sContentID 				= XmlUtil.getChildTextValue(eCamp, "cont_id");
				sContentName 			= XmlUtil.getChildCDataValue(eCamp, "cont_name");
				sFilterID 				= XmlUtil.getChildTextValue(eCamp, "filter_id");
				sFilterName 			= XmlUtil.getChildCDataValue(eCamp, "filter_name");
				sResponseForwarding 	= XmlUtil.getChildCDataValue(eCamp, "response_forwarding");
				sSubjectLine 			= XmlUtil.getChildCDataValue(eCamp, "subject_html");

				data.put("sMsgID",sMsgID);
				data.put("sCampID",sCampID);
				data.put("sSendDate",sSendDate);
				data.put("sSendDate",sSendDate);
				data.put("sSendDateTxt",sSendDateTxt);
				data.put("iReceived",iReceived);
				data.put("iBBack",iBBack);
				data.put("iUnsub",iUnsub);
				data.put("iOpen",iOpen);
				data.put("iClick",iClick);
				data.put("iVisit",iVisit);
				data.put("iSubs",iSubs);
				data.put("sOriginCampID",sOriginCampID);

				data.put("sSampleID",sSampleID);
				data.put("sTypeID",sTypeID);
				data.put("sCampName",sCampName);
				data.put("sFromName",sFromName);
				data.put("sFromAddress",sFromAddress);
				data.put("sContentID",sContentID);
				data.put("sContentName",sContentName);
				data.put("sFilterID",sFilterID);
				data.put("sFilterName",sFilterName);
				data.put("sResponseForwarding",sResponseForwarding);
				data.put("sSubjectLine",sSubjectLine);
				dataArray1.put(data);
			}

		}

	}



}
	dataArray.put(dataArray1);
	out.println(dataArray.toString());

%>

<%
}

catch (Exception ex)
{
	ErrLog.put(this, ex, "Error in " + this.getClass().getName() +"\r\n"+sListXML, out, 1);
}
%>
