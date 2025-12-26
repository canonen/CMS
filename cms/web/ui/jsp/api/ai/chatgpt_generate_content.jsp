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
    prompt.append("You are an expert email copywriter.\n");
    prompt.append("Generate a detailed email body (100–300+ words) based on the following information:\n\n");

    prompt.append("Focus on persuasive storytelling, clear CTA (Call-To-Action), and engaging structure.\n");
    prompt.append("Goal: Maximize click-through and conversion, not just open rate.\n\n");
    prompt.append("Email Purpose: ").append(emailDetail).append("\n");
    prompt.append("Language: ").append(language).append("\n");
    prompt.append("Audience Engagement Stage: ").append(audienceStage).append("\n");
    prompt.append("Type of Email: ").append(emailType).append("\n");
    prompt.append("Intent of the Email: ").append(intent).append("\n");
    prompt.append("Tone of Voice: ").append(tone).append("\n");
    prompt.append("Industry : ").append(industry).append("\n");
    if ("true".equals(emoji)) {
        prompt.append("Include appropriate emojis in the email body.\n");
    }

    prompt.append("Make sure the message is clear, engaging, and relevant to the audience.\n");
    prompt.append("The result should be a complete email ready to send.\n");
    prompt.append("Only return the body of the email as plain text, no labels or headers.\n");

    JSONObject jsonResponse = null;
    long startTime = System.currentTimeMillis();
    try {
        jsonResponse = generateChatGPTResponse(prompt,"You are an expert email copywriter. Only return the email body. Do not include a subject line, title, or labels.");
    } catch (Exception e) {
        throw new RuntimeException(e);
    }

    long endTime = System.currentTimeMillis();
    long elapsedTime = endTime - startTime; // milisaniye cinsinden süre

    int createdId = 0;
    String model = null;
//    String responseId = null;
    int totalTokens = 0;
    int promptTokens = 0;
    String reply = null;
    String[] replyLines;

    try {
        createdId = jsonResponse.getInt("created");
        model = jsonResponse.getString("model");
//        responseId = jsonResponse.getString("id");
        totalTokens = jsonResponse.getJSONObject("usage").getInt("total_tokens");
        promptTokens = jsonResponse.getJSONObject("usage").getInt("prompt_tokens");
        JSONArray choices = jsonResponse.getJSONArray("choices");
        JSONObject messageObj = choices.getJSONObject(0).getJSONObject("message");
        reply = messageObj.getString("content");
    } catch (JSONException e) {
        throw new RuntimeException(e);
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

        String sSql = "INSERT INTO ccnt_email_content_requests (user_id , prompt_text , output_text , tone ,temperature , max_tokens , model,response_time_ms ) " +
                " VALUES ( ?,?,?,?,?,?,?,?);";
        preStm = conn.prepareStatement(sSql, Statement.RETURN_GENERATED_KEYS);

        preStm.setInt(1, Integer.parseInt(user.s_user_id));
//        preStm.setInt(1, Integer.parseInt(user.s_cust_id));
//        preStm.setInt(2, Integer.parseInt(campId));
        preStm.setString(2, emailDetail);
        preStm.setString(3, reply);
        preStm.setString(4, tone);
        preStm.setFloat(5, 0.0F); // Temperature is set to 0.0 as per the original code
        preStm.setInt(6, totalTokens);
        preStm.setString(7, model);
        preStm.setLong(8, elapsedTime);

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

        sSql = "EXEC usp_update_email_content_usage_stats " +
                "    @user_id = ?, " +
                "    @cust_id = ?, " +
                "    @org_id = ?, " +
                "    @used_tokens = ?, " +
                "    @response_time = ?;";
        preStmlogs = conn.prepareStatement(sSql);
        preStmlogs.setInt(1, Integer.parseInt(user.s_user_id));
        preStmlogs.setInt(2, Integer.parseInt(user.s_cust_id));
        preStmlogs.setInt(3, createdId);
        preStmlogs.setInt(4, promptTokens);
        preStmlogs.setLong(5, elapsedTime);
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
    responseJson.put("reply", reply);
    responseJson.put("aiRequestContentId", requestId);
    out.println(responseJson);
%>

