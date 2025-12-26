<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.json.JSONObject"%>
<%@ page import="com.azure.storage.blob.*" %>
<%@ page import="com.azure.storage.blob.models.BlobHttpHeaders"%>
<%@ page import="com.britemoon.*" %>
<%@ page import="com.britemoon.cps.*"%>
<%@ page import="com.britemoon.cps.adm.CustFeature" %>

<%@ include file="header.jsp"%>

<%
    if (!ServletFileUpload.isMultipartContent(request)) {
        System.out.println("NOT multipart content!");
        JSONObject errorResult = new JSONObject();
        errorResult.put("uploaded", 0);
        errorResult.put("error", "Request must be multipart/form-data");
        out.println(errorResult);
        return;
    }

    String successStr = request.getParameter("success");
    String custId = request.getParameter("custId");

    if (!"true".equals(successStr)) {
        JSONObject errorResult = new JSONObject();
        errorResult.put("uploaded", 0);
        errorResult.put("error", "success parameter is required");
        out.println(errorResult);
        return;
    }

    if (custId == null || custId.isEmpty()) {
        JSONObject result = new JSONObject();
        result.put("error", "Customer id is required");
        result.put("uploaded", 0);
        out.println(result);
        return;
    }

    JSONObject result = new JSONObject();
    int fileIndex = 0;

    try {
        CustFeature custFeature = new CustFeature(custId, String.valueOf(Feature.PV_LOGIN));
        int retrieve = custFeature.retrieve();
        

        // CDN mi Remote Servers mi?
        boolean useCDN = (retrieve > 0);

        List<FileItem> multipartItems = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
        System.out.println("Dosya sayısı: " + multipartItems.size());

        for (FileItem item : multipartItems) {
            System.out.println("Item: " + item.getFieldName() + ", isFormField: " + item.isFormField());

            if (!item.isFormField()) {
                fileIndex++;
                String originalFileName = item.getName();

                int lastDotIndex = originalFileName.lastIndexOf('.');
                String fileName = originalFileName;
                if (lastDotIndex != -1) {
                    String nameWithoutExtension = originalFileName.substring(0, lastDotIndex).replace('.', '_');
                    String extension = originalFileName.substring(lastDotIndex);
                    fileName = nameWithoutExtension + extension;
                }

                int indexOfDot = fileName.indexOf('.');
                if (indexOfDot == -1) {
                    throw new RuntimeException("The file has not a valid format (the dot character is not found).");
                }
                String fileExtension = fileName.substring(indexOfDot);

                boolean validExtension = fileExtension.equalsIgnoreCase(".jpg") ||
                                        fileExtension.equalsIgnoreCase(".jpeg") ||
                                        fileExtension.equalsIgnoreCase(".png") ||
                                        fileExtension.equalsIgnoreCase(".gif");

                if (!validExtension) {
                    result.put("error_" + fileIndex, "Invalid file extension: " + fileName);
                    continue;
                }

                if (useCDN) {
                    System.out.println("CDN'e yükleniyor: " + fileName);

                    File tempFile = File.createTempFile("upload_", fileExtension);
                    item.write(tempFile);

                    try {
                        BlobClient blobClient = new BlobClientBuilder()
                                .connectionString("DefaultEndpointsProtocol=https;AccountName=revotascdn;AccountKey=HKzf4d/7EMc+E/0ay1IMbpvvZ4MzjgmydzoDdqFB9l27Ss5loS5yOulWgiBD+uoykOSWad2V8zRz0daMS2YfiA==;EndpointSuffix=core.windows.net")
                                .containerName("trc")
                                .blobName("web/" + custId + "/images/" + fileName)
                                .buildClient();

                        blobClient.uploadFromFile(tempFile.getAbsolutePath(), true);
                        System.out.println("Azure'a yüklendi: web/" + custId + "/images/" + fileName);

                        String contentType = "image/jpeg";
                        if (fileExtension.equalsIgnoreCase(".png")) {
                            contentType = "image/png";
                        } else if (fileExtension.equalsIgnoreCase(".gif")) {
                            contentType = "image/gif";
                        }
                        blobClient.setHttpHeaders(new BlobHttpHeaders().setContentType(contentType));

                        String cdnUrl = "https://revocdn.revotas.com/trc/web/" + custId + "/images/" + fileName;
                        result.put("cdn_url_" + fileIndex, cdnUrl);
                        result.put("fileName_" + fileIndex, fileName);
                        result.put("cdn_status_" + fileIndex, "success");

                    } catch (Exception cdnEx) {
                        System.err.println("CDN yükleme hatası: " + cdnEx.getMessage());
                        result.put("cdn_status_" + fileIndex, "failed");
                        result.put("cdn_error_" + fileIndex, cdnEx.getMessage());
                        cdnEx.printStackTrace();
                    } finally {
                        tempFile.delete();
                    }
                } else {
                    // Remote Servers'a yükle
                    System.out.println("Remote Servers'a yükleniyor: " + fileName);

                    // Önce geçici dosyaya yaz
                    File tempFile = File.createTempFile("upload_", fileExtension);
                    item.write(tempFile);
                    System.out.println("Geçici dosya oluşturuldu: " + tempFile.getAbsolutePath());

                    boolean uploadSuccess = false;

                    // L1'e kopyala
                    String l1Path = "\\\\192.168.151.11\\c$\\Revotas\\trc\\web\\web\\" + custId + "\\images\\" + fileName;
                    try {
                        File l1File = new File(l1Path);
                        File parentDir = l1File.getParentFile();
                        if (!parentDir.exists()) {
                            parentDir.mkdirs();
                        }
                        Files.copy(tempFile.toPath(), l1File.toPath(), StandardCopyOption.REPLACE_EXISTING);
                        uploadSuccess = true;
                        System.out.println("L1'e yüklendi: " + l1Path);
                        result.put("l1_url_" + fileIndex, "https://l1.revotas.com/trc/web/" + custId + "/images/" + fileName);
                        result.put("l1_status_" + fileIndex, "success");
                    } catch (Exception e) {
                        System.err.println("L1'e yükleme hatası: " + e.getMessage());
                        result.put("l1_status_" + fileIndex, "failed");
                        result.put("l1_error_" + fileIndex, e.getMessage());
                        e.printStackTrace();
                    }

                    // L2'ye kopyala
                    String l2Path = "\\\\192.168.151.13\\c$\\Revotas\\trc\\web\\web\\" + custId + "\\images\\" + fileName;
                    try {
                        File l2File = new File(l2Path);
                        File parentDir = l2File.getParentFile();
                        if (!parentDir.exists()) {
                            parentDir.mkdirs();
                        }
                        Files.copy(tempFile.toPath(), l2File.toPath(), StandardCopyOption.REPLACE_EXISTING);
                        uploadSuccess = true;
                        System.out.println("L2'ye yüklendi: " + l2Path);
                        result.put("l2_url_" + fileIndex, "https://l2.revotas.com/trc/web/" + custId + "/images/" + fileName);
                        result.put("l2_status_" + fileIndex, "success");
                    } catch (Exception e) {
                        System.err.println("L2'ye yükleme hatası: " + e.getMessage());
                        result.put("l2_status_" + fileIndex, "failed");
                        result.put("l2_error_" + fileIndex, e.getMessage());
                        e.printStackTrace();
                    }

                    // Load Balancer URL'i ekle
                    if (uploadSuccess) {
                        result.put("lb_url_" + fileIndex, "https://lb.revotas.com/trc/web/" + custId + "/images/" + fileName);
                        result.put("fileName_" + fileIndex, fileName);
                    }

                    // Geçici dosyayı sil
                    tempFile.delete();
                    System.out.println("Geçici dosya silindi");
                }
            }
        }

        result.put("uploaded", fileIndex);
        result.put("total_files", fileIndex);

        if (fileIndex > 0) {
            out.println(result);
        } else {
            JSONObject errorResult = new JSONObject();
            errorResult.put("uploaded", 0);
            errorResult.put("error", "No file uploaded");
            out.println(errorResult);
        }

    } catch (Exception e) {
        e.printStackTrace();
        JSONObject errorResult = new JSONObject();
        errorResult.put("uploaded", 0);
        errorResult.put("error", "File upload failed: " + e.getMessage());
        out.println(errorResult);
    }
%>
