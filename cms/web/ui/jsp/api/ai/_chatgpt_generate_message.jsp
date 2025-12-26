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
    String emailDetail = request.getParameter("emailDetail");
    String language = request.getParameter("language");
    String audienceStage = request.getParameter("audienceStage");
    String emailType = request.getParameter("emailType");
    String intent = request.getParameter("intent");
    String tone = request.getParameter("tone");
    String emoji = request.getParameter("emoji");

    // 📌 Prompt'u oluştur
    StringBuilder prompt = new StringBuilder();
    prompt.append("Generate 5 subject line suggestions for an email with the following details:\n");
    prompt.append("Email Purpose: ").append(emailDetail).append("\n");
    prompt.append("Language: ").append(language).append("\n");
    prompt.append("Audience Engagement Stage: ").append(audienceStage).append("\n");
    prompt.append("Type of Email: ").append(emailType).append("\n");
    prompt.append("Intent of the Email: ").append(intent).append("\n");
    prompt.append("Tone of Voice: ").append(tone).append("\n");
    if ("true".equals(emoji)) {
        prompt.append("Include emojis in the subject lines.\n");
    }


    String apiKey = "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";//"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"; //! OpenAI API key
    String apiUrl = "https://api.openai.com/v1/chat/completions";

    // Gövdeyi hazırla
    JSONObject message = new JSONObject();
    JSONObject requestBody = new JSONObject();
    try {
        message.put("role", "user");
        message.put("content", prompt.toString());
        JSONArray messages = new JSONArray();
        messages.put(message);
        requestBody.put("model", "gpt-3.5-turbo");
        requestBody.put("messages", messages);
    } catch (JSONException e) {
        throw new RuntimeException(e);
    }

// String olarak gönder
    String jsonInput = requestBody.toString();

    // Bağlantıyı kur
    URL url = new URL(apiUrl);
    HttpURLConnection con = (HttpURLConnection) url.openConnection();
    con.setRequestMethod("POST");
    con.setRequestProperty("Authorization", "Bearer " + apiKey);
    con.setRequestProperty("Content-Type", "application/json");
    con.setDoOutput(true);

    // JSON veriyi gönder
    long startTime = System.currentTimeMillis();
    OutputStream os = con.getOutputStream();
    os.write(jsonInput.getBytes("UTF-8"));
    os.flush();
    os.close();

    // Yanıtı oku
    BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
    StringBuilder responseBuilder = new StringBuilder();
    String line;
    while ((line = br.readLine()) != null) {
        responseBuilder.append(line);
    }
    br.close();

    // JSONObject olarak parse et
    JSONObject jsonResponse = new JSONObject(responseBuilder.toString());


    long endTime = System.currentTimeMillis();
    long elapsedTime = endTime - startTime; // milisaniye cinsinden süre


    // Yanıt içeriğini çek (choices[0].message.content)
    int createdId = 0;
    String model = null;
    String responseId = null;
    int totalTokens = 0;
    int promptTokens = 0;
    String reply = null;
    try {
        createdId = jsonResponse.getInt("created");
        model = jsonResponse.getString("model");
        responseId = jsonResponse.getString("id");
        totalTokens = jsonResponse.getJSONObject("usage").getInt("total_tokens");
        promptTokens = jsonResponse.getJSONObject("usage").getInt("prompt_tokens");
        JSONArray choices = jsonResponse.getJSONArray("choices");
        JSONObject messageObj = choices.getJSONObject(0).getJSONObject("message");
        reply = messageObj.getString("content").replace("\n", "<br>");
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
    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);

        String sSql = "INSERT INTO cms_subject_line_requests (customer_id, campaign_id, prompt, context, temperature, total_tokens, model) " +
                " VALUES ( ?,?, ?, ?, ?, ?,?);";
        preStm = conn.prepareStatement(sSql, Statement.RETURN_GENERATED_KEYS);

        preStm.setInt(1, Integer.parseInt(user.s_cust_id));
        preStm.setInt(2, Integer.parseInt(campId));
        preStm.setString(3, emailDetail);
        preStm.setString(4, reply);
        preStm.setString(5, "0.0");
        preStm.setInt(6, totalTokens);
        preStm.setString(7, model);

        int affectedRows = preStm.executeUpdate();
        int requestId = 0;
        if (affectedRows > 0) {
            ResultSet rs = preStm.getGeneratedKeys();
            if (rs.next()) {
                requestId  = rs.getInt(1);
                System.out.println("Oluşturulan request_id: " + requestId);
            }
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
    responseJson.put("reply", reply);
    out.println(responseJson);
%>
