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
<%@ include file="../header.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>

<%
    boolean bSTANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    String sSql = "";
    JsonObject jsonObject = new JsonObject();
    JsonObject j1 = new JsonObject();
    JsonArray arrayData = new JsonArray();

    Integer value = null;
    String label = null;

    j1.put("value", 0);
    j1.put("label", "all");


    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        sSql = " SELECT category_id, category_name  FROM ccps_category   WHERE cust_id=" + cust.s_cust_id;
        resultSet = statement.executeQuery(sSql);

        while (resultSet.next()) {

            jsonObject = new JsonObject();

            value = resultSet.getInt(1);
            label = resultSet.getString(2);


            jsonObject.put("value", value);
            jsonObject.put("label", label);


            arrayData.put(jsonObject);


        }
        arrayData.put(j1);
        resultSet.close();
        out.print(arrayData.toString());


    } catch (Exception exception) {
        System.out.println(exception.getMessage());
        exception.printStackTrace();
    } finally {
        if (statement != null) statement.close();
        if (connection != null) connectionPool.free(connection);
    }

%>

