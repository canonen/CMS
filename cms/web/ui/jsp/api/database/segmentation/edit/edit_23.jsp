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
	JsonObject responseData = new JsonObject();
	String sCampId = null;

	String sMode = null;

	String sStartDate = null;
	String sFinishDate = null;

	String sDiffDate = null;

	String sMainCountCompareOperation = null;
	String sMainCount = null;
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

		sMainCount = fps.getIntegerValue("main_count");
		sMainCountCompareOperation = fps.getStringValue("main_count_compare_operation");
		sDayCountCompareOperation = fps.getStringValue("day_count_compare_operation");
		sDayCount = fps.getIntegerValue("day_count");

	}
	if(sMode == null) sMode = "date_diff";

	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";

	if(sDiffDate==null) sDiffDate = "TODAY";

	if(sDayCountCompareOperation==null) sDayCountCompareOperation = "<";
	if(sMainCountCompareOperation == null) sMainCountCompareOperation = ">";
	if(sMainCount==null) sMainCount = "1";
	if(sDayCount==null) sDayCount = "30";

	responseData.put("filterType",FilterType.CAMP_SENT_WITHIN_TIME_INTERVAL);
	responseData.put("filterId",sFilterId);
	responseData.put("filterName",sFilterName);

	if("date_diff".equals(sMode)){
		responseData.put("isChecked","checked");
	}
	else responseData.put("isChecked","");

	responseData.put("diffDate",sDiffDate);
	responseData.put("sDayCount",sDayCount);
	responseData.put("sStartDate",sStartDate);
	responseData.put("sFinishDate",sFinishDate);
	responseData.put("sMainCount",sMainCount);

	if("=".equals(sMainCountCompareOperation)){
		responseData.put("mainCompareOperation","=");
		responseData.put("mainCompareOperationValue","Exactly (=)");
	}
	if(">".equals(sMainCountCompareOperation)){
		responseData.put("mainCompareOperation",">");
		responseData.put("mainCompareOperationValue","More Than (>)");
	}
	if(">=".equals(sMainCountCompareOperation)){
		responseData.put("mainCompareOperation",">=");
		responseData.put("mainCompareOperationValue","More Than Or Exactly (>=)");
	}
	if("<".equals(sMainCountCompareOperation)){
		responseData.put("mainCompareOperation","<");
		responseData.put("mainCompareOperationValue","Fewer Than (<");
	}
	if("<=".equals(sMainCountCompareOperation)){
		responseData.put("mainCompareOperation","<=");
		responseData.put("mainCompareOperationValue","Fewer Than Or Exactly (<=)");
	}


	if("=".equals(sDayCountCompareOperation)){
		responseData.put("sDayCountCompareOperation","=");
		responseData.put("sDayCountCompareOperationValue","Equal To (=)");
	}
	else if(">".equals(sDayCountCompareOperation)){
		responseData.put("sDayCountCompareOperation",">");
		responseData.put("sDayCountCompareOperationValue","Greater Than (>)");
	}
	else if(">=".equals(sDayCountCompareOperation)){
		responseData.put("sDayCountCompareOperation",">=");
		responseData.put("sDayCountCompareOperationValue","Greater Than Or Equal To (>=)");
	}
	else if("<".equals(sDayCountCompareOperation)){
		responseData.put("sDayCountCompareOperation","<");
		responseData.put("sDayCountCompareOperationValue","Less Than (<)");
	}
	else if("<=".equals(sDayCountCompareOperation)){
		responseData.put("sDayCountCompareOperation","<=");
		responseData.put("sDayCountCompareOperationValue","Less Than Or Equal To (<=)");
	}

//	JsonObject responseData= new JsonObject();
//	responseData.put("data",data);
	responseData.put("campaign",buildCampOptionsHtml(cust.s_cust_id, sCampId));
	out.println(responseData);
%>
<%!
	private static JsonArray buildCampOptionsHtml(String sCustId, String sSelectedCampId) throws Exception
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

	private static JsonArray buildOptionsHtml(String sCustId, String sSelectedCampId, Statement stmt) throws Exception
	{
		JsonArray CampainArray = new JsonArray();
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
			JsonObject data= new JsonObject();
			sId = rs.getString(1);
			b = rs.getBytes(2);
			sName = (b==null)?null:new String(b, "UTF-8");
			data.put("id",sId);
			data.put("name",sName);
			if(sId.equals(sSelectedCampId)){
				data.put("isSelected","selected");
			}
			else data.put("isSelected","selected");
			CampainArray.put(data);
		}
		rs.close();

		return CampainArray;
	}
%>