



<%@ page import="javax.servlet.http.*,
				 javax.servlet.jsp.*,
				 java.text.*,
		 		 java.util.*"
			contentType="text/html; charset=UTF-8"
%>


<%
	String bodyURL = "system_welcome.jsp?d=0&epi_location=epi__location__system_welcome&epi_component_type=Modules&query_type=basic_query&epi_context=epi_context_system&epi_page_size=";
	String pathToJSLib = "jslib";
	
	String title = "Welcome";
	String body = request.getParameter("body");
	if(body!=null) {
		try {
			int bt = Integer.parseInt(body);
			switch(bt) {
				case 3: 	title = "Campaigns";
									break;
				default:	break;
			}
		} catch(Exception e) {
		}
	}	
%>

<head>
<script language="JavaScript">
// reload the body frame so that it shows the new number of results
function showNewCount() {
	var newCount = document.count_form.count.options[document.count_form.count.selectedIndex].text;
	parent.mainFrame.location.href = "<%=bodyURL%>" + newCount;
}
</script>
<script language="JavaScript" src="<%= pathToJSLib %>/epi-utils.js"></script>
<link rel="stylesheet" href="../ui/framework/css/stylesheet_admin_common_ie.css" type="text/css" />

<link rel="stylesheet" href="../ui/framework/css/stylesheet_admin_header_sys.css" type="text/css" />
</head>

<body topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0" marginwidth="0" marginheight="0" class="color-trail-3">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr class="color-trail-1">

		<td width="25" nowrap><img src="../ui/framework/images/misc/spacer.gif" border="0" alt="" width="6" height="25" /><img src="../ui/framework/images/icons/icon_efs.gif" border="0" alt="Site Icon" width="15" height="25" /><img src="../ui/framework/images/misc/spacer.gif" border="0" alt="" width="4" height="25" /></td>
		
		<td>
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td class="font-trail" nowrap>
						<span class="font-trail-current"><%=title%></span></td>
					<td align="right" nowrap class="font-menu">
				
						<a href="" onClick="javascript:openWindow('./help/frame.jsp?loadpage=overview.jsp', 'Help', 500, 500, 'yes', 'yes'); return false" class="Help">Help</a></td>
						
				</tr>
			</table></td>
		<td>
			<img src="../ui/framework/images/misc/spacer.gif" border="0" alt="" width="6" height="25" /></td>
	</tr>

	<tr class="color-trail-2">
		<td>
			<img src="../ui/framework/images/misc/spacer.gif" border="0" width="25" height="1" /></td>
		<td>
			<img src="../ui/framework/images/misc/spacer.gif" border="0" width="550" height="1" /></td>
		<td>
			<img src="../ui/framework/images/misc/spacer.gif" border="0" alt="" width="6" height="1" /></td>
	</tr>
	<tr class="color-trail-4">
		<td>
			<img src="../ui/framework/images/misc/spacer.gif" border="0" width="25" height="1" /></td>
		<td>
			<img src="../ui/framework/images/misc/spacer.gif" border="0" width="550" height="1" /></td>
		<td>
			<img src="../ui/framework/images/misc/spacer.gif" border="0" alt="" width="6" height="1" /></td>
	</tr>

</table>
</body>
</html>
