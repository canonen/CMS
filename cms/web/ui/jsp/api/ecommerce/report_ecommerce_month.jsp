<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                java.sql.*,
                java.util.Calendar,
                java.io.*,
                org.apache.log4j.Logger,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.Month" %>

<%! static Logger logger = null;%>
<% if (logger == null) {
    logger = Logger.getLogger(this.getClass().getName());
} %>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%
    String sCustId = cust.s_cust_id;
    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;


    String d_startdate = null;
    String d_enddate = null;

   // String tarih_aralik = request.getParameter("tarih_aralik");
    String firstDate = request.getParameter("first_date");
    String lastDate = request.getParameter("last_date");
    String MonthlyGrowth = request.getParameter("MonthlyGrowth");
//    if (tarih_aralik != null) {
//        String[] parts = tarih_aralik.split("-");
//        d_startdate = parts[0];
//        d_enddate = parts[1];
//    }
//    if (firstDate != null) {
//        String[] parts = firstDate.split("-");
//        d_startdate = parts[0];
//        d_enddate = parts[1];
//    }
//    if (lastDate != null) {
//    String[] parts = lastDate.split("-");
//    d_startdate = parts[0];
//    d_enddate = parts[1];
//}

    JsonObject data = new JsonObject();
    JsonArray reportEcommerceMonth = new JsonArray();
    JsonObject data1 = new JsonObject();
    JsonArray reportEcommerceMonth1 = new JsonArray();
    JsonObject data2 = new JsonObject();
    JsonArray reportEcommerceMonth2 = new JsonArray();
    JsonObject data3 = new JsonObject();
    JsonArray reportEcommerceMonth3 = new JsonArray();
    JsonArray allData = new JsonArray();


    Calendar calendar = Calendar.getInstance();


    int current_year;
    int current_month;
    int current_month_cal;
    int current_day;

    current_year = calendar.get(Calendar.YEAR);
    current_month = calendar.get(Calendar.MONTH);
    current_month_cal = current_month + 1;
    current_day = calendar.get(Calendar.DAY_OF_MONTH);


    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    StringBuilder ReportDay_Chart = new StringBuilder();
    StringBuilder ReportMonth_Chart = new StringBuilder();
    StringBuilder ReportPurchase_Chart = new StringBuilder();

    String YearOption = null;

    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sSql_day = "";


        if (firstDate != null) {

            sSql_day = "SELECT DAY(date) DAY, SUM(amount_sum) FROM untt_mbs_order_date with(nolock)WHERE cust_id = " + sCustId + " AND date >='" + firstDate + "' AND date<='" + lastDate + "' GROUP BY DAY(date) ORDER BY 1 ;";

        } else {
            sSql_day = "SELECT DAY(date) DAY, SUM(amount_sum) FROM untt_mbs_order_date with(nolock)WHERE cust_id = " + sCustId + " AND MONTH(date)=" + current_month_cal + " AND YEAR(date)=" + current_year + " GROUP BY DAY(date) ORDER BY 1 ;";
        }

        rs = stmt.executeQuery(sSql_day);

        int iCount_D = 0;
        String sDay_D = "";
        String sTotal_D = "";
        String graph_cat_d = "";
        String graph_val1_d = "";
        String daily_rev = "";


        while (rs.next()) {
            data = new JsonObject();

            sDay_D = rs.getString(1);
            sTotal_D = rs.getString(2);
            data.put("day",sDay_D);
            data.put("sTotal_D",sTotal_D);
            reportEcommerceMonth.put(data);

        }
        allData.put(reportEcommerceMonth);
        rs.close();
       if (MonthlyGrowth == null) {
            MonthlyGrowth = new Integer(current_year).toString();
        }
        String sSql_UserYear = "SELECT YEAR(summary_date)  FROM ccps_db_growth_summary with(nolock) WHERE cust_id = " + sCustId + "  GROUP BY YEAR(summary_date) ORDER BY 1 ";
        rs = stmt.executeQuery(sSql_UserYear);

        String select = "";
        while (rs.next()) {
            data1=new JsonObject();

            String x = rs.getString(1);

            data1.put("year", x);


            if (x.equals(MonthlyGrowth)) {

                select = "selected";
            } else {
                select = "";
            }
            data1.put("yearOption", YearOption);
            reportEcommerceMonth1.put(data1);
        }

        //data1.put("select", select);
        allData.put(reportEcommerceMonth1);



        rs.close();
