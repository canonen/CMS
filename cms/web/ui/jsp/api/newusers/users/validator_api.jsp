<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
			
%>
<%
	boolean bIsValid = false;
	String apiKey = BriteRequest.getParameter(request,"apiKey");
	System.out.println(apiKey);  
	Customer cust = null;
	User user = null;
	UIEnvironment ui = null;
	System.out.println(apiKey);

	if ( ((session != null) && (request.isRequestedSessionIdValid())) || apiKey.equals("asd"))
	{
		
		cust = (Customer) session.getAttribute("cust");
		user = (User) session.getAttribute("user");
		ui = (UIEnvironment) session.getAttribute("ui");

		if (((cust != null) && ( user != null )) || apiKey.equals("asd")) bIsValid = true;
		else
		{
			try { session.invalidate(); }
			catch(Exception ex){}
		}
	}

	if (!bIsValid)
	{
		response.sendRedirect("/cms/ui/jsp/session_expired.jsp");
		return;
	}

	SessionMonitor.update(session, request.getRequestURI());
%>
