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
<%@page contentType="application/json; charset=UTF-8"%>
<%@ page isThreadSafe="false"%>

<%@page import="org.json.JSONObject"%>
<%@page import="org.json.JSONException"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONString"%>

<%

	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin","http://dev.revotas.com:3001");
	//  response.setHeader("Access-Control-Allow-Origin", "*");
	response.setHeader("Access-Control-Allow-Credentials", "true");
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
	String Cust_id = null;

	int MAXSIZE = 1024 * 1024 * 1;

	String message;
	JSONObject json = new JSONObject();

	String path ="C:/Revotas/trc/web/webpush/img";

	
	String DOMAIN_URL = "https://revotrack.revotas.com/trc/webpush/img";

	FileItemFactory factory1 = new DiskFileItemFactory();
	ServletFileUpload upload2 = new ServletFileUpload(factory1);
	List<FileItem> uploadItems = upload2.parseRequest(request);

	for (FileItem uploadItem : uploadItems) {

		if (uploadItem.isFormField()) {

			if (uploadItem.getFieldName().equals("cust_id")) {
				Cust_id = uploadItem.getString();

			}

		} else {

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

					if (AnaKlasor.exists()) {

						Date now = new Date();
						SimpleDateFormat format = new SimpleDateFormat(
								"dMyyyy-hhmmss");

						File fNew = new File(AnaPath + File.separator,
								format.format(now) + "." + UZANTI[1]);
						
                                                uploadItem.write(fNew);

						String img_url = DOMAIN_URL + "/" + Cust_id
								+ "/" + format.format(now) + "."
								+ UZANTI[1];

						json.put("status_code", "200");
						json.put("status_txt", "OK");

						JSONObject data = new JSONObject();
						data.put("img_name", format.format(now) + "."
								+ UZANTI[1]);
						data.put("img_url", img_url);
						data.put("thumb_url", img_url);
						json.put("data", data);

						message = json.toString();

						out.print(message);
						out.flush();

					}

					else {
						File anaolustur = new File(AnaPath);
						anaolustur.mkdir();

						Date now = new Date();
						SimpleDateFormat format = new SimpleDateFormat(
								"dMyyyy-HHmm");

						File fNew = new File(AnaPath + File.separator,
								format.format(now) + "." + UZANTI[1]);
						uploadItem.write(fNew);

						String img_url = DOMAIN_URL + "/" + Cust_id
								+ "/" + format.format(now) + "."
								+ UZANTI[1];

						json.put("status_code", "200");
						json.put("status_txt", "OK");

						JSONObject data = new JSONObject();
						data.put("img_name", format.format(now) + "."
								+ UZANTI[1]);
						data.put("img_url", img_url);
						data.put("thumb_url", img_url);
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
	}
%>

