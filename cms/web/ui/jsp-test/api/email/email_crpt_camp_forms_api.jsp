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
<%@ include file="../../utilities/header.jsp" %>
<%@ include file="../../utilities/validator.jsp" %>
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


    Integer campId = null ;
    Integer firstFormId = null;
    Integer lastFormId = null;
    String firstFormName =null;
    String lastFormName = null;
    Integer totalViews = null;
    Integer totalSubmits = null;
    Integer distinctViews = null;
    Integer disctinctSubmits = null;
    Double multiSubmitters = null;
    Double totalViewSubmitPrc = null;
    Double distinctViewSubmitPrc = null;

    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        out.print(cust_id);
        sSql = " EXEC usp_crpt_camp_forms       "+camp_id+","+","+cache_id+","+sCache+"";
        resultSet = statement.executeQuery(sSql);
        while (resultSet.next()){
            campId = resultSet.getInt(1);
            firstFormId = resultSet.getInt(2);
            lastFormId = resultSet.getInt(3);
            firstFormName = resultSet.getString(4);
            lastFormName = resultSet.getString(5);
            totalViews = resultSet.getInt(6);
            totalSubmits = resultSet.getInt(7);
            distinctViews = resultSet.getInt(8);
            disctinctSubmits = resultSet.getInt(9);
            multiSubmitters =resultSet.getDouble(10);
            totalViewSubmitPrc = resultSet.getDouble(11);
            distinctViewSubmitPrc = resultSet.getDouble(12);





        }
        resultSet.close();

        jsonObject.put("campId",campId);
        jsonObject.put("firstFormId",firstFormId);
        jsonObject.put("lastFormId",lastFormId);
        jsonObject.put("lastFormName",lastFormName);
        jsonObject.put("totalViews",totalViews);
        jsonObject.put("totalSubmits",totalSubmits);
        jsonObject.put("distinctViews",distinctViews);
        jsonObject.put("disctinctSubmits",disctinctSubmits);
        jsonObject.put("multiSubmitters",multiSubmitters);
        jsonObject.put("totalViewSubmitPrc",totalViewSubmitPrc);
        jsonObject.put("distinctViewSubmitPrc",distinctViewSubmitPrc);
        jsonObject.put("firstFormName",firstFormName);

    }catch (Exception exception){
        System.out.println(exception.getMessage());
        exception.printStackTrace();
    }

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");







%>