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
public multiLanguage{ 
	public static void main(String arg[]){ 
	Locale currentLocale= new Locale("fr", "FR"); 
	ResourceBundle rb = ResourceBundle.getBundle("MessagesBundle", currentLocale); 
	System.out.println(rb.getString("About")); 
	} 
} 	
%>