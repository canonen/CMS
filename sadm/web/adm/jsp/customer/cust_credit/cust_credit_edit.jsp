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
CustCredit cust_credit = new CustCredit(sCustId);
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
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Customer Credit</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form name="FT" method="POST" action="cust_credit_save.jsp">
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150">cust_id</td>
								<td><INPUT type="text" name="cust_id" size="50" readonly value="<%=cust_credit.s_cust_id%>"></td>
							</tr>
							<tr>
								<td width="150">Allocated Credit</td>
								<td><input type="text" name="allocated_credit" size="50" readonly value="<%=(cust_credit.s_allocated_credit == null ? 0 : cust_credit.s_allocated_credit)%>"></td>
							</tr>
							<tr>
								<td width="150">Used Credit</td>
								<td><input type="text" name="used_credit" size="50" readonly value="<%=(cust_credit.s_used_credit == null ? 0 : cust_credit.s_used_credit)%>"></td>
							</tr>
							<tr>
								<td width="150">Remaining Credit</td>
								<td><input type="text" name="remaining_credit" size="50" readonly value="<%=(cust_credit.s_remaining_credit == null ? 0 : cust_credit.s_remaining_credit)%>"></td>
							</tr>
							<tr>
								<td width="150">Add Credit</td>
								<td>
									<select name="credit">
										<option value="0"> -- Add new credit --</option>
										<option value="5000"> 5.000</option>
										<option value="10000"> 10.000</option>
										<option value="20000"> 20.000</option>
										<option value="50000"> 50.000</option>
										<option value="100000"> 100.000</option>
									</select>
								</td>
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
