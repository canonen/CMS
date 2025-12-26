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
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>



<%
 
    String firstDate = request.getParameter("first_date");
    String lastDate  = request.getParameter("last_date");
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
    double conversion_rate = 0;
    double users = 0;
    double revenue = 0;
    double revenue_customers = 0;
    double aov = 0;
    double pageview = 0;
    double rateCount=0;

    try {
    
        cp = ConnectionPool.getInstance(sCustId);
        conn = cp.getConnection(this);
        stmt = conn.createStatement();
        if((firstDate == null || firstDate == "") || (lastDate == null || lastDate == "")) {
            String sDate = "week";
            String sql = "SELECT conversion_rate,users,revenue,revenue_customers,aov,pageview "+
            " FROM rque_cust_order_day "+
            " WHERE activity_date > dateadd("+sDate+" , -1, getdate()) "+
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
        else {
            String dateSql = " SELECT conversion_rate,users,revenue,revenue_customers,aov,pageview "+
                  " FROM rque_cust_order_day "+
                  " WHERE activity_date "+ 
                  " BETWEEN  '"+firstDate+"' "+
                  " AND '"+lastDate+"';";
            rs = stmt.executeQuery(dateSql);
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
        rs.close();
        jsonArray.put(jsonObject);
        out.print(jsonArray);
    }
    
    catch(Exception exception) {
        exception.printStackTrace();
    } 

    
%>
