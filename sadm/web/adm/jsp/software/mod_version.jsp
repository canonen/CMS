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
	<TITLE>Module Version</TITLE>
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

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("mod_version.jsp");
	stmt = conn.createStatement();
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
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Module Version</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form method="post" name="FT" action="mod_version_save.jsp">
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="100">Module</td>
								<td>
									<select name=mod_id>
									<%
									sSQL  = " SELECT mod_id, mod_name FROM sadm_module";
									
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
								<td width="100">Version</td>
								<td><input type=text name=version value="<%=((sVersion != null)?sVersion:"")%>"></td>
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
