<%@  page language="java"
	import="java.net.*,
	   		java.util.ArrayList,
	   		java.text.SimpleDateFormat,
			java.sql.*,
			java.util.Calendar,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*
            "
	contentType="text/html;charset=UTF-8"%>
<%
	response.setHeader("Access-Control-Allow-Origin", "*");
	response.setHeader("Access-Control-Allow-Methods",
			" GET, POST, PATCH, PUT, DELETE, OPTIONS");
	response.setHeader("Access-Control-Allow-Headers",
			"Origin, Content-Type, X-Auth-Token");
%>

<%
String loginStatus = request.getParameter("loginStatus");
String userID      = request.getParameter("userId");
String revotasUser = request.getParameter("revotas_user");


if(loginStatus==null || userID==null || revotasUser==null)
	return;


%>
 <!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
</head>
 <body>
 <script type="text/javascript">
 
 var user='<%=userID%>';
 var status='<%=loginStatus%>';
 var revotas_user='<%=revotasUser%>';
 
var cookieCheck=getCookie(revotas_user); 
 
 if(cookieCheck!="")
	 {
	 var val= '\''+revotas_user+'\'' + '=; expires=Thu, 01-Jan-70 00:00:01 GMT;';
     document.cookie =val;
     setCookie(revotas_user, status, "3",".cms.revotas.com");
	 }
 else
	 {
	 
	 setCookie(revotas_user, status, "3",".cms.revotas.com");
	 }
 function getCookie(cname) {
	    var name = cname + "=";
	    var decodedCookie = decodeURIComponent(document.cookie);
	    var ca = decodedCookie.split(';');
	    for(var i = 0; i <ca.length; i++) {
	        var c = ca[i];
	        while (c.charAt(0) == ' ') {
	            c = c.substring(1);
	        }
	        if (c.indexOf(name) == 0) {
	            return c.substring(name.length, c.length);
	        }
	    }
	    return "";
	}

 function setCookie(name,value,days,ckie_dmn) {
	    var expires = "";
	    if (days) {
	        var date = new Date();
	        date.setTime(date.getTime() + (days*24*60*60*1000));
	        expires = "; expires=" + date.toUTCString();
	    }
	    document.cookie = name + "=" + (value || "")  + expires +";domain="+ckie_dmn+ "; path=/";
	}

 
 
 
 
 
 
 </script>
 </body>
 </html>