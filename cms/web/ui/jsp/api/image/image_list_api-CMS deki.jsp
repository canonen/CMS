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
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"

%>

<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
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

    String userCustId = user.s_cust_id;
    String custCustId = cust.s_cust_id;
    boolean bCanExecute = can.bExecute;
    boolean bCanWrite = can.bExecute;


    String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
    if ((sSelectedCategoryId == null) && ((userCustId).equals(custCustId)))
        sSelectedCategoryId = ui.s_category_id;

    String sErrors = BriteRequest.getParameter(request, "errors");

   	JsonArray array = new JsonArray();
   	JsonArray array2 = new JsonArray();
   	JsonArray array3 = new JsonArray();
   	JsonArray array4 = new JsonArray();
   	JsonArray array5 = new JsonArray();
   	JsonArray finalArray = new JsonArray();
    
        JsonObject data;
        JsonObject data2;
        JsonObject data3;
        JsonObject data4;
        JsonObject data5;


    try {

        ConnectionPool cp = null;
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        String sql = null;
        try {


        } catch (Exception e) {
            throw new RuntimeException(e);
        }


        // get the ID for the Root Folder.  If this customer has no root folder, create it.
        String sRootFolderId = null;
        sRootFolderId = ImageHostUtil.getRoot(cust.s_cust_id);
        if ((sRootFolderId == null) && (can.bWrite)) {
            sRootFolderId = ImageHostUtil.createRoot(cust.s_cust_id, user.s_user_id);
        }

        String sGlobalFolderId = null;
        sGlobalFolderId = ImageHostUtil.getGlobalRoot(cust.s_cust_id);
        if (sGlobalFolderId == null) {
            sGlobalFolderId = ImageHostUtil.createGlobalRoot(cust.s_cust_id, user.s_user_id);
        }

        String sRootId = null;


        //        Global Folder

        ImgFolder globalFolder = null;
	
        globalFolder = new ImgFolder(sGlobalFolderId);

        int globalImgSize = globalFolder.getImgSize(cust.s_cust_id);
        int globalImgCount = globalFolder.getImgCount(cust.s_cust_id);
        String globalFolderId = globalFolder.s_folder_id;
        String globalFolderName = globalFolder.s_folder_name;
        String globalLastModDate = globalFolder.s_last_mod_date;

        data = new JsonObject();

        data.put("global_folder_id", globalFolderId);
        data.put("global_folder_name", globalFolderName);
        data.put("global_img_size", globalImgSize);
        data.put("global_img_count", globalImgCount);
        data.put("type", "global-folder");
        data.put("global_last_mod_date", globalLastModDate);

        array.put(data);

        //        Root Folder

        ImgFolder rootFolder = null;
		
        rootFolder = new ImgFolder(sRootFolderId);
        int rootImgSize = rootFolder.getImgSize(cust.s_cust_id);
        int rootImgCount = rootFolder.getImgCount(cust.s_cust_id);
        String rootFolderId = rootFolder.s_folder_id;
        String rootFolderName = rootFolder.s_folder_name;
        String rootLastModDate = rootFolder.s_last_mod_date;

        data2 = new JsonObject();
        data2.put("root_folder_id", rootFolderId);
        data2.put("root_folder_name", rootFolderName);
        data2.put("root_img_size", rootImgSize);
        data2.put("root_img_count", rootImgCount);
        data2.put("root_last_mod_date", rootLastModDate);
        data2.put("type", "root-folder");

        array2.put(data2);

        //        Sub Folder

        ImgFolder subFolder = null;

        rootFolder.getSubFolders(cust.s_cust_id);
        rootFolder.getImages(cust.s_cust_id);

        globalFolder.getSubFolders(cust.s_cust_id);
        globalFolder.getImages(cust.s_cust_id);
		int counter=0;
        Iterator rootSubFolders = rootFolder.m_SubFolders.iterator();
        Iterator globalSubFolders = globalFolder.m_SubFolders.iterator();

        while (rootSubFolders.hasNext()) {
			System.out.println(counter++);
            data3 = new JsonObject();
            subFolder = (ImgFolder) rootSubFolders.next();

            data3.put("parent_folder_id",subFolder.s_parent_id);
            data3.put("root_sub_folder_id", subFolder.s_folder_id);
            data3.put("root_sub_folder_name", subFolder.s_folder_name);
            data3.put("root_sub_folder_img_count", subFolder.getImgCount(cust.s_cust_id));
            data3.put("root_sub_folder_img_size", subFolder.getImgSize(cust.s_cust_id));
            data3.put("root_sub_folder_last_mod_date", subFolder.s_last_mod_date);
            data3.put("type", "root-sub-folder");
            array3.put(data3);
			
        }
         


        while (globalSubFolders.hasNext()) {
			System.out.println(counter++);
            data4 = new JsonObject();
            subFolder = (ImgFolder) globalSubFolders.next();

            data4.put("global_sub_folder_id", subFolder.s_folder_id);
            data4.put("global_sub_folder_name", subFolder.s_folder_name);
            data4.put("global_sub_folder_img_count", subFolder.getImgCount(cust.s_cust_id));
            data4.put("global_sub_folder_img_size", subFolder.getImgSize(cust.s_cust_id));
            data4.put("global_sub_folder_last_mod_date", subFolder.s_last_mod_date);
            data4.put("type", "global-sub-folder");
            array4.put(data4);
			
        }
        

        //        Image Folder

        Iterator itImages = rootFolder.m_Images.iterator();
        Image image = null;
        String imageFileName = "";
        int nameStart = 0;

        while (itImages.hasNext()) {
			System.out.println(counter++);
            data5 = new JsonObject();
            image = (Image) itImages.next();
            imageFileName = image.s_url_path;
            nameStart = imageFileName.lastIndexOf("/");
            imageFileName = imageFileName.substring(nameStart + 1);

            data5.put("parent_folder_id",image.s_folder_id);
            data5.put("image_id", image.s_image_id);
            data5.put("image_name", imageFileName);
            data5.put("image_url", image.s_url_path);
            data5.put("image_size", image.s_size);
            data5.put("image_last_mod_date", image.s_last_mod_date);
            data5.put("type", "image");
            array5.put(data5);
            
			
        }  

        finalArray.put(array);
        finalArray.put(array2);
        finalArray.put(array3);
        finalArray.put(array4);
        finalArray.put(array5);
 
        out.println(finalArray);

    } catch (Exception ex) {

        logger.error("Problem producing Image list", ex);

    }
%>
