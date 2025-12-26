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
if(logger == null) {
	logger = Logger.getLogger(this.getClass().getName());
}

String query_cust_id = null;
String query_type_id = null;
String query_camp_id = null;
String query_action = null;
Element eRoot = XmlUtil.getRootElement(request);
if (eRoot == null) {
	out.println("<ERROR>Error retrieving XML in campaign_monitor_report.jsp.  XML did not parse correctly.</ERROR>");
	return;
}
else {
	query_cust_id = XmlUtil.getChildTextValue(eRoot, "cust_id");
	query_type_id = XmlUtil.getChildTextValue(eRoot, "type_id");
	query_camp_id = XmlUtil.getChildTextValue(eRoot, "camp_id");
	query_action = XmlUtil.getChildTextValue(eRoot, "action");
}

String sRedirect = "/cms/adm/jsp/camp/camp_monitor.jsp?want_xml=1";
	
if (null != query_cust_id) {
	sRedirect += "&cust_id=" + query_cust_id;
}
if (null != query_type_id){
	sRedirect += "&type_id=" + query_type_id;
}
if (null != query_camp_id && query_camp_id != ""){
	sRedirect += "&camp_id=" + query_camp_id;
}
if (null != query_action && query_action != ""){
	sRedirect += "&action=" + query_action;
}
//System.out.println("redirect => " + sRedirect);	
response.sendRedirect(sRedirect);

%>
