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

if(!can.bRead)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

String sAttrId = request.getParameter("attr_id");
String sSort = request.getParameter("sort");

if( sAttrId == null) return;

Attribute a = new Attribute(sAttrId);
CustAttr ca = new CustAttr(cust.s_cust_id, sAttrId);

%>
<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<title>Attribute Values</title>
</HEAD>
<BODY>
<table cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<%= ca.s_display_name %> (<%= a.s_attr_name %>)&nbsp;
			<br><br>
			<table class="listTable" cellpadding="2" cellspacing="0">
				<tr>
					<th aligh="center"><span style="cursor:hand;" onclick="location.href = 'values_show.jsp?attr_id=<%= ca.s_attr_id %>&sort=value';">Value</span></th>
					<th aligh="center"><span style="cursor:hand;" onclick="location.href = 'values_show.jsp?attr_id=<%= ca.s_attr_id %>&sort=count';">Count</span></th>
				</tr>
			<%
			ConnectionPool cp = null;
			Connection conn = null;
			Statement	stmt = null;
			ResultSet	rs = null; 
			String sSQL = null;

			try
			{
				cp = ConnectionPool.getInstance();
				conn = cp.getConnection(this);
				stmt = conn.createStatement();

				sSQL =
					" SELECT attr_value, value_qty" +
					" FROM ccps_attr_value" +
					" WHERE cust_id=" + ca.s_cust_id +
					" AND attr_id=" + ca.s_attr_id;

				if("count".equals(sSort)) sSQL += " ORDER BY value_qty DESC";
				else sSQL += " ORDER BY attr_value";

 				rs = stmt.executeQuery(sSQL);

				String sAttrValue = null;
				String sValueQty = null;

				byte[] b = null;
							
				String sClassAppend = "";
				
				for(int i = 0; rs.next(); i++)
				{
					if (i % 2 != 0) sClassAppend = "_Alt";
					else sClassAppend = "";
					
					b = rs.getBytes(1);
					sAttrValue = (b==null)?null:new String(b, "UTF-8");
					sValueQty = rs.getString(2);
					%>
				<tr>
					<td class="listItem_Data<%= sClassAppend %>"><%= HtmlUtil.escape(sAttrValue) %></td>
					<td class="listItem_Data<%= sClassAppend %>"><%= sValueQty %></td>
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
</BODY>
</HTML>
