<%@ page

        language="java"
        import="com.britemoon.cps.imc.*,
                com.britemoon.cps.*,
                com.britemoon.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                org.w3c.dom.*,
                org.apache.log4j.*"
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
    AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT);

    if (!can.bWrite) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }


    JsonObject data = new JsonObject();
    JsonArray array = new JsonArray();

    // Connection
    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool connectionPool = null;
    Connection srvConnection = null;


    String sRequestXML = "";
    String sListXML = "";

    int i = 0;
    int numRecips = 10;

    String sEnableFlag = Registry.getKey("recip_edit_enable_flag");


    try {
        String sSelectedCategoryId = request.getParameter("category_id");
        if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
            sSelectedCategoryId = ui.s_category_id;

        if (!sEnableFlag.equals("0")) {
            connectionPool = ConnectionPool.getInstance();
            srvConnection = connectionPool.getConnection("manual_import.jsp");
            stmt = srvConnection.createStatement();

            boolean nonEmailFinger = false;
            rs = stmt.executeQuery("SELECT attr_name FROM ccps_attribute a, ccps_cust_attr c " +
                    "WHERE c.cust_id = " + cust.s_cust_id + " AND a.attr_id = c.attr_id " +
                    "AND fingerprint_seq IS NOT NULL");
            while (rs.next()) {
                if (!rs.getString(1).equals("email_821")) {
                    nonEmailFinger = true;
                    data.put("email_821", rs.getString(1));
                    array.put(data);
                    break;
                }
            }
            rs.close();
            out.println(array);
            if (!nonEmailFinger) {
                String[] sEmailType = new String[50];
                int[] iEmailTypeId = new int[50];
                int nEmailType = 0;


                rs = stmt.executeQuery("SELECT email_type_id, email_type_name FROM ccps_email_type WHERE email_type_id > 0");
                while (rs.next()) {
                    data = new JsonObject();
//                    iEmailTypeId[nEmailType] = rs.getInt(1);
//                    sEmailType[nEmailType] = rs.getString(2);
//                    nEmailType++;
                    data.put("iEmailTypeId", rs.getInt(1));
                    data.put("sEmailType", rs.getString(2));
                    array.put(data);
                }

                rs.close();
                out.println(array);

                if ((sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0"))) {
                    rs = stmt.executeQuery("SELECT DISTINCT b.batch_id, b.batch_name, b.type_id" +
                            " FROM cupd_batch b, cupd_import i " +
                            " WHERE ((b.type_id = 1" +
                            " AND b.batch_id IN (SELECT DISTINCT i.batch_id FROM cupd_import i, cupd_batch b" +
                            " WHERE i.status_id = " + UpdateStatus.COMMIT_COMPLETE +
                            " AND i.batch_id = b.batch_id AND b.cust_id = " + cust.s_cust_id + "))" +
                            " OR b.type_id = 2)" +
                            " AND b.cust_id = " + cust.s_cust_id +
                            " ORDER BY b.type_id DESC, b.batch_id DESC");
                } else {
                    rs = stmt.executeQuery("SELECT DISTINCT b.batch_id, b.batch_name, b.type_id" +
                            " FROM cupd_batch b, cupd_import i " +
                            " WHERE ((b.type_id = 1" +
                            " AND b.batch_id IN (SELECT DISTINCT i.batch_id" +
                            " FROM cupd_import i, cupd_batch b, ccps_object_category oc" +
                            " WHERE i.status_id = " + UpdateStatus.COMMIT_COMPLETE +
                            " AND i.batch_id = b.batch_id" +
                            " AND b.cust_id = " + cust.s_cust_id +
                            " AND oc.object_id = i.import_id" +
                            " AND oc.type_id = " + ObjectType.IMPORT +
                            " AND oc.cust_id = " + cust.s_cust_id +
                            " AND oc.category_id = " + sSelectedCategoryId + "))" +
                            " OR b.type_id = 2)" +
                            " AND b.cust_id = " + cust.s_cust_id +
                            " ORDER BY b.type_id DESC, b.batch_id DESC");
                }
                int batchID;
                String batchid = request.getParameter("batch_id");
                data = new JsonObject();
                while (rs.next()) {
                    String deg = rs.getInt(1) + "";
                    if (batchid.equals(deg)) {
                        data.put("if", rs.getString(1));
                        data.put("if2", rs.getString(2));
                    } else {
                        data.put("else", rs.getString(1));
                        data.put("else2", rs.getString(2));


                    }
                    array.put(data);
                }
                rs.close();
            }
            out.println(array);
        }
    } catch (Exception ex) {

        ErrLog.put(this, ex, "Problem with Manual Import list.", out, 1);

    } finally {
        if (stmt != null) stmt.close();
        if (srvConnection != null) connectionPool.free(srvConnection);
    }
%>
