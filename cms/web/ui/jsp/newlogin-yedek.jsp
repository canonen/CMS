<%@page import="com.britemoon.*" %>
<%@page import="com.britemoon.cps.*" %>
<%@page import="com.britemoon.cps.imc.*" %>

<%@ page
    language="java"
    import="com.britemoon.*,
    com.britemoon.cps.*,
    java.sql.*,java.io.*,
    java.util.*,java.net.*,
    com.britemoon.cps.*,java.sql.*,
    java.io.*,javax.servlet.*,
    javax.servlet.http.*,java.util.*,
    java.net.*,
    org.apache.log4j.*"
    contentType="text/html;charset=UTF-8"
%>
<%@ page import="org.json.JSONObject" %>
<%! static Logger logger = null;%>
<%@ include file="header.jsp"%>

<%
if(logger == null) {
    logger = Logger.getLogger(this.getClass().getName());
}

try {
    String sCustLogin = request.getParameter("company");
    String sUserLogin = request.getParameter("login");
    String sPassword = request.getParameter("password");

    String sRedirect = "";
    String sUserId = "";

    JSONObject data1 = new JSONObject();
    Customer cust = new Customer(null, sCustLogin);

    boolean bIsCustActive = ((cust.s_status_id != null) && (CustStatus.ACTIVATED == Integer.parseInt(cust.s_status_id))) ? true : false;

    User user = new User(null, sUserLogin, cust.s_cust_id);
    sUserId = user.s_user_id;
    boolean bIsUserActive = ((user.s_status_id != null) && (UserStatus.ACTIVATED == Integer.parseInt(user.s_status_id))) ? true : false;
    boolean bIsPasswordValid = ((user.s_password != null) && (user.s_password.equals(sPassword))) ? true : false;
    boolean bPasswordExpiring = user.isPassExpiring();
    boolean bPasswordHasExpired = user.isPassHasExpired();

    if (bIsCustActive && bIsUserActive && bIsPasswordValid && (!bPasswordHasExpired)) {
        data1.put("success", true);
        data1.put("message", "login successful.");

        session = request.getSession(true);
        UIEnvironment ui = new UIEnvironment(session, user, cust);
        SessionMonitor.update(session, request.getRequestURI());

        Service service = null;
        Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
        service = (Service) services.get(0);
        String rcpData = service.getURL().getHost();

        data1.put("session", session.getId());
        data1.put("custId", cust.s_cust_id);
        data1.put("rcpData", rcpData);
        data1.put("custName", cust.s_cust_name);
        data1.put("company", cust.s_login_name);

        out.print(data1.toString());
    } else {
        data1.put("success", false);
        data1.put("message", "Invalid username or password.");

        response.setStatus(403);

        out.print(data1.toString());
    }
} catch (Exception ex) {
    JSONObject data1 = new JSONObject();
    data1.put("success", false);
    data1.put("message", "Server error: " + ex.getMessage());

    response.setStatus(500);

    out.print(data1.toString());

    ErrLog.put(this, ex, "Error in newlogin.jsp", out, 1);
} finally {
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");
}
%>
