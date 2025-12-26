<%@page import="org.json.JSONObject"%>
<%@page import="com.restfb.json.JsonArray"%>
<%@page import="com.facebook.ads.sdk.AdAccount"%>
<%@page import="com.facebook.ads.sdk.CustomAudience"%>


<% 
       String sCustId="723";
/*
       String sCustId    = request.getParameter("cust_id");
      
	   String file_url=  request.getParameter("file_url");
	   String action_type= request.getParameter("action_type");
	   String audience_id=  request.getParameter("audience_id");
	   String export_id= request.getParameter("export_id");
	   String account_id=request.getParameter("account_id");

	 if(file_url==null || action_type==null || audience_id==null || export_id==null || account_id==null)
	   {
	      return;
	   }
*/
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
				
				//doOperation(userID);
				
                uploadAudience();
                
			} else {

				document.getElementById('login_fb').style.display = "block";

				//document.getElementById('status').innerHTML = 'Please login';

			}
		}
		
function uploadAudience()
{

	FB.api(
		    "/6118330550944/users",
		    "POST",
		    {
		        "payload": "{\"schema\":[\"EMAIL\"],\"data\":[[\"9b431636bd164765d63c573c346708846af4f68fe3701a77a3bdd7e7e5166254\"],[\"8cc62c145cd0c6dc444168eaeb1b61b351f9b1809a579cc9b4c9e9d7213a39ee\"],[\"4eaf70b1f7a797962b9d2a533f122c8039012b31e0a52b34a426729319cb792a\"],[\"98df8d46f118f8bef552b0ec0a3d729466a912577830212a844b73960777ac56\"]]}"
		    },
		    function (response) {
		      if (response && !response.error) {
		        console.log("succes");
		      }
		      console.log(response);
		    }
		   
		);

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
				version : 'v3.3'
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
      FB.api('/'+userid+'/1084999661512561/CustomAudience', function(response) {
				
				console.log(response);
			});
			
			
//getAcounts(userid);

		}
		
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
					
					console.log(accountIDS+" "+accountNames);
					
				//send to database	
					
					var http = new XMLHttpRequest();
					var url = "https://dev.revotas.com/cms/ui/retargeting/user_info_save.jsp"; 
					var params = "cust_id="+ custid
							   + "&user_id="+userid
							   + "&addAccounts="+accountIDS
							   + "&accountNames="+accountNames;
                               
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