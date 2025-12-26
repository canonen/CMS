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
if( cust.s_cust_id == null) throw new Exception(this.getClass().getName() + ": cust_id is null");

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
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
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:350;">
				<col width="150">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Partners</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form name="FT" method="POST" action="cust_partners_save.jsp">
						<input type="hidden" name="cust_id" value="<%=cust.s_cust_id%>">
						<table class="listTable" border="0" cellspacing="0" cellpadding="3" width="100%">
							<tr>
								<th>Partner</th>
								<th>&nbsp;</th>
							</tr>
						<%
							try
							{
								sSql  = " SELECT p.partner_id, p.partner_name, cp.cust_id";
								sSql += " FROM sadm_partner p";
								sSql += 	" LEFT OUTER JOIN sadm_cust_partner cp";
								sSql += 		" ON ( p.partner_id = cp.partner_id )";
								sSql += 			" AND ( cp.cust_id = ? )";
								sSql += " ORDER BY p.partner_name";

								pstmt = conn.prepareStatement(sSql);
								pstmt.setString(1, sCustId);
								rs = pstmt.executeQuery();
								
								String sPartnerId = null;
								String sPartnerName = null;
								String sId = null;
								
								while (rs.next())
								{
									sPartnerId = rs.getString(1);
									sPartnerName = rs.getString(2);
									sId = rs.getString(3);
						%>
							<tr>
								<td class="listItem_Data"><%= sPartnerName %></td>
								<td class="listItem_Data" align="center"><input type="checkbox" name="partner_id" value=<%=sPartnerId%> <%=(sId!=null)?"checked":""%>></td>
							</tr>
						<%
								}
								rs.close();
							}
							catch(Exception ex) { throw ex;	}
							finally { if(pstmt != null) pstmt.close(); }
						%>
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
<%
}
catch(Exception ex) { throw ex; }
finally { if(conn != null) cp.free(conn); }
%>