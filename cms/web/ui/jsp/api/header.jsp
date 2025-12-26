<%
	response.setContentType("*/*");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Headers", "x-requested-with, content-type");
	response.setHeader("Access-Control-Allow-Origin","https://cms.revotas.com:3001");
	response.setHeader("Access-Control-Allow-Credentials", "true");
	response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
%>
