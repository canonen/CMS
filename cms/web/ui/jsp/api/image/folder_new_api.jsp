<%@ page
        language="java"
        import="com.britemoon.cps.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.*,
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

    /*  permission checks */
    AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    JsonArray jsonArray = new JsonArray();
    JsonObject jsonObject = new JsonObject();

    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

    String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;

    String sParentId = BriteRequest.getParameter(request, "parent_id");
    if (sParentId == null)
        sParentId = "";
    String sFolderId = BriteRequest.getParameter(request, "folder_id");
    int nFolderId = Integer.parseInt((sFolderId == null) ? "0" : sFolderId);
    String sFolderName = BriteRequest.getParameter(request, "folder_name");
    if (sFolderName == null)
        sFolderName = "";
    String sErrors = BriteRequest.getParameter(request, "errors");
    String sClone = BriteRequest.getParameter(request, "clone");
    if (sClone == null)
        sClone = "";
    String sPrevFolderName = "";
    String sPrevFolderId = "";
    if (sClone != null && sClone.equals("1")) {
        if (sFolderId != null) {
            ImgFolder prevFolder = new ImgFolder(sFolderId);
            sPrevFolderName = prevFolder.s_folder_name;
            sPrevFolderId = prevFolder.s_folder_id;
            sParentId = prevFolder.s_parent_id;
        }
    }

    String selFolderID = "";

    if (sClone != null && sClone.equals("1")) {
        selFolderID = "";
    } else {
        selFolderID = sFolderId;
    }


    boolean bCanExecute = can.bExecute;
    boolean bCanWrite = (can.bWrite || bCanExecute);
    /* *** */

//UI Type
    boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);
    /* *** */

// Connection
    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool connectionPool = null;
    Connection srvConnection = null;
    /* *** */


    try {
        connectionPool = ConnectionPool.getInstance();
        srvConnection = connectionPool.getConnection("folder_new.jsp");
        stmt = srvConnection.createStatement();

        /* Categories */
        String sSql =
                " SELECT c.category_id, c.category_name" +
                        " FROM ccps_category c" +
                        " WHERE c.cust_id=" + cust.s_cust_id;
        rs = stmt.executeQuery(sSql);

        String sCategoryId = null;
        String sCategoryName = null;
        String htmlCategories = "";
        JsonArray categories = new JsonArray();
        JsonObject category = null;
        while (rs.next()) {
            category = new JsonObject();
            sCategoryId = rs.getString(1);
            sCategoryName = new String(rs.getBytes(2), "UTF-8");
    
            category.put("categoryId", sCategoryId);
            category.put("categoryName", sCategoryName);

            categories.put(category);
             
        }
        jsonObject.put("categories",categories);
        rs.close();
        /* *** */

        String sGlobalFolderId = ImageHostUtil.getGlobalRoot(cust.s_cust_id);
        String sFolderHTML = ImageHostUtil.getFolderOptionsHTML(sGlobalFolderId, 0, selFolderID, cust.s_cust_id);
        String sRootFolderId = ImageHostUtil.getRoot(cust.s_cust_id);
        sFolderHTML += ImageHostUtil.getFolderOptionsHTML(sRootFolderId, 0, selFolderID, cust.s_cust_id);
        jsonObject.put("folderHTML", clearHtml(sFolderHTML));
        jsonObject.put("globalFolderId", sGlobalFolderId);
        jsonObject.put("rootFolderId", sRootFolderId);

        int nChildCount = -1;
        rs = stmt.executeQuery("EXEC usp_ccps_cust_tree_get @cust_id = " + cust.s_cust_id);
        while (rs.next()) {
            //only interested in last customer on chain
            nChildCount++;
        }
        rs.close();
        jsonObject.put("childCount", nChildCount);
        if (nChildCount > 0) {
            String sFolderCustAccessHTML = ImageHostUtil.getFolderCustAccessHTML(cust.s_cust_id, sFolderId);
            jsonObject.put("folderCustAccessHTML", sFolderCustAccessHTML);
        }
        jsonArray.put(jsonObject);
        out.print(jsonArray);

    } catch (Exception ex) {

        throw ex;

    } finally {
        if (stmt != null) stmt.close();
        if (srvConnection != null) connectionPool.free(srvConnection);
    }
%>
<%!
    private String clearHtml(String html) {
        html = html.replaceAll("<[^>]+>", "");
        html = html.replaceAll("&nbsp;", " ");
        html = html.replaceAll("\r", "");
        html = html.replaceAll("\n", "");
        html = html.replaceAll("\t", "");

        return html;
    }
%>