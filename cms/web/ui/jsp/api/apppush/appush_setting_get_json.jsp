<%@ page
        import="com.britemoon.*"
        import="com.britemoon.cps.*"
        import="com.britemoon.cps.imc.*"
        import="java.io.*"
        import="java.net.HttpURLConnection"
        import="java.net.URL"
        import="java.util.*"
        contentType="application/json;charset=UTF-8"
%>
<%
    String custId = request.getParameter("custId");

    if (custId == null || custId.isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("{\"error\":\"custId parametresi eksik\"}");
        return;
    }

    try {
        List<Object> services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, custId);
        Service service = (Service) services.get(0); // Properly cast

        // Diğer sunucunun JSP endpoint'i
        String otherServerUrl = "https://" + service.getURL().getHost() + "/rrcp/imc/app_push/get_firebase_auth_json.jsp?custId=" + custId;

        URL url = new URL(otherServerUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        // Yanıtı oku
        int responseCode = conn.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
            StringBuilder responseBuilder = new StringBuilder();
            String line;
            while ((line = in.readLine()) != null) {
                responseBuilder.append(line);
            }
            in.close();

            out.print("{\"message\":\"success\", \"response\":" + responseBuilder.toString() + "}");
        } else {
            response.setStatus(responseCode);
            out.print("{\"error\":\"Diğer sunucudan başarısız yanıt: " + conn.getResponseMessage() + "\"}");
        }

    } catch (Exception e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("{\"error\":\"Hata: " + e.getMessage() + "\"}");
    }
%>