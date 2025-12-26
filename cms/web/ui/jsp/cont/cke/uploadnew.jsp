<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.annotation.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>
<%@ page import="org.json.JSONObject"%>
<%@ page import="com.azure.storage.blob.*" %>
<%@ page import="com.azure.storage.blob.models.BlobHttpHeaders"%>
<%@ page import="java.net.*"%>

<%
    response.setHeader("Access-Control-Allow-Origin", "*");
%>

<%
   UploadServlet servlet = new UploadServlet();

   servlet.doPost(request, response);
%>

<%!
@WebServlet("/UploadServlet")
@MultipartConfig
public class UploadServlet extends HttpServlet {
    private static final String UPLOAD_DIRECTORY = "C:\\Images"; // Directory to save uploaded files

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (ServletFileUpload.isMultipartContent(request)) {
			
            try {
                List<FileItem> multipartItems = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
                for (FileItem item : multipartItems) {
                    if (!item.isFormField()) {
                        String fileName = item.getName();
                        // Save the file locally (optional) or directly upload to CDN
                        File uploadedFile = new File(UPLOAD_DIRECTORY + File.separator, fileName);
                        item.write(uploadedFile);
                        
                        // Upload to CDN (using your CDN's API)
                        uploadToCDN(new FileInputStream(uploadedFile), uploadedFile.getName());
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().print("File upload failed: " + e.getMessage());
            }
        }
    }

    private void uploadToCDN(File file) {
        // Implement your CDN upload logic here using the appropriate SDK or API
        // For example, using AWS SDK, Azure Blob Storage SDK, etc.
		if (!file.exists() || !file.isFile()) {
            throw new IllegalArgumentException("The specified file does not exist or is not a file.");
        }
		BlobClient blobClient = new BlobClientBuilder()
                .connectionString("https://revocdn.revotas.com/cms/ui/images/")
                .blobName(file.getName())
                .buildClient();
		
		try {
            // Upload the file
            blobClient.uploadFromFile(file.getAbsolutePath());

            blobClient.setHttpHeaders(new BlobHttpHeaders().setContentType("image/jpg"));

            System.out.println("File uploaded to Azure Blob Storage: " + file.getName());
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to upload file to Azure Blob Storage", e);
        }
    }
	
	//Overloading
	private void uploadToCDN(InputStream inputStream, String fileName) throws IOException {
        String urlString = "https://revocdn.revotas.com/cms/ui/images";
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        
        connection.setDoOutput(true);
		connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "image/jpeg");
        connection.setRequestProperty("Content-Length", String.valueOf(inputStream.available()));
        
		OutputStream outputStream = null;
		
        try {
			outputStream = connection.getOutputStream();
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
			
        } catch (Exception e) {
			System.out.println(e);
		} finally {
			outputStream.close();
		}
        
        int responseCode = connection.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            System.out.println("Image uploaded successfully.");
        } else {
            System.out.println("Failed to upload image. Response code: " + responseCode);
        }
	}
}
%>