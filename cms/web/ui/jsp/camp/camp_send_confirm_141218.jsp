<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			org.w3c.dom.*,java.util.*,
			java.sql.*,
			java.net.*,
			java.io.*,
			java.text.DateFormat, 
			java.text.SimpleDateFormat,
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
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.CAMPAIGN);


if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canApprove = user.getAccessPermission(ObjectType.CAMPAIGN_APPROVAL);

boolean canFromAddrPers = ui.getFeatureAccess(Feature.FROM_ADDR_PERS);
boolean canFromNamePers = ui.getFeatureAccess(Feature.FROM_NAME_PERS);
boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);
boolean canSampleSet = ui.getFeatureAccess(Feature.SAMPLE_SET);
boolean canStep2 = ui.getFeatureAccess(Feature.CAMP_STEP_2);
boolean canStep3 = ui.getFeatureAccess(Feature.CAMP_STEP_3);
boolean canQueueStep = ui.getFeatureAccess(Feature.QUEUE_STEP);
boolean canSpecTest = ui.getFeatureAccess(Feature.SPECIFIED_TEST);
boolean canTestHelp = ui.getFeatureAccess(Feature.TESTING_HELP);
boolean isHyatt = ui.getFeatureAccess(Feature.HYATT);

%>

<%
// First get Campaign ID/Sample ID and mode info from the Request object.

String sCampId = request.getParameter("camp_id");
String sMode = request.getParameter("mode");
if (sMode == null) sMode = "send";
String sSampleId = request.getParameter("sample_id");
String sCategoryId = BriteRequest.getParameter(request, "category_id");
String sPvTestListIds = BriteRequest.getParameter(request, "pv_test_list_ids");

// Get all component objects needed to display all Campaign data
Campaign camp = new Campaign(sCampId);
CampSendParam csp = new CampSendParam(sCampId);
Content cont = new Content(camp.s_cont_id);
MsgHeader msghdr = new MsgHeader(sCampId);
Schedule sch = new Schedule(sCampId);
CampList camplist = new CampList(sCampId);
LinkedCamp linkcamp = new LinkedCamp(sCampId);
com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter(camp.s_filter_id);
com.britemoon.cps.tgt.Filter seed_list = new com.britemoon.cps.tgt.Filter(camp.s_seed_list_id);
FilterStatistic filter_stat = new FilterStatistic(camp.s_filter_id);

Vector vSamples = null;
Iterator iSamples = null;
int iNumberOfSamples = 0;

boolean isPrintCampaign = false;
if (camp.s_media_type_id != null && camp.s_media_type_id.equals("2")) {
	isPrintCampaign = true;
}
boolean bHasSampleset = false;
boolean bDisplayingFinal = false;
boolean bDisplayingSamples = false;
CampSampleset sampleset = new CampSampleset();
sampleset.s_camp_id = sCampId;
if(sampleset.retrieve() > 0) bHasSampleset = true;

bDisplayingFinal = (bHasSampleset && sSampleId == null);
bDisplayingSamples = (bHasSampleset && sSampleId != null);
String sSampleLabel = "&nbsp;Samples";
boolean isDynamicCampaign = false;
if (sampleset.s_filter_flag != null && sampleset.s_filter_flag.equals("1")) {
	isDynamicCampaign = true;
	sSampleLabel = "&nbsp;Dynamic Campaigns";
}

boolean templateRequiresApproval = WorkflowUtil.getTemplateAppovalFlag(sCampId);

boolean bCantSendOffers = false;
Vector offers = WorkflowUtil.getOffersLastSendDate(sCampId);
Iterator it = offers.iterator();
while (it.hasNext()) {
	HashMap offer = (HashMap) it.next();
	String sName = (String) offer.get("offer_name");
	String sLastSendDate = (String) offer.get("last_send_date");
	bCantSendOffers = true;
}
System.out.println(" workflow parameters: bWorkflow = " + bWorkflow + " can.bApprove = "+ can.bApprove + " bCantSendOffers = " + bCantSendOffers + " templateRequiresApproval = " + templateRequiresApproval);

/*
System.out.println("=====");
System.out.println("sCampId:" + sCampId);
if (sSampleId == null) System.out.println("sSampleId is NULL");
else System.out.println("sSampleId:" + sSampleId);
System.out.println("bHasSampleset:"+bHasSampleset);
System.out.println("bDisplayingFinal:"+bDisplayingFinal);
System.out.println("bDisplayingSamples:"+bDisplayingSamples);
*/

if (bDisplayingSamples)
{
	vSamples = new Vector();
	iNumberOfSamples = Integer.parseInt(sampleset.s_camp_qty);
	for (int i = 1;i<=iNumberOfSamples;i++)
	{
		vSamples.addElement(new CampSampleBean(sCampId,String.valueOf(i)));
	}
	iSamples = vSamples.iterator();
}


// Variables for data items not found directly in any component objects
String s_recip_qty = null;
String s_from_address = null;
String s_linked_camp_name = null;
String s_form_name = null;
String s_exclusion_list_name = null;
String s_test_list_name = null;
String s_last_test_date = null;
String s_send_to_list_name = null;
String s_send_to_attr_name = null;
int iCampTypeId = new Integer(camp.s_type_id).intValue();
boolean bTested = false;

s_recip_qty = (filter_stat.s_recip_qty == null) ?"???": filter_stat.s_recip_qty;

if (isPrintCampaign)
{
	s_recip_qty = (filter_stat.s_print_recip_qty == null) ?"???": filter_stat.s_print_recip_qty;
}

// === === ===

