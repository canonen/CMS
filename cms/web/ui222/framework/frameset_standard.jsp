<%@ page import="javax.servlet.http.*,
				 java.io.*,
				 java.net.*,
		 		 java.util.*"

%>
<%
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sMainUrl = request.getParameter("url");
%>

<%

	String pageName = "Welcome";
	String sAltURL = request.getParameter("url");


	String bodyURL = "../jsp/home/welcome.jsp";
	String body = request.getParameter("body");
	if(body!=null) {
		try {
			int bt = Integer.parseInt(body);
			switch(bt) {
				case 3: 	bodyURL = "../pages/camp/camp_list.jsp";
									break;
				default:	break;
			}
		} catch(Exception e) {
		}
	}
	if(sAltURL!=null)
		bodyURL = sAltURL;
	String trailURL = "trail.jsp";
%><html>
<head>
	<title><%=pageName%></title>
</head>


<frameset rows="27,1*" frameborder="NO" border="0" framespacing="0">
	<frame name="topFrame" scrolling="NO" noresize src="<%=trailURL%>?tab=<%= sNavTab %>&sec=<%= sNavSection %>&url=<%= URLEncoder.encode(sMainUrl) %>">
	<frame name="mainFrame" scrolling="AUTO" src="<%=bodyURL%>">
</frameset>


<noframes>
	<body bgcolor="#FFFFFF">
		NO FRAMES
	</body>
</noframes>

</html>
