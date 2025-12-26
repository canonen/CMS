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
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>

<%
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);  
    String date = request.getParameter("date");
    String sCustId = request.getParameter("cust_id");
    //String sCustId = user.s_cust_id;
    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;

   

    try {
        Statement stmt = null;
        ResultSet rs = null;
        ResultSet sr = null;
        ResultSet crs = null;
        ConnectionPool cp = null;
        Connection conn = null;
        JsonObject jsonObject = new JsonObject();
        JsonArray jsonArray = new JsonArray();
        double conversion_rate = 0;
        double users = 0;
        double revenue = 0;
        double revenue_customers = 0;
        double aov = 0;
        double pageview = 0;
        double rateCount=0;

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();
    
        if(date == null || date == "") {
            date = "week";
            String sql = "SELECT conversion_rate,users,revenue,revenue_customers,aov,pageview "+
            " FROM rque_cust_order_day "+
            " WHERE activity_date > dateadd("+date+" , -1, getdate()) "+
            " AND activity_date <= getdate();";
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
            jsonObject.put("conversion_rate", conversion_rate/rateCount);
            jsonObject.put("users", users);
            jsonObject.put("revenue", revenue);
            jsonObject.put("revenue_customers", revenue_customers);
            jsonObject.put("aov", aov);
            jsonObject.put("pageview", pageview);
            }

        String sql = "SELECT conversion_rate, users, revenue, revenue_customers, aov, pageview "+
            " FROM rque_cust_order_day"+
            " WHERE activity_date > DATEADD(DAY, -1, '"+date+"') "+
            " AND activity_date <= getdate();";
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
        
        jsonArray.put(jsonObject);
        out.print(jsonArray);
    }
    
    catch(Exception exception) {
        exception.printStackTrace();
    } 
    finally{
     
    } 
    
%>
