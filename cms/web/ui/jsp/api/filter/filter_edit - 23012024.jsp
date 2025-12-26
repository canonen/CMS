<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			com.britemoon.cps.ctl.*,
			java.io.*,java.sql.*,java.util.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"	
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>

<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}


JsonObject jsonObject  = new JsonObject();
JsonArray jsonArray = new JsonArray();
boolean bSTANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);

String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) sSelectedCategoryId = ui.s_category_id;

String sFilterId = BriteRequest.getParameter(request, "filter_id");

//Sinan Celik 2018-08-18
String referer = BriteRequest.getParameter(request, "referer");

// KO: Added for content filter support
String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");
String sLogicId = BriteRequest.getParameter(request, "logic_id");
String sParentContId = BriteRequest.getParameter(request, "parent_cont_id");

//KU: Added for content logic ui
boolean bIsTargetGroup = true;
String sTargetGroupDisplay = "Target Group";
if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Logic Element";
	bIsTargetGroup = false;
}
else if(String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Report Filter";
	bIsTargetGroup = false;
}
else
{
	sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
}

boolean canSupReq = ui.getFeatureAccess(Feature.SUPPORT_REQUEST);

// === === ===

com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter();
FilterEditInfo filter_edit_info = new FilterEditInfo();
User creator = null;
User modifier = null;

boolean bIsNewFilter = false;
String s_recip_qty = null;
String s_last_update_date = null;

if(sFilterId == null)
{
	filter.s_filter_name = "New " + sTargetGroupDisplay;
	filter.s_type_id = String.valueOf(FilterType.MULTIPART);
	filter.s_cust_id = cust.s_cust_id;
	filter.s_status_id = String.valueOf(FilterStatus.NEW);
	filter.s_usage_type_id = String.valueOf(FilterUsageType.REGULAR);
	
	creator = user;
	modifier = user;

     bIsNewFilter = true;
	s_recip_qty = "";
	s_last_update_date = "";
}
else
{
	filter.s_filter_id = sFilterId;
	if(filter.retrieve() < 1) return;

	filter_edit_info.s_filter_id = filter.s_filter_id;
	filter_edit_info.retrieve();

	creator = new User(filter_edit_info.s_creator_id);
	modifier = new User(filter_edit_info.s_modifier_id);
	
	FilterStatistic filter_stat = new FilterStatistic(filter.s_filter_id);
	s_recip_qty = (filter_stat.s_recip_qty == null) ?"Unknown": filter_stat.s_recip_qty;
	s_last_update_date = (filter_stat.s_finish_date == null) ?"Unknown": filter_stat.s_finish_date;
}

int iStatusId = Integer.parseInt(filter.s_status_id);

boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.FILTER);
String sAprvlRequestId = request.getParameter("aprvl_request_id");
boolean isApprover = false;
String sAprvlStatusFlag = null;
if (sFilterId != null) {
     if (sAprvlRequestId == null)
          sAprvlRequestId = "";
     ApprovalRequest arRequest = null;
     if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
          arRequest = new ApprovalRequest(sAprvlRequestId);
     } else {
          arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.FILTER),sFilterId);
     }
     if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
          sAprvlRequestId = arRequest.s_approval_request_id;
          isApprover = true;
     }
}

boolean bCanEditParts = true;
if ((bWorkflow && iStatusId == FilterStatus.PENDING_APPROVAL) || "-1".equals(filter.s_aprvl_status_flag)) {
     bCanEditParts = false;
}

    JsonArray data = new JsonArray();
	ConnectionPool cp = null;
	Connection conn = null;
	Statement	stmt = null;
	ResultSet	rs = null; 
	String sSQL = null;
    
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		sSQL =
			" SELECT attr_id, filter_usage" +
			" FROM ccps_attr_calc_props" +
			" WHERE cust_id = '" + cust.s_cust_id + "'" + 
			" AND calc_values_flag in (1,2) " + 
			" AND filter_usage in (1,2)";

			rs = stmt.executeQuery(sSQL);

		String sAttrID = "";
		String sFilterUsage = "";
		String saveArr = "";
					
		for(int i = 0; rs.next(); i++)
		{
			sAttrID = "";
			sFilterUsage = "";
			saveArr = "";
			
			sAttrID = rs.getString(1);
			sFilterUsage = rs.getString(2);
			
			saveArr = sAttrID + ";" + sFilterUsage;
			
			data.put(saveArr);
		}
		jsonObject.put("values", data);
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally { if(conn!=null) cp.free(conn); }

    jsonObject.put("disposition_id", "0");
	jsonObject.put("object_type", String.valueOf(ObjectType.FILTER));
	jsonObject.put("object_id", (sFilterId != null)?sFilterId:"0");
	jsonObject.put("usage_type_id", (sUsageTypeId!=null)?sUsageTypeId:String.valueOf(FilterUsageType.REGULAR));
	jsonObject.put("aprvl_request_id", sAprvlRequestId);
    jsonObject.put("usage_type_id", (sUsageTypeId!=null)?sUsageTypeId:"");
	jsonObject.put("logic_id", (sLogicId!=null)?sLogicId:"");
	jsonObject.put("parent_cont_id", (sParentContId!=null)?sParentContId:"");
	if (filter.s_filter_id !=null ) { 
          jsonObject.put("filter_id", filter.s_filter_id);
	}
 	jsonObject.put("filter_name", (filter.s_filter_name!=null)?filter.s_filter_name:"");
    jsonObject.put("category_id", (sSelectedCategoryId!=null)?sSelectedCategoryId:"");
    if (bIsTargetGroup) { 
    if( iStatusId == FilterStatus.NEW ) { 
	jsonObject.put("statusMessage", "Once you update this Target Group, either by clicking the Save &amp; Update button " +
	"or clicking the Update link from the main target group list page, " +
	"relevant information about the status of your target group will appear here.");

	}
	else if ( iStatusId == FilterStatus.PENDING_APPROVAL ) {
		jsonObject.put("statusMessage", "This Target Group is currently pending approval.");
	}
	else if ( iStatusId == FilterStatus.QUEUED_FOR_PROCESSING || iStatusId == FilterStatus.PROCESSING ) {
		jsonObject.put("statusMessage", "The Target Group is currently processing. You cannot make changes to it until after processing is completed.");
	}
	else if ( iStatusId == FilterStatus.READY ) {
		jsonObject.put("statusMessage", "When last updated, this Target Group included " + s_recip_qty + " records.<br><br>Click the Save &amp; Update button to recalculate the record count.");
        if(!("0".equals(s_recip_qty))){
			if (canTGPreview) {
				
			}
		}
	}
	else if ( iStatusId == FilterStatus.PROCESSING_ERROR ) {
        if(canSupReq){}
	}
    jsonObject.put("creator_user_name",creator.s_user_name);
	jsonObject.put("creator_last_name",creator.s_last_name);
	jsonObject.put("modifier_user_name",modifier.s_user_name);
	jsonObject.put("modifier_last_name",modifier.s_last_name);
	jsonObject.put("create_date",filter_edit_info.s_create_date);
	jsonObject.put("modify_date",filter_edit_info.s_modify_date);

	jsonArray.put(jsonObject);

	out.print(jsonArray);
}
%>




