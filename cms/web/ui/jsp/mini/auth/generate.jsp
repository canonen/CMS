<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,java.sql.*,
			java.io.*,javax.servlet.*,
			javax.servlet.http.*,java.util.*,
			java.security.MessageDigest,
			java.security.NoSuchAlgorithmException,
			java.net.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%

String token = "rvs1";

String userid = request.getParameter("userid");
String username = request.getParameter("username");
String custid = request.getParameter("custid");
String email = request.getParameter("email");
String password = request.getParameter("password");





String concatAuthCredentials = userid + username + password + custid + token;

byte[] defaultBytes = concatAuthCredentials.getBytes();
String hashAuthCredentials = "";

try
{
	MessageDigest algorithm = MessageDigest.getInstance("MD5");
	algorithm.reset();
	algorithm.update(defaultBytes);
	byte messageDigest[] = algorithm.digest();
			
	StringBuffer hexString = new StringBuffer();
	for (int i=0;i<messageDigest.length;i++) {
		hexString.append(Integer.toHexString(0xFF & messageDigest[i]));
	}

	out.println("Key: "+userid+"-"+hexString.toString()+"-"+custid);
}
catch(Exception e)
{
	
}
%>
