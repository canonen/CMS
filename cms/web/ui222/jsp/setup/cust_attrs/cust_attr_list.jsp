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

if(!can.bRead)
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
<%
if (can.bWrite)
{
	%>
<table cellspacing="0" cellpadding="3" border="0" width="650">
	<tr>
	<%
	if (nUIType == UIType.ADVANCED)
	{
		%>
		<td align="left" valign="middle" nowrap>
			&nbsp;&nbsp;&nbsp;<a class="newbutton" href="cust_attr_edit.jsp">New Field</a>&nbsp;&nbsp;&nbsp;
		</td>
		<%
		if( (cust.s_parent_cust_id != null) && (!"0".equals(cust.s_parent_cust_id)) )
		{
			%>
		<td align="left" valign="middle" nowrap>
			&nbsp;&nbsp;&nbsp;<a class="subactionbutton" href="cust_attr_inherit.jsp">Inherit from Parent</a>&nbsp;&nbsp;&nbsp;
		</td>
			<%
		}
	}
	%>
		<td align="right" valign="middle" width="100%">
			&nbsp;&nbsp;&nbsp;<a class="subactionbutton" href="cust_attr_recip_view_seq.jsp">Set Recip View Sequence</a>&nbsp;&nbsp;&nbsp;
			&nbsp;&nbsp;&nbsp;<a class="subactionbutton" href="cust_attr_seq.jsp">Set Display Sequence</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
	<%
}
%>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			Custom Fields&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th nowrap>Display Name</th>
					<th nowrap>Attribute Name</th>
					<th nowrap>Field Type</th>
					<th width="5%" nowrap>Multi-value</th>
					<th width="5%">Fingerprint</th>
					<th width="5%">Newsletter</th>
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
					"	ca.newsletter_flag," +
					"	t.type_name" +
					" FROM" +
					"	ccps_cust_attr ca," +
					"	ccps_attribute a," +
					"	ccps_data_type t" +
					" WHERE" +
					"	ca.cust_id=" + cust.s_cust_id + " AND" +
					"	ca.attr_id = a.attr_id AND" +
					"	a.type_id = t.type_id AND" +
					"	ISNULL(ca.display_seq, 0) > 0 AND" +
					"	ISNULL(a.internal_flag,0) <= 0" +
					" ORDER BY display_seq, display_name";

 				ResultSet rs = stmt.executeQuery(sSQL);

				String sAttrId = null;
				String sAttrName = null;
				String sValueQty = null;
				
				String sDisplayName = null;
				String sDisplaySeq = null;
				String sFingerprintSeq = null;
				String sNewsletterFlag = null;

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
					sNewsletterFlag = rs.getString(7);

					sTypeName = rs.getString(8);
					%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>"><a href="cust_attr_edit.jsp?attr_id=<%=sAttrId%>"><%=sDisplayName%></a></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=sAttrName%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=sTypeName%></td>
					<td class="listItem_Data<%= sClassAppend %>" align="center"><INPUT type="checkbox" <%=(sValueQty==null)?"":"checked"%> disabled></td>
					<td class="listItem_Data<%= sClassAppend %>" align="center"><INPUT type="checkbox" <%=(sFingerprintSeq==null)?"":"checked"%> disabled></td>
					<td class="listItem_Data<%= sClassAppend %>" align="center"><INPUT type="checkbox" <%=(sNewsletterFlag==null)?"":"checked"%> disabled></td>
				</tr>
				<%
				}
				rs.close();
				
				if (i == 0)
				{
					%>
				<tr>
					<td class="listItem_Title" colspan="4">There are currently no Custom Fields</td>
				</tr>
					<%
				}
			}
			catch(Exception ex)
			{
				throw ex;
			}
			finally
			{
				if(conn!=null) cp.free(conn);
			}
			%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</BODY>
</HTML>
