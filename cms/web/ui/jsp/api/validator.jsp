
<%

    com.restfb.json.JsonObject sessionObject = new com.restfb.json.JsonObject();
    com.restfb.json.JsonArray   sessionArray  = new com.restfb.json.JsonArray();

    boolean bIsValid = false;
    Customer cust = null;
    User user = null;
    UIEnvironment ui = null;
    // System.out.println("Session ID >>>> : "+ session.getId());
    // System.out.println("Rquest Session ID >>>> : "+ session.getId());
    // System.out.println("Rquest Session ID VALID >>>> : "+ request.isRequestedSessionIdValid());
    if ( (session != null) && (request.isRequestedSessionIdValid()))
    {
        cust = (Customer) session.getAttribute("cust");
        user = (User) session.getAttribute("user");
        ui = (UIEnvironment) session.getAttribute("ui");

        //System.out.println("cust " + cust.toString());
        //System.out.println("user " + user.toString());
        //System.out.println("session"+ session.getId());
        //System.out.println("�alisti amk");

        if ((cust != null) && ( user != null )) bIsValid = true;
        else
        {
            try { session.invalidate(); }
            catch(Exception ex){}
        }
    }

    if (!bIsValid)
    {
        sessionObject.put("validate",false);
        sessionArray.put(sessionObject);
        out.println(sessionArray.toString());
        return;
    }

    SessionMonitor.update(session, request.getRequestURI());
%>




