<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="com.example.SessionManager" %>

<%
    boolean bIsValid = false;
    Customer cust = null;
    User user = null;
    UIEnvironment ui = null;

    System.out.println(session.getId() + "sesion3");
    if ((session != null) && (request.isRequestedSessionIdValid())) {
        cust = (Customer) session.getAttribute("cust");
        user = (User) session.getAttribute("user");
        ui = (UIEnvironment) session.getAttribute("ui");

        System.out.println("cust " + cust.toString());
        System.out.println("user " + user.toString());
        System.out.println("session" + session.getId());

        if ((cust != null) && (user != null)) {
            bIsValid = true;
        } else {
            try {
                session.invalidate();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    if (!bIsValid) {
        HttpSession previousSession = request.getSession(false);
        if (previousSession != null) {
            SessionManager.invalidateSession(previousSession);
        }
        session = request.getSession(true);

        response.sendRedirect("anasayfa.jsp");
        return;
    }
    SessionMonitor.update(session, request.getRequestURI());
%>
