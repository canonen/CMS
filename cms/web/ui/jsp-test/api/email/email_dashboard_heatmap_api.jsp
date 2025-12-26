<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.rcp.*,
			com.britemoon.rcp.que.*,
			java.io.*,
			java.sql.*,
			java.util.*,
			org.w3c.dom.*,
			javax.mail.*,
			org.apache.log4j.Logger,
			com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			com.britemoon.rcp.imc.*,
			java.util.Calendar"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../../utilities/validator.jsp" %>
<%@ include file="../../utilities/header.jsp" %>
<%

boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    String sCustId = cust.s_cust_id;

//    String sCustId =  cust.s_cust_id;

    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;


    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet =null;
    StringBuilder reportDayTR = new StringBuilder();
    StringBuilder reportDayChart = new StringBuilder();

    StringBuilder reportTR = new StringBuilder();
    StringBuilder reportOpenChart = new StringBuilder();
    StringBuilder reportClickChart = new StringBuilder();
       JsonArray array = new JsonArray();
      JsonObject clickReportObject  = new JsonObject();
   
    JsonObject reportDayChartJSON = new JsonObject();
    JsonArray reportOpenAndDaysArray = new JsonArray();


    try {

        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        String sSqlArd	 = "select opens2,days,days_num from ccps_schedule_advisor_day_report where cust_id = " + sCustId + " order by days_num";
        resultSet = statement.executeQuery(sSqlArd);


        String Opens			="";
        String Days				="";
        String Days_Num			="";


        while (resultSet.next())
        {
             reportDayChartJSON = new JsonObject();
            Opens 		= resultSet.getString(1);
            Days		= resultSet.getString(2);
            Days_Num	= resultSet.getString(3);

            reportDayTR.append("<tr><td>"+Opens+"</td><td>"+Days+"</td><td>"+Days_Num+"</td></tr>");
            reportDayChart.append("['"+ Days +"',"+Opens+"],");
            reportDayChartJSON.put("reportDays",Days);
            reportDayChartJSON.put("reportDayOpens",Opens);
            reportOpenAndDaysArray.put(reportDayChartJSON);

        }

        resultSet.close();

        String sSql ="select hours,opens1,clicks,pct from ccps_schedule_advisor_report where cust_id = " + sCustId + " order by hours";
        resultSet = statement.executeQuery(sSql);

        String hours				="";
        String open					="";
        String clicks				="";
        String pct					="";

        while (resultSet.next())
        {
           clickReportObject = new JsonObject();
            
            hours 		= resultSet.getString(1);
            open		= resultSet.getString(2);
            clicks	= resultSet.getString(3);
            pct	= resultSet.getString(4);

            reportTR.append("<tr><td>"+hours+"</td><td>"+open+"</td><td>"+clicks+"</td><td>"+pct+"</td></tr>");
            reportOpenChart.append("['"+ hours +"',"+open+"],");

            clickReportObject.put("hour", hours );
            clickReportObject.put("clickHour",clicks);
            clickReportObject.put("open",open);
            clickReportObject.put("pct",pct);

            array.put(clickReportObject );



        }





        JsonObject JsonObject = new JsonObject();

        JsonObject.put("custId",sCustId);
     
         JsonObject.put("ReportClick_ChartArray",array);
        JsonObject.put("reportDayOpen",reportOpenAndDaysArray);
        out.print(JsonObject);

    }
    catch(Exception ex)
    {
        ex.printStackTrace(new PrintWriter(out));
    }
    finally
    {
        if (statement !=null) statement.close();
        if (connection != null) connectionPool.free(connection);
    }

%>

