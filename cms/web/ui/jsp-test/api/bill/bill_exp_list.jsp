<%@ page
        import="com.britemoon.*"
        import="com.britemoon.cps.*"
        import="java.io.*"
        import="java.sql.*"
        import="java.util.*"
        import="java.security.MessageDigest"
        import="java.security.NoSuchAlgorithmException"
        import="org.apache.log4j.*"
        import="java.text.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp" %>

<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    if (!can.bWrite) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }


    String ACTION = request.getParameter("action");
    String FILENAME = request.getParameter("filename");
    JsonObject data;
    JsonArray array = new JsonArray();

    String sExportDir = Registry.getKey("import_data_dir");
    if (sExportDir == null) {
        throw new Exception("'sas_export_dir' key is not found in registry");
        // sExportDir = "D:\\britemoon\\adm\\web\\export\\";
    }
    String sExportUrl = Registry.getKey("import_url_dir");
    if (sExportUrl == null) {
        throw new Exception("'sas_export_url' key is not found in registry");
        // sExportUrl = "http://192.168.0.226:80/sadm/export/";
    }


    //Hash Customer ID

    String custIdHash = cust.s_cust_id;
    byte[] defaultBytes = custIdHash.getBytes();
    String hashId = "";

    try {
        MessageDigest algorithm = MessageDigest.getInstance("MD5");
        algorithm.reset();
        algorithm.update(defaultBytes);
        byte messageDigest[] = algorithm.digest();

        StringBuffer hexString = new StringBuffer();
        for (int i = 0; i < messageDigest.length; i++) {
            hexString.append(Integer.toHexString(0xFF & messageDigest[i]));
        }

        hashId = hexString.toString();

    } catch (NoSuchAlgorithmException nsae) {

    }

    String sClassAppend = "";

    // see if we need to delete a report
    if ((ACTION != null) && (ACTION.equals("1")) && (FILENAME != null) && (FILENAME.length() > 0)) {
        String name = null;
        name = sExportDir + hashId + "/" + FILENAME;
        try {
            File f = new File(name);
            if (f.exists()) {
                boolean rc = f.delete();
            }
        } catch (Exception e) {
        }
        ;
    }
    File dir = new File(sExportDir + hashId + "/");


    File[] files = dir.listFiles();

    if (files == null) {
        out.print("There is no export.");

    } else {

        SimpleDateFormat formatter = new SimpleDateFormat("MMM dd yyyy hh:mm aaa");
        String s_file_name = "";
        String s_file_url = "";
        java.util.Date d = null;
        String s_file_date = "";
        Long s_file_size = 0L;


        int fileCount = 0;
        while(fileCount<files.length) {
                data = new JsonObject();
            if (files[fileCount].isFile()) {
                s_file_name = files[fileCount].getName();
                s_file_url = sExportUrl + hashId + "/" + s_file_name;
                d = new java.util.Date(files[fileCount].lastModified());
                s_file_date = formatter.format(d);
                s_file_size = files[fileCount].length();

                data.put("fileId",fileCount);
                data.put("fileUrl", s_file_url);
                data.put("fileName", s_file_name);
                data.put("fileDate", s_file_date);
                data.put("fileSize", s_file_size);
                array.put(data);
            }
            fileCount++;
        }
        out.print(array);
    }

%>
