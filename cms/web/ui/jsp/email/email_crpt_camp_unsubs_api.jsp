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
    Integer levelId = null;
    String levelName = null;
    Integer unsubs = 0;
    Double unsubsPrc =null;


    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        out.print(cust_id);
        sSql = " EXEC usp_crpt_camp_unsubs  "  +camp_id+","+","+cache_id+","+sCache+"";;
        resultSet = statement.executeQuery(sSql);
        resultSet.close();
        while (resultSet.next()){
            campId = resultSet.getInt(1);
            levelId = resultSet.getInt(2);
            levelName = resultSet.getString(3);
            unsubs = resultSet.getInt(4);
            unsubsPrc = resultSet.getDouble(5);





        }

        jsonObject.put("campId",campId);
        jsonObject.put("levelId",levelId);
        jsonObject.put("levelName",levelName);
        jsonObject.put("unsubs",unsubs);
        jsonObject.put("unsubsPrc",unsubsPrc);



    }catch (Exception exception){
        System.out.println(exception.getMessage());
        exception.printStackTrace();
    }

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");






%>