<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="java.util.Arrays" %>

<%
    String username = request.getParameter("username");

    boolean bIsValid = false;
    Customer cust = null;
    User user = null;
    UIEnvironment ui = null;
    if ((session != null) && (request.isRequestedSessionIdValid())) {
        cust = (Customer) session.getAttribute("cust");
        user = (User) session.getAttribute("user");
        ui = (UIEnvironment) session.getAttribute("ui");

        if ((cust != null) && (user != null)) {
            String existingUser = null;
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if (cookie.getName().equals("username")) {
                        existingUser = cookie.getValue();
                        break;
                    }
                }
            }

            if (existingUser != null && !existingUser.equals(username)) {
                session.invalidate();
                response.sendRedirect("../../newlogin.jsp"); 
                return;
            }

            bIsValid = true;
        } else {
            session.invalidate();
            response.sendRedirect("../../newlogin.jsp");
            return;
        }
    }

    if (!bIsValid) {
        response.sendRedirect("../../newlogin.jsp"); 
        return;
    }

    // Yeni kullanıcıyı oturumla
    Cookie userCookie = new Cookie("username", username);
    userCookie.setPath("/"); 
    response.addCookie(userCookie);

    out.println("Yeni kullanıcı (" + username + ") oturumlandı!<br>");
    out.println("<br>");
%>
