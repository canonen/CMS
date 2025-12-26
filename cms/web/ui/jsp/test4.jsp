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
   
public class LocalizationDemo {
	public static void main(String[] args) {
		Locale currentLocale = Locale.getDefault();
		ResourceBundle messages = ResourceBundle.getBundle("Messages",currentLocale);
		System.out.println(messages.getString("wish"));
	}
}
 
%>