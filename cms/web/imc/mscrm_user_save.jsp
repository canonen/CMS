<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.adm.*, 
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
Element eNote = XmlUtil.getRootElement(request);
String sUserId = "";
	
if (eNote == null)
{
	out.println("<ERROR level=\"1\">Error retrieving XML in CPS->mscrm_user_save.jsp.  XML sent to CPS did not parse correctly.</ERROR>");
}
else
{
	User user = new User(eNote);
	user.saveWithSync();
	sUserId = user.s_user_id;
}

%>
<response><user_id><%= sUserId %></user_id></response>