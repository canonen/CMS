<style type="text/css">
a {
	outline: none;
}
ul#tabnav {
	text-align: right; 
	margin: 0 0;
				padding: 3px 0;	
	list-style-type: none;
	border-bottom:1px solid #00759B;
}

ul#tabnav li { 
	display: inline;
}

#tabnav li.active { 
	border-bottom: 1px solid #fff; 
	background-color: #fff; 
}

#tabnav li a.active  { 
	background-color: #fff; 
	color: #000; 
	position: relative;
	top: 1px;
	padding-top: 4px; 
	font-weight:bold;
	
}

ul#tabnav li a { 
	padding: 3px 15px; 
	border: 1px solid #00759B; 
	background-color: #F1F1F1; 
	color: #9F9E9E; 
	margin-right: 0px; 
	text-decoration: none;
	border-bottom: none;
	font-size: 13px;
	font-weight:normal;
	border-radius: 5px 5px 0 0;
}

ul#tabnav a:hover {
	background: #fff; 
}
.noClassPassiveTab {
	border:none !important;
	color:#666666 !important;
	font-weight:bold !important;
}
	
</style>
<script type="text/javascript" src="../../js/report/jquery-1.5.1.js"></script>
<script>
 	$(document).ready(function () {
		$('.loader').click(function() {
			
			$("#loader").show();
		});
	});
</script>


<div style="margin-bottom:10px"><img id=loader src="http://www.revotas.com/bigloader.gif" style="display:none;"/></div>
<!--
<div id="new-camp-sec">
	<a href="home.jsp"><span>Home</span></a>
	<a href="campaigns.jsp"><span>Campaigns</span></a>
	<a href="reporting.jsp" class="loader"><span>Reporting</span></a>
	<a href="accounts.jsp"><span>Accounts</span></a>
	<div style="clear:both"></div>
</div>
-->