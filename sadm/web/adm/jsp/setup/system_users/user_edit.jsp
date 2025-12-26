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
String sUserId = BriteRequest.getParameter(request, "user_id");

User user = null;
UserUiSettings uus = null;

if( sUserId == null)
{
	String sCustId = BriteRequest.getParameter(request, "cust_id");
	user = new User();
	user.s_cust_id = sCustId;
	uus = new UserUiSettings();	
}
else
{
	user = new User(sUserId);
	uus = new UserUiSettings(sUserId);	
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
						<% if(user.s_user_id != null) { %>
							<tr>
								<td width="75">User ID</td>
								<td><input type="text" name="user_id" size="50" readonly value="<%=user.s_user_id%>"></td>
							</tr>
						<% } %>
							<tr>
								<td width="75">First name</td>
								<td><input type="text" name="user_name" size="50" value="<%=(user.s_user_name==null)?"":user.s_user_name%>"></td>
							</tr>
							<tr>
								<td width="75">Last name</td>
								<td><input type="text" name="last_name" size="50" value="<%=(user.s_last_name==null)?"":user.s_last_name%>"></td>
							</tr>
							<tr>
								<td width="75">Cust ID</td>
								<td><input type="text" name="cust_id" size="50" readonly value="<%=(user.s_cust_id==null)?"":user.s_cust_id%>"></td>
							</tr>
							<tr>
								<td width="75">Login Name</td>
								<td><input type="text" name="login_name" size="50" value="<%=(user.s_login_name==null)?"":user.s_login_name%>"></td>
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
								<td><input type="text" name="email" size="50" value="<%=(user.s_email==null)?"":user.s_email%>"></td>
							</tr>
							<tr>
								<td width="75">Phone</td>
								<td><input type="text" name="phone" size="50" value="<%=(user.s_phone==null)?"":user.s_phone%>"></td>
							</tr>
							<tr>
								<td width="75">Position</td>
								<td><input type="text" name="position" size="50" value="<%=(user.s_position==null)?"":user.s_position%>"></td>
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
								<td width="75">UI Type</td>					
								<td>
									<select name="ui_type_id">
										<option value="<%=UIType.STANDARD%>" <%=(String.valueOf(UIType.STANDARD).equals(uus.s_ui_type_id))?"selected":""%>>Standard</option>
										<option value="<%=UIType.ADVANCED%>" <%=(String.valueOf(UIType.ADVANCED).equals(uus.s_ui_type_id))?"selected":""%>>Advanced</option>
										<option value="<%=UIType.HYATT_USER%>" <%=(String.valueOf(UIType.HYATT_USER).equals(uus.s_ui_type_id))?"selected":""%>>Hyatt User</option>
										<option value="<%=UIType.HYATT_ADMIN%>" <%=(String.valueOf(UIType.HYATT_ADMIN).equals(uus.s_ui_type_id))?"selected":""%>>Hyatt Admin</option>
									</select>
								</td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="75">Recip Owner?</td>
								<td>
									<select size="1" name="recip_owner">
										<option value="0"<%=("0".equals(user.s_recip_owner))?" selected":""%>>NO</option>
										<option value="1"<%=("1".equals(user.s_recip_owner))?" selected":""%>>YES</option>			
									</select>
								</td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="75">Recip View Record Count</td>					
								<td>
									<input type="text" name="recip_view_count" size="20" value="<%= (uus.s_recip_view_count == null)?"500":uus.s_recip_view_count %>">
								</td>
							</tr>
							<tr>
								<td width="75">Default Page Size</td>					
								<td>
									<select name="default_page_size">
										<option value="10"<%=("10".equals(uus.s_default_page_size))?" selected":""%>>10</option>
										<option value="25"<%=(("25".equals(uus.s_default_page_size)) || (uus.s_default_page_size == null))?" selected":""%>>25</option>
										<option value="50"<%=("50".equals(uus.s_default_page_size))?" selected":""%>>50</option>
										<option value="100"<%=("100".equals(uus.s_default_page_size))?" selected":""%>>100</option>
										<option value="1000"<%=("1000".equals(uus.s_default_page_size))?" selected":""%>>ALL</option>
									</select>
								</td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="75">Description</td>
								<td>
									<textarea rows="5" name="descrip" cols="40"><%=(user.s_descrip==null)?"":user.s_descrip%></textarea>
								</td>
							</tr>
						</table>
						<!-- added for release 5.9 , pviq changes -->
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="75">PV Login Name</td>
								<td><input type="text" name="pv_login" size="50" value="<%=(user.s_pv_login==null)?"":user.s_pv_login%>"></td>
							</tr>
							<tr>
								<td width="75">PV Password</td>
								<td><input type="text" name="pv_password" size="50" value="<%=(user.s_pv_password==null)?"":user.s_pv_password%>"></td>
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
