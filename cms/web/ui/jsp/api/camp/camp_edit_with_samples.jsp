<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			java.text.*,org.apache.log4j.*"
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
if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

// **********JM
AccessPermission canApprove = user.getAccessPermission(ObjectType.CAMPAIGN_APPROVAL);
// ********** JM

boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
boolean canFromAddrPers = ui.getFeatureAccess(Feature.FROM_ADDR_PERS);
boolean canFromNamePers = ui.getFeatureAccess(Feature.FROM_NAME_PERS);
boolean canSubjectPers = ui.getFeatureAccess(Feature.SUBJECT_PERS);
boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);
boolean canSampleSet = ui.getFeatureAccess(Feature.SAMPLE_SET);
boolean canStep2 = ui.getFeatureAccess(Feature.CAMP_STEP_2);
boolean canStep3 = ui.getFeatureAccess(Feature.CAMP_STEP_3);
boolean canQueueStep = ui.getFeatureAccess(Feature.QUEUE_STEP);
boolean canSpecTest = ui.getFeatureAccess(Feature.SPECIFIED_TEST);
boolean canTestHelp = ui.getFeatureAccess(Feature.TESTING_HELP);
boolean isHyatt = ui.getFeatureAccess(Feature.HYATT);

boolean bUseSampleset = true;
%>

<%
String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

String sCampId = request.getParameter("camp_id");
String sCampType = request.getParameter("type_id");

String sAprvlRequestId = request.getParameter("aprvl_request_id");
if (sAprvlRequestId == null)
     sAprvlRequestId = "";

// === === ===

Campaign camp = new Campaign();

CampEditInfo camp_edit_info = null;
CampList camp_list = null;
CampSendParam camp_send_param = null;
MsgHeader msg_header = null;
Schedule schedule = null;
LinkedCamp linked_camp = null;
FilterStatistic filter_statistic = null;

User creator = null;
User modifier = null;

CampSampleset camp_sampleset = null;

if(sCampId == null)
{
	if(sCampType == null) throw new Exception("Undefined campaign type ...");

	camp.s_type_id = sCampType;

	camp_send_param = new CampSendParam();
	schedule = new Schedule();
	msg_header = new MsgHeader();
	camp_list = new CampList();
	camp_edit_info = new CampEditInfo();
	linked_camp = new LinkedCamp();
	filter_statistic = new FilterStatistic();

	creator = user;
	modifier = user;

	// === === ===

	// DnB default frequency
	if (cust.s_cust_id.equals("20") || cust.s_cust_id.equals("36")) // FOR PRODUCTION
	{
//	if (cust.s_cust_id.equals("32") || cust.s_cust_id.equals("33"))  // FOR TESTING ONLY
//	{
		if (camp.s_type_id.equals("2")) camp_send_param.s_camp_frequency = "15";
	}
}
else
{
	camp = new Campaign();
	camp.s_camp_id = sCampId;
	if(camp.retrieve() < 1) throw new Exception("Campaign does not exist");
	
	camp_send_param = new CampSendParam(sCampId);
	schedule = new Schedule(sCampId);
	msg_header = new MsgHeader(sCampId);
	camp_list = new CampList(sCampId);
	camp_edit_info = new CampEditInfo(sCampId);
	linked_camp = new LinkedCamp(sCampId);
	filter_statistic = new FilterStatistic(camp.s_filter_id);

	creator = new User(camp_edit_info.s_creator_id);
	modifier = new User(camp_edit_info.s_modifier_id);

	camp_sampleset = new CampSampleset(sCampId);
}

// === SET DEFAULTS ===

if(camp.s_camp_name == null) camp.s_camp_name = "New campaign";
if(camp.s_status_id == null) camp.s_status_id = String.valueOf(CampaignStatus.DRAFT);

if(camp_send_param.s_recip_qty_limit == null)			camp_send_param.s_recip_qty_limit			= "0";
if(camp_send_param.s_randomly == null)					camp_send_param.s_randomly					= "0";
if(camp_send_param.s_delay == null)						camp_send_param.s_delay						= "0";
if(camp_send_param.s_limit_per_hour == null)			camp_send_param.s_limit_per_hour			= "0";
if(camp_send_param.s_msg_per_email821_limit == null)	camp_send_param.s_msg_per_email821_limit	= "0";
if(camp_send_param.s_msg_per_recip_limit != null )		camp_send_param.s_msg_per_recip_limit 		= "1";

