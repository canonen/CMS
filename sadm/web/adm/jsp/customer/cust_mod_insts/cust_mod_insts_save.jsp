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
CustModInsts cmis = null; //new CustModInsts(cust);
//cmis.delete();

cmis = new CustModInsts();
CustModInst cmi = null;

String[] sModInstIds = BriteRequest.getParameterValues(request, "mod_inst_id");

int l = ( sModInstIds == null )?0:sModInstIds.length;

for (int i = 0; i < l; i++)
{
	cmi = new CustModInst();
	cmi.s_mod_inst_id = sModInstIds[i];
	cmi.s_cust_id = cust.s_cust_id;
	cmis.add(cmi);
}

cmis.save();

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "cust_mod_insts.jsp?cust_id=<%=cust.s_cust_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
