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
	String sCampId = null;

	String sMode = null;

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

		sCampId = fps.getIntegerValue("camp_id");

		sMode = fps.getStringValue("mode");

		sStartDate = fps.getStringValue("start_date");

		sFinishDate = fps.getStringValue("finish_date");
		sDiffDate = fps.getStringValue("diff_date");

		sDayCountCompareOperation = fps.getStringValue("day_count_compare_operation");
		sDayCount = fps.getIntegerValue("day_count");

	}
	if(sMode == null) sMode = "date_diff";

	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";

	if(sDiffDate==null) sDiffDate = "TODAY";

	if(sDayCountCompareOperation==null) sDayCountCompareOperation = "<";
	if(sDayCount==null) sDayCount = "30";

	data.put("filterType",FilterType.CAMP_SENT_WITHIN_TIME_INTERVAL);
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

	data= new JsonObject();
	data.put("campaign",buildCampOptionsHtml(cust.s_cust_id, sCampId));
	array.put(data);
	out.println(array);
%>
<%!
	private static JsonObject buildCampOptionsHtml(String sCustId, String sSelectedCampId) throws Exception
	{
		ConnectionPool cp = null;
		Connection conn = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("select.jsp.buildOptionsHtml()");
			Statement stmt = null;
			try
			{
				stmt = conn.createStatement();
				return buildOptionsHtml(sCustId,sSelectedCampId,stmt);
			}
			catch(Exception ex) { throw ex; }
			finally { if(stmt != null) stmt.close(); }
		}
		catch(Exception ex) { throw ex; }
		finally { if(conn != null) cp.free(conn); }
	}

	private static JsonObject buildOptionsHtml(String sCustId, String sSelectedCampId, Statement stmt) throws Exception
	{
		JsonObject data = new JsonObject();

		String sId = null;
		byte[] b = null;
		String sName = null;

		String sSql =
				" SELECT camp_id, camp_name" +
						" FROM cque_campaign WITH(NOLOCK)" +
						" WHERE origin_camp_id IS NULL" +
						" AND cust_id = " + sCustId +
						" AND status_id <> " + CampaignStatus.DELETED +
						" ORDER BY camp_name";

		ResultSet rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			data= new JsonObject();
			sId = rs.getString(1);
			b = rs.getBytes(2);
			sName = (b==null)?null:new String(b, "UTF-8");
			data.put("id",sId);
			data.put("name",sName);
			if(sId.equals(sSelectedCampId)){
				data.put("isSelected","selected");
			}
			else data.put("isSelected","selected");
		}
		rs.close();

		return data;
	}
%>
