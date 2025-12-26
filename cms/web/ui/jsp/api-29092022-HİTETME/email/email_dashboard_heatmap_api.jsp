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

<%@ include file="../validator_api.jsp"%>
<%

    String sCustId =  "420";

//    String sCustId =  cust.s_cust_id;

    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;


    ConnectionPool	cp		= null;
    Connection 		conn	= null;
    Statement		stmt	= null;
    ResultSet 		rs		=null;
    StringBuilder ReportDay_TR = new StringBuilder();
    StringBuilder ReportDay_Chart = new StringBuilder();

    StringBuilder Report_TR = new StringBuilder();
    StringBuilder ReportOpen_Chart = new StringBuilder();
    StringBuilder ReportClick_Chart = new StringBuilder();
       JsonArray array = new JsonArray();
      JsonObject clickReportObject  = new JsonObject();
   
    JsonObject reportDayChart = new JsonObject();
    JsonArray reportOpenAndDaysArray = new JsonArray();


    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sSql_ard	 = "select opens2,days,days_num from ccps_schedule_advisor_day_report where cust_id = " + sCustId + " order by days_num";
        rs = stmt.executeQuery(sSql_ard);


        String Opens			="";
        String Days				="";
        String Days_Num			="";


        while (rs.next())
        {
             reportDayChart = new JsonObject();
            Opens 		= rs.getString(1);
            Days		= rs.getString(2);
            Days_Num	= rs.getString(3);

            ReportDay_TR.append("<tr><td>"+Opens+"</td><td>"+Days+"</td><td>"+Days_Num+"</td></tr>");
            ReportDay_Chart.append("['"+ Days +"',"+Opens+"],");
            reportDayChart.put("reportDays",Days);
            reportDayChart.put("reportDayOpens",Opens);
            reportOpenAndDaysArray.put(reportDayChart);

        }

        rs.close();

        String sSql ="select hours,opens1,clicks,pct from ccps_schedule_advisor_report where cust_id = " + sCustId + " order by hours";
        rs = stmt.executeQuery(sSql);

        String Hours				="";
        String Open					="";
        String Clicks				="";
        String Pct					="";

        while (rs.next())
        {
           clickReportObject = new JsonObject();
            
            Hours 		= rs.getString(1);
            Open		= rs.getString(2);
            Clicks	= rs.getString(3);
            Pct	= rs.getString(4);

            Report_TR.append("<tr><td>"+Hours+"</td><td>"+Open+"</td><td>"+Clicks+"</td><td>"+Pct+"</td></tr>");
            ReportOpen_Chart.append("['"+ Hours +"',"+Open+"],");

            clickReportObject.put("hour", Hours );
            clickReportObject.put("clickHour",Clicks);
            clickReportObject.put("open",Open);
            clickReportObject.put("pct",Pct);

            array.put(clickReportObject );



        }



        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");

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
        if (stmt!=null) stmt.close();
        if (conn != null) cp.free(conn);
    }

%>

