<%@ page import="java.io.*, java.util.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.json.*" %>
<%@ page import="com.azure.storage.blob.*" %>
<%@ page import="com.azure.storage.blob.models.BlobHttpHeaders"%>
<%@ page import="com.britemoon.*, com.britemoon.cps.*, com.britemoon.cps.imc.*, com.britemoon.cps.que.*, com.britemoon.cps.ctl.*, org.w3c.dom.*,org.apache.log4j.*" %>

<%@ page import="java.net.*"%>

<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Dosya Yükleme</title>
</head>
<body>
<h2>Dosya Yükleme Formu</h2>

<% 
    // Yükleme dizinini belirle
    String uploadPath = "C:\\Revotas\\cms\\web\\ui\\images\\" + cust.s_cust_id + "\\content_load\\wizard";
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) {
        uploadDir.mkdir(); // Yükleme dizini yoksa oluştur
    }

    // POST isteği varsa dosyayı yükle
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (ServletFileUpload.isMultipartContent(request)) {
            try {
                List<FileItem> formItems = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
                if (formItems != null && 0 < formItems.size()) {
                    for (FileItem item : formItems) {
                        if (!item.isFormField()) {
                            String fileName = new File(item.getName()).getName();
                            String filePath = uploadPath + File.separator + fileName;
                            File storeFile = new File(filePath);
                            item.write(storeFile); // Dosyayı yaz
							uploadToCDN(storeFile, cust.s_cust_id);
							
							JSONObject result = new JSONObject();
							
							result.put("url", "https://revocdn.revotas.com/cms/ui/images/" + cust.s_cust_id + "/content_load/wizard" + "/" + fileName);
							result.put("uploaded", 1);
                            out.println(result);
                        }
                    }
                }
            } catch (Exception ex) {
				JSONObject result = new JSONObject();
				
				result.put("uploaded", 0);
				result.put("errorMessage", ex.getMessage());
                out.println(result);
            }
        } else {
            out.println("<p>Form multipart değil!</p>");
        }
    }
%>

<%!
public void uploadToCDN(File file, String custId) {
        // Implement your CDN upload logic here using the appropriate SDK or API
        // For example, using AWS SDK, Azure Blob Storage SDK, etc.
		if (!file.exists() || !file.isFile()) {
            throw new IllegalArgumentException("The specified file does not exist or is not a file.");
        }
		BlobClient blobClient = new BlobClientBuilder()
                .connectionString("DefaultEndpointsProtocol=https;AccountName=revotascdn;AccountKey=HKzf4d/7EMc+E/0ay1IMbpvvZ4MzjgmydzoDdqFB9l27Ss5loS5yOulWgiBD+uoykOSWad2V8zRz0daMS2YfiA==;EndpointSuffix=core.windows.net")
				.containerName("cms")
                .blobName("ui/images/" + custId + "/content_load/wizard" + File.separator + file.getName())
				.buildClient();
		
		try {
			String absolutePath = file.getAbsolutePath();
            // Upload the file
			System.out.println("Absolute Path: " + absolutePath);
            blobClient.uploadFromFile(file.toString());

            blobClient.setHttpHeaders(new BlobHttpHeaders().setContentType("image/jpg"));

            System.out.println("File uploaded to Azure Blob Storage: " + file.getName());
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to upload file to Azure Blob Storage", e);
        }
    }
%>

<form action="<%= request.getRequestURI() %>" method="post" enctype="multipart/form-data">
    Dosya yüklemek için seçin:
    <input type="file" name="file" required />
    <input type="submit" value="Dosya Yükle" />
</form>

</body>
</html>