// As needed retrieve data from the database for data items not found directly in component objects.
PreparedStatement pstmt = null;
ResultSet rs = null;
ConnectionPool cp = null;
Connection conn  = null;

String sSql = null;

boolean bWasFinalCampSent = false;
boolean bWasSamplesetSent = false;
boolean bWasAnythingSent = false;

boolean bShowRow = true;
String sSampleCampName = "";
int nTypeId = -1;
int nStatusId = -1;
int nAprovalFlag = -1;
int nIsSample = -1;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("camp_send_confirm.jsp");

	sSql =
		" SELECT" +
		" camp_name," +
		" type_id," +
		" status_id," +
		" ISNULL(approval_flag,0)," +
		" SIGN(ISNULL(sample_id,0)) " +
		" FROM cque_campaign" +
		" WHERE origin_camp_id = ?" +
		" AND ISNULL(mode_id,0) <> ?" + // Don't display any calc_only test campaigns
		" ORDER BY type_id, status_id, ISNULL(approval_flag,0), SIGN(ISNULL(sample_id,0))";

	pstmt = conn.prepareStatement(sSql);
	pstmt.setString(1,sCampId);
	pstmt.setInt(2,CampaignMode.CALC_ONLY);
	rs = pstmt.executeQuery();

	if (rs.next())
	{
		bWasAnythingSent = true;

		do
		{
			bShowRow = true;
			
			sSampleCampName = rs.getString(1);
			nTypeId = rs.getInt(2);
			nStatusId = rs.getInt(3);
			nAprovalFlag = rs.getInt(4);
			nIsSample = rs.getInt(5);
				
			if((nIsSample == 0) && (nTypeId != CampaignType.TEST))
			{
				bWasFinalCampSent = true;
			}
			else
			{
				if (nTypeId != CampaignType.TEST)
				{
					bWasSamplesetSent = true;
				}
			}

		} while (rs.next());
	}
	
	rs.close();
	
	// get from_address
	if ( !bHasSampleset || bDisplayingFinal || (bDisplayingSamples && sampleset.s_from_address_flag == null) )
	{
		// from_address is not a sample data item, use from_address from main campaign
		if (msghdr.s_from_address != null)
		{
			s_from_address = msghdr.s_from_address;
		}
		else
		{
			sSql = "Select prefix +'@' + domain " +
					"from ccps_from_address " +
					"where from_address_id = ?";

			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1,msghdr.s_from_address_id);
			rs = pstmt.executeQuery();

			if (rs.next())
			{
				s_from_address = rs.getString(1);
			}
			else
			{
				s_from_address = "";
			}
			rs.close();
			pstmt.close();
		}
	}

	// get linked_campaign info
	if (linkcamp.s_linked_camp_id != null)
	{
		sSql =
			" SELECT camp.camp_name " +
			" FROM cque_campaign camp " +
			" WHERE type_id in (3,4)" +
			" AND status_id > 0 " +
			" AND camp.origin_camp_id = ? ";		

		pstmt = conn.prepareStatement(sSql);
		pstmt.setString(1,linkcamp.s_linked_camp_id);
		rs = pstmt.executeQuery();

		if (rs.next())
		{
			s_linked_camp_name = rs.getString(1);
		}
		rs.close();
		pstmt.close();
	}

	// get form info
	if (linkcamp.s_form_id != null)
	{
		sSql =
			" Select form_name " +
			" from csbs_form " +
			" where form_id = ? ";

		pstmt = conn.prepareStatement(sSql);
		pstmt.setString(1,linkcamp.s_form_id);
		rs = pstmt.executeQuery();

		if (rs.next())
		{
			s_form_name = rs.getString(1);
		}
		rs.close();
		pstmt.close();
	}

	//get test info

	sSql =
		" SELECT camp.camp_name, ISNULL(stat.start_date, '1/1/00') AS start " +
		" FROM  cque_campaign camp " +
		" INNER JOIN cque_camp_type type ON " +
		" camp.type_id = type.type_id " +
		" INNER JOIN cque_camp_statistic stat ON" +
		" camp.camp_id = stat.camp_id " +
		" WHERE (camp.origin_camp_id = ?) " +
		" AND (UPPER(type.type_name) = 'TEST')";

	pstmt = conn.prepareStatement(sSql);
	pstmt.setString(1,sCampId);
	rs = pstmt.executeQuery();
	if (rs.next())
	{
		bTested = true;
		s_last_test_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp("start"));
		if (s_last_test_date.equals("Jan 1, 1900 12:00 AM"))
		{
			s_last_test_date = null;
		}
	}
	else
	{
		bTested = false;
	}
	rs.close();
	pstmt.close();


	// get Exlusion List info
	if (camplist.s_exclusion_list_id != null)
	{
		sSql =
			" SELECT isnull(list_name,'null') " +
			" FROM cque_email_list list, " +
			" cque_list_type type " +
			" WHERE list.type_id = type.type_id "+
			" AND UPPER(type.type_name) = 'CAMPAIGN EXCLUSION LIST' " +
			" AND list_id = ?";

		pstmt = conn.prepareStatement(sSql);
		pstmt.setString(1,camplist.s_exclusion_list_id);
		rs = pstmt.executeQuery();

		if (rs.next())
		{
			s_exclusion_list_name = rs.getString(1);
		}
		rs.close();
		pstmt.close();
	}

	// get Test List info
	if (!bHasSampleset || sSampleId == null)
	{
		if (camplist.s_test_list_id != null)
		{
			sSql =
				" SELECT isnull(list_name,'null') " +
				" FROM cque_email_list list, " +
				" cque_list_type type " +
				" WHERE list.type_id = type.type_id "+
				" AND UPPER(type.type_name) like '% TEST %' " +
				" AND list_id = ?";

			pstmt = conn.prepareStatement(sSql);
			pstmt.setString(1,camplist.s_test_list_id);
			rs = pstmt.executeQuery();

			if (rs.next())
			{
				s_test_list_name = rs.getString(1);
			}
			rs.close();
			pstmt.close();
		}
	}

	// get Send To Attribute info
	if (camplist.s_auto_respond_attr_id != null)
	{
		sSql =
			" SELECT display_name " +
			" FROM ccps_cust_attr " +
			" WHERE attr_id = ?";

		pstmt = conn.prepareStatement(sSql);
		pstmt.setString(1,camplist.s_auto_respond_attr_id);
		rs = pstmt.executeQuery();

		if (rs.next())
		{
			s_send_to_attr_name = rs.getString(1);
		}
		rs.close();
		pstmt.close();
	}


	// get Send To List info
	if (camplist.s_auto_respond_list_id != null)
	{
		sSql =
			" SELECT list_name " +
			" FROM cque_email_list " +
			" WHERE list_id = ?";

		pstmt = conn.prepareStatement(sSql);
		pstmt.setString(1,camplist.s_auto_respond_list_id);
		rs = pstmt.executeQuery();

		if (rs.next())
		{
			s_send_to_list_name = rs.getString(1);
		}
		rs.close();
		pstmt.close();
	}


}
catch(SQLException sqlex)
{
	logger.error("SQLException thrown from camp_send_confirm.jsp.",sqlex);
	throw sqlex;
}
catch(Exception ex)
{
	logger.error("General Exception thrown from camp_send_confirm.jsp.",ex);
	throw ex;
}
finally
{
	if(pstmt != null) pstmt.close();
	if(conn != null) cp.free(conn);
}
// done with database retrieval

