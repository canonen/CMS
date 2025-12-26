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
String sTypeId = BriteRequest.getParameter(request, "type_id");
int nTypeId = Integer.parseInt(sTypeId);

String sTypeName = null;
switch (nTypeId)
{
	case 110 : sTypeName = "Recipient IDs"; break;
	case 130 : sTypeName = "Link IDs"; break;
	case 140 : sTypeName = "Form IDs"; break;
	case 150 : sTypeName = "Batch IDs"; break;
	case 160 : sTypeName = "Import IDs"; break;
	case 170 : sTypeName = "Content IDs"; break;
	case 180 : sTypeName = "Paragraph IDs"; break;
	case 190 : sTypeName = "Campaign IDs"; break;
	case 200 : sTypeName = "Filter IDs"; break;
	case 210 : sTypeName = "Formula IDs"; break;
	case 220 : sTypeName = "Campaign Form IDs"; break;
}	


CustUniqueId cui = new CustUniqueId(sTypeId, sCustId);

int nAlloc = -1;
if((cui.s_min_id != null)&&(cui.s_max_id != null))
{
	int nCurMin = Integer.parseInt(cui.s_min_id);
	int nCurMax = Integer.parseInt(cui.s_max_id);
	nAlloc = nCurMax - nCurMin + 1;
}

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
</HEAD>

<BODY>
<FORM action="cust_unique_id_reallocate.jsp">
<INPUT type="hidden" name="cust_id" value="<%=sCustId%>">
<INPUT type="hidden" name="type_id" value="<%=sTypeId%>">
<BR>
Allocate <INPUT type="text" name="allocate" value="<%=(nAlloc<1000000)?nAlloc:1000000%>"> 
additional <%=sTypeName%> for Customer <%=sCustId%> (<%=nAlloc%> last allocated).
<BR>
<INPUT type="submit">
<BR>
</FORM>
</BODY>
</HTML>


