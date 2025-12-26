<%@ page
        language="java"
        import="com.oreilly.servlet.multipart.*,
                com.oreilly.servlet.multipart.Part,
                com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.cnt.*,
                java.io.*,
                java.util.*,
                java.sql.*,
                javax.servlet.http.*,
                javax.servlet.*,
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

    if (!can.bExecute) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    Statement stmt = null;
    PreparedStatement prepStmt = null;
    ResultSet rs = null;
    ConnectionPool connectionPool = null;
    Connection srvConnection = null;
    String sSql = null;
    JsonArray jsonArray = new JsonArray();
    JsonObject jsonObject = new JsonObject();

    try {
        connectionPool = ConnectionPool.getInstance();
        srvConnection = connectionPool.getConnection("folder_save.jsp");
        stmt = srvConnection.createStatement();

        String sCategories = BriteRequest.getParameter(request, "categorytemp");
        String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");

        String sFolderName = BriteRequest.getParameter(request, "folder_name");
        sFolderName = sFolderName.replace(' ', '_');

        String sFolderId = BriteRequest.getParameter(request, "folder_id");
        String sParentId = BriteRequest.getParameter(request, "parent_id");
        String sClone = BriteRequest.getParameter(request, "clone");
        if (sClone == null)
            sClone = "0";
        String sPrevFolderId = BriteRequest.getParameter(request, "prevFolderId");

        String sAccessCusts = BriteRequest.getParameter(request, "access_map");
        String[] sAccessMap = sAccessCusts.split(";");

        if (sParentId == null || sParentId.length() == 0 || sParentId.equals("null")) {

            jsonObject.put("Message", "No Parent Folder ID parameter found...cannot save folder");
            jsonArray.put(jsonObject);
            throw new Exception("No Parent Folder ID parameter found...cannot save folder");
        }

        /* check for duplicate folder path */
        boolean bDuplicateFolder = false;
        String sExistingFolderId = null;
        sExistingFolderId = ImageHostUtil.getFolderIdFromName(cust.s_cust_id, sParentId, sFolderName);
        if (sExistingFolderId != null) {            //&& sFolderId != null && !sExistingFolderId.equalsIgnoreCase(sFolderId))
            bDuplicateFolder = true;
            String sErrors = "ERROR--Duplicate folder path.  Could not save folder.";
            jsonObject.put("Message", sErrors);
            jsonArray.put(jsonObject);
            response.sendRedirect("folder_new.jsp?parent_id=" + sParentId + "&folder_name=" + sFolderName + "&errors=" + sErrors);
        } else {
            /*  ***  */
            /* Save or Create folder */
            if (sClone == null || sClone.equals("0")) {
                sFolderId = ImageHostUtil.createFolder(cust.s_cust_id, sFolderName, sParentId, user.s_user_id, sAccessMap);
                jsonObject.put("Message", "Folder created successfully");
                jsonArray.put(jsonObject);
            } else if (sClone.equals("1")) {
                sFolderId = ImageHostUtil.cloneFolder(sPrevFolderId, sFolderName, sParentId, user.s_user_id, cust.s_cust_id, sAccessMap);
                jsonObject.put("Message", "Folder cloned successfully");
                jsonArray.put(jsonObject);
            }
        }
        out.print(jsonArray);

    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error in folder_save", out, 1);
        jsonObject.put("Message", "Error in folder_save");
        jsonArray.put(jsonObject);
        out.print(jsonArray);
    } finally {
        if (prepStmt != null) prepStmt.close();
        if (stmt != null) stmt.close();
        if (srvConnection != null) connectionPool.free(srvConnection);
    }

%>