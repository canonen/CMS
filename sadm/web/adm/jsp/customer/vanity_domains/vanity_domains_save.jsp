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

VanityDomains vds = new VanityDomains();
VanityDomain vd = null;

String[] sDomainIds = BriteRequest.getParameterValues(request, "domain_id");
String[] sModInstIds = BriteRequest.getParameterValues(request, "mod_inst_id");
String[] sDomains = BriteRequest.getParameterValues(request, "domain");

String sDomainId = null;
String sModInstId = null;
String sDomain = null;

int l = ( sModInstIds == null )?0:sModInstIds.length;

for (int i = 0; i < l; i++)
{
	sDomainId = sDomainIds[i];
	sModInstId = sModInstIds[i];
	sDomain = sDomains[i];

	sDomainId = ("".equals(sDomainId))?null:sDomainId;
	sDomain = ("".equals(sDomain))?null:sDomain;

	if((sDomainId != null) || (sDomain != null))
	{
		vd = new VanityDomain();
		vd.s_domain_id = sDomainId;
		vd.s_cust_id = cust.s_cust_id;
		vd.s_mod_inst_id = sModInstId;
		vd.s_domain = sDomain;
		vds.add(vd);
	}
}

vds.save();

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "vanity_domains.jsp?cust_id=<%=cust.s_cust_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
