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
<%@ include file="../fixTurkishCharacters.jsp" %>
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

//    String campId = request.getParameter("campId");
    String emailDetail = request.getParameter("emailDetail");
    String language = request.getParameter("language");
    String audienceStage = request.getParameter("audienceStage");
    String emailType = request.getParameter("emailType");
    String intent = request.getParameter("intent");
    String tone = request.getParameter("tone");
    String emoji = request.getParameter("emoji");
    String industry = request.getParameter("industry");

    // 📌 Prompt'u oluştur
    StringBuilder prompt = new StringBuilder();
    prompt.append("You are an expert email copywriter. Generate 5 subject line suggestions for an email with the following details. Just return the subject lines, one per line, no list numbers, no bullets, and no extra text or explanation.\n");
    prompt.append("Email Purpose: ").append(emailDetail).append("\n");
    prompt.append("Language: ").append(language).append("\n");
    prompt.append("Audience Engagement Stage: ").append(audienceStage).append("\n");
    prompt.append("Type of Email: ").append(emailType).append("\n");
    prompt.append("Intent of the Email: ").append(intent).append("\n");
    prompt.append("Tone of Voice: ").append(tone).append("\n");
    prompt.append("Industry : ").append(industry).append("\n");
    if ("true".equals(emoji)) {
        prompt.append("Include emojis in the subject lines.\n");
    }

    JSONObject jsonResponse = null;
    long startTime = System.currentTimeMillis();
    try {
        jsonResponse = generateChatGPTResponse(prompt,"You are an expert email copywriter. Only return the subject lines without any list numbers or extra formatting.");
    } catch (Exception e) {
        throw new RuntimeException(e);
    }

    long endTime = System.currentTimeMillis();
    long elapsedTime = endTime - startTime; // milisaniye cinsinden süre

    int createdId = 0;
    String model = null;
    String responseId = null;
    int totalTokens = 0;
    int promptTokens = 0;
    String reply = null;
    String[] replyLines= null;
    try {
//        createdId = jsonResponse.getInt("created");
        model = jsonResponse.getString("model");
        responseId = jsonResponse.getString("id");
        totalTokens = jsonResponse.getJSONObject("usage").getInt("total_tokens");
        promptTokens = jsonResponse.getJSONObject("usage").getInt("prompt_tokens");
        JSONArray choices = jsonResponse.getJSONArray("choices");
        JSONObject messageObj = choices.getJSONObject(0).getJSONObject("message");
        reply = messageObj.getString("content").replace("\n", "<br>");
        String content =fixTurkishCharacters(messageObj.getString("content"));
        replyLines = content.trim().split("\\n");
    } catch (JSONException e) {
        throw new RuntimeException(e);
    }

    JSONObject error = null;
    String errorMessage = null;
    if (jsonResponse.has("error")) {
        error = jsonResponse.getJSONObject("error");
        errorMessage = error.getString("message");
        System.err.println("API hatası: " + errorMessage + " (Kod: " + error + ")");
    }


    ConnectionPool cp = null;
    Connection conn = null;
    ResultSet rsLogs = null;
    PreparedStatement preStm = null;
    PreparedStatement preStmlogs = null;
    int requestId = 0;
    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        String sSql = "INSERT INTO cms_subject_line_requests (customer_id, prompt, context, temperature, total_tokens, model) " +
                " VALUES ( ?, ?, ?, ?, ?, ?);";
        preStm = conn.prepareStatement(sSql, Statement.RETURN_GENERATED_KEYS);

        preStm.setInt(1, Integer.parseInt(user.s_cust_id));
//        preStm.setInt(2, Integer.parseInt(aiId));
        preStm.setString(2, emailDetail);
        preStm.setString(3, reply);
        preStm.setString(4, "0.0");
        preStm.setInt(5, totalTokens);
        preStm.setString(6, model);

        int affectedRows = preStm.executeUpdate();
        if (affectedRows > 0) {
            ResultSet rs = preStm.getGeneratedKeys();
            if (rs.next()) {
                requestId  = rs.getInt(1);
                System.out.println("Oluşturulan request_id: " + requestId);
            }
        }
        if (requestId==0){
            throw new RuntimeException("Request ID oluşturulamadı.");
        }

        sSql = "INSERT INTO cms_api_usage_logs ( request_id, response_id, tokens_used, api_status," +
                " error_message, latency_ms) " +
                " VALUES (?, ?, ?, ?, ?, ?);";
        preStmlogs = conn.prepareStatement(sSql);
        preStmlogs.setInt(1, requestId);
        preStmlogs.setString(2, responseId);
        preStmlogs.setInt(3, promptTokens);
        preStmlogs.setString(4, error == null ? "success" : "error");
        preStmlogs.setString(5, errorMessage);
        preStmlogs.setLong(6, elapsedTime);
        preStmlogs.executeUpdate();



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
    responseJson.put("reply", replyLines);
    responseJson.put("aiRequestSubjectId", requestId);
    out.println(responseJson);
%>
