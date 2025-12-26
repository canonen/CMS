<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CATEGORY);

if(!can.bRead)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

String sDefaultCategoryID = ui.s_category_id;
boolean bCanDefault = ((user.s_cust_id).equals(cust.s_cust_id) && can.bExecute);
%>
<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<SCRIPT src="../../../js/disable_forms.js"></SCRIPT>
</HEAD>
<BODY>
<%
if(can.bWrite)
{
	%>
	<table cellspacing="0" cellpadding="3" border="0" width="650">
		<tr>
			<td align="left" valign="middle">
				<a class="newbutton" href="category_edit.jsp">New Category</a>&nbsp;&nbsp;&nbsp;
			</td>
		<%
		if (bCanDefault && (sDefaultCategoryID != null))
		{
			%>
			<td align="right" valign="middle">
				&nbsp;&nbsp;&nbsp;<a class="subactionbutton" href="set_default.jsp?category_id=0" target="_self">Clear Default</a>&nbsp;&nbsp;&nbsp;
			</td>
			<%
		}
		%>
		</tr>
	</table>
	<br>
	<%
}
%>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Categories&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th>Name</th>
					<th>Description</th>
					<th>&nbsp;</th>
				</tr>
		<%
		ConnectionPool cp = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sSql = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);

			try
			{
				sSql  =
					" SELECT category_id, category_name, ISNULL(category_descrip,'')" +
					" FROM ccps_category" +
					" WHERE cust_id=?" +
					" ORDER BY category_name";

				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, cust.s_cust_id);
				rs = pstmt.executeQuery();
				
				String sCategoryId = null;
				String sCategoryName = null;
				String sCategoryDescrip = null;
				
				String sClassAppend = "";
				int i = 0;
				
				while (rs.next())
				{
					if (i % 2 != 0)
					{
						sClassAppend = "_Alt";
					}
					else
					{
						sClassAppend = "";
					}
					i++;
					
					sCategoryId = rs.getString(1);
					sCategoryName = new String(rs.getBytes(2), "UTF-8");
					sCategoryDescrip = new String(rs.getBytes(3), "UTF-8");
					%>
					<tr>
						<td class="listItem_Title<%= sClassAppend %>">
							<%=(sCategoryId.equals(sDefaultCategoryID))?"* ":""%>
							<a href="category_edit.jsp?category_id=<%=sCategoryId%>" target="_self"><%=sCategoryName%></a>
						</td>
						<td class="listItem_Data<%= sClassAppend %>"><%=sCategoryDescrip%></td>
					<%
					if (bCanDefault)
					{
						%>
						<td class="listItem_Data<%= sClassAppend %>" align="right"><%=(sCategoryId.equals(sDefaultCategoryID))?"Default":
							"<a href=\"set_default.jsp?category_id="+sCategoryId+"\" target=\"_self\">Set Default</a>"%>
						</td>
						<%
					}
					%>
					</tr>
					<%
				}
				rs.close();
						
				if (i == 0)
				{
					%>
					<tr>
						<td class="listItem_Title" colspan="3">There are currently no Categories</td>
					</tr>
					<%
				}
				%>
			</table>
		</td>
	</tr>
</table>
<br>
				<%
			}
			catch(Exception ex)
			{
				throw ex;
			}
			finally
			{
				if(pstmt != null) pstmt.close();
			}
		}
		catch(Exception ex)
		{
			throw ex;
		}
		finally
		{
			if(conn != null) cp.free(conn);
		}
		%>
</BODY>
</HTML>