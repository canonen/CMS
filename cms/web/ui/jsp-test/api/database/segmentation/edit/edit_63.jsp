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
<%@ include file="../../../../utilities/validator.jsp"%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

//KU: Added for content logic ui
JsonObject jsonObject = new JsonObject();
JsonArray jsonArray = new JsonArray();
String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");

String sTargetGroupDisplay = "Target Group";
if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Logic Element";
}
else
{
	sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
}
	

	String sFilterId = request.getParameter("filter_id");	
	String sFilterName = null;
	
	String sMode = null;	
	String sMainCountCompareOperation = null;
	String sMainCount = null;
	
	String sStartDate = null;
	String sFinishDate = null;
	
	String sDiffDate = null;
		
	String sDayCountCompareOperation = null;	
	String sDayCount = null;
	
	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		FilterParams fps = new FilterParams();
		fps.s_filter_id = sFilterId;
		fps.retrieve();

		sMainCountCompareOperation = fps.getStringValue("main_count_compare_operation");
		sMainCount = fps.getIntegerValue("main_count");

		sMode = fps.getStringValue("mode");

		sStartDate = fps.getStringValue("start_date");
		sFinishDate = fps.getStringValue("finish_date");
		sDiffDate = fps.getStringValue("diff_date");

		sDayCountCompareOperation = fps.getStringValue("day_count_compare_operation");
		sDayCount = fps.getIntegerValue("day_count");

		jsonObject.put("filter_id", sFilterId);
	}
	if(sMainCountCompareOperation == null) sMainCountCompareOperation = ">";
	if(sMainCount==null) sMainCount = "1";

	if(sMode == null) sMode = "date_diff";
		
	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";
	
	if(sDiffDate==null) sDiffDate = "TODAY";	

	if(sDayCountCompareOperation==null) sDayCountCompareOperation = "<";
	if(sDayCount==null) sDayCount = "30";

	jsonObject.put("type_id", FilterType.READ_X_PERCENT_MESSAGES_DURING_TIME_INTERVAL);

    if("=".equals(sMainCountCompareOperation)){
		jsonObject.put("main_count_compare_operation", "=");
	}
	if(">".equals(sMainCountCompareOperation)){
		jsonObject.put("main_count_compare_operation", ">");
	}
	if(">=".equals(sMainCountCompareOperation)){
		jsonObject.put("main_count_compare_operation", ">=");
	}
	if("<".equals(sMainCountCompareOperation)){
		jsonObject.put("main_count_compare_operation", "<");
	}
	if("<=".equals(sMainCountCompareOperation)){
		jsonObject.put("main_count_compare_operation", "<=");
	}
    jsonObject.put("main_count", sMainCount);
    jsonObject.put("link_count", sMainCount);
	jsonObject.put("date_diff", (("date_diff".equals(sMode))?" checked":""));
	jsonObject.put("diff_date", sDiffDate);
	
	if("=".equals(sDayCountCompareOperation)){
		jsonObject.put("day_count_compare_operation", "=");
	}
	if(">".equals(sDayCountCompareOperation)){
		jsonObject.put("day_count_compare_operation", ">");
	}
	if(">=".equals(sDayCountCompareOperation)){
		jsonObject.put("day_count_compare_operation", ">=");
	}
	if("<".equals(sDayCountCompareOperation)){
		jsonObject.put("day_count_compare_operation", "<");
	}
	if("<=".equals(sDayCountCompareOperation)){
		jsonObject.put("day_count_compare_operation", "<=");
	}
	jsonObject.put("day_count", sDayCount);
	jsonObject.put("start_finish", (("start_finish".equals(sMode))?" checked":""));
    jsonObject.put("start_date", sStartDate);
	jsonObject.put("finish_date", sFinishDate);
	jsonObject.put("filter_name", sFilterName);

	jsonArray.put(jsonObject);
	out.print(jsonArray);
%>

