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
if( cust.s_cust_id == null) {
	logger.error(this.getClass().getName() + ": cust_id is null");
	throw new Exception(this.getClass().getName() + ": cust_id is null");
}

CustSendParam cust_send_param = new CustSendParam(sCustId);
%>

<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
</HEAD>
<body>

<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
	<col>
	<tr height="35">
		<td valign="top">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="FT.submit()">Save</a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
			<br>
		</td>
	</tr>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:500;">
				<col width="150">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Send Params</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form name="FT" method="POST" action="cust_send_param_save.jsp">
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="200">Cust ID</td>
								<td><input type="text" name="cust_id" size="50" readonly value="<%=cust_send_param.s_cust_id%>"></td>
							</tr>
							<tr>
								<td width="200">Errors-To Address</td>
								<td><input type="text" name="error_to_address" size="50" value="<%=HtmlUtil.escape(cust_send_param.s_error_to_address)%>"></td>
							</tr>
							<tr>
								<td width="200">Sender Address (for sender ID) </td>
								<td><input type="text" name="sender_address" size="50" value="<%=HtmlUtil.escape(cust_send_param.s_sender_address)%>"></td>
							</tr>
						</table>
						</form>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>
