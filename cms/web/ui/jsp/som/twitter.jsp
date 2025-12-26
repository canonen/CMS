<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="java.util.ArrayList"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>New Campaign</title>
</head>
<body>
</body>
</html>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="java.util.ArrayList,javax.servlet.http.HttpServletRequest,javax.servlet.http.HttpSession"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title></title>
</head>
<body>	
<%
		String referer 	  = "";
		HttpSession scope = request.getSession(false);
		
		if(scope.getAttribute("referer") != null)
		{
			scope.removeAttribute("referer");
		%>
			<script type="text/javascript">
			window.opener.location.href = '/cms/ui/jsp/home/welcome.jsp';
			window.opener.focus();
			self.close();
			</script>
		<%
		} else {
			%>
				<script type="text/javascript">
				window.opener.location.href = 'home.jsp';
				window.opener.focus();
				self.close();
				</script>
			<%
			
		}

%>
</body>
</html>