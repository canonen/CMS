<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			javax.servlet.*,javax.servlet.http.*,
			java.util.*,java.net.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%@ include file="header.jsp"%>

<HTML>

<HEAD>
	<TITLE>Your session has expired!</TITLE>
	<BASE target="_self">
	<LINK rel="stylesheet" href="/cms/ui/ooo/style.css" type="text/css">
	<script type="text/javascript">
	
		var count = 10;

		var counter = setInterval(timer, 1000); 

		function timer()
		{
		  count=count-1;
		  if (count <= 0)
		  {
		     clearInterval(counter);
		     window.parent.location.href = "https://login.revotas.com";
		  }

		  document.getElementById("countdown").innerHTML = count;
		}

	</script>
	
</HEAD>

<BODY>
	<div style="text-align:center;margin:10px auto;padding:5px;"><img src="https://cms.revotas.com/cms/ui/ooo/images/nav/revotaslogo.png"></div>
	<div style="text-align:center;margin:10px auto;font-size:18px;color:#FF8821;padding:5px;">Your session has expired!</div>
	<div style="text-align:center;margin:10px auto;font-size:14px;color:#404040;padding:5px;">Your have been disconnected due to inactivity. Please login again to your system to continue work.</div>
	<div style="text-align:center;margin:10px auto;font-size:14px;color:#404040;padding:5px;">You are being redirected automatically after <span style="font-weight:bold;"><span id="countdown" style="width:20px;">10</span></span> seconds. If you would like to go faster, <a style="font-size:14px;" href="http://login.revotas.com">click here.</a></div>
	
</BODY>

</HTML>
