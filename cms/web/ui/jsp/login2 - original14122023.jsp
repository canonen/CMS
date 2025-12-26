<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,java.sql.*,
			java.io.*,javax.servlet.*,
			javax.servlet.http.*,java.util.*,
			java.net.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="header.jsp"%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
try	
{
	String sCustLogin = request.getParameter("company");
	String sUserLogin = request.getParameter("login");
	String sPassword = request.getParameter("password");
	
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");
	String sAltURL = request.getParameter("url");
	
	String sRedirect = "";
	String sUserId = "";

	Customer cust = new Customer(null, sCustLogin);

	boolean bIsCustActive = ((cust.s_status_id != null) && (CustStatus.ACTIVATED == Integer.parseInt(cust.s_status_id)))?true:false;

	User user = new User(null, sUserLogin, cust.s_cust_id);
	sUserId = user.s_user_id;
	boolean bIsUserActive = ((user.s_status_id != null) && (UserStatus.ACTIVATED == Integer.parseInt(user.s_status_id)))?true:false;
	boolean bIsPasswordValid = ((user.s_password != null) && (user.s_password.equals(sPassword)))?true:false;
	boolean bPasswordExpiring = user.isPassExpiring();
	boolean bPasswordHasExpired = user.isPassHasExpired();
	
	if ( bIsCustActive && bIsUserActive && bIsPasswordValid && (!bPasswordHasExpired))
	{
		session = request.getSession(true);
		UIEnvironment ui = new UIEnvironment(session, user, cust);
		
		sRedirect = "index.jsp?login=true";
		
		if (null != sNavTab)
		{
			sRedirect += "&tab=" + sNavTab;
		}
		if (null != sNavSection)
		{
			sRedirect += "&sec=" + sNavSection;
		}
		if ((null != sAltURL) && (!sAltURL.equals("")))
		{
			sRedirect += "&url=" + URLEncoder.encode(sAltURL, "UTF-8");
		}
 		
 		response.sendRedirect(sRedirect);

		SessionMonitor.update(session, request.getRequestURI());
	}
	else
	{		
		SessionMonitor.update(session, request.getRequestURI());
		
		if (bIsCustActive && bIsUserActive && bIsPasswordValid && bPasswordHasExpired)
		{
			session = request.getSession(true);
			UIEnvironment ui = new UIEnvironment(session, user, cust);
		}
		else
		{
			session.invalidate();
		}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "https://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="https://www.w3.org/1999/xhtml" dir="ltr" lang="tr">

<head>
<title>Revotas: Login</title>
<script>

function putFocus()
{
	if (login_form.company.value=='')login_form.company.focus();
	else if (login_form.login.value=='')login_form.login.focus();
	else if (login_form.password.value=='')login_form.password.focus();
}

function loadPassChange()
{
	URL = "setup/users/pass_change.jsp?status=2&user_id=<%= sUserId %>";
	windowName = "PassChange";
	windowFeatures = "dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=350, width=400";
   	window.open(URL, windowName, windowFeatures);
}

</script>
        <script type="text/javascript" src="https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/js/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/js/ab-degisenArkaPlan.js"></script>

        <script type="text/javascript">
            $(document).ready(function(){
                $('body').abDegisenArkaPlan({
                    resimlerArasiGecis  : 10000,
                    resimEfekleri       : 2000,
          	resimler:
"https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/golden.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/at.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/deniz.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/deniz2.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/deniz3.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/fil.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/aslan.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/pnda.jpg"
                });
            });
        </script>

	<link type="text/css" href="https://www.revotas.com/host/revotas/new_style.css" rel="stylesheet"/>
	<link rel="stylesheet" href="/cms/ui/ooo/style.css" TYPE="text/css"/>


<style type="text/css">
html,
body {
	margin:0;
	padding:0;
	height:100%;
}
.transbox {
position:relative;
top:90px;
border-radius:4px 4px 4px 4px;
width:350px; 
height:200px
      }

#wrapper {
	min-height:100%;
	position:relative;
}
#header {
	padding:10px;

}
#content {
	padding:10px;
	padding-bottom:80px;   /* Height of the footer element */
}
#footer {
	width:100%;
	position:fixed;
        bottom:0; 
        right:0; 
        left:0;

}

<!--[if lt IE 7]>
	<style type="text/css">
		#wrapper { height:100%; }
	</style>
<![endif]-->

</style>
        
</HEAD>

