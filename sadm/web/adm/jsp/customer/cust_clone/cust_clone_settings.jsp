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
	<SCRIPT>
	function doSubmit()
	{
		if(!confirm("DO YOU REALLY WANT TO CLONE THIS CUSTOMER?")) return false;
		cust_clone_form.action = "cust_clone.jsp";
		cust_clone_form.submit();
	}
	</SCRIPT>
</HEAD>

<BODY>
<FORM method="post" action="none" name="cust_clone_form">
<INPUT type="hidden" name="original_cust_id" value="<%=cust.s_cust_id%>">
<TABLE border="0" cellspacing="0" cellpadding="1">
	<TR>
		<TD>
			Clone
			&nbsp;<INPUT type="text" name="how_many" value="1">&nbsp;
			times.
			&nbsp;<INPUT type="button" value="Clone" onClick="doSubmit();">
		</TD>
	</TR>
	<TR>
		<TD>
<UL>
	<LI><B>General info</B></LI>
		<OL>
			<LI><INPUT type="checkbox" checked disabled name="clone_customer"><B>Name & blah ...</B></LI>
			<LI><INPUT type="checkbox" checked name="clone_cust_addr"><B>Address & Phone</B></LI>			
			<LI><INPUT type="checkbox" checked name="clone_cust_ui_settings"><B>UI settings</B></LI>
			<LI><INPUT type="checkbox" checked name="clone_cust_partner"><B>Partners</B></LI>
		</OL>
	<LI><B>System & Modules</B></LI>
		<OL>
			<LI><INPUT type="checkbox" checked name="clone_cust_mod_inst"><B>Bind Module Instances</B></LI>
			<LI><INPUT type="checkbox" checked name="clone_vanity_domain"><B>Vanity domains</B></A></LI>
			<LI><INPUT type="checkbox" checked name="clone_unique_ids"><B>Sequence numbers</B></LI>
		</OL>
	<LI><B>Users</B></LI>
		<OL>
			<LI><INPUT type="checkbox" checked name="clone_user"><B>General Info</B></LI>
			<LI><INPUT type="checkbox" checked name="clone_access_mask"><B>Access Rights</B></LI>
		</OL>
	<LI><B>Recipients</B></LI>
		<OL>
			<LI><INPUT type="checkbox" checked disabled><B>Standard attributes</B></LI>
			<LI><INPUT type="checkbox" checked name="clone_cust_attr"><B>Inherited attributes</B></LI>			
		</OL>
	<LI><B>Other</B></LI>
		<OL>
			<LI><INPUT type="checkbox" checked name="clone_unsub_msg"><B>Unsubscribe messages</B></LI>
			<LI><INPUT type="checkbox" checked name="clone_from_address"><B>From addresses</B></LI>
			<LI><INPUT type="checkbox" checked name="clone_send_param"><B>Send Parameters</B></LI>
			<LI><INPUT type="checkbox" checked name="clone_cust_feature"><B>Features</B></LI>
		</OL>
	<LI><B>Workflow</B></LI>
		<OL>
			<LI><INPUT type="checkbox" checked name="clone_aprvl_cust"><B>Aprvl Cust</B></LI>
		</OL>
</UL>
		</TD>
	</TR>
</TABLE>

</FORM>
</BODY>
</HTML>
