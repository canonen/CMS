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

<%
String sCustId = BriteRequest.getParameter(request, "cust_id");

Customer cust = null;

if( sCustId == null) cust = new Customer();
else cust = new Customer(sCustId);

if(cust.s_parent_cust_id == null) cust.s_parent_cust_id = "0";
%>

<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../header.html" %>
	<LINK rel="stylesheet" href="../../css/style.css" type="text/css">
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
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Customer Info</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form name="FT" method="POST" action="cust_save.jsp">
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
						<% if(cust.s_cust_id != null) { %>
							<tr>
								<td width="150" title="cust_id">Customer ID</td>
								<td><INPUT type="text" name="cust_id" size="50" readonly value="<%=cust.s_cust_id%>"></td>
							</tr>
						<% } %>
							<tr>
								<td width="150" title="cust_name">Customer Name</td>
								<td><INPUT type="text" name="cust_name" size="50" value="<%=(cust.s_cust_name==null)?"":cust.s_cust_name%>"></td>
							</tr>
							<tr>
								<td width="150" title="login_name">Login Name</td>
								<td><INPUT type="text" name="login_name" size="50" value="<%=(cust.s_login_name==null)?"":cust.s_login_name%>"></td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150" title="status_id">Status</td>
								<td>
									<SELECT size="1" name="status_id">
										<%=CustStatus.toHtmlOptions(cust.s_status_id)%>
									</SELECT>
								</td>
							</tr>
							<tr>
								<td width="150" title="level_id">Trust Level</td>
								<td>
									<SELECT size="1" name="level_id">
										<%=TrustedLevel.toHtmlOptions(cust.s_level_id)%>
									</SELECT>
								</td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150" title="max_bbacks">Max. BBacks</td>
								<td><INPUT type="text" name="max_bbacks" size="50" value=<%=(cust.s_max_bbacks==null)?"":cust.s_max_bbacks%>></td>
							</tr>
							<tr>
								<td width="150" title="max_bback_days">Max. BBack Days</td>
								<td><INPUT type="text" name="max_bback_days" size="50" value=<%=(cust.s_max_bback_days==null)?"":cust.s_max_bback_days%>></td>
							</tr>
							<tr>
								<td width="150" title="max_consec_bbacks">Max. Consecutive BBacks</td>
								<td><INPUT type="text" name="max_consec_bbacks" size="50" value=<%=(cust.s_max_consec_bbacks==null)?"":cust.s_max_consec_bbacks%>></td>
							</tr>
							<tr>
								<td width="150" title="max_consec_bback_days">Max. Consecutive BBack Days</td>
								<td><INPUT type="text" name="max_consec_bback_days" size="50" value=<%=(cust.s_max_consec_bback_days==null)?"":cust.s_max_consec_bback_days%>></td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150" title="pass_expire_interval">Password Expiration Interval</td>
								<td><INPUT type="text" name="pass_expire_interval" size="50" value=<%=(cust.s_pass_expire_interval==null)?"":cust.s_pass_expire_interval%>></td>
							</tr>
							<tr>
								<td width="150" title="pass_notify_days">Password Notification Days</td>
								<td><INPUT type="text" name="pass_notify_days" size="50" value=<%=(cust.s_pass_notify_days==null)?"":cust.s_pass_notify_days%>></td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150" title="cti_group_id">CTI Group ID</td>
								<td><INPUT type="text" name="cti_group_id" size="50" value=<%=(cust.s_cti_group_id==null)?"":cust.s_cti_group_id%>></td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150" title="descrip">Description</td>
								<td>
									<TEXTAREA rows="5" name="descrip" cols="40"><%=(cust.s_descrip==null)?"":cust.s_descrip%></TEXTAREA>
								</td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150" title="upd_rule_id">Default Update Rule:</td>
								<td>
									<SELECT name="upd_rule_id" size="1">
										<%=UpdateRule.toHtmlOptions(cust.s_upd_rule_id)%>
									<SELECT>
								</td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150" title="parent_cust_id">
									<FONT color="#FF0000">
										Parent Customer:<BR>
										(Select before save!)
									</FONT>
								</td>
								<td>
									<SELECT size="1" name="parent_cust_id">
										<OPTION value="0">NONE ( 0 )</OPTION>
						<%
						ConnectionPool cp = null;
						Connection conn = null;

						try
						{
							cp = ConnectionPool.getInstance();
							conn = cp.getConnection("customer.jsp");

							PreparedStatement pstmt = null;
							try
							{
								String sSql =
									" SELECT cust_id, cust_name" +
									" FROM sadm_customer" +
									" WHERE cust_id in (SELECT DISTINCT cust_id FROM sadm_cust_attr WHERE fingerprint_seq IS NOT NULL)" +
									" ORDER BY cust_name";

								pstmt = conn.prepareStatement(sSql);
								ResultSet rs = pstmt.executeQuery();
								String sCustName = null;
								byte[] b = null;
								while (rs.next())
								{
									sCustId = rs.getString(1);
									b = rs.getBytes(2);
									sCustName = (b==null)?null:new String(b,"UTF-8");
						%>
									<OPTION value="<%=sCustId%>"<%=(sCustId.equals(cust.s_parent_cust_id)?" selected":"")%>><%=sCustName%> ( <%=sCustId%> )</OPTION>
						<%
								}
								rs.close();
							}
							catch(Exception ex) { throw ex; }
							finally { if(pstmt != null) pstmt.close(); }
						}
						catch(Exception ex) { throw ex; }
						finally { if(conn != null) cp.free(conn); }
						%>
									</SELECT>
								</td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150" title="upd_hierarchy_id">Default Update Hierarchy:</td>
								<td>
									<SELECT name="upd_hierarchy_id" size="1">
										<%=com.britemoon.Hierarchy.toHtmlOptions(cust.s_upd_hierarchy_id)%>
									<SELECT>
								</td>
							</tr>
							<tr>
								<td width="150" title="unsub_hierarchy_id">Default Unsubscribe Hierarchy:</td>
								<td>
									<SELECT name="unsub_hierarchy_id" size="1">
										<%=com.britemoon.Hierarchy.toHtmlOptions(cust.s_unsub_hierarchy_id)%>
									<SELECT>
								</td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150" title="auto_report_flag">Report Auto-Update Flag:</td>
								<td>
									<INPUT type=checkbox name="auto_report_flag" value=1 <%=(((cust.s_auto_report_flag==null)||("0".equals(cust.s_auto_report_flag)))?"":"checked")%>>
								</td>
							</tr>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150" title="auto_report_frequency">Report Auto-Update Frequency (minutes)</td>
								<td><INPUT type="text" name="auto_report_frequency" size="50" value=<%=(cust.s_auto_report_frequency==null)?"":cust.s_auto_report_frequency%>></td>
							</tr>
							<tr>
								<td width="150" title="auto_report_std_duration">Standard-Campaign Report Auto-Update Duration (days)</td>
								<td><INPUT type="text" name="auto_report_std_duration" size="50" value=<%=(cust.s_auto_report_std_duration==null)?"":cust.s_auto_report_std_duration%>></td>
							</tr>
							<tr>
								<td width="150" title="auto_report_auto_duration">Automated-Campaign Report Auto-Update Duration (days)</td>
								<td><INPUT type="text" name="auto_report_auto_duration" size="50" value=<%=(cust.s_auto_report_auto_duration==null)?"":cust.s_auto_report_auto_duration%>></td>
							</tr>
						</table>
                                                <br>
           					<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150" title="max_domains_on_report">Max Domains On Report:</td>
								<td><INPUT type="text" name="max_domains_on_report" size="50" value=<%=(cust.s_max_domains_on_report==null)?"":cust.s_max_domains_on_report%>></td>
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
