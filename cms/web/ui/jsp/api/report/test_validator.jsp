<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", " GET, POST, PATCH, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>

<%


    boolean bIsValid = false;
    Customer cust = null;
    User user = null;
    UIEnvironment ui = null;
	JsonObject obj = new JsonObject();
	JsonArray array = new JsonArray();
    HttpSession mySession = request.getSession(false); // Yeni ismi mySession olarak atıyoruz

    if (mySession != null && mySession.getAttribute("cust") != null && mySession.getAttribute("user") != null) {
        cust = (Customer) mySession.getAttribute("cust"); // Eski session değişkeni yerine mySession kullanılıyor
        user = (User) mySession.getAttribute("user"); // Eski session değişkeni yerine mySession kullanılıyor
        ui = (UIEnvironment) mySession.getAttribute("ui"); // Eski session değişkeni yerine mySession kullanılıyor

        bIsValid = true;
    } else {
		
		
        // If the session is not valid, invalidate it
        //if (mySession != null) {
			obj.put("session1",false);
			array.put(obj);
			out.print(array);
            mySession.invalidate(); // Eski session değişkeni yerine mySession kullanılıyor
			
        //}
    }
	
    if (!bIsValid) {
        System.out.println("Invalid session");
        return; // Stop further processing for invalid session
    }

    SessionMonitor.update(mySession, request.getRequestURI()); // Eski session değişkeni yerine mySession kullanılıyor
	
%>
