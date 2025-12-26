<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.net.*,java.io.*,
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
<%
Statement			stmt = null;
ResultSet			rs = null; 
ConnectionPool		cp = null;
Connection			conn = null;

String sRequestXML = "";
String sListXML = "";
String sSyncDate = request.getParameter("sync_date");
String sSyncId = request.getParameter("sync_id");
String sDirection = request.getParameter("direction");

int syncCount = 0;

String sClassAppend = "";
%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<title>BriteConnect Chunk Status</title>
</HEAD>
<body>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="subactionbutton" href="briteconnect_daily.jsp"> &lt;&lt;&lt;BriteConnect</a>
		</td>
		<td vAlign="middle" align="left">
			<a class="subactionbutton" href="briteconnect_sync.jsp?direction=<%= sDirection %>&sync_date=<%=sSyncDate %>"> &lt;&lt;<%= sDirection %>: <%= sSyncDate %></a>
		</td>
	</tr>
</table>
<br>
<%
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("briteconnect_chunk.jsp");
	stmt = conn.createStatement();
	
     DocumentBuilder docb = DocumentBuilderFactory.newInstance().newDocumentBuilder();
	Document docXml = docb.newDocument();
     Element eRootOut = docXml.createElement("ChunkRequest");
     Element eTmp = XmlUtil.appendCDataChild(eRootOut, "cust_id", cust.s_cust_id);
     eTmp =  XmlUtil.appendCDataChild(eRootOut, "sync_id", sSyncId);
     eTmp =  XmlUtil.appendCDataChild(eRootOut, "direction", sDirection);
     docXml.appendChild(eRootOut);
     
     StringWriter swXml = new StringWriter();
     Transformer t = TransformerFactory.newInstance().newTransformer();
     t.transform(new DOMSource(docXml), new StreamResult(swXml));
     sRequestXML = swXml.toString();

//	sRequestXML += "<ChunkRequest>\r\n";
//	sRequestXML += "  <cust_id>"+cust.s_cust_id+"</cust_id>\r\n";
//	sRequestXML += "  <sync_id>"+sSyncId+"</sync_id>\r\n";
//	sRequestXML += "  <direction>"+sDirection+"</direction>\r\n";
//	sRequestXML += "</ChunkRequest>\r\n";
	
     Vector vSvcs = Services.getByType(ServiceType.RRCP_BRITECONNECT_CHUNK_STATUS);
     Service svc = (Service) vSvcs.get(0);
     svc.s_host = "localhost";
     sListXML = Service.communicate(svc,sRequestXML).trim();
//	sListXML = Service.communicate(ServiceType.RRCP_BRITECONNECT_CHUNK_STATUS, cust.s_cust_id, sRequestXML);
	
//	System.out.println(sListXML);
	Element eRoot = XmlUtil.getRootElement(sListXML);
	XmlElementList xelChunks = XmlUtil.getChildrenByName(eRoot, "Chunk");
	
	out.println("<table cellspacing=0 cellpadding=0 width=\"100%\" border=0>");
	out.println("	<tr>");
	out.println("		<td class=\"listHeading\" valign=\"center\" nowrap align=\"left\">");
	out.println("			Synchronization " + sDirection + ": " + sSyncDate + ": Sync ID " + sSyncId);
	out.println("			<br><br>");
	out.println("<table class=\"listTable\" border=0 cellspacing=0 cellpadding=2 width=\"100%\">");
	out.println("	<tr>");
	out.println("		<th>Chunk Id</th>");
	out.println("		<th>Chunk Type</th>");
	out.println("		<th>Qty</th>");
	out.println("		<th>Status</th>");
	out.println("		<th>Description</th>");
	out.println("		<th>Start</th>");
	out.println("		<th>End</th>");
	out.println("	</tr>");
	
	Element eChunk = null;
	String 	sChunkId = "";
	String 	sQty = "";
	String 	sTypeId = "";
	String 	sStatusId = "";
	String 	sStatusDesc = "";
	String	sStartDate = "";
	String	sEndDate = "";

	for (int n=0; n < xelChunks.getLength(); n++) {
		eChunk = (Element)xelChunks.item(n);
		sChunkId = XmlUtil.getChildCDataValue(eChunk,"chunk_id");
		sTypeId = XmlUtil.getChildCDataValue(eChunk,"type_id");
		sQty = XmlUtil.getChildCDataValue(eChunk,"qty");
		sStatusId = XmlUtil.getChildCDataValue(eChunk,"status_id");
		sStatusDesc = XmlUtil.getChildCDataValue(eChunk,"status_desc");
		if (sStatusDesc == null || sStatusDesc.equals("null")) sStatusDesc = "";
		sStartDate = XmlUtil.getChildCDataValue(eChunk,"start_date");
		sEndDate = XmlUtil.getChildCDataValue(eChunk,"end_date");
		if (sEndDate == null || sEndDate.equals("null")) sEndDate = "";
		
		if (syncCount % 2 != 0) sClassAppend = "_other";
		else sClassAppend = "";
		
		syncCount++;
		
		out.println("	<tr>");
		out.println("		<td class=\"list_row" + sClassAppend + "\"><a href=\"briteconnect_item.jsp?sync_id="+sSyncId+"&chunk_id="+sChunkId+"&direction="+sDirection+"&sync_date="+sSyncDate+"\">"+sChunkId+"</a></td>");
		out.println("		<td class=\"listItem_Data" + sClassAppend + "\">"+SyncObjectType.getDisplayName(Integer.parseInt(sTypeId))+"</td>");
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
	ErrLog.put(this,ex,"briteconnect_chunk.jsp",out,1);
} 
finally {
	try { if( stmt  != null ) stmt.close(); } 
	catch (Exception ex2) { } 
	if ( conn  != null ) cp.free(conn); 
}
%>
</body>
</html>



