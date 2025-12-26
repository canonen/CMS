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
CustAddr cust_addr = new CustAddr(sCustId);
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
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:650;">
				<col width="200">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Customer Address and Phone</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form name="FT" method="POST" action="cust_addr_save.jsp">
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150">cust_id</td>
								<td><INPUT type="text" name="cust_id" size="50" readonly value="<%=cust_addr.s_cust_id%>"></td>
							</tr>
							<tr>
								<td width="150">address1</td>
								<td><INPUT type="text" name="address1" size="50" value="<%=(cust_addr.s_address1==null)?"":cust_addr.s_address1%>"></td>
							</tr>
							<tr>
								<td width="150">address2</td>
								<td><INPUT type="text" name="address2" size="50" value="<%=(cust_addr.s_address2==null)?"":cust_addr.s_address2%>"></td>
							</tr>
							<tr>
								<td width="150">city</td>
								<td><INPUT type="text" name="city" size="50" value="<%=(cust_addr.s_city==null)?"":cust_addr.s_city%>"></td>
							</tr>
							<tr>
								<td width="150">state</td>
								<td><INPUT type="text" name="state" size="50" value="<%=(cust_addr.s_state==null)?"":cust_addr.s_state%>"></td>
							</tr>
							<tr>
								<td width="150">zip</td>
								<td><INPUT type="text" name="zip" size="50" value="<%=(cust_addr.s_zip==null)?"":cust_addr.s_zip%>"></td>
							</tr>
							<tr>
								<td width="150">country</td>
								<td><INPUT type="text" name="country" size="50" value="<%=(cust_addr.s_country==null)?"":cust_addr.s_country%>"></td>
							</tr>
							<tr>
								<td width="150">phone</td>
								<td><INPUT type="text" name="phone" size="50" value="<%=(cust_addr.s_phone==null)?"":cust_addr.s_phone%>"></td>
							</tr>
							<tr>
								<td width="150">fax</td>
								<td><INPUT type="text" name="fax" size="50" value="<%=(cust_addr.s_fax==null)?"":cust_addr.s_fax%>"></td>
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
