<%@ page
        language="java"
        import="com.britemoon.*,
        		com.britemoon.cps.*,
        		com.britemoon.cps.ctl.*,
        		com.britemoon.cps.imc.*,
        		com.britemoon.cps.rpt.*,
        		com.britemoon.cps.tgt.*,
        		com.britemoon.cps.que.*,
        		com.britemoon.cps.cnt.*,
        		com.britemoon.cps.*,
        		com.britemoon.rcp.*,
        		java.sql.*,
        		java.util.Vector,
        		org.w3c.dom.*,
        		org.apache.log4j.*"

        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.nio.charset.StandardCharsets" %>

<%
    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statment = null;
    ResultSet resultSet = null;

    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statment = connection.createStatement();
        String link_id, link_name, link_type_id, link_type, link_definition;


        String sCustId = request.getParameter("custId");

        String sSql = "EXEC usp_ccnt_link_renaming_list_get " + sCustId;

        resultSet = statment.executeQuery(sSql);
        JsonObject data = new JsonObject();
        JsonArray arrayData = new JsonArray();

        while (resultSet.next()) {

            data = new JsonObject();

            link_id = resultSet.getString(1);
            link_name = new String(resultSet.getBytes(2), "UTF-8");
            link_type_id = resultSet.getString(3);
            link_type = new String(resultSet.getBytes(4), "UTF-8");
            link_definition =   new String(resultSet.getBytes(5), "UTF-8");
          


            data.put("linkID", link_id);
            data.put("linkName", link_name);
            data.put("linkTypeID", link_type_id);
            data.put("linkType", link_type);
            data.put("linkDefinition", link_definition);
            arrayData.put(data);

        }
        resultSet.close();
        out.print(arrayData.toString());


    } catch (Exception ex) {
        throw ex;
    } finally {
        if (statment != null) statment.close();
        if (connection != null) connectionPool.free(connection);
    }
%>
