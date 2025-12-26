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

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="tr">


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

        <script type="text/javascript" src="https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/js/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/js/ab-degisenArkaPlan.js"></script>

        <script type="text/javascript">
            $(document).ready(function(){
                $('body').abDegisenArkaPlan({
                    resimlerArasiGecis  : 10000,
                    resimEfekleri       : 2000,
          	resimler:
"https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/sunset.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/conf.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/earth.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/fall.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/foam.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/island.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/power.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/spirit.jpg,https://www.revotas.com/host/Revotas_Kurumsal/new_login/kutuphane/resim/air.jpg"
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

<BODY onLoad="putFocus();">

<FORM method="POST" action="login2.jsp" name="login_form">
<input type="hidden" name="tab" value="<%= (sNavTab==null)?"":sNavTab %>">
<input type="hidden" name="sec" value="<%= (sNavSection==null)?"":sNavSection %>">
<input type="hidden" name="url" value="<%= (sAltURL==null)?"":sAltURL %>">

<font face=arial size=1>

<center>

<table width=250 cellpadding=0 cellspacing=0>

<tr>
<td width=250>


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
	   									<a href="http://www.revotas.com/blog/">
	   	   				                    <img alt="Revotas at Blog" src="https://www.revotas.com/host/Revotas_Kurumsal/social_media/social_rss.png" border="0"/></a>
	   	
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
	   
	   		</div>
	   	</div>


		
		
		

</td>
</tr>
</table>

</center>

</FORM>
<script>
if(!window['rvtsPopupArray'])
    var rvtsPopupArray = [];
    rvtsPopupArray.push({rvts_customer_id:'420', rvts_popup_id:'pw5rbao14pyco4sdzmhcacmi64vdzr'});
(function() {
    var _rTag = document.getElementsByTagName('script')[0];
    var _rcTag = document.createElement('script');
    _rcTag.type = 'text/javascript';
    _rcTag.async = 'true';
    _rcTag.src = ('https://l.revotas.com/trc/smartwidget/smartwidget.js');
    _rTag.parentNode.insertBefore(_rcTag, _rTag);
})();
</script>
</BODY>
</HTML>
