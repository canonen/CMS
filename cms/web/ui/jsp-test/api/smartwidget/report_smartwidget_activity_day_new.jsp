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
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.Vector" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>
<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp" %>


<%

   // System.out.println("--------------SMARTWIDGETREPORT----------");
    String sCustId = cust.s_cust_id;

    Service service = null;
    Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, sCustId);
    service = (Service) services.get(0);
    String rcpLink = service.getURL().getHost();


    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;


    String d_startdate = null;
    String d_enddate = null;

    String firstDate = request.getParameter("firstDate");
    String lastDate = request.getParameter("lastDate");

    String valuee = request.getParameter("oldData");
    Integer value = 0;

    value = Integer.parseInt(valuee);
    if (firstDate != null) {
        d_startdate = firstDate;
    }
    if (lastDate != null) {
        d_enddate = lastDate;
    }
   // value=(-1)*(value);

    Statement stmt = null;
    ResultSet rs = null;
    ResultSet resultSet =null ;
    ConnectionPool cp = null;
    Connection conn = null;

    JsonObject data = new JsonObject();
    JsonArray arrayData = new JsonArray();
    JsonArray smartWidgetActivityDay = new JsonArray();

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sSql_day = "";

        sSql_day = "IF Object_ID('TempDB..#t') IS NOT NULL  DROP TABLE #t "+
                "SELECT YEAR(activity_date) as YİL, MONTH(activity_date) as AY, DAY(activity_date) as GUN, count(activity_date) as COUNTS,type_name,activity,impression,revenue into #t "+
                "FROM  ccps_smart_widget_activity_day "+
                "WHERE cust_id="+sCustId+" and (activity_date BETWEEN '"+d_startdate+" 00:00:00' AND '"+d_enddate+" 23:59:59') "+
                "GROUP BY YEAR(activity_date), MONTH(activity_date),DAY(activity_date),type_name,activity,impression,revenue "+
                "ORDER BY YİL,AY,GUN,type_name "+
                "INSERT #t(YİL,AY,GUN,COUNTS,type_name) "+
                "SELECT #t.YİL,#t.AY,#t.GUN,'0','1' FROM #t "+
                "WHERE type_name='1' and #t.YİL not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='2') and #t.AY not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='2') and #t.GUN not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='2') "+
                "INSERT #t(YİL,AY,GUN,COUNTS,type_name) "+
                "SELECT #t.YİL,#t.AY,#t.GUN,'0','1' FROM #t "+
                "WHERE type_name='2' and #t.YİL not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='1') and #t.AY not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='1') and #t.GUN not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='1') "+
                "select YİL,AY,GUN,sum(activity) activitiy,sum(impression) impression,sum(revenue) revenue,type_name from #t GROUP BY YİL,AY,GUN,type_name order by YİL,AY,GUN,type_name ";


        rs = stmt.executeQuery(sSql_day);
        JsonObject currentWeek = new JsonObject();
        arrayData = new JsonArray();
        while (rs.next()) {

            data = new JsonObject();
            String year = rs.getString(1);
            String month = rs.getString(2);
            String day = rs.getString(3);
            String activity = rs.getString(4);
            String impression = rs.getString(5);
            String revenue =  rs.getString(6);
            String type_name = rs.getString(7);
            data.put("date",year+"-"+month+"-"+day);
            data.put("impression",impression);
            data.put("revenue",revenue);
            data.put("type_name",type_name);
            data.put("activity",activity);
            arrayData.put(data);
        }
        currentWeek.put("currentWeek",arrayData);
        smartWidgetActivityDay.put(currentWeek);
        rs.close();


        String sSql_week = "IF Object_ID('TempDB..#t') IS NOT NULL  DROP TABLE #t "+
                "SELECT YEAR(activity_date) as YİL, MONTH(activity_date) as AY, DAY(activity_date) as GUN, count(activity_date) as COUNTS,type_name,activity,impression,revenue into #t "+
                "FROM  ccps_smart_widget_activity_day "+
                "WHERE cust_id="+sCustId+" and (activity_date BETWEEN DATEADD(day,"+"-"+valuee+" , '"+ d_startdate + "') AND '"+d_startdate+" 23:59:59') "+
                "GROUP BY YEAR(activity_date), MONTH(activity_date),DAY(activity_date),type_name,activity,impression,revenue "+
                "ORDER BY YİL,AY,GUN,type_name "+
                "INSERT #t(YİL,AY,GUN,COUNTS,type_name) "+
                "SELECT #t.YİL,#t.AY,#t.GUN,'0','1' FROM #t "+
                "WHERE type_name='1' and #t.YİL not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='2') and #t.AY not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='2') and #t.GUN not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='2') "+
                "INSERT #t(YİL,AY,GUN,COUNTS,type_name) "+
                "SELECT #t.YİL,#t.AY,#t.GUN,'0','1' FROM #t "+
                "WHERE type_name='2' and #t.YİL not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='1') and #t.AY not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='1') and #t.GUN not in "+
                "(SELECT  #t.GUN FROM #t WHERE type_name='1') "+
                "select YİL,AY,GUN,sum(activity) activitiy,sum(impression) impression,sum(revenue) revenue,type_name from #t GROUP BY YİL,AY,GUN,type_name order by YİL,AY,GUN,type_name ";
        rs = stmt.executeQuery(sSql_week);
        JsonObject weekObject = new JsonObject();
        arrayData = new JsonArray();
        while (rs.next()) {
            data = new JsonObject();
            String year = rs.getString(1);
            String month = rs.getString(2);
            String day = rs.getString(3);
            String activity = rs.getString(4);
            String impression = rs.getString(5);
            String revenue =  rs.getString(6);
            String type_name = rs.getString(7);
            data.put("date",year+"-"+month+"-"+day);
            data.put("impression",impression);
            data.put("revenue",revenue);
            data.put("type_name",type_name);
            data.put("activity",activity);

            arrayData.put(data);
        }
        weekObject.put("weekData",arrayData);
        smartWidgetActivityDay.put(weekObject);
        rs.close();



        String sql = "select popup_id, popup_name, config_param, form_id, create_date, modify_date from c_smart_widget_config where cust_id=" + sCustId;
       // System.out.println("SQL':" + sql);

        rs = stmt.executeQuery(sql);

        arrayData = new JsonArray();
        while (rs.next()) {


            data = new JsonObject();
            String popup_id = rs.getString(1);
            String popup_name = rs.getString(2);
            String form_id = rs.getString(4);
            String create_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(5));
            String modify_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(6));

            data.put("popup_id", popup_id);
            data.put("popup_name", popup_name);
            data.put("form_id", form_id);
            data.put("create_date", create_date);
            data.put("modify_date", modify_date);

            arrayData.put(data);

        }
        smartWidgetActivityDay.put(arrayData);
        rs.close();

        Integer totalView=0;
        Integer totalSubmit=0;
        Integer totalClick = 0;
        Double totalRevenue =0.0;


        String totalViewSqlQuery = "select  sum(impression) as totalview  from ccps_smart_widget_activity_day WHERE cust_id=" +sCustId+"  AND activity_date >= DATEADD(day,"+"-"+value+", '"+ d_startdate + "')";


        resultSet = stmt.executeQuery(totalViewSqlQuery);
        arrayData = new JsonArray();
        while (resultSet.next()) {
            data = new JsonObject();
            totalView = resultSet.getInt(1);
            data.put("totalRevenue", totalRevenue);
            arrayData.put(data);
        }

        resultSet.close();
        String totalRevenueSqlQuery = "select   sum(revenue) as revenue    from ccps_smart_widget_activity_day WHERE cust_id=" +"'" +sCustId +"'"+"  AND activity_date >= DATEADD(day,"+"-"+value+", '"+ d_startdate + "')";


        resultSet = stmt.executeQuery(totalRevenueSqlQuery);

        while (resultSet.next()) {
            data = new JsonObject();
            totalRevenue = resultSet.getDouble(1);
            data.put("totalView", totalView);
            arrayData.put(data);
        }

        resultSet.close();
        String  totalClickSqlQuery= "select  sum(activity) as click  from ccps_smart_widget_activity_day WHERE cust_id=" +sCustId+"  AND activity_date >= DATEADD(day,"+"-"+value+", '"+ d_startdate + "')  and type_name = 1";


        resultSet = stmt.executeQuery(totalClickSqlQuery);

        while (resultSet.next()) {
            data = new JsonObject();
            totalClick = resultSet.getInt(1);
            data.put("totalClick", totalClick);
            arrayData.put(data);
        }

        resultSet.close();
        String totalSubmitSqlQuery = "select  sum(activity) as submit  from ccps_smart_widget_activity_day WHERE cust_id=" +sCustId+"  AND activity_date >= DATEADD(day,"+"-"+value+",'"+ d_startdate + "') and type_name = 2 ";


        resultSet = stmt.executeQuery(totalSubmitSqlQuery);

        while (resultSet.next()) {
            totalSubmit = resultSet.getInt(1);
            data = new JsonObject();
            data.put("totalSubmit", totalSubmit);
            arrayData.put(data);
        }
        resultSet.close();


        smartWidgetActivityDay.put(arrayData);

        out.println(smartWidgetActivityDay);
    }


    catch (Exception ex) {
        ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            logger.error("Could not clean db statement or connection", e);
        }
    }


%>
