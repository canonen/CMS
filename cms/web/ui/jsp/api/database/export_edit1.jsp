<%@ page
        language="java"
        import="com.britemoon.*,
            com.britemoon.cps.*,
            com.britemoon.cps.exp.*,
            com.britemoon.cps.ctl.*,
            com.britemoon.cps.tgt.Filter,
            java.sql.*,
            java.util.*,
            java.io.*,
            java.net.*,
            org.w3c.dom.*,
            org.apache.log4j.*"
%>
<%@ page import="com.restfb.json.*" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ include file="../fixTurkishCharacters.jsp" %>

<%!
    static Logger logger = Logger.getLogger("ExportEdit");
    String getParam(HttpServletRequest request, String name, String defaultValue) {
        String val = request.getParameter(name);
        return val != null ? val : defaultValue;
    }
%>
<%
    if (!user.getAccessPermission(ObjectType.EXPORT).bWrite) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    String sfile_id = request.getParameter("file_id");
    String sSelectedCategoryId = getParam(request, "category_id", ui.s_category_id);
    if (!user.s_cust_id.equals(cust.s_cust_id)) sSelectedCategoryId = null;

    String expName = null, expDelimiter = null, sAttribList = null, sParamId = null, sLinkId = "";
    String sSelectedLinkId = null, sAction = null, sRecipOption = null, sParams = null, sExpParamId = "";
    String sFileUrl = null, sTotalRecip = null, ExpDescrip = "";
    int iStatusId = 0;

    boolean isCamp = false, isClick = false, isTgt = false, isBatch = false, isBounce = false, isUnsub = false;

    JsonObject data = new JsonObject();
    JsonArray chooseAreaArray = new JsonArray();
    JsonObject dataObjectJson = new JsonObject();

    if (sfile_id != null) {
        Export exp = new Export(sfile_id);
        expName = exp.s_export_name;
        expDelimiter = exp.s_delimiter;
        sAttribList = exp.s_attr_list;
        sAction = exp.s_action;
        sParams = exp.s_params;
        sFileUrl = exp.s_file_url;
        if (exp.s_status_id != null && !exp.s_status_id.trim().isEmpty()) {
            iStatusId = Integer.parseInt(exp.s_status_id.trim());
        } else {
            iStatusId = 0; // veya sistemine uygun default bir değer
        }

        ExportParam eps = new ExportParam(sfile_id);
        sRecipOption = eps.s_param_name;
        sParamId = eps.s_param_value;

        // sExpParamId belirleme
        if ("camp_id".equals(sRecipOption)) {
            sExpParamId = (sParams != null && sParams.indexOf("link_id") > -1) ? "2" : "1";
        } else if (sAction != null && sAction.indexOf("Tgt") == 0) {
            sExpParamId = "3";
            if (sParamId != null) {
                Filter filter = new Filter(sParamId);
                ExpDescrip = "Export of " + filter.s_filter_name;
                dataObjectJson.put("ExpDescrip", ExpDescrip);
            }
        }
        dataObjectJson.put("sExpParamId", sExpParamId);

        // isCamp, isClick, isTgt, ... bayraklarını ayarla
        isCamp = "camp_id".equals(sRecipOption);
        isClick = "2".equals(sExpParamId);
        isTgt = "ExpTgt".equals(sAction);
        isBatch = "ExpBatch".equals(sAction);
        isBounce = "ExpBBack".equals(sAction);
        isUnsub = "ExpUnsub".equals(sAction);

        dataObjectJson.put("isCamp", isCamp);
        dataObjectJson.put("isClick", isClick);
        dataObjectJson.put("isTgt", isTgt);
        dataObjectJson.put("isBatch", isBatch);
        dataObjectJson.put("isBounce", isBounce);
        dataObjectJson.put("isUnsub", isUnsub);

        // Total Recipients bul
        if (sFileUrl != null) {
            BufferedReader reader = null;
            try {
                reader = new BufferedReader(new InputStreamReader(new URL(sFileUrl).openStream()));
                String line = null;
                while ((line = reader.readLine()) != null) {
                    if (line.indexOf("Total Recipients") > -1) {
                        sTotalRecip = line.substring(line.indexOf(":") + 1).trim();
                        dataObjectJson.put("sTotalRecip", sTotalRecip);
                        break;
                    }
                }
            } catch (IOException ex) {
                logger.error("File parse error: ", ex);
            } finally {
                if (reader != null) try { reader.close(); } catch (IOException ignore) {}
            }
        }

        // Diğer bilgileri ekle
        if (expDelimiter != null) dataObjectJson.put("expDelimiter", expDelimiter);
        if (expName != null) dataObjectJson.put("exportName", fixTurkishCharacters(expName));
        dataObjectJson.put("sFileID", sfile_id);

        // Kategori seçimi
        dataObjectJson.put("sSelectedCategoryId", sSelectedCategoryId != null ? sSelectedCategoryId : "");
        dataObjectJson.put("sAction", sAction);

        // which1 kodu (alan ön seçimi)
        if (sAction != null) {
            if (sAction.indexOf("Sent") > -1) dataObjectJson.put("which1", 1);
            else if (sAction.indexOf("Read") > -1) dataObjectJson.put("which1", 2);
            else if (sAction.indexOf("BBack") > -1) dataObjectJson.put("which1", 3);
            else if (sAction.indexOf("Unsub") > -1) dataObjectJson.put("which1", 4);
            else if (sAction.indexOf("Click") > -1) dataObjectJson.put("which1", 5);
        }
    }

    chooseAreaArray.put(dataObjectJson);
    data.put("ChooseArea", chooseAreaArray);

    // Final JSON çıktısı
    JsonArray fin_array = new JsonArray();
    fin_array.put(data);
    out.print(fin_array);
%>