%>
<HTML>
<HEAD>
	<BASE target="_self">
	<%@ include file="../header.html"%>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<table width=650 class=listTable cellspacing=0 cellpadding=0>
	<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Campaign:</b> <%=(sMode.equals("test"))?"Test":"Send"%> Confirmation</th>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td  valign=top align=center width=100%>
			<table  cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px; font-size:14pt;">
						You are about to Send the following <%= CampaignType.getDisplayName(iCampTypeId) %><%=(isPrintCampaign?" Print ":"")%><%= (sSampleId != null)?sSampleLabel:"&nbsp;Campaign" %>
						<br>
						Please confirm all Campaign details before sending
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br>

<table id="Tabs_Table2" class=listTable cellspacing="0" cellpadding="0" width="650" border="0">
<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Campaign Details</th>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td style="padding:0" valign="top" align="center" width="100%">

<%-- Start Step 1 information --%>

			<table class="" cellspacing="0" cellpadding="0" width="100%">
				<tr>
					<td class=heads width="125" height="25" align="left" valign="middle">Name: </td>
					<td width="425" height="25" align="left" valign="middle"><%=HtmlUtil.escape(camp.s_camp_name)%> </td>
				</tr>
			</table>

<%-- End of Step 1 information --%>

			

<%-- Start Step 2 information --%>

		<%
		if (!isPrintCampaign && (!bHasSampleset || bDisplayingFinal || (bDisplayingSamples && (sampleset.s_from_address_flag == null) || (sampleset.s_from_name_flag == null))))
		{
			%>
			<table class="" cellspacing="0" cellpadding="0" width="100%">
			<%
			if (!bHasSampleset || bDisplayingFinal || (bDisplayingSamples && sampleset.s_from_name_flag == null) )
			{
				%>
				<tr>
					<td class=heads width="125" height="25">From Name: </td>
					<td width="425" height="25"><%= HtmlUtil.escape(msghdr.s_from_name) %> </td>
				</tr>
				<%
			}

			if (!bHasSampleset || bDisplayingFinal || (bDisplayingSamples && sampleset.s_from_address_flag == null) )
			{
				%>
				<tr>
					<td class=heads width="125" height="25">From Address: </td>
					<td width="425" height="25"><%= HtmlUtil.escape(s_from_address) %> </td>
				</tr>
				<%
			}
			//else { System.out.println("sampleset.sfromaddrflag=" + sampleset.s_from_address_flag); }
			%>
			</table>
			
			<%
		}

		if (!isPrintCampaign && (!bHasSampleset  || bDisplayingFinal || (bDisplayingSamples && sampleset.s_subject_flag == null) ))
		{
			%>
			<table class="" cellspacing="0" cellpadding="0" width="100%">
				<tr>
					<td class=heads width="125" height="25">Subject: </td>
					<td width="425" height="25">
						<table>
							<tr>
								<td width="425"><%= HtmlUtil.escape(msghdr.s_subject_html) %> </td>
							</tr>
							<tr style="display:none;">
								<td style="display:none;" width="125">Text Subject: </td>
								<td style="display:none;" width="425">
								<%
								if ((msghdr.s_subject_text != null) && !(msghdr.s_subject_text.equals(""))  )
								{
									%>
									<%= HtmlUtil.escape(msghdr.s_subject_text) %>
									<%
								}
								else
								{
									%>
									<b>NONE</b> assigned
									<%
								}
								%>
								</td>
							</tr>
							<tr style="display:none;">
								<td style="display:none;" width="125">AOL Subject: </td>
								<td style="display:none;" width="425">
								<%
								if ((msghdr.s_subject_aol != null) && !(msghdr.s_subject_aol.equals("")) )
								{
									%>
									<%= HtmlUtil.escape(msghdr.s_subject_aol) %>
									<%
								}
								else
								{
									%>
									<b>NONE</b> assigned
									<%
								}
								%>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			
			<%
		}
		%>
			<table class="" cellspacing="0" cellpadding="0" width="100%">
			<%
			if (!bHasSampleset  || bDisplayingFinal || (bDisplayingSamples && sampleset.s_cont_flag == null) )
			{
				%>
				<tr>
					<td class=heads width="125" height="25">Content: </td>
					<td width="425" height="25">
						<%= HtmlUtil.escape(cont.s_cont_name) %>
						&nbsp;&nbsp;
						<a class="resourcebutton" href="javascript:dynamic_popup(<%= HtmlUtil.escape(cont.s_cont_id) %>);">Preview</a>
						&nbsp;&nbsp;
                        <% if (!isPrintCampaign) { %>
						<a class="resourcebutton" href="javascript:score_popup(<%= HtmlUtil.escape(cont.s_cont_id) %>,
						'<%= HtmlUtil.escape(msghdr.s_from_name) %>',
						'<%= HtmlUtil.escape(s_from_address) %>',
						'<%= HtmlUtil.escape(msghdr.s_subject_text.replaceAll("'","\\\\'")) %>',
						'<%= HtmlUtil.escape(msghdr.s_subject_html.replaceAll("'","\\\\'")) %>',
						'<%= HtmlUtil.escape(msghdr.s_subject_aol.replaceAll("'","\\\\'")) %>');">Score</a>
                        <% } %>
					</td>
				</tr>
			<%
			}

			int showTG = 1;

			if (iCampTypeId == CampaignType.SEND_TO_FRIEND)
			{
				%>
				<tr>
					<td width="125" height="25">Form: </td>
					<td width="425" height="25">
						<%
						if (s_form_name != null)
						{
							showTG = 0;
							%>
							<%= HtmlUtil.escape(s_form_name) %>
							<%
						}
						else
						{
							%>
							This Send to Friend campaign is based on a Target Group, not on the submission of a Form
							<%
						}
						%>
					</td>
				</tr>
				<%
			}

			if (showTG == 1)
			{
				%>
				<tr>
					<td class=heads width="125" height="25">Target Group: </td>
					<td width="425" height="25">
						<%= HtmlUtil.escape(filter.s_filter_name) %>
						&nbsp;(<%= HtmlUtil.escape(s_recip_qty) %> recipients)
						<% if (canTGPreview) { %>&nbsp;&nbsp;<a class="resourcebutton" href="javascript:targetgroup_popup(<%= HtmlUtil.escape(filter.s_filter_id) %>);">Preview</a><% } %>
				<%
				String sCalcCampID = null;
				
				sSql = "SELECT max(camp_id) FROM cque_campaign"
						+ " WHERE type_id = "+CampaignType.TEST
						+ " AND status_id = "+CampaignStatus.DONE
						+ " AND mode_id = "+CampaignMode.CALC_ONLY
						+ " AND origin_camp_id = ?";

				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, camp.s_camp_id);
				rs = pstmt.executeQuery();
					
				if (rs.next()) sCalcCampID = rs.getString(1);
				rs.close();
				
				if (sCalcCampID != null)
				{
					CampStatDetails csds = new CampStatDetails();
					csds.s_camp_id = sCalcCampID;
					csds.retrieve();
					
					if(csds.size() != 0)
					{
						%>
						&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:showCampDetails('<%= sCalcCampID %>', 'stats');" class="resourcebutton">Calculated Recipient Statistics</a>
						<%
					}
				}
				%>
					</td>
				</tr>
				<%
					if (!filter.s_status_id.equals( "40"))
					{
						// if Target Group has not been updated, display a warning
						%>
						<tr>
							<td valign="middle" align="center" style="padding:5px;" colspan="2">
								<FONT color="red"><B>*** This Target Group has NOT been Updated. ***</B></FONT>
								<br>
								You may be sending this campaign to an unknown number of recipients.
								<br>
							It is <b>highly recommended</b> that the Target Group is updated before sending this campaign.
								<br><br>
								<a class="subactionbutton" href="../index.jsp?tab=Data&sec=2" target="_parent">Go to Target Groups</a>
							</td>
						</tr>
						<%
					}
				if (bDisplayingFinal && !bWasSamplesetSent)
				{
					// showing final camp with samples not sent, display a warning
					%>
					<tr>
						<td valign="middle" align="center" style="padding:5px;" colspan="2">
							<FONT color="red"><B>*** Final Campaign will be sent to Entire Target Group ***</B></FONT>
							<br>
							A final campaign is designed to be sent to the remainder of a target group after <%=sSampleLabel.toLowerCase() %> are sent.  
                                   No <%=sSampleLabel.toLowerCase() %> have been sent for this campaign, therefore this final campaign will be sent to 
							the entire target group.
							<br>
							Before confirming the launch of this campaign, be sure that the <%=sSampleLabel.toLowerCase() %> should not have 
							been sent and that this final campaign should be sent to the <b>entire</b> target group.
							<br><br>
							<a class="subactionbutton" href="javascript:doSend(0);"><< Back to edit &amp; Send <%=sSampleLabel %></a>
						</td>
					</tr>
					<%
				}

			}
			else
			{
				%>
				<tr>
					<td width="125" height="25">Target Group: </td>
					<td width="425" height="25">
						This Send to Friend campaign is based on the submission of a Form, not a Target Group
					</td>
				</tr>
				<%
			}

			%>
                <% if (!isPrintCampaign) { %>
				<tr>
					<td class=heads width="125" height="25">Response Forwarding: </td>
					<td width="425" height="25"><%= HtmlUtil.escape(csp.s_response_frwd_addr) %></td>
				</tr>
                <% } %>
			<%
			if (iCampTypeId == CampaignType.AUTO_RESPOND)
			{
				%>
				<tr>
					<td width="125" height="25">
					<%
					if (s_send_to_list_name != null)
					{
						// Send to Notification List
						%>
						Send email to:
					</td>
					<td width="425" height="25"><%= HtmlUtil.escape(s_send_to_list_name) %></td>
					<%
					}
					else if (s_send_to_attr_name != null)
					{
						// Send to email from attribute
						%>
						Send email to email address based on:
					</td>
					<td width="425" height="25"><%= HtmlUtil.escape(s_send_to_attr_name) %></td>
					<%
					}
					else
					{
						// Send to Subscriber
						%>
						Send email to Subscriber
					</td>
					<td>&nbsp;</td>
						<%
					}
					%>
				</tr>
				<%
			}
			%>
			</table>
			
			<% if (canStep2) { %>
			<table  class="" cellspacing="0" cellpadding="0" border="0" width="100%">
                <% if (!isPrintCampaign) { %>
				<tr>
					<td class=heads width="125" height="25">Reply To: </td>
					<td width="425" height="25">
						<%
						if ( (msghdr.s_reply_to != null) && (!msghdr.s_reply_to.equals("")) )
						{
							%>
							<%= HtmlUtil.escape(msghdr.s_reply_to) %>
							<%
						}
						else
						{
							%>
							<b>NO</b> Reply To address was assigned for this campaign.
							<br>
							Responses will be tracked through the Response Tracking module
							and any valid replies will be forwarded to the Response Forwarding address listed above.
							<%
						}
						%>
					</td>
				</tr>
                <% } %>
			<%
			if (iCampTypeId != CampaignType.SEND_TO_FRIEND)
			{
				%>
				<tr>
					<td class=heads width="125" height="25">Seed List: </td>
					<td width="425" height="25">
						<%
						if ( (seed_list.s_filter_name != null) && !(seed_list.s_filter_name.equals("")) )
						{
							%>
							<%= HtmlUtil.escape(seed_list.s_filter_name) %>
							<%
						}
						else
						{
							%>
							<b>NO</b> Seed List was assigned for this campaign
							<%
						}
						%>
					</td>
				</tr>
				<%
			}

			if (iCampTypeId == CampaignType.STANDARD && !isPrintCampaign)
			{
				%>
				<tr>
					<td class=heads width="125" height="25">Linked to Campaign: </td>
					<td width="425" height="25">
						<%
						if (s_linked_camp_name != null)
						{
							%>
							<%= HtmlUtil.escape(s_linked_camp_name) %>
							<%
						}
						else
						{
							%>
							<b>NO</b> Send-to-Friend or Auto-Respond Campaigns linked to this campaign.
							<br>
							Any links in the content to a Send to Friend Form will not work correctly.
							<%
						}
						%>
					</td>
				</tr>
				<%
			}

			if (iCampTypeId == CampaignType.AUTO_RESPOND)
			{
				%>
				<tr>
					<td width="125" height="25">
						Recipients are<%= (csp.s_msg_per_recip_limit == null)?" <b>NOT</b>":"" %> allowed to recieve this campaign multiple times
					</td>
				</tr>
				<%
			}
			%>
			</table>
			
			<% } %>
			<% if (canStep3) { %>
			<table  class="" cellspacing="0" cellpadding="0" border="0" width="100%">
				<tr>
					<td class=heads width="125" height="25">Exclusion List: </td>
					<td width="425" height="25">
						<%
						if ((s_exclusion_list_name != null) && (!s_exclusion_list_name.equals("null")))
						{
							%>
							<%= HtmlUtil.escape(s_exclusion_list_name) %>
							<%
						}
						else
						{
							%>
							<b>NO</b> Exclusion List was assigned for this campaign
							<%
						}
						%>
					</td>
				</tr>
			<%
			if (iCampTypeId != CampaignType.SEND_TO_FRIEND)
			{
				if (csp.s_camp_frequency != null)
				{
					%>
				<tr>
					<td colspan="2" height="25">
						Exclude recipients who have received a campaign in the previous <%= HtmlUtil.escape(csp.s_camp_frequency) %> days
					</td>
				</tr>
					<%
				}
				else
				{
					%>
				<tr>
					<td class=heads width="125" height="25">Frequency Exclusion: </td>
					<td width="425" height="25">
						<b>NO</b> exclusion based on receiving a campaign in the past
					</td>
				</tr>
					<%
				}
			}

			if (iCampTypeId == CampaignType.STANDARD && !isPrintCampaign)
			{
				%>
				<tr>
					<td class=heads width="125" height="25">Subset Sendout: </td>
					<td width="425" height="25">
						<%
						if ((csp.s_recip_qty_limit != null) && (!csp.s_recip_qty_limit.equals("0")) )
						{
							%>
							<%= HtmlUtil.escape(csp.s_recip_qty_limit) %>
							<%
							if (csp.s_randomly.equals("1"))
							{
								%>
								&nbsp;(randomly)
								<%
							}
						}
						else
						{
							%>
							<b>NO</b> subset send out<br>
							All recipients in the Target Group will receive this campaign
							<%
						}
						%>
					</td>
				</tr>
				<%
			}

			if (!isPrintCampaign && iCampTypeId == CampaignType.STANDARD)
			{
				%>
				<tr>
					<td class=heads width="125" height="25">Maximum messages to be sent per hour: </td>
					<td width="425" height="25"><%= (!csp.s_limit_per_hour.equals("0"))?HtmlUtil.escape(csp.s_limit_per_hour):"<b>NO</b> throttle<br>Messages will be sent as quickly as the mail delivery servers pull them" %> </td>
				</tr>
				<%
			}
			%>
			</table>
			
			<% } %>
			
