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
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String userid = "914";
String username = "Tech";
String password = "@dm1n";
String custid = "327";
String token = "rvs1";

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

	out.println(hexString.toString());
}
catch(Exception e)
{
	
}
%>