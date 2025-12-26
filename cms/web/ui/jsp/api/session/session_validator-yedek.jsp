<%@page import="com.britemoon.*" %>
<%@page import="com.britemoon.cps.*" %>
<%@page import="com.britemoon.cps.imc.*" %>
<%@page import="com.britemoon.cps.rpt.*" %>
<%@page import="com.britemoon.cps.User" %>
<%@page import="com.britemoon.cps.Customer" %>
<%@page import="com.britemoon.cps.UIEnvironment" %>
<%@page import="com.britemoon.cps.SessionMonitor" %>
<%@ page import="java.util.*, java.net.*, java.io.*" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Array" %>
<%@ include file="session_header.jsp" %>

<%
    boolean bIsValid = false;

    Customer cust = null;
    User user = null;
    UIEnvironment ui = null;
    JsonObject sessionObject = new JsonObject();
    JsonArray sessionArray = new JsonArray();
    String web_page = "";
    
	if ( (session != null) && (request.isRequestedSessionIdValid()))
    {
        cust = (Customer) session.getAttribute("cust");
        user = (User) session.getAttribute("user");
        ui = (UIEnvironment) session.getAttribute("ui");

        String domainRegex = "^(https?://)?([a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,6}(/.*)?$";
		
		Service service = null;
        Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
        service = (Service) services.get(0);
		String rcpData = service.getURL().getHost();


        ConnectionPool cp = null;
        Connection conn = null;
        Statement stmt = null;



        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection(this);

            stmt = conn.createStatement();

            String sSql = "SELECT web_page FROM c_smart_widget_settings WHERE cust_id =" + cust.s_cust_id;

            ResultSet rs = stmt.executeQuery(sSql);
            if (rs.next()) {
                 web_page = rs.getString(1);
            }
            rs.close();

        } catch (Exception ex) {
            throw ex;
        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        }


        if ((cust != null) && ( user != null ))
        {
            Pattern pattern = Pattern.compile(domainRegex);
            Matcher matcher = pattern.matcher(web_page);

            bIsValid = true;
            sessionObject.put("success",true);
			sessionObject.put("session",session.getId());
			sessionObject.put("custId",cust.s_cust_id);
			sessionObject.put("rcpData", rcpData);
			sessionObject.put("custName", cust.s_cust_name);
			sessionObject.put("company", cust.s_login_name);
			sessionObject.put("message", "login successful.");
			sessionObject.put("fullName", user.s_user_name + " " + user.s_last_name);
            if (matcher.matches()) {
                sessionObject.put("webPage", web_page);
            }
			sessionArray.put(sessionObject);
            out.print(sessionArray);
        }
        else
        {
            try { session.invalidate(); }
            catch(Exception ex){}
        }
    }

    if (!bIsValid)
    {
        
        sessionObject.put("session",false);
        sessionArray.put(sessionObject);
        out.print(sessionArray);
        return;
    }

    SessionMonitor.update(session, request.getRequestURI());
%>
