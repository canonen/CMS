<%@ page
    import="com.britemoon.*"
    import="com.britemoon.cps.*"
    import="java.sql.*"
    import="java.util.*"
    import="org.apache.log4j.*"
    import="com.restfb.json.JsonObject"
    import="com.restfb.json.JsonArray"
    contentType="application/json;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>

<%!
    static Logger logger = Logger.getLogger("LogicBlockEditLogger");
%>

<%
response.setContentType("application/json");

if(logger == null) {
    logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if(!can.bRead) {
    response.sendRedirect("../access_denied.jsp");
    return;
}
String logicID = request.getParameter("logic_id");
if (!can.bWrite && logicID == null) {
    response.sendRedirect("../access_denied.jsp");
    return;
}
String parentContID = request.getParameter("parent_cont_id");

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

ui.setSessionProperty("dynamic_elements_section", "1");

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
    sSelectedCategoryId = ui.s_category_id;

JsonObject resultJson = new JsonObject();
JsonArray resultArray = new JsonArray();


JsonObject resultJson1 = new JsonObject();
JsonArray resultArray1 = new JsonArray();

JsonObject resultJson2 = new JsonObject();
JsonArray resultArray2 = new JsonArray();

JsonObject resultJson3 = new JsonObject();
JsonArray resultArray3 = new JsonArray();

JsonObject resultJson4 = new JsonObject();
JsonArray resultArray4 = new JsonArray();

ConnectionPool cp = null;
Connection conn = null;

PreparedStatement pslogic = null;
ResultSet rslogic = null;
PreparedStatement psextra = null;
ResultSet rsextra = null;

PreparedStatement psElement = null;
ResultSet rsElement = null;

PreparedStatement preStmCategory = null;
ResultSet rsCategory = null;

try {
    cp = ConnectionPool.getInstance();
    conn = cp.getConnection(this);

    // Logic info
    String sql1 = "SELECT c.cont_name, u1.user_name, ISNULL(CONVERT(varchar(255), ei.create_date, 100), ''), " +
                  "u2.user_name, ISNULL(CONVERT(varchar(255), ei.modify_date, 100), '') " +
                  "FROM ccnt_content c, ccnt_cont_edit_info ei, ccps_user u1, ccps_user u2 " +
                  "WHERE u1.user_id = ei.creator_id AND u2.user_id = ei.modifier_id " +
                  "AND c.cont_id = ei.cont_id AND c.cont_id = ?";
    pslogic = conn.prepareStatement(sql1);
    pslogic.setString(1, logicID);
    rslogic = pslogic.executeQuery();

    if(rslogic.next()) {
        JsonObject json = new JsonObject();
        json.put("logic_name", rslogic.getString(1));
        json.put("creator", rslogic.getString(2));
        json.put("creation_date", rslogic.getString(3));
        json.put("editor", rslogic.getString(4));
        json.put("modify_date", rslogic.getString(5));

        resultArray1.put(json);
        resultJson1.put("logic_info", resultArray1);
    }else{
        resultJson1.put("logic_info", new JsonArray());
    }
    rslogic.close();
    pslogic.close();

    resultArray.put(resultJson1);

    // Logic blocks
    String sql2 = "SELECT c.cont_id, c.cont_name, l.seq, l.filter_id, l.default_flag, " +
                  "l.max_elements_in_logic_block, f.filter_name " +
                  "FROM ccnt_cont_part l " +
                  "INNER JOIN ccnt_content c ON l.child_cont_id = c.cont_id " +
                  "LEFT OUTER JOIN ctgt_filter f ON l.filter_id = f.filter_id " +
                  "WHERE l.parent_cont_id = ? ORDER BY l.seq";

    psElement = conn.prepareStatement(sql2);
    psElement.setInt(1, Integer.valueOf(logicID));
    rsElement = psElement.executeQuery();

    while (rsElement.next()) {
        JsonObject json = new JsonObject();
        json.put("child_cont_id", rsElement.getString(1));
        json.put("child_cont_name", rsElement.getString(2));
        json.put("seq", rsElement.getInt(3));
        json.put("filter_id", rsElement.getString(4));
        json.put("default_flag", rsElement.getString(5));
        json.put("max_elements_in_logic_block", rsElement.getString(6));
        json.put("filter_name", rsElement.getString(7));

        resultArray2.put(json);
        resultJson2.put("logic_block_details", resultArray2);
    }
    rsElement.close();
    psElement.close();

    resultArray.put(resultJson2);

    String sqlExtra = "SELECT cont_name FROM ccnt_content WHERE origin_cont_id = ?";
    psextra = conn.prepareStatement(sqlExtra);
    psextra.setInt(1, Integer.valueOf(logicID));
    rsextra = psextra.executeQuery();

    while (rsextra.next()){
        JsonObject json = new JsonObject();
        json.put("extra_content_names", rsextra.getString("cont_name"));
        resultArray3.put(json);
        resultJson3.put("extra_content_names", resultArray3);
    }

    resultArray.put(resultJson3);


    // Categories
    String sSql = "SELECT c.category_id, c.category_name, oc.object_id " +
                  "FROM ccps_category c " +
                  "LEFT OUTER JOIN ccps_object_category oc " +
                  "ON (c.category_id = oc.category_id AND c.cust_id = oc.cust_id AND oc.object_id = ? AND oc.type_id = ?) " +
                  "WHERE c.cust_id = ?";
    preStmCategory = conn.prepareStatement(sSql);
    preStmCategory.setString(1, parentContID);
    preStmCategory.setInt(2, ObjectType.CONTENT);
    preStmCategory.setString(3, cust.s_cust_id);
    rsCategory = preStmCategory.executeQuery();

    JsonArray categories = new JsonArray();
    while (rsCategory.next()) {
        JsonObject json = new JsonObject();
        json.put("category_id", rsCategory.getString(1));
        json.put("category_name", new String(rsCategory.getBytes(2), "UTF-8"));
        boolean isSelected = (rsCategory.getString(3) != null || (sSelectedCategoryId != null && sSelectedCategoryId.equals(rsCategory.getString(1))));
        json.put("is_selected", isSelected);

        resultArray4.put(json);
        resultJson4.put("categories", resultArray4);
    }

    resultArray.put(resultJson4);
    resultJson.put("data", resultArray);

    rsCategory.close();
    preStmCategory.close();


} catch (Exception e) {
    logger.error("Error in logic_block_edit.jsp", e);
    resultJson.put("error", "Error retrieving logic block details: " + e.getMessage());
    return;
} finally {
    out.print(resultJson);
     if(rslogic != null) rslogic.close();
     if(pslogic != null) pslogic.close();
     if(rsElement != null) rsElement.close();
     if(rsextra != null) rsextra.close();
     if(psextra != null) psextra.close();
     if(psElement != null) psElement.close();
     if(rsCategory != null) rsCategory.close();
     if(preStmCategory != null) preStmCategory.close();
     if(conn != null) cp.free(conn); 
}

%>
