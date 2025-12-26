<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.adm.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.ctl.*,
                java.util.*,
                java.sql.*,
                java.io.*,
                java.net.*,
                java.text.DateFormat,
                org.apache.log4j.*,
                java.net.URLEncoder"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%
    response.setContentType("*/*");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "https://dev.revotas.com:3002");
    response.setHeader("Access-Control-Allow-Credentials", "true");
%>
<%
    String custId = user.s_cust_id;
    String templateId = "";
    String category = "";
    String customerId = "";
    String name = "";
    String sections = "";
    String templateHTML = "";
    String templateTEXT = "";
    String templateMJML = "";
    String smallImage = "";
    String largeImage = "";
    String globalFlag = "";
    String active = "";
    String approvalFlag = "";
    int bytesRead;
    JsonArray jsonArray = new JsonArray();
    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet resultSet = null;
    InputStream inputStream = null;
    byte[] buffer = new byte[1024];
    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String query =
                "select  template_id,category,customer_id,name,sections_n,template_html,template_txt,template_mjml,small_image,large_image" +
                        " ,global_flag,active,approval_flag from ctm_templates where customer_id = '" + custId + "' " +
                        " UNION ALL select template_id,category,customer_id,name,sections_n,template_html,template_txt," +
                        " template_mjml,small_image,large_image,global_flag,active,approval_flag FROM ctm_templates;";
        resultSet = stmt.executeQuery(query);

        while (resultSet.next()) {
            JsonObject jsonObject = new JsonObject();

            templateId = resultSet.getString("template_id");
            jsonObject.put("templateId", templateId);

            category = resultSet.getString("category");
            jsonObject.put("category", category);

            customerId = resultSet.getString("customer_id");
            jsonObject.put("customerId", customerId);

            name = resultSet.getString("name");
            jsonObject.put("name", name);

            sections = resultSet.getString("sections_n");
            jsonObject.put("sections", sections);

            // Handle template_html
            inputStream = resultSet.getBinaryStream("template_html");
            if (inputStream != null) {
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                bytesRead = 0;
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    byteArrayOutputStream.write(buffer, 0, bytesRead);
                }
                byte[] blobData = byteArrayOutputStream.toByteArray();
                String templateHTMLString = new String(blobData, "UTF-8");
                jsonObject.put("templateHTML", templateHTMLString);
            }

            // Handle template_txt
            inputStream = resultSet.getBinaryStream("template_txt");
            if (inputStream != null) {
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                bytesRead = 0;
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    byteArrayOutputStream.write(buffer, 0, bytesRead);
                }
                byte[] templateTXTData = byteArrayOutputStream.toByteArray();
                String templateTXTString = new String(templateTXTData, "UTF-8");
                jsonObject.put("templateTEXT", templateTXTString);
            }

            
            // Handle template_mjml
            inputStream = resultSet.getBinaryStream("template_mjml");
            if (inputStream != null) {
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                bytesRead = 0;
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    byteArrayOutputStream.write(buffer, 0, bytesRead);
                }
                byte[] templateMJMLData = byteArrayOutputStream.toByteArray();
                String templateMJMLString = new String(templateMJMLData, StandardCharsets.UTF_8);
                String decodeMJML = URLDecoder.decode(templateMJMLString);
                jsonObject.put("templateMJML", decodeMJML);
            }

            // Handle other fields similarly

            jsonArray.put(jsonObject);
        }
        resultSet.close();
        out.println(jsonArray);
    } catch (Exception exception) {
        exception.printStackTrace();
    } finally {
        if (resultSet != null) {
            resultSet.close();
        }
        if (stmt != null) {
            stmt.close();
        }
        if (conn != null) {
            cp.free(conn);
        }
    }
%>

