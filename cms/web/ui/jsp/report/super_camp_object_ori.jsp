<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.util.*,
			java.net.*,org.w3c.dom.*,
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

Statement	stmt, stmt2;
ResultSet	rs, rs2; 
ConnectionPool 	cp 	= null;
Connection 	conn 	= null;
Connection 	conn2 	= null;
int	nStep = 1;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("super_camp_edit.jsp");
	conn2 = cp.getConnection("super_camp_edit.jsp 2");
	stmt  = conn.createStatement();
	stmt2  = conn2.createStatement();
} catch(Exception ex) {
	cp.free(conn);
	cp.free(conn2);
	out.println("<BR>Connection error ... !<BR><BR>"); 
	return;
}

String superCampID = request.getParameter("super_camp_id");
String superCampName = null;

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;
sSelectedCategoryId = (sSelectedCategoryId != null)?sSelectedCategoryId:"0";

try {

	String sSql = "SELECT super_camp_name FROM cque_super_camp " +
				  "WHERE cust_id = "+cust.s_cust_id+" AND super_camp_id = "+superCampID;
	rs = stmt.executeQuery(sSql);	
	if (!rs.next()) throw new Exception("Invalid super campaign - Doesn't exist or you are not allowed to see it");
	superCampName = new String(rs.getBytes(1),"UTF-8");
	
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<body>
<%
if (superCampID != null)
{
	%>
	<table cellpadding="4" cellspacing="0" border="0">
		<tr>
			<td vAlign="middle" align="left">
				<a class="savebutton" href="super_camp_edit.jsp?super_camp_id=<%=superCampID%>&category_id=<%=sSelectedCategoryId%>">Edit</a>
			</td>
			<td vAlign="middle" align="left">
				<a class="deletebutton" href="#" onclick="if( confirm('Are you sure?') ) location.href='super_camp_delete.jsp?super_camp_id=<%= superCampID %>';">Delete</a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Super Campaign:</b> General Information</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
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
					<td width="150" align="left" valign="middle">Name: </td>
					<td align="left" valign="middle"><%= superCampName %> </td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 2 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Super Campaign:</b> Campaigns</td>
	</tr>
</table>
<br>
<!---- Step 2 Info----->
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=listTable cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<th align="left" valign="middle">Campaign Name</th>
					<th align="left" valign="middle">Type</th>
				</tr>
			<%
			//Grab all of this super campaign's campaigns.
			sSql = "SELECT c.camp_id, c.camp_name, type_name " +
				"FROM cque_super_camp_camp cc, cque_campaign c, cque_camp_type t " +
				"WHERE cc.super_camp_id = "+superCampID+ " " +
				"AND c.camp_id = cc.camp_id " +
				"AND c.type_id = t.type_id";
				
			rs = stmt.executeQuery(sSql);
			
			String sCurCampID,sCurCampName,sCurCampType ;
			
			int iCount = 0;
			
			String sClassAppend = "_other";
			
			while (rs.next())
			{
				if (iCount % 2 != 0)
				{
					sClassAppend = "_other";
				}
				else
				{
					sClassAppend = "";
				}
				
				iCount++;

				sCurCampID = rs.getString (1);
				sCurCampName = new String (rs.getBytes(2), "UTF-8");
				sCurCampType = new String (rs.getBytes(3), "UTF-8");
				%>
				<tr>
					<td align="left" valign="middle" class="listItem_Data<%= sClassAppend %>">
						<%= sCurCampName %>
					</td>
					<td align="left" valign="middle" class="listItem_Data<%= sClassAppend %>">
						<%= sCurCampType %>
					</td>
				</tr>
				<%
			}
			%>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 3 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader width="100%">&nbsp;<b class=sectionheader>Super Campaign:</b> Links</td>
		<td nowrap>&nbsp;&nbsp;&nbsp;<a class="newbutton" href="super_link_edit.jsp?super_camp_id=<%=superCampID%>&category_id=<%=sSelectedCategoryId%>">New Link</a>&nbsp;&nbsp;&nbsp;</td>
	</tr>
</table>
<br>
<!---- Step 3 Info----->
		<%
		//Grab all of this super campaign's links.
		int nLinks = 0;
		
		sSql = "SELECT super_link_id, super_link_name FROM crpt_super_link WHERE super_camp_id = "+superCampID
			+ " ORDER BY super_link_id";
			
		rs = stmt.executeQuery(sSql);
		
		String sLinkID,sLinkName ;
		
		while (rs.next())
		{

			sLinkID = rs.getString (1);
			sLinkName = new String (rs.getBytes(2), "UTF-8");
			nLinks++;
			%>
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<table cellspacing="1" cellpadding="2" border="0" class="main" align="right">
				<tr>
					<td align="center" valign="middle" style="padding:4px;">
						&nbsp;&nbsp;&nbsp;&nbsp;<a class="savebutton" href="super_link_edit.jsp?super_camp_id=<%= superCampID %>&super_link_id=<%= sLinkID %>&category_id=<%= sSelectedCategoryId %>">Edit</a>&nbsp;&nbsp;&nbsp;&nbsp;
						|&nbsp;&nbsp;&nbsp;&nbsp;<a class="deletebutton" href="#" onclick="if( confirm('Are you sure?') ) location.href='super_link_delete.jsp?super_camp_id=<%= superCampID %>&super_link_id=<%= sLinkID %>&category_id=<%= sSelectedCategoryId %>'">Delete</a>&nbsp;&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
			<%= sLinkName %>
			<hr size="1" width="100%">
			<table class=listTable cellspacing=0 cellpadding=2 width="100%">
				<tr>
					<th align="left" valign="middle">Link Name</th>
					<th align="left" valign="middle">Link URL</th>
					<th align="left" valign="middle">Campaign</th>
				</tr>
				<%
				String sCurLinkID,sCurLinkName, sCurLinkHref;
				
				sSql = "SELECT s.link_id, l.link_name, c.camp_name, l.href"
					+ " FROM crpt_super_link_link s, cjtk_link l, cque_campaign c"
					+ " WHERE s.link_id = l.link_id"
					+ " AND l.cont_id = c.cont_id"
					+ " AND s.super_link_id = "+sLinkID
					+ " AND s.super_camp_id = "+superCampID
					+ " ORDER BY c.camp_id, l.link_name";
					
				rs2 = stmt2.executeQuery(sSql);
				
				iCount = 0;
				
				while (rs2.next())
				{
					if (iCount % 2 != 0)
					{
						sClassAppend = "_other";
					}
					else
					{
						sClassAppend = "";
					}
					
					iCount++;
					
					sCurLinkID = rs2.getString (1);
					sCurLinkName = new String (rs2.getBytes(2), "UTF-8");
					sCurCampName = new String (rs2.getBytes(3), "UTF-8");
					sCurLinkHref = rs2.getString(4);
					%>
				<tr>
					<td align="left" valign="middle" class="list_row<%= sClassAppend %>">
						<%= sCurLinkName %>
					</td>
					<td align="left" valign="middle" class="listItem_Data<%= sClassAppend %>">
						<a href="<%= sCurLinkHref %>" target="_new"><%= sCurLinkHref %></a>
					</td>
					<td align="left" valign="middle" class="listItem_Data<%= sClassAppend %>">
						<%= sCurCampName %>
					</td>
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
				
			if (nLinks == 0)
			{
				%>
				<br>
				<a class="newbutton" href="super_link_scan.jsp?super_camp_id=<%= superCampID %>&category_id=<%= sSelectedCategoryId %>">Generate Links</a>
				<br><br>
				<%
			}
			%>
<br><br>
</FORM>
</body>
</HTML>
<%
	} catch(Exception ex) {
		ErrLog.put(this,ex,"super_camp_edit.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
		if (stmt2 != null) stmt2.close();
		if (conn2 != null) cp.free(conn2);
	}
%>
