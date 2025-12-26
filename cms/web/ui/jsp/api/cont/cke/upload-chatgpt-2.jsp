<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.annotation.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.net.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>
<%@ page import="org.json.JSONObject"%>

<%
response.setHeader("Access-Control-Allow-Origin", "*");
%>

<%
   ImageUploadServlet servlet = new ImageUploadServlet();

   servlet.doPost(request, response);
%>

<%!
@WebServlet("/upload")
public class ImageUploadServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (ServletFileUpload.isMultipartContent(request)) {
            try {
                List<FileItem> multipartItems = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
                for (FileItem item : multipartItems) {
                    if (!item.isFormField()) {
                        String fileName = item.getName();
                        InputStream fileContent = item.getInputStream();
                        
                        // CDN'ye yükleme
                        uploadToCDN(fileContent, fileName);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void uploadToCDN(InputStream inputStream, String fileName) throws IOException {
        String urlString = "https://revocdn.revotas.com/cms/ui/images";
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        
        connection.setDoOutput(true);
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "image/jpeg"); // veya uygun MIME türü
        connection.setRequestProperty("Content-Length", String.valueOf(inputStream.available()));
        
        try (OutputStream outputStream = connection.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
        }
        
        int responseCode = connection.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            // Basarili yükleme
            System.out.println("Image uploaded successfully.");
        } else {
            // Hata durumu
            System.out.println("Failed to upload image. Response code: " + responseCode);
        }
    }
}
%>