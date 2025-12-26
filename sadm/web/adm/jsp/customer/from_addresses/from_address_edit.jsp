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
String sFromAddressId = BriteRequest.getParameter(request, "from_address_id");

FromAddress fa = null;

if( sFromAddressId == null)
{
	fa = new FromAddress();
	fa.s_cust_id = sCustId;
}
else fa = new FromAddress(sFromAddressId);
%>
<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
</HEAD>
<BODY>

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
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
				<col width="150">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">From Address</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form name="FT" method="POST" action="from_address_save.jsp">
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="125">Cust ID</td>
								<td><input type="text" name="cust_id" size="50" readonly value=<%=fa.s_cust_id%>></td>
							</tr>
						<%
						if(fa.s_from_address_id != null)
						{
							%>
							<tr>
								<td width="125">From Address ID</td>
								<td><input type="text" name="from_address_id" size="50" readonly value=<%=fa.s_from_address_id%>></td>
							</tr>
							<%
						}
						%>
							<tr>
								<td width="125">Prefix</td>
								<td><input type="text" name="prefix" size="50" value=<%=(fa.s_prefix==null)?"":fa.s_prefix%>></td>
							</tr>
								<td colspan=2>@</td>
							</tr>
							</tr>
								<td width="125">Domain</td>
								<td><input type="text" name="domain" size="50" value=<%=(fa.s_domain==null)?"":fa.s_domain%>></td>
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
