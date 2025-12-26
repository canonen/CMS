<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			org.w3c.dom.*,java.util.*,
			java.sql.*,java.net.*,java.io.*,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%

	User user = null;
	

		out.println("session " + session+"<br>");

		user = (User) session.getAttribute("user");


	
%>





<%

String usr=user.s_user_id;


%>  
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
<script type="text/javascript">
var user='<%=usr%>';

</script>
</body>
</html>