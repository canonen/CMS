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
<%! static Logger logger = null;%>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%
    String sCustId = request.getParameter("cust_id");
    String popupId = request.getParameter("popup_id");

    String tarih_aralik  = request.getParameter("tarih_aralik");
    String MonthlyGrowth = request.getParameter("MonthlyGrowth");
    Statement		statement= null;
    ResultSet		resultSet= null;
    ConnectionPool	connectionPool= null;
    Connection		connection= null;

    String firstDate = null;
    String lastDay = null;
    if(tarih_aralik!=null){
        String[] parts = tarih_aralik.split("-");
        firstDate = parts[0];
        lastDay = parts[1];
    }
    try {

        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        String sSql_day = "";

        if (request.getParameter(firstDate) != null) {

            sSql_day = "select CONVERT(VARCHAR(10), activity_date, 120) DAY, count(*), popup_id, form_id, type_name, activity, impression, revenue from ccps_smart_widget_activity_day with(nolock) WHERE " + "cust_id=" + sCustId + " AND activity_date >='" + firstDate + "' AND activity_date<='" + lastDay + "' GROUP BY CONVERT(VARCHAR(10), activity_date, 120), popup_id, form_id, type_name, activity, impression, revenue ORDER BY 1";
            System.out.println("SQL_DAY:" + sSql_day);


        } else {

            sSql_day = "select CONVERT(VARCHAR(10), activity_date, 120) DAY, count(*), popup_id, form_id, type_name, activity, impression, revenue from ccps_smart_widget_activity_day with(nolock) WHERE " + "cust_id=" + sCustId + " AND activity_date >= DATEADD(day, -30, getdate()) GROUP BY CONVERT(VARCHAR(10), activity_date, 120), popup_id, form_id, type_name, activity, impression, revenue ORDER BY 1";
            System.out.println("SQL_DAY:" + sSql_day);
        }

         resultSet= statement.executeQuery(sSql_day);

        while (resultSet.next()) {
            String day = resultSet.getString(1);
            String count = resultSet.getString(2);
            String popup_id = resultSet.getString(3);
            String form_id = resultSet.getString(4);
            String type_name = resultSet.getString(5);
            String activity_count = resultSet.getString(6);
            String impression = resultSet.getString(7);
            String revenue = resultSet.getString(8);


        }
    } catch (Exception exception){
        exception.printStackTrace();
        System.out.println(exception.getMessage());
    }






%>