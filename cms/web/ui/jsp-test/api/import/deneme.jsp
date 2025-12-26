<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.upd.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			org.json.JSONArray,
            org.json.JSONObject,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>

<%! static Logger logger = null;%>

<%
	JSONObject obj = new JSONObject();
	JSONArray arr = new JSONArray();
	
	obj.put("test1","test");
	arr.put(obj);
	out.print(arr);
%>