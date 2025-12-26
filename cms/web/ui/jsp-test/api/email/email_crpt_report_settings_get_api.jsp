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
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    String sCustId = cust.s_cust_id;
    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;


    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    String sSql = "";
    JsonObject jsonObject = new JsonObject();

    String custId = request.getParameter("custId");
    Integer totalsSecFlag = null;
    totalsSecFlag = 1;
    Integer generalSecFlag = null;
    generalSecFlag = 1;
    Integer bbackSecFlag = null;
    bbackSecFlag =1;

    Integer actionSecFlag = null;
    actionSecFlag =1 ;
    Integer disctClickSecFlag = null;
    disctClickSecFlag = 1;

    Integer totClickSecFlag = null;
    totClickSecFlag = 0;
    Integer formSecFlag = null;
    formSecFlag = 1;
    Integer totReadFlag = null;
    totReadFlag = 0;

    Integer multiReadFlag = null;
    multiReadFlag = 1;
    Integer totClickFlag = null;
    totClickFlag = 1;
    Integer multiLinkClickFlag = null;
    multiLinkClickFlag = 1;
    Integer linkMultiClickFlag = null;
    linkMultiClickFlag = 1;
    Integer domainFlag = null;
    domainFlag = 1;
    Integer optoutFlag = null;
    optoutFlag = 0 ;




    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        out.print(custId);
        sSql = " EXEC usp_crpt_report_settings_get "+ custId + "";
        resultSet = statement.executeQuery(sSql);

        while(resultSet.next()){
            totalsSecFlag = resultSet.getInt(1);
            generalSecFlag = resultSet.getInt(2);
            bbackSecFlag = resultSet.getInt(3);
            actionSecFlag = resultSet.getInt(4);
            disctClickSecFlag = resultSet.getInt(5);
            totClickSecFlag = resultSet.getInt(6);
            formSecFlag = resultSet.getInt(7);
            totReadFlag = resultSet.getInt(8);
            multiReadFlag = resultSet.getInt(9);
            totClickFlag = resultSet.getInt(10);
            multiLinkClickFlag = resultSet.getInt(11);
            linkMultiClickFlag = resultSet.getInt(12);
            domainFlag = resultSet.getInt(13);
            optoutFlag = resultSet.getInt(14);


            jsonObject.put("totalsSecFlag", totalsSecFlag);
            jsonObject.put("generalSecFlag", generalSecFlag);
            jsonObject.put("bbackSecFlag", bbackSecFlag);
            jsonObject.put("actionSecFlag", actionSecFlag);
            jsonObject.put("disctClickSecFlag", disctClickSecFlag);
            jsonObject.put("totClickSecFlag", totClickSecFlag);
            jsonObject.put("formSecFlag", formSecFlag);
            jsonObject.put("totReadFlag", totReadFlag);
            jsonObject.put("multiReadFlag", multiReadFlag);
            jsonObject.put("totClickFlag", totClickFlag);
            jsonObject.put("multiLinkClickFlag", multiLinkClickFlag);
            jsonObject.put("linkMultiClickFlag", linkMultiClickFlag);
            jsonObject.put("domainFlag", domainFlag);
            jsonObject.put("actionSecFlag", optoutFlag);



        }
        resultSet.close();






    }catch (Exception exception){


        System.out.println(exception.getMessage());
        exception.printStackTrace();

    }
    out.print(jsonObject);

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");









%>