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
SystemUser user = new SystemUser(sUserId);

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
	<SCRIPT>
		function check_all(action)
		{
			var n = access_masks.elements.length;
			var obj;
			for(var i=0; i < n; i++)
			{
				obj = access_masks.elements[i];
				if(obj.type == 'checkbox' && obj.disabled == false) obj.checked = action;
			}
		}
		function check_partner_user()
		{
			check_all(false);
			var n = access_masks.elements.length;
			var obj;
			for(var i=0; i < n; i++)
			{
				obj = access_masks.elements[i];
				// 100 = customer
				if (obj.name == '100' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 150 = system entities
				if (obj.name == '150' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 330 = support tickets
				if (obj.name == '330' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
			}
		}
		function check_britemoon_user()
		{
			check_all(false);
			var n = access_masks.elements.length;
			var obj;
			for(var i=0; i < n; i++)
			{
				obj = access_masks.elements[i];
				// 100 = customer
				if (obj.name == '100' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				if (obj.name == '100' && obj.type == 'checkbox' && obj.value == '4') obj.checked = true;
				// 110 = customer users
				if (obj.name == '110' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 150 = system entities
				if (obj.name == '150' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 200 = server
				if (obj.name == '200' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 310 = help document
				if (obj.name == '310' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 320 = faqs
				if (obj.name == '320' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 330 = support tickets
				if (obj.name == '330' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 400 = billing
				if (obj.name == '400' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 510 = system users
				if (obj.name == '510' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 520 = partners
				if (obj.name == '520' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 530 = system notes
				if (obj.name == '530' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 540 = host monitor
				if (obj.name == '540' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 550 = registry
				if (obj.name == '550' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
				// 560 = delivery monitor
				if (obj.name == '560' && obj.type == 'checkbox' && obj.value == '2') obj.checked = true;
			}
		}
	</SCRIPT>
</HEAD>

<BODY>

<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
	<col>
	<tr height="35">
		<td valign="top">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="access_masks.submit()">Save</a>&nbsp;&nbsp;&nbsp;
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
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Access Rights</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<form method="POST" action="access_masks_save.jsp" name="access_masks">
						<input type="hidden" name="system_user_id" value="<%=user.s_system_user_id%>">
						<table class="listTable" border="0" cellspacing="0" cellpadding="3" width="100%">
							<tr>
								<th>Accessible Object \ Accesss Type</th>
								<th>Read</th>		
								<th>Write</th>
								<th>Execute</th>
								<th>Delete</th>
							</tr>
							<%
							try
							{
								sSql  = " SELECT ot.type_id, ot.display_name, mask=ISNULL(am.mask, 0)";
								sSql += " FROM sadm_system_object_type ot";
								sSql += 	" LEFT OUTER JOIN sadm_system_access_mask am";
								sSql += 		" ON ( ot.type_id = am.type_id )";
								sSql += 			" AND ( am.system_user_id = ? )";
								sSql += " ORDER BY ot.type_id";
								
								pstmt = conn.prepareStatement(sSql);
								pstmt.setString(1, user.s_system_user_id);
								rs = pstmt.executeQuery();
								
								String sTypeId = null;
								String sTypeName = null;
								int iMask = 0;

								int iCount = 0;
								String sClassAppend = "";
								
								while (rs.next())
								{
									if (iCount % 2 != 0) sClassAppend = "_Alt";
									else sClassAppend = "";

									++iCount;
									
									sTypeId = rs.getString(1);
									sTypeName = rs.getString(2);
									iMask = rs.getInt(3);
									%>
							<tr>
								<td class="listItem_Data<%= sClassAppend %>">
									<%=sTypeName%>
									<input type="hidden" name=<%=sTypeId%> value=0>
								</td>
								<td class="listItem_Data<%= sClassAppend %>" align="center"><input type="checkbox" name=<%=sTypeId%> value=<%=AccessRight.READ%> <%=((AccessRight.READ & iMask) == AccessRight.READ)?"checked":""%>></td>
								<td class="listItem_Data<%= sClassAppend %>" align="center"><input type="checkbox" name=<%=sTypeId%> value=<%=AccessRight.WRITE%> <%=((AccessRight.WRITE & iMask) == AccessRight.WRITE)?"checked":""%>></td>
								<td class="listItem_Data<%= sClassAppend %>" align="center"><input type="checkbox" name=<%=sTypeId%> value=<%=AccessRight.EXECUTE%> <%=((AccessRight.EXECUTE & iMask) == AccessRight.EXECUTE)?"checked":""%>></td>
								<td class="listItem_Data<%= sClassAppend %>" align="center"><input type="checkbox" name=<%=sTypeId%> value=<%=AccessRight.DELETE%> <%=((AccessRight.DELETE & iMask) == AccessRight.DELETE)?"checked":""%>></td>
							</tr>
									<%
								}
								rs.close();
							}
							catch(Exception ex) { throw ex; }
							finally { if(pstmt != null) pstmt.close(); }
							%>
						</table>
						<br>
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td align="center" style="padding:10px;">
									<a class="subactionbutton" href="#" onclick="check_partner_user();">Partner User</a>&nbsp;&nbsp;&nbsp;
									<a class="subactionbutton" href="#" onclick="check_britemoon_user();">Revotas User</a>&nbsp;&nbsp;&nbsp;
									<a class="subactionbutton" href="#" onclick="check_all(true);">Check All</a>&nbsp;&nbsp;&nbsp;
									<a class="subactionbutton" href="#" onclick="check_all(false);">Un-Check All</a>
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
<%
}
catch(Exception ex) { throw ex; }
finally { if(conn != null) cp.free(conn); }
%>