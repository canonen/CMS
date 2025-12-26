<%@  page language="java"
          import="java.net.*,
                  com.britemoon.*,
                  com.britemoon.rcp.*,
                  com.britemoon.rcp.imc.*,
                  com.britemoon.rcp.que.*,
                  java.sql.*,
                  java.util.Map,
                  java.util.HashMap,
                  java.util.HashSet,
                  java.util.Iterator,
                  org.json.JSONArray,
                  org.json.JSONException,
                  org.json.JSONObject,
                  java.util.Date,
                  java.io.*,
                  java.math.BigDecimal,
                  java.text.NumberFormat,
                  java.util.Locale,
                  java.io.*,
                  org.apache.log4j.Logger,
                  org.w3c.dom.*"
          contentType="text/html;charset=UTF-8"
%>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", " GET, POST, PATCH, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>
<%
    String cust_id = request.getParameter("cust_id");
%>
<%
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    if (cust_id == null)
        return;

    ConnectionPool cp = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {

        cp = ConnectionPool.getInstance(cust_id);
        conn = cp.getConnection("get_product_filter_attributes.jsp");
        String sql = null;

        Map<String, Long> attributeMap = new HashMap<String, Long>();
        JSONArray attributeArray = new JSONArray();

        sql = "select attr_name, is_list from rrcp_product_attribute with(nolock)";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            String attrName = rs.getString(1);
            Long isList = rs.getLong(2);
            attributeMap.put(attrName, isList);
        }

        pstmt.close();
        rs.close();

        JSONArray arr = new JSONArray();
        for (Map.Entry<String, Long> entry : attributeMap.entrySet()) {
            String attrName = entry.getKey();
            Long isList = entry.getValue();
            if (isList == 1L) {
                sql = "declare @tblname varchar(255) \n" +
                        "declare @clmname varchar(255) \n" +
                        "declare @sql varchar(255) \n" +
                        "set @tblname = (select table_name from rrcp_product_attribute a with(nolock) left join rrcp_product_data_type d with(nolock) on a.type_id = d.type_id where a.is_list = 1 and a.attr_name = ?) \n" +
                        "set @clmname = (select column_name from rrcp_product_attribute a with(nolock) left join rrcp_product_data_type d with(nolock) on a.type_id = d.type_id where a.is_list = 1 and a.attr_name = ?) \n" +
                        "set @sql = 'select t.attr_value, a.attr_name, a.attr_id from ' + @tblname + ' t with(nolock) left join rrcp_product_attribute a with(nolock) on t.attr_id = a.attr_id' \n" +
                        "execute(@sql)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, attrName);
                pstmt.setString(2, attrName);
                rs = pstmt.executeQuery();

                JSONObject attributeObj = new JSONObject();
                JSONArray paramsArray = new JSONArray();
                JSONObject paramsObj = new JSONObject();
                JSONArray elementsArray = new JSONArray();

                while (rs.next()) {
                    String value = rs.getString(1);
                    String name = rs.getString(2);
                    elementsArray.put(new JSONObject("{\"name\":\"" + value + "\",\"value\":\"" + value + "\"}"));
                }

                paramsObj.put("type", "list");
                paramsObj.put("elements", elementsArray);

                paramsArray.put(new JSONObject("{\"type\":\"list\",\"elements\":[{\"name\":\"IS\",\"value\":\"IS\"},{\"name\":\"IS NOT\",\"value\":\"IS NOT\"}]}"));
                paramsArray.put(paramsObj);

                attributeObj.put("name", attrName);
                attributeObj.put("params", paramsArray);
                arr.put(attributeObj);
            } else {
                sql = "select operation_id, sql_name from rrcp_recommendation_compare_operation with(nolock)";
                pstmt = conn.prepareStatement(sql);
                rs = pstmt.executeQuery();

                JSONObject attributeObj = new JSONObject();
                JSONArray paramsArray = new JSONArray();
                JSONObject paramsObj = new JSONObject();
                JSONArray elementsArray = new JSONArray();

                while (rs.next()) {
                    String operationId = rs.getString(1);
                    String sqlName = rs.getString(2);
                    elementsArray.put(new JSONObject("{\"name\":\"" + sqlName + "\",\"value\":\"" + operationId + "\"}"));
                }

                paramsObj.put("type", "list");
                paramsObj.put("elements", elementsArray);

                paramsArray.put(new JSONObject("{\"type\":\"list\",\"elements\":[{\"name\":\"IS\",\"value\":\"IS\"},{\"name\":\"IS NOT\",\"value\":\"IS NOT\"}]}"));
                paramsArray.put(paramsObj);
                paramsArray.put(new JSONObject("{\"type\":\"text\"}"));

                attributeObj.put("name", attrName);
                attributeObj.put("params", paramsArray);
                arr.put(attributeObj);


            }
            pstmt.close();
            rs.close();
        }
        out.println(arr.toString());
    } catch (Exception e) {
        throw e;
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) cp.free(conn);
    }

%>