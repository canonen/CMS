<%@  page language="java" import="java.net.*"
	contentType="text/html;charset=UTF-8"%>

<% String sCustId = request.getParameter("cust_id");
   String revotasUser=request.getParameter("revotas_user");
   
   if(sCustId==null || revotasUser==null)
	   return;
   String parameters="cust_id="+sCustId+"&revotas_user="+revotasUser;
%>
<!DOCTYPE html>
<html>
<head>
   <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Retargeting | Integrations</title>
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
/* Style the tab */
.tab {
	overflow: hidden;
	border: 1px solid #ccc;
	background-color: #f1f1f1;
}

/* Style the buttons inside the tab */
.tab button {
	background-color: inherit;
	float: left;
	border: none;
	outline: none;
	cursor: pointer;
	padding: 14px 16px;
	transition: 0.3s;
	font-size: 17px;
}

/* Change background color of buttons on hover */
.tab button:hover {
	background-color: #ddd;
}

/* Create an active/current tablink class */
.tab button.active {
	background-color: #ccc;
}

/* Style the tab content */
.tabcontent {
	display: none;
	padding: 6px 12px;
	border: 1px solid #ccc;
	border-top: none;
  </style>
</head>
<body class="hold-transition" style="background-color:#f1f1f1;">

	
	
	<section class="content-header" >
	 <div class="box box-solid">
            <div class="box-header with-border">
					 <div class="col-md-6"><h3>Integrations</h3></div>
					 
			
			 </div>
     </div>
	 
  </section>

 <section class="content" style="margin-left:20px;margin-right:20px;">
  <div class="box box-solid">
            <div class="box-header with-border">
	<div class="tab">
		<button class="tablinks" onclick="openCity(event, 'all_integrations')">All Integrations</button>
		<button id="enable_button" class="tablinks" onclick="openCity(event, 'enabled_integrations')">Enabled Integrations</button>

	</div>

	<div id="all_integrations" class="tabcontent">
		<ul style="list-style-type: none;">
          <li>
             <a href="https://rcp3.revotas.com/rrcp/ui/retargeting/facebook.jsp?<%= parameters%>"style="color: #100400; text-decoration: none;">
             <div text-align: center;>
              
               <img width="40" height="40" src="./images/facebook.png">
               Facebook Retargeting
            
             </div>  
              </a> 
          </li>
          <br>
		    <li>
             <a href="https://rcp3.revotas.com/rrcp/ui/retargeting/google.jsp?<%= parameters%>" style="color: #100400; text-decoration: none;">
             <div text-align: center;>
              
               <img width="40" height="40" src="./images/google.png">
               Google Retargeting
            
             </div>  
              </a> 
          </li>

		</ul>
	</div>

	<div id="enabled_integrations" class="tabcontent">
				<ul style="list-style-type: none;">
          <li>
   <a href="https://rcp3.revotas.com/rrcp/ui/retargeting/facebook.jsp?<%= parameters%>"style="color: #100400; text-decoration: none;">
             <div text-align: center;>
              
               <img width="40" height="40" src="./images/facebook.png">
               Facebook Retargeting
            
             </div>  
              </a> 
          </li>
<br>
		    <li>
             <a href="https://rcp3.revotas.com/rrcp/ui/retargeting/google.jsp?<%= parameters%>" style="color: #100400; text-decoration: none;">
             <div text-align: center;>
              
               <img width="40" height="40" src="./images/google.png">
               Google Retargeting
            
             </div>  
              </a> 
          </li>
 
		</ul>
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
	<script>
	
		function openCity(evt, cityName) {
			var i, tabcontent, tablinks;
			tabcontent = document.getElementsByClassName("tabcontent");
			for (i = 0; i < tabcontent.length; i++) {
				tabcontent[i].style.display = "none";
			}
			tablinks = document.getElementsByClassName("tablinks");
			for (i = 0; i < tablinks.length; i++) {
				tablinks[i].className = tablinks[i].className.replace(
						" active", "");
			}
			document.getElementById(cityName).style.display = "block";
			evt.currentTarget.className += " active";
		}
	
  setChoose("tablinks","enabled_integrations");	
	function setChoose(evt, cityName) {
		var i, tabcontent, tablinks;
		tabcontent = document.getElementsByClassName("tabcontent");
		for (i = 0; i < tabcontent.length; i++) {
			tabcontent[i].style.display = "none";
		}
		tablinks = document.getElementsByClassName("tablinks");
		for (i = 0; i < tablinks.length; i++) {
			tablinks[i].className = tablinks[i].className.replace(
					" active", "");
		}
		document.getElementById(cityName).style.display = "block";
		    document.getElementById('enable_button').className +=" active";
	}
	</script>

</body>
</html>
