<%
	
    boolean bIsValid = false;
    Customer cust = null;
    User user = null;
    UIEnvironment ui = null;
    System.out.println("sessionim"+ session.getId());
    if ( (session != null) && (request.isRequestedSessionIdValid()))
    {
        cust = (Customer) session.getAttribute("cust");
        user = (User) session.getAttribute("user");
        ui = (UIEnvironment) session.getAttribute("ui");
	
        //System.out.println("cust " + cust.toString());
        //System.out.println("user " + user.toString());
        //System.out.println("session"+ session.getId());
        //System.out.println("çalisti amk");
	
        if ((cust != null) && ( user != null )) bIsValid = true;
        else
        {
            try { session.invalidate(); }
            catch(Exception ex){}
        }
    }

    if (!bIsValid)
    {
        //System.out.println("çalismadi mk2");
        return;
    }

    SessionMonitor.update(session, request.getRequestURI());
%>




