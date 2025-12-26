<%@ page
        language="java"
        import="com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			com.britemoon.rcp.*,
			com.britemoon.rcp.imc.*,
			com.britemoon.rcp.que.*,
			java.sql.*,
			java.util.Calendar,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../validator_api.jsp"%>
<%

  //  String sCustId =  cust.s_cust_id;
    Campaign camp = new Campaign();
//    camp.s_cust_id = sCustId;

    String	d_startdate = null;
    String	d_enddate = null;

    String firstDate = request.getParameter("firstDate");

    String lastDate = request.getParameter("lastDate");

    String tarih_aralik  = request.getParameter("tarih_aralik");

//    String sCustId =request.getParameter("sCustId");
    String sCustId ="420";

    if(tarih_aralik!=null){
        String[] parts = tarih_aralik.split("-");
        d_startdate = parts[0];
        d_enddate = parts[1];
    }

    Calendar calendar = Calendar.getInstance();


    int  current_year;
    int  current_month;
    int  current_month_cal;
    int  current_day;

    current_year = calendar.get(Calendar.YEAR);
    current_month = calendar.get(Calendar.MONTH);
    current_month_cal = current_month + 1;
    current_day = calendar.get(Calendar.DAY_OF_MONTH);


    Statement				stmt	= null;
    ResultSet				rs		= null;
    ConnectionPool			cp		= null;
    Connection				conn	= null;

    JsonObject yearUnsubCount = new JsonObject();
    JsonObject yearsTotalRecip = new JsonObject();

    JsonObject montlySubTotal = new JsonObject();

    JsonObject montlyUnsubTotal = new JsonObject();

    JsonObject daySumCountObject = new JsonObject();
    JsonObject daySumUnsubObject = new JsonObject();
    JsonObject dbGrowthObject = new JsonObject();
    JsonArray countDaily = new JsonArray();
    JsonArray countMonthly = new JsonArray();
    JsonArray countYear = new JsonArray();

    try{

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sSql_day = "";



            sSql_day = "SELECT DAY(summary_date) DAY, sum(sub_count) COUNT FROM ccps_db_growth_summary with(nolock) WHERE summary_date >='"+firstDate+"' AND summary_date<='"+lastDate+"' AND cust_id = " + sCustId + " GROUP BY DAY(summary_date) ORDER BY 1 ";



        rs = stmt.executeQuery(sSql_day);


        while (rs.next())
        {
            daySumCountObject = new JsonObject();


            daySumCountObject.put("day",rs.getString(1));
            daySumCountObject.put("sub",rs.getString(2));

            countDaily.put(daySumCountObject);

        }

        rs.close();

        String sSql_unsubday = "";
        sSql_unsubday = "SELECT DAY(summary_date) DAY, sum(unsub_count) COUNT FROM ccps_db_growth_summary with(nolock) WHERE summary_date >='"+firstDate+"' AND summary_date<='"+lastDate+"' AND cust_id = " + sCustId + " GROUP BY DAY(summary_date) ORDER BY 1 ";

        rs = stmt.executeQuery(sSql_unsubday);

        while (rs.next())
        {

            daySumUnsubObject = new JsonObject();

            daySumUnsubObject.put("day",rs.getString(1));
            daySumUnsubObject.put("unsub",rs.getString(2));

            countDaily.put(daySumUnsubObject);

        }

        rs.close();

        int YearCount=1;

        if(firstDate ==null){
            firstDate = new Integer(current_year).toString();
        }
        String sSql_UserYear="SELECT YEAR(summary_date)  FROM ccps_db_growth_summary with(nolock) WHERE cust_id = " + sCustId + "  GROUP BY YEAR(summary_date) ORDER BY 1 ";
        rs = stmt.executeQuery(sSql_UserYear);

        String select="";
        while (rs.next())
        {
            String x=rs.getString(1);
            if(x.equals(firstDate)){

                select="selected" ;
            }else{
                select="";
            }


        }
        rs.close();

        System.out.println(firstDate);
        String firstDateSplit = firstDate.split("-")[0];
        System.out.println(firstDateSplit);
        String sSql_User_Week = "";
        sSql_User_Week="IF Object_ID('TempDB..#MONTH_RECIP') IS NOT NULL  DROP TABLE #MONTH_RECIP "
                +"CREATE TABLE #MONTH_RECIP(  MONTH VARCHAR (100),  COUNT VARCHAR (100) )   "
                +" INSERT INTO #MONTH_RECIP "
                +" SELECT '01', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=01 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +" SELECT '02', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=02 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +" SELECT '03', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=03 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +" SELECT '04', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=04 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +" SELECT '05', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=05 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +" SELECT '06', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=06 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +" SELECT '07', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=07 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +" SELECT '08', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=08 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +" SELECT '09', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=09 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +" SELECT '10', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=10 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +" SELECT '11', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=11 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +" SELECT '12', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=12 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId
                +" SELECT * FROM #MONTH_RECIP";

        String sSql_Unsub_Week = "";
        sSql_Unsub_Week= "	IF Object_ID('TempDB..#MONTH_UNSUB') IS NOT NULL  DROP TABLE #MONTH_UNSUB "
                +"CREATE TABLE #MONTH_UNSUB(  MONTH VARCHAR (100),  COUNT VARCHAR (100) )  "
                +"INSERT INTO #MONTH_UNSUB "
                +"SELECT '01', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=01 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +"SELECT '02', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=02 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +"SELECT '03', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=03 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +"SELECT '04', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=04 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +"SELECT '05', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=05 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +"SELECT '06', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=06 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +"SELECT '07', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=07 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +"SELECT '08', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=08 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +"SELECT '09', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=09 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +"SELECT '10', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=10 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +"SELECT '11', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=11 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId + " UNION ALL "
                +"SELECT '12', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=12 and YEAR(summary_date)="+ firstDateSplit +"  AND cust_id = " + sCustId
                +"SELECT * FROM #MONTH_UNSUB ";

        rs = stmt.executeQuery(sSql_User_Week);



        while (rs.next())
        {


            if (rs.getString(2) !=  null) {
                montlySubTotal = new JsonObject();
                montlySubTotal.put("sub", rs.getString(2));
                montlySubTotal.put("month", rs.getString(1));

                countMonthly.put(montlySubTotal);
            }

        }
        rs.close();

        rs = stmt.executeQuery(sSql_Unsub_Week);
        while (rs.next())
        {

            if (rs.getString(2) != null) {
                montlyUnsubTotal = new JsonObject();

                montlyUnsubTotal.put("month", rs.getString(1));

                montlyUnsubTotal.put("unsub", rs.getString(2));

                countMonthly.put(montlyUnsubTotal);
            }
        }
        rs.close();




        String sSql_years = "SELECT sum(sub_count) as Total_Recipient, YEAR(summary_date) as R_Year FROM ccps_db_growth_summary with(nolock) WHERE cust_id = " + sCustId + " GROUP BY YEAR(summary_date)  ORDER BY YEAR(summary_date) ";
        rs = stmt.executeQuery(sSql_years);

        while (rs.next()) {


            yearsTotalRecip = new JsonObject();

            yearsTotalRecip.put("year",rs.getString(2));
            yearsTotalRecip.put("totalRecip",rs.getString(1));


            countYear.put(yearsTotalRecip);

        }
        rs.close();


        String 	sSql_unsub_years= "SELECT YEAR(summary_date) YEAR, sum(unsub_count) COUNT FROM ccps_db_growth_summary with(nolock) WHERE cust_id = " + sCustId + " GROUP BY YEAR(summary_date) ORDER BY 1";
        rs = stmt.executeQuery(sSql_unsub_years);

        while (rs.next()) {
            yearUnsubCount =new JsonObject();

            yearUnsubCount.put("year",rs.getString(1));
            yearUnsubCount.put("unbsub",rs.getString(2));

            countYear.put(yearUnsubCount);

        }
        rs.close();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");


        dbGrowthObject.put("countDaily",countDaily);

        dbGrowthObject.put("countMonthly",countMonthly);

        dbGrowthObject.put("countYear",countYear);

        out.print(dbGrowthObject);

    }


    catch(Exception ex)
    {
        ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
    }
    finally
    {
        try
        {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        }
        catch (SQLException e)
        {
            e.printStackTrace();
        }
    }



%>