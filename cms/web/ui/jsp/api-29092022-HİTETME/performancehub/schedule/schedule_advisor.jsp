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
<%
    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    StringBuilder ReportDay_TR = new StringBuilder();
    StringBuilder ReportDay_Chart = new StringBuilder();

    StringBuilder Report_TR = new StringBuilder();
    StringBuilder ReportOpen_Chart = new StringBuilder();
    StringBuilder ReportClick_Chart = new StringBuilder();
    JsonObject data = new JsonObject();
    JsonArray arrayData = new JsonArray();

    String sCustId = request.getParameter("custId");

    if (!sCustId.equals("null") &&  sCustId != null){


    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sSql_ard = "select opens2,days,days_num from ccps_schedule_advisor_day_report where cust_id = " + sCustId + " order by days_num";
        rs = stmt.executeQuery(sSql_ard);


        String Opens = "";
        String Days = "";
        String Days_Num = "";


        while (rs.next()) {

            data  = new JsonObject();
            Opens = rs.getString(1);
            Days = rs.getString(2);
            Days_Num = rs.getString(3);

            data.put("open",Opens);
            data.put("days",Days);
            data.put("daysNum",Days_Num);

            arrayData.put(data);

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
            data = new JsonObject();

            Hours 		= rs.getString(1);
            Open		= rs.getString(2);
            Clicks	= rs.getString(3);
            Pct	= rs.getString(4);

            data.put("hours",Hours);
            data.put("open",Open);
            data.put("clicks",Clicks);
            data.put("pct",Pct);

            arrayData.put(data);
        }
        rs.close();

    } catch (Exception ex) {
        ex.printStackTrace(new PrintWriter(out));
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }




    out.print(arrayData.toString());


    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");
    }else{
        System.out.println("custId null");
        out.print("custId null");
    }

%>