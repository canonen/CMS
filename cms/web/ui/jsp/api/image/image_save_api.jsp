    <%@ page
            language="java"
            import="com.oreilly.servlet.multipart.*,
                com.oreilly.servlet.multipart.Part,
                com.britemoon.*,
                com.britemoon.cps.cnt.*,
                com.oreilly.servlet.multipart.MultipartParser,
                com.britemoon.cps.*,
                java.io.*,java.util.*,
                java.sql.*,javax.servlet.http.*,
                javax.servlet.*,org.apache.log4j.*"
            contentType="text/html;charset=UTF-8"
    %>
    <%@ page import="com.azure.storage.blob.BlobContainerClient" %>
    <%@ page import="com.azure.storage.blob.BlobClient" %>
    <%@ page import="com.azure.storage.blob.BlobServiceClientBuilder" %>
    <%@ page import="com.azure.storage.blob.BlobServiceClient" %>
    <%@ page import="org.json.JSONObject" %>
    <%@ page import="java.util.Date" %>
    <%@ page import="org.json.JSONException" %>
    <%@ page import="java.text.SimpleDateFormat" %>
    <%@ page import="com.azure.storage.blob.models.BlobHttpHeaders" %>
    <%@ include file="../header.jsp" %>
    <%@ include file="../validator.jsp"%>
    <%! static Logger logger = null;%>
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

      JSONObject JsonDataProcess(String[] uzanti, String image_url, JSONObject json) throws JSONException {
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

      void changeContentTypeJpg(BlobClient blobClient){
        BlobHttpHeaders blobHttpHeaders = new BlobHttpHeaders();
        blobHttpHeaders.setContentType("image/jpg");
        blobClient.setHttpHeaders(blobHttpHeaders);
      }
      void changeContentTypePdf(BlobClient blobclient){
        BlobHttpHeaders blobHttpHeaders = new BlobHttpHeaders();
        blobHttpHeaders.setContentType("application/pdf");
        blobclient.setHttpHeaders(blobHttpHeaders);
      }

    %>
    <%
      if(logger == null)
      {
        logger = Logger.getLogger(this.getClass().getName());
      }

      AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

      if(!can.bExecute)
      {
        response.sendRedirect("../access_denied.jsp");
        return;
      }

      String sSelectedCategoryId = null;
      String sImageId = "0";
      String sFileName = null, sImageUrl = null, sFolderName = null, sFolderId = null, sOverwrite = null;
      String sAccessCusts = null;
      String[] sAccessMap = null;
      Vector vSavedImages = new Vector();
      Vector vErroredImages = new Vector();
      Vector vZipFiles = new Vector();
      String sProcessedMsg = null;
      boolean bNewImage = false, bOverwrite = true;
      FilePart fpImage = null;
      Part myPart = null;


      Statement stmt = null;
      ResultSet rs = null;
      Connection connection = null;

      final String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
      final String urdb = "jdbc:sqlserver://192.168.151.101:1433;databaseName=brite_ccps_500";
      final String dbUser = "revotasadm";
      final String dbPassword = "abs0lut";
      PrintWriter printWriter = new PrintWriter(out);

      try {
        Class.forName(driver);

      } catch (ClassNotFoundException e) {
        e.printStackTrace();
      }

      connection = DriverManager.getConnection(urdb, dbUser, dbPassword);
      stmt = connection.createStatement();


    //Have a 10 Meg limit as default
      int iTotalFileSizeLimit = ImageHostUtil.getTotalFileSizeLimit(cust.s_cust_id);
      int iTotalFileSizeUsed = ImageHostUtil.getTotalFileSizeUsed(cust.s_cust_id);
      int iFileSizeLimit = ImageHostUtil.getFileSizeLimit(cust.s_cust_id);
      if (iTotalFileSizeLimit == 0) iTotalFileSizeLimit = 10240000;
      MultipartParser mp = null;
      try
      {
        mp = new MultipartParser(request, iTotalFileSizeLimit);

      }
      catch (Exception e)
      {
        mp = null;
        vErroredImages.add("<td colspan=4><font color=red>No files saved.  Upload exceded total file size limit for customer.</font></td>");
        System.out.println(e.getMessage());
      }
      System.out.println("MPPP "+mp);
      String connectStr = "DefaultEndpointsProtocol=https;AccountName=revotascdn;AccountKey=HKzf4d/7EMc+E/0ay1IMbpvvZ4MzjgmydzoDdqFB9l27Ss5loS5yOulWgiBD+uoykOSWad2V8zRz0daMS2YfiA==;EndpointSuffix=core.windows.net";

      System.out.println("Blob yapilandirma baslandi");
      // Bir container client olusturmak i�in kullanilacak bir BlobServiceClient nesnesi olusturulur
      BlobServiceClient blobServiceClient = new BlobServiceClientBuilder().connectionString(connectStr).buildClient();
      String containerName="cms";

      if (mp != null)
      {
        System.out.println("file name "+sFileName);
        while ((myPart = mp.readNextPart()) != null)
        {
          System.out.println("file name İÇİNDE "+sFileName);
          System.out.println("MYPARTTT333 "+myPart.getClass());
          out.println("NAME :"+myPart.getName());
          if (myPart.getName().equals("category_id")) sSelectedCategoryId = ((ParamPart)myPart).getStringValue();
          if (myPart.getName().equalsIgnoreCase("image_id"))
          {
            sImageId = ((ParamPart)myPart).getStringValue();
            if (sImageId == null) sImageId = "0";

          }

          if (myPart.getName().equals("folder_id")) sFolderId = ((ParamPart)myPart).getStringValue();

          if (myPart.getName().equals("folder_name")) sFolderName = ((ParamPart)myPart).getStringValue();


          if (myPart.getName().equals("image_url")) sImageUrl = ((ParamPart)myPart).getStringValue();
          if (myPart.getName().equals("overwrite"))
          {
            System.out.println("geçtiiiii-1");

            sOverwrite = ((ParamPart)myPart).getStringValue();
            if (sOverwrite != null) bOverwrite = true;
          }
          if (myPart.getName().equals("access_map"))
          {
            System.out.println("geçtiiiii0");

            sAccessCusts = ((ParamPart)myPart).getStringValue();
            sAccessMap = sAccessCusts.split(";");
          }
          System.out.println("MYPARTTT "+myPart.getClass());
          System.out.println("VsavedImages = "+vSavedImages.isEmpty());
          if (myPart.isFile())
          {
            System.out.println("İÇERİDEYİMM...");
            fpImage = (FilePart) myPart;
            System.out.println(fpImage);
            String contentType=fpImage.getContentType();
            String[] UZANTI = contentType.split("/");
            Date now = new Date();

            SimpleDateFormat format = new SimpleDateFormat("dMyyyy-hhmmss");


            if (fpImage != null)
            {
              sFileName = fpImage.getFileName();
              if (sOverwrite == null)	bOverwrite = false;


              // check file extension to see if it is a ZIP file
              if (ImageHostUtil.isZipFile(sFileName))
              {
                if (myPart.getName().equals("zip_file"))
                {

                  vZipFiles = ImageHostUtil.processZipFile(fpImage, cust.s_cust_id, sFolderId, user.s_user_id, false, sAccessMap);
                  break;
                }
                else
                {    // ZIP file loaded with image files.  Can't do it.
                  sProcessedMsg = "Cannot load ZIP file while uploading image files. Upload ZIP files separately.";
                }
              }
              else
              {
                sProcessedMsg = ImageHostUtil.processFile(fpImage, cust.s_cust_id, sFolderId, user.s_user_id, sImageId, sFileName, false, sAccessMap);

              }
            }

            if (sProcessedMsg.equalsIgnoreCase("success")) {

              //Localde resmin cekildigi uzanti
              String path =null;
              //CDN de bulunmasi istenen uzanti
              String url =null;

              String ssql="select file_path from ccnt_img_folder where folder_id="+sFolderId;
              rs=stmt.executeQuery(ssql);
              while (rs.next()){
                path=rs.getString("file_path");
              }
              String no="c:\\Revotas\\cms\\web\\";
              String noUrl=path.substring(path.indexOf(no)+no.length());

              url=noUrl+sFileName;
              System.out.println("PATH1:"+path);
              path=path+sFileName;
              System.out.println("PATH2: "+path);
              System.out.println("NOURL:"+noUrl);
              System.out.println("URL: "+url);

              vSavedImages.add(sFileName);


              //Container var mi diye kontrol edilir yoksa yenisini kurar
              if(!(blobServiceClient.getBlobContainerClient(containerName).exists())){
                System.out.println("Yeni container kuruluyor");
                BlobContainerClient containerClient = blobServiceClient.createBlobContainer(containerName);
                BlobClient blobClient = containerClient.getBlobClient(url);
                if(path.contains(".jpg")){
                  blobClient.uploadFromFile(path.toString());
                  changeContentTypeJpg(blobClient);
                }
                if(path.contains(".pdf")){
                  blobClient.uploadFromFile(path.toString());
                  changeContentTypePdf(blobClient);
                }
              }else{
                System.out.println("Kurulumu daha once yapilmis container");
                BlobContainerClient containerClient = blobServiceClient.getBlobContainerClient(containerName);
                BlobClient blobClient = containerClient.getBlobClient(url);
                if(path.contains(".jpg")){
                  blobClient.uploadFromFile(path.toString());
                  changeContentTypeJpg(blobClient);
                }
                if(path.contains(".pdf")){
                  blobClient.uploadFromFile(path.toString());
                  changeContentTypePdf(blobClient);
                }
              }
              //TODO canliya alininca acilmasi gereken sorgu
              //TODO PAZARTESI BURAYA BAK
              String DOMAIN_URL ="'https://revocdn.revotas.com/cms/%s'";
              DOMAIN_URL = String.format(DOMAIN_URL,url);
              String sql ="Update ccnt_image set url_path= "+DOMAIN_URL+" where cust_id= "+cust.s_cust_id+" and image_name='%s'";
              sql=String.format(sql,sFileName);
              stmt.executeUpdate(sql);
            }
            else
            {
              vErroredImages.add("<td>" + sFileName + "</td><td>Image</td><td><font color=red>Error</font></td><td>" + sProcessedMsg + "</td>");
            }
          }
        }
        int itemCount = 0;

        if (vSavedImages != null && vSavedImages.size() > 0)
        {
          Iterator itSavedImages = vSavedImages.iterator();
          while (itSavedImages.hasNext()) {

            itemCount++;
			break;
          }

        }

        if(vErroredImages != null && vErroredImages.size()>0 ){
          Iterator itErroredImages = vErroredImages.iterator();
          while (itErroredImages.hasNext()){
            itemCount++;
			break;
          }
        }

        if(vZipFiles != null && vZipFiles.size()>0 ){
          Iterator itZipFiles = vZipFiles.iterator();
          while (itZipFiles.hasNext()){
            String sTmp = (String)itZipFiles.next();
            itemCount++;
			break;
          }
        }

        if(itemCount ==0){
          out.println("No images or folders were saved or uploaded.");
        }
        JSONObject info = new JSONObject();
        String message = "success";
        info.put("message: ", message);
        out.print(info);


      }
    %>
