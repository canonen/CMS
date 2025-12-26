<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*" 
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*" 
	import="org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%
response.setHeader("Expires", "0");
response.setHeader("Pragma", "no-cache");
response.setHeader("Cache-Control", "no-store, no-cache, max-age=0");
response.setContentType("text/xml;charset=UTF-8");
%>
<%

String cust_id = BriteRequest.getParameter(request, "cust_id");

if((cust_id == null) || ("".equals(cust_id)))
{
	cust_id = "0";
}

Customer cust = new Customer(cust_id);
CustRetrieveUtil.retrieveFull(cust);

String userXML = "";
userXML = cust.toXml();

%><%= userXML %>