<%-- End of Step 2 information --%>

<%-- Start Step 3 information --%>

		<%
		if (bDisplayingSamples)
		{
			while (iSamples.hasNext())
			{
				CampSampleBean csbTmp = (CampSampleBean) iSamples.next();
				%>
				<table  class="" cellspacing="0" cellpadding="0" border="0" width="100%">
					<tr>
						<td colspan="2"><b><%=(isDynamicCampaign?"Campaign ":"Sample ") %><%= HtmlUtil.escape(csbTmp.getSampleId()) %></b></td>
					</tr>
				<%
				if (sampleset.s_from_name_flag != null)
				{
					%>
					<tr>
						<td width="125" height="25">From Name: </td>
						<td width="425" height="25"><%= HtmlUtil.escape(csbTmp.getFromName()) %> </td>
					</tr>
					<%
				}

				if (sampleset.s_from_address_flag != null)
				{
					%>
					<tr>
						<td width="125" height="25">From Address: </td>
						<td width="425" height="25"><%= HtmlUtil.escape(csbTmp.getFromAddress()) %> </td>
					</tr>
					<%
				}
				
				if (sampleset.s_reply_to_flag != null)
				{
					%>
					<tr>
						<td width="125" height="25">Reply To: </td>
						<td width="425" height="25"><%= HtmlUtil.escape(csbTmp.getReplyTo()) %> </td>
					</tr>
					<%
				}

				if (sampleset.s_filter_flag != null)
				{
					com.britemoon.cps.tgt.Filter sampleFilter = new com.britemoon.cps.tgt.Filter(csbTmp.getFilterId());
					%>
					<tr>
						<td width="125" height="25">Logic Element: </td>
						<td width="425" height="25"><%= HtmlUtil.escape(sampleFilter.s_filter_name) %> </td>
					</tr>
					<tr>
						<td width="125" height="25">Priority: </td>
						<td width="425" height="25"><%= HtmlUtil.escape(csbTmp.getPriority()) %> </td>
					</tr>
					<%
				}
				
				if (sampleset.s_subject_flag != null)
				{
					if (csbTmp.getSubjectHtml() != null)
					{
						%>
					<tr>
						<td class=heads width="125" height="25">Subject: </td>
						<td width="425" height="25"><%= HtmlUtil.escape(csbTmp.getSubjectHtml()) %> </td>
					</tr>
						<%
					}

					if (csbTmp.getSubjectText() != null)
					{
						%>
					<tr style="display:none;">
						<td style="display:none;" width="125" height="25">Text Subject: </td>
						<td style="display:none;" width="425" height="25"><%= HtmlUtil.escape(csbTmp.getSubjectText()) %> </td>
					</tr>
						<%
					}

					if (csbTmp.getSubjectAol() != null)
					{
						%>
					<tr style="display:none;">
						<td style="display:none;" width="125" height="25">AOL Subject: </td>
						<td style="display:none;" width="425" height="25"><%= HtmlUtil.escape(csbTmp.getSubjectAol()) %> </td>
					</tr>
						<%
					}
				}

				if (sampleset.s_cont_flag != null)
				{
					%>
					<tr>
						<td width="125" height="25">Content: </td>
						<td width="425" height="25">
							<%= HtmlUtil.escape(csbTmp.getContName()) %>
							&nbsp;&nbsp;
							<a class="resourcebutton" href="javascript:dynamic_popup(<%=HtmlUtil.escape(csbTmp.getContId())%>);">Preview</a>
							&nbsp;&nbsp;
                            <% if (!isPrintCampaign) { %>
							<a class="resourcebutton" href="javascript:score_popup(<%=HtmlUtil.escape(csbTmp.getContId())%>,
							'<%=HtmlUtil.escape( ((sampleset.s_from_name_flag != null)?csbTmp.getFromName():msghdr.s_from_name) )%>',
							'<%=HtmlUtil.escape( ((sampleset.s_from_address_flag != null)?csbTmp.getFromAddress():s_from_address) )%>',
							'<%=HtmlUtil.escape( ((sampleset.s_subject_flag != null)?csbTmp.getSubjectText().replaceAll("'","\\\\'"):msghdr.s_subject_text.replaceAll("'","\\\\'")) )%>',
							'<%=HtmlUtil.escape( ((sampleset.s_subject_flag != null)?csbTmp.getSubjectHtml().replaceAll("'","\\\\'"):msghdr.s_subject_html.replaceAll("'","\\\\'")) )%>',
							'<%=HtmlUtil.escape( ((sampleset.s_subject_flag != null)?csbTmp.getSubjectAol().replaceAll("'","\\\\'"):msghdr.s_subject_aol.replaceAll("'","\\\\'")) )%>');">Score</a>
                            <% } %>
						</td>
					</tr>
				<%
				}

				if (sampleset.s_send_date_flag != null)
				{
					%>
					<tr>
						<td width="125" height="25">Send Date: </td>
						<td width="425" height="25">
						<%
						if (csbTmp.getSendDate() != null && !csbTmp.getSendDate().equals(""))
						{
							%>
							<%= HtmlUtil.escape(csbTmp.getSendDate()) %>
							<%
						}
						else
						{
							%>
							NOW
							<%
						}
						%>
						</td>
					</tr>
					<%
				}
					%>
                    <% if (!isPrintCampaign) { %>
					<tr>
						<td width="125" height="25">Test List: </td>
						<td width="425" height="25">
						<%
						if (csbTmp.getTestListName() != null && !csbTmp.getTestListName().equals(""))
						{
							%>
							<%= HtmlUtil.escape(csbTmp.getTestListName()) %>
							<%
						}
						else
						{
							%>
							<b>NONE</b> assigned
							<%
						}
						%>
						</td>
					</tr>
					<tr>
						<td valign="middle" align="center" style="background-color:#D1D1D1" colspan="2">
						<%
						if (csbTmp.getTested() && csbTmp.getLastTestDate() != null)
						{
							%>
							The last test for this sample was started at: <%= HtmlUtil.escape(csbTmp.getLastTestDate()) %>
							<%
						}
						else
						{
							%>
							<FONT color="red"><B>*** No Test Has Been Sent For This Campaign ***</B></FONT><br>
							It is <b>highly recommended</b> that a Test of this campaign be sent before finally sending the campaign.
							<br><br>
							<a class="subactionbutton" href="javascript:doSend(0);"><< Back to edit &amp; Send a test</a>
							<%
						}
						%>
						</td>
					</tr>
                    <% } %>
				</table>
				
				<%
			}   	// while (iSamples.hasNext())
		}   	// if (bDisplayingSamples)
		else {   // !bDisplayingSamples
		%>
            <% if (!isPrintCampaign) { %>
			<%--
			<%
			if ((s_test_list_name != null) && (!s_test_list_name.equals("null")))
			{
				%>
				<table  class="" cellspacing="0" cellpadding="0" border="0" width="100%">
					<tr>
						<td class=heads align="left" valign="middle">Test List: <%= HtmlUtil.escape(s_test_list_name) %></td>
					</tr>
				</table>
				<br>
				<%
			}
			%>
			--%>
			<table class="" cellspacing="0" cellpadding="0" width="100%">
				<tr>
					<td valign="middle" align="center" style="background-color:#D1D1D1">
					<%
					if (bTested)
					{
						%>
							The last test for this campaign was started at: <%= HtmlUtil.escape(s_last_test_date) %>
						<%
					}
					else
					{
						%>
						<FONT color="red"><B>*** No Test Has Been Sent For This Campaign ***</B></FONT><br>
						It is <b>highly recommended</b> that a Test of this campaign be sent before finally sending the campaign.
						<br><br>
						<a class="subactionbutton" href="javascript:doSend(0);"><< Back to edit &amp; Send a test</a>
						<%
					}
					%>
					</td>
				</tr>
			</table>
            <% } %>
		<%   }  // !bDisplayingSamples %>

