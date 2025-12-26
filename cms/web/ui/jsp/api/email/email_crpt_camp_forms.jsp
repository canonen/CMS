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

<%@ include file="../../validator.jsp" %>
<%@ include file="../../header.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>
<%
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    String sSql = "";
    JsonObject jsonObject = new JsonObject();
    JsonArray arrayData = new JsonArray();
    String   camp_id = request.getParameter("campId");
    String   cache_id = request.getParameter("cacheId");
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


        sSql =  "EXEC usp_crpt_camp_forms @camp_id="+camp_id+", @cache_id="+cache_id+", @cache="+sCache+"";

        resultSet = statement.executeQuery(sSql);
        while (resultSet.next()){
            jsonObject = new JsonObject();

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


            arrayData.put(jsonObject);




        }
        resultSet.close();
        out.print(arrayData.toString());

    }catch (Exception exception){
        System.out.println(exception.getMessage());
        exception.printStackTrace();
    }
    finally {
        if (resultSet != null) {
            try {
                resultSet.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (statement != null) {
            try {
                statement.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (connection != null) {
            connectionPool.freeConnection(connection);
        }
    }

%>
