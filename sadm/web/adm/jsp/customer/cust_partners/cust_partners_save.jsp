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
Customer cust = new Customer(sCustId);

CustPartners cps = new CustPartners();
cps.s_cust_id = cust.s_cust_id;
cps.retrieve();
cps.delete();

cps = new CustPartners();
CustPartner cp = null;

String[] sPartnerIds = BriteRequest.getParameterValues(request, "partner_id");

int l = ( sPartnerIds == null )?0:sPartnerIds.length;

for (int i = 0; i < l; i++)
{
	cp = new CustPartner();
	cp.s_cust_id = cust.s_cust_id;
	cp.s_partner_id = sPartnerIds[i];
	cps.add(cp);
}

cps.save();

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "cust_partners.jsp?cust_id=<%=cust.s_cust_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
