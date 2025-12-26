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
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

// KU: Added for content logic ui
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");

    String sTargetGroupDisplay = "Target Group";
    if (String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId)) {
        sTargetGroupDisplay = "Logic Element";
    } else if (String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId)) {
        sTargetGroupDisplay = "Report Filter";
    } else {
        sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
    }

    String sFilterId = request.getParameter("filter_id");
    String sEntityId = request.getParameter("entity_id");
    String sFilterName = null;
    FilterParams fps = new FilterParams();
    if (sFilterId != null) {
        com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
        sFilterName = f.s_filter_name;
        fps.s_filter_id = sFilterId;
        fps.retrieve();
        sEntityId = fps.getIntegerValue("entity_id");
        jsonObject.put("filter_id", sFilterId);
    }
    jsonObject.put("type_id", FilterType.ENTITY);
    jsonObject.put("usage_type_id", sUsageTypeId);
    jsonObject.put("entity_id", sEntityId);
    jsonObject.put("filter_name", HtmlUtil.escape(sFilterName));

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String sSql =
                " SELECT attr_id, attr_name," +
                        " CASE" +
                        "	WHEN type_id = 10 THEN 'INTEGER'" +
                        "	WHEN type_id = 20 THEN 'STRING'" +
                        "	WHEN type_id = 30 THEN 'DATETIME'" +
                        "	WHEN type_id = 40 THEN 'IMAGE'" +
                        "	WHEN type_id = 50 THEN 'MONEY'" +
                        "	ELSE 'UMNKNOWN'" +
                        " END" +
                        " FROM cntt_entity_attr" +
                        " WHERE entity_id = " + sEntityId +
                        " AND type_id < 100" +
                        " AND ISNULL(internal_id_flag,0)=0" +
                        " ORDER BY attr_id";

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        pstmt = conn.prepareStatement(sSql);
        rs = pstmt.executeQuery();

        String sId = null;
        String sName = null;
        String sTypeName = null;
        String sCompareOperation = null;
        String sAttrValue = null;
        String sParamName = null;
        String sInputId = null;
        JsonArray jsonArr = new JsonArray();
        byte[] b = null;

        while (rs.next()) {
            try {

                sId = rs.getString(1);
                b = rs.getBytes(2);
                sName = (b == null) ? null : new String(b, "UTF-8");
                sTypeName = rs.getString(3);

                sParamName = "entity_attr_id";
                jsonObject.put("param_name", sParamName);
                jsonObject.put("id", sId);
                jsonObject.put("sName", sName);
                jsonObject.put("sTypeName", sTypeName);

                sParamName = "entity_attr_id_" + sId + "_compare_operation";
                jsonObject.put("param_name", sParamName);

                sCompareOperation = fps.getStringValue(sParamName);

                // Diğer karşılaştırma durumlarını buraya ekleyin

                sParamName = "entity_attr_id_" + sId + "_value";
                jsonObject.put("param_name", sParamName);

                sAttrValue = fps.getStringValue(sParamName);
                jsonObject.put("sAttrValue", HtmlUtil.escape(sAttrValue));

                sParamName = "entity_attr_id_" + sId + "_value2";
                sInputId = "entity_input_id_" + sId + "_value2";
                jsonObject.put("param_name", sParamName);

                sAttrValue = fps.getStringValue(sParamName);

                jsonObject.put("sInputId", sInputId);
                jsonObject.put("sAttrValue", HtmlUtil.escape(sAttrValue));
                jsonObject.put("sCompareOperation", ("between".equals(sCompareOperation) ? "" : "none"));
                jsonArr.put(jsonObject);
            } catch (Exception e) {
                logger.error("An error occurred while processing result set:", e);
            }
        }
        jsonObject.put("jsonArr", jsonArr);
        jsonArray.put(jsonObject);
        out.print(jsonArray);
    } catch (Exception ex) {
        logger.error("An error occurred:", ex);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException sqle) {
            logger.error("An error occurred while closing resources:", sqle);
        }
    }
%>
