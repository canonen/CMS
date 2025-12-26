<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.imc.*,
                com.britemoon.rcp.que.*,
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
%>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>


<%

    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", " GET, POST, PATCH, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");


    String firstDate = request.getParameter("first_date");
    String lastDate = request.getParameter("last_date");
    String sCustId = request.getParameter("cust_id");
    //String sCustId = user.s_cust_id;
    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;

    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    double conversion_rate = 0.0;
    double users = 0.0;
    double revenue = 0.0;
    double revenue_customers = 0.0;
    double aov = 0.0;
    double pageview = 0.0;
    double orders = 0.0;
    int customers = 0;
    double rateCount = 0;

    try {

        cp = ConnectionPool.getInstance(sCustId);
        conn = cp.getConnection(this);
        stmt = conn.createStatement();
        if ((firstDate == null || firstDate == "") && (lastDate == null || lastDate == "")) {
            String sDate = "week";
            String sql = "SELECT  conversion_rate,\n" +
                    "    users,\n" +
                    "    revenue,\n" +
                    "    revenue_customers,\n" +
                    "    aov,\n" +
                    "    pageview,\n" +
                    "    orders,\n" +
                    "    customers" +
                    " FROM rque_cust_order_day " +
                    " WHERE activity_date > dateadd(" + sDate + " , -1, getdate()) " +
                    " AND activity_date <= getdate();";
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conversion_rate += (rs.getObject(1) != null) ? rs.getDouble(1) : 0.0;
                users += (rs.getObject(2) != null) ? rs.getDouble(2) : 0.0;
                revenue += (rs.getObject(3) != null) ? rs.getDouble(3) : 0.0;
                revenue_customers += (rs.getObject(4) != null) ? rs.getDouble(4) : 0.0;
                aov += (rs.getObject(5) != null) ? rs.getDouble(5) : 0.0;
                pageview += (rs.getObject(6) != null) ? rs.getDouble(6) : 0.0;
                orders += (rs.getObject(7) != null) ? rs.getDouble(7) : 0.0;
                customers += (rs.getObject(8) != null) ? rs.getInt(8) : 0;
                rateCount++;
            }
            if (rateCount != 0) {
                jsonObject.put("conversion_rate", conversion_rate / rateCount);
            } else {
                jsonObject.put("conversion_rate", 0.0);
            }
            jsonObject.put("users", users);
            jsonObject.put("revenue", revenue);
            if (customers != 0) {
                jsonObject.put("revenue_customers", revenue_customers / customers);
            } else {
                jsonObject.put("revenue_customers", 0.0);
            }
            if (customers != 0) {
                jsonObject.put("aov", aov / customers);
            } else {
                jsonObject.put("aov", 0.0);
            }
            jsonObject.put("pageview", pageview);
            jsonObject.put("orders", orders);
        }
         else {
            String dateSql = " SELECT  conversion_rate,\n" +
                    "    users,\n" +
                    "    revenue,\n" +
                    "    revenue_customers,\n" +
                    "    aov,\n" +
                    "    pageview,\n" +
                    "    orders,\n" +
                    "    customers" +
                    " FROM rque_cust_order_day " +
                    " WHERE activity_date " +
                    " BETWEEN  '" + firstDate + "' " +
                    " AND '" + lastDate + "';";
            rs = stmt.executeQuery(dateSql);
            while (rs.next()) {
                conversion_rate += (rs.getObject(1) != null) ? rs.getDouble(1) : 0.0;
                users += (rs.getObject(2) != null) ? rs.getDouble(2) : 0.0;
                revenue += (rs.getObject(3) != null) ? rs.getDouble(3) : 0.0;
                revenue_customers += (rs.getObject(4) != null) ? rs.getDouble(4) : 0.0;
                aov += (rs.getObject(5) != null) ? rs.getDouble(5) : 0.0;
                pageview += (rs.getObject(6) != null) ? rs.getDouble(6) : 0.0;
                orders += (rs.getObject(7) != null) ? rs.getDouble(7) : 0.0;
                customers += (rs.getObject(8) != null) ? rs.getInt(8) : 0;
                rateCount++;
            }

            if (rateCount != 0) {
                jsonObject.put("conversion_rate", conversion_rate / rateCount);
            } else {
                jsonObject.put("conversion_rate", 0.0);
            }
            jsonObject.put("users", users);
            jsonObject.put("revenue", revenue);
            if (customers != 0) {
                jsonObject.put("revenue_customers", revenue_customers / customers);
            } else {
                jsonObject.put("revenue_customers", 0.0);
            }
            if (customers != 0) {
                jsonObject.put("aov", aov / customers);
            } else {
                jsonObject.put("aov", 0.0);
            }
            jsonObject.put("pageview", pageview);
            jsonObject.put("orders", orders);
        }

        jsonArray.put(jsonObject);
        rs.close();
        out.print(jsonArray);

    } catch (Exception exception) {
        exception.printStackTrace();
    } finally {
        if (rs != null) {
            rs.close();
        }
        if (stmt != null) {
            stmt.close();
        }
        if (conn != null) {
            conn.close();
        }
    }


%>
