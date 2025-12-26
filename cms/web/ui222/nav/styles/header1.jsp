<%@ page import="javax.servlet.http.*,
		 		 java.util.*"
			
%><%
	String imagePath = "../ui/framework/images";
	String loggedInAs = "OVALCA ADMIN";
	String logoutURL = "http://login.ovalca.com";
	String logoImage = "../ui/framework/images/header_elements/header_sys_right.gif";
	String logoWidth = "295";
	String title = "Ovalca Console v2.0";	
	String sitePopupURL = "sitePopupURL";
	String backgroundImage = "../ui/framework/images/header_elements/header_sys_middle.gif";
%><html>
<head>
<link rel="stylesheet" href="../ui/framework/css/stylesheet_admin_common_ie.css" type="text/css" />

<link rel="stylesheet" href="../ui/framework/css/stylesheet_admin_header_sys.css" type="text/css" />



<script language="JavaScript">
// handle to popup window
var popupWin;
function showSiteSelectionPopup(url) {
	var height = 420;
	var width = 440;
	var left = (screen.width - width) / 2;
	var top = (screen.height - height) / 2;
	var props = "resizable,scrollbars=yes,left=" + left + ",top=" + top + ",width=" + width + ",height=" + height;
	popupWin = window.open(url, "site_selector_popup", props);
	popupWin.focus();
}
</script>
</head>

<body bgcolor="000000" 
	topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0" 
	marginwidth="0" marginheight="0" background="<%=backgroundImage%>" >

<table width="100%" border="0" cellspacing="0" cellpadding="0" class="font-normal">
	<tr>
		<td width="6">
			<img src="<%=imagePath%>/misc/spacer.gif" border="0" alt="" width="6" height="21" /></td>
		<td nowrap width="100%" class="color-welcome-text">
			Logged in as <%=loggedInAs%>
			


			| <a href="<%= logoutURL %>" target="_top" class="welcome">Logout</a>


			<!-- | <a href="<%=sitePopupURL%>" class="welcome">Switch to Site...</a> -->

		</td>
		<td rowspan="2" align="right">
			<!--<img src="<%=logoImage%>" border="0" alt="" width="<%=logoWidth%>" height="49" />-->
						<IFRAME src="../jsp/cust/session_info.jsp" width="400" height="50" scrolling="no" frameborder="0" class="navLogo">
						[Your user agent does not support frames or is currently configured
						not to display frames. However, you may visit
						<A href="foo.html">the related document.</A>]
			</IFRAME> 	
			</td>
	</tr>
	<tr>
		<td width="6" nowrap>
			<img src="<%=imagePath%>/misc/spacer.gif" border="0" alt="" width="6" height="28" /></td>
		<td nowrap width="100%" class="font-context-name">
			<span class="color-context-name"><%=title%></span>
			
		
			
			</td>
	</tr>
	
	<tr>
		<td nowrap>
			<img src="<%=imagePath%>/misc/spacer.gif" border="0" alt="" width="6" height="2" />			
			</td>
		<td nowrap>
			<img src="<%=imagePath%>/misc/spacer.gif" border="0" alt="" width="499" height="2" /></td>
		<td nowrap>
			<img src="<%=imagePath%>/misc/spacer.gif" border="0" alt="" width="<%=logoWidth%>" height="2" /></td>
	</tr>
</table>

</body>
</html>

