<%--
  Created by IntelliJ IDEA.
  User: MusaUysal
  Date: 1/8/2023
  Time: 7:02 PM
  To change this template use File | Settings | File Templates.
--%>
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
<%@ page import="org.apache.commons.lang.ObjectUtils" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>

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
    String sExportDir = Registry.getKey("import_data_dir");
    if (sExportDir == null)
    {
        throw new Exception("'sas_export_dir' key is not found in registry");
        // sExportDir = "D:\\britemoon\\adm\\web\\export\\";
    }

    String custIdHash = cust.s_cust_id;
    byte[] defaultBytes = custIdHash.getBytes();
    String hashId = "";

    try{
        MessageDigest algorithm = MessageDigest.getInstance("MD5");
        algorithm.reset();
        algorithm.update(defaultBytes);
        byte messageDigest[] = algorithm.digest();

        StringBuffer hexString = new StringBuffer();
        for (int i=0;i<messageDigest.length;i++) {
            hexString.append(Integer.toHexString(0xFF & messageDigest[i]));
        }

        hashId = hexString.toString();


    }catch(NoSuchAlgorithmException nsae){
         nsae.printStackTrace();
    }

    try {
        // see if we need to delete a report
        if ( (ACTION != null) && (ACTION.equals("1")) && (FILENAME != null) && (FILENAME.length() > 0) ) {
            String name = null;
            name = sExportDir + hashId + "/" + FILENAME;
            try {
                File f = new File(name);
                if (f.exists()) {
                    boolean rc = f.delete();
                }
                out.print(FILENAME+" silindi...");
            }
            catch (Exception e) {
                out.print(FILENAME+" silinemedi...");
            };
        }
    } catch (Exception e) {
         e.printStackTrace();
    }


%>
