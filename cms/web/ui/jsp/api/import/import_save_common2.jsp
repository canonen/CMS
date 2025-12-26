<%
    Import imp = new Import();

    if (in == null) {
        throw new IllegalArgumentException("Input stream is null");
    }

    if (cust.s_cust_id == null || cust.s_cust_id.trim().isEmpty()) {
        throw new IllegalArgumentException("Customer ID is null or empty");
    }
    String sImportName = (String) request.getAttribute("sImportName");
    String sBatchId = (String) request.getAttribute("sBatchId");
    String sFieldSeparator = (String) request.getAttribute("sFieldSeparator");
    String sFirstRow = (String) request.getAttribute("sFirstRow");
    String sImportFile = (String) request.getAttribute("sImportFile");
    String sUpdRuleId = (String) request.getAttribute("sUpdRuleId");
    String sFullNameFlag = (String) request.getAttribute("sFullNameFlag");
    String sEmailTypeFlag = (String) request.getAttribute("sEmailTypeFlag");
    String sUpdHierarchyId = (String) request.getAttribute("sUpdHierarchyId");
    String sMultiValueFieldSeparator = (String) request.getAttribute("sMultiValueFieldSeparator");
    String sBatchName = (String) request.getAttribute("sBatchName");
    String sBatchTypeId = (String) request.getAttribute("sBatchTypeId");
    String sNewsletters = (String) request.getAttribute("sNewsletters");
    String sCategories = (String) request.getAttribute("sCategories");
    String sSelectedCategoryId = (String) request.getAttribute("sSelectedCategoryId");
    FieldsMappings fmFieldsMappings = (FieldsMappings) request.getAttribute("fmFieldsMappings");
    if (aImportParameters == null) {
        logger.error("aImportParameters is null");
        throw new IllegalArgumentException("Import parameters are not initialized.");
    }

    if (sImportName == null) {
        logger.error("Import name is null");
        throw new IllegalArgumentException("Import name is required.");
    }
    sImportName = sImportName.trim();



    if (!aImportParameters.containsKey("server_file_name")) {
        logger.error("server_file_name not found in import parameters.");
        throw new IllegalArgumentException("server_file_name not found in import parameters.");
    }

    if ("null".equals(sMultiValueFieldSeparator) || "".equals(sMultiValueFieldSeparator)) {
        sMultiValueFieldSeparator = null;
    }

    sNewsletters = sNewsletters.equals("null") ? "" : sNewsletters;



    imp.s_import_id = null;
    imp.s_import_name = sImportName; //
    imp.s_batch_id = sBatchId; //

    imp.s_status_id = String.valueOf(ImportStatus.DOWNLOADED);
    imp.s_import_date = null;

    if (sFieldSeparator.equals("tab")) {
        sFieldSeparator = "\\t";
    } else if (sFieldSeparator.equals("pipe")) {
        sFieldSeparator = "|";
    } else if (sFieldSeparator.equals("semicolon")) {
        sFieldSeparator = ";";
    } else if (sFieldSeparator.equals("comma")) {
        sFieldSeparator = ",";
    }
    imp.s_field_separator = sFieldSeparator;
    imp.s_first_row = sFirstRow;
    imp.s_import_file = sImportFile;
    imp.s_upd_rule_id = sUpdRuleId;
    imp.s_import_url = Registry.getKey("import_url_dir");
    imp.s_full_name_flag = sFullNameFlag;
    imp.s_email_type_flag = sEmailTypeFlag;
    imp.s_type_id = null;
    imp.s_upd_hierarchy_id = sUpdHierarchyId;
    imp.s_auto_commit_flag = null;
    imp.s_multi_value_field_separator = sMultiValueFieldSeparator;

    if (imp.s_batch_id == null) {
        Batch batch = new Batch();
        batch.s_batch_id = null;
        batch.s_batch_name = sBatchName;
        batch.s_cust_id = cust.s_cust_id;
        batch.s_type_id = sBatchTypeId;
        batch.s_descrip = null;

        imp.m_Batch = batch;
    }

    imp.m_FieldsMappings = fmFieldsMappings;

    String sFld = null;
    int nBegin = 0;
    int nEnd = 0;
    if (sNewsletters != null && sNewsletters.length() > 0) {
        ImportNewsletters inls = new ImportNewsletters();
        while (true) {
            nEnd = sNewsletters.indexOf(",", nBegin);

            if (nEnd == -1) {
                sFld = sNewsletters.substring(nBegin);
            } else {
                sFld = sNewsletters.substring(nBegin, nEnd);
            }

            sFld = sFld.trim();
            if ("".equals(sFld)) break;

            ImportNewsletter inl = new ImportNewsletter();
            inl.s_attr_id = sFld;
            inls.add(inl);

            if (nEnd == -1) break;
            nBegin = nEnd + 1;
        }

        imp.m_ImportNewsletters = inls;
    }

    try {
        imp.save();
        ImportUtil.setupRCP(imp.s_import_id);
    } catch (Exception ex) {
        if (imp.s_import_id != null) {
            String sSql = "UPDATE cupd_import SET status_id = " + ImportStatus.ERROR + " WHERE import_id = " + imp.s_import_id;
            BriteUpdate.executeUpdate(sSql);
        }
        throw ex;
    }

    saveCategories(cust.s_cust_id, imp.s_import_id, sCategories); // sCategories tanımlı olmalı

%>

<%!
    private static void saveCategories(String sCustId, String sImportId, String sCategories) {
        if (sCategories == null || sCategories.trim().equals("")) return;

        String[] sCatsArray = sCategories.split(",");
        if (sCatsArray.length <= 0) return;

        ConnectionPool cp = null;
        Connection conn = null;

        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("import_save.jsp");

            String sSql = "INSERT INTO ccps_object_category (cust_id, object_id, type_id, category_id) VALUES (?, ?, ?, ?)";
            PreparedStatement pstmt = null;

            for (String sCategory : sCatsArray) {
                try {
                    pstmt = conn.prepareStatement(sSql);
                    pstmt.setString(1, sCustId);
                    pstmt.setString(2, sImportId);
                    pstmt.setString(3, String.valueOf(ObjectType.IMPORT));
                    pstmt.setString(4, sCategory.trim());
                    pstmt.executeUpdate();
                } catch (Exception exx) {
                    throw exx; // Hata atılıyor
                } finally {
                    if (pstmt != null) pstmt.close();
                }
            }
        } catch (Exception ex) {
            logger.error("Exception", ex);
        } finally {
            if (conn != null) cp.free(conn);
        }
    }
%>
