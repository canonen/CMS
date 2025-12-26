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
<%! static Logger logger = null;%>
<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%
 if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
    String date = request.getParameter("activity_date");
    Customer customer = new Customer();
    String custId = customer.getCustomerId();

    Statement stmt = null;
    ResultSet rs = null;
    ResultSet sr = null;
    ResultSet crs = null;
    ConnectionPool cp = null;
    Connection conn = null;
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();

    try {
        double conversion_rate = 0;
        double users = 0;
        double revenue = 0;
        double revenue_customers = 0;
        double aov = 0;
        double pageview = 0;
        double rateCount=0;
        cp = ConnectionPool.getInstance(custId);
        conn = cp.getConnection();
        stmt = conn.createStatement();
        if(date == null || date == "") {
            date = "week";
            String sql = "select conversion_rate,users,revenue,revenue_customers,aov,pageview"+
                "from rque_cust_order_day "+
                "where activity_date > dateadd("+date+" , -1, getdate())"+
                "and activity_date <= getdate();";
            rs = stmt.executeQuery(sql);
            while(rs.next()) {
                conversion_rate += rs.getDouble(1);
                users += rs.getDouble(2);
                revenue += rs.getDouble(3);
                revenue_customers += rs.getDouble(4);
                aov += rs.getDouble(5);
                pageview += rs.getDouble(6);
                rateCount++;
            }
            rs.close();
            jsonObject.put("conversion_rate", conversion_rate/rateCount);
            jsonObject.put("users", users);
            jsonObject.put("revenue", revenue);
            jsonObject.put("revenue_customers", revenue_customers);
            jsonObject.put("aov", aov);
            jsonObject.put("pageview", pageview);
            }

        String sql = "SELECT conversion_rate, users, revenue, revenue_customers, aov, pageview"+
            "FROM rque_cust_order_day"+
            "WHERE activity_date > DATEADD(DAY, -1, '"+date+"')"+
            "AND activity_date <= getdate();";
        rs = stmt.executeQuery(sql);
        while(rs.next()) {
            conversion_rate += rs.getDouble(1);
            users += rs.getDouble(2);
            revenue += rs.getDouble(3);
            revenue_customers += rs.getDouble(4);
            aov += rs.getDouble(5);
            pageview += rs.getDouble(6);
            rateCount++;
        }
        rs.close();
        jsonObject.put("conversion_rate", conversion_rate/rateCount);
        jsonObject.put("users", users);
        jsonObject.put("revenue", revenue);
        jsonObject.put("revenue_customers", revenue_customers);
        jsonObject.put("aov", aov);
        jsonObject.put("pageview", pageview);
    }
    jsonArray.put(jsonObject);
    out.print(jsonArray);
    catch(Exception e) {
        logger.error("Error in getting data from database", e);
    }
%>
