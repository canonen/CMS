<%@ page
        import="com.britemoon.*"
        import="com.britemoon.cps.*"
        import="com.britemoon.cps.imc.*"
        import="java.io.*"
        import="java.security.MessageDigest"
        import="java.security.NoSuchAlgorithmException"
        import="java.sql.*"
        import="java.util.*"
        import="org.apache.log4j.*"
        import="org.w3c.dom.*"
        import="org.apache.commons.fileupload.*"
        import="org.apache.commons.fileupload.disk.*"
        import="org.apache.commons.fileupload.servlet.*"
        import="java.net.HttpURLConnection"
        import="java.util.Base64"
        import="java.net.URL"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%
    String custId = cust.s_cust_id;
    DiskFileItemFactory factory = new DiskFileItemFactory();
    ServletFileUpload upload = new ServletFileUpload(factory);

    String otherServerUrl = "https://rcp1.revotas.com/rrcp/imc/app_push/receive.jsp"; // Diğer sunucunun JSP URL'si
    Map<String, String> formFields = new HashMap<String, String>(); // Tür belirtildi
    String fileContent = null;

    try {
        // Dosya yükleme işlemini başlat
        List<FileItem> formItems = upload.parseRequest(request); // Tür belirtildi

        // Gelen form verilerini işle
        for (FileItem item : formItems) {
            if (item.isFormField()) {
                // Form alanlarını al
                formFields.put(item.getFieldName(), item.getString("UTF-8"));
            } else {
                // Dosya içeriğini oku
                InputStream inputStream = item.getInputStream();
                ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                byte[] data = new byte[1024];
                int bytesRead;

                while ((bytesRead = inputStream.read(data, 0, data.length)) != -1) {
                    buffer.write(data, 0, bytesRead);
                }

                fileContent = new String(buffer.toByteArray(), "UTF-8");
                inputStream.close();
            }
        }

        if (formFields.isEmpty() || fileContent == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Eksik parametreler\"}");
            return;
        }

        // Dosya içeriğini Base64'e dönüştürme
        String base64EncodedFileContent = Base64.getEncoder().encodeToString(fileContent.getBytes("UTF-8"));

        // Diğer sunucuya POST isteği gönder
        URL url = new URL(otherServerUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/json");

        // JSON oluştur
        String jsonPayload = "{"
                + "\"custId\":\"" + custId + "\","
                + "\"device\":\"" + formFields.get("device") + "\","
                + "\"appId\":\"" + formFields.get("appId") + "\","
                + "\"fileContent\":\"" + base64EncodedFileContent + "\""
                + "}";
        // JSON'u gönder
        OutputStream os = conn.getOutputStream();
        os.write(jsonPayload.getBytes("UTF-8"));
        os.close();

        // Yanıtı al
        int responseCode = conn.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            StringBuilder responseBuilder = new StringBuilder();
            String line;
            while ((line = in.readLine()) != null) {
                responseBuilder.append(line);
            }
            in.close();
            out.print("{\"message\":\"Başarılı\", \"response\":" + responseBuilder.toString() + "}");
        } else {
            response.setStatus(responseCode);
            out.print("{\"error\":\"Diğer sunucu hatası: " + conn.getResponseMessage() + "\"}");
        }

    } catch (Exception ex) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("{\"error\":\"Hata: " + ex.getMessage() + "\"}");
    }
%>
