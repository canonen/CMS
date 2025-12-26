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
<%@ include file="session_header.jsp" %>

<%
    boolean bIsValid = false;

    Customer cust = null;
    User user = null;
    UIEnvironment ui = null;
    JsonObject sessionObject = new JsonObject();
    JsonArray sessionArray = new JsonArray();
    
	if ( (session != null) && (request.isRequestedSessionIdValid()))
    {
        cust = (Customer) session.getAttribute("cust");
        user = (User) session.getAttribute("user");
        ui = (UIEnvironment) session.getAttribute("ui");
		
		Service service = null;
        Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
        service = (Service) services.get(0);
		String rcpData = service.getURL().getHost();

        if ((cust != null) && ( user != null ))
        {
            bIsValid = true;
            sessionObject.put("success",true);
			sessionObject.put("session",session.getId());
			sessionObject.put("custId",cust.s_cust_id);
			sessionObject.put("rcpData", rcpData);
			sessionObject.put("custName", cust.s_cust_name);
			sessionObject.put("company", cust.s_login_name);
			sessionObject.put("message", "login successful.");
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
