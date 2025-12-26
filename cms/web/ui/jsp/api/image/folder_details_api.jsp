<%@ page
        language="java"
        import="javax.servlet.http.*,
                javax.servlet.*,
                com.britemoon.cps.*,
                com.britemoon.*,
                com.britemoon.cps.ctl.*,
                com.britemoon.cps.cnt.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

    boolean bCanExecute = can.bExecute;
    boolean bCanWrite = (can.bWrite || bCanExecute);


    String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;

    String sErrors = BriteRequest.getParameter(request, "errors");
    String sFolderId = BriteRequest.getParameter(request, "folder_id");

    JsonArray jsonArray = new JsonArray();
    JsonObject jsonObject = new JsonObject();

    try {
        if (sFolderId == null) {
            throw new Exception("Cannot display folder details.  Folder ID not found.");
        }
        ImgFolder folder = new ImgFolder(sFolderId);
        String sPath = folder.getPrettyPath();

        String sGlobalFolderId = ImageHostUtil.getGlobalRoot(cust.s_cust_id);
        String sFolderHTML = ImageHostUtil.getFolderOptionsHTML(sGlobalFolderId, 0, sFolderId, cust.s_cust_id);
        String sRootFolderId = ImageHostUtil.getRoot(cust.s_cust_id);
        sFolderHTML += ImageHostUtil.getFolderOptionsHTML(sRootFolderId, 0, sFolderId, cust.s_cust_id);


//        String cleanedFolderHTML = sFolderHTML.replaceAll("<[^>]+>", "");
//        cleanedFolderHTML = cleanedFolderHTML.replaceAll("&nbsp;", "");
//        cleanedFolderHTML = cleanedFolderHTML.replaceAll("\r", "");
//        cleanedFolderHTML = cleanedFolderHTML.replaceAll("\n", "");

        String cleanedPath = sPath.replaceAll("<[^>]+>", "");
        cleanedPath = cleanedPath.replaceAll("&nbsp;", "");
        cleanedPath = cleanedPath.replaceAll("&gt;", "/");
        cleanedPath = cleanedPath.replaceAll("\r", "");
        cleanedPath = cleanedPath.replaceAll("\n", "");

        jsonObject.put("path", cleanedPath);
        jsonObject.put("rootFolderId", sRootFolderId);
//        jsonObject.put("folderHTML", cleanedFolderHTML);


        if (bCanWrite) {
            //Only show Set Access if folder is global type, is not root global, and cust has children

            // Connection
            Statement stmt = null;
            ResultSet rs = null;
            ConnectionPool cp = null;
            Connection conn = null;
            /* *** */


            int nChildCount = -1;
            try {
                cp = ConnectionPool.getInstance();
                conn = cp.getConnection("image_new.jsp");
                stmt = conn.createStatement();

                rs = stmt.executeQuery("EXEC usp_ccps_cust_tree_get @cust_id = " + cust.s_cust_id);
                while (rs.next()) {
                    //only interested in last customer on chain
                    nChildCount++;
                }
                rs.close();

            } catch (Exception ex) {

                throw ex;

            } finally {
                if (stmt != null) stmt.close();
                if (conn != null) cp.free(conn);
            }

        }
        int iCount = -1;
        int iItems = 0;
        boolean bHasContents = false;

        //get and display subfolders
        folder.getSubFolders(cust.s_cust_id);

        if (folder.m_SubFolders != null && folder.m_SubFolders.size() > 0) {
            bHasContents = true;
            Iterator itSubFolders = folder.m_SubFolders.iterator();
            JsonArray subFolderArray = new JsonArray();
            JsonObject subFolderObject = new JsonObject();
            while (itSubFolders.hasNext()) {
                subFolderObject = new JsonObject();
                ImgFolder subFolder = (ImgFolder) itSubFolders.next();
                iCount++;
                iItems++;

                subFolderObject.put("subFolderId", subFolder.s_folder_id);
                subFolderObject.put("subFolderName", subFolder.s_folder_name);

                subFolderArray.put(subFolderObject);

                if (iCount >= 4) {
                    iCount = 0;
                }

            }
            jsonArray.put(subFolderArray);
        }
        //get and display images
        folder.getImages(cust.s_cust_id);
        iItems = 0;

        if (folder.m_Images != null && folder.m_Images.size() > 0) {
            bHasContents = true;
            Iterator itImages = folder.m_Images.iterator();
            JsonArray imageArray = new JsonArray();
            JsonObject imageObject = new JsonObject();
            while (itImages.hasNext()) {
                imageObject = new JsonObject();
                Image image = (Image) itImages.next();
                iCount++;
                iItems++;


                imageObject.put("imageId", image.s_image_id);
                imageObject.put("imageUrl", image.s_url_path.replace("\\", "/"));
                imageObject.put("imageName", image.s_image_name);

                imageArray.put(imageObject);

                if (iCount >= 4) {
                    iCount = 0;
                }

            }
            jsonArray.put(imageArray);
        }
        jsonArray.put(jsonObject);
        out.print(jsonArray);
    } catch (Exception ex) {

        ErrLog.put(this, ex, "Problem producing Image list", out, 1);

    }
%>
