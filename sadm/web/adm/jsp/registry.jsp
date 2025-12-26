<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%
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
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="subactionbutton" href="registry.jsp?action">Refresh This Screen</a>&nbsp;&nbsp;&nbsp;
		</td>
		<td vAlign="middle" align="left" nowrap>
			<a class="subactionbutton" href="registry.jsp?action=refresh">Reload Data From DB</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table class="listTable" width="300" cellspacing="0" cellpadding="2" border="0">
	<tr>
		<th nowrap>Key Name</th>
		<th nowrap>Key Value</th>
	</tr>
<%
Object oKey = null;
Object oValue = null;

Iterator iRegistry = Registry.hRegistry.keySet().iterator();
		
int iCount = 0;
String sClassAppend = "";
	
while (iRegistry.hasNext())
{
	if (iCount % 2 != 0) sClassAppend = "_Alt";
	else sClassAppend = "";
	
	++iCount;
	
	oKey = iRegistry.next();
	oValue = Registry.hRegistry.get(oKey);
	%>
	<tr>
		<td class="listItem_Title<%= sClassAppend %>"><%= oKey %></td>
		<td class="listItem_Data<%= sClassAppend %>"><%= oValue %></td>
	</tr>
	<%
}
%>
</TABLE>
</BODY>
</HTML>