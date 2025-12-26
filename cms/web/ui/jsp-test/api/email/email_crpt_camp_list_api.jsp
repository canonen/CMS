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
<%@ page import="java.util.Date" %>

<%@ include file="../../utilities/validator.jsp" %>
<%@ include file="../../utilities/header.jsp" %>
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
    JsonArray array = new JsonArray();

    String cust_id = cust.s_cust_id;
    String camp_id = request.getParameter("campId");
    String cache_id = request.getParameter("cacheId");
    String sCache = request.getParameter("sCache");


    String campName = null;
    String startDate = null;
    Integer bBacks = 0;
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
    Double bBackPrc = null;
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


        sSql = "Exec usp_crpt_camp_list_report_2022 @camp_id="+camp_id+", @cust_id="+cust_id+", @cache_id="+cache_id+", @cache="+sCache+"";
        resultSet = statement.executeQuery(sSql);

        while (resultSet.next()) {
            jsonObject = new JsonObject();
            campName = resultSet.getString(2);
            startDate = resultSet.getString(4);
            bBacks = resultSet.getInt(10);
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
            bBackPrc = resultSet.getDouble(27);
            reachingPrc = resultSet.getDouble(28);
            distinctReadPrc = resultSet.getDouble(29);
            unsubPrc = resultSet.getDouble(30);
            distinctClickPrc = resultSet.getDouble(31);
            totalTextPrc = resultSet.getDouble(32);
            totalHTMLPrc = resultSet.getDouble(33);
            distinctTextPrc =resultSet.getDouble(35);
            distinctHTMLPrc =resultSet.getDouble(36);
            sent = resultSet.getInt(9);

            jsonObject.put("campName",campName);
            jsonObject.put("startDate",startDate);
            jsonObject.put("bBacks", bBacks);
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
            jsonObject.put("bBackPrc", bBackPrc);
            jsonObject.put("reachingPrc",reachingPrc);
            jsonObject.put("distinctReadPrc",distinctReadPrc);
            jsonObject.put("unsubPrc",unsubPrc);
            jsonObject.put("distinctClickPrc",distinctClickPrc);
            jsonObject.put("totalTextPrc",totalTextPrc);
            jsonObject.put("totalHTMLPrc",totalHTMLPrc);
            jsonObject.put("distinctTextPrc",distinctTextPrc);
            jsonObject.put("distinctHTMLPrc",distinctHTMLPrc);
            jsonObject.put("sent",sent);
            array.put(jsonObject);
        }

        resultSet.close();
        out.println(array.toString());

    } catch (Exception exception) {
        System.out.println(exception.getMessage());
        exception.printStackTrace();
    }


%>