<%-- End of Step 3 information --%>

			

<%-- Start Step 4 information --%>

		<%
		if (!bHasSampleset || bDisplayingFinal || (bDisplayingSamples && sampleset.s_send_date_flag == null) )
		{
			%>
			<table class="" cellspacing="0" cellpadding="0" width="100%">
				<tr>
					<td class=heads width="125" height="25">Send Start Date: </td>
					<td width="425" height="25"><%= (sch.s_start_date == null)?"NOW":HtmlUtil.escape(sch.s_start_date) %> </td>
				</tr>
			<%
			if (iCampTypeId != CampaignType.STANDARD)
			{
				%>
				<tr>
					<td width="125" height="25">End Date: </td>
					<td width="425" height="25"><%= (sch.s_end_date != null)?HtmlUtil.escape(sch.s_end_date):"<b>NO</b> End date specified" %> </td>
				</tr>
				<%
			}
			if (canQueueStep)
			{
			%>
				<tr>
					<td class=heads width="125" height="25">Queue Start Date: </td>
					<td width="425" height="25"><%= (csp.s_queue_date != null)?HtmlUtil.escape(csp.s_queue_date):"<b>NO</b> Queue Start Date specified" %> </td>
				</tr>
			</table>
			<%
			}
		}
		%>

<%-- End of Step 4 information --%>

