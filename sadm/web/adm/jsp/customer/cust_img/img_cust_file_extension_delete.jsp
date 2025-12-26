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

ImgCustFileExtension icfe = new ImgCustFileExtension();

icfe.s_cust_id = sCustId;
icfe.s_file_extension = BriteRequest.getParameter(request, "file_extension");
	
icfe.delete();
%>
<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		self.location.href = "img_cust_file_extensions.jsp?cust_id=<%=sCustId%>";
		alert("Deleted!");
	</SCRIPT>
</HEAD>
<BODY>
</BODY>
</HTML>
