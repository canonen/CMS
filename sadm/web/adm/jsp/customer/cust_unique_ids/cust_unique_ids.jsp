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
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:650;">
				<col width="150">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Unique IDs</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form name="FT" method="POST" action="cust_unique_ids_save.jsp">
						<input type="hidden" name="cust_id" value="<%=cust.s_cust_id%>">
						<table class="listTable" border="0" cellspacing="0" cellpadding="3" width="100%">
							<tr>
								<th>Type</th>
								<th>Allocated</th>
								<th>Minimum</th>
								<th>Maximum</th>
							</tr>
						<%
							try
							{
								sSql  = " SELECT uit.type_id, uit.type_name,";
								sSql += 	" cui.cust_id, cui.min_id, cui.max_id, allocated = cui.max_id - cui.min_id + 1";
								sSql += " FROM sadm_unique_id_type uit";
								sSql += 	" LEFT OUTER JOIN sadm_cust_unique_id cui";
								sSql += 		" ON ( uit.type_id = cui.type_id )";
								sSql += 			" AND ( cui.cust_id = ? )";
								sSql += " WHERE ( uit.type_id not in (180,220))"; //paragraph_id, camp_form_id,
								sSql += " ORDER BY uit.type_name";

								pstmt = conn.prepareStatement(sSql);
								pstmt.setString(1, sCustId);
								rs = pstmt.executeQuery();
								
								String sTypeId = null;
								String sTypeName = null;
								String sId = null;
								String sMinId = null;
								String sMaxId = null;
								String sAllocated = null;
								
								while (rs.next())
								{
									sTypeId = rs.getString(1);
									sTypeName = rs.getString(2);
									sId = rs.getString(3);
									sMinId = rs.getString(4);
									sMaxId = rs.getString(5);
									sAllocated = rs.getString(6);
						%>
							<tr>
								<td>
									<%=sTypeName%>
								</td>
								<td align="left">
									<input type="text" name="allocated" value=<%=(sAllocated==null)?"":sAllocated + " disabled"%>>
									<input type="hidden" name="type_id" value=<%=sTypeId%> <%=(sAllocated==null)?"":"disabled"%>>
								</td>
								<td align="left">
									<input type="text" name="min_id" value="<%=(sMinId==null)?"not allocated":sMinId%>" disabled>
								</td>
								<td align="left">
									<input type="text" name="max_id" value="<%=(sMaxId==null)?"not allocated":sMaxId%>" disabled>
								</td>
							</tr>
						<%
								}
								rs.close();
							}
							catch(Exception ex) { throw ex; }
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