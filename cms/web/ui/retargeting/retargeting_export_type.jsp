<%@ page
	language="java"
	import="
			java.sql.DriverManager,
			java.sql.*,
			java.util.Calendar,
			java.util.Date,java.io.*,
			java.text.DecimalFormat,
			java.math.BigDecimal,
			java.text.NumberFormat,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%> 
<%

String cust_id = request.getParameter("cust_id");

if(cust_id==null)
	return;


%>

 <!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <script src="https://apis.google.com/js/api.js"></script>
  <title>Retargeting Type</title>
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
  
    
   input[type="radio"] {
    	display: none;
    
    }
 
    input[type="radio"]:checked + .bbox {
      color:#fff;
      background-color: #59C8E6 ;
    }
    
   .btn-app2{ 
   		border-radius: 3px;
	    padding: 15px 5px;
	    width: 100%;
	  
	    text-align: center;
	    color: #666;
	    border: 1px solid #ddd;
	    background-color: #f4f4f4;
	    font-size: 16px;
    }
    .btn-app2 > .fa, .btn-app2 > .glyphicon, .btn-app2 > .ion {
	    font-size: 40px;
	    line-height: 50px;
	    display: block;
	}
	.bg{background-color:#007e90;}
	.blabel{width: 100%;}
	
  </style>
</head>
<body class="hold-transition" style="background-color:#f1f1f1;">

<section class="content-header" >
	 <div class="box box-solid">
            <div class="box-header with-border">
					 <div class="col-md-6"><h3>Retargeting Account</h3></div>
					 
			
			 </div>
     </div>
	 
</section>
	
	
 <section class="content" style="margin-left:20px;margin-right:20px;">
     
 
	   <div class="row"  >
	   		<div class="box box-primary" >
					
					<div class="box-body">
						  <div id="button-box" class="row">
							 <div style="display:none;" class="col-md-2 col-xs-4 facebook-clone"> 
							 		  	<label for="r1" class="blabel"> 
									 		<input type="radio" name="user">  
									 	  	<a class="btn btn-app2 bbox ">
							                	<i class="fa fa-facebook-f"></i>Facebook
							             	 </a>
							           </label>
									    
							 </div>
							 <div style="display:none;" class="col-md-2 col-xs-4 google-clone"> 
							 
							 		  	<label for="r2" class="blabel"> 
									 		<input type="radio" name="user">  
									 	  	<a class="btn btn-app2 bbox ">
							                	<i class="fa fa-google"></i>Google
							             	 </a>
							           </label>
									    
							 </div>
						 </div>
					</div>
					<div class="fa-3x" id="next-loader" align="center"><i class="fa fa-spinner fa-pulse"></i></div>
				    <div id="next-button" class="box-body" align="center" style="display: none;">
					 	 <button onclick="selectuser()" class="btn btn-flat b_mavi c_beyaz">
					 	 	Next<i class="glyphicon glyphicon-triangle-right"></i>
					 	 </button>
				 	</div>
			
			 </div>
	   </div>
	   
 </section>
 
 <script type="text/javascript">
     
function selectuser() {
    var input = document.querySelector('input[name=user]:checked');
    var userId = input.getAttribute('user_id');
    var userType = input.getAttribute('user_type');
	var refresh_token = input.getAttribute('refresh_token');
    window.location = 'https://cms.revotas.com/cms/ui/jsp/export/retargeting_list.jsp?user_id='+userId+'&user_type='+userType+'&refresh_token='+refresh_token;
}

fetch('https://cms.revotas.com/cms/ui/retargeting/get_account_list.jsp?cust_id=<%=cust_id%>')
.then(function(resp){return resp.json()})
.then(function(resp) {
    var i=0;
	resp.forEach(function(element) {
        var userId = element.userId;
        var userName = element.userName;
        var refreshToken = element.refreshToken;
        var type = element.userType;
        var clonedButton = document.querySelector('.'+type+'-clone');
		if(clonedButton) {
			clonedButton = clonedButton.cloneNode(true);
			clonedButton.classList.remove(type+'-clone')
			clonedButton.style.display = 'block';
			clonedButton.querySelector('input').id = 'user-'+i;
			clonedButton.querySelector('input').setAttribute('user_id', userId);
			clonedButton.querySelector('input').setAttribute('user_type', type);
			clonedButton.querySelector('input').setAttribute('refresh_token', refreshToken);
			clonedButton.querySelector('label').setAttribute('for', 'user-'+i);
			clonedButton.querySelector('.bbox').innerHTML = type === 'facebook' ? '<i class="fa fa-facebook-f"></i>' + userName : '<i class="fa fa-google"></i>' + userName;
			document.getElementById('button-box').appendChild(clonedButton);
			i++;
		}
    });
    document.getElementById('next-loader').style.display = 'none';
    document.getElementById('next-button').style.display = 'block';
});
 
 </script>

<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/bootstrap.min.js"></script>
<script src="assets/js/adminlte.min.js"></script>
 <!-- FastClick -->
<script src="assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="assets/js/demo.js"></script>

</body>
</html>

 