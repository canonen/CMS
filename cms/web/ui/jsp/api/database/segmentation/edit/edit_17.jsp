<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.tgt.*,
			java.io.*,java.sql.*,
			java.util.*,org.w3c.dom.*,
			org.apache.log4j.*"
		errorPage="../../error_page.jsp"
		contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../../validator.jsp"%>
<%@ include file="../../header.jsp"%>
<%! static Logger logger = null; %>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

//KU: Added for content logic ui
	String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");

	String sTargetGroupDisplay = "Target Group";
	if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
	{
		sTargetGroupDisplay = "Logic Element";
	}
	else if(String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId))
	{
		sTargetGroupDisplay = "Report Filter";
	}
	else
	{
		sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
	}


	String sFilterId = request.getParameter("filter_id");
	String sFilterName = null;

    String sCustomerId = null;
    String sFilterStatusId = null;
    String sOriginFilterId = null;
    String sApprovalStatusFlag = null;

	String sMode = null;
	String sMainCountCompareOperation = null;
	String sMainCount = null;

	String sStartDate = null;
	String sFinishDate = null;

	String sDiffDate = null;

	String sDayCountCompareOperation = null;
	String sDayCount = null;
	JsonObject data = new JsonObject();
	JsonObject customerData = new JsonObject();
	JsonArray array = new JsonArray();

	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		FilterParams fps = new FilterParams();
		fps.s_filter_id = sFilterId;
		fps.retrieve();

        sCustomerId = f.s_cust_id;
        sFilterStatusId = f.s_status_id;
        sOriginFilterId = f.s_origin_filter_id;
        sApprovalStatusFlag = f.s_aprvl_status_flag;

		sMainCountCompareOperation = fps.getStringValue("main_count_compare_operation");
		sMainCount = fps.getIntegerValue("main_count");

		sMode = fps.getStringValue("mode");

		sStartDate = fps.getStringValue("start_date");
		sFinishDate = fps.getStringValue("finish_date");
		sDiffDate = fps.getStringValue("diff_date");

		sDayCountCompareOperation = fps.getStringValue("day_count_compare_operation");
		sDayCount = fps.getIntegerValue("day_count");

		if(sCustomerId != null){
		    Customer customer = new Customer(sCustomerId);
		    customerData.put("custId", customer.s_cust_id);
		    customerData.put("custName", customer.s_cust_name);
		    customerData.put("custStatusId", customer.s_status_id);
		    customerData.put("custLevelId", customer.s_level_id);
		    data.put("customer", customerData);
		}

	}
	if(sMainCountCompareOperation == null) sMainCountCompareOperation = ">";
	if(sMainCount==null) sMainCount = "1";

	if(sMode == null) sMode = "date_diff";

	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";

	if(sDiffDate==null) sDiffDate = "TODAY";

	if(sDayCountCompareOperation==null) sDayCountCompareOperation = "<";
	if(sDayCount==null) sDayCount = "30";

	data.put("filterType",FilterType.CLICK_COUNT_WITHIN_TIME_INTERVAL);
	data.put("filterId",sFilterId);
	data.put("filterName",sFilterName);

    data.put("customerId", sCustomerId);
    data.put("filterStatusId", sFilterStatusId);
    data.put("filterStatusName", (sFilterStatusId != null ? FilterStatus.getDisplayName(Integer.parseInt(sFilterStatusId)) : null));
    data.put("originFilterId", sOriginFilterId);
    data.put("approvalStatusFlag", sApprovalStatusFlag);

	if("=".equals(sMainCountCompareOperation)){
		data.put("mainCompareOperation","=");
		data.put("mainCompareOperationValue","Exactly (=)");
	}
	if(">".equals(sMainCountCompareOperation)){
		data.put("mainCompareOperation",">");
		data.put("mainCompareOperationValue","More Than (>)");
	}
	if(">=".equals(sMainCountCompareOperation)){
		data.put("mainCompareOperation",">=");
		data.put("mainCompareOperationValue","More Than Or Exactly (>=)");
	}
	if("<".equals(sMainCountCompareOperation)){
		data.put("mainCompareOperation","<");
		data.put("mainCompareOperationValue","Fewer Than (<");
	}
	if("<=".equals(sMainCountCompareOperation)){
		data.put("mainCompareOperation","<=");
		data.put("mainCompareOperationValue","Fewer Than Or Exactly (<=)");
	}

	data.put("sMainCount",sMainCount);

	if("date_diff".equals(sMode)){
		data.put("isChecked","checked");
	}
	else data.put("isChecked","");

	data.put("diffDate",sDiffDate);
	data.put("sDayCount",sDayCount);
	data.put("sStartDate",sStartDate);
	data.put("sFinishDate",sFinishDate);

	if("=".equals(sDayCountCompareOperation)){
		data.put("sDayCountCompareOperation","=");
		data.put("sDayCountCompareOperationValue","Equal To (=)");
	}
	else if(">".equals(sDayCountCompareOperation)){
		data.put("sDayCountCompareOperation",">");
		data.put("sDayCountCompareOperationValue","Greater Than (>)");
	}
	else if(">=".equals(sDayCountCompareOperation)){
		data.put("sDayCountCompareOperation",">=");
		data.put("sDayCountCompareOperationValue","Greater Than Or Equal To (>=)");
	}
	else if("<".equals(sDayCountCompareOperation)){
		data.put("sDayCountCompareOperation","<");
		data.put("sDayCountCompareOperationValue","Less Than (<)");
	}
	else if("<=".equals(sDayCountCompareOperation)){
		data.put("sDayCountCompareOperation","<=");
		data.put("sDayCountCompareOperationValue","Less Than Or Equal To (<=)");
	}
	out.println(data);
%>