//********************************
     /*   if (MonthlyGrowth == null) {
            MonthlyGrowth = new Integer(current_year).toString();
        }
        String sSql_UserYear = "select YEAR(date)  from untt_mbs_order_date with(nolock) \n" +
                "where cust_id = " + sCustId + " and  camp_id in (select camp_id from cque_campaign with(nolock) where cust_id = " + sCustId + " and type_id in (2,4)) and YEAR(date) is not null \n" +
                "GROUP BY YEAR(date) ORDER BY 1;";
        rs = stmt.executeQuery(sSql_UserYear);

        String select = "";
        while (rs.next()) {
            data1=new JsonObject();
            String x = rs.getString(1);
            if (x.equals(MonthlyGrowth)) {

                select = "selected";
            } else {
                select = "";
            }
            data1.put("selected",select);
            reportEcommerceMonth1.put(data1);
            out.println(reportEcommerceMonth1);
        }
        rs.close();*/

        String amountDate = "and date BETWEEN  '" + MonthlyGrowth + "-01-01' AND '" + MonthlyGrowth + "-12-31' ";


        String sSql = "";
        sSql = "select sum(amount_sum) as Total, CONVERT(VARCHAR(7), date, 111) as 'Date ' \n" +
                "from untt_mbs_order_date with(nolock) where cust_id = " + sCustId + " and  camp_id in (select camp_id from cque_campaign with(nolock) \n" +
                "where type_id in (2,4)) and cust_id = " + sCustId + "  and amount_sum is not null and date BETWEEN  '" + MonthlyGrowth + "-01-01' AND '" + MonthlyGrowth + "-12-31' " +
                "group by CONVERT(VARCHAR(7), date, 111) order by 2 ;";
        rs = stmt.executeQuery(sSql);

        int iCount = 0;
        String sDate = null;
        String sTotal = null;
        String graph_cat = "";
        String graph_val1 = "";
        String m_xxx = "";

        while (rs.next()) {
            data2 = new JsonObject();

            sDate = rs.getString(2);

            sTotal = rs.getString(1);
            data2.put("sDate",sDate.split("/"));
            data2.put("sTotal",sTotal);
            reportEcommerceMonth2.put(data2);


            iCount++;
        }


        allData.put(reportEcommerceMonth2);


        rs.close();

        String sSql_Week = "";
        sSql_Week = "SELECT sum(amount_sum) as 'Amount' , DATENAME(dw, date)  as 'days', DATEPART(dw, date) as 'Number' \n" +
                "FROM untt_mbs_order_date with(nolock) \n" +
                "WHERE amount_sum is not null and cust_id= " + sCustId + " and camp_id in (select camp_id from cque_campaign with(nolock) \n" +
                "where type_id in (2,4)and cust_id= " + sCustId + " )  GROUP BY DATENAME(dw, date), DATEPART(dw, date) ORDER BY 3 asc ; ";
        //sSql_Week = "select sum(_amount) as Total, CONVERT(VARCHAR(7), _order_date_time, 111) as 'Date ' from untt_mbs_order with(nolock) where _amount is not null group by CONVERT(VARCHAR(7), _order_date_time, 111) order by 1 ";
        rs = stmt.executeQuery(sSql_Week);

        int iCount2 = 0;
        String sDate_w = null;
        String sTotal_w = null;
        String graph_cat_w = "";
        String graph_val1_w = "";
        String xxx = "";

        while (rs.next()) {
            data3 = new JsonObject();

            sDate_w = rs.getString(2);
            sTotal_w = rs.getString(1);
            data3.put("sDate_w",sDate_w);
            data3.put("sTotal_w",sTotal_w);
            reportEcommerceMonth3.put(data3);
        }


        allData.put(reportEcommerceMonth3);
        out.print(allData);
        rs.close();



    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            logger.error("Could not clean db statement or connection", e);
        }
    }
%>

