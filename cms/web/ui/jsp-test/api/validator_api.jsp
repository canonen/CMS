<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.imc.*,
                com.britemoon.rcp.que.*,
                java.sql.DriverManager,
                java.sql.*,
                java.util.Calendar,
                java.util.Date,
                java.io.*,
                java.math.BigDecimal,
                java.text.NumberFormat,
                java.util.Locale,
                java.io.*,
                org.apache.log4j.Logger,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../utilities/header.jsp" %>
<%@ include file="../utilities/validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>

<%

   // String cust_id = request.getParameter("cust_id");
    String sCustId = cust.s_cust_id;
    out.println(sCustId);
    JsonArray array =new JsonArray();
    JsonObject dataOBJECT=new JsonObject();
    Statement stmt = null;
    ResultSet rs = null;
    ResultSet sr = null;
    ResultSet crs = null;
    ConnectionPool cp = null;
    Connection conn = null;


    int totalOrder = 0;
    int totalCustomer = 0;
    float totalRevenue = 0;
    float revenueCustomer = 0;
    float aov = 0;
    float avarageConversionRate = 0;
    int aTotalPageview = 0;
    int aTotalUsers = 0;
    float apageviewUser = 0;
    int activeProducts = 0;
    int inActiveProducts = 0;
    int newProducts = 0;

    StringBuilder table_reco = new StringBuilder();
    StringBuilder table_smart_widget = new StringBuilder();
    StringBuilder table_webpush = new StringBuilder();
    StringBuilder table_email = new StringBuilder();
    String currencyFormat = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        if (cp == null || sCustId == null) {
            out.println("Cust ID Bulunmamadi");
            return;
        }

        String currencyString = "select country,language,currency,format,display_sample from rrcp_language_currency where active = 1";
        crs = stmt.executeQuery(currencyString);
        if (crs.next()) {
            currencyFormat = "{\"country\":\"" + crs.getString(1) + "\",\"language\":\"" + crs.getString(2) + "\",\"currency\":\"" + crs.getString(3) + "\",\"format\":\"" + crs.getString(4) + "\",\"display_sample\":\"" + crs.getString(5) + "\"}";
        }
        crs.close();

        String queryString = "select orders, customers, revenue, revenue_customers, aov, conversion_rate, pageview, users, pageview_user" +
                " from rque_cust_order_day where activity_date > dateadd(month , -1, getdate()) and activity_date <= getdate() and type_name = 'GENERAL'";
        rs = stmt.executeQuery(queryString);
