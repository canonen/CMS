<%@ page language="java" import="com.britemoon.*,
                                 com.britemoon.cps.*,
                                 com.britemoon.cps.imc.*,
                                 java.sql.*,
                                 java.net.*,
                                 java.util.Calendar,
                                 java.io.*,
                                 java.util.*,
                                 java.text.DateFormat,
                                 org.apache.log4j.*" contentType="text/html;charset=UTF-8" %>
<%@ include file="../../jsp/api/validator.jsp" %>
<%@ include file="../../jsp/api/header.jsp" %>

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%
    Service service = null;
    Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
    service = (Service) services.get(0);
    String rcpUrl = service.getURL().getHost();
    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String dateBetween = request.getParameter("date_between");
    String config_param = null;
    String createUser = null;
    String modifyUser = null;
    String createUserDate = null;
    String modifyUserDate = null;
    Long status = null;
    JsonArray jsonArray = new JsonArray();


    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        String sql = "select psc.config_param,psc.status ,  " +
                "psei.creator_id as user_create_id , psei.create_date as user_create_date , " +
                "psei.modifier_id as user_modifier_id , psei.modify_date as user_modify_date " +
                " FROM c_personal_search_config as psc" +
                " LEFT JOIN c_personal_search_edit_info AS psei  ON  psei.personal_search_id = psc.id " +
                " where psc.cust_id = ?";
        pstmt = conn.prepareStatement(sql);
        int x = 1;
        pstmt.setLong(x++, Long.parseLong(cust.s_cust_id));
        rs = pstmt.executeQuery();
        if (rs.next()) {
            config_param = rs.getString(1);
            status = rs.getLong(2);
            User creatorUser = new User(rs.getString("user_create_id"));
            createUser = creatorUser.s_user_name + " " + creatorUser.s_last_name;

            createUserDate = rs.getString("user_create_date");
            User modifierUser = new User(rs.getString("user_modifier_id"));
            modifyUser = modifierUser.s_user_name + " " + modifierUser.s_last_name;
            modifyUserDate = rs.getString("user_modify_date");
        }
        JsonObject configParamObject = new JsonObject(config_param == null ? "{}" : config_param);
        JsonObject statusObject = new JsonObject();
        statusObject.put("status", status);
        statusObject.put("user_create_user", createUser);
        statusObject.put("user_create_date", createUserDate);
        statusObject.put("user_modify_user", modifyUser);
        statusObject.put("user_modify_date", modifyUserDate);
        jsonArray.put(configParamObject);
        jsonArray.put(statusObject);
        
        out.println(jsonArray);
        
        rs.close();

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
	if (pstmt != null) pstmt.close();
        if (conn != null) cp.free(conn);
    }
%>
