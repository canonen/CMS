<%

/*
cached		1	eDesign Optimizer:  reports-edo-link.php
action		Run+Report	All Reports
iframe		1	All Reports; use for both iFrame AND POPUP
Choice of 1* of the following dependent on Unique ID Method Chosen			
1	X-PVIQ*	X-PVIQ header for campaign	Option for ANY of The Reports
2	message-id*	Message ID of the Campaign	Option for eDesign Optimizer & eContent Scorer Reports
3	custom_x*	Custom X-Header Value	Option for eDelivery Tracker Report only
	EDT_REPORTGROUP_ID	eDT Report Group ID	- Required if Using custom_x Parameter Otherwise Not Used.
	CLIENT_ID	PV Client ID	- Required if Using custom_x Parameter Otherwise Not Used.
*/

String sPVCached = "1";
String sPVAction = "Run+Report";

String sPVGetParameters = "cached=" + sPVCached + "&" +
						  "action=" + sPVAction;
%>

<html>
<head>
<title>Auto Login to pvIQ</title>
</head>
<body>

	<form name='frmUserCode' id='frmUserCode' method='post' action='<%=sPVActionURL%>'>
	        <input type='hidden' name='iframe' value='1'> <!-- must have for security (so user cannot browse PV site)  -->
            <input type='hidden' name='session' value='1'> <!-- must have for security (so user cannot retrieve username and password from report urls) -->
            <input type='hidden' name='cached' value='1'>
            <input type='hidden' name='action' value='Run+Report'>
            <input type=hidden value='<%=sPVuserId%>' name=username>
            <input type=hidden value='<%=sPVclientid%>' name=clientid>
            <input type=hidden value='<%=sPVpassword%>' name=password>  
            <input type=hidden value='LOGIN' name=submitbutton>  
	</form>
<script language="javascript">
	<!--
	document.frmUserCode.submit();
	-->
</script>
</body>
</html>

