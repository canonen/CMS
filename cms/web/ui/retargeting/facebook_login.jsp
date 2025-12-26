<%@page import="org.json.JSONObject"%>
<%@page import="com.restfb.json.JsonArray"%>
<%@page import="com.facebook.ads.sdk.AdAccount"%>
<%@page import="com.facebook.ads.sdk.CustomAudience"%>


<% String sCustId = request.getParameter("cust_id");
   String revotasUser=request.getParameter("revotas_user");
   
   if(sCustId==null || revotasUser==null)
	   return;
%>


<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
<title>Facebook Login</title>
<meta charset="UTF-8">
</head>
<body>
		<div style="margin-left: 20px; margin-top: 20px">
			<div id="login_fb" style="display: none">

			Facebook Login :
			<fb:login-button scope="public_profile,email"onlogin="checkLoginState();">
			</fb:login-button>
    		
    		</div>

		<div id="status"></div>
		<br>
		<div id="logout_fb" style="display: none">

			<button onclick="logout()">Logout</button>

		</div>
	 </div>

	<script>
function statusChangeCallback(response) {
   
	var userID="";
	
			if (response.status === 'connected') {
                
				userID       = response.authResponse.userID;
				
				//console.log(userID);
				
				doOperation(userID);
				

			} else {

				document.getElementById('login_fb').style.display = "block";

				//document.getElementById('status').innerHTML = 'Please login';

			}
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

function doOperation(userid) {

			document.getElementById('login_fb').style.display = "none";
			document.getElementById('logout_fb').style.display = "block";

			FB.api('/'+userid+'', function(response) {
				
				document.getElementById('status').innerHTML = 'Welcome '+ response.name + ", you logged in Facebook";
			});

			
			
getAcounts(userid);
function getAcounts(userid) {

	var custid=<%=sCustId%>;
	
				FB.api('/'+userid+'/adaccounts?fields=name', function(response) {
					                  
					var data = response.data;
					
					//Ad Accounts ID
					var accountIDS="";
                    var accountID="";
                    
                    //Ad Accounts Name
                    var accountNames="";
                    var accountName="";
                    
                    
					for (var i = 0; i < data.length; i++) {
						
						accountID = data[i].id;
						accountID=accountID.substring(4,accountID.length);
						
						accountName=data[i].name;
						
						 if(accountID.length!=8)
							{		 
							accountIDS+=accountID+",";
							accountNames+=accountName+",";
							
							}
						
					}
					accountIDS = accountIDS.substring(0,accountIDS.length-1);
					accountNames=accountNames.substring(0,accountNames.length-1);
					
					//console.log(accountIDS+" "+accountNames);
					
				//send to database	
					
				    var revotas_user='<%=revotasUser%>';
					var http = new XMLHttpRequest();
			        var url = "https://cms.revotas.com/cms/ui/retargeting/user_info_save.jsp"; 
					var params = "cust_id="+ custid
							   + "&user_id="+userid
							   + "&addAccounts="+accountIDS
							   + "&accountNames="+accountNames
							   + "&revotas_user="+revotas_user;
                               
					http.open("POST", url, true);
					http.setRequestHeader("Content-type",
							"application/x-www-form-urlencoded; charset=UTF-8");

					http.onreadystatechange = function() {
						if (http.readyState == 4 && http.status == 200) {
							var serverResponse = http.responseText;

						}
					}
                 	http.send(params);
                 	
				});

			}
		}

function logout() {
			FB.getLoginStatus(function(response) {
				if (response.status == 'connected')
					FB.logout(function(response) {
							document.getElementById('logout_fb').style.display = "none";
							document.getElementById('login_fb').style.display = "block";
							document.getElementById('status').innerHTML = '';
									});
						else{
							//window.location.href = redirectUrl;
							console.log("Error. Logout on Facebook");
						}
					});
		}
	</script>
</body>
</html>