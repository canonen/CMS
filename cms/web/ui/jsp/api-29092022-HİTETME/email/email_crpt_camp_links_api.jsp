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



        Integer  campId = null;
        Integer  hrefId = null;
        String linkName = null;
        Integer totalClicks = null;
        Integer totalText = null;
        Integer totalHtml = null;
        Integer distinctClicks = null;
        Integer distinctText = null;
        Integer distinctHtml = null;
        Integer multiClickers = null;
        Double totalClickPrc = null ;
        Integer totalTextPrc = null;
        Integer totalHtmlPrc = null;
        Double distinctClickPrc = null;
        Double distinctTextPrc = null;
        Double disctinctHtmlPrc = null;


        try {
            connectionPool = ConnectionPool.getInstance();
            connection = connectionPool.getConnection(this);
            statement = connection.createStatement();

            out.print(cust_id);
            sSql = " EXEC usp_crpt_camp_links    " +camp_id+","+","+cache_id+","+sCache+"";
            resultSet = statement.executeQuery(sSql);
            while (resultSet.next()){
                campId = resultSet.getInt(1);
                hrefId = resultSet.getInt(2);
                linkName = resultSet.getString(3);
                totalClicks = resultSet.getInt(4);
                totalText = resultSet.getInt(5);
                totalHtml = resultSet.getInt(6);
                distinctClicks = resultSet.getInt(8);
                distinctText  = resultSet.getInt(9);
                distinctHtml = resultSet.getInt(10);
                multiClickers = resultSet.getInt(12);
                totalClickPrc = resultSet.getDouble(13);
                totalTextPrc = resultSet.getInt(14);
                totalHtmlPrc = resultSet.getInt(15);
                distinctClickPrc = resultSet.getDouble(17);
                distinctTextPrc = resultSet.getDouble(18);
                disctinctHtmlPrc = resultSet.getDouble(19);









            }
            resultSet.close();
            jsonObject.put("campId",campId);
            jsonObject.put("hrefId",hrefId);
            jsonObject.put("linkName",linkName);
            jsonObject.put("totalClicks",totalClicks);
            jsonObject.put("totalText",totalText);
            jsonObject.put("totalHtml",totalHtml);
            jsonObject.put("distinctClicks",distinctClicks);
            jsonObject.put("distinctText",distinctText);
            jsonObject.put("distinctHtml",distinctHtml);
            jsonObject.put("multiClickers",multiClickers);
            jsonObject.put("totalClickPrc",totalClickPrc);
            jsonObject.put("totalTextPrc",totalTextPrc);
            jsonObject.put("totalHtmlPrc",totalHtmlPrc);
            jsonObject.put("distinctClickPrc",distinctClickPrc);
            jsonObject.put("distinctTextPrc",distinctTextPrc);
            jsonObject.put("disctinctHtmlPrc",disctinctHtmlPrc);


        }catch (Exception exception){
            System.out.println(exception.getMessage());
            exception.printStackTrace();
        }


        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");



