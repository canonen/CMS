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
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>

<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%
    String sCustId = cust.s_cust_id;
    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;


    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    String sSql = "";
    JsonObject jsonObject = new JsonObject();
    String   cust_id = request.getParameter("cust_id");
    String   camp_id = request.getParameter("camp_id");
    String   cache_id = request.getParameter("cache_id");
    String   sCache = request.getParameter("sCache");

    Integer campId = null;
    Integer attrId = null ;
    String attrName = null;
    Integer optouts = null ;
    Double optoutPrc = null;

    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        out.print(cust_id);
        sSql = " EXEC usp_crpt_camp_optouts   " +camp_id+","+","+cache_id+","+sCache+"";
        resultSet = statement.executeQuery(sSql);
        while (resultSet.next()){
            campId = resultSet.getInt(1);
            attrId = resultSet.getInt(2);
            attrName = resultSet.getString(3);
            optouts = resultSet.getInt(4);
            optoutPrc =resultSet.getDouble(5);



        }

        jsonObject.put("campId",campId);
        jsonObject.put("attrId",attrId);
        jsonObject.put("attrName",attrName);
        jsonObject.put("optouts",optouts);
        jsonObject.put("optoutPrc",optoutPrc);
        resultSet.close();

    }catch (Exception exception){
        System.out.println(exception.getMessage());
        exception.printStackTrace();
    }

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");






%>