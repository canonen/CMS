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
    String campId = request.getParameter("campId");
    String cacheId = request.getParameter("cacheId");
    String   sCache = request.getParameter("sCache");



    Integer iCampId = null;
    Integer levelId = null;
    String levelName = null;
    Integer unsubs = 0;
    Double unsubsPrc =null;


    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        out.print(custId);
        sSql = " EXEC usp_crpt_camp_unsubs  "  + campId +","+","+ cacheId +","+sCache+"";;
        resultSet = statement.executeQuery(sSql);
        resultSet.close();
        while (resultSet.next()){
            iCampId = resultSet.getInt(1);
            levelId = resultSet.getInt(2);
            levelName = resultSet.getString(3);
            unsubs = resultSet.getInt(4);
            unsubsPrc = resultSet.getDouble(5);





        }

        jsonObject.put("iCampId", iCampId);
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