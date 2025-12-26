<%
	String requireLogin = Registry.getKey("sas_require_login");
	boolean forceLogin = false;

	if ("1".equals(requireLogin))
	{
		forceLogin = true;
	}
	else
	{
		forceLogin = false;
	}
	
	boolean bIsValid = false;

	Partner part = null;
	SystemUser systemuser = null;
	UIEnvironment ui = null;

	if ( (session != null) && (request.isRequestedSessionIdValid()))
	{
		part = (Partner) session.getAttribute("part");
		systemuser = (SystemUser) session.getAttribute("systemuser");
		ui = (UIEnvironment) session.getAttribute("ui");

		if ((part != null) && ( systemuser != null )) bIsValid = true;
		else
		{
			try { session.invalidate(); }
			catch(Exception ex){}
		}
	}

	if (!bIsValid && forceLogin)
	{
		response.sendRedirect("/sadm/adm/jsp/session_expired.jsp");
		return;
	}
%>
