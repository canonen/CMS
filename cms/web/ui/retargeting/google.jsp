<% String sCustId = request.getParameter("cust_id");
   String revotasUser=request.getParameter("revotas_user");
   String redirect_to=request.getParameter("redirect_to");
   
   if(sCustId==null || revotasUser==null)
	   return;
%>

 <!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <script src="https://apis.google.com/js/api.js"></script>
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
  <link rel="stylesheet" href="assets/css/google.css">

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
					 <div class="col-md-6"><h3>Google Retargeting</h3></div>
			 </div>
     </div>
	 
</section>
		<!-- <div id="login_fb" style="padding-left:20px;display: none">
            Please login :
			<fb:login-button scope="public_profile,email"onlogin="checkLoginState();">
			</fb:login-button>
    		
    		</div>
       <div id="logout_fb" style="padding-left:20px;display: none">

			<button onclick="logout()">Logout</button>&nbsp;&nbsp;From Facebook!

		</div> -->
		<div style="padding-left: 20px; display: none;">
			Please login:<button class="loginBtn loginBtn--google" id="authorize-button">Login</button>
		</div>
		<div style="padding-left: 20px; display: none;">
			<button id="signout-button" style="margin-right: 5px;">Sign Out</button>Logout from Google!
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
					          <div id="google_user" style="padding-left:40px"></div> 
					           <br>  
							</tr>
							</thead>
							<tbody>
							 <div id="ad_accounts" style="padding-left:40px;">
							 
							 <b>Advertising Account</b>
							 <br>
							 <select id="adAccounts"></select>
							 <br><br>
					 
		<div style="width:260px">
		<button type="button"  class="btn btn-block btn-info btn-xs" onclick="updateSettings()">Update Google Retargeting Settings</button>
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

let authorizeButton = document.getElementById('authorize-button');
let signoutButton = document.getElementById('signout-button');
let accountSelect = document.getElementById('adAccounts');
let cust_id=<%=sCustId%>;
let revotas_user='<%=revotasUser%>';
let code;
let user_id;
let accountIds;
let accountNames;
let refresh_token;
let redirect_to='<%=redirect_to%>';

gapi.load('auth2', initClient);

let auth2;
let user_name;

async function initClient() {
	auth2 = await gapi.auth2.init({
			clientId: '374776364298-spg38ncante486ctc4dhfdfbqegi1l5k.apps.googleusercontent.com',
			scope: 'https://www.googleapis.com/auth/adwords'
	});
	auth2.isSignedIn.listen(updateSigninStatus);
	updateSigninStatus(auth2.isSignedIn.get(), true);
	authorizeButton.onclick = handleAuthClick;
	signoutButton.onclick = handleSignoutClick;
}

async function updateSigninStatus(isSignedIn, alreadyLoggedIn) {
	if (isSignedIn) {
		user_id = auth2.currentUser.get().getId();
        let googleUserName = auth2.currentUser.get().getBasicProfile().getName();
		user_name = googleUserName; 
        authorizeButton.parentElement.style.display = 'none';
        signoutButton.parentElement.style.display = 'block';
        document.getElementById('google_user').innerText = 'The Google user '+ googleUserName + ' is authenticated with Revotas.';
		if(alreadyLoggedIn) {
			let response = await fetch('https://cms.revotas.com/cms/ui/retargeting/get_google_refresh_token.jsp?user_id='+user_id)
			.then(resp=>resp.json());
			refresh_token = response.refresh_token;
			const { accountList } = await fetch('https://rcp3.revotas.com/rrcp/GoogleApiServlet/fetchAccountList?refresh_token=' + refresh_token)
			.then(resp=>resp.json());
			fillAccountList(accountList);
		} else {
			let addSettings = false;
			let response = await fetch('https://cms.revotas.com/cms/ui/retargeting/get_google_refresh_token.jsp?user_id='+user_id)
			.then(resp=>resp.json());
			if(!response.success) {
					response = await fetch('https://rcp3.revotas.com/rrcp/GoogleApiServlet/authGoogle?code=' + code)
					.then(resp=>resp.json());
					addSettings = true;
			}
			refresh_token = response.refresh_token;
			if(addSettings)
				await updateSettings();
			if(redirect_to==='google') {
				window.location = 'https://dev.revotas.com/cms/ui/retargeting/retargeting_export_type.jsp?cust_id=' + cust_id + '&revotas_user=' + revotas_user + '&selected=google';
				return;
			}
			const { accountList } = await fetch('https://rcp3.revotas.com/rrcp/GoogleApiServlet/fetchAccountList?refresh_token=' + refresh_token)
			.then(resp=>resp.json());
			fillAccountList(accountList);
		}
	} else {
        authorizeButton.parentElement.style.display = 'block';
        signoutButton.parentElement.style.display = 'none';
	}
}
  
async function handleAuthClick(event) {
	const response = await auth2.grantOfflineAccess();
	code = response.code;
	/*console.log('user_id', auth2.currentUser.get());
	user_id = auth2.currentUser.get().getId();
	let addSettings = false;
	let response = await fetch('https://cms.revotas.com/cms/ui/retargeting/get_google_refresh_token.jsp?user_id='+user_id)
    .then(resp=>resp.json());
	if(!response.success) {
			response = await fetch('https://rcp3.revotas.com/rrcp/GoogleApiServlet/authGoogle?code=' + code)
			.then(resp=>resp.json());
			addSettings = true;
	}
	refresh_token = response.refresh_token;
	if(addSettings)
		updateSettings();
	if(redirect_to==='google') {
		window.location = 'https://dev.revotas.com/cms/ui/retargeting/retargeting_export_type.jsp?cust_id=' + cust_id + '&revotas_user=' + revotas_user + '&selected=google';
		return;
	}
	const { accountList } = await fetch('https://rcp3.revotas.com/rrcp/GoogleApiServlet/fetchAccountList?refresh_token=' + refresh_token)
	.then(resp=>resp.json());
	fillAccountList(accountList);*/
	
}

function clearAccountList() {
	while (accountSelect.hasChildNodes()) {
		accountSelect.removeChild(accountSelect.firstChild);
	}
}

function fillAccountList(accountList) {
    accountIds = accountList.map(val => val.id).join(',');
	accountNames = accountList.map(val => val.name).join(',');
	clearAccountList();
	for(var i=0;i<accountList.length;i++) {
		let account = accountList[i];
		let newOption = document.createElement('option');
		newOption.value = account.id;
		newOption.innerText = account.name;
		accountSelect.appendChild(newOption);
	}
}

function handleSignoutClick(event) {
    gapi.auth2.getAuthInstance().signOut().then(function(resp) {
		document.getElementById('google_user').innerText = '';
		user_id = null;
		accountIds = null;
		accountNames = null;
		refresh_token = null;
		clearAccountList();
    });
}

async function updateSettings()
{
	const { accountList } = await fetch('https://rcp3.revotas.com/rrcp/GoogleApiServlet/fetchAccountList?refresh_token=' + refresh_token)
	.then(resp=>resp.json());
	fillAccountList(accountList);
	if(!user_id || !accountIds || !accountNames || !refresh_token)
		return;
	const params = {cust_id,revotas_user,user_id,user_name,accountIds,accountNames,refresh_token};
	let paramString = '?';
	for(let param in params)
		paramString += param + '=' + params[param] + '&';
	fetch('https://cms.revotas.com/cms/ui/retargeting/google_user_info_save.jsp' + paramString);
}
/*
function saveAdAccounts(custid, revotas_user, acID, acName, guser)
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
				   + "&user_id="+guser
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
*/
</script>


</body>
</html>

 