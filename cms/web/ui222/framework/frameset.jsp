<%@ page
	language="java"
	import="com.britemoon.*, com.britemoon.cps.*, java.net.*,
		 java.io.*, java.sql.*, java.util.*, java.util.*, java.sql.*, org.w3c.dom.*"
	errorPage="../jsp/error_page.jsp"
	contentType="text/html;charset=UTF-8"

%><%@ include file="../jsp/header.jsp" %><%@ include file="../jsp/validator.jsp"%><%
//grab query strings
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sAltURL = request.getParameter("url");
	String sMainUrl = "";
	String sTitle = "";

//set default values for querystrings
	if ((null == sNavTab) || ("" == sNavTab))
	{
		sNavTab = "Home";
	}
	
	if ((null == sNavSection) || ("" == sNavSection))
	{
		sNavSection = "1";
	}


//check tab and set variables
	if (sNavTab.equals("Home"))
	{
		//set variables
			sTitle = "Home";
	}
	else if (sNavTab.equals("Camp"))
	{
		//set variables
			sTitle = "Campaign";
	}
	else if (sNavTab.equals("Data"))
	{
		//set variables
			sTitle = "Database";
	}
	else if (sNavTab.equals("Cont"))
	{
		//set variables
			sTitle = "Content";
	}
	else if (sNavTab.equals("Rept"))
	{
		//set variables
			sTitle = "Report";
	}
	else if (sNavTab.equals("Admn"))
	{
		//set variables
			sTitle = "Administration";
	}
	else if (sNavTab.equals("Help"))
	{
		//set variables
			sTitle = "Help";
	}
	else
	{
		//set variables
			sTitle = "Home";
	}

//check for alternate url
	if ((null != sAltURL) && ("" != sAltURL))
	{
		sMainUrl = sAltURL;
	}
	
	String CRMMode = request.getParameter("mode");
	String redirectURL;
	
	if (CRMMode == null) CRMMode = ui.getSessionProperty("crm_mode");
	if ((CRMMode == null)||("".equals(CRMMode))) CRMMode = "advanced";
	ui.setSessionProperty("crm_mode", CRMMode);
	
	if(!sMainUrl.startsWith(((HttpServletRequest)request).getContextPath()))
		sMainUrl = ((HttpServletRequest)request).getContextPath() + "/ui/jsp/" + sMainUrl;
	redirectURL = "home.jsp?tab=" + sNavTab + "&sec=" + sNavSection + "&url=" + URLEncoder.encode(sMainUrl);
	
	if ("simple".equals(CRMMode)) response.sendRedirect(redirectURL);
	
%>












<%

	
	String _pathToSecondaryFiles = "";
	String pageTitle = "Ovalca Console";
	String headerFile = "header.jsp";
	String bodyURL = "body.jsp";
	String windowName = "main_admin";
%>

<html>
	<head>
		<title><%= pageTitle %></title>
	</head>
<script>
	if(window.top!=window.self)
		window.top.location.href =window.self.location.href;
</script>
<script language="JavaScript">window.name = "<%=windowName%>";</script>

<frameset rows="51,*" frameborder="NO" border="0" framespacing="0" bordercolor="#000000">
	<frame name="headerFrame" scrolling="NO" noresize src="<%=_pathToSecondaryFiles%><%=headerFile %>?tab=<%= sNavTab %>&sec=<%= sNavSection %>&url=<%= URLEncoder.encode(sMainUrl) %>" />
	<frameset cols="195,*" frameborder="YES" border="2" framespacing="2">
		<frame name="leftFrame" scrolling="NO" src="<%=_pathToSecondaryFiles%>menu_frameset.jsp?tab=<%= sNavTab %>&sec=<%= sNavSection %>&url=<%= URLEncoder.encode(sMainUrl) %>"/>
		<frame name="bodyFrame" src="<%=_pathToSecondaryFiles + bodyURL%>?tab=<%= sNavTab %>&sec=<%= sNavSection %>&url=<%= URLEncoder.encode(sMainUrl) %>"  />
	</frameset> 
</frameset>

<noframes>
<body bgcolor="#FFFFFF" text="#000000">

</body>
</noframes>
</html>
