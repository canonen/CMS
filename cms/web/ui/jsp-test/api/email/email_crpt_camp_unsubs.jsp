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
    JsonArray arrayData = new JsonArray();

    String camp_id = request.getParameter("campId");
    String cache_id = request.getParameter("cacheId");
    String sCache = request.getParameter("sCache");



    Integer iCampId = null;
    Integer levelId = null;
    String levelName = null;
    Integer unsubs = 0;
    Double unsubsPrc =null;


    try {
       connectionPool = ConnectionPool.getInstance();
       			connection = connectionPool.getConnection(this);
       			statement = connection.createStatement();

    	sSql = "Exec usp_crpt_camp_unsubs @camp_id="+camp_id+", @cache_id="+cache_id+", @cache="+sCache+"";

        resultSet = statement.executeQuery(sSql);
        while (resultSet.next()){

            jsonObject = new JsonObject();

            iCampId = resultSet.getInt(1);
            levelId = resultSet.getInt(2);
            levelName = resultSet.getString(3);
            unsubs = resultSet.getInt(4);
            unsubsPrc = resultSet.getDouble(5);

            jsonObject.put("iCampId", iCampId);
            jsonObject.put("levelId",levelId);
            jsonObject.put("levelName",levelName);
            jsonObject.put("unsubs",unsubs);
            jsonObject.put("unsubsPrc",unsubsPrc);

            arrayData.put(jsonObject);
        }
            resultSet.close();
			out.print(arrayData.toString());


    }catch (Exception exception){
        System.out.println(exception.getMessage());
        exception.printStackTrace();
    }

%>