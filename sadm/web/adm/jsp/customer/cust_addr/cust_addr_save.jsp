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

CustAddr cust_addr = new CustAddr();

cust_addr.s_cust_id = BriteRequest.getParameter(request, "cust_id");
cust_addr.s_address1 = BriteRequest.getParameter(request, "address1");
cust_addr.s_address2 = BriteRequest.getParameter(request, "address2");
cust_addr.s_state = BriteRequest.getParameter(request, "state");
cust_addr.s_city = BriteRequest.getParameter(request, "city");
cust_addr.s_country = BriteRequest.getParameter(request, "country");
cust_addr.s_zip = BriteRequest.getParameter(request, "zip");
cust_addr.s_phone = BriteRequest.getParameter(request, "phone");
cust_addr.s_fax = BriteRequest.getParameter(request, "fax");

cust_addr.save();

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "cust_addr_edit.jsp?cust_id=<%=cust_addr.s_cust_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
