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
    else
    {
        sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
    }

    ConnectionPool cp = null;
    Connection conn = null;
    JsonObject data = new JsonObject();
    JsonArray array = new JsonArray();
    JsonObject actionData = new JsonObject();
    JsonObject dateData = new JsonObject();
    ResultSet rs =null;
    try {
        String sSql = null;
        cp = ConnectionPool.getInstance();

        String sFilterId = request.getParameter("filter_id");
        String sFilterName = null;

        String sActionType = null;

        String sMode = null;

        String sStartDate = null;
        String sFinishDate = null;

        String sDiffDate = null;

        String sDayCountCompareOperation = null;
        String sDayCount = null;

        if (sFilterId != null) {
            com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
            sFilterName = f.s_filter_name;
            FilterParams fps = new FilterParams();
            fps.s_filter_id = sFilterId;
            fps.retrieve();

            sActionType = fps.getStringValue("action_type");

            sMode = fps.getStringValue("mode");

            sStartDate = fps.getStringValue("start_date");
            sFinishDate = fps.getStringValue("finish_date");
            sDiffDate = fps.getStringValue("diff_date");

            sDayCountCompareOperation = fps.getStringValue("day_count_compare_operation");
            sDayCount = fps.getIntegerValue("day_count");

        }

        if (sMode == null) sMode = "date_diff";

        if (sStartDate == null) sStartDate = "MM/DD/YYYY";
        if (sFinishDate == null) sFinishDate = "TODAY";

        if (sDiffDate == null) sDiffDate = "TODAY";

        if (sDayCountCompareOperation == null) sDayCountCompareOperation = "<";
        if (sDayCount == null) sDayCount = "30";

        sSql = " SELECT actiontype, actionname FROM cjtk_action_type WHERE cust_id = " + cust.s_cust_id + " ORDER BY actionname";

        try {
            conn = cp.getConnection(this);

            PreparedStatement pstmt = null;
            try {
                pstmt = conn.prepareStatement(sSql);
                rs = pstmt.executeQuery();

                String sId = null;
                String sName = null;

                byte[] b = null;

                while (rs.next()) {
                    data = new JsonObject();
                    sId = rs.getString(1);
                    b = rs.getBytes(2);
                    sName = (b == null) ? null : new String(b, "UTF-8");
                    data.put("actionType", sId);
                    data.put("actionName", sName);
                    data.put("sfilterId", sFilterId);
                    data.put("sfilterName", sFilterName);
                    data.put("filterType", FilterType.BRITETRACK_DID_ACTION);
                    if (sId.equals(sActionType)) data.put("isSelected", "selected");
                    else data.put("isSelected", "");
                    data.put("TargetName", sTargetGroupDisplay);
                    array.put(data);
                }
                rs.close();
                actionData.put("actionData", array);
                out.println(actionData);




            } catch (Exception ex) {
                throw ex;
            } finally {
                if (pstmt != null) pstmt.close();
            }
        } catch (Exception ex) {
            throw new Exception(sSql + "\r\n" + ex.getMessage());

        } finally {
            if(rs != null) rs.close();
            if (conn != null) {
                cp.free(conn);
                conn = null;
            }
        }
//		JsonObject data1 = new JsonObject();
//		JsonArray array1 = new JsonArray();
//		data1.put("dateDiff", sDiffDate);
//		data1.put("dayCount", sDayCount);
//		data1.put("startDate", sStartDate);
//		data1.put("finishDate", sFinishDate);
//		array1.put(data1);
//		dateData.put("dateData", dateData);
//		out.println(dateData);

//		array = new JsonArray();
//		JsonObject compareObj = new JsonObject();
//		JsonObject compareData = new JsonObject();
//		//data.put("CompareOperation",CompareOperation.toHtmlOptions(formula.s_operation_id));
//		compareObj.put("key", "=");
//		compareObj.put("value", "10");
//		array.put(compareObj);
//		compareObj = new JsonObject();
//		compareObj.put("key", ">");
//		compareObj.put("value", "20");
//		array.put(compareObj);
//		compareObj = new JsonObject();
//		compareObj.put("key", ">=");
//		compareObj.put("value", "30");
//		array.put(compareObj);
//		compareObj = new JsonObject();
//		compareObj.put("key", "<");
//		compareObj.put("value", "40");
//		array.put(compareObj);
//		compareObj = new JsonObject();
//		compareObj.put("key", "<=");
//		compareObj.put("value", "50");
//		array.put(compareObj);
//		compareData.put("CompareData", array);
//		out.println(compareData);



    }
    finally {

    }
%>