<%-- Start Step 5 information --%>
<% if (bCantSendOffers) { %>
	<table class="" cellspacing="0" cellpadding="0" width="100%">
				<tr>
					<td width="125" height="25">Offers: </td>
					<td width="425" height="25"><FONT color="red">WARNING: Offers in this content cannot be sent.&nbsp;&nbsp;Select another content.</FONT><br>
						<%
						DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
						SimpleDateFormat sdf = new SimpleDateFormat("yyy-MM-dd");
						it = offers.iterator();
						while (it.hasNext()) {
							HashMap offer = (HashMap) it.next();
							String sName = (String) offer.get("offer_name");
							String sLastSendDate = (String) offer.get("last_send_date"); 
							java.util.Date dSendDate = df.parse(sLastSendDate);
							
							sdf.applyPattern("MMMM d yyyy ");
							String sSendDate = sdf.format(dSendDate);
   						%>
							<%=sName%>&nbsp;-&nbsp;<%=sSendDate%><br>
					<% } %>
						 </td>
				</tr>
	</table>
	<% System.out.println("past the table displaying expired offers"); } %>
		</td>
	</tr>
	</tbody>
</table>
<br>


<table id="Tabs_Table3" cellspacing=0 cellpadding=0 width=650 border=0 class=listTable>
<tr>
		<th class=sectionheader>&nbsp;<b class=sectionheader>Campaing settings verification</th>
	</tr>
	<tbody class=EditBlock id=block3_Step1>
	<tr>
		<td  valign=top align=center width=100%>
			<FORM method="POST" name="confirmation_form" action="" style="display:inline;">
				<INPUT type=hidden name="camp_id" value="<%= HtmlUtil.escape(camp.s_camp_id) %>">
				<INPUT type=hidden name="sample_id" value="<%= HtmlUtil.escape(sSampleId) %>">
				<INPUT type=hidden name="mode" value="<%= HtmlUtil.escape(sMode) %>">
				<INPUT type=hidden name="type_id" value="<%= HtmlUtil.escape(camp.s_type_id) %>">
				<% if(sCategoryId != null) { %>
					<INPUT TYPE="hidden" NAME="category_id" value="<%=sCategoryId%>">
				<% } %>
				<% if(sPvTestListIds != null) { %>
					<INPUT TYPE="hidden" NAME="pv_test_list_ids" value="<%=sPvTestListIds%>">
				<% } %>
				<INPUT type=hidden name="approval_flag" value=0>
				<table class= cellspacing=0 cellpadding=0 width="100%">
					<tr>
						<td align="center" valign="middle" width="50%" style="padding:5px;">
							<table cellspacing="0" cellpadding="3" border="0">
								<tr>
									<td align="center" valign="middle">If the above information is incorrect in any way:</td>
								</tr>
								<tr>
									<td align="center" valign="middle">
										<a class="subactionbutton" href="javascript:doSend(0);"><< Go Back To Edit</a>
									</td>
								</tr>
							</table>
						</td>
						<% if (!bCantSendOffers) { %>
						<td align="center" valign="middle" width="50%" style="padding:5px;">
							<table cellspacing="0" cellpadding="3" border="0">
								<tr>
									<td align="center" valign="middle">If the above information is correct:</td>
								</tr>
							<% if (!bWorkflow) { %>
								<tr>
									<td align="center" valign="middle">
										<a class="buttons-action" href="javascript:doSend(1);">Confirm >> Send Campaign</a>
									</td>
								</tr>
								<% if (canApprove.bExecute) { %>
								<tr>
									<td align="center" valign="middle">OR</td>
								</tr>
								<tr>
									<td align="center" valign="middle">
										<a class="buttons-action" href="javascript:doSend(2);">Confirm >> Send &amp; Approve Campaign</a>
									</td>
								</tr>
								<% } %>
							<% } else if (bWorkflow && can.bApprove) { %>
								<% if (ui.n_ui_type_id != UIType.HYATT_ADMIN) { %>
								<tr>
									<td align="center" valign="middle">
										<a class="buttons-action" href="javascript:doSend(1);">Confirm >> Send Campaign</a>
									</td>
								</tr>
								<tr>
									<td align="center" valign="middle">OR</td>
								</tr>
								<% } %>
								<tr>
									<td align="center" valign="middle">
										<a class="buttons-action" href="javascript:doSend(2);">Confirm >> Send &amp; Approve Campaign</a>
									</td>
								</tr>
							<% } else if ((bWorkflow && !can.bApprove) || (bWorkflow && templateRequiresApproval)) { %> <%-- workflow is true, but this user does not have approve access to campaigns --%>
								<tr>
									<td align="center" valign="middle">
										<a class="buttons-action" href="javascript:RequestApproval();">Confirm >> Request Approval</a>
									</td>
								</tr>
							<% } %>
							</table>
						</td>
						
					</tr>
					<tr>
						<td colspan="2" align="center" valign="middle" style="padding:10px;">
							<font color="red"><b>WARNING:</b></font>&nbsp;After clicking the Confirm button above, do not click the "Back" button of the internet browser.<br><br>
							<b>Doing so could inadvertantly queue the campaign twice.</b>
						</td>
					</tr>
					<% } %>
				</table>
			</FORM>
		</td>
	</tr>
	</tbody>
