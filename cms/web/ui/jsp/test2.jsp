<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			com.britemoon.cps.ctl.*,
			java.io.*,java.sql.*,java.util.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"	
	contentType="text/html;charset=UTF-8"
%>
<%
      // create a new locale
      //Locale locale1 = new Locale("en", "US", "WIN");

      // print locale
      //out.println("Locale:" + locale1);
      
	//out.println("Riego  Locale.getDefault().getLanguage(): "  + Locale.getDefault().getLanguage());
	out.println(Locale.getDefault().getLanguage());
	Locale.setDefault(Locale.ITALY);
	out.println(Locale.getDefault().getLanguage());		
%>