<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.sql.*,
                java.util.Calendar,
                java.io.*,
                org.apache.log4j.Logger,
                java.text.DateFormat,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.sun.org.apache.xpath.internal.operations.Bool" %>
<%@ page import="org.apache.commons.lang.ObjectUtils" %>
<%@ page import="java.util.Objects" %>
<%@ include file="../../validator.jsp" %>
<%@ include file="../header.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    Statement statement = null;
    ResultSet resultSet = null;
    ConnectionPool connectionPool = null;
    Connection connection = null;
    Integer attrId = 0;
    String attrName = null;
    Boolean valueQty = null;
    String displayName = null;
    Integer displaySeq = 0;
    Boolean fingerprintSeq = null;
    Boolean newsletterFlag = null;
    String typeName = null;
    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        String customFieldsSqlQuery = "SELECT a.attr_id, a.attr_name, a.value_qty, ca.display_name, ca.display_seq," +
                " ca.fingerprint_seq, ca.newsletter_flag, t.type_name FROM " +
                " ccps_cust_attr ca, ccps_attribute a, ccps_data_type t WHERE ca.cust_id=" + cust.s_cust_id + " " +
                " AND ca.attr_id = a.attr_id AND a.type_id = t.type_id AND " +
                " ISNULL(ca.display_seq, 0) > 0 AND ISNULL(a.internal_flag,0) <= 0 ORDER BY display_seq, display_name";

        resultSet = statement.executeQuery(customFieldsSqlQuery);

        JsonObject customFieldsObject;
        JsonArray customFieldsArray = new JsonArray();
        while (resultSet.next()) {
            customFieldsObject = new JsonObject();
            attrId = resultSet.getInt(1);
            attrName = resultSet.getString(2);
            valueQty = resultSet.getInt(3) == 1 ? true : false;
            displayName = resultSet.getString(4);
            displaySeq = resultSet.getInt(5);
            fingerprintSeq = resultSet.getInt(6) == 1 ? true : false;
            
            if(resultSet.getString(7) != null) newsletterFlag = (resultSet.getString(7).equals("1") || resultSet.getString(7).equals("Y")) ? true : false;
            typeName = resultSet.getString(8);


            customFieldsObject.put("attrId", attrId);
            customFieldsObject.put("attrName", attrName);
            customFieldsObject.put("valueQty", valueQty);
            customFieldsObject.put("displayName", displayName);
            customFieldsObject.put("displaySeq", displaySeq);
            customFieldsObject.put("fingerprintSeq", fingerprintSeq);
            customFieldsObject.put("newsletterFlag", newsletterFlag);
            customFieldsObject.put("typeName", typeName);
            customFieldsArray.put(customFieldsObject);
        }

        out.println(customFieldsArray);

        jsonObject.put("customFields", customFieldsArray);

        resultSet.close();
        jsonArray.put(jsonObject);
        out.print(jsonArray);


    } catch (Exception exception) {
        out.println("HATA : "+exception.getMessage());
        exception.printStackTrace();
    } finally {
        if (resultSet != null) resultSet.close();
        if (statement != null) statement.close();
        if (connection != null) connectionPool.free(connection);
    }

%>
