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
    String sCustID = request.getParameter("sCustID");
    String sCampID = request.getParameter("sCampID");
    String sCacheID = request.getParameter("sCacheID");
    String   sCache = request.getParameter("sCache");


    String campId = null ;
    String categoryId = null;
    String categoryName = null;
    String bBacks = null ;
    String bBackPrc = null;

    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        out.print(sCustID);
        sSql = " EXEC usp_crpt_camp_bbacks      "+ sCampID +","+","+ sCacheID +","+sCache+"";
        resultSet = statement.executeQuery(sSql);
        while (resultSet.next()){
            campId = resultSet.getString(1);
            categoryId = resultSet.getString(2);
            categoryName = resultSet.getString(3);
            bBacks = resultSet.getString(4);
            bBackPrc = resultSet.getString(5);






        }
        resultSet.close();

        jsonObject.put("campId",campId);
        jsonObject.put("categoryId",categoryId);
        jsonObject.put("categoryName",categoryName);
        jsonObject.put("bBacks", bBacks);
        jsonObject.put("bBackPrc", bBackPrc);

    }catch (Exception exception){
        System.out.println(exception.getMessage());
        exception.printStackTrace();
    }

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");







%>