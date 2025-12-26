<%@ page

	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.que.*,
		com.britemoon.cps.ctl.*,
		java.util.*,java.sql.*,
		java.net.*,java.text.DateFormat,
		org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
ConnectionPool		cp				= null;
Connection			conn 			= null;
Statement			stmt			= null;
ResultSet			rs				= null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("user_note_list.jsp");
	stmt = conn.createStatement();
	String sClassAppend = "";
	String sSql = "";
	
	AccessPermission can = user.getAccessPermission(ObjectType.USER_NOTES);
%>
<html>
<head>
<title></title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="JavaScript" src="../../js/scripts.js"></script>
<script language="JavaScript" src="../../js/tab_script.js"></script>
<script language="javascript">

	function showHide(id)
	{
		var tRows = document.getElementById("row_" + id);
		
		if (tRows.length >= 1)
		{
			for (i=0; i < tRows.length; i++)
			{
				showHideRow(tRows[i], id);
			}
		}
		else
		{
			showHideRow(tRows, id);
		}
	}
	
	function showHideRow(oRow, id)
	{
		if (oRow.style.display == "none")
		{
			oRow.style.display = "";
			document.getElementById("link_" + id).innerText = "-";
			document.getElementById("pRow_" + id).height = "";
		}
		else
		{
			oRow.style.display = "none";
			document.getElementById("link_" + id).innerText = "+";
			document.getElementById("pRow_" + id).height = "24";
		}
	}

</script>
</head>
<body>
<% if (can.bWrite) { %>
<table cellpadding="3" cellspacing="0" border="0" width="95%">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="user_note_edit.jsp">New Note</a>&nbsp;&nbsp;&nbsp;
		</td>
		<td nowrap valign="middle" align="right" width="100%">
			&nbsp;
		</td>
	</tr>
</table>
<% } %>
<br>
<table cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Current User Notes&nbsp;
			<br><br>
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<%
			String sNoteId = "-999";
			sSql = "EXEC usp_chom_user_note_list_get_published @cust_id=" + cust.s_cust_id + ",@admin=0,@exclude_id="+ sNoteId;
			
			int iCount = 0;
			rs = stmt.executeQuery(sSql);
			
			String sId = "";
			String sSubj = "";
			String sUserID = "";
			String sUser = "";
			String dDate = "";
			String sDate = "";
			String sBody = "";
			byte[] b = null;

			while (rs.next())
			{
				++iCount;

				sId = rs.getString(1);
				sSubj = rs.getString(2);
				sUserID = rs.getString(3);
				sUser = rs.getString(4);
				dDate = rs.getString(5);
				sDate = rs.getString(6);
				b = rs.getBytes(7);
				sBody = (b == null)?null:new String(b,"UTF-8");
				%>
				<tr id="pRow_<%= sId %>"<%= (iCount != 1)?" height=\"24\"":"" %>>
					<td>
						<table cellspacing="0" cellpadding="1" border="0" class="listTable layout" style="width:100%;">
							<col width="25">
							<col width="50">
							<col>
							<col width="40">
							<col>
							<col width="40">
							<col width="150">
							<tr height="25">
								<td class="MenuBar" nowrap><a id="link_<%= sId %>" class="resourcebutton" style="width:15px;text-align:center;" href="javascript:showHide('<%= sId %>');"><%= (iCount != 1)?"+":"-" %></a>&nbsp;&nbsp;&nbsp;</td>
								<td class="MenuBar" align="left" valign="middle"><b>Subject:</b></td>
								<td class="MenuBar" align="left" valign="middle"><%= sSubj %></td>
								<td class="MenuBar" align="left" valign="middle"><b>From:</b></td>
								<td class="MenuBar" align="left" valign="middle"><%= sUser %></td>
								<td class="MenuBar" align="left" valign="middle"><b>Date:</b></td>
								<td class="MenuBar" align="left" valign="middle"><%= sDate %></td>
							</tr>
							<tr id="row_<%= sId %>"<%= (iCount != 1)?" style=\"display:none;\"":"" %>>
								<td valign="middle" nowrap>&nbsp;</td>
								<td colspan="6" align="left" valign="middle">
									<%= sBody %>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<%
			}
			rs.close();
			
			if (iCount == 0)
			{
				%>
				<tr>
					<td class="listItem_Title" align="left" valign="middle">There are currently no User Notes</td>
				</tr>
				<%
			}
			%>
			</table>
		</td>
	</tr>
</table>
<br><br>
<table cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			My User Notes&nbsp;
			<br><br>
			<table class="listTable" cellpadding="2" cellspacing="0" border="0" width="100%">
				<tr>
					<th align="left" valign="middle" width="40%">Subject</th>
					<th align="left" valign="middle" width="15%" nowrap>User</th>
					<th align="left" valign="middle" width="15%" nowrap>Modified Date</th>
					<th align="left" valign="middle" width="15%" nowrap>Status</th>
					<th align="left" valign="middle" width="15%" nowrap>Action</th>
				</tr>
			<%
			sSql = "EXEC usp_chom_user_note_list_get_my @cust_id=" + cust.s_cust_id + ",@user_id="+ user.s_user_id + ",@admin=0";
			
			iCount = 0;
			rs = stmt.executeQuery(sSql);
			
			sId = "";
			sSubj = "";
			sUserID = "";
			sUser = "";
			dDate = "";
			sDate = "";
			String sPub = "";
			String sStatus = "";
			String sAction = "";

			while (rs.next())
			{
				if (iCount % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";
				
				++iCount;

				sId = rs.getString(1);
				sSubj = rs.getString(2);
				sUserID = rs.getString(3);
				sUser = rs.getString(4);
				dDate = rs.getString(5);
				sDate = rs.getString(6);
				sPub = rs.getString(7);
				sStatus = "Draft";
				sAction = "---";
				
				if (sPub.equals("1"))
				{
					sStatus = "Published";
					if (can.bWrite) sAction = "<a href=\"user_note_publish.jsp?action=setdraft&note_id=" + sId + "\">Set to Draft</a>";
				}
				else
				{
					sStatus = "Draft";
					if (can.bWrite) sAction = "<a href=\"user_note_publish.jsp?action=publish&note_id=" + sId + "\">Publish</a>";
				}
				%>
				<tr>
					<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="40%"><a href="user_note_edit.jsp?note_id=<%=sId%>"><%=sSubj%></a></td>
					<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="15%" nowrap><%=sUser%></td>
					<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="15%" nowrap><%=sDate%></td>
					<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="15%" nowrap><%=sStatus%></td>
					<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="15%" nowrap><%=sAction%></td>
				</tr>
				<%
			}
			rs.close();
			
			if (iCount == 0)
			{
				%>
				<tr>
					<td class="listItem_Title" colspan="5" align="left" valign="middle">There are currently no User Notes</td>
				</tr>
				<%
			}
			%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</body>
</html>
<%
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex,"user_note_list.jsp",out,1);	
}
finally
{
	try { if (stmt != null) stmt.close(); }
	catch(Exception e)
	{}
	if (conn != null) cp.free(conn);
}
%>
