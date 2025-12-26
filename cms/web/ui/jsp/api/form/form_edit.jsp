<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                java.text.DateFormat,
                java.sql.*,
                java.net.*,
                java.io.*,
                java.util.*,
                org.xml.sax.*,
                javax.xml.transform.*,
                javax.xml.transform.stream.*,
                org.w3c.dom.*,
                javax.xml.parsers.*,
                org.apache.log4j.Logger"
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

    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    JsonArray jsonArray = new JsonArray();
    JsonObject jsonObject = new JsonObject();

    String formID = request.getParameter("form_id");

    String strURL, sql;
    String nextForm = null, badRecipForm = null, noRecipForm = null;
    String formTypeId = "";
    String sbsFormID = "", formName = "", creator = "", createDate = "", modifier = "", modifyDate = "";
    String prefillFlag = "", prefillNoValidateFlag = "", highPriorityFlag = "", postValidateFlag = "";
    String confirmURL = "", formURL = "", updateIncompleteFlag = "", formSource = "";

    String sUnsubHierarchyId = null;
    String sUpdHierarchyId = null;
    String sUpdRuleId = null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        if (formID != null) {
            //Retrieve form info from form table
            sql =
                    " SELECT f.form_id, f.form_name, f.type_id, " +
                            " c1.user_name as creator, fei.create_date, " +
                            " c2.user_name as editor, fei.modify_date, " +
                            " prefill_flag, prefill_no_validate_flag, high_priority_flag, post_validate_flag, " +
                            " confirm_url, form_url, update_incomplete_flag, form_next_success, " +
                            " form_alt_prefill_bad_recip, form_alt_prefill_no_recip, form_source, " +
                            " unsub_hierarchy_id, upd_hierarchy_id, upd_rule_id" +
                            " FROM" +
                            "	csbs_form f," +
                            "	csbs_form_edit_info fei," +
                            "	ccps_user c1," +
                            "	ccps_user c2 " +
                            " WHERE" +
                            "	f.form_id = " + formID + " AND" +
                            "	f.cust_id = " + cust.s_cust_id + " AND" +
                            "	fei.form_id = f.form_id AND" +
                            "	fei.creator_id = c1.user_id AND" +
                            "	fei.modifier_id = c2.user_id";

            rs = stmt.executeQuery(sql);
            if (!rs.next()) {
                throw new Exception("Could not find form in cps database.");
            }
            sbsFormID = rs.getString(1);
            formName = rs.getString(2);
            formTypeId = rs.getString(3);
            creator = rs.getString(4);
            createDate = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(5));
            modifier = rs.getString(6);
            modifyDate = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(rs.getTimestamp(7));
            prefillFlag = rs.getString(8);
            prefillNoValidateFlag = rs.getString(9);
            highPriorityFlag = rs.getString(10);
            postValidateFlag = rs.getString(11);
            confirmURL = rs.getString(12);
            formURL = rs.getString(13);
            updateIncompleteFlag = rs.getString(14);
            nextForm = rs.getString(15);
            badRecipForm = rs.getString(16);
            noRecipForm = rs.getString(17);
            byte[] b = rs.getBytes(18);
            formSource = (b == null) ? null : new String(b, "UTF-8");

            sUnsubHierarchyId = rs.getString(19);
            sUpdHierarchyId = rs.getString(20);
            sUpdRuleId = rs.getString(21);
        } else {
            formName = "New Subscription Form";
        }
        jsonObject.put("sbsFormID", sbsFormID);
        jsonObject.put("formName", formName);
        jsonObject.put("formTypeId", formTypeId);
        jsonObject.put("creator", creator);
        jsonObject.put("createDate", createDate);
        jsonObject.put("modifier", modifier);
        jsonObject.put("modifyDate", modifyDate);
        jsonObject.put("prefillFlag", prefillFlag);
        jsonObject.put("prefillNoValidateFlag", prefillNoValidateFlag);
        jsonObject.put("highPriorityFlag", highPriorityFlag);
        jsonObject.put("postValidateFlag", postValidateFlag);
        jsonObject.put("confirmURL", confirmURL);
        jsonObject.put("formURL", formURL);
        jsonObject.put("updateIncompleteFlag", updateIncompleteFlag);
        jsonObject.put("nextForm", nextForm);
        jsonObject.put("badRecipForm", badRecipForm);
        jsonObject.put("noRecipForm", noRecipForm);
        jsonObject.put("formSource", formSource);
        jsonObject.put("sUnsubHierarchyId", sUnsubHierarchyId);
        jsonObject.put("sUpdHierarchyId", sUpdHierarchyId);
        jsonObject.put("sUpdRuleId", sUpdRuleId);