</table>


<SCRIPT>

var nSubmitOnce = 0;

function doSend(parm)
{
	// as Caghan was able to send "doubled" campaign somehow
	// nSubmitOnce variable is here to prevent accidental "doubled" click
	// just in case it was the reason

	if(nSubmitOnce > 0) return;
	nSubmitOnce = 1;

	switch( parm )
	{
		case 0:
		{
			confirmation_form.action="camp_edit.jsp";
			confirmation_form.method = "get";
			break;
		}
		case 1:
		{
			confirmation_form.approval_flag.value="0";
			confirmation_form.action="camp_send.jsp";
			break;
		}
		case 2:
		{
			confirmation_form.approval_flag.value="1";
			confirmation_form.action="camp_send.jsp";
			break;
		}
	}

	confirmation_form.submit();
}

function RequestApproval()
{

	confirmation_form.action="../workflow/approval_request_edit_camp.jsp";
	confirmation_form.submit();
}


function dynamic_popup(contID)
{
	URL = '/cms/ui/jsp/cont/cont_preview_frame.jsp?cont_id=' + contID;
	windowName = 'preview_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
	SmallWin = window.open(URL, windowName, windowFeatures);
}

function score_popup(contID, from_name, from_address, subj_text, subj_html, subj_aol)
{
	from = escape('"' + from_name + '" ' + from_address);
	URL = '/cms/ui/jsp/cont/cont_score_frame.jsp?cont_id=' + contID + '&from=' + from + '&subjText=' + subj_text + '&subjHtml=' + subj_html + '&subjAol=' + subj_aol;
	windowName = 'score_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
	SmallWin = window.open(URL, windowName, windowFeatures);
}

function targetgroup_popup(filterID)
{
	URL = '/cms/ui/jsp/filter/filter_preview.jsp?filter_id=' + filterID;
	windowName = 'targetgroup_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=yes, height=600, width=700';
	SmallWin = window.open(URL, windowName, windowFeatures);
}

var _oPop;

function showCampDetails(camp_id, action)
{
	_oPop = window.open("camp_stat_details.jsp?a=" + action + "&camp_id=" + camp_id, "CampDetails", "resizable=yes, directories=0, location=0, menubar=0, scrollbars=1, status=0, toolbar=0, height=350, width=450");
}

</SCRIPT>


</BODY>
</HTML>

