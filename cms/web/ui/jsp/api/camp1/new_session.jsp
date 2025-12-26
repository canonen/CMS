<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="com.example.SessionManager" %>

<%
    boolean bIsValid = false;
    Customer cust = null;
    User user = null;
    UIEnvironment ui = null;

    HttpSession currentSession = request.getSession(false); // Mevcut oturumu kontrol et

    System.out.println(session.getId() + "sesion3");
    if ((currentSession != null) && (currentSession.isNew() || currentSession.isRequestedSessionIdValid())) {
        cust = (Customer) currentSession.getAttribute("cust");
        user = (User) currentSession.getAttribute("user");
        ui = (UIEnvironment) currentSession.getAttribute("ui");

        System.out.println("cust " + cust.toString());
        System.out.println("user " + user.toString());
        System.out.println("session" + currentSession.getId());

        if ((cust != null) && (user != null)) {
            bIsValid = true;
        } else {
            try {
                currentSession.invalidate();
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
        currentSession = request.getSession(true);

        //response.sendRedirect("login.jsp");
        return;
    }
    SessionMonitor.update(currentSession, request.getRequestURI());
%>
