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

	String sAggregateFunction = null;
	String sAggregateAttrId = null;

	String sCompareOperation = null;
	String sCompareValue = null;

	String sStartDate = null;
	String sFinishDate = null;

	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		FilterParams fps = new FilterParams();
		fps.s_filter_id = sFilterId;
		fps.retrieve();

		sAggregateFunction = fps.getStringValue("aggregate_function");
		sAggregateAttrId = fps.getStringValue("aggregate_attr_id");

		sCompareOperation = fps.getStringValue("compare_operation");
		sCompareValue = fps.getIntegerValue("compare_value");

		sStartDate = fps.getStringValue("start_date");
		sFinishDate = fps.getStringValue("finish_date");

	}
	if(sAggregateFunction==null) sAggregateFunction = "SUM";

	if(sCompareOperation == null) sCompareOperation = ">";
	if(sCompareValue==null) sCompareValue = "0";

	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";

	data.put("filterType",FilterType.ATTR_HISTORY_AGGREGATION_WITHIN_TIME_INTERVAL);
	data.put("filterId",sFilterId);
	data.put("filterName",sFilterName);


	data.put("sCompareValue",sCompareValue);
	data.put("sStartDate",sStartDate);
	data.put("sFinishDate",sFinishDate);

	if("=".equals(sCompareOperation)){
		data.put("sCompareOperation","=");
	}
	else if(">".equals(sCompareOperation)){
		data.put("sCompareOperation",">");
	}
	else if(">=".equals(sCompareOperation)){
		data.put("sCompareOperation",">=");
	}
	else if("<".equals(sCompareOperation)){
		data.put("sCompareOperation","<");
	}
	else if("<=".equals(sCompareOperation)){
		data.put("sCompareOperation","<=");
	}
	array.put(data);

	CustAttrs attrs = CustAttrsUtil.retrieve4filter(cust.s_cust_id, sFilterId, DataType.INTEGER);
	CustAttr ca = null;
	for(Enumeration e = attrs.elements(); e.hasMoreElements(); )
	{
		data = new JsonObject();
		ca = (CustAttr) e.nextElement();
		data.put("attrId",ca.s_attr_id);
		data.put("displayName",ca.s_display_name);
		array.put(data);
	}

	data = new JsonObject();

	if("SUM".equals(sAggregateFunction)){
		data.put("sAggregateFunction","SUM");
	}
	else if("COUNT".equals(sAggregateFunction)){
		data.put("sAggregateFunction","COUNT");
	}
	else if("MIN".equals(sAggregateFunction)){
		data.put("sAggregateFunction","MIN");
	}
	else if("MAX".equals(sAggregateFunction)){
		data.put("sAggregateFunction","MAX");
	}
	array.put(data);

	out.println(array);
%>
