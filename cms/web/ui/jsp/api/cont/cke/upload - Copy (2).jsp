<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="com.britemoon.*, com.britemoon.cps.*, com.britemoon.cps.imc.*, com.britemoon.cps.que.*, com.britemoon.cps.ctl.*, org.w3c.dom.*,org.apache.log4j.*" %>
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
<%@ page import="java.text.SimpleDateFormat"%>

<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>

<% 
   UploadServlet servlet = new UploadServlet();

   servlet.setCustId(cust.s_cust_id);
   
   System.out.println("Servlet Cust ID: " + servlet.getCustId());
   
   servlet.doPost(request, response);
   
   if (servlet.successfullyUploaded()) {
	   out.println(servlet.getResult());
   } else {
	   JSONObject result = new JSONObject();
	   
	   result.put("uploaded", 0);
	   
	   out.println(result);
   }
%>

<%!
@WebServlet("/UploadServlet")
@MultipartConfig
public class UploadServlet extends HttpServlet {
    private static final String UPLOAD_DIRECTORY = "C:\\Revotas\\cms\\web\\ui\\images\\"; // Directory to save uploaded files
	private boolean successfullyUploaded = true;
	private JSONObject result = new JSONObject();
	private String custId;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		this.successfullyUploaded = false;
        if (ServletFileUpload.isMultipartContent(request)) {
			System.out.println("Hey!");
			
            try {
                List<FileItem> multipartItems = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
                for (FileItem item : multipartItems) {
                    if (!item.isFormField()) {
                        String fileName = item.getName();
                        // Save the file locally (optional) or directly upload to CDN
						String directory = UPLOAD_DIRECTORY + this.custId + "\\content_load\\wizard";
						
						File createdDirectory = new File(directory);
						
						// Creates a directory if not exists.
						createdDirectory.mkdirs();
                        File uploadedFile = new File(directory + File.separator, this.getNowAsFormatted() + this.getFileExtension(fileName));
                        item.write(uploadedFile);
                        
                        // Upload to CDN (using your CDN's API)
						System.out.println(uploadedFile.getAbsolutePath());
                        uploadToCDN(uploadedFile);
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
                .connectionString("DefaultEndpointsProtocol=https;AccountName=revotascdn;AccountKey=HKzf4d/7EMc+E/0ay1IMbpvvZ4MzjgmydzoDdqFB9l27Ss5loS5yOulWgiBD+uoykOSWad2V8zRz0daMS2YfiA==;EndpointSuffix=core.windows.net")
				.containerName("cms")
                .blobName("ui/images/" + this.custId + "/content_load/wizard" + File.separator + file.getName())
				.buildClient();
		
		
		
		try {
			String absolutePath = file.getAbsolutePath();
            // Upload the file
			System.out.println("Absolute Path: " + absolutePath);
            blobClient.uploadFromFile(file.toString());

            blobClient.setHttpHeaders(new BlobHttpHeaders().setContentType("image/jpg"));

            System.out.println("File uploaded to Azure Blob Storage: " + file.getName());
			
			this.successfullyUploaded = true;
			this.result = new JSONObject();
			
			result.put("url", "https://revocdn.revotas.com/cms/ui/images/" + this.custId + "/content_load/wizard/" + file.getName());
			result.put("fileName", file.getName());
			result.put("uploaded", 1);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to upload file to Azure Blob Storage", e);
        }
    }
	
	//Overloading
	private void uploadToCDN(InputStream inputStream, String fileName) throws IOException {
        String urlString = "https://revocdn.revotas.com/cms/ui/images/420/content_load/wizard";
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        
        connection.setDoOutput(true);
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "image/jpg");
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
	
	public boolean successfullyUploaded() {
		return this.successfullyUploaded;
	}
	
	public JSONObject getResult() {
		return this.result;
	}
	
	public void setCustId(String custId) {
		this.custId = custId;
	}
	
	public String getCustId() {
		return this.custId;
	}
	
	private String getNowAsFormatted() {
		Date now = new Date();
		SimpleDateFormat format = new SimpleDateFormat("dMyyyy-hhmmss");
		
		return format.format(now);
	}
	
	private String getFileExtension(String fileName) {
		int indexOfDot = -1;
		
		for (int i = 0; i < fileName.length(); i++) {
			if (fileName.charAt(i) == '.') {
				indexOfDot = i;
				break;
			}
		}
		if (indexOfDot == -1) {
			throw new RuntimeException("The file has not a valid format (the dot character is not found).");
		}
		return fileName.substring(indexOfDot);
	}
}
%>