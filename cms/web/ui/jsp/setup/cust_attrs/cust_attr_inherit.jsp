<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);
int nUIType = ui.n_ui_type_id;

if((!can.bRead) || (!can.bWrite))
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>
<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px; font-size:14pt;">
						Attributes available to inherit from parent
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Custom Fields&nbsp;
			<hr size="1" width="100%">
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th>Display Name</th>
					<th nowrap>Field Type</th>
					<th width="5%" nowrap>Multi-value</th>
					<th width="5%">Fingerprint</th>
				</tr>
		<%
		ConnectionPool cp = null;
		Connection conn = null;
		Statement	stmt = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
			stmt = conn.createStatement();

			String sSQL =
				" SELECT" +
				"	a.attr_id," +
				"	a.attr_name," +
				"	a.value_qty," +			
				"	ca.display_name," +
				"	ca.display_seq," +
				"	ca.fingerprint_seq," +
				"	t.type_name" +
				" FROM" +
				"	ccps_cust_attr ca," +
				"	ccps_attribute a," +
				"	ccps_data_type t" +
				" WHERE" +
				"	ca.cust_id=" + cust.s_parent_cust_id + " AND" +			
				"	ca.attr_id = a.attr_id AND" +
				"	a.type_id = t.type_id AND" +
				"	a.scope_id = " + AttrScope.PUBLIC + " AND" +			
				"	ISNULL(a.internal_flag,0) <= 0 AND" +
				"	ca.attr_id NOT IN" +
				"		(SELECT attr_id FROM ccps_cust_attr" +
				"			WHERE cust_id = " + cust.s_cust_id + ")" +
				" ORDER BY display_seq, display_name";

 			ResultSet rs = stmt.executeQuery(sSQL);

			String sAttrId = null;
			String sAttrName = null;
			String sValueQty = null;
			
			String sDisplayName = null;
			String sDisplaySeq = null;
			String sFingerprintSeq = null;

			String sTypeName = null;

			String sDescrip = null;
					
			String sClassAppend = "";
			int i = 0;

			while(rs.next())
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
				
				sAttrId = rs.getString(1);
				sAttrName = rs.getString(2);
				sValueQty = rs.getString(3);

				sDisplayName = new String(rs.getBytes(4), "UTF-8");
				sDisplaySeq = rs.getString(5);
				sFingerprintSeq = rs.getString(6);

				sTypeName = rs.getString(7);
				%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>"><a href="cust_attr_edit.jsp?attr_id=<%= sAttrId %>"><%= sDisplayName %></a></td>
					<td class="listItem_Data<%= sClassAppend %>"><%= sTypeName %></td>
					<td class="listItem_Data<%= sClassAppend %>" align="center"><INPUT type="checkbox" <%=(sValueQty==null)?"":"checked"%> disabled></td>
					<td class="listItem_Data<%= sClassAppend %>" align="center"><INPUT type="checkbox" <%=(sFingerprintSeq==null)?"":"checked"%> disabled></td>
				</tr>
				<%
			}
			rs.close();
		}
		catch(Exception ex) { throw ex; }
		finally { if(conn!=null) cp.free(conn); }
		%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</BODY>
</HTML>
