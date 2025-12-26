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
String sAllocate = BriteRequest.getParameter(request, "allocate");


String sSql = 
	" EXEC usp_sadm_cust_unique_id_reallocate" +
	" @cust_id=" + sCustId +
	", @type_id=" + sTypeId +
	", @allocate=" + sAllocate;

logger.info(sSql);

BriteUpdate.executeUpdate(sSql);

%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
</HEAD>

<BODY>
IDs reallocated.
<P>
Now <a href="../sync/sync_list.jsp?cust_id=<%=sCustId%>">Sync</a>.

</BODY>
</HTML>
