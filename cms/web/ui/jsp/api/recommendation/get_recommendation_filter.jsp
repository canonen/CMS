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
        conn = cp.getConnection("get_recommendation_filter.jsp");
        String sql = null;

        JSONArray resultArr = new JSONArray();
        Map<Long, String> filterSet = new HashMap<Long, String>();
        sql = "select filter_id,filter_name from rrcp_recommendation_filter with(nolock) where status_id not in(0,900)";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            Long filterId = rs.getLong(1);
            String filterName = new String(rs.getBytes(2), "UTF-8");
            filterSet.put(filterId, filterName);
        }
        pstmt.close();
        rs.close();

        for (Map.Entry<Long, String> filterSetEntry : filterSet.entrySet()) {
            long fId = filterSetEntry.getKey();
            String fName = filterSetEntry.getValue();


            Map<Long, JSONObject> groupMap = new HashMap<Long, JSONObject>();

            sql = "select group_id, parent_group_id, sql_name, is_excluded from rrcp_recommendation_formula_group with(nolock) where filter_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setLong(1, fId);
            rs = pstmt.executeQuery();

            Long parentGroup = null;

            while (rs.next()) {
                Long groupId = rs.getLong(1);
                Long parentGroupId = rs.getLong(2);
                String sqlName = rs.getString(3);
                int flag = rs.getInt(4);
                JSONObject obj = new JSONObject();
                obj.put("operator", sqlName);
                obj.put("flag", flag);
                obj.put("type", "group");
                obj.put("groupId", groupId);
                if (parentGroupId != null && parentGroupId > 0) obj.put("parentGroupId", parentGroupId);
                if (parentGroupId == 0L) parentGroup = groupId;
                obj.put("elements", new JSONArray());
                groupMap.put(groupId, obj);
            }

            for (Map.Entry<Long, JSONObject> entry : groupMap.entrySet()) {
                JSONObject obj = entry.getValue();

                Long parentGroupId = obj.has("parentGroupId") ? obj.getLong("parentGroupId") : null;
                if (parentGroupId != null) {
                    groupMap.get(parentGroupId).getJSONArray("elements").put(obj);
                    obj.remove("parentGroupId");
                }

            }

            pstmt.close();
            rs.close();

            sql = "select f.parent_group_id, a.attr_name, o.operation_id, f.value1, f.value2, f.positive_flag, a.is_list, f.is_excluded from rrcp_recommendation_formula f with(nolock) left join rrcp_product_attribute a with(nolock) on f.attr_id = a.attr_id left join rrcp_recommendation_compare_operation o with(nolock) on f.operation_id = o.operation_id where filter_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setLong(1, fId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Long groupId = rs.getLong(1);
                String attrName = rs.getString(2);
                String operatorId = rs.getString(3);
                String value1 = rs.getBytes(4) != null ? new String(rs.getBytes(4), "UTF-8") : null;
                String value2 = rs.getBytes(5) != null ? new String(rs.getBytes(5), "UTF-8") : null;
                int positiveFlag = rs.getInt(6);
                int isList = rs.getInt(7);
                int flag = rs.getInt(8);
                JSONObject obj = new JSONObject();
                JSONArray params = new JSONArray();
                obj.put("type", "condition");
                obj.put("f", attrName);
                obj.put("flag", flag);
                if (positiveFlag == 1) params.put("IS");
                else params.put("IS NOT");
                if (isList != 1) params.put(operatorId);
                params.put(value1);
                params.put(value2);
                obj.put("params", params);
                groupMap.get(groupId).getJSONArray("elements").put(obj);
            }

            rs.close();

            JSONObject result = groupMap.get(parentGroup);
            result.put("filterId", fId);
            result.put("filterName", fName);

            resultArr.put(result);


        }

        out.println(resultArr.toString());


    } catch (Exception e) {
        throw e;
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) cp.free(conn);
    }

%>