<%@ page
	language="java"
	import="org.json.JSONObject,
	        com.restfb.json.JsonArray,
	        com.facebook.ads.sdk.AdAccount,
	        com.facebook.ads.sdk.CustomAudience"
	contentType="text/html;charset=UTF-8"
%> 
 <%
response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
 %>

<% String sCustId = request.getParameter("cust_id");
   String revotasUser=request.getParameter("revotas_user");
   String pageStatus=request.getParameter("page_status");
   
   
 /*  
 if(sCustId==null || revotasUser==null)
	   return;
 */
%>

 <!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
</head>
 <body>

 <script type="text/javascript">
 function statusChangeCallback(response) {
	   
		var userID="";
		var status="";
  if (response.status === 'connected') {
	                
			 userID       = response.authResponse.userID;
			 status="logged";
			 
		          } 
	    else {
	    	 status="logout";
	    	
			 }
  window.location.href="https://cms.revotas.com/cms/ui/jsp/export/retargeting_list.jsp?fbLogin="+status+"&fbUser="+userID;	    
	}
 function checkLoginState() {
		FB.getLoginStatus(function(response) {
			statusChangeCallback(response);
		});
	}

	window.fbAsyncInit = function() {
		FB.init({
			appId : '278434559502747',
			cookie : true,
			xfbml : true,
			version : 'v3.2'
		});

		FB.getLoginStatus(function(response) {
			statusChangeCallback(response);
		});

	};

(function(d, s, id) {
		var js, fjs = d.getElementsByTagName(s)[0];
		if (d.getElementById(id))
			return;
		js = d.createElement(s);
		js.id = id;
		js.src = "https://connect.facebook.net/en_US/sdk.js";
		fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));
 

 </script> 
<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->

</body>
</html>