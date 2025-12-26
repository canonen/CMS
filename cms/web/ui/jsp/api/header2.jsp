<%--<%
	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Headers", "Access-Control-*, Origin, X-Requested-With, Content-Type, Accept");
	response.setHeader("Access-Control-Allow-Origin", "https://dev.revotas.com:3002");
	//response.setHeader("Access-Control-Allow-Credentials", "true");
	response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
%>--%>

<%
	 response.setContentType("application/json");
	 response.setCharacterEncoding("UTF-8");
	 response.setHeader("Access-Control-Allow-Headers", "x-requested-with, content-type");
	 response.setHeader("Access-Control-Allow-Origin", "https://dev.revotas.com:3002");
	 response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
%>
