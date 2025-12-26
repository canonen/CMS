<%@ page import="javax.servlet.http.*,
				java.util.*,
				java.net.*,
				java.io.* "
				contentType="text/html; charset=UTF-8"
%>

<%
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sMainUrl = request.getParameter("url");
%>

<html>
<head>
	<title>sub_frameset_pagination_nav</title>
</head>

<frameset rows="27,1*" frameborder="NO" border="0" framespacing="0">
	<frame name="topFrame" scrolling="NO" noresize src="system_menu_trail.jsp?tab=<%= sNavTab %>&sec=<%= sNavSection %>&url=<%= URLEncoder.encode(sMainUrl) %>">
	<frame name="mainFrame" scrolling="AUTO" src="menu.jsp?tab=<%= sNavTab %>&sec=<%= sNavSection %>&url=<%= URLEncoder.encode(sMainUrl) %>">
</frameset>

<noframes> 
<body bgcolor="#FFFFFF">

</body>
</noframes> 
</html>


