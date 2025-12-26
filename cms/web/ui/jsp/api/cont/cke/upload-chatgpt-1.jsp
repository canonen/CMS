<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.annotation.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>
<%@ page import="org.json.JSONObject"%>

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
    }
}

%>