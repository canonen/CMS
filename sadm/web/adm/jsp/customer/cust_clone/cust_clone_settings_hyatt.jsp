<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp" %>
<%
String sCustId = BriteRequest.getParameter(request, "cust_id");
if(sCustId == null) return;

Customer cust = new Customer(sCustId);
if(cust.s_cust_id == null) return;
%>

<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
</HEAD>

<BODY>
<FORM method="post" action="cust_clone_preview_hyatt.jsp">
<INPUT type="hidden" name="original_cust_id" value="<%=cust.s_cust_id%>">
<H5>Paste tab delimited settings (from your Excel file):</H5>
<TABLE border="0" cellspacing="0" cellpadding="1">
	<TR>
		<TH>Spirit<BR>Code</TH>
		<TH>Customer<BR>Name</TH>
		<TH>Customer<BR>Login<BR>Name</TH>
		<TH>Street<BR>Address<BR>1</TH>
		<TH>Street<BR>Address<BR>2</TH>
		<TH>City</TH>
		<TH>State</TH>
		<TH>Zip</TH>
		<TH>Country</TH>
		<TH>User<BR>Name<BR>1</TH>
		<TH>User<BR>Phone<BR>1</TH>
		<TH>User<BR>Email<BR>1</TH>
		<TH>User<BR>Login<BR>1</TH>
		<TH>User<BR>Pass<BR>1</TH>
		<TH>User<BR>Name<BR>2</TH>		
		<TH>User<BR>Phone<BR>2</TH>
		<TH>User<BR>Email<BR>2</TH>
		<TH>User<BR>Login<BR>2</TH>
		<TH>User<BR>Pass<BR>2</TH>
	</TR>		
	<TR>
		<TD colspan=19>
<TEXTAREA name="hayatt_settings" style="width: 100%; height: 300"></TEXTAREA>
		</TD>
	</TR>
	<TR>
		<TD colspan=19 align=center>
<INPUT type=submit style="width: 75%;" value="Parse">
		</TD>
	</TR>
</TABLE>

</FORM>
</BODY>
</HTML>
