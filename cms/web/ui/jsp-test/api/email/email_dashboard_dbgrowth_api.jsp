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

<%@ include file="../../utilities/header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    Campaign camp = new Campaign();
//    camp.s_cust_id = sCustId;

    String dStartdate = null;
    String dEnddate = null;

    String firstDate = request.getParameter("firstDate");

    String lastDate = request.getParameter("lastDate");


    String sCustId =user.s_cust_id;

    Calendar calendar = Calendar.getInstance();


    int currentYear;
    int currentMonth;
    int currentMonthCal;
    int currentDay;

    currentYear = calendar.get(Calendar.YEAR);
    currentMonth = calendar.get(Calendar.MONTH);
    currentMonthCal = currentMonth + 1;
    currentDay = calendar.get(Calendar.DAY_OF_MONTH);


    Statement statement = null;
    ResultSet resultSet = null;
    ConnectionPool connectionPool = null;
    Connection connection = null;

    JsonObject yearUnsubCount = new JsonObject();
    JsonObject yearsTotalRecip = new JsonObject();

    JsonObject montlySubTotal = new JsonObject();

    JsonObject montlyUnsubTotal = new JsonObject();

    JsonObject daySumCountObject = new JsonObject();
    JsonObject daySumUnsubObject = new JsonObject();
    JsonObject dbGrowthObject = new JsonObject();
    JsonObject countDaily = new JsonObject();
    JsonObject countMonthly = new JsonObject();
    JsonObject countYear = new JsonObject();
    JsonArray countArr = new JsonArray();


    try{

        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();
        countArr = new JsonArray();
        String ssqlDay = "";



            ssqlDay = "SELECT DAY(summary_date) DAY, sum(sub_count) COUNT FROM ccps_db_growth_summary with(nolock) WHERE summary_date >='"+firstDate+"' AND summary_date<='"+lastDate+"' AND cust_id = " + sCustId + " GROUP BY DAY(summary_date) ORDER BY 1 ";


        resultSet = statement.executeQuery(ssqlDay);


        while (resultSet.next())
        {
            daySumCountObject = new JsonObject();


            daySumCountObject.put("day", resultSet.getString(1));
            daySumCountObject.put("sub", resultSet.getString(2));

            countArr.put(daySumCountObject);

        }
        countDaily.put("countDailySub",countArr);

        resultSet.close();
        countArr = new JsonArray();
        String sSql_unsubday = "";
        sSql_unsubday = "SELECT DAY(summary_date) DAY, sum(unsub_count) COUNT FROM ccps_db_growth_summary with(nolock) WHERE summary_date >='"+firstDate+"' AND summary_date<='"+lastDate+"' AND cust_id = " + sCustId + " GROUP BY DAY(summary_date) ORDER BY 1 ";

        resultSet = statement.executeQuery(sSql_unsubday);

        while (resultSet.next())
        {

            daySumUnsubObject = new JsonObject();

            daySumUnsubObject.put("day", resultSet.getString(1));
            daySumUnsubObject.put("unsub", resultSet.getString(2));

            countArr.put(daySumUnsubObject);

        }
        countDaily.put("countDailyUnsub",countArr);

        resultSet.close();

        countArr = new JsonArray();
        int YearCount=1;

        if(firstDate ==null){
            firstDate = new Integer(currentYear).toString();
        }
        String sSqlUserYear="SELECT YEAR(summary_date)  FROM ccps_db_growth_summary with(nolock) WHERE cust_id = " + sCustId + "  GROUP BY YEAR(summary_date) ORDER BY 1 ";
        resultSet = statement.executeQuery(sSqlUserYear);

        String select="";
        while (resultSet.next())
        {
            String x= resultSet.getString(1);
            if(x.equals(firstDate)){

                select="selected" ;
            }else{
                select="";
            }


        }
        resultSet.close();
        System.out.println(firstDate);
        String firstDateSplit = firstDate.split("-")[0];
        System.out.println(firstDateSplit);
        String sSqlUserWeek = "";
        sSqlUserWeek="IF Object_ID('TempDB..#MONTH_RECIP') IS NOT NULL  DROP TABLE #MONTH_RECIP "
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

        String sSqlUnsubWeek = "";
        sSqlUnsubWeek= "	IF Object_ID('TempDB..#MONTH_UNSUB') IS NOT NULL  DROP TABLE #MONTH_UNSUB "
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

        resultSet = statement.executeQuery(sSqlUserWeek);



        while (resultSet.next())
        {


            if (resultSet.getString(2) !=  null) {
                montlySubTotal = new JsonObject();
                montlySubTotal.put("sub", resultSet.getString(2));
                montlySubTotal.put("month", resultSet.getString(1));
               countArr.put(montlySubTotal);
            }

        }
         countMonthly.put("countMonthlySub",countArr);
        resultSet.close();
        countArr = new JsonArray();
        resultSet = statement.executeQuery(sSqlUnsubWeek);
        while (resultSet.next())
        {

            if (resultSet.getString(2) != null) {
                montlyUnsubTotal = new JsonObject();

                montlyUnsubTotal.put("month", resultSet.getString(1));

                montlyUnsubTotal.put("unsub", resultSet.getString(2));

                countArr.put(montlyUnsubTotal);
            }
        }
        countMonthly.put("countMonthlyUnsub",countArr);
        resultSet.close();

        countArr = new JsonArray();
        String sSql_years = "SELECT sum(sub_count) as Total_Recipient, YEAR(summary_date) as R_Year FROM ccps_db_growth_summary with(nolock) WHERE cust_id = " + sCustId + " GROUP BY YEAR(summary_date)  ORDER BY YEAR(summary_date) ";
        resultSet = statement.executeQuery(sSql_years);

        while (resultSet.next()) {


            yearsTotalRecip = new JsonObject();

            yearsTotalRecip.put("year", resultSet.getString(2));
            yearsTotalRecip.put("totalRecip", resultSet.getString(1));


            countArr.put(yearsTotalRecip);

        }
        countYear.put("countYearSub",countArr);
        resultSet.close();

        countArr = new JsonArray();
        String 	sSqlUnsubYears= "SELECT YEAR(summary_date) YEAR, sum(unsub_count) COUNT FROM ccps_db_growth_summary with(nolock) WHERE cust_id = " + sCustId + " GROUP BY YEAR(summary_date) ORDER BY 1";
        resultSet = statement.executeQuery(sSqlUnsubYears);

        while (resultSet.next()) {
            yearUnsubCount =new JsonObject();

            yearUnsubCount.put("year", resultSet.getString(1));
            yearUnsubCount.put("unbsub", resultSet.getString(2));

            countArr.put(yearUnsubCount);

        }
         countYear.put("countYearUnsub",countArr);
        resultSet.close();



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
            if (statement != null) statement.close();
            if (connection != null) connectionPool.free(connection);
        }
        catch (SQLException e)
        {
            e.printStackTrace();
        }
    }



%>