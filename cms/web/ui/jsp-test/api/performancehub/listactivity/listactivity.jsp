
<%@ page

        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                com.britemoon.rcp.*,
                java.sql.*,
                java.io.*,
                java.util.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.que.*,
                java.util.Calendar,
                java.math.BigDecimal,
                org.apache.log4j.Logger,
                javax.mail.*,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="org.apache.http.impl.cookie.BasicClientCookie" %>
<%@ page import="org.apache.http.client.CookieStore" %>
<%@ page import="org.apache.http.impl.client.BasicCookieStore" %>
<%@ page import="org.apache.http.client.methods.HttpPost" %>
<%@ page import="org.apache.http.cookie.Cookie" %>

<%@ include file="../../../utilities/validator.jsp"%>
<%@ include file="../header.jsp"%>



<%

boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    String sCustId =   cust.s_cust_id;
    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;


    String d_startdate = null;
    String d_enddate = null;

    String firstDate = request.getParameter("firstDate");
    String lastDate = request.getParameter("lastDate");
    String year = request.getParameter("year");

    Calendar calendar = Calendar.getInstance();


    int current_year;
    int current_month;
    int current_month_cal;
    int current_day;

    current_year = calendar.get(Calendar.YEAR);
    current_month = calendar.get(Calendar.MONTH);
    current_month_cal = current_month + 1;
    current_day = calendar.get(Calendar.DAY_OF_MONTH);

    if (year != null && !year.equals("null")){
        current_year = Integer.parseInt(year);
    }else{
        current_year = calendar.get(Calendar.YEAR);
    }

    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    String stotal_sent = null;
    BigDecimal sread_prc = null;
    BigDecimal sclick_prc = null;
    BigDecimal sbback_prc = null;



    JsonObject data = new JsonObject();
    JsonArray listActivityDataArray = new JsonArray();
    JsonArray allData = new JsonArray();

    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sSql_Send = "";

        sSql_Send = "SELECT sum(m.rque_count) ";
        sSql_Send += "FROM ccps_rque_message m WITH(NOLOCK) ";
        sSql_Send += "WHERE m.send_date >='" + firstDate + "' AND m.send_date<='" + lastDate + "' AND cust_id = " + sCustId;


        rs = stmt.executeQuery(sSql_Send);


        while (rs.next()) {
            data = new JsonObject();
            if (!rs.getString(1).equals("null") && rs.getString(1) != null) {
                stotal_sent = rs.getString(1);
            }

            data.put("totalSent", stotal_sent);
            allData.put(data);

        }
        listActivityDataArray.put(allData);
        rs.close();

        String sSql_Rate = "";
        sSql_Rate = "SELECT ";
        sSql_Rate += "	 distinctReadPrc = avg(";
        sSql_Rate += "	CASE r.sent-r.bbacks";
        sSql_Rate += "	WHEN 0 THEN 0";
        sSql_Rate += "	ELSE convert(decimal(5,1),(r.dist_reads*100.0)/(r.sent-r.bbacks))";
        sSql_Rate += "	   END),";
        sSql_Rate += "	  distinctClickPrc =avg(";
        sSql_Rate += "	   CASE r.sent-r.bbacks";
        sSql_Rate += "		WHEN 0 THEN 0";
        sSql_Rate += "		ELSE convert(decimal(5,1),(r.dist_clicks*100.0)/(r.sent-r.bbacks))";
        sSql_Rate += "	   END),";

        sSql_Rate += "	BBackPrc =avg(";
        sSql_Rate += "	CASE Sent";
        sSql_Rate += "		WHEN 0 THEN 0";
        sSql_Rate += "		ELSE convert(decimal(5,1),(BBacks*100.0)/Sent)";
        sSql_Rate += "	END)";

        sSql_Rate += "	FROM ccps_rrpt_camp_summary_and_rque_campaign as r with(nolock) ";
        sSql_Rate += " WHERE r.start_date >='" + firstDate + "' AND r.start_date<= '" + lastDate + "'  AND cust_id = " + sCustId;


        rs = stmt.executeQuery(sSql_Rate);

        allData = new JsonArray();
        while (rs.next()) {
            data = new JsonObject();

            sread_prc = rs.getBigDecimal(1);
            sclick_prc = rs.getBigDecimal(2);
            sbback_prc = rs.getBigDecimal(3);

            if (sread_prc == null) {

                sread_prc = new BigDecimal("0.00");
                data.put("readPrc",sread_prc);

            } else {

                sread_prc = sread_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
                data.put("readPrc",sread_prc);

            }
            if (sclick_prc == null) {

                sclick_prc = new BigDecimal("0.00");

                data.put("clickPrc",sclick_prc);

            } else {
                sclick_prc = sclick_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
                data.put("clickPrc",sclick_prc);
            }
            if (sbback_prc == null) {
                sbback_prc = new BigDecimal("0.00");

                data.put("bbackPrc",sbback_prc);

            } else {

                sbback_prc = sbback_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
                data.put("bbackPrc",sbback_prc);

            }

            sread_prc = sread_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
            sclick_prc = sclick_prc.setScale(2, BigDecimal.ROUND_HALF_UP);
            sbback_prc = sbback_prc.setScale(2, BigDecimal.ROUND_HALF_UP);



            allData.put(data);
        }
        listActivityDataArray.put(allData);
        rs.close();


        String sSql_day = "";
        sSql_day = "SELECT DAY(send_date) DAY, sum(rque_count) COUNT FROM ccps_rque_message with(nolock) WHERE send_date >='"+firstDate+"' AND send_date<='"+lastDate+"' AND cust_id = " + sCustId +" GROUP BY DAY(send_date) ORDER BY 1 ";

        rs = stmt.executeQuery(sSql_day);

        int iCount_D = 0;
        String sDay_D			=null;
        String sTotal_D			=null;

        allData = new JsonArray();
        while (rs.next())
        {
            data = new JsonObject();

            sDay_D 		= rs.getString(1);
            sTotal_D 	= rs.getString(2);

            data.put("day",sDay_D);
            data.put("total",sTotal_D);



            allData.put(data);
        }
        listActivityDataArray.put(allData);
        rs.close();


        String sSql_openday = "";

        sSql_openday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND click_time >='"+firstDate+"' AND click_time<='"+lastDate+"' AND cust_id = " + sCustId +" GROUP BY DAY(click_time) ORDER BY 1 ";
        rs= stmt.executeQuery(sSql_openday);

        String sTotal_open 	= "";
        allData = new JsonArray();
        while (rs.next())
        {
            data = new JsonObject();

            sDay_D 			= rs.getString(1);
            sTotal_open 	= rs.getString(2);

            data.put("day",sDay_D);
            data.put("totalOpen",sTotal_open);


            allData.put(data);
        }
        listActivityDataArray.put(allData);
        rs.close();
        String sSql_clickday = "";


        sSql_clickday = "SELECT DAY(click_time) DAY, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND click_time >='"+firstDate+"' AND click_time<='"+lastDate+"' AND cust_id = " + sCustId +" GROUP BY DAY(click_time) ORDER BY 1 ";
        rs= stmt.executeQuery(sSql_clickday);



        String sTotal_click 	= "";
        allData = new JsonArray();
        while (rs.next())
        {
            data = new JsonObject();

            sDay_D 		= rs.getString(1);
            sTotal_click 	= rs.getString(2);

            data.put("day",sDay_D);
            data.put("totalClick",sTotal_click);


            allData.put(data);
        }
        listActivityDataArray.put(allData);
        rs.close();

        String sSql = "";


        sSql = "SELECT MONTH(send_date) MONTH, sum(rque_count) COUNT FROM ccps_rque_message with(nolock) WHERE YEAR(send_date)="+current_year+" AND cust_id = " + sCustId + " GROUP BY MONTH(send_date) ORDER BY 1 ";
        rs = stmt.executeQuery(sSql);


        String sDate		=null;
        String sTotal		=null;

        allData = new JsonArray();
        while (rs.next())
        {
            data = new JsonObject();

            sDate 		= rs.getString(1);
            sTotal 		= rs.getString(2);

            data.put("month",sDate);
            data.put("totalMonth",sTotal);



            allData.put(data);
        }
        listActivityDataArray.put(allData);
        rs.close();

        String sSql_open_month = "";

        sSql_open_month= "SELECT MONTH(click_time) MONTH, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1 AND YEAR(click_time)="+current_year+" AND cust_id = " + sCustId +" GROUP BY MONTH(click_time) ORDER BY 1";
        rs = stmt.executeQuery(sSql_open_month);

        String sTotal_open_month 	= "";

        allData = new JsonArray();
        while (rs.next())
        {
            data = new JsonObject();
            sDay_D 				= rs.getString(1);
            sTotal_open_month 	= rs.getString(2);


            data.put("month",sDay_D);
            data.put("totalOpenMonth",sTotal_open_month);


            allData.put(data);
        }
        listActivityDataArray.put(allData);
        rs.close();

        String sSql_click_month = "";

        sSql_click_month= "SELECT MONTH(click_time) MONTH, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND YEAR(click_time)="+current_year+" AND cust_id = " + sCustId +" GROUP BY MONTH(click_time) ORDER BY 1";
        rs = stmt.executeQuery(sSql_click_month);


        String sTotal_click_month 	= "";
        allData = new JsonArray();
        while (rs.next())
        {

            data = new JsonObject();
            sDay_D 				= rs.getString(1);
            sTotal_click_month 	= rs.getString(2);


            data.put("month",sDay_D);
            data.put("clickMonth",sTotal_click_month);


            allData.put(data);

        }
        listActivityDataArray.put(allData);

        rs.close();

        String sqlYear = "";


        sqlYear = "SELECT sum(rque_count) as Total_Recipient, YEAR(send_date) as R_Year FROM ccps_rque_message with(nolock)  WHERE cust_id = " + sCustId + " GROUP BY YEAR(send_date)  ORDER BY YEAR(send_date) ";
        rs = stmt.executeQuery(sqlYear);


        String sDate_w		=null;
        String sTotal_w		=null;

        allData = new JsonArray();
        while (rs.next())
        {
            data = new JsonObject();
            sTotal_w 		= rs.getString(1);
            sDate_w 		= rs.getString(2);

            data.put("year",sDate_w);
            data.put("total",sTotal_w);


            allData.put(data);
        }
        listActivityDataArray.put(allData);

        rs.close();

        String sSql_open_year = "";

        sSql_open_year= "SELECT YEAR(click_time) YEAR, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=1  AND cust_id = " + sCustId + " GROUP BY YEAR(click_time) ORDER BY 1";
        rs = stmt.executeQuery(sSql_open_year);


        int iCount_open_year = 0;
        String sTotal_open_year 	= "";

        allData = new JsonArray();

        while (rs.next())
        {
            data = new JsonObject();

            sDay_D 				= rs.getString(1);
            sTotal_open_year 	= rs.getString(2);


            data.put("year",sDay_D);
            data.put("totalYearOpen",sTotal_open_year);


            allData.put(data);

        }
        listActivityDataArray.put(allData);
        rs.close();

        String sSql_click_year = "";

        sSql_click_year= "SELECT YEAR(click_time) YEAR, sum(rjtk_count) COUNT FROM ccps_rjtk_link_activity with(nolock) WHERE type_id=2 AND cust_id = " + sCustId +" GROUP BY YEAR(click_time) ORDER BY 1";
        rs = stmt.executeQuery(sSql_click_year);



        String sTotal_click_year 	= "";

        allData = new JsonArray();
        while (rs.next())
        {
            data = new JsonObject();

            sDay_D 				= rs.getString(1);
            sTotal_click_year 	= rs.getString(2);

            data.put("year",sDay_D);
            data.put("totalClickYear",sTotal_click_year);


            allData.put(data);
        }
        listActivityDataArray.put(allData);

        rs.close();

    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            System.out.println(e.getMessage());

        }
    }




    out.print(listActivityDataArray.toString());




%>
