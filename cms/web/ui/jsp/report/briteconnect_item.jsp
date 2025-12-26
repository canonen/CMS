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

// === === ===

String sSyncDate = request.getParameter("sync_date");
String sSyncId = request.getParameter("sync_id");
String sChunkId = request.getParameter("chunk_id");
String sDirection = request.getParameter("direction");
%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<title>BriteConnect Item Status</title>
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
		<td vAlign="middle" align="left">
			<a class="subactionbutton" href="briteconnect_chunk.jsp?direction=<%= sDirection %>&sync_date=<%=sSyncDate %>&sync_id=<%=sSyncId %>"> &lt;Sync ID <%= sSyncId %></a>
		</td>
	</tr>
</table>
<br>
<%
	String sRequestXML =
		"<ItemRequest>" +
		"<cust_id><![CDATA["+cust.s_cust_id+"]]></cust_id>" + 
		"<chunk_id><![CDATA["+sChunkId+"]]></chunk_id>" +
		"<direction><![CDATA["+sDirection+"]]></direction>" +
		"</ItemRequest>";

/*	
	Vector vSvcs = Services.getByType(ServiceType.RRCP_BRITECONNECT_ITEM_STATUS);
	Service service = (Service) vSvcs.get(0);
	service.s_host = "localhost";
	String sListXML = service.communicate(sRequestXML);
	sListXML = sListXML.trim();
*/	
	String sListXML = Service.communicate(ServiceType.RRCP_BRITECONNECT_ITEM_STATUS, cust.s_cust_id, sRequestXML);
	
	Element eRoot = XmlUtil.getRootElement(sListXML);
	XmlElementList xelItems = XmlUtil.getChildrenByName(eRoot, "Item");
%>
<table cellspacing=0 cellpadding=0 width="100%" border=0>
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Synchronization <%=sDirection%>: <%=sSyncDate%>: Sync ID <%=sSyncId%>: Chunk ID <%=sChunkId%>
			<br><br>

<table class="listTable" width="100%" border=0 cellspacing=0 cellpadding=2>
	<tr>
		<th>Object Type</th>
		<th>Object ID<br>(N/A for recipients)</th>
		<th>Name</th>
	</tr>
<%
	Element eItem = null;
	String 	sTypeId = null;
	String 	sItemId = null;
	String 	sName = null;

	for (int n=0; n < xelItems.getLength(); n++)
	{
		eItem = (Element)xelItems.item(n);
		sTypeId = XmlUtil.getChildCDataValue(eItem,"type_id");
		sItemId = XmlUtil.getChildCDataValue(eItem,"item_id");
		sName = XmlUtil.getChildCDataValue(eItem,"name");
%>
		<tr>
			<td><%=SyncObjectType.getDisplayName(Integer.parseInt(sTypeId))%></td>
			<td><%=sItemId%></td>
			<td><%=sName%></td>
		</tr>
<%
	}
%>
</table>

		</td>
	</tr>
</table>
<br>
<br>
</body>
</html>



