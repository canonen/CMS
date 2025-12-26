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
	<style type="text/css">
		input
		{
			border-top: 1px solid #676767;
			border-left: 1px solid #676767;
			border-right: 1px solid #000000;
			border-bottom: 1px solid #000000;
		}
	</style>
</HEAD>

<BODY>

<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
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
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
				<col width="200">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Customer Specific Services</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<div style="width:100%; height:100%; overflow:auto;">
						<form name="FT" method="POST" action="cust_mod_inst_services_save.jsp">
						<input type="hidden" name="cust_id" value="<%=cust.s_cust_id%>">
						<table border="0" cellspacing="0" cellpadding="3" class="listTable layout" style="width:100%;">
							<col>
							<col>
							<col width="150">
							<col width="70">
							<col>
							<col width="50">
							<col width="200">
							<tr>
								<th  nowrap>Module</th>
								<!--<th nowrap>Version</th>//-->
								<th nowrap>Machine</th>
								<th nowrap>Service</th>
								<th nowrap>Protocol</th>
								<th nowrap>Ip Address</th>
								<th nowrap>Port</th>
								<th nowrap>Path</th>
							</tr>
						<%
							try
							{
								sSql  = " SELECT mo.abbreviation, ma.machine_name, ma.ip_address,";
								sSql += 	" mi.mod_inst_id, mi.version,";
								sSql += 	" st.type_id, st.type_name,";
								sSql += 	" cmis.cust_id, cmis.protocol, cmis.port, cmis.path";
								sSql += " FROM sadm_module mo";
								sSql += 	" INNER JOIN sadm_mod_inst mi"; 
								sSql += 		" ON mo.mod_id = mi.mod_id";
								sSql += 		" INNER JOIN sadm_machine ma ON mi.machine_id = ma.machine_id";
								sSql += 		" INNER JOIN sadm_mod_version_service mvs";
								sSql += 			" ON mi.mod_id = mvs.mod_id";
								sSql += 				" AND mi.version = mvs.version";
								sSql += 			" INNER JOIN sadm_service_type st ON mvs.service_type_id = st.type_id";
								sSql += 		" INNER JOIN sadm_cust_mod_inst cmi";
								sSql += 			" ON mi.mod_inst_id = cmi.mod_inst_id";
								sSql += 			" LEFT OUTER JOIN sadm_cust_mod_inst_service cmis";
								sSql +=					" ON cmi.mod_inst_id = cmis.mod_inst_id";
								sSql += 					" AND cmi.cust_id = cmis.cust_id";
								sSql += 					" AND mvs.service_type_id = cmis.service_type_id";
								sSql += " WHERE ( cmi.cust_id = ? )";
								sSql += " ORDER BY mo.abbreviation, ma.ip_address";

								pstmt = conn.prepareStatement(sSql);
								pstmt.setString(1, cust.s_cust_id);
								rs = pstmt.executeQuery();
								
								String sAbbreviation = null;
								String sMachineName = null;
								String sIpAddress = null;
								String sModInstId = null;
								String sVersion = null;
								String sServiceTypeId = null;
								String sServiceTypeName = null;
								String sId = null;
								String sProtocol = null;
								String sPort = null;
								String sPath = null;
								
								while (rs.next())
								{
									sAbbreviation = rs.getString(1);
									sMachineName = rs.getString(2);
									sIpAddress = rs.getString(3);
									sModInstId = rs.getString(4);
									sVersion = rs.getString(5);
									sServiceTypeId = rs.getString(6);
									sServiceTypeName = rs.getString(7);
									sId = rs.getString(8);
									sProtocol = rs.getString(9);
									sPort = rs.getString(10);
									sPath = rs.getString(11);
						%>
							<tr>
								<td align="left" nowrap class="listItem_Data" style="font-size:7pt;"><%=sAbbreviation%> (<%=sModInstId%>)</td>
								<!--<td align="left" nowrap class="listItem_Data" style="font-size:7pt;">v. <%=sVersion%></td>//-->
								<td align="left" nowrap class="listItem_Data" style="font-size:7pt;"><%=sMachineName%></td>
								<td align="left" nowrap class="listItem_Data" style="font-size:7pt;"><%=sServiceTypeName%></td>
								<td align="center" nowrap class="listItem_Data">
									<input type="text" name="protocol"  size="1" value="<%=(sProtocol==null)?"":sProtocol%>">
								</td>
								<td align="left" nowrap class="listItem_Data" style="font-size:7pt;">://<%=sIpAddress%>:</td>
								<td align="center" nowrap class="listItem_Data">
									<input type="text" name="port"  size="1" value="<%=(sPort==null)?"":sPort%>">
								</td>
								<td align="center" nowrap class="listItem_Data">
									<input type="text" name="path"  size="30" value="<%=(sPath==null)?"":sPath%>">
								</td>
								<input type="hidden" name="is_new" value="<%=(sId==null)?"yes":"no"%>">
								<input type="hidden" name="mod_inst_id" value="<%=sModInstId%>">
								<input type="hidden" name="service_type_id" value="<%=sServiceTypeId%>">
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
						</div>
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