//TODO find revenueCustomer as
        int counter = 0;
        while (rs.next()) {
            totalOrder += rs.getInt(1);
            totalCustomer += rs.getInt(2);
            totalRevenue += rs.getFloat(3);
            revenueCustomer += rs.getFloat(4); //divide
            aov += rs.getFloat(5); //divide
            avarageConversionRate += rs.getFloat(6); //divide
            aTotalPageview += rs.getInt(7);
            aTotalUsers += rs.getInt(8);
            apageviewUser += rs.getFloat(9); //divide
            counter++;

        }

        DecimalFormat df = new DecimalFormat();
        DecimalFormat formatter = new DecimalFormat("##.##");
        df.setMaximumFractionDigits(2);
        apageviewUser = apageviewUser / (counter > 0 ? counter : 1);
        avarageConversionRate = avarageConversionRate / (counter > 0 ? counter : 1);
        aov = aov / (counter > 0 ? counter : 1);
        revenueCustomer = revenueCustomer / (counter > 0 ? counter : 1);
        apageviewUser = Float.parseFloat(df.format(apageviewUser).replace(",", ""));
        aov = Float.parseFloat(df.format(aov).replace(",", ""));
        avarageConversionRate = Float.parseFloat(df.format(avarageConversionRate).replace(",", ""));
        revenueCustomer = Float.parseFloat(df.format(revenueCustomer).replace(",", ""));


        String recoInfoString = "select camp_name, sum(impression) as impression, sum(activity) as activity, sum(contribution) as contribution, sum(revenue)as revenue from  rrcp_recommendation_activity_day " +
                " where activity_date < getdate() and activity_date > getdate() - 365 group by camp_id,camp_name";
        String recoInfoStringCheck = " IF (EXISTS (SELECT *  FROM INFORMATION_SCHEMA.TABLES" +
                " WHERE TABLE_NAME =\'rrcp_recommendation_activity_day\'))" +
                " BEGIN " +
                recoInfoString +
                " END" +
                " ELSE" +
                " BEGIN" +
                " select \'no info\'" +
                " END";
        sr = stmt.executeQuery(recoInfoStringCheck);
        counter = 0;
        while (sr.next() && counter < 10) {
            dataOBJECT=new JsonObject();
            String check = sr.getString(1);
            if (!check.equalsIgnoreCase("no info")) {
                String camp_name = sr.getString(1);
//            String type_name = sr.getString(2);
//            int type_id = sr.getInt(3);
                int preview_count = sr.getInt(2);
                int activity_count = sr.getInt(3);
                double ctr = 0.00;
                if (activity_count == 0 || preview_count == 0)
                    ctr = 0.00;
                else {
                    ctr = (double) (activity_count * 100) / preview_count;
                    //float ctr = (activity_count * 100) / preview_count;
                }
                //ctr = Float.parseFloat(df.format(ctr).replace(",", ""));
                ctr = Double.parseDouble(formatter.format(ctr));
                float revenue = sr.getFloat(5);
                revenue = Float.parseFloat(df.format(revenue).replace(",", ""));
                dataOBJECT.put("camp_name",camp_name);
                dataOBJECT.put("ctr", ctr);
                dataOBJECT.put("revenue",revenue);
                array.put(dataOBJECT);
                String tableLine = "";
                table_reco.append(tableLine);
                counter++;
            }
        }
        while (counter < 10) {
            String emptyLine = "";
            table_reco.append(emptyLine);
            counter++;
        }


        String smartWidgetString = "select popup_name, sum(impression) as impression, sum(activity) as activity, sum(contribution) as contribution, sum(revenue)as revenue from  rrcp_smart_widget_activity_day " +
                "where activity_date < getdate() and activity_date > getdate() - 365 group by popup_id,popup_name";
        String smartWidgetStringCheck = " IF (EXISTS (SELECT *  FROM INFORMATION_SCHEMA.TABLES" +
                " WHERE TABLE_NAME =\'rrcp_smart_widget_activity_day\'))" +
                " BEGIN " +
                smartWidgetString +
                " END" +
                " ELSE" +
                " BEGIN" +
                " select \'no info\'" +
                " END";
        rs = stmt.executeQuery(smartWidgetStringCheck);
        counter = 0;
        while (rs.next() && counter < 10) {
            dataOBJECT=new JsonObject();

            String check = rs.getString(1);
            if (!check.equalsIgnoreCase("no info")) {
                String camp_name = rs.getString(1);
                int preview_count = rs.getInt(2);
                int activity_count = rs.getInt(3);
                double ctr = 0;
                if (activity_count == 0 || preview_count == 0)
                    ctr = 0;
                else {
                    ctr = (double) (activity_count * 100) / preview_count;
                    //float ctr = (activity_count * 100) / preview_count;
                }
                //ctr = Float.parseFloat(df.format(ctr));
                ctr = Double.parseDouble(formatter.format(ctr));
                float revenue = rs.getFloat(5);

                revenue = Float.parseFloat(df.format(revenue).replace(",", ""));
                dataOBJECT.put("camp_name",camp_name);
                dataOBJECT.put("ctr", ctr);
                dataOBJECT.put("revenue",revenue);
                array.put(dataOBJECT);
                String tableLine = "";
                table_smart_widget.append(tableLine);
                counter++;
            }
        }
        while (counter < 10) {
            String emptyLine = "";
            table_smart_widget.append(emptyLine);
            counter++;
        }

        String webPushString = "select camp_id, camp_name , sum(sent), sum(activity) as activity, sum(conversion) as conversion, sum(revenue) as revenue from rrcp_webpush_activity_day  " +
                " where activity_date  > getdate() -365  and activity_date  <= getDate() group by camp_id, camp_name order by revenue desc";
        String webPushStringCheck = " IF (EXISTS (SELECT *  FROM INFORMATION_SCHEMA.TABLES" +
                " WHERE TABLE_NAME =\'rrcp_email_activity_day\'))" +
                " BEGIN " +
                webPushString +
                " END" +
                " ELSE" +
                " BEGIN" +
                " select \'no info\'" +
                " END";
        rs = stmt.executeQuery(webPushStringCheck);
        counter = 0;
        while (rs.next() && counter < 10) {
            String check = rs.getString(1);
            if (!check.equalsIgnoreCase("no info")) {
                int camp_id = rs.getInt(1);
                String camp_name = rs.getString(2);
                int delivered = rs.getInt(3);
                int tot_clicks = rs.getInt(4);
                double total = rs.getDouble(6);
                double ctr = 0;
                if (tot_clicks == 0 || delivered == 0) {
                    ctr = 0.00;
                } else {
                    ctr = (double) (tot_clicks * 100) / delivered;
                    //ctr = (tot_clicks * 100) / delivered;
                }
                //ctr = Float.parseFloat(df.format(ctr).replace(",", ""));
                ctr = Double.parseDouble(formatter.format(ctr));
                String tableLine = "";
                table_webpush.append(tableLine);
                counter++;
            }
        }

        while (counter < 10) {
            String emptyLine = "";
            table_webpush.append(emptyLine);
            counter++;
        }

        String emailString = "select camp_id, camp_name , sum(sent) as impression, sum(activity) as activity, sum(conversion) as conversion, sum(revenue) as revenue from rrcp_email_activity_day" +
                " where activity_date > getdate()-365 and activity_date <= getdate() group by camp_id, camp_name order by revenue desc";
        String emailStringCheck = " IF (EXISTS (SELECT *  FROM INFORMATION_SCHEMA.TABLES" +
                " WHERE TABLE_NAME =\'rrcp_email_activity_day\'))" +
                " BEGIN " +
                emailString +
                " END" +
                " ELSE" +
                " BEGIN" +
                " select \'no info\'" +
                " END";


        rs = stmt.executeQuery(emailStringCheck);
        counter = 0;
        while (rs.next() && counter < 10) {
            dataOBJECT=new JsonObject();

            String check = rs.getString(1);
            if (!check.equalsIgnoreCase("no info")) {
                int camp_id = rs.getInt(1);
                String camp_name = rs.getString(2);
                double total_revenue = rs.getDouble(6);
                int total_click = rs.getInt(4);
                int total_order = rs.getInt(5);
                int total_impression = rs.getInt(3);
                double ctr = 0;
                if (total_click != 0 && total_impression != 0)
                    ctr = (double) (total_click * 100) / total_impression;

                ctr = Double.parseDouble(formatter.format(ctr));

                dataOBJECT.put("camp_name",camp_name);
                dataOBJECT.put("ctr", ctr);
                dataOBJECT.put("total_order",total_order);
                dataOBJECT.put("total_click",total_click);
                dataOBJECT.put("total_revenue",total_revenue);
                array.put(dataOBJECT);
                String tableLine = "";
                //System.out.println(tableLine);
                table_email.append(tableLine);
                counter++;
            }
        }

        while (counter < 10) {

            String emptyLine = "";
            table_email.append(emptyLine);
            counter++;
        }

        String productChartString = "SELECT product_status from z_rec_products";
        String productChartStringCheck = " IF (EXISTS (SELECT *  FROM INFORMATION_SCHEMA.TABLES" +
                " WHERE TABLE_NAME =\'z_rec_products\'))" +
                " BEGIN " +
                productChartString +
                " END" +
                " ELSE" +
                " BEGIN" +
                " select \'no info\'" +
                " END";
        rs = stmt.executeQuery(productChartStringCheck);
        while (rs.next()) {
            String check = rs.getString(1);
            if (!check.equalsIgnoreCase("no info")) {
                String statu = rs.getString(1);
                if (statu.equalsIgnoreCase("ACTIVE"))
                    activeProducts++;
                else if (statu.equalsIgnoreCase("INACTIVE"))
                    inActiveProducts++;
                else if (statu.equalsIgnoreCase("NEW"))
                    newProducts++;
            }
        }

        rs.close();
        sr.close();
        stmt.close();

    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
        throw ex;
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } catch (SQLException e) {
            logger.error("Could not clean db statement or connection", e);
        }
    }


%>

