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
<%@ include file="/adm/jsp/header.jsp" %>
<%
String sCustId = BriteRequest.getParameter(request, "cust_id");

String[] sFingerPrints = BriteRequest.getParameterValues(request, "fingerprint");

int l = ( sFingerPrints == null )?0:sFingerPrints.length;

String sIn = "-1";

for (int i = 0; i < l; i++) sIn += ", " + sFingerPrints[i];

String sSql =
	" UPDATE sadm_cust_attr SET fingerprint_seq = attr_id" +
	" WHERE (cust_id=" + sCustId  + ") AND (attr_id IN (" + sIn + "))";

BriteUpdate.executeUpdate(sSql);
%>

<HTML>
<HEAD>
	<%@ include file="/adm/jsp/header.html" %>
	<link rel="stylesheet" href="../../../../css/style.css" TYPE="text/css">
	<SCRIPT>
		self.location.href = "fingerprint.jsp?cust_id=<%=sCustId%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
