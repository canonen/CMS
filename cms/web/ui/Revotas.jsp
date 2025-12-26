<%@ page language="java" 
              import="java.net.*,
	   		java.util.ArrayList,
	   		java.text.SimpleDateFormat,
			java.sql.*,
			java.util.Calendar,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
			java.util.Locale,
			java.io.*"
	contentType="text/html;charset=UTF-8"
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <meta charset="utf-8">
  <title>WebPush Permission</title>
  <meta name="description" content="This page demonstrates the use of the Realtime Web Push Notitications using GCM">
  <meta name="author" content="Realtime">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="//fonts.googleapis.com/css?family=Raleway:400,300,600" rel="stylesheet" type="text/css">

  
  <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script> 
  
<!--  offline 
<script src="https://www.gstatic.com/firebasejs/5.0.2/firebase.js"></script>
<script src="https://revotrack.revotas.com/trc/webpush-test/revotas_popup.js"></script>
--> 

</head>

<body>


<div class="container">
    <div class="row">
      <div align="center" style="margin-top: 120px">

        <br>
     <img alt="" src="https://www.revotas.com/tr/wp-content/uploads/2017/06/digitalmarketing_ana.jpg">              
      </div>
     <div align="center" style="font-family: Arial,Helvetica Neue,Helvetica,sans-serif;font-size: 15px"> 
     
     <h3>Revotas Web Push Notification Process</h3>
     </div>

 
      
      
    </div>

  </div>



<!--------- Revotas WebPush ------------>
<link href="https://revotrack.revotas.com/trc/webpush/revotas_popup.css" rel="stylesheet" type="text/css">
<div id="a1"></div>
<script type="text/javascript">
var rvts = 'tst';
(function() {
var _rTag = document.getElementsByTagName('script')[0];
var _rcTag = document.createElement('script');
_rcTag.type = 'text/javascript';
_rcTag.async = 'true';
_rcTag.src = ('https://revotrack.revotas.com/trc/webpush/revotas_popup.js');
_rTag.parentNode.insertBefore(_rcTag,_rTag);
})();
</script>
<!--------- Revotas WebPush ------------>




</body>
</html>