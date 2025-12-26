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
    String domain = null;
    Integer sent = null ;
    Integer bbacks = null;
    Double bbackPrc = null;
    Integer reads = null ;
    Double readPrc = null;
    Integer clicks = null ;
    Double clickPrc =null ;
    Integer unsubs = null;
    Double unsubPrc = null;
    Integer spam = null;
    Double spamPrc= null;




    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        out.print(cust_id);
        sSql = " EXEC usp_crpt_camp_domains   " +camp_id+","+","+cache_id+","+sCache+"";
        resultSet = statement.executeQuery(sSql);
        while (resultSet.next()){
            campId = resultSet.getInt(1);
            domain = resultSet.getString(2);
            sent = resultSet.getInt(3);
            bbacks = resultSet.getInt(4);
            bbackPrc = resultSet.getDouble(5);
            reads = resultSet.getInt(6);
            readPrc = resultSet.getDouble(7);
            clicks =resultSet.getInt(8);
            clickPrc = resultSet.getDouble(9);
            unsubs = resultSet.getInt(10);
            unsubPrc = resultSet.getDouble(11);
            spam = resultSet.getInt(12);
            spamPrc = resultSet.getDouble(13);

        }
        resultSet.close();
        jsonObject.put("campId",campId);
        jsonObject.put("domain",domain);
        jsonObject.put("sent",sent);
        jsonObject.put("bbackPrc",bbackPrc);
        jsonObject.put("reads",reads);
        jsonObject.put("readPrc",readPrc);
        jsonObject.put("clicks",clicks);
        jsonObject.put("clickPrc",clickPrc);
        jsonObject.put("unsubs",unsubs);
        jsonObject.put("unsubPrc",unsubPrc);
        jsonObject.put("spam",spam);
        jsonObject.put("spamPrc",spamPrc);
        jsonObject.put("bbacks",bbacks);


    }catch (Exception exception){
        System.out.println(exception.getMessage());
        exception.printStackTrace();
    }


    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");




%>