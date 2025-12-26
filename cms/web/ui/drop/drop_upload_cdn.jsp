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
<%@page import="org.json.JSONString"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="java.io.InputStream"%><%@ page import="java.io.FileInputStream"%><%@ page import="com.azure.storage.blob.models.BlobHttpHeaders"%>

<%
	response.setHeader("Access-Control-Allow-Origin", "*");
%>

<%!
    String getSizeString(float sizeInBytes) {
		if (sizeInBytes < 1024)
			return sizeInBytes + " Bytes";
		else if (sizeInBytes < 1024 * 1024) {
			return sizeInBytes / 1024 + " KB";
		} else {
			return sizeInBytes / 1024 * 1024 + " MB";
		}
	}

	JSONObject JsonDataProcess(String[] uzanti,String image_url,JSONObject json) throws JSONException{
        	Date now = new Date();
        	SimpleDateFormat format = new SimpleDateFormat("dMyyyy-hhmmss");
        	json.put("status_code", "200");
        	json.put("status_txt", "OK");
			JSONObject data = new JSONObject();
			data.put("img_name", format.format(now) + "."+ uzanti[1]);
			data.put("img_url", image_url);
			data.put("thumb_url", image_url);
			json.put("data", data);
			return json;
	}

	void changeContentType(BlobClient blobClient){
        BlobHttpHeaders blobHttpHeaders = new BlobHttpHeaders();
		blobHttpHeaders.setContentType("image/jpg");
		blobClient.setHttpHeaders(blobHttpHeaders);
	}

	%>
<%
    System.out.println("***********************************************");
	String message;
	JSONObject json = new JSONObject();
	String name = null;
	String Cust_id = null;
	String Cont_id=null;

	Date now = new Date();
	SimpleDateFormat format = new SimpleDateFormat("dMyyyy-hhmmss");

	int MAXSIZE = 1024 * 1024 * 1;
	String path="C:/Revotas/cms/web/ui/drop/uploads";
    String DOMAIN_URL="https://revocdn.revotas.com/cms/ui/drop/uploads";

	FileItemFactory factory1 = new DiskFileItemFactory();
	ServletFileUpload upload2 = new ServletFileUpload(factory1);
	List<FileItem> uploadItems = upload2.parseRequest(request);

	for (FileItem uploadItem : uploadItems) {
		if (uploadItem.isFormField()) {

		    if (uploadItem.getFieldName().equals("cust_id")) {
			    Cust_id = uploadItem.getString();
			}

		    if(uploadItem.getFieldName().equals("cont_id"))  {
		         Cont_id=uploadItem.getString();
            }

		} else {
		    //Yuklenen dosyanın adını getirir
			long SIZE = uploadItem.getSize();
			String contentType = uploadItem.getContentType();
			String[] UZANTI = contentType.split("/");
			name=format.format(now)+"."+UZANTI[1];


            //TODO burasi revotas ile degistirilmeli
			String connectStr = "DefaultEndpointsProtocol=https;AccountName=revotascdn;AccountKey=HKzf4d/7EMc+E/0ay1IMbpvvZ4MzjgmydzoDdqFB9l27Ss5loS5yOulWgiBD+uoykOSWad2V8zRz0daMS2YfiA==;EndpointSuffix=core.windows.net";

			System.out.println("Blob yapılandırma baslandi");
            // Bir container client oluşturmak için kullanılacak bir BlobServiceClient nesnesi oluşturulur
            BlobServiceClient blobServiceClient = new BlobServiceClientBuilder().connectionString(connectStr).buildClient();

            System.out.println("Blob yapılandırma bitti");
            String url = "ui/drop/uploads/"+Cust_id+"/"+Cont_id+"/"+name;
            String containerName="cms";

			if (UZANTI[1].equals("png") || UZANTI[1].equals("jpg")|| UZANTI[1].equals("jpeg")|| UZANTI[1].equals("gif")) {
                System.out.println("Request analizi yapildi");
				if (SIZE < MAXSIZE) {
					String AnaPath = path + "\\" + Cust_id+"\\"+Cont_id;
					//Date ve formatı olusturulur

					if (!(blobServiceClient.getBlobContainerClient(containerName).exists())) {
					    System.out.println("Yeni container kuruluyor");
					    BlobContainerClient containerClient = blobServiceClient.createBlobContainer(containerName);
						File anaolustur = new File(AnaPath);
						anaolustur.mkdir();
						//Sisteme eklenecek imgnin baglantisi
						File fNew = new File(AnaPath + File.separator,name);
                        uploadItem.write(fNew);

						//Sistemde istenen ismin imgye referansı olusturulur
						BlobClient blobClient = containerClient.getBlobClient(url);
                        blobClient.uploadFromFile(fNew.toString());
                        changeContentType(blobClient);

                        String img_url = DOMAIN_URL + "/" + Cust_id	+ "/"+Cont_id+"/" +name;
						json=JsonDataProcess(UZANTI,img_url,json);
						message = json.toString();
					    out.print(message);
					    out.flush();
					}

					else {
					    System.out.println("Kurulumu daha once yapilmis container");
					    BlobContainerClient containerClient = blobServiceClient.getBlobContainerClient(containerName);

					    File anaolustur = new File(AnaPath);
						anaolustur.mkdirs();

						File fNew = new File(AnaPath + File.separator,name);
                        uploadItem.write(fNew);

						BlobClient blobClient = containerClient.getBlobClient(url);
						blobClient.uploadFromFile(fNew.toString());
						changeContentType(blobClient);

						String img_url = DOMAIN_URL + "/" + Cust_id+ "/" +Cont_id+"/"+name;
						json=JsonDataProcess(UZANTI,img_url,json);
						message = json.toString();
					    out.print(message);
					    out.flush();
					}
				} else {

					System.out.println("Dosya Boyutu Buyuk");
					json.put("status_code", "403");
					json.put("status_txt", "Dosya Boyutu Buyuk");
					message = json.toString();
					out.print(message);
					out.flush();
				}
			} else {
				System.out.println("Uzanti Dogru Degil");
				json.put("status_code", "403");
				json.put("status_txt", "Uzanti Dogru Degil");
				message = json.toString();
				out.print(message);
				out.flush();

			}

		}
	}
%>

