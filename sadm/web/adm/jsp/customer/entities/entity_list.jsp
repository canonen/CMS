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
<%@ include file="/adm/jsp/header.jsp" %>
<%
	String sCustId = BriteRequest.getParameter(request, "cust_id");
%>

<HTML>
<HEAD>
	<%@ include file="/adm/jsp/header.html" %>
	<link rel="stylesheet" href="../../../css/style.css" TYPE="text/css">
	<BASE target="main_02">
</HEAD>
<BODY>
<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="savebutton" href="entity_edit_frame.jsp?cust_id=<%= sCustId %>">New entity</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table cellspacing="0" cellpadding="0" width="100%" border="0">
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100% colspan=2><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab>
			<table width=100% class=main border="0" cellspacing="1" cellpadding="2">
				<tr>
					<td align="left" valign="middle" class="pageheader">Entities</td>
				</tr>
				<tr>
					<td align="left" valign="middle" style="padding:10px;">
<table border="0" cellspacing="0" cellpadding="2">
<%
	Entities entities = new Entities();
	entities.s_cust_id = sCustId;
	entities.retrieve();
	
	Entity entity = null;
	for (Enumeration e = entities.elements() ; e.hasMoreElements() ;)
	{
		entity = (Entity)e.nextElement();
%>
	<tr>
		<td colspan="3">
			<a href="entity_edit_frame.jsp?entity_id=<%=entity.s_entity_id%>">
				<b><LI><%=entity.s_entity_name%></b>
			</a>
		</td>	
	</tr>
<%
	}
%>
	<tr>
		<td colspan="3"><b><LI>recipient</b></td>
	</tr>
	<tr>
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td>1</td>
		<td><a href="recipient/cust_attr_frame.jsp?cust_id=<%= sCustId %>">Attributes</a></td>
	</tr>
	<tr>
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td>2</td>
		<td><a href="recipient/fingerprint.jsp?cust_id=<%= sCustId %>">Fingerprint</a></td>
	</tr>
</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

</BODY>
</HTML>