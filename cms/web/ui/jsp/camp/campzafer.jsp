<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.adm.*,
		com.britemoon.cps.que.*,
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
CampApproveDAO cDAO = new CampApproveDAO();
String sActiveCampId = null;
boolean bWasSent = false;
boolean bIsApproved = false;
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
AccessPermission canUserPvDesignOptimizer = user.getAccessPermission(ObjectType.PV_DESIGN_OPTIMIZER);
AccessPermission canUserPvContentScorer = user.getAccessPermission(ObjectType.PV_CONTENT_SCORER);
AccessPermission canUserPvDeliveryTracker = user.getAccessPermission(ObjectType.PV_DELIVERY_TRACKER);
boolean canPvDesignOptimizer = ui.getFeatureAccess(Feature.PV_DESIGN_OPTIMIZER);
boolean canPvContentScorer = ui.getFeatureAccess(Feature.PV_CONTENT_SCORER);
boolean canPvDeliveryTracker = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

String sAutoQueueDailyFlag = request.getParameter("auto_queue_daily_flag");

String sCampId = request.getParameter("camp_id");
String sCampType = request.getParameter("type_id");
String sMediaType = request.getParameter("media_type_id");

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

User creator = null;
User modifier = null;

if(sCampId == null)
{
	if(sCampType == null) throw new Exception("Undefined campaign type ...");

	camp.s_type_id = sCampType;
	camp.s_media_type_id = sMediaType;

	camp_send_param = new CampSendParam();

	if("1".equals(sAutoQueueDailyFlag))
		camp_send_param.s_queue_daily_flag = "1";

	schedule = new Schedule();
	msg_header = new MsgHeader();
	camp_list = new CampList();
	camp_edit_info = new CampEditInfo();
	linked_camp = new LinkedCamp();

	creator = user;
	modifier = user;

	// === === ===

	// DnB default frequency
	// if (cust.s_cust_id.equals("32") || cust.s_cust_id.equals("33")) // FOR TESTING ONLY		
	if (cust.s_cust_id.equals("20") || cust.s_cust_id.equals("36")) // FOR PRODUCTION
	{
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

	creator = new User(camp_edit_info.s_creator_id);
	modifier = new User(camp_edit_info.s_modifier_id);
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
if(camp_send_param.s_queue_daily_weekday_mask == null )	camp_send_param.s_queue_daily_weekday_mask	= "127";

if(schedule.s_start_daily_weekday_mask == null ) schedule.s_start_daily_weekday_mask = "127";


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

	String sSql = null;

	// === === ===

	boolean	isDone		= false;
	boolean isTesting	= false;
	boolean isSending	= false;

/* for workflow processing */
     boolean isPending = false;
     boolean isPendingEdits = false;
     boolean isApprover = false;
     ApprovalRequest arRequest = null;
     if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
          arRequest = new ApprovalRequest(sAprvlRequestId);
     } else {
          arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.CAMPAIGN),camp.s_camp_id);
     }
     if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
          sAprvlRequestId = arRequest.s_approval_request_id;
          isApprover = true;
     }
/* *** */     

	int tmpType = 0;
	int tmpStatus = 0;
	int tmpMode = 0;
	String StatusCampID = null;
	String SendCampApproved = "0";

	if(camp.s_camp_id != null)
	{
		//Find out what state this campaign is in based on camps with origin_camp_id
		sSql = "EXEC usp_cque_camp_get_status_single " + camp.s_camp_id;
		
		rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			tmpType = rs.getInt(1);
			tmpStatus = rs.getInt(2);
			StatusCampID = rs.getString(3);
			SendCampApproved = rs.getString(4);
			tmpMode = rs.getInt(5);
			
			if (tmpType == 1)
			{
				//Test, see if it is in the middle of testing
				if (tmpStatus < CampaignStatus.DONE)
				{
					isTesting = true;
				}
				else
				{
					tmpStatus = CampaignStatus.DRAFT;
				}
			}
			else
			{
				//Normal campaign
				camp.s_status_id = String.valueOf(tmpStatus);
				if (tmpStatus == CampaignStatus.DRAFT)
				{
					//nothing
				} else if (tmpStatus == CampaignStatus.PENDING_APPROVAL) {
                         isPending = true;
                    }
				else if (tmpStatus == CampaignStatus.PENDING_EDITS) {
                         isPendingEdits = true;
                    }
				else if (tmpStatus < CampaignStatus.DONE || tmpStatus == CampaignStatus.CANCELLED)
				{
					isSending = true;
				}
				else
				{
					isDone = true;
				}
			}
		}
		rs.close();

          isPendingEdits = (WorkflowUtil.getPendingEditsCampId(cust.s_cust_id, camp.s_camp_id, camp.s_sample_id) != null);
	}
%>

<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<TITLE>Campaign Edit With Samples</TITLE>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script language="javascript" src="/cms/ui/js/tabscript.js" type="text/javascript"></script>
</HEAD>

<BODY<%=((!can.bWrite)?" ONLOAD='disable_forms();'":"")%> class="paging_body">

<%
int editCampId = 0;
String zSql = "SELECT camp_id FROM cque_campaign c WITH(NOLOCK) WHERE origin_camp_id = "+camp.s_camp_id;
rs = stmt.executeQuery(zSql);

while (rs.next())
	editCampId = rs.getInt("camp_id");
rs.close();
%>

<table cellspacing="0" cellpadding="4" border="0">
	<tr>
<%
if( !isDone && !isSending && !isTesting && !isPending && (!isPendingEdits || (isPendingEdits && isApprover)) && can.bWrite)
{
%>
		<td align="left" valign="middle">
			<a class="buttons-save" href="#" onClick="save();" TARGET="_self"><span>Save</span></a>
		</td>
<%
} 

