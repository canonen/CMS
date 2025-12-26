<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>Bilginet Mini Revotas</title>
	<link rel="stylesheet" href="default.css" TYPE="text/css">
	<META HTTP-EQUIV="Content-Type" CONTENT="text/html;charset=UTF-8">
	<script type="text/javascript" language="javascript" src="jquery.js"></script>
	<script type="text/javascript" language="javascript" src="jquery.dataTables.min.js"></script>
</head>
<body>
	<%
		String activeTab = "home";
		
		if(request.getParameter("a") != null)
		{
				String param = request.getParameter("a");
				
				if(param.equals("campaigns"))
					activeTab = "campaigns";
				else if(param.equals("reports"))
					activeTab = "reports";
				else if(param.equals("help"))
					activeTab = "help";
		}
	%>
	<div id="wrapper">
	<ul id="tabnav">
				<li>
					<a class="<%if(activeTab.equals("home"))out.println("active");%>" href="home.jsp?a=home">Hesap Özeti</a>
				</li>
				<li>
					<a class="<%if(activeTab.equals("campaigns"))out.println("active");%>" href="campaigns.jsp?a=campaigns">Kampanyalar</a>
				</li>
				<li>
					<a class="<%if(activeTab.equals("reports"))out.println("active");%>" href="reports.jsp?a=reports">Raporlar</a>
				</li>
				<li>
					<a class="<%if(activeTab.equals("help"))out.println("active");%>" href="help.jsp?a=help">Yardım</a>
				</li>
			</ul>
			
		<div id="container">
			
			
			<div id="main-container">