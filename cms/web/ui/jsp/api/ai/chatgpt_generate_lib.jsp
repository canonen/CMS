<%--
  Created by IntelliJ IDEA.
  User: Emre CERRAH
  Date: 1.07.2025
  Time: 11:01
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.net.*, java.util.*" %>
<%@ page import="javax.ws.rs.core.HttpHeaders" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="org.json.JSONException" %>
<%@ page import="com.jscape.inet.http.Http" %>
<%!
  String API_KEY = "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";//"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"; //! OpenAI API key
  String API_URL = "https://api.openai.com/v1/chat/completions";
  String GPT_3_5_TURBO = "gpt-3.5-turbo";
%>
<%!
    public JSONObject generateChatGPTResponse (StringBuilder prompt, String systemMessage) throws IOException, JSONException {
      JSONObject requestBody = new JSONObject();
      JSONArray messages = new JSONArray();
      try {

// 1. System mesajı: modelin davranışını tanımlar
        JSONObject system = new JSONObject();
        system.put("role", "system");
        system.put("content", systemMessage);

        messages.put(system);

// 2. User mesajı: kullanıcı girdisi (senin prompt)
        JSONObject message = new JSONObject();
        message.put("role", "user");
        message.put("content", prompt.toString());

        messages.put(message);
        requestBody.put("model", GPT_3_5_TURBO);
        requestBody.put("messages", messages);
      } catch (JSONException e) {
        throw new RuntimeException(e);
      }

// String olarak gönder
      String jsonInput = requestBody.toString();

      // Bağlantıyı kur
      URL url = new URL(API_URL);
      HttpURLConnection con = (HttpURLConnection) url.openConnection();
      con.setRequestMethod("POST");
      con.setRequestProperty(HttpHeaders.AUTHORIZATION, "Bearer " + API_KEY);
      con.setRequestProperty(HttpHeaders.CONTENT_TYPE, "application/json");
      con.setDoOutput(true);

      // JSON veriyi gönder
      OutputStream os = con.getOutputStream();
      os.write(jsonInput.getBytes(StandardCharsets.UTF_8));
      os.flush();
      os.close();

      // Yanıtı oku
      BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8));
      StringBuilder responseBuilder = new StringBuilder();
      String line;
      while ((line = br.readLine()) != null) {
        responseBuilder.append(line);
      }
      br.close();

      // JSONObject olarak parse et
        return new JSONObject(responseBuilder.toString());
    }
%>