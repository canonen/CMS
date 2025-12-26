<%@ page
        import="org.apache.commons.fileupload.*,
				 org.apache.commons.fileupload.servlet.ServletFileUpload,
				 org.apache.commons.fileupload.disk.DiskFileItemFactory,
				 org.apache.commons.io.FilenameUtils,
				 com.britemoon.*,
				com.britemoon.cps.*,
				com.britemoon.cps.imc.*,
				com.britemoon.cps.que.*,
				 java.util.*,
				 java.io.File,
				 java.util.Date,
				java.text.SimpleDateFormat,
				 java.lang.Exception"%>
<%@ page import="com.azure.storage.blob.*" %>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="utf-8" %>
<%@ page isThreadSafe="false"%>

<%@page import="org.json.JSONObject"%>
<%@page import="org.json.JSONException"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONString"%><%@ page import="java.net.URLEncoder"%><%@ page import="java.io.InputStream"%><%@ page import="java.io.FileInputStream"%><%@ page import="com.azure.storage.blob.models.BlobHttpHeaders"%>

<%
    response.setHeader("Access-Control-Allow-Origin", "*");
%>
<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>


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
        json.put("status_code", "200");
        json.put("status_txt", "OK");
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
    String message = null;
    JSONObject json = new JSONObject();
    String Cust_id = cust.s_cust_id;
    int MAXSIZE = 1024 * 1024 * 1;
    String path ="C:/Revotas/cms/web/ui/images";
    String DOMAIN_URL = "https://revocdn.revotas.com/cms/ui/images";
    String funcNum = request.getParameter("CKEditorFuncNum");
    String img_url="";
    Date now = new Date();
    SimpleDateFormat format = new SimpleDateFormat("dMyyyy-hhmmss");

    String name = null;
    int uploaded = 0;

    FileItemFactory factory1 = new DiskFileItemFactory();
    ServletFileUpload upload2 = new ServletFileUpload(factory1);
    List<FileItem> uploadItems = upload2.parseRequest(request);

    for (FileItem uploadItem : uploadItems) {
        System.out.println("ILK FOR ICINDEYIM");
        if (uploadItem.isFormField()) {
            if (uploadItem.getFieldName().equals("cust_id")) {
                Cust_id = uploadItem.getString();
                System.out.println("ILK FOR ICI CUST_ID "+Cust_id);
            }
        } else {
            //Yuklenen dosyanin adini getirir
            //Yuklenen dosyanin boyutunu getirir
            long SIZE = uploadItem.getSize();
            
            if (0 < SIZE) {
                uploaded = 1;
            }
            String contentType = uploadItem.getContentType();
            String[] UZANTI = contentType.split("/");
            System.out.println("UZANTI 11 "+UZANTI);
            name=format.format(now)+"."+UZANTI[1];
            System.out.println("ILK NAME FORMATI "+name);
            //TODO burasi revotas ile degistirilmeli
            String connectStr = "DefaultEndpointsProtocol=https;AccountName=revotascdn;AccountKey=HKzf4d/7EMc+E/0ay1IMbpvvZ4MzjgmydzoDdqFB9l27Ss5loS5yOulWgiBD+uoykOSWad2V8zRz0daMS2YfiA==;EndpointSuffix=core.windows.net";

            System.out.println("Blob yapilandirma baslandi");
            // Bir container client olusturmak için kullanilacak bir BlobServiceClient nesnesi olusturulur
            BlobServiceClient blobServiceClient = new BlobServiceClientBuilder().connectionString(connectStr).buildClient();

            System.out.println("Blob yapilandirma bitti");
            String containerName="cms";

            if (UZANTI[1].equals("png") || UZANTI[1].equals("jpg")|| UZANTI[1].equals("jpeg")|| UZANTI[1].equals("gif")) {
                System.out.println("Request analizi yapildi");
                System.out.println("IF ICINDE BULUNMAKTAYIM SORUNSUZ");
                if (SIZE < MAXSIZE) {
                    String AnaPath = path + "\\" + Cust_id+"\\content_load\\wizard";
                    //Date ve formati olusturulur
                    String url = "ui/images/"+Cust_id+"/content_load/wizard/"+name;
                    System.out.println("IF ICI URL "+url);
                    if (!(blobServiceClient.getBlobContainerClient(containerName).exists())) {
                        System.out.println("Yeni container kuruluyor");
                        BlobContainerClient containerClient = blobServiceClient.createBlobContainer(containerName);

                        File anaolustur = new File(AnaPath);
                        anaolustur.mkdirs();

                        File fNew = new File(AnaPath + File.separator,name);
                        uploadItem.write(fNew);

                        //Sistemde istenen ismin imgye referansi olusturulur
                        BlobClient blobClient = containerClient.getBlobClient(url);
                        blobClient.uploadFromFile(fNew.toString());
                        changeContentType(blobClient);
                        System.out.println("BLOB CLIENT "+blobClient);
                        img_url = DOMAIN_URL + "/" + Cust_id+ "/content_load/wizard/" +name;
                        System.out.println("UZANTI 22 "+UZANTI);
                        System.out.println("IMG_URL 22 "+img_url);
                        json=JsonDataProcess(UZANTI,img_url,json);
                        message = json.toString();
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

                        img_url = DOMAIN_URL + "/" + Cust_id+ "/content_load/wizard/" +name;
                        System.out.println("UZANTI 33 "+UZANTI);
                        System.out.println("IMG_URL 33 "+img_url);
                        json=JsonDataProcess(UZANTI,img_url,json);

                    }
                }else {
                    System.out.println("Dosya Boyutu Buyuk");
                    json.put("status_code", "403");
                    json.put("status_txt", "Dosya Boyutu Buyuk");
                    message = json.toString();
                    out.print(message);
                    out.flush();
                }
            }else {
                System.out.println("Uzanti Dogru Degil");
                json.put("status_code", "403");
                json.put("status_txt", "Uzanti Dogru Degil");
                message = json.toString();
                out.print(message);
                out.flush();
            }
        }
    }
    JSONObject result = new JSONObject();

    result.put("fileName", name);
    result.put("url", img_url);
    result.put("uploaded", uploaded);
    out.println(result);
%>


