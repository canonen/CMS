<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,
			java.sql.*,
			java.util.*,
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	String sAction = request.getParameter("action");
	if ( (sAction != null) && sAction.equals("refresh") )
	{
		Registry.init(this.getServletContext());
		Thread.currentThread().sleep(1000);
		response.sendRedirect("registry.jsp");
	}
%>

<HTML>
<HEAD>
	<link rel="stylesheet" href="../css/style.css" TYPE="text/css">
</HEAD>
<BODY>

<H3>Registry</H3>
Current Time: <%=new java.util.Date()%>
<BR>
<A href="registry.jsp?action">Refresh this screen</A>
|
<A href="registry.jsp?action=refresh">Reload data from db</A>
<BR>
<TABLE border="1">
<TR>
	<TH>Key Name</TH>
	<TH>Key Value</TH>
</TR>
<%
	Object oKey = null;
	Object oValue = null;

	Iterator iRegistry = Registry.hRegistry.keySet().iterator();
		
	while (iRegistry.hasNext())
	{
		oKey = iRegistry.next();
		oValue = Registry.hRegistry.get(oKey);
%>
	<TR>
		<TD><%=oKey%></TD>
		<TD><%=oValue%></TD>
	</TR>
<%
	}
%>
</TABLE>
</BODY>
</HTML>