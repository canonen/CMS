<%@ page import="java.util.*,
		 	java.io.*"
			contentType="text/html; charset=UTF-8"
%>












<html>
<head>
<script language="JavaScript">


function reloadAndClose(url) {
	top.opener.top.location.href = url;
	top.close();
}

function loadBodyAndClose(url) {
	top.opener.top.bodyFrame.location.href = url;
	top.close();
}

// handle to popup window
var popupWin;

function showPopup(url, name, width, height) {
	var left = (screen.width - width) / 2;
	var top = (screen.height - height) / 2;
	var props = "resizable,scrollbars=yes,left=" + left + ",top=" + top + ",width=" + width + ",height=" + height;
	popupWin = window.open(url, name, props);
	popupWin.focus();
}

// handle site selection popup window
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

<link rel="stylesheet" href="css/stylesheet_admin_common_ie.css" type="text/css" />

<link rel="stylesheet" href="css/stylesheet_admin_header_sys.css" type="text/css" />


</head>
<body bgcolor="ffffff" topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0" marginwidth="0" marginheight="0">
<form>


 <table width="100%" border="0" cellpadding="0" cellspacing="0">

  <tr>

   <td rowspan="6"><img src="images/misc/spacer.gif" border="0" alt="" width="25" height="10" /></td>
   <td colspan="2"><img src="images/misc/spacer.gif" border="0" alt="" width="530" height="10" /></td>
   <td rowspan="6"><img src="images/misc/spacer.gif" border="0" alt="" width="25" height="10" /></td>
  </tr>
  <tr>

   <td colspan="2" class="font-title">Welcome to Vignette Application Portal</td>
  </tr>





  <tr>

   <td colspan="2">

	<hr size="1" />
	  </td>
  </tr>

  <tr>

   <td colspan="2" align="left">

	<table  border="0" cellpadding="0" cellspacing="0" width="100%">




	 <tr>

	  <td width="100%" valign="top">
	   <table border="0" cellpadding="2" cellspacing="1" width="100%">
   <tr class="color-row-header" valign="middle">
      <th nowrap class="font-list-header" valign="middle" scope="col" align="left" rowspan='1' colspan='1'>&nbsp;<a href="system_welcome.jsp?d=0&epi_location=epi__location__system_welcome&epi_component_type=Modules&epi_context=epi_context_system&epi_sort_field=sort_by_title&epi_sort_direction=sort_descending" class="table-header">Sites<img src="images/widgets/sort_up.gif" border="0" width="13" height="6" alt=""/></a></th>
   </tr>
   <tr class="color-row-even">
      <td align="left"><a href="/portal/templates/template0036/t0036style0001/frameset.jsp?d=0&epi_itemUID=221bd4b8be16820ef09af46253295c48&epi_location=epi__location__system_welcome&epi_siteUID=221bd4b8be16820ef09af46253295c48&epi_context=epi_context_site" target="_top">Business</a></td>
   </tr>
   <tr class="color-row-odd">
      <td align="left"><a href="/portal/templates/template0036/t0036style0001/frameset.jsp?d=0&epi_itemUID=add31ee54b1c457b71b7471053295c48&epi_location=epi__location__system_welcome&epi_siteUID=add31ee54b1c457b71b7471053295c48&epi_context=epi_context_site" target="_top">BYOP Verizon Online Portal</a></td>
   </tr>
   <tr class="color-row-even">
      <td align="left"><a href="/portal/templates/template0036/t0036style0001/frameset.jsp?d=0&epi_itemUID=1bf020e1af393623645ef30253295c48&epi_location=epi__location__system_welcome&epi_siteUID=1bf020e1af393623645ef30253295c48&epi_context=epi_context_site" target="_top">Content Administration</a></td>
   </tr>
   <tr class="color-row-odd">
      <td align="left"><a href="/portal/templates/template0036/t0036style0001/frameset.jsp?d=0&epi_itemUID=d22bdc9d41f7574311ec3982c16ae2ec&epi_location=epi__location__system_welcome&epi_siteUID=d22bdc9d41f7574311ec3982c16ae2ec&epi_context=epi_context_site" target="_top">EFS Front End</a></td>
   </tr>
   <tr class="color-row-even">
      <td align="left"><a href="/portal/templates/template0036/t0036style0001/frameset.jsp?d=0&epi_itemUID=24c25b398895bbdb8c738c31cc695c48&epi_location=epi__location__system_welcome&epi_siteUID=24c25b398895bbdb8c738c31cc695c48&epi_context=epi_context_site" target="_top">Email</a></td>
   </tr>
   <tr class="color-row-odd">
      <td align="left"><a href="/portal/templates/template0036/t0036style0001/frameset.jsp?d=0&epi_itemUID=b4b22fd8efded5eb8c738c31cc695c48&epi_location=epi__location__system_welcome&epi_siteUID=b4b22fd8efded5eb8c738c31cc695c48&epi_context=epi_context_site" target="_top">Flyout</a></td>
   </tr>
   <tr class="color-row-even">
      <td align="left"><a href="/portal/templates/template0036/t0036style0001/frameset.jsp?d=0&epi_itemUID=b90bdd7e2d87d137ec519de1ad65c7ec&epi_location=epi__location__system_welcome&epi_siteUID=b90bdd7e2d87d137ec519de1ad65c7ec&epi_context=epi_context_site" target="_top">myaccount</a></td>
   </tr>
   <tr class="color-row-odd">
      <td align="left"><a href="/portal/templates/template0036/t0036style0001/frameset.jsp?d=0&epi_itemUID=599105488b282de3e7e5d2b6c16ae2ec&epi_location=epi__location__system_welcome&epi_siteUID=599105488b282de3e7e5d2b6c16ae2ec&epi_context=epi_context_site" target="_top">Stress Tester</a></td>
   </tr>
   <tr class="color-row-even">
      <td align="left"><a href="/portal/templates/template0036/t0036style0001/frameset.jsp?d=0&epi_itemUID=0bb8b4d99fb6a0b192371ff3f2295c48&epi_location=epi__location__system_welcome&epi_siteUID=0bb8b4d99fb6a0b192371ff3f2295c48&epi_context=epi_context_site" target="_top">VASP Services Developers Site</a></td>
   </tr>
   <tr class="color-row-odd">
      <td align="left"><a href="/portal/templates/template0036/t0036style0001/frameset.jsp?d=0&epi_itemUID=d7bc17c6ce65b4958ce405d4cc695c48&epi_location=epi__location__system_welcome&epi_siteUID=d7bc17c6ce65b4958ce405d4cc695c48&epi_context=epi_context_site" target="_top">Verizon</a></td>
   </tr>
