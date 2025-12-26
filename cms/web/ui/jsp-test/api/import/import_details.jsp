<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.upd.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.wfl.*,
                java.io.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                org.w3c.dom.*,
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);
    AccessPermission canFilter = user.getAccessPermission(ObjectType.FILTER);

    boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.IMPORT);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    boolean bCanWrite = can.bWrite;
    boolean bCanExecute = can.bExecute;
    boolean bCanFilter = canFilter.bWrite;

    //UI Type
    boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

    String sSelectedCategoryId = request.getParameter("category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
        sSelectedCategoryId = ui.s_category_id;

    // === === ===

    String sImportID = request.getParameter("import_id");

    // === === ===

    Import imp = new Import(sImportID);
    Batch batch = new Batch(imp.s_batch_id);

    // There was no this check before. It should be.
    // But it is commented because referenced from one of admin pages
    // and right now there is no time to fix it.
    // if(!cust.s_cust_id.equals(batch.s_cust_id)) return; // customer does not match

    // === === ===
    // out.print(imp.s_upd_rule_id + 1000);
    int nUpdRuleId = Integer.parseInt(imp.s_upd_rule_id);
    int nStatusID = Integer.parseInt(imp.s_status_id);

    int nFullNameFlag = 1;
    int nEmailTypeFlag = 1;

    if (imp.s_full_name_flag != null) nFullNameFlag = Integer.parseInt(imp.s_full_name_flag);
    if (imp.s_email_type_flag != null) nEmailTypeFlag = Integer.parseInt(imp.s_email_type_flag);

    // === === ===

    ImportStatistics imp_stats = new ImportStatistics(sImportID);

    // === === ===

    String sStatusName = null;
    String sNewsletters = "";

    // === === ===

    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;

    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();

    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();

        // === === ===

        String sSql =
                " SELECT isnull(s.display_name, s.status_name)" +
                        " FROM cupd_import_status s " +
                        " WHERE s.status_id = " + imp.s_status_id;

        resultSet = statement.executeQuery(sSql);
        if (resultSet.next()) sStatusName = resultSet.getString(1);
        jsonObject.put("status_name", sStatusName);
        resultSet.close();

        resultSet = statement.executeQuery("SELECT ISNULL(c.display_name, a.attr_name)"
                + " FROM cupd_import_newsletter n, ccps_cust_attr c, ccps_attribute a"
                + " WHERE n.attr_id = c.attr_id"
                + " AND c.attr_id = a.attr_id"
                + " AND c.cust_id = " + cust.s_cust_id
                + " AND n.import_id = " + sImportID);


        while (resultSet.next()) {
            byte b[] = resultSet.getBytes(1);
            sNewsletters += (b != null) ? (((sNewsletters.length() > 0) ? ", " : "") + (new String(b, "UTF-8"))) : "";
            // sNewsletters = (b != null) ? (new String(b, "UTF-8")) : "";

        }
        jsonObject.put("sNewsletters", sNewsletters);

        resultSet.close();

        // out.print(jsonArray);
    } catch (Exception ex) {
        ErrLog.put(this, ex, "Problem viewing Import Details", out, 1);
    } finally {
        if (statement != null) statement.close();
        if (connection != null) connectionPool.free(connection);
    }

    // === === ===

    String sUpdRuleId = null;
    switch (nUpdRuleId) {
        case UpdateRule.DISCARD_DUPLICATES:
            sUpdRuleId = "Insert only new recipients discarding duplicates from import.";
            break;
        case UpdateRule.INSERT_ONLY_NEW_FIELDS:
            sUpdRuleId = "Insert only new fields not overwriting existing recipient data.";
            break;
        case UpdateRule.OVERWRITE_IGNORE_BLANKS:
            sUpdRuleId = "Update duplicates ignoring blank import fields.";
            break;
        case UpdateRule.OVERWRITE_WITH_BLANKS:
            sUpdRuleId = "Update duplicates including blank import fields.";
            break;
        default:
            sUpdRuleId = "";
    }
    jsonObject.put("sUpdRule", sUpdRuleId);

    // === === ===

    boolean isApprover = false;
    ApprovalRequest arRequest = null;
    String sAprvlRequestId = request.getParameter("aprvl_request_id");
    if (sAprvlRequestId == null) sAprvlRequestId = "";
    if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
        arRequest = new ApprovalRequest(sAprvlRequestId);
    } else {
        arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.IMPORT), sImportID);
    }

    if (arRequest != null && arRequest.s_approver_id != null &&
            arRequest.s_approver_id.equals(user.s_user_id)) {
        sAprvlRequestId = arRequest.s_approval_request_id;
        isApprover = true;
    }
    jsonObject.put("arRequest", arRequest);
    jsonObject.put("sAprvlRequestId", sAprvlRequestId);

    //html

    jsonObject.put("nStatusID", nStatusID);                      //TODO sorulacak...
    jsonObject.put("sSelectedCategoryId", sSelectedCategoryId);  //TODO sorulacak...


    if (sImportID != null) {
        jsonObject.put("sImportID", sImportID);
    } else {
        jsonObject.put("sImportID", "0");
    }
	//jsonObject.put("importName", HtmlUtil.escape(imp.s_import_name));
    jsonObject.put("importName", imp.s_import_name);
    jsonObject.put("batchName", batch.s_batch_name);
    jsonObject.put("row", imp.s_first_row);
    jsonObject.put("delimiter", imp.s_field_separator);
    jsonObject.put("multiValueFieldDelimiter", imp.s_multi_value_field_separator);

    if (nFullNameFlag == 0) {
        jsonObject.put("nFullNameFlag", "not");
    } else {
        jsonObject.put("nFullNameFlag", "");
    }

    if (imp_stats.s_tot_rows != null) {
        jsonObject.put("totalRecordsInImportFile", imp_stats.s_tot_rows);
    } else {
        jsonObject.put("totalRecordsInImportFile", "N/A");
    }

    if (imp_stats.s_bad_rows != null) {
        jsonObject.put("badRowsInImportFile", imp_stats.s_bad_rows);
    } else {
        jsonObject.put("badRowsInImportFile", "N/A");
    }

    if (imp_stats.s_warning_recips != null) {
        jsonObject.put("recordsThatGeneratedAWarningInProcess", imp_stats.s_warning_recips);
    } else {
        jsonObject.put("recordsThatGeneratedAWarningInProcess", "N/A");
    }

    if (imp_stats.s_bad_fingerprints != null) {
        jsonObject.put("unrecoverableFingerprintRecords", imp_stats.s_bad_fingerprints);
    } else {
        jsonObject.put("unrecoverableFingerprintRecords", "N/A");
    }

    if (imp_stats.s_bad_emails != null) {
        jsonObject.put("unrecoverableEmailRecords", imp_stats.s_bad_emails);
    } else {
        jsonObject.put("unrecoverableEmailRecords", "N/A");
    }

    if (imp_stats.s_file_dups != null) {
        jsonObject.put("duplicatesInTheImportFile", imp_stats.s_file_dups);
    } else {
        jsonObject.put("duplicatesInTheImportFile", "N/A");
    }

    if (imp_stats.s_tot_recips != null) {
        jsonObject.put("total", imp_stats.s_tot_recips);
    } else {
        jsonObject.put("total", "N/A");
    }

    if (imp_stats.s_dup_recips != null) {
        jsonObject.put("duplicatesInTheDB", imp_stats.s_dup_recips);
    } else {
        jsonObject.put("duplicatesInTheDB", "N/A");
    }

    if (imp_stats.s_num_committed != null) {
        jsonObject.put("committed", imp_stats.s_num_committed);
    } else {
        jsonObject.put("committed", "N/A");
    }

    if (imp_stats.s_left_to_commit != null) {
        jsonObject.put("leftToCommit", imp_stats.s_left_to_commit);
    } else {
        jsonObject.put("leftToCommit", "N/A");
    }

    if (imp_stats.s_error_message != null) {
        jsonObject.put("Error", imp_stats.s_error_message);
    }

    //html

    if ((nStatusID >= 30 && nStatusID < 70) || nStatusID == 7) //ImportStatus.IN_STAGING
    {
        String sImportURL = null;
        try {
            if ((imp.s_import_file == null) || (imp.s_import_file.trim().equals(""))) {
                String sErrMsg =
                        "import_detail.jsp ERROR: " +
                                "import_file is not specified. import_id = " + imp.s_import_id;
                throw new Exception();
            }

            // === === ===

            Vector services = Services.getByCust(ServiceType.RUPD_IMPORT_RESULT_FILE_VIEW, cust.s_cust_id);
            Service service = (Service) services.get(0);

            sImportURL = service.getURL().toString();
            sImportURL +=
                    "?cust_id=" + cust.s_cust_id +
                            "&import_id=" + imp.s_import_id +
                            "&file_type=preview" +
                            "&import_file=" + imp.s_import_file.trim();

            HttpURLConnection huc = null;
            try {
                URL url = new URL(sImportURL);
                huc = (HttpURLConnection) url.openConnection();
                huc.setDoOutput(false);
                huc.setDoInput(true);

                BufferedReader inRCP = new BufferedReader(new InputStreamReader(huc.getInputStream(), "UTF-8"));

                for (String sLine = inRCP.readLine(); sLine != null; sLine = inRCP.readLine()) {
                    out.print(sLine);
                    //jsonObject.put("sLine", sLine);
                }

                inRCP.close();

                if (huc.getResponseCode() != HttpServletResponse.SC_OK) {
                    throw new IOException("import_detail.jsp ERROR: " + huc.getResponseMessage());
                }
            } catch (Exception ex) {
                throw ex;
            } finally {
                if (huc != null) huc.disconnect();
            }
        } catch (Exception ex) {
            logger.error("import_details.jsp ERROR: cannot get data from url: " + sImportURL, ex);

        }
    }

    jsonArray.put(jsonObject);
    out.print(jsonArray);

%>
