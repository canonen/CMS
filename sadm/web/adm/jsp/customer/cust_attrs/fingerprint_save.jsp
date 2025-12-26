<%@ page
	language="java"
	import="com.britemoon.*, com.britemoon.sas.*, com.britemoon.sas.adm.*, java.io.*,java.sql.*,java.util.*"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>

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
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "fingerprint.jsp?cust_id=<%=sCustId%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