// === SET MEDIA TYPE DEFAULTS ===

boolean isPrintCampaign = false;
if (camp.s_media_type_id != null && camp.s_media_type_id.equals("2")) {
	isPrintCampaign = true;
	canFromAddrPers = false;
	canFromNamePers = false;
	canSubjectPers = false;
	canSpecTest = false;
	canTestHelp = false;
}

boolean isDynamicCampaign = false;
if (camp_sampleset.s_filter_flag != null && camp_sampleset.s_filter_flag.equals("1")) {
	isDynamicCampaign = true;
}
// === === ===

ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("camp_edit.jsp");
	stmt = conn.createStatement();

	boolean bWasFinalCampSent = false;
	boolean bWasSamplesetSent = false;
	boolean bWasAnythingSent = false;
	boolean bHasUnapprovedCamps = false;
	
	String sShowSampleStatus = "&nbsp;";

	boolean isTesting = false;
	boolean isSending = false;
	boolean bIsDone = false;

/* for workflow processing */
     boolean finalIsPending = false;
     boolean samplesArePending = false;
     boolean isFinalApprover = false;
     boolean isSamplesApprover = false;
     ApprovalRequest arRequest = null;
     ApprovalRequest arRequestSamples = null;
     if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
//          System.out.println("getting approval request dealy for:" + sAprvlRequestId);
          arRequest = new ApprovalRequest(sAprvlRequestId);
          ApprovalTask at = new ApprovalTask(arRequest.s_aprvl_id);
          if (at.s_camp_sample_flag != null && at.s_camp_sample_flag.equals("1")) {
               arRequestSamples = arRequest;
               arRequest = null;
          }
     } else {
          arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.CAMPAIGN),camp.s_camp_id,"0");
          arRequestSamples = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.CAMPAIGN),camp.s_camp_id,"1");
     }
     if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
//          sAprvlRequestId = arRequest.s_approval_request_id;
          isFinalApprover = true;
     }
     if (arRequestSamples != null && arRequestSamples.s_approver_id != null && arRequestSamples.s_approver_id.equals(user.s_user_id)) {
//          sAprvlRequestId = arRequestSamples.s_approval_request_id;
          isSamplesApprover = true;
     }
//     System.out.println("arRequest is null?:" + (arRequest == null) + ";  arRequestSamples is null?:" + (arRequestSamples == null));
/* *** */     


	String	sSql		= "";

// === === ===

%>
<HTML>
<HEAD>
<TITLE>Campaign Edit With Samples</TITLE>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
<script language="javascript" src="../../js/tab_script.js" type="text/javascript"></script>
</HEAD>

<BODY<%=((!can.bWrite)?" onload='disable_forms();'":"")%>>
<% if(camp.s_camp_id != null) { %>
<%@ include file="camp_edit/with_samples/status_description.jsp"%>
<% } %>
<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<%
		if( !bWasFinalCampSent && can.bWrite)
		{
			%>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onclick="save();">Save</a>
		</td>
			<%
		} 
		if( camp.s_camp_id != null )
		{
			if (can.bWrite)
			{
				%>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onclick="clone();">Clone</a>
		</td>
				<%
				if(ui.getUIMode() != ui.SINGLE_CUSTOMER)
				{
					%>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onclick="clone2destination();">Clone To Destination</a>
		</td>
					<%
				}
			}

			if (can.bDelete && !isSending && !isTesting)
			{
				%>
		<td align="left" valign="middle">
			<a class="deletebutton" href="#" onclick="if( confirm('Are you sure?') ) location.href='camp_delete.jsp?camp_id=<%=camp.s_camp_id%>'">Delete</a>
		</td>
				<%
			}
		}
		%>
	</tr>
</table>
<BR>
<FORM METHOD="POST" NAME="FT" ACTION="camp_save.jsp" TARGET="_self">
	<INPUT TYPE="hidden" NAME="camp_id"	value="<%=HtmlUtil.escape(camp.s_camp_id)%>">
	<INPUT TYPE="hidden" NAME="type_id"	value="<%=HtmlUtil.escape(camp.s_type_id)%>">
	<INPUT TYPE="hidden" NAME="media_type_id"	value="<%=HtmlUtil.escape(camp.s_media_type_id)%>">

	<INPUT TYPE="hidden" NAME="mode"	value="">
	<INPUT TYPE="hidden" NAME="filter_flag"	value="<%=HtmlUtil.escape(camp_sampleset.s_filter_flag)%>">
	<INPUT TYPE="hidden" NAME="form_flag"	value="<%=(camp.s_type_id.equals("3") && (camp.s_filter_id == null))?"1":"0"%>">

	<INPUT TYPE="hidden" NAME="camp_qty"	value="<%=HtmlUtil.escape(camp_sampleset.s_camp_qty)%>">
	<INPUT TYPE="hidden" NAME="sample_id"	value="">

