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
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<title>Recipient Campaign History</title>
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
		
		function popMessageDetails(msg_id)
		{
			var url = "recip_message_detail.jsp?recip_id=<%= sRecipID %>&msg_id=" + msg_id;
			var windowName = 'message_detail_window';
			var windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, location=no, height=600, width=700';
			var MsgWin = window.open(url, windowName, windowFeatures);
		}
		
	</script>
</HEAD>
<body onload="self.focus();">
<BODY>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
	<tr height="30">
		<td>
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
				<%
				if ("report".equals(sFrom))
				{
					%>
					<td align="left" valign="middle">
						<a class="subactionbutton" href="javascript:history.go(-1);"><< Return to Report Details</a>
					</td>
					<%
				}
				%>
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
	%>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="listTable" style="width:100%;">
				<col width="150">
				<col width="150">
				<col>
				<tr height="20">
					<th class="Tab_OFF" id="tab1_Step1" onclick="location.href='../edit/recip_edit.jsp?recip_id=<%= sRecipID %>';" valign="center" nowrap align="middle">Recipient Edit</th>
					<th class="Tab_ON" id="tab1_Step2" valign="center" nowrap align="middle">Campaign History</th>
					<th class="Tab_OFF" valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></th>
				</tr>
				<tr height="100">
					<td class="" valign="top" align="left" colspan="3" >
						<table width="100%"  class=listTable cellspacing=0 cellpadding=0>
							<tr>
								<th align=left colspan="2">Recipient Info</th>
							</tr>
							<tr>
								<td class="listItem_Data" nowrap align=left>First Name:</td>
								<td class="listItem_Data"><B><%= sPNmGiven %>&nbsp;</B></td>
							</tr>
							<tr>
								<td class="listItem_Data_Alt" nowrap align=left>Last Name:</td>
								<td class="listItem_Data_Alt"><B><%= sPNmFamily %>&nbsp;</B></td>
							</tr>
							<tr>
								<td class="listItem_Data" nowrap align=left>Email :</td>
								<td class="listItem_Data"><b><%= sEmail821 %>&nbsp;</b></td>
							</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td class="" valign="top" align="center" colspan="3">
						<table cellspacing="0" cellpadding="0" border="0" class="listTable" style="width:100%;">
							
										<col width="25">
										<col>
										<col width="115">
										<col width="80">
										<col width="60">
										<col width="90">
										<col width="109">
										<tr height="21">
											<th>&nbsp;</th>
											<th><nobr>Campaign</nobr></th>
											<th><nobr>Sent Date</nobr></th>
											<th><nobr>Open HTML</nobr></th>
											<th><nobr># Clicks</nobr></th>
											<th><nobr>Unsubscribed</nobr></th>
											<th><nobr>Bounced Back</nobr></th>
										</tr>
									
							
							<tr>
								<td valign="top" align="center" style="padding:5px;" colspan=7>
									<div style="width: 100%; overflow-y: scroll; height: 300px;">
									<table class="" cellspacing="0" cellpadding="0" style="width:100%;" id="histTable">
										<col width="25">
										<col>
										<col width="115">
										<col width="80">
										<col width="60">
										<col width="90">
										<col width="90">
									<%
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
												
												%>
										<tr>
											<td class="listItem_Data<%= sClassAppend %>" align="center" valign="middle"><nobr><a href="javascript:toggleDetails('<%= sMsgID %>');" id="link_<%= sMsgID %>" class="resourcebutton" style="width:15px; text-align:center;">+</a></nobr></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><nobr><a href="javascript:popMessageDetails('<%= sMsgID %>');"><b><%= sCampName %></b></a></nobr></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><nobr><%= sSendDateTxt %></nobr></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><nobr><%= (!iOpen.equals("0"))?"Yes":"No" %></nobr></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><nobr><%= iClick %></nobr></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><nobr><%= (!iUnsub.equals("0"))?"Yes":"No" %></nobr></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><nobr><%= (!iBBack.equals("0"))?"Yes":"No" %></nobr></td>
										</tr>
										<tr id="row_<%= sMsgID %>" style="display:none;">
											<td class="listItem_Data<%= sClassAppend %>">&nbsp;</td>
											<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" colspan="6" style="padding:5px;">
												<table cellspacing="0" cellpadding="7" border="0" class="layout" style="width:100%;">
													<col width="60">
													<col>
													<col width="15">
													<col width="60">
													<col>
													<col width="15">
													<col width="90">
													<col>
													<tr>
														<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle"><b>Status:</b></td>
														<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle"><%= (!iReceived.equals("0"))?"Sent":"NOT SENT YET" %></td>
														<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle">&nbsp;</td>
														<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle"><b>Type:</b></td>
														<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle">
															<nobr>
															<%= ("2".equals(sTypeID))?"Standard Campaign":"" %>
															<%= ("3".equals(sTypeID))?"Send To Friend Campaign":"" %>
															<%= ("4".equals(sTypeID))?"Triggered Campaign":"" %>
															<%= ("5".equals(sTypeID))?"Web / DM / Call Campaign":"" %>
															</nobr>
														</td>
														<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle">&nbsp;</td>
														<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle"><b># Form Subs:</b></td>
														<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle"><%= iSubs %></td>
													</tr>
												</table>
												<br>
											</td>
										</tr>
												<%
												/*
												xelEvents = XmlUtil.getChildrenByName(eCamp, "event");
												eEvent = null;
												nCount = xelEvents.getLength();
												
												if ("0".equals(sSampleID))
												{
													//nothing
												}
												else
												{
													sCampName = sCampName + " - Sample " + sSampleID;
												}
												
												if (nCount > 0)
												{
													for (int n=0; n < nCount; n++)
													{
														sEventID 		= "";
														sEventTypeID 	= "";
														sEventName 		= "";
														sEventTypeName 	= "";
														sEventDate 		= "";
														sEventSourceID 	= "";
														
														eEvent = (Element) xelEvents.item(n);
														
														sEventID 		= XmlUtil.getChildTextValue(eEvent, "event_id");
														sEventTypeID 	= XmlUtil.getChildTextValue(eEvent, "type_id");
														sEventName 		= XmlUtil.getChildCDataValue(eEvent, "event_name");
														sEventTypeName 	= XmlUtil.getChildCDataValue(eEvent, "event_type");
														sEventDate 		= XmlUtil.getChildCDataValue(eEvent, "event_date");
														sEventSourceID 	= XmlUtil.getChildTextValue(eEvent, "source_id");
													}
												}
												*/
											}
										}
										else
										{
											%>
										<tr>
											<td class="listItem_Data" colspan="6">This Recipient has not received any campaigns yet.</td>
										</tr>
											<%
										}
									}
									else
									{
										%>
										<tr>
											<td class="listItem_Data" colspan="6">This Recipient has not received any campaigns yet.</td>
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
