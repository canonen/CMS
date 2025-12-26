<%@ page
    import="com.britemoon.*, com.britemoon.cps.*, com.britemoon.cps.ctm.*"
    import="java.sql.*, java.io.*"
    import="javax.servlet.*, javax.servlet.http.*"
    import="org.apache.log4j.*"
    import="com.restfb.json.JsonObject"
    contentType="application/json;charset=UTF-8"
%><%@ page import="com.restfb.json.JsonArray"%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<%!
    static Logger logger = Logger.getLogger("cont_block_edit_json");
%>

<%
response.setContentType("application/json");
AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
if (!can.bRead) {
    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Read permission denied.");
    return;
}

String contID = request.getParameter("cont_id");
if (!can.bWrite && contID == null) {
    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Write permission denied.");
    return;
}
String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;
JsonObject json = new JsonObject();

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement preStm = null;
PreparedStatement preStmPersonalize = null;
PreparedStatement preStmStatus = null;
PreparedStatement preStmCharset = null;
PreparedStatement preStmCategory = null;



ResultSet rsCont = null;
ResultSet rsPersonalize = null;
ResultSet rsStatus = null;
ResultSet rsCharset = null;
ResultSet rsCategory = null;





try {
    cp = ConnectionPool.getInstance();
    conn = cp.getConnection(this);

    // --- Content Info ---
    if (contID != null) {
        String sql = "EXEC dbo.usp_ccnt_info_get " + contID;
        preStm = conn.prepareStatement(sql);
        rsCont = preStm.executeQuery();
        if (rsCont.next()) {
            json.put("contName", new String(rsCont.getBytes("Name"), "UTF-8"));
            json.put("contStatus", rsCont.getString("Status"));
            json.put("sendType", rsCont.getString("SendType"));
            json.put("contHTML", new String(rsCont.getBytes("HTML"), "UTF-8"));
            json.put("contText", new String(rsCont.getBytes("Text"), "UTF-8"));
            json.put("contAOL", new String(rsCont.getBytes("AOL"), "UTF-8"));
            json.put("creator", rsCont.getString("creator"));
            json.put("creationDate", rsCont.getString("create_date"));
            json.put("editor", rsCont.getString("modifier"));
            json.put("modifyDate", rsCont.getString("modify_date"));
        }
    } else {
        json.put("contName", "new_cont_block");
    }


    String sqlPersonalize ="SELECT c.attr_id, a.attr_name, c.display_name FROM ccps_cust_attr c, ccps_attribute a WHERE c.cust_id = ? AND c.display_seq IS NOT NULL AND c.attr_id = a.attr_id ORDER BY display_seq";
    preStmPersonalize = conn.prepareStatement(sqlPersonalize);
    preStmPersonalize.setString(1, cust.s_cust_id);
    rsPersonalize = preStmPersonalize.executeQuery();

    JsonArray personalizations = new JsonArray();


    while (rsPersonalize.next()) {
        JsonObject jsonPersonalize = new JsonObject();
        String attrID = rsPersonalize.getString(1);
        String attrName = rsPersonalize.getString(2);
        String attrDisplayName = new String(rsPersonalize.getBytes(3), "UTF-8");

        jsonPersonalize.put("attrID", attrID);
        jsonPersonalize.put("attrName", attrName);
        jsonPersonalize.put("attrDisplayName", attrDisplayName);

        personalizations.put(jsonPersonalize);
    }
    rsPersonalize.close();
    preStmPersonalize.close();
    json.put("personalizations", personalizations);

    String sqlStatus ="SELECT status_id, status_name FROM ccnt_cont_status WHERE status_id NOT IN (15, 25)";
    preStmStatus = conn.prepareStatement(sqlStatus);
    rsStatus = preStmStatus.executeQuery();
    JsonArray status = new JsonArray();
    while (rsStatus.next()) {
        JsonObject jsonStatus = new JsonObject();
        jsonStatus.put("status_id", rsStatus.getString(1));
        jsonStatus.put("status_name", rsStatus.getString(2));
        status.put(jsonStatus);
    }
    rsStatus.close();
    preStmStatus.close();
    json.put("statuses", status);

    String sqlCharset = "SELECT charset_id, display_name FROM ccnt_charset";
    preStmCharset = conn.prepareStatement(sqlCharset);
    rsCharset = preStmCharset.executeQuery();
    JsonArray charsets = new JsonArray();
    while (rsCharset.next()) {
        JsonObject jsonCharset = new JsonObject();
        jsonCharset.put("charset_id", rsCharset.getString(1));
        jsonCharset.put("display_name", rsCharset.getString(2));
        charsets.put(jsonCharset);
    }
    rsCharset.close();
    preStmCharset.close();
    json.put("charsets", charsets);


    String sSql = "SELECT c.category_id, c.category_name, oc.object_id FROM ccps_category c LEFT OUTER JOIN ccps_object_category oc ON (c.category_id = oc.category_id AND c.cust_id = oc.cust_id AND oc.object_id = ? AND oc.type_id = ?) WHERE c.cust_id = ?";
    preStmCategory = conn.prepareStatement(sSql);
    preStmCategory.setString(1, contID);
    preStmCategory.setInt(2, ObjectType.CONTENT);
    preStmCategory.setString(3, cust.s_cust_id);
    rsCategory = preStmCategory.executeQuery();
    JsonArray categories = new JsonArray();
    while (rsCategory.next()) {
        JsonObject cat = new JsonObject();
        cat.put("category_id", rsCategory.getString(1));
        cat.put("category_name", new String(rsCategory.getBytes(2), "UTF-8"));
        boolean isSelected = (rsCategory.getString(3) != null || (sSelectedCategoryId != null && sSelectedCategoryId.equals(rsCategory.getString(1))));
        cat.put("is_selected", isSelected);
        categories.put(cat);
    }
    rsCategory.close();
    preStmCategory.close();
    json.put("categories", categories);

    out.print(json.toString());

} catch (Exception ex) {
    logger.error("Error in cont_block_edit.jsp", ex);
    json = new JsonObject();
    json.put("message", ex.toString());
} finally {
    if (rsCont != null)  rsCont.close();
    if (preStm != null)  preStm.close();
    if (conn != null) cp.free(conn);
}


%>
