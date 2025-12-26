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
String sMsgId = BriteRequest.getParameter(request, "msg_id");

UnsubMsg um = null;

if( sMsgId == null)
{
	um = new UnsubMsg();
	um.s_cust_id = sCustId;
}
else um = new UnsubMsg(sMsgId);

um.s_msg_name = BriteRequest.getParameter(request, "msg_name");
um.s_text_msg = BriteRequest.getParameter(request, "text_msg");
um.s_html_msg = BriteRequest.getParameter(request, "html_msg");

um.save();
%>

<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<SCRIPT>
		parent.location.href = "unsub_msg_frame.jsp?cust_id=<%=um.s_cust_id%>&msg_id=<%=um.s_msg_id%>";
		alert("Saved!");
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>
