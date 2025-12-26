<%@ page

        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
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

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>


<%@ include file="../validator.jsp" %>
<%@ include file="../../header.jsp" %>


<%

  boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
  if (session != null) {
	  int timeout = session.getMaxInactiveInterval();
	  
	  out.println("timeout: " + timeout);
  }


%>
