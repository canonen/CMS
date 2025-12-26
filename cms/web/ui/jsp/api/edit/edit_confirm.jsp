<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,javax.servlet.*,
			javax.servlet.http.*,java.util.*,
			org.apache.log4j.*"
%>

<%! static Logger logger = null;%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
JsonObject jsonObject = new JsonObject();
JsonArray jsonArray = new JsonArray();

String result = "Recipient information has been placed in the update queue.";
jsonObject.put("message",result);
jsonArray.put(jsonObject);
out.print(jsonArray);
%>
