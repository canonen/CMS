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

CustUniqueIds cuis = new CustUniqueIds();
CustUniqueId cui = null;

String[] sTypeIds = BriteRequest.getParameterValues(request, "type_id");
String[] sAllocated = BriteRequest.getParameterValues(request, "allocated");

int l = ( sTypeIds == null )?0:sTypeIds.length;

for (int i = 0; i < l; i++)
{
	if(sAllocated[i].trim().length() > 0)
	{
		cui = new CustUniqueId();
		cui.s_cust_id = cust.s_cust_id;
		cui.s_type_id = sTypeIds[i];
		cui.s_min_id = "-" + sAllocated[i];
		cui.s_max_id = "0";
		cuis.add(cui);
	}
}

cuis.save();

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "cust_unique_ids.jsp?cust_id=<%=cust.s_cust_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
