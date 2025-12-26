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
	if(sCustId == null) cust = new Customer();
	else
	{
		cust = new Customer(sCustId);
		sCustId = cust.s_cust_id;
	}
%>

<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<BASE target="main_01">
	<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>
<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="resourcebutton" href="cust_list.jsp" target="_parent"><< Return to Customers</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table cellspacing="0" cellpadding="0" width="100%" border="0">
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100% colspan=2><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab>
			<table width=100% class=main border="0" cellspacing="1" cellpadding="2">
				<tr>
					<td align="left" valign="middle" class="pageheader"><%=(sCustId==null)?"New":cust.s_cust_name +" (" + cust.s_cust_id + ")"%></td>
				</tr>
				<tr>
					<td align="left" valign="middle" style="padding:10px;">
						<table border="0" cellspacing="0" cellpadding="2">
							<tr>
								<td colspan="3"><b>General Info</b></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>1</td>
								<td><a href="cust_edit.jsp<%= (sCustId==null)?"":"?cust_id=" + sCustId %>">Name, Etc.</a></td>
							</tr>
<% if(sCustId == null) { %>
						</table>
<% } else { %>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>2</td>
								<td><a href="cust_addr/cust_addr_edit.jsp?cust_id=<%= sCustId %>">Address & Phone</a></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>3</td>
								<td><a href="cust_ui_settings/cust_ui_settings_edit.jsp?cust_id=<%= sCustId %>">UI Settings</a></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>4</td>
								<td><a href="cust_partners/cust_partners.jsp?cust_id=<%= sCustId %>">Partners</a></td>
							</tr>
							<tr>
								<td colspan="3"><b>System &amp; Modules</b></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>1</td>
								<td><a href="cust_mod_insts/cust_mod_insts.jsp?cust_id=<%= sCustId %>">Bind Module Instances</a></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>2</td>
								<td><a href="vanity_domains/vanity_domains.jsp?cust_id=<%= sCustId %>">Vanity Domains</a></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>3</td>
								<td><a href="cust_mod_insts/cust_mod_inst_services.jsp?cust_id=<%= sCustId %>">Customer Specific Services</a></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>4</td>
								<td><a href="cust_unique_ids/cust_unique_ids.jsp?cust_id=<%= sCustId %>">Sequence Numbers</a></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>5</td>
								<td><a href="cust_credit/cust_credit_edit.jsp?cust_id=<%= sCustId %>">Customer Credit</a></td>
							</tr>
							<tr>
								<td colspan="3"><b>Users</b></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>1</td>
								<td><a href="users/user_list.jsp?cust_id=<%= sCustId %>">Users</a></td>
							</tr>

							<tr>
								<td colspan="3"><b>Entities</b></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>1</td>
								<td><a href="entities/entities_frame.jsp?cust_id=<%= sCustId %>">Entities</a></td>
							</tr>
							<tr>
								<td colspan="3"><b>Other</b></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>1</td>
								<td><a href="unsub_msgs/unsub_msg_frame.jsp?cust_id=<%= sCustId %>">Unsubscribe Messages</a></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>2</td>
								<td><a href="from_addresses/from_address_frame.jsp?cust_id=<%= sCustId %>">From Addresses</a></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>3</td>
								<td><a href="cust_send_param/cust_send_param_edit.jsp?cust_id=<%= sCustId %>">Send Parameters</a></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>4</td>
								<td><a href="cust_features/cust_features.jsp?cust_id=<%= sCustId %>">Features</a></td>
							</tr>
							<tr>
								<td colspan="3"><b>Workflow</b></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>1</td>
								<td><a href="cust_workflow/aprvl_custs.jsp?cust_id=<%= sCustId %>">Approval Objects</a></td>
							</tr>
							<tr>
								<td colspan="3"><b>Image Library</b></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>1</td>
								<td><a href="cust_img/img_cust_refresh_info.jsp?cust_id=<%= sCustId %>">Image Refresh Info</a></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td>2</td>
								<td><a href="cust_img/img_cust_file_extensions.jsp?cust_id=<%= sCustId %>">Image File Ext.</a></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br>
<table cellspacing="5" cellpadding="5" width="100%" border="0">
	<tr>
		<td align="center" valign="middle">
			<a class="subactionbutton" href="sync/sync_list.jsp?cust_id=<%=sCustId%>">Synchronize Customer Info</a>
		</td>
	<tr>
	</tr>			
		<td align="center" valign="middle">
			<a class="savebutton" href="cust_clone/cust_clone_settings.jsp?cust_id=<%=sCustId%>">Clone</a>
		</td>
	</tr>
	</tr>			
		<td align="center" valign="middle">
			<a class="savebutton" href="cust_clone/cust_clone_settings_hyatt.jsp?cust_id=<%=sCustId%>">Clone Hyatt</a>
		</td>
	</tr>
</table>
<br><br>
<%
}
%>
</BODY>

</HTML>