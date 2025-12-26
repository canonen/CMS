<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="com.britemoon.*" %>
<%@ page import="com.britemoon.cps.*" %>
<%@ page import="com.britemoon.cps.imc.*" %>
<%@page import="com.britemoon.cps.imc.*" %>
<%@page import="com.britemoon.cps.rpt.*" %>
<%@page import="com.britemoon.cps.User" %>
<%@page import="com.britemoon.cps.Customer" %>
<%@ page import="java.sql.*" %>
<%@ page
        language="java"
        import="com.britemoon.*,
    com.britemoon.cps.*,
    java.sql.*,java.io.*,
    java.util.*,java.net.*,
    org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="org.json.JSONObject" %>
<%@ include file="header.jsp"%>

<%!
    private static final Logger logger = Logger.getLogger("YourClassName"); // Replace "YourClassName" with the actual class name.
%>

<%
    try {
        String sCustLogin = request.getParameter("company");
        String sUserLogin = request.getParameter("login");
        String sPassword = request.getParameter("password");
		String customer_type = "";
		ConnectionPool cp = null;
        Connection conn = null;
        Statement stmt = null;
        boolean isValid = false;

        JSONObject data1 = new JSONObject();

        Customer cust = new Customer(null, sCustLogin);
        User user = new User(null, sUserLogin, cust.s_cust_id);

        boolean bIsCustActive = cust.s_status_id != null && CustStatus.ACTIVATED == Integer.parseInt(cust.s_status_id);
        boolean bIsUserActive = user.s_status_id != null && UserStatus.ACTIVATED == Integer.parseInt(user.s_status_id);
        boolean bIsPasswordValid = user.s_password != null && user.s_password.equals(sPassword);
        boolean bPasswordExpiring = user.isPassExpiring();
        boolean bPasswordHasExpired = user.isPassHasExpired();

        if (bIsCustActive && bIsUserActive && bIsPasswordValid && !bPasswordHasExpired) {

            UIEnvironment ui = new UIEnvironment(session, user, cust);
            Customer sessionCust = (Customer) session.getAttribute("cust");
            User sessionUser = (User) session.getAttribute("user");


            if(sessionCust.s_cust_id != null   && sessionUser.s_user_id != null) {
                data1.put("valid", true);

                data1.put("success", true);
                data1.put("message", "Login Successful.");

                session = request.getSession(true);
                SessionMonitor.update(session, request.getRequestURI());

                List<Object> services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
                Service service = (Service) services.get(0); // Properly cast to Service type

                String rcpData = service.getURL().getHost();

                data1.put("session", session.getId());
                data1.put("custId", cust.s_cust_id);
                data1.put("rcpData", rcpData);
                data1.put("custName", cust.s_cust_name);
                data1.put("company", cust.s_login_name);
				try {
					cp = ConnectionPool.getInstance();
					conn = cp.getConnection(this);

					stmt = conn.createStatement();

					String sSql = "Select ui_type_id as type from ccps_user_ui_settings where user_id=" + user.s_user_id;

					ResultSet rs = stmt.executeQuery(sSql);
					if (rs.next()) {
						if(rs.getString("type").equals("100")){
							customer_type = "STANDARD";
						}else{
							customer_type = "ADVANCED";
						}
					}
					rs.close();

				} catch (Exception ex) {
					throw ex;
				} finally {
					if (stmt != null) stmt.close();
					if (conn != null) cp.free(conn);
				}
				data1.put("customerType", customer_type);
                out.print(data1.toString());
            }
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

        logger.error("Error in newlogin.jsp", ex);
    } finally {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
    }
%>
