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
                javax.servlet.*,
                javax.servlet.http.*,
                java.io.File,
                java.io.FileInputStream,
                java.text.DateFormat,
                org.apache.log4j.*,
                java.net.URLEncoder"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>
<%! static Logger logger = null;%>
<%@ page import="java.nio.charset.StandardCharsets" %>

<%
    String custId = "";
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
    FileInputStream smallImageStream = null;
    FileInputStream largeImageStream = null;
    byte[] buffer = new byte[1024];
    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        custId = request.getParameter("custId");

        String query =
                "select  template_id,category,customer_id,name,sections_n,template_html,template_txt,template_mjml,small_image,large_image" +
                        " ,global_flag,active,approval_flag from ctm_templates where template_mjml is not null and (customer_id = '" + custId + "' " +
                        " or  customer_id = '0')";
       ;
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
                //String decodeMJML = URLDecoder.decode(templateMJMLString);
                jsonObject.put("templateMJML", templateMJMLString);
            }

            /*//Handle small and large image
            String smallImageFileName = resultSet.getString("small_image");
            if (smallImageFileName != null && !smallImageFileName.isEmpty()) {
                String smallImagePath = application.getInitParameter("ImagePath") + "templates\\" + smallImageFileName;

                try {
                    smallImageStream = new FileInputStream(smallImagePath);
                    byte[] smallImageBytes = new byte[smallImageStream.available()];
                    smallImageStream.read(smallImageBytes);
                    String smallImageContent = new String(smallImageBytes, StandardCharsets.UTF_8);
                    jsonObject.put("smallImage", smallImageContent);
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                    out.print("Small image name is not found.");
                }

            }
            String largeImageFileName = resultSet.getString("large_image");
            if (largeImageFileName != null && !largeImageFileName.isEmpty()) {
                String largeImagePath = application.getInitParameter("ImagePath") + "templates\\" + largeImageFileName;

                try {
                    largeImageStream = new FileInputStream(largeImagePath);
                    byte[] largeImageBytes = new byte[largeImageStream.available()];
                    largeImageStream.read(largeImageBytes);
                    String largeImageContent = new String(largeImageBytes, StandardCharsets.UTF_8);
                    jsonObject.put("largeImage", largeImageContent);
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                    out.print("Large image name is not found.");
                }

            }*/
            smallImage = resultSet.getString("small_image");
            jsonObject.put("smallImage", smallImage);

            largeImage = resultSet.getString("large_image");
            jsonObject.put("largeImage", largeImage);


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

