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

<% String sCustId = BriteRequest.getParameter(request, "cust_id"); %>

<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
	<SCRIPT>
		function check_all(action)
		{
			var n = aprvl_custs.elements.length;
			var obj;
			for(var i=0; i < n; i++)
			{
				obj = aprvl_custs.elements[i];
				if(obj.type == 'checkbox' && obj.disabled == false) obj.checked = action;
			}
		}
	</SCRIPT>
</HEAD>

<BODY>

<table cellspacing="0" cellpadding="0" border="0">
	<tr height="35">
		<td valign="top">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="aprvl_custs.submit()">Save</a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
			<br>
		</td>
	</tr>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0">
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" width="150" valign="center" nowrap align="middle">Aprvl custs</td>
					<td class="EmptyTab" valign="center" width="150" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
					
<!-- === === === --->

<form method="POST" action="aprvl_custs_save.jsp" name="aprvl_custs">
<input type="hidden" name="cust_id" value="<%=sCustId%>">
<table class="listTable" border="0" cellspacing="0" cellpadding="3">
	<tr>
		<th>Object Type</th>
		<th>Aprvl Workflow Flag</th>		
	</tr>
<%
ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);

	try
	{
		String sSql = 
			" SELECT ot.type_id, ot.type_name, aprvl_workflow_flag=ISNULL(ac.aprvl_workflow_flag, 0)" +
			" FROM scps_object_type ot" +
				" LEFT OUTER JOIN scps_aprvl_cust ac" +
					" ON ( ot.type_id = ac.object_type )" +
						" AND ( ac.cust_id = ? )" +
			" ORDER BY ot.type_name";
		
		pstmt = conn.prepareStatement(sSql);
		pstmt.setString(1, sCustId);

		ResultSet rs = pstmt.executeQuery();
		
		String sTypeId = null;
		String sTypeName = null;
		int nAprvlWorkflowFlag = 0;

		int iCount = 0;
		String sClassAppend = "";
		
		while (rs.next())
		{
			if (iCount % 2 != 0) sClassAppend = "_Alt";
			else sClassAppend = "";

			++iCount;
			
			sTypeId = rs.getString(1);
			sTypeName = rs.getString(2);
			nAprvlWorkflowFlag = rs.getInt(3);
%>
	<tr>
		<td class="listItem_Data<%= sClassAppend %>">
			<%=sTypeName%>
			<input type="hidden" name=<%=sTypeId%> value=0>
		</td>
		<td class="listItem_Data<%= sClassAppend %>" align="center">
			<input type="checkbox" name=<%=sTypeId%> value=1<%=(nAprvlWorkflowFlag == 1)?" checked":""%>>
		</td>
	</tr>
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
</table>
</form>
<br>
<table class="main" border="0" cellspacing="1" cellpadding="3">
	<tr>
		<td align="center" style="padding:10px;">
			<a class="subactionbutton" href="#" onclick="check_all(true);">Check All</a>&nbsp;&nbsp;&nbsp;
			<a class="subactionbutton" href="#" onclick="check_all(false);">Un-Check All</a>
		</td>
	</tr>
</table>

<!-- === === === --->
						
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>
