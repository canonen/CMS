<%@ page
	language="java"
	import="com.britemoon.*" 
	import="com.britemoon.cps.*" 
	import="java.io.*"
	import="java.sql.*" 
	import="java.util.*" 
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

Element eRoot = XmlUtil.getRootElement(request);
if (eRoot == null) {
	out.println("<ERROR>Error retrieving XML in camp_status_set.jsp.  XML did not parse correctly.</ERROR>");
	return;
}
String cust_id = XmlUtil.getChildTextValue(eRoot, "cust_id");
String camp_id = XmlUtil.getChildTextValue(eRoot, "camp_id");
String status_id = XmlUtil.getChildTextValue(eRoot, "status_id");
String sql = "UPDATE cque_campaign SET status_id = " + status_id + " WHERE camp_id = " + camp_id;
if (camp_id != null && status_id != null) {
	BriteUpdate.executeUpdate(sql);
}

%>
