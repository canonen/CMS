<%@ page
        language="java"
        import="com.britemoon.*,
        		com.britemoon.cps.*,
        		com.britemoon.cps.adm.*,
        		com.britemoon.cps.que.*,
        		com.britemoon.cps.ctl.*,
        		com.britemoon.cps.cnt.*,
        		com.britemoon.cps.jtk.*,
        		com.britemoon.cps.ctl.*,
        		com.britemoon.cps.xcs.cti.ContentClient,
        		java.sql.*,
        		java.io.*,
        		javax.servlet.*,
        		javax.servlet.http.*,
        		org.xml.sax.*,
        		javax.xml.transform.*,
        		java.util.*,
        		java.sql.*,
        		java.io.*,
        		java.net.*,
        		java.text.DateFormat,
        		org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "http://dev.revotas.com:3002");
    response.setHeader("Access-Control-Allow-Credentials", "true");
%>

<%@ include file="../validator.jsp" %>

<%! static Logger logger = null;%>

<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    InputStream inputStream = null;

    String templateId = request.getParameter("template_id");
    String custId = request.getParameter("cust_id");
    String category = "";
    String name = "";
    String section = "";
    String templateHtml = "";
    String templateText = "";
    String templateMJML = "";
    String smallImage = "";
    String largeImage = "";
    String globalFlag = "";
    String active = "";
    String approvalFlag = "";
    byte[] bytes = null;

    if (templateId != null) {
        try {

            connectionPool = ConnectionPool.getInstance();
            connection = connectionPool.getConnection(this);
            statement = connection.createStatement();

            String query = "select  template_id,category,customer_id,name,sections_n,template_html,template_txt,template_mjml,small_image,large_image," +
                    " global_flag,active,approval_flag from ctm_templates where template_id = '" + templateId + "' AND customer_id = '" + custId + "'";

            resultSet = statement.executeQuery(query);

            if (resultSet.next()) {

                jsonObject.put("template_id", resultSet.getString("template_id"));
                jsonObject.put("category", resultSet.getString("category"));
                jsonObject.put("customer_id", resultSet.getString("customer_id"));
                jsonObject.put("name", resultSet.getString("name"));
                jsonObject.put("sections_n", resultSet.getString("sections_n"));

                inputStream = resultSet.getBinaryStream("template_html");
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                int bytesRead;
                byte[] buffer = new byte[4096];
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    byteArrayOutputStream.write(buffer, 0, bytesRead);
                }
                byte[] blobData = byteArrayOutputStream.toByteArray();
                templateHtml = new String(blobData, "UTF-8");
                jsonObject.put("templateHTML", templateHtml);

                inputStream = resultSet.getBinaryStream("template_txt");
                byteArrayOutputStream = new ByteArrayOutputStream();
                bytesRead = 0;
                buffer = new byte[4096];
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    byteArrayOutputStream.write(buffer, 0, bytesRead);
                }
                byte[] templateTXTData = byteArrayOutputStream.toByteArray();
                templateText = new String(templateTXTData, "UTF-8");
                jsonObject.put("templateTEXT", templateText);

                inputStream = resultSet.getBinaryStream("template_mjml");
                if (inputStream != null) {
                    byteArrayOutputStream = new ByteArrayOutputStream();
                    bytesRead = 0;
                    buffer = new byte[4096];

                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        byteArrayOutputStream.write(buffer, 0, bytesRead);
                    }

                    byte[] templateMJMLData = byteArrayOutputStream.toByteArray();

                    templateMJML = new String(templateMJMLData, "UTF-8");
                    jsonObject.put("templateMJML", templateMJML);
                } else {
                    jsonObject.put("templateMJML", "");
                }
                jsonObject.put("small_image", resultSet.getString("small_image"));
                jsonObject.put("large_image", resultSet.getString("large_image"));
                jsonObject.put("global_flag", resultSet.getString("global_flag"));
                jsonObject.put("active", resultSet.getString("active"));
                jsonObject.put("approval_flag", resultSet.getString("approval_flag"));

                jsonArray.put(jsonObject);

            }
            resultSet.close();
            out.print(jsonArray.toString());

        } catch (Exception exception) {
            exception.printStackTrace();
        } finally {
            if (resultSet != null) {
                resultSet.close();
            }
            if (statement != null) {
                statement.close();
            }
            if (connection != null) {
                connectionPool.free(connection);
            }
        }
    }

%>