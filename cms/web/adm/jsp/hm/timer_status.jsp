<%@ page
	language="java"
	import="java.net.*, 
			java.util.*,
			com.britemoon.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp" %>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="/rrcp/adm/css/style.css" TYPE="text/css">
</HEAD>
<BODY>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	String sAction = request.getParameter("action");
	String sTimerName = request.getParameter("name");

	if(sTimerName==null)
	{
		out.println("<H3>Parameter name is required</H3>");
		return;
	}

	BriteTimerGeneric btm = (BriteTimerGeneric)TimerManager.getTimer(sTimerName);
	if(btm==null)
	{
		out.println("<H3>Timer with name \"" + sTimerName + "\" does not exist.</H3>");
		return;
	}

	if(sAction!=null)
	{
		if("start".equals(sAction)) btm.start();
		if("stop".equals(sAction)) btm.stop();
		Thread.currentThread().sleep(1000);
	}
%>
<%=sTimerName%>
<BR>
<%=(btm.isStarted())?"Started":"Stopped" + ((btm.findSleepInterval()<=0)?" (sleep_interval <= 0, so print magic word Started for host monitor)":"")%>
<BR>
<%=(btm.isWorking())?"Working":"Sleeping"%>
<BR>
<%=(btm.isStopping())?"Stopping":""%>

</BODY>
</HTML>
