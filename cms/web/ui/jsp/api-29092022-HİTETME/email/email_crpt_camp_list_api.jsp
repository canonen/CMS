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
<%@ page import="net.sourceforge.jtds.jdbc.DateTime" %>
<%@ page import="java.sql.Date" %>

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
    String cust_id = request.getParameter("cust_id");
    String camp_id = request.getParameter("camp_id");
    String cache_id = request.getParameter("cache_id");
    String cache = request.getParameter("cache");


    String campName = null;
    Date startDate = null;
    Integer bbacks = 0;
    Integer sent =0 ;
    Integer reaching = null;
    Integer distinctReads = null;
    Integer totalReads = null;
    Integer multiReads = null;
    Integer unsubs = null;
    Integer totalLinks = null;
    Integer totalClicks = null;
    Integer totalText = null;
    Integer totalHtml = null;
    Integer distinctClicks = null;
    Integer distinctText = null;
    Integer distinctHtml = null;
    Integer oneLinkMultiClickers = null;
    Integer multiLinkClickers = null;
    Double bbackPrc = null;
    Double reachingPrc = null;
    Double distinctReadPrc = null;
    Double unsubPrc = null;
    Double distinctClickPrc = null;
    Double totalTextPrc = null;
    Double totalHTMLPrc = null;
    Double distinctTextPrc = null;
    Double distinctHTMLPrc = null;


    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        out.print(cust_id);
        sSql = " EXEC usp_crpt_camp_list  " + cust_id + "," + camp_id + "," + "," + cache_id + "," + cache + "";
        resultSet = statement.executeQuery(sSql);
        while (resultSet.next()) {
            campName = resultSet.getString(2);
            startDate = resultSet.getDate(4);
            bbacks = resultSet.getInt(10);
            reaching = resultSet.getInt(11);
            distinctReads = resultSet.getInt(12);
            totalReads = resultSet.getInt(13);
            multiReads = resultSet.getInt(14);
            unsubs = resultSet.getInt(15);
            totalLinks = resultSet.getInt(16);
            totalClicks = resultSet.getInt(17);
            totalText = resultSet.getInt(18);
            totalHtml = resultSet.getInt(19);
            distinctClicks = resultSet.getInt(21);
            distinctText = resultSet.getInt(22);
            distinctHtml = resultSet.getInt(23);
            oneLinkMultiClickers = resultSet.getInt(25);
            multiLinkClickers = resultSet.getInt(26);
            bbackPrc = resultSet.getDouble(27);
            reachingPrc = resultSet.getDouble(28);
            distinctReadPrc = resultSet.getDouble(29);
            unsubPrc = resultSet.getDouble(30);
            distinctClickPrc = resultSet.getDouble(31);
            totalTextPrc = resultSet.getDouble(32);
            totalHTMLPrc = resultSet.getDouble(33);
            distinctTextPrc =resultSet.getDouble(35);
            distinctHTMLPrc =resultSet.getDouble(36);
            sent = resultSet.getInt(9);

        }

        jsonObject.put("campName",campName);
        jsonObject.put("startDate",startDate);
        jsonObject.put("bbacks",bbacks);
        jsonObject.put("reaching",reaching);
        jsonObject.put("distinctReads",distinctReads);
        jsonObject.put("totalReads",totalReads);
        jsonObject.put("multiReads",multiReads);
        jsonObject.put("unsubs",unsubs);
        jsonObject.put("totalLinks",totalLinks);
        jsonObject.put("totalClicks",totalClicks);
        jsonObject.put("totalText",totalText);
        jsonObject.put("totalHtml",totalHtml);
        jsonObject.put("distinctClicks",distinctClicks);
        jsonObject.put("distinctText",distinctText);
        jsonObject.put("distinctHtml",distinctHtml);
        jsonObject.put("oneLinkMultiClickers",oneLinkMultiClickers);
        jsonObject.put("multiLinkClickers",multiLinkClickers);
        jsonObject.put("bbackPrc",bbackPrc);
        jsonObject.put("reachingPrc",reachingPrc);
        jsonObject.put("distinctReadPrc",distinctReadPrc);
        jsonObject.put("unsubPrc",unsubPrc);
        jsonObject.put("distinctClickPrc",distinctClickPrc);
        jsonObject.put("totalTextPrc",totalTextPrc);
        jsonObject.put("totalHTMLPrc",totalHTMLPrc);
        jsonObject.put("distinctTextPrc",distinctTextPrc);
        jsonObject.put("distinctHTMLPrc",distinctHTMLPrc);
        jsonObject.put("sent",sent);


        resultSet.close();

    } catch (Exception exception) {
        System.out.println(exception.getMessage());
        exception.printStackTrace();
    }

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");


%>