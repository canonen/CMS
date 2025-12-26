    <%@ page
            language="java"
            import="com.britemoon.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.imc.*,
                com.britemoon.rcp.que.*,
                java.sql.DriverManager,
                java.sql.*,
                java.util.Calendar,
                java.util.Date,java.io.*,
                java.math.BigDecimal,
                java.text.NumberFormat,
                java.util.Locale,
                java.io.*,
                org.apache.log4j.Logger,
                org.w3c.dom.*"
            contentType="text/html;charset=UTF-8"
    %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}



String sCampId = request.getParameter("camp_id");
String sCustId = request.getParameter("cust_id");


//Connection
ConnectionPool	cp   = null;
Connection		conn = null;
Statement		stmt = null;
ResultSet       rs   = null;
String          sql  = null;

JsonObject object = new JsonObject();
JsonArray array = new JsonArray();

try
{
    cp = ConnectionPool.getInstance(sCustId);
    if(cp==null || sCustId==null ){
       out.println("Cust ID Bulunmamadi");
       return;
    }
    conn = cp.getConnection(this);
    stmt = conn.createStatement();
    String queryString = "Select * from rque_camp_stat_detail where camp_id="+sCampId+"";
    rs=stmt.executeQuery(queryString);
    System.out.println("dsfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfds");
    while(rs.next()){
        object =  new JsonObject();
        object.put("detailName",rs.getString(3));
        object.put("value",rs.getInt(4));
        array.put(object);
    }

    rs.close();
    out.print(array);
}
catch(Exception ex)
{
	System.out.println(ex);
}

%>
