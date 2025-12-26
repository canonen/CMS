<%--
  Created by IntelliJ IDEA.
  User: Emre Kursat OZER
  Date: 26.03.2025
  Time: 12:54
  To change this template use File | Settings | File Templates.
--%>
<%@ page
        language="java"
        import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.wfl.*,
		java.sql.*,java.io.*,java.util.*,
		org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.net.URL" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="javax.net.ssl.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.Base64" %>
<%@ page import="org.json.JSONException" %>
<%@ include file="../header.jsp"%>
<%! static Logger logger = null;%>


<%
    // SSL sertifika doğrulamasını devre dışı bırakmak için



    try {
        TrustManager[] trustAllCerts = new TrustManager[]{
                new X509TrustManager() {
                    public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                        return null;
                    }
                    public void checkClientTrusted(java.security.cert.X509Certificate[] certs, String authType) {
                    }
                    public void checkServerTrusted(java.security.cert.X509Certificate[] certs, String authType) {
                    }
                }
        };

        SSLContext sc = SSLContext.getInstance("SSL");
        sc.init(null, trustAllCerts, new java.security.SecureRandom());
        HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

        HostnameVerifier allHostsValid = new HostnameVerifier() {
            public boolean verify(String hostname, SSLSession session) {
                return true;
            }
        };
        HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
    } catch (Exception e) {
        out.println("SSL doğrulama devre dışı bırakılamadı: " + e.getMessage());
    }

    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream(), StandardCharsets.UTF_8));
    StringBuilder sb = new StringBuilder();
    String line;
    while ((line = reader.readLine()) != null) {
        sb.append(line);
    }
    String jsonBody = sb.toString();

    if (jsonBody.trim().isEmpty()) {
        out.println("Body boş geldi.");
        return;
    }


    String customerId = request.getParameter("cust_id");

    if(customerId == null || customerId.trim().isEmpty()){
        out.println("Customer ID boş geldi.");
        return;
    }


    String urlString = "https://cms.revotas.com:6060/tickets/send-email?customerId=" + customerId;

    System.out.println("URL >> " +urlString);
    HttpURLConnection con = null;
    try {
        URL url = new URL(urlString);
        con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Content-Type", "application/json; utf-8");
        con.setDoOutput(true);

        // JSON'u isteğin gövdesine yazıyoruz
        try  {
            OutputStream os = con.getOutputStream();
            byte[] input = jsonBody.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }catch (Exception e){
            out.println("Hata oluştu: " + e.getMessage());
            e.printStackTrace();
        }

        // Yanıt kodunu alalım
        int responseCode = con.getResponseCode();
        out.println("Response Code: " + responseCode + "<br/>");

        // Yanıt gövdesini okuyalım
        BufferedReader br = null;
        if (responseCode >= 200 && responseCode < 300) {
            br = new BufferedReader(new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8));
        } else {
            // 4xx veya 5xx durumlarında hata akışını okuyarak,
            // hangi alanın eksik/hatalı olduğunu öğrenebilirsiniz.
            if (con.getErrorStream() != null) {
                br = new BufferedReader(new InputStreamReader(con.getErrorStream(), StandardCharsets.UTF_8));
            }
        }

        if (br != null) {
            StringBuilder responseStr = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                responseStr.append(responseLine.trim());
            }
            br.close();
            out.println("Response Body: " + responseStr.toString());
        }

    } catch (Exception e) {
        out.println("Hata oluştu: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (con != null) {
            con.disconnect();
        }
    }

%>