<%-- following hidden fields are for workflow --%>
     <INPUT TYPE="hidden" NAME="object_id"	value="<%=HtmlUtil.escape(camp.s_camp_id)%>">
	<INPUT TYPE="hidden" NAME="object_type"	value="<%=String.valueOf(ObjectType.CAMPAIGN)%>">
	<INPUT TYPE="hidden" NAME="object_name"	value="<%=HtmlUtil.escape(camp.s_camp_name)%>">
	<INPUT TYPE="hidden" NAME="aprvl_request_id"	value="<%=sAprvlRequestId%>">
	<INPUT TYPE="hidden" NAME="disposition_id" value="">
<%-- *** --%>


<% if(sSelectedCategoryId!=null) { %>
	<INPUT TYPE="hidden" NAME="category_id"		value="<%=sSelectedCategoryId%>">
<% } %>
<%
	int nTabId = 0;
	int nTabHeaderId = 0;
	int nTabPageId = 0;
%>
	<table width=650 class=main cellspacing=0 cellpadding=0>
		<tr>
			<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> General Information</td>
		</tr>
	</table>
	<br>
<%@ include file="camp_edit/with_samples/step_1.jsp"%>

	<br><br>
	<table width=650 class=main cellspacing=0 cellpadding=0>
		<tr>
			<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Define Campaign</td>
		</tr>
	</table>
	<br>
	
<%@ include file="camp_edit/with_samples/step_2.jsp"%>

	<br><br>	
	<table width=650 class=main cellspacing=0 cellpadding=0>
		<tr>
			<td width=100% align="left" valign="middle" class=sectionheader>&nbsp;<b class=sectionheader>Step 3:</b> Define <%=(isDynamicCampaign?"Dynamic Campaign":"Sampleset") %> Variables</td>
		<%	if (can.bWrite && !bWasFinalCampSent && !bWasSamplesetSent && canSampleSet) { %>
			<td align="right" valign="middle" nowrap>
				&nbsp;&nbsp;<a class="subactionbutton" href="camp_sampleset_edit.jsp?camp_id=<%=camp.s_camp_id%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">Edit <%=(isDynamicCampaign?"Dynamic Campaigns":"Samples") %></a>&nbsp;&nbsp;
			</td>
		<%	} %>
		</tr>
	</table>
	<br>

<%@ include file="camp_edit/with_samples/step_3.jsp"%>

<%  if (isPrintCampaign) { %>
	<br><br>
	<table width=650 class=main cellspacing=0 cellpadding=0>
		<tr>
			<td class=sectionheader>&nbsp;<b class=sectionheader>Step 3,&nbsp;Part 2:</b> Define Your Export</td>
		</tr>
		<tr>
			<td>
<%@ include file="camp_edit/with_samples/step_3_map.jsp"%>
            </td>
		</tr>
	</table>
	<br>
<%  } %>

	<br><br>
	<table width=650 class=main cellspacing=0 cellpadding=0>
		<tr>
			<td class=sectionheader>&nbsp;<b class=sectionheader>Step 4:</b> Launch Campaign</td>
		</tr>
	</table>
	<br>
	
<%@ include file="camp_edit/with_samples/step_4.jsp"%>

	<br><br>
	<table width=650 class=main cellspacing=0 cellpadding=0>
		<tr>
			<td class=sectionheader>&nbsp;<b class=sectionheader>Logs:</b> Campaign History</td>
		</tr>
	</table>
	<br>
	
<%@ include file="camp_edit/with_samples/step_5.jsp"%>

</FORM>

<BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>&nbsp;

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<%@ include file="camp_edit/with_samples/js_camp_save.jsp"%>
<%@ include file="camp_edit/with_samples/js_date.jsp"%>
<%@ include file="camp_edit/with_samples/js_popup.jsp"%>
<%@ include file="camp_edit/with_samples/js_other.jsp"%>
</SCRIPT>

</BODY>
</HTML>
<%	
}
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn); 
}
%>

<%@ include file="camp_edit/functions.jsp"%>
<%@ include file="camp_edit/calendar.jsp"%>
