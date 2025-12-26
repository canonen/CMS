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

        <!-- jquery dosyalari -->

        <script type="text/javascript" src="http://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/js/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="http://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/js/ab-degisenArkaPlan.js"></script>

        <script type="text/javascript">
            $(document).ready(function(){
                $('body').abDegisenArkaPlan({
                    resimlerArasiGecis  : 10000,
                    resimEfekleri       : 2000,
          	resimler:
"http://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/golden.jpg,http://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/at.jpg,http://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/deniz.jpg,http://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/deniz2.jpg,http://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/deniz3.jpg,http://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/fil.jpg,http://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/aslan.jpg,http://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/pnda.jpg"
                });
            });
        </script>

        <link type="text/css" href="http://login.revotas.com/cms/ui/ooo/style.css" rel="stylesheet"/>
	    <link type="text/css" href="http://www.revotas.com/host/revotas/new_style.css" rel="stylesheet"/>

        <style type="text/css">
	      .transbox {
	      position:relative;
	      top:190px;
	      border-radius:4px 4px 4px 4px;
	      width:350px;
	      height:200px
	      }
		  footer#nav {
		  position:fixed;
		  bottom:0;
		  right:0;
		  left:0;
		  }
    	</style>

<link rel="stylesheet" href="/cms/ui/ooo/style.css" TYPE="text/css"/>

<script src="http://www.revotas.com/host/Revotas_Kurumsal/login/popup_revo.js" language="javascript"></script>
<link type="text/css" href="http://www.revotas.com/host/Revotas_Kurumsal/login/basic.css" rel="stylesheet" media="screen" />
<link type="text/css" href="http://www.revotas.com/host/Revotas_Kurumsal/login/basic_ie.css" rel="stylesheet" media="screen" />
<link type="text/css" href="http://www.revotas.com/host/Revotas_Kurumsal/login/gg_fb.css" rel="stylesheet" media="screen" />
<script type="text/javascript" src="http://www.revotas.com/host/Revotas_Kurumsal/login/jquery.simplemodal.1.4.1.min.js"></script>

</HEAD>

<BODY  class="login" onLoad="putFocus();">


	
		

<table width=250 cellpadding=0 cellspacing=0 align="center" >
<tr>
<td valign="top" align="center">



<FORM method="POST" action="login2.jsp" name="login_form">
<input type="hidden" name="tab" value="<%= (sNavTab==null)?"":sNavTab %>">
<input type="hidden" name="sec" value="<%= (sNavSection==null)?"":sNavSection %>">
<input type="hidden" name="url" value="<%= (sAltURL==null)?"":sAltURL %>">
	<font face=arial size=1>

<center>
<br><br><br><br><br><br><br>

<table width=250 cellpadding=0 cellspacing=0>

<tr>
<td width=250>


	   <table cellpadding="0" cellspacing="0" class="transbox" style="background-image:url('http://www.revotas.com/host/Revotas_Kurumsal/new_login/LoginBoxBG.png')" align="center">

	   <tr>
	   <td colspan="2" style="height:100%;padding-left:35px" valign="top">

	   <table  cellpadding="0" cellspacing="0">

	   <tr>
	   <td height="50">&nbsp;</td>
	   <td height="50" valign="middle" align="center" style="text-align:center">
	   <img src="http://www.revotas.com/host/Revotas_Kurumsal/new_login/logo.png" width="200"/>
	   </td>
	   </tr>


	   <tr>
	   <td style="font-family:Verdana, Geneva, Tahoma, sans-serif;font-size:13px;color:#ffffff"><b>
	   Company:</b>&nbsp;</td>
	   <td> <input class="genel" type="text" name="company" value="<%=(sCustLogin==null)?"":sCustLogin%>"/></td>
   	   </tr>
	   <tr><td colspan="2">&nbsp;</td></tr>
	   <tr>
	   <td style="font-family:Verdana, Geneva, Tahoma, sans-serif;font-size:13px;color:#ffffff"><b>
	   Login:</b>&nbsp;</td>
	   <td> <input class="genel" type="text" name="login" value="<%=(sUserLogin==null)?"":sUserLogin%>"/></td>
	   </tr>
	   <tr><td colspan="2">&nbsp;</td></tr>
	   <tr>
	   <td style="font-family:Verdana, Geneva, Tahoma, sans-serif;font-size:13px;color:#ffffff"><b>
	   Password:</b>&nbsp;</td>
	   <td> <input class="genel" type="password" name="password" value=""/></td>
	   </tr>
	   <tr><td colspan="2">&nbsp;</td></tr>
	   <tr>
	   <td>&nbsp;</td>
	   <td style="text-align:center" align="center">
	   <a  href="#" style="cursor:pointer;background-color: #FF8000;border-radius: 4px 4px 4px 4px;color: #FFFFFF;font-family: Verdana;font-size: 15px;font-weight: bold;height: 40px;width: 205px;letter-spacing:12px;border:none"  onclick="document.forms['login_form'].submit()" style="text-align:center;width:200px"/>&nbsp;&nbsp;Login&nbsp;&nbsp; </a></td>
	   </tr>


	   </table>


       </td>
	   </tr>

	   <tr><td>&nbsp;</td></tr>

	   </table>


		<footer id="nav">
	    <table  cellpadding="0" cellspacing="0" width="100%" style="background-image:url('http://www.revotas.com/host/ogun/LoginBoxBG.png')">
		<tr>
			<td style="text-align:center">
				<div>
				     <div>
				           <div>
					                <p style="color:#ffffff;font-size:12px;letter-spacing:2px">Bizi takip edin</p>

					                <a href="https://www.facebook.com/RevotasTurkey">
					                    <img alt="Revotas at Facebook" src="http://www.revotas.com/host/Revotas_Kurumsal/social_media/social_facebook.png" border="0"/></a>
									<a href="https://twitter.com/RevotasTurkey">
					                    <img alt="Revotas at Twitter" src="http://www.revotas.com/host/Revotas_Kurumsal/social_media/social_twitter.png" border="0"/></a>
									<a href="https://www.linkedin.com/company/revotas">
	     				                <img alt="Revotas at LinkedIn" src="http://www.revotas.com/host/Revotas_Kurumsal/social_media/social_linkedin.png" border="0"/></a>
									<a href="http://www.revotas.com/blog/">
	   				                    <img alt="Revotas at Blog" src="http://www.revotas.com/host/Revotas_Kurumsal/social_media/social_rss.png" border="0"/></a>

										<!--
										<img alt="Revotas at Google+" src="http://www.revotas.com/host/Revotas_Kurumsal/social_media/social_google-plus.png" border="0"/>
	 				                    <img alt="Revotas at YouTube" src="http://www.revotas.com/host/Revotas_Kurumsal/social_media/social_youtube.png" border="0"/>
					                    <img alt="Revotas at Tumblr" src="http://www.revotas.com/host/Revotas_Kurumsal/social_media/social_tumblr.png" border="0"/>
					                    -->


				           </div>
			         </div>
			    </div>
			</td>
		</tr>
		</table>
		</footer>
		
		
		

</td>
</tr>
</table>
</center>

</FORM>

</td>
</tr>
</table>


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

<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-618301-6");
pageTracker._trackPageview();
} catch(err) {}</script>


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
