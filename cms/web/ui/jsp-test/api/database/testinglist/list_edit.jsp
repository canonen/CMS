<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../../header.jsp" %>
<%@ include file="../../../utilities/validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    String listID = request.getParameter("listID");
    if (!can.bWrite && listID == null) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

// === === ===

    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    String sSql = null;
    JsonObject data = new JsonObject();
    JsonArray listArray = new JsonArray();
    JsonArray listEdit = new JsonArray();
    JsonObject listTypeData = new JsonObject();

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        int maxSize = 40;
        int listSize = 0;
        String listTypeID = "2", listType = "QA Test";
        String listName = "";
        String listStatusID = String.valueOf(EmailListStatus.ACTIVE);

        if (listID == null) {
            listName = "New list";
            listTypeID = request.getParameter("typeID");

            if (listTypeID == null) listTypeID = "2";
        } else {
            sSql =
                    " SELECT list_name, type_id, status_id" +
                            " FROM cque_email_list" +
                            " WHERE cust_id = " + cust.s_cust_id +
                            " AND list_id = " + listID;

            rs = stmt.executeQuery(sSql);
            if (rs.next()) {
                data = new JsonObject();
                listName = new String(rs.getBytes(1), "UTF-8");
                listTypeID = rs.getString(2);
                listStatusID = rs.getString(3);

                data.put("listName",listName);
                data.put("listTypeID",listTypeID);
                data.put("listStatusID",listStatusID);
                listArray.put(data);
            }
            listEdit.put(listArray);
            rs.close();

            // === === ===

            listArray = new JsonArray();
            sSql =
                    " SELECT count(*) FROM cque_email_list_item" +
                            " WHERE list_id = " + listID;

            rs = stmt.executeQuery(sSql);
            if (rs.next()) {

                listSize = rs.getInt(1);
                data.put("listSize",listSize);
                listArray.put(data);
            }
            listEdit.put(listArray);

            rs.close();
        }

        boolean isDisabled = ((listSize > maxSize) && (("1".equals(listTypeID)) || ("3".equals(listTypeID))));

        String sFingerSeq = "";
        if (listTypeID.equals("1")) {
            listType = "Global Exclusion";
            listTypeData.put("listType",listType);
        }
        else if (listTypeID.equals("3")){
            listType = "Exclusion";
            listTypeData.put("listType",listType);
        }
        else if (listTypeID.equals("4") || listTypeID.equals("6")){
            listType = "Auto-Respond Notification";
            listTypeData.put("listType",listType);
        }
        else if (listTypeID.equals("5")) {
            listType = "Specified Test Recipient";
            listTypeData.put("listType",listType);

           listArray = new JsonArray();
            sSql =
                    " SELECT isnull(ca.display_name,a.attr_name)" +
                            " FROM ccps_attribute a, ccps_cust_attr ca" +
                            " WHERE ca.cust_id = " + cust.s_cust_id +
                            " AND ca.fingerprint_seq IS NOT NULL" +
                            " AND a.attr_id = ca.attr_id" +
                            " ORDER BY ca.fingerprint_seq";

            rs = stmt.executeQuery(sSql);
            while (rs.next()){
                data = new JsonObject();

                sFingerSeq += ((sFingerSeq.length() > 0) ? " + " : "") + rs.getString(1);

                data.put("sFingerSeq",sFingerSeq);

                listArray.put(data);
            }
            listEdit.put(listArray);

            rs.close();
        } else if (listTypeID.equals("7")) {
            listType = "Dynamic Content";
            listTypeData.put("listType",listType);
        }

        int i = -1;
        int x = 0;

        sSql = "EXEC usp_cque_email_list_get " + listID;
        rs = stmt.executeQuery(sSql);

        String rowEmail = "";
        int icountHTML = 0;
        int icountText = 0;
        int icountMulti = 0;
        int icountAOL = 0;
        int imaxCount = 0;

        byte[] b = null;
        listArray = new JsonArray();
        while (rs.next()) {
            data = new JsonObject();

            b = rs.getBytes(2);
            rowEmail = ((b == null) ? null : new String(b, "UTF-8"));

            icountHTML = rs.getInt(3);
            icountText = rs.getInt(4);
            icountMulti = rs.getInt(5);
            icountAOL = rs.getInt(6);

            imaxCount = icountHTML;

            if (icountText > imaxCount){
                imaxCount = icountText;
                data.put("imaxCount",imaxCount);
            }
            if (icountMulti > imaxCount){
                imaxCount = icountMulti;
                data.put("imaxCount",imaxCount);
            }
            if (icountAOL > imaxCount){
                imaxCount = icountAOL;
                data.put("imaxCount",imaxCount);
            }

            data.put("b",b);
            data.put("rowEmail",rowEmail);
            data.put("icountHTML",icountHTML);
            data.put("icountText",icountText);
            data.put("icountMulti",icountMulti);
            data.put("icountAOL",icountAOL);
            data.put("imaxCount",imaxCount);

            listArray.put(data);


        }

        rs.close();
        listArray.put(listTypeData);
        listEdit.put(listArray);

        out.print(listEdit.toString());

    } catch (Exception ex) {
        ErrLog.put(this, ex, "list_edit.jsp", out, 1);
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }
%>
