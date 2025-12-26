<%@ page
	language="java"
	import="com.britemoon.*, com.britemoon.sas.*, java.io.*, java.sql.*, java.util.*, java.sql.*, org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="header.jsp" %>
<%@ include file="validator.jsp"%>
<html>
<head>
<title></title>
<%@ include file="header.html" %>
<link rel="stylesheet" href="../css/style.css" type="text/css">
</head>
<body marginheight="0" marginwidth="0" leftmargin="0" topmargin="0" style="padding:0px;">
	<table border="0" cellpadding="2" cellspacing="0" class="layout" style="width:100%; height:100%;">
		<col>
		<tr>
			<td class="sessionInfo" align="right" valign="middle">
				Welcome: <b><%= systemuser.s_first_name %>&nbsp;<%= (systemuser.s_last_name!=null)?systemuser.s_last_name:"" %></b>,<br>  
				You are currently logged into:
				<br><b><%=part.s_partner_name%></b>
			</td>
		</tr>
	</table>
</body>
</html>