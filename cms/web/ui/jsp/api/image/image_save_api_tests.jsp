<%@ page
    language="java"
    import="com.oreilly.servlet.multipart.*,
    com.oreilly.servlet.multipart.Part,
    com.britemoon.*,
    com.britemoon.cps.cnt.*,
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
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>

<%
    AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

    if (!can.bExecute) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    String sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;
    
    String sImageId=BriteRequest.getParameter(request,"image_id");
    String sErrors = BriteRequest.getParameter(request,"errors");    
    //String sImageId = "0";
    String sFolderId=BriteRequest.getParameter(request,"folder_id");
    String sFolderName=BriteRequest.getParameter(request,"folder_name");
    String sImageUrl=BriteRequest.getParameter(request,"image_url");
    //String sAccessMap=BriteRequest.getParameter(request,"access_map");
    String sFileName =BriteRequest.getParameter(request,"file_name");
    String sOverwrite = null;
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
    final String urdb = "jdbc:sqlserver://cms.revotas.com:1433;databaseName=brite_ccps_500";
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

    // Have a 10 Meg limit as default
    int iTotalFileSizeLimit = ImageHostUtil.getTotalFileSizeLimit(cust.s_cust_id);
    int iTotalFileSizeUsed = ImageHostUtil.getTotalFileSizeUsed(cust.s_cust_id);
    int iFileSizeLimit = ImageHostUtil.getFileSizeLimit(cust.s_cust_id);
    if (iTotalFileSizeLimit == 0) iTotalFileSizeLimit = 10240000;
    MultipartParser mp = null;

    try {
        mp = new MultipartParser(request, iTotalFileSizeLimit);
    } catch (Exception e) {
        mp = null;
        vErroredImages.add("<td colspan=4><font color=red>No files saved.  Upload exceeded total file size limit for customer.</font></td>");
    }

    String connectStr = "DefaultEndpointsProtocol=https;AccountName=revotascdn;AccountKey=HKzf4d/7EMc+E/0ay1IMbpvvZ4MzjgmydzoDdqFB9l27Ss5loS5yOulWgiBD+uoykOSWad2V8zRz0daMS2YfiA==;EndpointSuffix=core.windows.net";

    // Create a BlobServiceClient to interact with the Azure Blob Storage
    BlobServiceClient blobServiceClient = new BlobServiceClientBuilder().connectionString(connectStr).buildClient();
    String containerName = "cms";

    if (mp != null) {
        while ((myPart = mp.readNextPart()) != null) {

            if (myPart.getName().equals("category_id")) sSelectedCategoryId = ((ParamPart) myPart).getStringValue();
            if (myPart.getName().equalsIgnoreCase("image_id")) {
                sImageId = ((ParamPart) myPart).getStringValue();
                if (sImageId == null) sImageId = "0";
            }

            if (myPart.getName().equals("folder_id")) sFolderId = ((ParamPart) myPart).getStringValue();

            if (myPart.getName().equals("folder_name")) sFolderName = ((ParamPart) myPart).getStringValue();


            if (myPart.getName().equals("image_url")) sImageUrl = ((ParamPart) myPart).getStringValue();
            if (myPart.getName().equals("overwrite")) {
                sOverwrite = ((ParamPart) myPart).getStringValue();
                if (sOverwrite != null) bOverwrite = true;
            }
            if (myPart.getName().equals("access_map")) {
                sAccessCusts = ((ParamPart) myPart).getStringValue();
                sAccessMap = sAccessCusts.split(";");
            }
            if (myPart.isFile()) {
                fpImage = (FilePart) myPart;
                String contentType = fpImage.getContentType();
                String[] UZANTI = contentType.split("/");
                Date now = new Date();
                SimpleDateFormat format = new SimpleDateFormat("dMyyyy-hhmmss");

                if (fpImage != null) {
                    sFileName = fpImage.getFileName();
                    if (sOverwrite == null) bOverwrite = false;

                    // check file extension to see if it is a ZIP file
                    if (ImageHostUtil.isZipFile(sFileName)) {

                        if (myPart.getName().equals("zip_file")) {

                            vZipFiles = ImageHostUtil.processZipFile(fpImage, cust.s_cust_id, sFolderId, user.s_user_id, false, sAccessMap);
                            break;
                        } else {
                            // ZIP file loaded with image files. Can't do it.
                            sProcessedMsg = "Cannot load ZIP file while uploading image files. Upload ZIP files separately.";
                        }
                    } else {
                        sProcessedMsg = ImageHostUtil.processFile(fpImage, cust.s_cust_id, sFolderId, user.s_user_id, sImageId, sFileName, false, sAccessMap);
                    }
                }
                if (sProcessedMsg.equalsIgnoreCase("success")) {

                    // Localde resmin çekildiği uzantı
                    String path = null;
                    // CDN de bulunmasi istenen uzanti
                    String url = null;

                    String ssql = "select file_path from ccnt_img_folder where folder_id=" + sFolderId;
                    rs = stmt.executeQuery(ssql);
                    while (rs.next()) {
                        path = rs.getString("file_path");
                    }
                    String no = "c:\\Revotas\\cms\\web\\";
                    String noUrl = path.substring(path.indexOf(no) + no.length());

                    url = noUrl + sFileName;

                    vSavedImages.add(sFileName);

                    // Container var mı diye kontrol edilir yoksa yenisini kurar
                    if (!(blobServiceClient.getBlobContainerClient(containerName).exists())) {
                        BlobContainerClient containerClient = blobServiceClient.createBlobContainer(containerName);
                        BlobClient blobClient = containerClient.getBlobClient(url);
                        if (path.contains(".jpg")) {
                            blobClient.uploadFromFile(path.toString());
                            BlobHttpHeaders blobHttpHeaders = new BlobHttpHeaders();//
                            blobHttpHeaders.setContentType("image/jpg");
                            blobClient.setHttpHeaders(blobHttpHeaders);
                        }
                        if (path.contains(".pdf")) {
                            blobClient.uploadFromFile(path.toString());
                            BlobHttpHeaders blobHttpHeaders = new BlobHttpHeaders();//
                            blobHttpHeaders.setContentType("application/pdf");
                            blobClient.setHttpHeaders(blobHttpHeaders);
                        }
                    } else {
                        BlobContainerClient containerClient = blobServiceClient.getBlobContainerClient(containerName);
                        BlobClient blobClient = containerClient.getBlobClient(url);
                        if (path.contains(".jpg")) {
                            blobClient.uploadFromFile(path.toString());
                            BlobHttpHeaders blobHttpHeaders = new BlobHttpHeaders();//
                            blobHttpHeaders.setContentType("image/jpg");
                            blobClient.setHttpHeaders(blobHttpHeaders);
                        }
                        if (path.contains(".pdf")) {
                            blobClient.uploadFromFile(path.toString());
                            BlobHttpHeaders blobHttpHeaders = new BlobHttpHeaders();//
                            blobHttpHeaders.setContentType("application/pdf");
                            blobClient.setHttpHeaders(blobHttpHeaders);
                        }
                    }

                    // TODO canlıya alınınca açılması gereken sorgu
                    // TODO PAZARTESİ BURAYA BAK
                    String DOMAIN_URL = "'https://revocdn.revotas.com/cms/%s'";
                    DOMAIN_URL = String.format(DOMAIN_URL, url);
                    String sql = "Update ccnt_image set url_path= " + DOMAIN_URL + " where cust_id= " + cust.s_cust_id + " and image_name='%s'";
                    sql = String.format(sql, sFileName);
                    stmt.executeUpdate(sql);
                } else {
                    vErroredImages.add("<td>" + sFileName + "</td><td>Image</td><td><font color=red>Error</font></td><td>" + sProcessedMsg + "</td>");
                }
            }
        }
    }
%>