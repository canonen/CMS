<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.exp.*,
			java.sql.*,java.io.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="application/pdf;charset=UTF-8"
%>
<%
	response.setHeader("Expires", "0");
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Cache-Control", "max-age=0");
%>
<%@ include file="../validator.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">


<html>
<head>
<meta http-equiv="Content-Type" content="application/pdf; charset=UTF-8">
<title>Export As PDF</title>
</head>
<body>
	<%
		ExportToPDF pdf = new ExportToPDF();
		pdf.setUrlString(request.getHeader("Referer"));
		
		
		
		
		pdf.createPDF(session);
	%>
	
</body>
</html>