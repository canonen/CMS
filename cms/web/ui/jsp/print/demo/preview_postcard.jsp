<%@ page
language="java"
import="com.britemoon.*,
		com.britemoon.cps.*,
		java.io.*,java.sql.*,
		java.util.*,java.util.*,
		java.sql.*,org.w3c.dom.*,
		org.apache.log4j.*"
errorPage="../../error_page.jsp"
contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String headerImg = "hdr2a";
String productImg = "camera.gif";
String offerText = "We'd like to thank you for being such a<br>valued customer by giving you <b>$10 off any<br>purchase of $100 or more</b>. This offer is valid<br>in ALL stores!";

String getFName = request.getParameter("fname");
String getLName = request.getParameter("lname");
String getAddr = request.getParameter("addr");
String getCityState = request.getParameter("cityst");
String getPurchDate = request.getParameter("purch_date");
String getPurchDept = request.getParameter("purch_dept");

if (getFName == null) getFName = "";
if (getLName == null) getLName = "";
if (getAddr == null) getAddr = "";
if (getCityState == null) getCityState = "";
if (getPurchDate == null) getPurchDate = "hdr2a";
if (getPurchDept == null) getPurchDept = "camera.gif";

headerImg = getPurchDate;
productImg = getPurchDept;

String code1 = "";

if ("hdr2a".equals(headerImg))
{
	offerText = "We'd like to thank you for being such a<br>valued customer by giving you <b>$10 off any<br>purchase of $100 or more</b>. This offer is valid<br>in ALL stores!";
	code1 = "2AHDRFRRVJU";
}
else if ("hdr2b".equals(headerImg))
{
	offerText = "We'd like to thank you for being such a<br>valued customer by giving you <b>$15 off any<br>purchase of $100 or more</b>. This offer is valid<br>in ALL stores!";
	code1 = "3BHDRBNWQSST";
}
else if ("hdr2c".equals(headerImg))
{
	offerText = "We'd like to thank you for being such a<br>valued customer by giving you <b>20% off any<br>purchase of $100 or more</b>. This offer is valid<br>in ALL stores!";
	code1 = "4CHDRGYIIRF";
}
else if ("hdr2".equals(headerImg))
{
	offerText = "We'd like to thank you for being such a<br>valued customer by inviting you to come to<br>ANY store and check out the great deals!";
	code1 = "1EHDRXD4LO";
}

String fullName = getFName + " " + getLName;

if (" ".equals(fullName)) fullName = "Valued Customer";		 

%>
<html>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<head>
<title>BargainBasement - Special Customer Discount!</title>
<style type="text/css">
body { margin: 0px;}
a:link {color: #0000CC; text-decoration: underline; !important}
a:visited {color: purple; text-decoration: underline; !important}
.chooseBig {font-family: verdana; font-size: 18px; font-weight: bold; color="#0000CC";}
.regfont {font-family: arial; font-size: 13px;}
.regfontv {font-family: verdana; font-size: 13px;}
.footsmall {font-family: verdana; font-size: 10px;}
.topnav {font-family: verdana; font-size: 10px; color: #032B80; }
.spotbig {font-family: arial; font-size: 16px;}
.spotsmall {font-family: verdana; font-size: 10px; line-height: 14px;}
div.main {background: #FFFFFF;}
</style>
</head>
<body>
<div class="main" align="center">
&nbsp;<br><br>
<a href="http://www.BargainBasement.com"><img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/ba.gif" width="405" height="36" border=0><img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/sb.gif" width="163" height="36" border=0></a><br>
<img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/topshadow.gif" width=568 height=3 border=0><br>
<table cellpadding=0 cellspacing=0 border=0 width=568>
	<tr>
		<td bgcolor="#B3DAF5" rowspan=3><img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/s.gif" width=2 height=2></td>
		<td width="360" valign="top"><img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/spot-hdr.gif" alt="" border="0"></td>
		<td width="204" bgcolor="#B3DAF5" align="center" background="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/searchbg.gif">&nbsp;</td>
		<td bgcolor="#B3DAF5" rowspan=3><img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/s.gif" width=2 height=2></td>
	</tr>
	<tr>
		<td width=204 colspan=2><img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/spot-<%= headerImg %>.gif" border=0></td>
	</tr>
	<tr>
		<td colspan=2 align="center" valign="top" nowrap>
			<table cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td rowspan=2 valign="bottom"><img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/<%= productImg %>"></td>
					<td valign=center>
						<div class=regfont>
							Take advantage of extra-special savings!<br><br> 
							Dear <%= fullName %>, <br><br>
							<%= offerText %> <br><br>
							Simply go to Bargainbasement.com and when you check out enter the code: 
							<b><%= code1 %></b> to get your rebate.<br><br>
							We look forward to serving you!<br><br>
							The BargainBasement Team
						</div>
					</td>
				</tr>
				<tr>
					<td><img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/s.gif" width=1 height=12></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="4" align="center" bgcolor="#B3DAF5"><img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/s.gif" width="2" height="8" border="0" alt=""></td>
	</tr>
</table>
<table cellpadding="0" cellspacing="0" width="568">
	<tr>
		<td bgcolor="#CC0000"><img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/s.gif" width="1" height="1" border="0" alt=""></td>
	</tr>
</table>
<br><br>
<table style="font-family:arial;border:#000000 1px solid;" cellpadding="25" cellspacing=0 width=570>
	<tr>
		<td valign=center>
			<%= fullName %>
			<br><%= getAddr %>
			<br><%= getCityState %>
		</td>
		<td valign=center align=right><img src="http://www.revotas.com/ImageHost/Smart_Bargains/winback/images/frontblurb.gif"></td>
	</tr>
</table>
</body>
</html>