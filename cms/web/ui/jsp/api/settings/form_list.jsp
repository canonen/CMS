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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>
<%
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    System.out.println("--------------SUBSCRIPTION------------");

    String sCustId = cust.s_cust_id;
    Statement statement = null;
    ResultSet resultSet = null;
    ConnectionPool connectionPool = null;
    Connection connection = null;
%>
<%
    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        Integer formId = 0;
        String formName = null;
        String formUrl = null;
        String modifyDate = null;
        String createDate = null;

        String subscriptionFormSqlQuery = "SELECT f.form_id, f.form_name, f.form_url, fei.modify_date, fei.create_date FROM csbs_form f, csbs_form_edit_info fei WHERE f.cust_id=" + sCustId + "AND fei.form_id = f.form_id ORDER BY fei.modify_date desc";

        resultSet = statement.executeQuery(subscriptionFormSqlQuery);

        JsonArray array = new JsonArray();

        while (resultSet.next()) {
            formId = resultSet.getInt(1);
            formName = resultSet.getString(2);
            formUrl = resultSet.getString(3);
            modifyDate = dateFormatter(resultSet.getTimestamp(4));
            createDate = dateFormatter(resultSet.getTimestamp(5));

            JsonObject data = new JsonObject();
            data.put("formId", formId);
            data.put("formName", formName);
            data.put("formUrl", formUrl);
            data.put("modifyDate", modifyDate);
            data.put("createDate", createDate);
            array.put(data);
        }
        JsonObject jsonObject = new JsonObject();
        jsonObject.put("Subscription", array);

        resultSet.close();

        out.print(jsonObject);
    } catch (Exception exception) {
        System.out.println(sCustId + exception.getMessage());
        exception.printStackTrace();
    } finally {
        if (resultSet != null) resultSet.close();
        if (statement != null) statement.close();
        if (connection != null) connectionPool.free(connection);
    }


%>

<%!
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private String dateFormatter(Timestamp ts) {
        try {
            return (ts != null) ? ts.toLocalDateTime().format(formatter) : null;
        } catch (Exception ex) {
            // Tarih formatlama hatası için belirgin mesaj
            return "HATA: Tarih formatı dönüştürülemedi! (" + ex.getMessage() + ")";
        }
    }
%>