</table>


	   <table  border="0" cellpadding="3" cellspacing="0" width="100%">
		<tr>
		 <td width="100%">
		  <hr size="1" />
		  <a href="javascript:showSiteSelectionPopup('/portal/templates/template0006/t0006style0001/frameset_standard.jsp?d=0&epi_location=epi__location__site_selection_popup&epi_sort_field=sort_by_title&epi_sort_direction=sort_ascending&epi_context=epi_context_system');" class="button">More...</a></td>
		</tr>
   		</table>

		<br />
			  <br />
	   <table  border="0" cellpadding="3" cellspacing="0" width="100%">
		<tr class="color-row-header" align="left">
		 <td class="font-list-header" nowrap colspan="2">License &amp; Entitlements</td>
		</tr>
		<tr class="row-color-lighter">
		 <td nowrap class="font-list-item-bold" valign=top>Version:</td>
		 <td width="100%" valign=top nowrap>4.5 SP1 (build 248)</td>
		</tr>

		<tr class="row-color-lighter">
		 <td nowrap class="font-list-item-bold" valign=top>Patches:</td>
		 <td width="100%" valign=top nowrap>10/31/2003 - 92098<br>
05/19/2004 - 86145<br>
</td>
		</tr>

		<tr class="row-color-lighter">
		 <td nowrap class="font-list-item-bold" valign=top>Serial Number:</td>
		 <td width="100%" valign=top nowrap>1194101964052</td>
		</tr>
		<tr class="row-color-lighter">
		 <td nowrap class="font-list-item-bold" valign=top>License Type:</td>
		 <td width="100%" valign=top nowrap>Development Permanent</td>
		</tr>
		<tr class="row-color-lighter">
		 <td nowrap class="font-list-item-bold" valign=top>License Expiration:</td>
		 <td width="100%" valign=top nowrap>Never</td>
		</tr>
		<tr class="row-color-lighter">
		 <td nowrap class="font-list-item-bold" valign=top>User Limit:</td>
		 <td width="100%" valign=top nowrap>Unlimited</td>
		</tr>
		<tr class="row-color-lighter">
		 <td nowrap class="font-list-item-bold" valign=top>Clustered:</td>
		 <td width="100%" valign=top>Yes, 4
						servers in cluster.<br /><a target="bodyFrame" href="frameset_standard.jsp?beanID=1282343088&epi_location=epi__location__server_tools_host&epi_context=epi_context_system&viewID=cluster&epi_sort_field=licenseType&epi_sort_direction=sort_ascending"><span class="color-alert">
					(Warning: This cluster is currently operating with different license levels.)</span></a></td>
		</tr>
		<tr>
			<td nowrap colspan="2"><hr size="1" /></td>
		</tr>
		<tr>
			<td nowrap>
				<a target="bodyFrame" href="frameset_standard.jsp?beanID=1282343088&epi_location=epi__location__server_tools_host&epi_context=epi_context_system" class="button">Details...</a></td>
			<td nowrap align="right">
				<a target="_top" href="http://license.epicentric.com" class="button">Go To License Site...</a></td>
		</tr>
	   </table>
	   <br />

	   </td>
	  <td width="30" ><img src="images/misc/spacer.gif" border="0" alt="0" width="30" height="8"><img src="images/misc/spacer.gif" border="0" alt="" width="30" height="20" /></td>
	  <td valign="top">

	   <img src="images/misc/sys_welcome_image_final.jpg" border="0" alt="" width="300" height="400" /><br />
			</td>
	 </tr>
  		</table>
   </td>
  </tr>

  <tr>

   <td align="left" colspan="2" class="font-dimmed">
   	

	<hr size="1" />U.S Patent No. 6,327,628 and Patents Pending. Copyright Â© 1999-2003 Vignette Â® Corporation. All Rights Reserved. JMX and all JMX based trademarks and logos are trademarks or registered trademarks of Sun Microsystems, Inc. in the U.S. and other countries.

	  </td>
  </tr>

  <tr>

   <td align="left" width="50%">&nbsp;

	</td>
   <td align="right" width="50%">&nbsp;</td>
  </tr>
  </table>

<br />
</form>
</body>
</html>
