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
CustCredit cust_credit = new CustCredit();

String cust_id 			= BriteRequest.getParameter(request, "cust_id");
String allocated_credit = BriteRequest.getParameter(request, "allocated_credit");
String used_credit 		= BriteRequest.getParameter(request, "used_credit");
String remaining_credit = BriteRequest.getParameter(request, "remaining_credit");
String credit	 		= BriteRequest.getParameter(request, "credit");


int i_credit 			= Integer.parseInt(credit);
int i_used_credit 		= Integer.parseInt(used_credit);
int i_allocated_credit 	= Integer.parseInt(allocated_credit);
int i_remaining_credit 	= Integer.parseInt(remaining_credit);

i_remaining_credit = i_remaining_credit + i_credit;
i_allocated_credit = i_allocated_credit + i_credit;

cust_credit.s_cust_id = cust_id;
cust_credit.s_allocated_credit = Integer.toString(i_allocated_credit);
cust_credit.s_used_credit = Integer.toString(i_used_credit);
cust_credit.s_remaining_credit = Integer.toString(i_remaining_credit);
cust_credit.m_sSaveSql = "EXECUTE usp_sadm_cust_credit_save @cust_id=?, @allocated_credit=?, @used_credit=?, @remaining_credit=?";

cust_credit.save();


%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
		<SCRIPT>
			self.location.href = "cust_credit_edit.jsp?cust_id=<%=cust_credit.s_cust_id%>";
			alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>