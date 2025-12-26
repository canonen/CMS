<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
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
   File file ;
   int maxFileSize = 5000 * 1024;
   int maxMemSize = 5000 * 1024;

   String path = "https://revocdn.revotas.com/cms/ui/images";

   String contentType = request.getContentType();
   if (contentType != null && (contentType.indexOf("multipart/form-data") >= 0)) {

      DiskFileItemFactory factory = new DiskFileItemFactory();
      factory.setSizeThreshold(maxMemSize);
      ServletFileUpload upload = new ServletFileUpload(factory);
      upload.setSizeMax( maxFileSize );
      try{
         List fileItems = upload.parseRequest(request);
         Iterator i = fileItems.iterator();

         while ( i.hasNext () )
         {
            FileItem fi = (FileItem)i.next();
            if ( !fi.isFormField () )  {
                String fieldName = fi.getFieldName();
                String fileName = fi.getName();
                boolean isInMemory = fi.isInMemory();
                long sizeInBytes = fi.getSize();
                path = path + "\\420\\content_load\\wizard";
                String fullPath = path + "\\" + fileName;
                File directory = new File(path);

                directory.mkdirs();

                file = new File(path + File.separator, fileName);

                fi.write( file ) ;
                
                JSONObject result = new JSONObject();

                result.put("fileName", fileName);
                result.put("url", fullPath);
                result.put("uploaded", (0 < sizeInBytes) ? 1 : 0);

                out.println(result);
            }
         }
      } catch(Exception e) {
         JSONObject exception = new JSONObject();

         exception.put("exceptionMessage", e.getMessage());

         out.println(exception);
      }
   } else {
       JSONObject message = new JSONObject();

       message.put("messageValue", "The request content type is missing or doesn't contain the 'multipart/form-data' as a substring.");

       out.println(message);
   }
%>