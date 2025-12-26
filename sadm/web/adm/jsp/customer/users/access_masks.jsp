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
User user = new User(sUserId);
UserUiSettings uus = new UserUiSettings(sUserId);

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
						<input type="hidden" name="user_id" value="<%=user.s_user_id%>">
						<table class="listTable" border="0" cellspacing="0" cellpadding="3" width="100%">
							<tr>
								<th>Accessible Object \ Accesss Type</th>
								<th>Read</th>		
								<th>Write</th>
								<th>Execute</th>
								<th>Delete</th>
								<th>Approve</th>
							</tr>
							<%
							try
							{
								sSql  = " SELECT ot.type_id, ot.type_name, mask=ISNULL(am.mask, 0)";
								sSql += " FROM scps_object_type ot";
								sSql += 	" LEFT OUTER JOIN scps_access_mask am";
								sSql += 		" ON ( ot.type_id = am.type_id )";
								sSql += 			" AND ( am.user_id = ? )";

								if(!String.valueOf(UIType.ADVANCED).equals(uus.s_ui_type_id))
								{
									sSql += " AND (ot.type_id NOT IN (" + ObjectType.FORM + ", " + ObjectType.LOGIC_BLOCK + "))";
								}

								sSql += " ORDER BY ot.type_name";
								
								pstmt = conn.prepareStatement(sSql);
								pstmt.setString(1, user.s_user_id);
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
								<td class="listItem_Data<%= sClassAppend %>" align="center"><input type="checkbox" name=<%=sTypeId%> value=<%=AccessRight.APPROVE%> <%=((AccessRight.APPROVE & iMask) == AccessRight.APPROVE)?"checked":""%>></td>
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
<script language="javascript">
	
	var obj;
	
<% if (String.valueOf(UIType.HYATT_USER).equals(uus.s_ui_type_id)) { %>
	
	//USER ACCOUNTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.USER) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//IMPORTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.IMPORT) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//EXPORTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.EXPORT) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//RECIPIENTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.RECIPIENT) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//CUSTOM FIELDS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.RECIPIENT_ATTRIBUTE) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//CATEGORIES
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.CATEGORY) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//CONTENT
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.CONTENT) %>");
		obj[1].disabled = true;
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//IMAGE LIBRARY
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.IMAGE) %>");
		obj[2].disabled = true;
		obj[3].disabled = true;
		
	var checks = document.getElementsByTagName("INPUT");
	var icount = 0;
	
	for (i=0; i < checks.length; i++)
	{
		if (checks[i].type == "checkbox")
		{
			if (checks[i].value == "32")
			{
				checks[i].disabled = true;
			}
		}
	}

<% } %>

<% if (String.valueOf(UIType.HYATT_ADMIN).equals(uus.s_ui_type_id)) { %>
	
	//IMPORTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.IMPORT) %>");
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
	//RECIPIENTS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.RECIPIENT) %>");
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
		obj[5].disabled = true;
	//CUSTOM FIELDS
		obj = document.getElementsByName("<%= String.valueOf(ObjectType.RECIPIENT_ATTRIBUTE) %>");
		obj[2].disabled = true;
		obj[3].disabled = true;
		obj[4].disabled = true;
		obj[5].disabled = true;
	
<% } %>
	
</script>
</BODY>
</HTML>
<%
}
catch(Exception ex) { throw ex; }
finally { if(conn != null) cp.free(conn); }
%>