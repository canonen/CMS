<%@ page

    language="java"

    import="com.britemoon.*,

            com.britemoon.cps.*,

            java.sql.*,java.io.*,

            javax.servlet.*,javax.servlet.http.*,

            java.util.*,java.net.*,

            org.apache.log4j.*"

    contentType="text/html;charset=UTF-8"

%>
<%! static Logger logger = null;%>
<%

    
  response.setHeader("Expires", "0");

    
  response.setHeader("Pragma", "no-cache");

    
  response.setHeader("Cache-Control", "no-store, no-cache"); //, max-age=0");

    
  response.setContentType("text/html;charset=UTF-8");
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%
	JsonObject obj = new JsonObject();
	JsonArray arr = new JsonArray();
	
	obj.put("session",false);
	arr.put(obj);
	out.print(arr);
    if(logger == null)

    {

        logger = Logger.getLogger(this.getClass().getName());

    }

%>

