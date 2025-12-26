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

	contentType="text/html;charset=UTF-8"
%>
<%
   
   Locale locale = Locale.getDefault(); 
   String lng = locale.getCountry(); 

   session.setAttribute( "language", lng);

   if (lng.equals( "UA"))
       locale = new Locale( "uk", "UA");
   else if (lng.equals( "RU"))
       locale = new Locale( "ru", "RU");
   else
       locale = Locale.US;

   ResourceBundle boundle = ResourceBundle.getBundle("messages", locale);

   for (Enumeration e = boundle.getKeys(); e.hasMoreElements(); ) {
       String key = (String) e.nextElement();
       String s = boundle.getString(key);
       session.setAttribute( key, s);
   }

 System.out.println(bundle.getString("About"));
 
%>