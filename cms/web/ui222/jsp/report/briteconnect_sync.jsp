<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.io.*,
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
	<title>BriteConnect Sync Status</title>
</HEAD>
<body>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="subactionbutton" href="briteconnect_daily.jsp"> &lt;&lt;&lt;BriteConnect</a>
		</td>
	</tr>
</table>
<br>
<%
Statement			stmt = null;
ResultSet			rs = null; 
ConnectionPool		cp = null;
Connection			conn = null;

String sRequestXML = "";
String sListXML = "";
String sSyncDate = request.getParameter("sync_date");
String sDirection = request.getParameter("direction");

int syncCount = 0;

String sClassAppend = "";

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("briteconnect_sync.jsp");
	stmt = conn.createStatement();
	
     DocumentBuilder docb = DocumentBuilderFactory.newInstance().newDocumentBuilder();
	Document docXml = docb.newDocument();
     Element eRootOut = docXml.createElement("SyncRequest");
     Element eTmp = XmlUtil.appendCDataChild(eRootOut, "cust_id", cust.s_cust_id);
     eTmp =  XmlUtil.appendCDataChild(eRootOut, "sync_date", sSyncDate);
     eTmp =  XmlUtil.appendCDataChild(eRootOut, "direction", sDirection);
     docXml.appendChild(eRootOut);
     
     StringWriter swXml = new StringWriter();
     Transformer t = TransformerFactory.newInstance().newTransformer();
     t.transform(new DOMSource(docXml), new StreamResult(swXml));
     sRequestXML = swXml.toString();

//	sRequestXML += "<SyncRequest>\r\n";
//	sRequestXML += "  <cust_id>"+cust.s_cust_id+"</cust_id>\r\n";
//	sRequestXML += "  <sync_date>"+sSyncDate+"</sync_date>\r\n";
//	sRequestXML += "  <direction>"+sDirection+"</direction>\r\n";
//	sRequestXML += "</SyncRequest>\r\n";
	
     Vector vSvcs = Services.getByType(ServiceType.RRCP_BRITECONNECT_SYNC_STATUS);
     Service svc = (Service) vSvcs.get(0);
     svc.s_host = "localhost";
     sListXML = Service.communicate(svc,sRequestXML).trim();
//	sListXML = Service.communicate(ServiceType.RRCP_BRITECONNECT_SYNC_STATUS, cust.s_cust_id, sRequestXML);
logger.info("from RCP for sync:" + sListXML);
	
	Element eRoot = XmlUtil.getRootElement(sListXML);
	XmlElementList xelSyncs = XmlUtil.getChildrenByName(eRoot, "Sync");
	
	out.println("<table cellspacing=0 cellpadding=0 width=\"100%\" border=0>");
	out.println("	<tr>");
	out.println("		<td class=\"listHeading\" valign=\"center\" nowrap align=\"left\">");
	out.println("			Synchronization " + sDirection + ": " + sSyncDate);
	out.println("			<br><br>");
	out.println("<table class=\"listTable\" width=\"100%\" border=0 cellspacing=0 cellpadding=2>");
	out.println("	<tr>");
	out.println("		<th>Sync Id</th>");
	out.println("		<th>Sync Type</th>");
	out.println("		<th>Qty</th>");
	out.println("		<th>Status</th>");
	out.println("		<th>Description</th>");
	out.println("		<th>Start</th>");
	out.println("		<th>End</th>");
	out.println("	</tr>");
	
	Element eSync = null;
	String 	sSyncId = "";
	String 	sTypeId = "";
	String 	sStatusId = "";
	String 	sStatusDesc = "";
	String	sStartDate = "";
	String	sEndDate = "";
	String	sQty = "";

	for (int n=0; n < xelSyncs.getLength(); n++) {
		eSync = (Element)xelSyncs.item(n);
		sSyncId = XmlUtil.getChildCDataValue(eSync,"sync_id");
		sTypeId = XmlUtil.getChildCDataValue(eSync,"type_id");
		sStatusId = XmlUtil.getChildCDataValue(eSync,"status_id");
		sStatusDesc = XmlUtil.getChildCDataValue(eSync,"status_desc");
		if (sStatusDesc == null || sStatusDesc.equals("null")) sStatusDesc = "";
		sStartDate = XmlUtil.getChildCDataValue(eSync,"start_date");
		sEndDate = XmlUtil.getChildCDataValue(eSync,"end_date");
		if (sEndDate == null || sEndDate.equals("null")) sEndDate = "";
		sQty = XmlUtil.getChildCDataValue(eSync,"qty");
		
		if (syncCount % 2 != 0) sClassAppend = "_Alt";
		else sClassAppend = "";
		
		syncCount++;
		
		out.println("	<tr>");
		out.println("		<td class=\"listItem_Title" + sClassAppend + "\"><a href=\"briteconnect_chunk.jsp?sync_id="+sSyncId+"&direction="+sDirection+"&sync_date="+sSyncDate+"\">"+sSyncId+"</a></td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+SyncType.getDisplayName(Integer.parseInt(sTypeId))+"</td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+sQty+"</td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+SyncStatus.getDisplayName(Integer.parseInt(sStatusId))+"</td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+sStatusDesc+"</td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+sStartDate+"</td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+sEndDate+"</td>");
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
	ErrLog.put(this,ex,"briteconnect_sync.jsp",out,1);
} 
finally {
	try { if( stmt  != null ) stmt.close(); } 
	catch (Exception ex2) { } 
	if ( conn  != null ) cp.free(conn); 
}
%>
</body>
</html>



