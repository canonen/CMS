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
String sUserId = BriteRequest.getParameter(request, "system_user_id");

SystemUser user = null;

if( sUserId == null)
{
	user = new SystemUser();
}
else
{
	user = new SystemUser(sUserId);	
}
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
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">User Info</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form name="FT" method="POST" action="user_save.jsp">
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
						<% if(user.s_system_user_id != null) { %>
							<tr>
								<td width="75">User ID</td>
								<td><input type="text" name="system_user_id" size="50" readonly value="<%=user.s_system_user_id%>"></td>
							</tr>
						<% } %>
							<tr>
								<td width="75">First name</td>
								<td><input type="text" name="first_name" size="50" value="<%=(user.s_first_name==null)?"":user.s_first_name%>"></td>
							</tr>
							<tr>
								<td width="75">Last name</td>
								<td><input type="text" name="last_name" size="50" value="<%=(user.s_last_name==null)?"":user.s_last_name%>"></td>
							</tr>
							<tr>
								<td width="75">Login Name</td>
								<td><input type="text" name="username" size="50" value="<%=(user.s_username==null)?"":user.s_username%>"></td>
							</tr>
							<tr>
								<td width="75">Password</td>
								<td><input type="text" name="password" size="50" value="<%=(user.s_password==null)?"":user.s_password%>"></td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="75">Email</td>
								<td><input type="text" name="email" size="50" value="<%=(user.s_email_address==null)?"":user.s_email_address%>"></td>
							</tr>
							<tr>
								<td width="75">Phone</td>
								<td><input type="text" name="phone" size="50" value="<%=(user.s_phone==null)?"":user.s_phone%>"></td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="75">Status</td>
								<td>
									<select size="1" name="status_id">
										<%=UserStatus.toHtmlOptions(user.s_status_id)%>			
									</select>
								</td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="75">Partner</td>
								<td>
									<select size="1" name="partner_id">
								<%
								ConnectionPool cp = null;
								Connection conn = null;
								Statement	stmt = null;
								ResultSet	rs = null; 
								String sSQL = null;

								try
								{
									cp = ConnectionPool.getInstance();
									conn = cp.getConnection(this);
									stmt = conn.createStatement();

									sSQL =
										" SELECT partner_id, partner_name" +
										" FROM sadm_partner" +
										" ORDER BY partner_name";
										
									String sPartnerID = "";
									String sPartnerName = "";
									byte[] b = null;
									
									rs = stmt.executeQuery(sSQL);
									while(rs.next())
									{
										sPartnerID = rs.getString(1);
										b = rs.getBytes(2);
										sPartnerName = (b==null)?"":new String(b,"UTF-8");
										%>
										<option value="<%= sPartnerID %>"<%= (sPartnerID.equals(user.s_partner_id))?" selected":"" %>><%= sPartnerName %></option>
										<%
									}
									
									rs.close();
								}
								catch(Exception ex)
								{
									ex.printStackTrace(response.getWriter());
								}
								finally
								{
									if(conn!=null) cp.free(conn);
								}
								%>			
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
