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
String sFromAddressId = BriteRequest.getParameter(request, "from_address_id");

FromAddress fa = null;

if( sFromAddressId == null)
{
	fa = new FromAddress();
	fa.s_cust_id = sCustId;
}
else fa = new FromAddress(sFromAddressId);

fa.s_prefix = BriteRequest.getParameter(request, "prefix");
fa.s_domain = BriteRequest.getParameter(request, "domain");

fa.save();
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		parent.location.href = "from_address_frame.jsp?cust_id=<%=fa.s_cust_id%>&from_address_id=<%=fa.s_from_address_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
