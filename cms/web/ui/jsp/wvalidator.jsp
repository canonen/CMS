<%
	boolean bIsValid = false;

	Customer cust = null;
	User user = null;
	UIEnvironment ui = null;

	if ( (session != null) && (request.isRequestedSessionIdValid()))
	{
		cust = (Customer) session.getAttribute("cust");
		user = (User) session.getAttribute("user");
		ui = (UIEnvironment) session.getAttribute("ui");

		if ((cust != null) && ( user != null )) bIsValid = true;
		else
		{
			try { session.invalidate(); }
			catch(Exception ex){}
		}
	}

	if (!bIsValid)
	{
		response.sendRedirect("/cms/ui/jsp/wsession_expired.jsp");
		return;
	}

	SessionMonitor.update(session, request.getRequestURI());
%>
