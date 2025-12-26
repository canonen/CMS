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
<%@ include file="../../header.jsp"%>
<%! static Logger logger = null;%>
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
	JsonObject data = new JsonObject();
	JsonArray array = new JsonArray();

	String sMode = null;

	String sStartDate = null;
	String sFinishDate = null;
	String sStartFinishAttrId = null;

	String sDiffDate = null;
	String sDiffDateAttrId = null;

	String sDayCountCompareOperation = null;
	String sDayCount = null;

	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		FilterParams fps = new FilterParams();
		fps.s_filter_id = sFilterId;
		fps.retrieve();

		sMode = fps.getStringValue("mode");

		sStartDate = fps.getStringValue("start_date");
		sFinishDate = fps.getStringValue("finish_date");

		sStartFinishAttrId = fps.getStringValue("start_finish_attr_id");

		sDiffDate = fps.getStringValue("diff_date");

		sDiffDateAttrId = fps.getStringValue("diff_date_attr_id");

		sDayCountCompareOperation = fps.getStringValue("day_count_compare_operation");
		sDayCount = fps.getIntegerValue("day_count");
	}
	if(sMode == null) sMode = "date_diff";

	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";

	if(sDiffDate==null) sDiffDate = "TODAY";

	if(sDayCountCompareOperation==null) sDayCountCompareOperation = "<";
	if(sDayCount==null) sDayCount = "30";

	data.put("filterType",FilterType.DATE_ATTR_COMPARISON);
	data.put("filterId",sFilterId);
	data.put("filterName",sFilterName);

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
	}
	else if(">".equals(sDayCountCompareOperation)){
		data.put("sDayCountCompareOperation",">");
	}
	else if(">=".equals(sDayCountCompareOperation)){
		data.put("sDayCountCompareOperation",">=");
	}
	else if("<".equals(sDayCountCompareOperation)){
		data.put("sDayCountCompareOperation","<");
	}
	else if("<=".equals(sDayCountCompareOperation)){
		data.put("sDayCountCompareOperation","<=");
	}
	array.put(data);

	CustAttrs attrs = CustAttrsUtil.retrieve4filter(cust.s_cust_id, sFilterId, DataType.DATETIME);
	CustAttr ca = null;
	for(Enumeration e = attrs.elements(); e.hasMoreElements(); )
	{
		data = new JsonObject();
		ca = (CustAttr) e.nextElement();
		data.put("attrId",ca.s_attr_id);
		data.put("displayName",ca.s_display_name);
		array.put(data);
	}

	attrs = CustAttrsUtil.retrieve4filter(cust.s_cust_id, sFilterId, DataType.DATETIME);

	ca = null;
	for(Enumeration e = attrs.elements(); e.hasMoreElements(); )
	{
		data = new JsonObject();
		ca = (CustAttr) e.nextElement();
		data.put("attrId",ca.s_attr_id);
		data.put("displayName",ca.s_display_name);
		array.put(data);
	}
	out.println(array);
%>
