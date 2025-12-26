
<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<html>
<body>
	<table border="1">

	<tr>
	<td><b>Username</b></td>
	<td><b>Password</b></td>
	<td><b>Options</b></td>
	</tr>
<%
ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt=	null;
ResultSet		rs	= null; 


String custid = request.getParameter("custid");
String username = "";
String email = "";
String password="";
int userid=0;



try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("bilginet/campaigns.jsp");
	stmt = conn.createStatement();
	
	String sSql = "select * from ccps_user where cust_id = "+custid;
	rs = stmt.executeQuery(sSql);
	
	while( rs.next() )
	{

		userid= rs.getInt(1);
		username = rs.getString(5);
		password = rs.getString(3);
		email = rs.getString(9);
		%>
		
		<tr>
		
		<td><%=username%></td>
		<td><%=email%></td>
		<td>
		<form method="post" action="generate.jsp">
			<input type="hidden" name="userid" value="<%=userid%>">
			<input type="hidden" name="username" value="<%=username%>">
			<input type="hidden" name="password" value="<%=password%>">
			<input type="hidden" name="email" value="<%=email%>">
			<input type="hidden" name="custid" value="<%=custid%>">
			<input type="submit" name="gen" value="Generate">
		</form>
		</td>
	</tr>
		
		<%
	}
	}
	catch(Exception e){
	}
%>	</table>




</body>
</html>

