<%@ page
	import="org.apache.commons.fileupload.*,
				 org.apache.commons.fileupload.servlet.ServletFileUpload,
				 org.apache.commons.fileupload.disk.DiskFileItemFactory,
				 org.apache.commons.io.FilenameUtils,
				 java.util.*,
				 java.io.File,
				 java.util.Date,
				java.text.SimpleDateFormat,
				 java.lang.Exception"%>
<%@ page import="com.azure.storage.blob.*" %>
<%@page contentType="application/json; charset=UTF-8" pageEncoding="utf-8" %>
<%@ page isThreadSafe="false"%>

<%@page import="org.json.JSONObject"%>
<%@page import="org.json.JSONException"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONString"%><%@ page import="java.net.URLEncoder"%><%@ page import="java.io.InputStream"%><%@ page import="java.io.FileInputStream"%><%@ page import="com.azure.storage.blob.models.BlobHttpHeaders"%>

<%
	response.setHeader("Access-Control-Allow-Origin", "*");
	// response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
	// response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>

<%!String getSizeString(float sizeInBytes) {
		if (sizeInBytes < 1024)
			return sizeInBytes + " Bytes";
		else if (sizeInBytes < 1024 * 1024) {
			return sizeInBytes / 1024 + " KB";
		} else {
			return sizeInBytes / 1024 * 1024 + " MB";
		}
	}%>
<%
	String name = null;
	String Cust_id = request.getParameter("cust_id");

	int MAXSIZE = 1024 * 1024 * 10;

	String message;
	JSONObject json = new JSONObject();

	String path ="C:/Revotas/trc/web/smartwidget/image";
	String connectStr = "DefaultEndpointsProtocol=https;AccountName=revotascdn;AccountKey=HKzf4d/7EMc+E/0ay1IMbpvvZ4MzjgmydzoDdqFB9l27Ss5loS5yOulWgiBD+uoykOSWad2V8zRz0daMS2YfiA==;EndpointSuffix=core.windows.net";
	BlobServiceClient blobServiceClient = new BlobServiceClientBuilder().connectionString(connectStr).buildClient();
	BlobContainerClient containerClient = blobServiceClient.getBlobContainerClient("trc");
	
	String DOMAIN_URL = "https://revocdn.revotas.com/trc/smartwidget/uploads/"+Cust_id;

	FileItemFactory factory1 = new DiskFileItemFactory();
	ServletFileUpload upload2 = new ServletFileUpload(factory1);
	List<FileItem> uploadItems = upload2.parseRequest(request);
	Date now = new Date();
    SimpleDateFormat format = new SimpleDateFormat(
            "dMyyyy-hhmmss");

	for (FileItem uploadItem : uploadItems) {

			name = uploadItem.getName();
			long SIZE = uploadItem.getSize();

			String contentType = uploadItem.getContentType();

			String[] UZANTI = contentType.split("/");

			if (UZANTI[1].equals("png") || UZANTI[1].equals("jpg")
					|| UZANTI[1].equals("jpeg")
					|| UZANTI[1].equals("gif")) {

				if (SIZE < MAXSIZE) {

					String AnaPath = path + "\\" + Cust_id;

					File AnaKlasor = new File(AnaPath);
					
					String fileName = format.format(now) + "-image." + UZANTI[1];
					String blobName = "smartwidget/uploads/"+Cust_id+"/"+fileName;

					if (AnaKlasor.exists()) {						

						File fNew = new File(AnaPath + File.separator,
								fileName);
						
                                                uploadItem.write(fNew);

						BlobClient blobClient = containerClient.getBlobClient(blobName);
						blobClient.uploadFromFile(fNew.toString(),true);
						
						BlobHttpHeaders blobHttpHeaders = new BlobHttpHeaders();
						blobHttpHeaders.setContentType("image/jpg");
						blobClient.setHttpHeaders(blobHttpHeaders);

						String img_url = DOMAIN_URL + "/" + fileName;

						json.put("status_code", "200");
						json.put("status_txt", "OK");

						JSONObject data = new JSONObject();
						data.put("img_name", format.format(now) + "-image."
								+ UZANTI[1]);
						data.put("img_url", img_url);
						json.put("data", data);
						
						
					
					
						message = json.toString();

						out.print(message);
						out.flush();

					}

					else {
						File anaolustur = new File(AnaPath);
						anaolustur.mkdir();

						File fNew = new File(AnaPath + File.separator,
								fileName);
						uploadItem.write(fNew);
						
						BlobClient blobClient = containerClient.getBlobClient(blobName);
						blobClient.uploadFromFile(fNew.toString());
						
						BlobHttpHeaders blobHttpHeaders = new BlobHttpHeaders();
						blobHttpHeaders.setContentType("image/jpg");
						blobClient.setHttpHeaders(blobHttpHeaders);

						String img_url = DOMAIN_URL + "/" + fileName;

						json.put("status_code", "200");
						json.put("status_txt", "OK");

						JSONObject data = new JSONObject();
						data.put("img_name", format.format(now) + "-image."
								+ UZANTI[1]);
						data.put("img_url", img_url);
						json.put("data", data);
						
						

						message = json.toString();

						out.print(message);
						out.flush();

					}

				} else {

					//out.println("Dosya Boyutu Buyuk");
					json.put("status_code", "403");
					json.put("status_txt", "Dosya Boyutu Buyuk");

					message = json.toString();

					out.print(message);
					out.flush();

				}

			} else {

				// out.println("Uzanti Dogru Degil");

				json.put("status_code", "403");
				json.put("status_txt", "Uzanti Dogru Degil");

				message = json.toString();

				out.print(message);
				out.flush();

			}
	}
%>

