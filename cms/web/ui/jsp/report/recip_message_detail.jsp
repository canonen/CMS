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
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// Connection


String sRequestXML = "";
String sListXML = "";

try
{
	String	sRecipID	= request.getParameter("recip_id");
	String	sMsgID	= request.getParameter("msg_id");

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
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script language="JavaScript" src="../../js/scripts.js"></script>
	<script language="JavaScript" src="../../js/tab_script.js"></script>
	<title>Recipient Campaign Message Detail</title>
	<script language="javascript">
		
		function toggleDetails(msg_id)
		{
			var oLink = document.getElementById("link_" + msg_id);
			var oRow = document.getElementById("row_" + msg_id);
			var oTable = document.getElementById("histTable");
			
			if (oRow.style.display == "")
			{
				oRow.style.display = "none";
				oLink.innerText = "+";
			}
			else
			{
				oRow.style.display = "";
				oLink.innerText = "-";
			
				if (oRow.rowIndex >= 3)
				{
					if (oTable.rows(oRow.rowIndex - 2).style.display == "")
					{
						oTable.rows(oRow.rowIndex - 2).scrollIntoView();
					}
					else
					{
						oTable.rows(oRow.rowIndex - 3).scrollIntoView();
					}
				}
			}
		}

		function window.onload()
		{
			self.focus();
			var typeID = document.getElementById("type_id");
			
			if (typeID.value != "5")
			{
			 	var cHTML = document.getElementById("contHTML");
			 	var cText = document.getElementById("contText");
			 	
				if (cHTML.value != "")
				{
					frameCont.document.body.innerHTML = cHTML.value;
				}
				else if (cText.value != "")
				{
					frameCont.document.body.innerText = cText.value;
				}
				else
				{
					frameCont.document.body.innerHTML = "<font face=Verdana size=2>No Content Selected</font>";
				}
			}
		}
		
	</script>
</HEAD>
<body>
<BODY>
<table cellspacing="0" cellpadding="0" border="0" class="" style="width:100%;">
	<col>
	<tr height="30">
		<td>
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="subactionbutton" href="#" onclick="window.close()">Cancel</a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%
Element eRecipList = XmlUtil.getRootElement(sListXML);
int nTotRecips = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_recips"));
int nTotReturned = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_returned"));

XmlElementList xelRecips = XmlUtil.getChildrenByName(eRecipList, "recipient");

Element eRecip = null;
String 	sEmail821 = "";
String 	sPnmGiven = "";
String 	sPnmFamily = "";


if (xelRecips.getLength() > 0)
{
	eRecip = (Element)xelRecips.item(0);
	sRecipID = XmlUtil.getChildCDataValue(eRecip,"recip_id");
	sEmail821 = XmlUtil.getChildCDataValue(eRecip,"email_821");
	sPnmGiven = XmlUtil.getChildCDataValue(eRecip,"pnmgiven");
	if (sPnmGiven == null)	sPnmGiven = "";
	sPnmFamily = XmlUtil.getChildCDataValue(eRecip,"pnmfamily");
	if (sPnmFamily == null)	sPnmFamily = "";

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
	String sEventDateTxt = "";	 
	String sEventSourceID = "";
	
	String sClassAppend = "";
			
	String sRequest = new String("<request><action>camp</action><recip_id>" + sRecipID + "</recip_id><cust_id>" + cust.s_cust_id + "</cust_id><msg_id>" + sMsgID + "</msg_id></request>");	
	
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
				
				if ("0".equals(sSampleID))
				{
					//nothing
				}
				else
				{
					sCampName = sCampName + " - Sample " + sSampleID;
				}
				
				String sOriginContID = "";
				String contHTML = "No Content";
				String contText = "No Content";
				
				byte[] b = null;

				if ((sContentID != null) && !("null".equals(sContentID)))
				{
					Statement			stmt = null;
					ResultSet			rs = null; 
					ConnectionPool		cp = null;
					Connection			conn = null;
					
					try
					{
						cp = ConnectionPool.getInstance();
						conn = cp.getConnection(this);
						stmt = conn.createStatement();
					
						rs = stmt.executeQuery("select origin_cont_id from ccnt_content with(nolock) where cont_id = '" + sContentID + "'");
						if (rs.next())
						{
							sOriginContID = rs.getString(1);
						}
						rs.close();
						
						sOriginContID = (sOriginContID != null)?sOriginContID:sContentID;
						
						if ((sOriginContID != null) && !sOriginContID.equalsIgnoreCase("null"))
						{
							rs = stmt.executeQuery("Exec dbo.usp_ccnt_info_get " + sOriginContID);
							if (rs.next())
							{
								contHTML = "No Content";
								contText = "No Content";
								
								b = rs.getBytes("HTML");				
								contHTML = (b==null)?"No Content":new String(b,"UTF-8");
								b = rs.getBytes("Text");
								contText = (b==null)?"No Content":new String(b,"UTF-8");
							}
							rs.close();
						}
						else
						{
							contHTML = "No Content";
							contText = "No Content";
						}
					}
					catch (Exception ex)
					{
						ErrLog.put(this, ex, "Error in " + this.getClass().getName() +"\r\n"+sListXML, out, 1);
					}
					finally
					{
						try
						{
							if( stmt  != null ) stmt.close();
						}
						catch (Exception ex2) { } 
						
						if( conn  != null ) cp.free(conn); 
					}
				}
				%>
	<tr>
		<td>
			<textarea id="contHTML" name="contHTML" style="display:none;"><%= HtmlUtil.escape(contHTML) %></textarea>
			<textarea id="contText" name="contText" style="display:none;"><%= HtmlUtil.escape(contText) %></textarea>
			<input type="hidden" name="type_id" id="type_id" value="<%= sTypeID %>">
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="listTable" style="width:100%;">
				<col width="150">
				<col width="150">
				<col>
				<tr height="20">
					<th class="Tab_ON" id="tab1_Step1" onclick="toggleTabs('tab1_Step','block1_Step',1,2,'Tab_ON','Tab_OFF');" valign="center" nowrap align="middle">Campaign Details</th>
					<th class="Tab_OFF" id="tab1_Step2" onclick="toggleTabs('tab1_Step','block1_Step',2,2,'Tab_ON','Tab_OFF');" valign="center" nowrap align="middle">Activities</th>
					<th class="Tab_OFF" valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></th>
				</tr>

				<tbody class="EditBlock" id="block1_Step1">
				<tr>
					<td class="" valign="top" align="left" colspan="3">
						<table class="table-soft" cellspacing="0" cellpadding="0" border="0" style="width:100%;">
							<col width="150">
							<col>
							<col width="110">
							<col width="130">
							<tr height="25">
								<td align="left" valign="middle"><b>Campaign:</b></td>
								<td align="left" valign="middle"><%= sCampName %></td>
								<td align="left" valign="middle"><b>Send Date:</b></td>
								<td align="left" valign="middle"><%= sSendDateTxt %></td>
							</tr>
							<tr height="25">
								<td align="left" valign="middle"><b>To:</b></td>
								<td align="left" valign="middle"><%= sPnmGiven %>&nbsp;<%= sPnmFamily %>&nbsp;[<%= sEmail821 %>]</td>
								<td align="left" valign="middle"><b>Campaign Type:</b></td>
								<td align="left" valign="middle">
									<%= ("2".equals(sTypeID))?"Standard":"" %>
									<%= ("3".equals(sTypeID))?"Send To Friend":"" %>
									<%= ("4".equals(sTypeID))?"Triggered":"" %>
									<%= ("5".equals(sTypeID))?"Web / DM / Call":"" %>
								</td>
							</tr>
							<%
							if (!("5".equals(sTypeID)))
							{
								%>
							<tr height="25">
								<td align="left" valign="middle"><b>From:</b></td>
								<td align="left" valign="middle" colspan="3"><%= sFromName %>&nbsp;[<%= sFromAddress %>]</td>
							</tr>
								<%
							}
							%>
							<tr height="25">
								<td align="left" valign="middle"><b>Target Group</b></td>
								<td align="left" valign="middle" colspan="3"><%= sFilterName %></td>
							</tr>
							<%
							if (!("5".equals(sTypeID)))
							{
								%>
							<tr height="25">
								<td align="left" valign="middle"><b>Subject:</b></td>
								<td align="left" valign="middle" colspan="3"><%= sSubjectLine %></td>
							</tr>
							<tr height="25">
								<td align="left" valign="middle"><b>Response Forwarding:</b></td>
								<td align="left" valign="middle" colspan="3"><%= sResponseForwarding %></td>
							</tr>
							<tr height="25">
								<td align="left" valign="middle"><b>Content:</b></td>
								<td align="left" valign="middle" colspan="3"><%= sContentName %></td>
							</tr>
							<tr>
								<td align="left" valign="middle" colspan="4">
									<iframe src="../header.html" frameborder="0" border="0" scrolling="auto" style="width:100%; height:100%;" id="frameCont"></iframe>
								</td>
							</tr>
								<%
							}
							else
							{
								%>
							<tr>
								<td align="left" valign="middle" colspan="4">&nbsp;</td>
							</tr>
								<%
							}
							%>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class="EditBlock" id="block1_Step2" style="display:none;">
				<tr>
					<td class="" valign="top" align="left" colspan="3">
						<table cellspacing="0" cellpadding="0" border="0" class="table-soft" style="width:100%;">
							<tr height="21">
								<td valign="bottom" align="center" style="padding:0px;">
									<table class="" cellspacing="0" cellpadding="0" style="width:100%;">
										<col>
										<col width="90">
										<col width="146">
										<tr height="21">
											<th><nobr>Activity</nobr></th>
											<th><nobr>Type</nobr></th>
											<th><nobr>Activity Date</nobr></th>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td valign="top" align="center" style="padding:0px;">
									<div style="width:100%; height:100%; overflow-y:scroll;">
									<table class="layout" cellspacing="0" cellpadding="2" style="width:100%;" id="histTable">
										<col>
										<col width="90">
										<col width="130">
				<%
				xelEvents = XmlUtil.getChildrenByName(eCamp, "event");
				eEvent = null;
				nCount = xelEvents.getLength();
				
				if (nCount > 0)
				{
					for (int n=0; n < nCount; n++)
					{
						if (n % 2 != 0) sClassAppend = "_other";
						else sClassAppend = "";
						
						sEventID 		= "";
						sEventTypeID 	= "";
						sEventName 		= "";
						sEventTypeName 	= "";
						sEventDateTxt 	= "";
						sEventSourceID 	= "";
						
						eEvent = (Element) xelEvents.item(n);
						
						sEventID 		= XmlUtil.getChildTextValue(eEvent, "event_id");
						sEventTypeID 	= XmlUtil.getChildTextValue(eEvent, "type_id");
						sEventName 		= XmlUtil.getChildCDataValue(eEvent, "event_name");
						sEventTypeName 	= XmlUtil.getChildCDataValue(eEvent, "event_type");
						sEventDateTxt 	= XmlUtil.getChildCDataValue(eEvent, "event_date_txt");
						sEventSourceID 	= XmlUtil.getChildTextValue(eEvent, "source_id");
						%>
										<tr>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><nobr><%= sEventName %></nobr></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><nobr><%= sEventTypeName %></nobr></td>
											<td class="list_row<%= sClassAppend %>" align="left" valign="middle"><nobr><%= sEventDateTxt %></nobr></td>
										</tr>
						<%
					}
				}
				else
				{
					%>
										<tr>
											<td class="listItem_Data" colspan="3">There are currently no activities for this Campaign Message for this Recipient.</td>
										</tr>
					<%
				}
				%>
									</table>
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
			<%
			}
		}
	}
	%>
	<%
}
else
{
	%>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
				<col>
				<tr height="2">
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center">
						<table class=main cellspacing=1 cellpadding=2 width="100%">
							<tr>
								<td align="center" valign="middle" style="padding:10px;">
									<b>Recipient Not Found!</b>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<%
}
%>
</table>
</body>
</html>
<%
}
catch (Exception ex)
{
	ErrLog.put(this, ex, "Error in " + this.getClass().getName() +"\r\n"+sListXML, out, 1);
}
%>
