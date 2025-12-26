<%
	response.setContentType("*/*");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin","https://dev.revotas.com:3002");
	response.setHeader("Access-Control-Allow-Credentials", "true");
	response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
%>
