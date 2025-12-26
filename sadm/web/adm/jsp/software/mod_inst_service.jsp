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
<%@ include file="../header.jsp" %>
<HTML>
<HEAD>
	<TITLE>Module Instance Service</TITLE>
	<%@ include file="../header.html" %>
	<LINK rel="stylesheet" href="../../css/style.css" type="text/css">
</HEAD>
<BODY>
<%
ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;
ResultSet	rs = null; 
String sSQL = null;

String sModInstID = BriteRequest.getParameter(request, "mod_inst_id");
String sServTypeID = BriteRequest.getParameter(request, "service_type_id");

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("mod_inst_service.jsp");
	stmt = conn.createStatement();

	String sProtocol = "";
	String sPort = "";
	String sPath = "";

	if (sServTypeID != null) {
		sSQL  = " select protocol, port, path FROM sadm_mod_inst_service"
			+ " WHERE mod_inst_id = "+sModInstID
			+ "  AND  service_type_id = "+sServTypeID;

	 	rs = stmt.executeQuery(sSQL);
		while(rs.next()) {
			sProtocol = rs.getString(1);
			sPort = rs.getString(2);
			sPath = rs.getString(3);
		}
		rs.close();
	}
	%>
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
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Module Instance Service</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form method="post" name="FT" action="mod_inst_service_save.jsp">
						<table border="1" cellspacing="0" width="100%">
							<tr>
								<td width="100">Module Instance</td>
								<td>
									<select name=mod_inst_id>
									<%
									sSQL  = " select mod_inst_id FROM sadm_mod_inst";
							 		
 									rs = stmt.executeQuery(sSQL);
							 		
									String sID = null;
									
									while(rs.next())
									{
										sID = rs.getString(1);
										%>
										<option value="<%=sID%>"<%=((sID.equals(sModInstID))?" selected":"")%>><%=sID%></option>
										<%
									}
									rs.close();
									%>
									</select>
								</td>
							</tr>
							<tr>
								<td width="100">Service Type</td>
								<td>
									<select name=service_type_id>
									<%
									sSQL  = " select type_id, type_name FROM sadm_service_type ORDER BY type_name";
							 		
 									rs = stmt.executeQuery(sSQL);
									
									String sTypeID = null;
									String sTypeName = null;
									
									while(rs.next())
									{
										sTypeID = rs.getString(1);
										sTypeName = rs.getString(2);
										%>
										<option value="<%=sTypeID%>"<%=((sTypeID.equals(sServTypeID))?" selected":"")%>><%=sTypeName%></option>
										<%
									}
									
									rs.close();
									%>
									</select>
								</td>
							</tr>
							<tr>
								<td width="100">Protocol</td>
								<td><input type=text name=protocol value="<%=sProtocol%>" size="10"></td>
							</tr>
							<tr>
								<td width="100">Port</td>
								<td><input type=text name=port value="<%=sPort%>" size="5"></td>
							</tr>
							<tr>
								<td width="100">Path</td>
								<td><input type=text name=path value="<%=sPath%>" size="40"></td>
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
	<%
}
catch(Exception ex)
{
	out.print(sSQL);
	ex.printStackTrace(response.getWriter());
}
finally
{
	if(conn!=null) cp.free(conn);
}

%>
</BODY>
</HTML>
