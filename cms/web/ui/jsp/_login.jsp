<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,java.net.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="header.jsp"%>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	//grab query strings
	String sCustLogin = request.getParameter("company");
	String sUserLogin = request.getParameter("login");
	
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sAltURL = request.getParameter("url");
%>

<HTML>

<HEAD>
	<TITLE>Revotas Login</TITLE>
	<BASE target="_self">

<SCRIPT>

	function putFocus()
	{
		if (login_form.company.value=='')login_form.company.focus();
		else if (login_form.login.value=='')login_form.login.focus();
		else if (login_form.password.value=='')login_form.password.focus();
	}

</SCRIPT>
<link rel="stylesheet" href="/cms/ui/ooo/style.css" TYPE="text/css"/>
</HEAD>

<BODY class="login" onLoad="putFocus();" >
	
	

<FORM method="POST" action="login2.jsp" name="login_form">
<input type="hidden" name="tab" value="<%= (sNavTab==null)?"":sNavTab %>">
<input type="hidden" name="sec" value="<%= (sNavSection==null)?"":sNavSection %>">
<input type="hidden" name="url" value="<%= (sAltURL==null)?"":sAltURL %>">
	<font face=arial size=1>

<center>
<br><br><br><br><br><br>

<table width=250 cellpadding=0 cellspacing=0>
<tr>
	<td><img src="http://cms.revotas.com/cms/ui/ooo/images/nav/revotaslogo.png"/><br><br></td>
</tr>
<tr>
<td width=250>

	<TABLE border="0" align="left" cellpadding=0 cellspacing=0 class=listTable>
		<TR>
			<th colspan=2 align="left" valign=bottom>System Authentication</th>
		</TR>
		<TR>
		<TR>
			<TD align="right">Company:</TD>
			<TD><INPUT class=logintblinput type="text" name="company" size="32" value="<%=(sCustLogin==null)?"":sCustLogin%>"></TD>
		</TR>
		<TR>
			<TD align="right">Login:</TD>
			<TD><INPUT class=logintblinput type="text" name="login" size="32" value="<%=(sUserLogin==null)?"":sUserLogin%>"></TD>
		</TR>
		<TR>
			<TD align="right">Password:</TD>
			<TD><INPUT class=logintblinput type="password" name="password" size="32" value=""></TD>
		</TR>
		<TR>
			<TD></TD>
			<TD align="right"><a class="buttons-action" href="#" onclick="document.forms['login_form'].submit()" style="text-align:center;width:100px">Login</a></TD>
		</TR>
	</TABLE>
</td>
</tr>
</table>
</center>

</FORM>


<script type="text/javascript">
adroll_adv_id = "KVN3M4OXKVAUVB7QGCJCDY";
adroll_pix_id = "JBJAAUIN4FGKTJZHIU6MWO";
(function () {
var oldonload = window.onload;
window.onload = function(){
   __adroll_loaded=true;
   var scr = document.createElement("script");
   var host = (("https:" == document.location.protocol) ? "https://s.adroll.com" : "http://a.adroll.com");
   scr.setAttribute('async', 'true');
   scr.type = "text/javascript";
   scr.src = host + "/j/roundtrip.js";
   ((document.getElementsByTagName('head') || [null])[0] ||
    document.getElementsByTagName('script')[0].parentNode).appendChild(scr);
   if(oldonload){oldonload()}};
}());
</script>

<!-- Google Code for Email Marketers Remarketing List -->
<script type="text/javascript">
/* <![CDATA[ */
var google_conversion_id = 1055764569;
var google_conversion_language = "en";
var google_conversion_format = "3";
var google_conversion_color = "ffffff";
var google_conversion_label = "i7aeCO-s1gIQ2eC29wM";
var google_conversion_value = 0;
/* ]]> */
</script>
<script type="text/javascript" src="http://www.googleadservices.com/pagead/conversion.js">
</script>
<noscript>
<div style="display:inline;">
<img height="1" width="1" style="border-style:none;" alt="" src="http://www.googleadservices.com/pagead/conversion/1055764569/?label=i7aeCO-s1gIQ2eC29wM&amp;guid=ON&amp;script=0"/>
</div>
</noscript>

</BODY>

</HTML>
