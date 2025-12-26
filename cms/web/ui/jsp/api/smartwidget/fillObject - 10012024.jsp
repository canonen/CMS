<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			java.sql.*,
			java.util.Calendar,
			java.io.*,
			org.apache.log4j.Logger,
			java.text.DateFormat,
			org.json.JSONObject,
			org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.Vector" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ include file="../validator.jsp"%>
<%@ include file="../header.jsp"%>

<%

    String sCustId = cust.s_cust_id;
    String popup_id = request.getParameter("popup_id");


    Statement		stmt= null;
    ResultSet resultSet = null;
    ConnectionPool	cp= null;
    Connection		conn= null;
    JsonObject data = new JsonObject();
    JsonArray array= new JsonArray();

%>
<%
    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

    
        String totalViewSqlQuery = "SELECT form_id, config_param, popup_id, popup_name FROM c_smart_widget_config WHERE cust_id =" + cust.s_cust_id + " AND popup_id ='" + popup_id + "'";


        resultSet = stmt.executeQuery(totalViewSqlQuery);

        while (resultSet.next()) {
            
            data = new JsonObject();
            data.put("formId", resultSet.getString(1));
            data.put("configParam", resultSet.getString(2));
            data.put("popupId",resultSet.getString(3));
            data.put("popupName",resultSet.getString(4));
            array.put(data);
            

        }
    out.print(array);
        resultSet.close();
        


    }catch (Exception exception){
        System.out.println(sCustId + exception.getMessage());
        exception.printStackTrace();

    }finally {
        if (stmt !=null) {
            stmt.close();
            conn.close();
        }
    }


%>