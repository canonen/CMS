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

// if input_name is not null, we will assume this page was opened from ccps/ui/jsp/ctm/sectionedit.jsp.
// we will switch to the 'selector mode', which will update the input field from sectionedit.jsp
// after a section has been made

    String sInputName = BriteRequest.getParameter(request, "input_name");
    String sFolderId = BriteRequest.getParameter(request, "folder_id");
    String sErrors = BriteRequest.getParameter(request, "errors");

    String sRootFolderId = null;
    String sGlobalFolderId = null;

    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();

    try {
        //no folder specified, grab root.
        sRootFolderId = ImageHostUtil.getRoot(cust.s_cust_id);
        sGlobalFolderId = ImageHostUtil.getGlobalRoot(cust.s_cust_id);

        if ((sRootFolderId == null) && (sGlobalFolderId == null)) {
            //No Images;
            sErrors = "This system does not have any images loaded.";
        }

        if ((sFolderId == null) || ("".equals(sFolderId))) {
            sFolderId = (sGlobalFolderId != null) ? sGlobalFolderId : sRootFolderId;
        }

        if (sErrors == null) {

            if (sFolderId == null) {
                throw new Exception("Cannot display folder details.  Folder ID not found.");
            }
            ImgFolder folder = new ImgFolder(sFolderId);
            String sPath = folder.getPrettyPathUrl(sInputName);

            String sFolderHTML = ImageHostUtil.getFolderOptionsHTML(sGlobalFolderId, 0, sFolderId, cust.s_cust_id);
            sFolderHTML += ImageHostUtil.getFolderOptionsHTML(sRootFolderId, 0, sFolderId, cust.s_cust_id);

            //sFolderHTML;

            String cleanedPath = sPath.replaceAll("<[^>]+>", "");
            cleanedPath = cleanedPath.replaceAll("&nbsp;", "");
            cleanedPath = cleanedPath.replaceAll("&gt;", "/");
            cleanedPath = cleanedPath.replaceAll("\r", "");
            cleanedPath = cleanedPath.replaceAll("\n", "");

            jsonObject.put("path", cleanedPath);

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
        }
        jsonArray.put(jsonObject);
        out.print(jsonArray);

    } catch (Exception ex) {

        ErrLog.put(this, ex, "Problem producing Image list", out, 1);

    }
%>