if( camp.s_camp_id != null )
{
	if (can.bWrite)
	{
		%>
		<td align="left" valign="middle">
			<a class="buttons-copy" href="#" onClick="clone();" TARGET="_self"><span>Copy</span></a>
		</td>
		<%
		if(ui.getUIMode() != ui.SINGLE_CUSTOMER)
		{
			%>
		<td align="left" valign="middle">
			<a class="buttons-copy" href="#" onClick="clone2destination();"><span>Copy To Destination</span></a>
		</td>
			<%
		}
	}
		
	if (can.bDelete && !isSending && !isTesting && !isPending && (!isPendingEdits || (isPendingEdits && isApprover)))
	{
		%>
		<td align="left" valign="middle">
			<a class="buttons-idelete" href="#" onClick="if( confirm('Are you sure?') ) location.href='camp_delete.jsp?camp_id=<%=camp.s_camp_id%>'" TARGET="_self"><span>Delete</span></a>
		</td>
		<%
	}
		
	if( camp.s_type_id.equals("2") && can.bWrite && !isDone && !isSending && !isTesting && !isPending && !isPendingEdits)
	{
		if (canSampleSet)
		{
			%>
		<td align="left" valign="middle">
			&nbsp;|&nbsp;
		</td>
		<td align="left" valign="middle">
			<a href="#" class="buttons-save" onClick="create_sampleset()"><span>Save & Create SampleSet</span></a>
		</td>
		<td align="left" valign="middle">
			<a href="#" class="buttons-save" onClick="create_dynamic()"><span>Save & Create Dynamic Campaigns</span></a>
		</td>
			<%
		}
	}
}
%>
	</tr>
</table>
<BR>
<FORM METHOD="POST" NAME="FT" ACTION="camp_save.jsp" TARGET="_self">
	<INPUT TYPE="hidden" NAME="camp_id"	value="<%=HtmlUtil.escape(camp.s_camp_id)%>">
	<INPUT TYPE="hidden" NAME="type_id"	 value="<%=HtmlUtil.escape(camp.s_type_id)%>">
	<INPUT TYPE="hidden" NAME="media_type_id"	 value="<%=HtmlUtil.escape(camp.s_media_type_id)%>">
	<INPUT TYPE="hidden" NAME="pv_test_list_ids"	value="">
	<INPUT TYPE="hidden" NAME="pvhist_pv_test_type_id"	value="">
	<INPUT TYPE="hidden" NAME="pvhist_pviq"	value="">
	<INPUT TYPE="hidden" NAME="mode"	value="">
	<INPUT TYPE="hidden" NAME="filter_flag"	value="">

	<INPUT TYPE="hidden" NAME="form_flag"	value="<%=(camp.s_type_id.equals("3") && (camp.s_filter_id == null))?"1":"0"%>">

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

<table class="listTable" cellspacing="0" cellpadding="5" width="660" border="0">
	<thead>
	<tr>
		<th class="Tab_ON" id="tab6_Step1" width="150" onclick="toggleTabs('tab6_Step','block6_Step',1,4,'Tab_ON','Tab_OFF');" valign="center" nowrap align="middle">(1) Campaign Info</td>
		<th class="Tab_OFF" id="tab6_Step2" width="150" onclick="toggleTabs('tab6_Step','block6_Step',2,4,'Tab_ON','Tab_OFF');" valign="center" nowrap align="middle">(2) Testing</td>
		<th class="Tab_OFF" id="tab6_Step3" width="150" onclick="toggleTabs('tab6_Step','block6_Step',3,4,'Tab_ON','Tab_OFF');" valign="center" nowrap align="middle">(3) Schedule</td>
		<th class="Tab_OFF" id="tab6_Step4" width="150" onclick="toggleTabs('tab6_Step','block6_Step',4,4,'Tab_ON','Tab_OFF');" valign="center" nowrap align="middle">(4) Logs</td>
		<th class="Tab_CLEAR" valign="center" nowrap align="middle" width="0"></td>
	</tr>
	</thead>

	<tbody class="Edit" id="block6_Step1">
	<tr>
		<td class="Tab_GREY" valign="top" align="left" width="100%" colspan="4" style=padding:0>

			<%@ include file="camp_edit/single/tab_1.jsp"%>      
			
		</td>
	</tr>
	</tbody>
	<tbody class="Edit" id="block6_Step2" style="display:none;">
	<tr>
		<td class="Tab_GREY" valign="top" align="center" width="660" colspan="4">

		<%@ include file="camp_edit/single/tab_2.jsp"%>  
		
		</td>
	</tr>
	</tbody>
	
	<tbody class="Edit" id="block6_Step3" style="display:none;">
	<tr>
		<td class="Tab_GREY" valign="top" align="left" width="660" colspan="4">
		<%@ include file="camp_edit/single/tab_3.jsp"%>  
	</tr>
	</tbody>
	
	<tbody class="Edit" id="block6_Step4" style="display:none;">
	<tr>
		<td class="Tab_GREY" valign="top" align="left" width="660" colspan="4">
		<%@ include file="camp_edit/single/tab_4.jsp"%>  
	</tr>
	</tbody>	
	
</table>

<br><br>
<table  cellspacing="0" cellpadding="0" width="660" border="0">
	<tr>
		<td>
<%@ include file="camp_edit/single/tab_6.jsp"%>
		</td>
	</tr>
</table>

<br>

</FORM>
<br><br>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<%@ include file="camp_edit/single/js_camp_init.jsp"%>
<%@ include file="camp_edit/single/js_camp_save.jsp"%>
<%@ include file="camp_edit/single/js_date.jsp"%>
<%@ include file="camp_edit/single/js_popup.jsp"%>
<%@ include file="camp_edit/single/js_other.jsp"%>
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
