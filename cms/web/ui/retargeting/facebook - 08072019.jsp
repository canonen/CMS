<%@ page
	language="java"
	import="org.json.JSONObject,
	        com.restfb.json.JsonArray,
	        com.facebook.ads.sdk.AdAccount,
	        com.facebook.ads.sdk.CustomAudience"
	contentType="text/html;charset=UTF-8"
%> 

<% String sCustId = request.getParameter("cust_id");
   String revotasUser=request.getParameter("revotas_user");
   
   if(sCustId==null || revotasUser==null)
	   return;
%>

 <!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Retargeting | Facebook Retargeting</title>
  <!-- Tell the browser to be responsive to screen width -->
  <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
 
  <link rel="stylesheet" href="assets/css/bootstrap.min.css">
   <link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">
  <link rel="stylesheet" href="assets/css/font-awesome.min.css">
 
  <link rel="stylesheet" href="assets/css/ionicons.min.css">
 
  <link rel="stylesheet" href="assets/css/AdminLTE.css">
  <link rel="stylesheet" href="assets/css/Style.css">
  <link rel="stylesheet" href="assets/css/DataTable/dataTables.bootstrap.min.css">
  <link rel="stylesheet" href="assets/css/skin-blue.min.css">

  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
  <!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->

  <!-- Google Font -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">
  
  <style>
  .table_status{
  	font-size: 12px;
  	line-height:32px;
    text-align: center;
    color: #59C8E6 ;  	
  }
  td{font-size: 12px;
      vertical-align:middle !important; 
      border:1px solid #f2f2f2 !important;
  }

  th{   font-size: 12px;
        background-color:#f2f2f2 ;
        border:1px solid #ddd !important;
      vertical-align:middle !important; 
  }
  </style>
</head>
<body class="hold-transition" style="background-color:#f1f1f1;">

<section class="content-header" >
	 <div class="box box-solid">
            <div class="box-header with-border">
					 <div class="col-md-6"><h3>Facebook Retargeting</h3></div>
					 
			
			 </div>
     </div>
	 
</section>
		<div id="login_fb" style="padding-left:20px;display: none">
            Please login :
			<fb:login-button scope="public_profile,email"onlogin="checkLoginState();">
			</fb:login-button>
    		
    		</div>
       <div id="logout_fb" style="padding-left:20px;display: none">

			<button onclick="logout()">Logout</button>&nbsp;&nbsp;From Facebook!

		</div>
		
   
 <section class="content" style="margin-left:20px;margin-right:20px;">
     
      <div class="row">
     
       
           
      </div>
 
	   <div class="row"  >
	   		<div class="box">
					 
					<div class="box-body">
						 <table id="example1" class="table table-bordered table-striped table-hover" >
							<thead>
							<tr>
					          <h4 style="margin-left:40px;"><b>Integration Settings</b></h4>
					          <div id="facebook_user" style="padding-left:40px"></div> 
					           <br>  
							</tr>
							</thead>
							<tbody>
							 <div id="ad_accounts" style="padding-left:40px;">
							 
							 <b>Advertising Account</b>
							 <br>
							 <select id="adAccounts"></select>
							 <br><br>
		<input type="hidden" id="accountIDHide" name=""accountIDHide"" value="">
		<input type="hidden" id="accountNameHide" name=""accountNameHide"" value="">
		<input type="hidden" id="FacebookUser" name=""FacebookUser"" value="">
					 
		<div style="width:260px">
		<button type="button"  class="btn btn-block btn-info btn-xs" onclick="updateSettins()">Update Facebook Retargeting Settings</button>
		</div>
		
							 
							 </div>
							 
							 </tbody>
							 
						  </table>
						 
					</div>
				  </div>
	   </div>
	   
 </section>
 


<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/bootstrap.min.js"></script>
<script src="assets/js/adminlte.min.js"></script>
 <!-- FastClick -->
<script src="assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="assets/js/demo.js"></script>

<script type="text/javascript">

function statusChangeCallback(response,loginCeheck) {
	
	var userID="";
	
			if (response.status === 'connected') {
                
				userID       = response.authResponse.userID;
				
				//console.log(response);
				
				connectedFB(userID,loginCeheck);
				

			} else {

				
               disconnectedFB();
				

			}
		}

function checkLoginState() {
			FB.getLoginStatus(function(response) {
				statusChangeCallback(response,"true");
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
				statusChangeCallback(response,"false");
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



function connectedFB(userid,loginCeheck)
{
	
	document.getElementById('logout_fb').style.display = "block";
	document.getElementById('login_fb').style.display = "none";
	
	FB.api('/'+userid+'', function(response) {
		
		document.getElementById('facebook_user').innerText = 'The Facebook user '+ response.name + " is authenticated with Revotas.";
		
		getAdAccounts(userid,loginCeheck);
	});
	
}
function getAdAccounts(userid,loginCeheck)
{
	
	FB.api('/'+userid+'/adaccounts?fields=name', function(response) {
	
		var data = response.data;
		
		var option_adaccounts="";
		
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
				 option_adaccounts+="<option value=\'"+accountID+"\'>"+accountName+"</option>";
				
				}
			
		}
		accountIDS = accountIDS.substring(0,accountIDS.length-1);
		accountNames=accountNames.substring(0,accountNames.length-1);
		
		document.getElementById('adAccounts').innerHTML=option_adaccounts;
		document.getElementById('accountIDHide').value=accountIDS;
		document.getElementById('accountNameHide').value=accountNames;
		document.getElementById('FacebookUser').value=userid;
		
		if(loginCeheck=="true")
			{
			
			saveAdAccounts();
			}
		
	});
	
	
}
function disconnectedFB()
{
	
	document.getElementById('login_fb').style.display = "block";	
	document.getElementById('facebook_user').innerHTML="";
	document.getElementById('adAccounts').innerHTML="";
	
}

function logout() {
	FB.getLoginStatus(function(response) {
		if (response.status == 'connected')
			FB.logout(function(response) {
					document.getElementById('logout_fb').style.display = "none";
					document.getElementById('login_fb').style.display = "block";
					document.getElementById('facebook_user').innerHTML="";
					document.getElementById('adAccounts').innerHTML="";
					
							});
				else{
					//window.location.href = redirectUrl;
					console.log("Error. Logout on Facebook");
				}
			});
	
	
	
}

function updateSettins()
{
	
   saveAdAccounts();	
}

function saveAdAccounts()
{
	
	var custid=<%=sCustId%>;
	var revotas_user='<%=revotasUser%>';
	var acID=document.getElementById('accountIDHide').value;
	var acName=document.getElementById('accountNameHide').value;
	var fuser=document.getElementById('FacebookUser').value;
	
	if(!(acID=="" || acName=="" ||fuser==""))
		{
		
		
		//send to database	
		
	    
		var http = new XMLHttpRequest();
        var url = "https://cms.revotas.com/cms/ui/retargeting/user_info_save.jsp"; 
		var params = "cust_id="+ custid
				   + "&user_id="+fuser
				   + "&addAccounts="+acID
				   + "&accountNames="+acName
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
		
		
		
		}
	
}
</script>


</body>
</html>

 