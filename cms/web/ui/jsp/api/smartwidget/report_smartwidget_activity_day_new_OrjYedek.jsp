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
<%@ include file="../validator.jsp"%>
<%@ include file="../header.jsp" %>


<%

    System.out.println("--------------SMARTWIDGETREPORT----------");

   // String sCustId = request.getParameter("custId");
    String sCustId = cust.s_cust_id;
    out.println(sCustId);
    String firstDate = request.getParameter("firstDate");
    String lastDate = request.getParameter("lastDate");
    
    Statement stmt= null;
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

        Integer totalView=0;
        Integer totalSubmit=0;
        Integer totalClick = 0;
        Double totalRevenue =0.0;
	

        String totalViewSqlQuery = "select sum(impression) as totalview from ccps_smart_widget_activity_day WHERE cust_id="+sCustId+" AND activity_date >="+"'"+firstDate+"'"+" AND activity_date<="+"'"+lastDate+"'"+"";


        resultSet = stmt.executeQuery(totalViewSqlQuery);

        while (resultSet.next()) {
            totalView = resultSet.getInt(1);
            data = new JsonObject();
            data.put("totalView", totalView);
            array.put(data);
            out.print(array);

        }

        resultSet.close();
        String totalRevenueSqlQuery = "select   sum(revenue) as revenue    from ccps_smart_widget_activity_day WHERE cust_id=" +sCustId+" AND activity_date >="+"'"+ firstDate +"'"+ " AND activity_date<="+"'"+lastDate+"'"+"";


        resultSet = stmt.executeQuery(totalRevenueSqlQuery);

        while (resultSet.next()) {
            totalRevenue = resultSet.getDouble(1);
            data = new JsonObject();
            data.put("totalRevenue", totalRevenue);
            array.put(data);
            out.print(array);

        }

        resultSet.close();
        String  totalClickSqlQuery= "select  sum(activity) as click  from ccps_smart_widget_activity_day WHERE cust_id=" +sCustId+" AND activity_date >="+"'"+firstDate+"'"+" AND activity_date<="+"'"+lastDate+"'"+" AND type_name = 1";


        resultSet = stmt.executeQuery(totalClickSqlQuery);

        while (resultSet.next()) {
            totalClick = resultSet.getInt(1);
            data = new JsonObject();
            data.put("totalClick", totalClick);
            array.put(data);
            out.print(array);

        }

        resultSet.close();
        String totalSubmitSqlQuery = "select  sum(activity) as submit  from ccps_smart_widget_activity_day WHERE cust_id=" +sCustId+" AND activity_date >="+"'"+firstDate+"'"+" AND activity_date<="+"'"+lastDate+"'"+" AND type_name = 2";


        resultSet = stmt.executeQuery(totalSubmitSqlQuery);

        while (resultSet.next()) {
            totalSubmit = resultSet.getInt(1);
            data = new JsonObject();
            data.put("totalSubmit", totalSubmit);
            array.put(data);
            out.print(array);

        }
        resultSet.close();

        data = new JsonObject();
        data.put("totalClick", totalClick);
        data.put("totalView", totalView);
        data.put("totalSubmit", totalSubmit);
        data.put("totalRevenue", totalRevenue);
        array.put(data);

          out.println(array);


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