//---------- Generate type option list -----------------

        sql = "SELECT type_id, type_name FROM csbs_form_type";
        rs = stmt.executeQuery(sql);
        String htmlTypeOptionList = "";
        String tempTypeID = "";
        while (rs.next()) {
            tempTypeID = rs.getString(1);
            htmlTypeOptionList += "<option value=" + tempTypeID;
            if (formTypeId.equals(tempTypeID)) htmlTypeOptionList += " selected";
            htmlTypeOptionList += ">" + rs.getString(2) + "</option>\n";
        }
        jsonObject.put("tempTypeID", tempTypeID);
        jsonObject.put("htmlTypeOptionList", htmlTypeOptionList);

//---------- Generate customer form option list --------

        sql =
                " SELECT form_id, form_name" +
                        " FROM csbs_form" +
                        " WHERE cust_id = " + cust.s_cust_id +
                        " ORDER BY form_name";

        rs = stmt.executeQuery(sql);
        String htmlNextFormOptionList = "";
        String htmlBadRecipFormOptionList = "";
        String htmlNoRecipFormOptionList = "";
        String tempID = "", tempName = "";
        while (rs.next()) {
            tempID = rs.getString(1);

            tempName = rs.getString(2);
            htmlNextFormOptionList += "<option value=" + tempID;
            htmlBadRecipFormOptionList += "<option value=" + tempID;
            htmlNoRecipFormOptionList += "<option value=" + tempID;

            if (tempID.equals(nextForm)) htmlNextFormOptionList += " selected";
            if (tempID.equals(badRecipForm)) htmlBadRecipFormOptionList += " selected";
            if (tempID.equals(noRecipForm)) htmlNoRecipFormOptionList += " selected";

            htmlNextFormOptionList += ">" + tempName + "</option>\n";
            htmlBadRecipFormOptionList += ">" + tempName + "</option>\n";
            htmlNoRecipFormOptionList += ">" + tempName + "</option>\n";
        }
        jsonObject.put("tempID", tempID);
        jsonObject.put("tempName", tempName);
        jsonObject.put("htmlNextFormOptionList", htmlNextFormOptionList);
        jsonObject.put("htmlBadRecipFormOptionList", htmlBadRecipFormOptionList);
        jsonObject.put("htmlNoRecipFormOptionList", htmlNoRecipFormOptionList);

//--- Prepare list of dropdown boxes ---

        String htmlKeywords = "";

        String htmlPers = "";

        String sSql =
                " SELECT a.attr_name, ca.display_name " +
                        " FROM ccps_attribute a, ccps_cust_attr ca" +
                        " WHERE" +
                        " ca.cust_id = " + cust.s_cust_id + " AND" +
                        " a.attr_id = ca.attr_id AND" +
                        " display_seq IS NOT NULL " +
                        " ORDER BY display_seq";

        rs = stmt.executeQuery(sSql);
        while (rs.next()) {
            htmlPers += "<option value=" + rs.getString(1) + ">" + rs.getString(2) + "</option>\n";
        }
        jsonObject.put("htmlKeywords", htmlKeywords);
        jsonObject.put("htmlPers", htmlPers);

        jsonArray.put(jsonObject);
        out.print(jsonArray);

    } catch (Exception ex) {
        throw ex;
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }
%>