<body class="login" <% if (!bPasswordHasExpired) { %> onLoad="putFocus();"<% } %>>
	
	
<form method="POST" action="login2.jsp" name="login_form">
<input type="hidden" name="tab" value="<%= (sNavTab==null)?"":sNavTab %>">
<input type="hidden" name="sec" value="<%= (sNavSection==null)?"":sNavSection %>">
<input type="hidden" name="url" value="<%= (sAltURL==null)?"":sAltURL %>">
<font face=arial size=1>
<center>






	   <table cellpadding="0" cellspacing="0"  align="center">

	   <tr>
	   <td colspan="2">

	   	<div id="wrapper">
	   		<div id="header"></div>
	   		<center>
	   		<div id="content">
	   		<table cellpadding="0" cellspacing="0" class="transbox" style="background-image:url('https://www.revotas.com/host/Revotas_Kurumsal/new_login/LoginBoxBG.png')" align="center">
	   	   
	   	   <tr>
	   	   <td colspan="2" style="height:100%;padding-left:35px;padding-bottom:10px" valign="top">
	   	   
	   	   <table  cellpadding="0" cellspacing="0">
	   	   
	   	   <tr>
	   	   <td height="50">&nbsp;</td>
	   	   <td height="50" valign="middle" align="center" style="text-align:center">
	   	   <img src="https://www.revotas.com/host/Revotas_Kurumsal/new_login/logo.png" width="200"/>
	   	   </td>
	   </tr>

	   <% if (bIsCustActive && bIsUserActive && bIsPasswordValid && bPasswordHasExpired) { %>
		<tr>
			<td style="font-family:arial;color:#555555;font-size:10px;" colspan=2 align=center>
				<b>Your password has expired!</b><br><br>
				You will be unable to log in until you have changed your password.<br><br>
				<a href="javascript:loadPassChange();">Click here</a> to change your password.
			</td>
		</tr>
           <% } else { %>
	   
	   <tr>
	   <td>&nbsp;</td>
	   <td style="font-family:arial;color:#ffffff;font-size:10px;padding:5px">Please try again.<br></td>
	   </tr>
	   
	   <tr>
	   <td style="font-family:Verdana, Geneva, Tahoma, sans-serif;font-size:13px;color:#ffffff;text-align:right"><b>
	   Company:</b>&nbsp;</td>
	   <td> <input class="genel" type="text" name="company" value="<%=(sCustLogin==null)?"":sCustLogin%>"/></td>
   	   </tr>
	   <tr><td colspan="2">&nbsp;</td></tr>
	   <tr>
	   <td style="font-family:Verdana, Geneva, Tahoma, sans-serif;font-size:13px;color:#ffffff;text-align:right"><b>
	   Username:</b>&nbsp;</td>
	   <td> <input class="genel" type="text" name="login" value="<%=(sUserLogin==null)?"":sUserLogin%>"/></td>
	   </tr>
	   <tr><td colspan="2">&nbsp;</td></tr>
	   <tr>
	   <td style="font-family:Verdana, Geneva, Tahoma, sans-serif;font-size:13px;color:#ffffff;text-align:right"><b>
	   Password:</b>&nbsp;</td>
	   <td> <input class="genel" type="password" name="password" value=""/></td>
	   </tr>
	   <tr><td colspan="2">&nbsp;</td></tr>
	   <tr>
	   <td>&nbsp;</td>
	   <td style="text-align:center;padding-top:5px;padding-bottom:5px;background-color: #FF8000;border-radius: 4px 4px 4px 4px" align="center">
	   <a  href="#" style="cursor:pointer;background-color: #FF8000;border-radius: 4px 4px 4px 4px;color: #FFFFFF;padding-left:7px;padding-right:8px;padding-top:5px;padding-bottom:5px;font-family: Verdana;font-size: 15px;font-weight: bold;height: 40px;width: 250px;border:none;text-align:center;text-decoration:none"  onclick="document.forms['login_form'].submit()" />&nbsp;&nbsp;Login&nbsp;&nbsp; </a></td>
	   </tr>

	   <% } %>
	
	   </table>
	   
	   <div id="footer">
	   	   		<table  cellpadding="0" cellspacing="0" width="100%" style="background-image:url('https://www.revotas.com/host/ogun/LoginBoxBG.png')">
	   	   		<tr>
	   	   			<td style="text-align:center">
	   	   				<div>
	   	   				     <div>
	   	   				           <div>
	   	   					                <p style="color:#ffffff;font-size:12px;letter-spacing:2px">
	   	   									Bizi takip edin</p>
	   	   					                    
	   	   					                <a href="https://www.facebook.com/RevotasTurkey">
	   	   					                    <img alt="Revotas at Facebook" src="https://www.revotas.com/host/Revotas_Kurumsal/social_media/social_facebook.png" border="0"/></a>
	   	   									<a href="https://twitter.com/RevotasTurkey">
	   	   					                    <img alt="Revotas at Twitter" src="https://www.revotas.com/host/Revotas_Kurumsal/social_media/social_twitter.png" border="0"/></a>
	   	   									<a href="https://www.linkedin.com/company/revotas">
	   	   	     				                <img alt="Revotas at LinkedIn" src="https://www.revotas.com/host/Revotas_Kurumsal/social_media/social_linkedin.png" border="0"/></a>
	   	   									<a href="https://www.revotas.com/blog/">
	   	   	   				                    <img alt="Revotas at Blog" src="https://www.revotas.com/host/Revotas_Kurumsal/social_media/social_rss.png" border="0"/></a>
	   	   	
	   	   										<!--
	   	   										<img alt="Revotas at Google+" src="https://www.revotas.com/host/Revotas_Kurumsal/social_media/social_google-plus.png" border="0"/>
	   	   	 				                    <img alt="Revotas at YouTube" src="https://www.revotas.com/host/Revotas_Kurumsal/social_media/social_youtube.png" border="0"/>              
	   	   					                    <img alt="Revotas at Tumblr" src="https://www.revotas.com/host/Revotas_Kurumsal/social_media/social_tumblr.png" border="0"/>
	   	   					                    -->
	   	   	  				                    
	   	   					                
	   	   				           </div>
	   	   			         </div>
	   	   			    </div>
	   	   			</td>
	   	   		</tr>
	   	   		</table>
	   	   
	   	   		</div>
	   	</div>
	   
	   

</center>
</font>
</form>


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
<script type="text/javascript" src="https://www.googleadservices.com/pagead/conversion.js">
</script>
<noscript>
<div style="display:inline;">
<img height="1" width="1" style="border-style:none;" alt="" src="https://www.googleadservices.com/pagead/conversion/1055764569/?label=i7aeCO-s1gIQ2eC29wM&amp;guid=ON&amp;script=0"/>
</div>
</noscript>
</body>
</html>
<%
	}
}
catch(Exception ex)
{
	ErrLog.put(this, ex, "Error in login.jsp", out, 1);
}
finally
{
}
%>
