<%@ page
        language="java"
        import="com.britemoon.cps.upd.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.*,
                com.britemoon.*,
                java.io.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                org.w3c.dom.*,
                org.apache.log4j.*"
        errorPage="../error_page.jsp"
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

    AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    String sImportId = request.getParameter("import_id");
    String sType = request.getParameter("type");
    int nType = Integer.parseInt(sType);
    String sImportURL = null;
    try {
        Import imp = new Import(sImportId);
        if ((imp.s_import_file == null) || (imp.s_import_file.trim().equals(""))) {
            String sErrMsg =
                    "import_detail.jsp ERROR: " +
                            "import_file is not specified. import_id = " + imp.s_import_id;
            throw new Exception(sErrMsg);
        }

        String sFileType = null;

        switch (nType) {
            case 0: //Commit
                jsonObject.put("nType", "Sample 25 records processed from Import file.");
                sFileType = "preview";
                break;
            case 1: //Bad Emails
                jsonObject.put("nType", "Records that produced an Error in processing.");
                sFileType = "errors";
                break;
            case 2: //File Dups
                jsonObject.put("nType", "Duplicates within the Import file.");
                sFileType = "int_dups";
                break;
            case 3: //Warnings
                jsonObject.put("nType", "Records that produced a Warning in processing.");
                sFileType = "warn";
                break;
            case 4: //DB Dups
                jsonObject.put("nType", "Recipients that already exist in the database.");
                sFileType = "ext_dups";
                break;
            case 5: //Bad Fingerprints
                jsonObject.put("nType", "Invalid Recipients.");
                sFileType = "bad_fingerprints";
                break;
            default:
                throw new Exception("Unknown type.");
        }

        // === === ===

        Vector services = Services.getByCust(ServiceType.RUPD_IMPORT_RESULT_FILE_VIEW, cust.s_cust_id);
        Service service = (Service) services.get(0);

        sImportURL = service.getURL().toString();
        sImportURL +=
                "?cust_id=" + cust.s_cust_id +
                        "&import_id=" + imp.s_import_id +
                        "&file_type=" + sFileType +
                        "&import_file=" + imp.s_import_file.trim();
        jsonObject.put("url", sImportURL);
        HttpURLConnection huc = null;
        try {
            jsonArray.put(jsonObject);
            out.print(jsonArray);
            URL url = new URL(sImportURL);
            huc = (HttpURLConnection) url.openConnection();
            huc.setDoOutput(false);
            huc.setDoInput(true);
            BufferedReader inRCP = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8"));
            for (String sLine = inRCP.readLine(); sLine != null; sLine = inRCP.readLine()) {
                jsonObject.put("line", sLine);

            }

            inRCP.close();
            huc.disconnect();
            if (huc.getResponseCode() != HttpServletResponse.SC_OK) {
                throw new IOException("import_detail.jsp ERROR: " + huc.getResponseMessage());
            }
        } catch (Exception ex) {
            throw ex;
        } finally {
            if (huc != null) huc.disconnect();
        }

    } catch (Exception ex) {
        logger.error("import_browse_recs.jsp ERROR: cannot get data from url: ", ex);
    }
%>





