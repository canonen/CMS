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
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Vanity Domains</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form name="FT" method="POST" action="vanity_domains_save.jsp">
						<input type="hidden" name="cust_id" value="<%=cust.s_cust_id%>">
						<table class="listTable" border="0" cellspacing="0" cellpadding="3" width="100%">
							<tr>
								<th>Module</th>
								<!--<th>Version</th>//-->
								<th>Machine</th>
								<th>Ip Address</th>
								<th>Domain</th>
							</tr>
						<%
							try
							{
								sSql  = " SELECT mo.abbreviation, ma.machine_name, ma.ip_address,";
								sSql += 	" mi.mod_inst_id, mi.version, cmi.cust_id, vd.domain_id, vd.domain";
								sSql += " FROM sadm_module mo";
								sSql += 	" INNER JOIN sadm_mod_inst mi ON ( mo.mod_id = mi.mod_id )";
								sSql += 	" INNER JOIN sadm_machine ma ON ( ma.machine_id = mi.machine_id )";
								sSql += 	" INNER JOIN (sadm_cust_mod_inst cmi";
								sSql += 			" LEFT OUTER JOIN sadm_vanity_domain vd";
								sSql += 				" ON ( cmi.mod_inst_id = vd.mod_inst_id )";
								sSql += 					" AND ( cmi.cust_id = vd.cust_id ))";
								sSql += 		" ON ( mi.mod_inst_id = cmi.mod_inst_id )";
								sSql += 			" AND ( cmi.cust_id = ? )";
								sSql += " ORDER BY mo.abbreviation, ma.ip_address";

								pstmt = conn.prepareStatement(sSql);
								pstmt.setString(1, cust.s_cust_id);
								rs = pstmt.executeQuery();
								
								String sAbbreviation = null;
								String sMachineName = null;
								String sIpAddress = null;
								String sModInstId = null;
								String sVersion = null;
								String sId = null;
								String sDomainId = null;
								String sDomain = null;
								
								while (rs.next())
								{
									sAbbreviation = rs.getString(1);
									sMachineName = rs.getString(2);
									sIpAddress = rs.getString(3);
									sModInstId = rs.getString(4);
									sVersion = rs.getString(5);
									sId = rs.getString(6);
									sDomainId = rs.getString(7);
									sDomain = rs.getString(8);
						%>
							<tr>
								<td class="listItem_Data"><%=sAbbreviation%> (<%=sModInstId%>)</td>
								<!--<td class="listItem_Data">v. <%=sVersion%></td>//-->
								<td class="listItem_Data"><%=sMachineName%></td>
								<td class="listItem_Data"><%=sIpAddress%></td>
								<td class="listItem_Data" align="center">
									<input type="hidden" name="domain_id" value="<%=(sDomainId==null)?"":sDomainId%>">
									<input type="hidden" name="mod_inst_id" value="<%=(sModInstId==null)?"":sModInstId%>">
									<input type="text" name="domain"  size="50" value="<%=(sDomain==null)?"":sDomain%>">
								</td>
							</tr>
						<%
								}
								rs.close();
							}
							catch(SQLException sqlex)
							{
								throw sqlex;
							}
							finally
							{
								if(pstmt != null) pstmt.close();
							}
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
catch(SQLException sqlex)
{
	throw sqlex;
}
finally
{
	if(conn != null) cp.free(conn);
}
%>