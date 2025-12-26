<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			javax.xml.transform.stream.*,
			javax.xml.transform.dom.*,
			javax.xml.parsers.*,
			javax.xml.transform.*,
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

AccessPermission can2 = user.getAccessPermission(ObjectType.RECIPIENT);

boolean bCanRead = can.bRead && can2.bRead;

if(!bCanRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<title>BriteConnect Daily Status</title>
</HEAD>
<body>
<%
Statement			stmt = null;
ResultSet			rs = null; 
ConnectionPool		cp = null;
Connection			conn = null;

String sRequestXML = "";
String sListXML = "";
String sDirection = "";

int syncCount = 0;

String sClassAppend = "";

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("briteconnect_sync.jsp");
	stmt = conn.createStatement();
	
	/* ToCust Daily Status */
	sDirection = "ToCust";
     sRequestXML = "";
     DocumentBuilder docb = DocumentBuilderFactory.newInstance().newDocumentBuilder();
	Document docXml = docb.newDocument();
     Element eRootOut = docXml.createElement("DailyRequest");
     Element eTmp = XmlUtil.appendCDataChild(eRootOut, "cust_id", cust.s_cust_id);
     eTmp =  XmlUtil.appendCDataChild(eRootOut, "direction", sDirection);
     docXml.appendChild(eRootOut);
     
     StringWriter swXml = new StringWriter();
     Transformer t = TransformerFactory.newInstance().newTransformer();
     t.transform(new DOMSource(docXml), new StreamResult(swXml));
     sRequestXML = swXml.toString();

//	sRequestXML += "<DailyRequest>\r\n";
//	sRequestXML += "  <cust_id>"+cust.s_cust_id+"</cust_id>\r\n";
//	sRequestXML += "  <direction>"+sDirection+"</direction>\r\n";
//	sRequestXML += "</DailyRequest>\r\n";

     Vector vSvcs = Services.getByType(ServiceType.RRCP_BRITECONNECT_DAILY_STATUS);
     Service svc = (Service) vSvcs.get(0);
     svc.s_host = "localhost";
     sListXML = Service.communicate(svc,sRequestXML).trim();
	
	//sListXML = Service.communicate(ServiceType.RRCP_BRITECONNECT_DAILY_STATUS, cust.s_cust_id, sRequestXML);
     //System.out.println("XML string received from RCP briteconnect_daily_status (ToCust):" + sListXML);

	Element eRoot = XmlUtil.getRootElement(sListXML);
	XmlElementList xelDailys = XmlUtil.getChildrenByName(eRoot, "Daily");
	
	out.println("<table cellspacing=0 cellpadding=0 width=\"100%\" border=0>");
	out.println("	<tr>");
	out.println("		<td class=\"listHeading\" valign=\"center\" nowrap align=\"left\">");
	out.println("			Synchronization To Customer");
	out.println("			<br><br>");
	out.println("<table class=\"listTable\" width=\"100%\" border=0 cellspacing=0 cellpadding=2>");
	out.println("	<tr>");
	out.println("		<th>Date</th>");
	out.println("		<th>Number Sent</th>");
	out.println("		<th>Number Processed</th>");
	out.println("		<th>Number Error</th>");
	out.println("	</tr>");
	
	Element eDaily = null;
	String 	sSyncDate = "";
	String 	sTotal = "";
	String 	sGood = "";
	String 	sBad = "";

	for (int n=0; n < xelDailys.getLength(); n++) {
		eDaily = (Element)xelDailys.item(n);
		sSyncDate = XmlUtil.getChildCDataValue(eDaily,"sync_date");
		sTotal = XmlUtil.getChildCDataValue(eDaily,"total");
		sGood = XmlUtil.getChildCDataValue(eDaily,"good");
		sBad = XmlUtil.getChildCDataValue(eDaily,"bad");
		
		if (syncCount % 2 != 0) sClassAppend = "_Alt";
		else sClassAppend = "";
		
		syncCount++;
		
		out.println("	<tr>");
		out.println("		<td class=\"listItem_Title" + sClassAppend + "\"><a href=\"briteconnect_sync.jsp?direction="+sDirection+"&sync_date="+sSyncDate+"\">"+sSyncDate+"</a></td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+sTotal+"</td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+sGood+"</td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+sBad+"</td>");
		out.println("	</tr>");
	}
	
	if (syncCount == 0)
	{
		out.println("	<tr>");
		out.println("		<td colspan=4 class=\"listItem_Data\">There have been no synchronizations to the Customer.</td>");
		out.println("	</tr>");
	}
	out.println("</table>");
	out.println("		</td>");
	out.println("	</tr>");
	out.println("</table>");
	out.println("<br>");

	/* FromCust Daily Status */
	sDirection = "FromCust";
     sRequestXML = "";
//     docb = DocumentBuilderFactory.newInstance().newDocumentBuilder();
	docXml = docb.newDocument();
     eRootOut = docXml.createElement("DailyRequest");
     eTmp = XmlUtil.appendCDataChild(eRootOut, "cust_id", cust.s_cust_id);
     eTmp =  XmlUtil.appendCDataChild(eRootOut, "direction", sDirection);
     docXml.appendChild(eRootOut);
     
     swXml = new StringWriter();
//     Transformer t = TransformerFactory.newInstance().newTransformer();
     t.transform(new DOMSource(docXml), new StreamResult(swXml));
     sRequestXML = swXml.toString();

//	sRequestXML += "<DailyRequest>\r\n";
//	sRequestXML += "  <cust_id>"+cust.s_cust_id+"</cust_id>\r\n";
//	sRequestXML += "  <direction>"+sDirection+"</direction>\r\n";
//	sRequestXML += "</DailyRequest>\r\n";
	
     sListXML = Service.communicate(svc,sRequestXML).trim();
//	sListXML = Service.communicate(ServiceType.RRCP_BRITECONNECT_DAILY_STATUS, cust.s_cust_id, sRequestXML);
     //StdLog.put(this,"XML string received from RCP briteconnect_daily_status (FromCust):" + sListXML);
	eRoot = XmlUtil.getRootElement(sListXML);
	xelDailys = XmlUtil.getChildrenByName(eRoot, "Daily");
	
	out.println("<table cellspacing=0 cellpadding=0 width=\"100%\" border=0>");
	out.println("	<tr>");
	out.println("		<td class=\"listHeading\" valign=\"center\" nowrap align=\"left\">");
	out.println("			Synchronization From Customer");
	out.println("			<br><br>");
	out.println("<table class=\"listTable\" width=\"100%\" border=0 cellspacing=0 cellpadding=2>");
	out.println("	<tr>");
	out.println("		<th>Date</th>");
	out.println("		<th>Number Received</th>");
	out.println("		<th>Number Processed</th>");
	out.println("		<th>Number Error</th>");
	out.println("	</tr>");
	
	eDaily = null;
	sSyncDate = "";
	sTotal = "";
	sGood = "";
	sBad = "";
	
	syncCount = 0;

	for (int n=0; n < xelDailys.getLength(); n++) {
		eDaily = (Element)xelDailys.item(n);
		sSyncDate = XmlUtil.getChildCDataValue(eDaily,"sync_date");
		sTotal = XmlUtil.getChildCDataValue(eDaily,"total");
		sGood = XmlUtil.getChildCDataValue(eDaily,"good");
		sBad = XmlUtil.getChildCDataValue(eDaily,"bad");
		
		if (syncCount % 2 != 0) sClassAppend = "_Alt";
		else sClassAppend = "";
		
		syncCount++;
		
		out.println("	<tr>");
		out.println("		<td class=\"listItem_Title" + sClassAppend + "\"><a href=\"briteconnect_sync.jsp?direction="+sDirection+"&sync_date="+sSyncDate+"\">"+sSyncDate+"</a></td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+sTotal+"</td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+sGood+"</td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+sBad+"</td>");
		out.println("	</tr>");
	}
	
	if (syncCount == 0)
	{
		out.println("	<tr>");
		out.println("		<td colspan=4 class=\"listItem_Data\">There have been no synchronizations from the Customer.</td>");
		out.println("	</tr>");
	}
	out.println("</table>");
	out.println("		</td>");
	out.println("	</tr>");
	out.println("</table>");
	out.println("<br>");
	out.println("<br>");
}
catch (Exception ex) {
	ErrLog.put(this,ex,"briteconnect_daily.jsp",out,1);
	out.println("<br>");
	out.println("<table class=\"listTable\" width=\"90%\" border=0 cellspacing=0 cellpadding=2>");
	out.println("	<tr>");
	out.println("		<th>Not Enabled</th>");
	out.println("	</tr>");
	out.println("	<tr>");
	out.println("		<td colspan=4 class=\"listItem_Data\">This module is not enabled for your system. Please contact <a target=\"_parent\" href=\"../index.jsp?tab=Help&sec=4\">Technical Support</a> with any questions about the BriteConnect database synchronization module.</td>");
	out.println("	</tr>");
	out.println("</table>");
	out.println("<br>");
	out.println("<br>");
    logger.error("Exception: ",ex);
} 
finally {
	try { if( stmt  != null ) stmt.close(); } 
	catch (Exception ex2) { } 
	if ( conn  != null ) cp.free(conn); 
}
%>
</body>
</html>



