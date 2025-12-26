<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

boolean canSpecTest = ui.getFeatureAccess(Feature.SPECIFIED_TEST);
boolean canTestHelp = ui.getFeatureAccess(Feature.TESTING_HELP);
%>

<%
// Connection
ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("list_list.jsp");
	stmt = conn.createStatement();

	String listTypeID = request.getParameter("typeID");
	if (listTypeID == null) listTypeID = "2";

	String listType = "Testing List";
	if (listTypeID.equals("1")) listType = "Global Exclusion List";
	if (listTypeID.equals("3")) listType = "Exclusion List";
	if (listTypeID.equals("4")) listType = "Auto-Respond Notification List";
//	if (listTypeID.equals("5")) listType = "Specified Test Recipient List";

	String		id, name, typeName;
%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script>
function openexplanation()
{
	var popurl="list_explanation.jsp?typeID=2"
	winpops=window.open(popurl,"","width=400,height=300,")
}
</script>
</HEAD>
<BODY>
<%
if(can.bWrite)
{
	%>
<table cellspacing="0" cellpadding="4" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="newbutton" href="list_edit.jsp?typeID=<%= listTypeID %>">New</a>
		</td>	
	<%
	if (listTypeID.equals("2") && canSpecTest)
	{
		%>
		<td align="left" valign="middle">
			<a class="newbutton" href="list_edit.jsp?typeID=5">New Specified</a>
		</td>
		<td align="left" valign="middle">
			<a class="newbutton" href="list_edit.jsp?typeID=7">New Dynamic Content</a>
		</td>
		<td align="left" valign="middle">
			Which Testing List should I create? <a class="resourcebutton" href="javascript:openexplanation()">Learn more >></a>
		</td>
		<%
	}
	else if (listTypeID.equals("3"))
	{
		%>
		<td align="left" valign="middle">
			<a class="newbutton" href="list_import.jsp?typeID=<%=listTypeID%>">Import List</a>
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
<FORM  METHOD="POST" NAME="FT" ACTION="">
<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<%= listType %>&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th>List Name</th>
					<%=((listTypeID.equals("2") || listTypeID.equals("4"))?"<th>List Type</th>":"")%>
				</tr>
			<%
			String sSql = 
					" SELECT list_id, list_name, type_name" +
					" FROM cque_email_list l, cque_list_type t " +
					" WHERE" +
					" (l.type_id = "+listTypeID+(listTypeID.equals("4")?" OR l.type_id = 6":"")+((listTypeID.equals("2") && canSpecTest)?" OR l.type_id = 5 OR l.type_id = 7":"")+") " +
					" AND cust_id = "+cust.s_cust_id+
					" AND l.type_id = t.type_id " +
					" AND list_name not like 'ApprovalRequest(%)' " +
					" AND l.status_id = '" + EmailListStatus.ACTIVE +  "'" +
					" ORDER BY list_name ASC";
									
			rs = stmt.executeQuery(sSql);
				
			String sClassAppend = "";
			int i = 0;

			while( rs.next() )
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
				
				id = rs.getString(1);
				name = new String(rs.getBytes(2),"UTF-8");
				typeName = new String(rs.getBytes(3),"UTF-8");

				%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>"><A HREF="list_edit.jsp?listID=<%=id%>" TARGET="_self"><%=name%></A></td>
					<%=((listTypeID.equals("2") || listTypeID.equals("4"))?"<td class=\"listItem_Data" + sClassAppend + "\">"+typeName+"</td>":"")%>
				</tr>
				<%
			}
			rs.close();
				
			if (i == 0)
			{
				%>
				<tr>
					<td class="listItem_Data" colspan="2">There are currently no <%= listType %>s</td>
				</tr>
				<%
			}
			%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</FORM>
</BODY>
</HTML>
<%
}
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (conn  != null) cp.free(conn); 
}
%>
