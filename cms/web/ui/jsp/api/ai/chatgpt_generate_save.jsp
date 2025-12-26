<%@ page
        language="java"
        import="com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                com.britemoon.*,
                javax.xml.parsers.*,
                java.util.*,
                java.sql.*,
                java.net.*,
                java.io.*,
                java.lang.Math.*,
                org.w3c.dom.*,
                org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.net.*, java.util.*" %>
<%@ page import="javax.ws.rs.core.HttpHeaders" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="org.json.JSONException" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ include file="chatgpt_generate_lib.jsp" %>

<%!
    static Logger logger = Logger.getLogger("cont_block_edit_json");
%>

<%
    response.setContentType("application/json");
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.FILTER);
    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    String campId = request.getParameter("campId");
    String aiRequestContentId = request.getParameter("aiRequestContentId");
    String aiRequestSucjectId = request.getParameter("aiRequestSubjectId");

    ConnectionPool cp = null;
    Connection conn = null;
    ResultSet rsLogs = null;
    PreparedStatement preStm = null;
    PreparedStatement preStmlogs = null;
    String sSql = null;
    int requestId = 0;
    boolean isContentRequest = false;
    boolean isSubjectRequest = false;
    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        if (conn == null) {
            throw new RuntimeException("Connection to database could not be established.");
        }

        if (aiRequestContentId != null && !aiRequestContentId.isEmpty()) {
            sSql = "update ccnt_email_content_requests set campaign_id = ? where id = ?;";
            preStm = conn.prepareStatement(sSql);

            preStm.setString(1, campId);
            preStm.setString(2, aiRequestContentId);

            int affectedRowsForContent = preStm.executeUpdate();
            if (affectedRowsForContent < 0) {
                throw new RuntimeException("ccnt_email_content_requests tablosunda Request ID bulunamadı.");
            }
            isContentRequest= true;
        }

        if (aiRequestSucjectId != null && !aiRequestSucjectId.isEmpty()) {
            sSql = "update cms_subject_line_requests set campaign_id = ? where request_id = ?;";
            preStm = conn.prepareStatement(sSql);

            preStm.setString(1, campId);
            preStm.setString(2, aiRequestSucjectId);

            int affectedRowsForSubject = preStm.executeUpdate();
            if (affectedRowsForSubject < 0) {
                throw new RuntimeException("cms_subject_line_requests tablosunda Request ID bulunamadı.");
            }
            isSubjectRequest= true;
        }
    } catch (SQLException e) {
        logger.error("Error inserting subject line request log", e);
    } finally {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }
    }
    JsonObject responseJson = new JsonObject();
    if (isSubjectRequest) {
        responseJson.put("Subject", "Subject line request saved successfully.");
    } else if (isContentRequest) {
        responseJson.put("Content", "Content request saved successfully.");
    }else {
        responseJson.put("Error", "No request was saved. Because no request ID was provided.");
    }
    out.println(responseJson);
%>
