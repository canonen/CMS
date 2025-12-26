
<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.ctl.*,
                com.britemoon.cps.*,
                com.britemoon.rcp.*,
                java.sql.*,
                java.io.*,
                java.util.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.que.*,
                java.util.Calendar,
                java.math.BigDecimal,
                org.apache.log4j.Logger,
                javax.mail.*,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.net.URL, java.io.BufferedReader, java.io.InputStreamReader"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>
<%
    AccessPermission can = user.getAccessPermission(ObjectType.FILTER);
    out.println(can);
    String urlStr = request.getParameter("url");

    StringBuilder source = new StringBuilder();

    JsonObject jsonObject = new JsonObject();
    JsonArray arrayData = new JsonArray();

    try {
        URL url = new URL(urlStr);
        BufferedReader reader = new BufferedReader(new InputStreamReader(url.openStream(), "UTF-8"));
        String line;
        while ((line = reader.readLine()) != null) {
            source.append(line);
        }
        jsonObject.put("code",source.toString());
        reader.close();
        out.println(jsonObject);
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

