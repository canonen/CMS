<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Facebook response</title>
	<script type="text/javascript">
	 	var token = self.document.location.hash.substring(1).split(/=/)[1].split(/&/)[0];
	 	if(token.length > 0)
	 	{
	 		window.location.href = "ManageAccounts?type=facebook&access_token="+token;	
	 	} else {
	 		window.location.href = "error.jsp?type=COULD_NOT_GET_ACCESS_TOKEN_FROM_FACEBOOK_FBHANDLER_JSP";
	 	}
	</script>
</head>
<body>
	Redirecting...
</body>
</html>