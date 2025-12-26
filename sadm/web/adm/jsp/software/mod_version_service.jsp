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
	<TITLE>Module Version Service</TITLE>
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

String sModID = BriteRequest.getParameter(request, "mod_id");
String sVersion = BriteRequest.getParameter(request, "version");
String sServTypeID = BriteRequest.getParameter(request, "service_type_id");

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("mod_version_service.jsp");
	stmt = conn.createStatement();

	String sProtocol = "";
	String sPort = "";
	String sPath = "";

	if (sServTypeID != null)
	{
		sSQL  = " select protocol, port, path FROM sadm_mod_version_service"
			+ " WHERE mod_id = "+sModID
			+ "  AND  version = '"+sVersion+"'"
			+ "  AND  service_type_id = "+sServTypeID;

	 	rs = stmt.executeQuery(sSQL);
	 	
		while(rs.next())
		{
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
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Module Version Service</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form method="post" name="FT" action="mod_version_service_save.jsp">
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="125">Module</td>
								<td>
									<select name=mod_id>
									<%
									sSQL  = " select mod_id, mod_name FROM sadm_module";
 									rs = stmt.executeQuery(sSQL);
									String sID = null;
									String sName = null;
									while(rs.next())
									{
										sID = rs.getString(1);
										sName = rs.getString(2);
										%>
										<option value="<%=sID%>"<%=((sID.equals(sModID))?" selected":"")%>><%=sName%></option>
										<%
									}
									rs.close();
									%>
									</select>
								</td>
							</tr>
							<tr>
								<td width="125">Version</td>
								<td>
									<select name=version>
									<%
									sSQL  = " select m.mod_id, m.mod_name, v.version FROM sadm_module m, sadm_mod_version v WHERE m.mod_id = v.mod_id";
 									rs = stmt.executeQuery(sSQL);
									String sVer = null;
									while(rs.next())
									{
										sID = rs.getString(1);
										sName = rs.getString(2);
										sVer = rs.getString(3);
										%>
										<option value="<%=sVer%>"<%=((sVer.equals(sVersion))?" selected":"")%>><%=sVer%> (Module: <%=sName%>)</option>
										<%
									}
									rs.close();
									%>
									</select>
								</td>
							</tr>
							<tr>
								<td width="125">Service Type</td>
								<td>
									<select name=service_type_id>
									<%
									sSQL  = " select type_id, type_name FROM sadm_service_type";
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
								<td width="125">Protocol</td>
								<td><input type=text name=protocol value="<%=sProtocol%>" size="10"></td>
							</tr>
							<tr>
								<td width="125">Port</td>
								<td><input type=text name=port value="<%=sPort%>" size="5"></td>
							</tr>
							<tr>
								<td width="125">Path</td>
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
