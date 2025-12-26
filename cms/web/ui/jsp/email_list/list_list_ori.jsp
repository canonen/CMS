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
	<link rel="stylesheet" href="../../css/style2.css" TYPE="text/css">
	<SCRIPT src="../../js/scripts.js"></SCRIPT>
	<SCRIPT LANGUAGE="JAVASCRIPT">
	<%@ include file="../../js/scripts.js" %>
	</SCRIPT>
	<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>
	<SCRIPT src="../../js/jquery.js"></SCRIPT>
	<SCRIPT src="../../js/jquery.dataTables.js"></SCRIPT>
	<script type="text/javascript">
		$(document).ready(function() {
			$("#checkboxall").click(function() 
			{ 
				var checked_status = this.checked;  
				$(".check_me").each(function(){
					this.checked = checked_status;
				});				
			}); 
			
			$('#example tbody td').hover( function() {
				$(this).siblings().addClass('highlighted');
				$(this).addClass('highlighted');
			}, function() {
				$(this).siblings().removeClass('highlighted');
				$(this).removeClass('highlighted');
			} );
			$('#example2 tbody td').hover( function() {
				$(this).siblings().addClass('highlighted');
				$(this).addClass('highlighted');
			}, function() {
				$(this).siblings().removeClass('highlighted');
				$(this).removeClass('highlighted');
			} );
			oTable = $('#example').dataTable({
				"sDom": "tlrip",
				"aoColumns": [{ "bSortable": false },{ "bSortable": false },null,null],
				"aaSorting": [[ 2, "asc" ]]
			});
			
			$('#filter').change( function(){
				filter_string = $('#filter').val();
				oTable.fnFilter( filter_string , 2);
			});
		} );
	</script>
<script>
function openexplanation()
{
	var popurl="list_explanation.jsp?typeID=2"
	winpops=window.open(popurl,"","width=400,height=300,")
}
</script>
</HEAD>
<BODY class="paging_body">
<DIV id=tsnazzy><B class=ttop><B class=tb1></B><B class=tb2></B><B 
class=tb3></B><B class=tb4></B></B>
	<div class="tip tboxcontent">
		<strong>Email marketing tip #6:</strong> Which Testing List should I create? <a href="javascript:openexplanation()">Learn more >></a>
	</div>
	<B class=tbottom><B class=tb4></B><B 
class=tb3></B><B class=tb2></B><B class=tb1></B></B></DIV>
<div class="page_header">Testing Lists</div>
<div class="page_desc">Create testing lists to send mini test campaigns before launching the real one.</div>
<%
if(can.bWrite)
{
	%>
<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent">
<table cellspacing="0" cellpadding="4" border="0">
	<tr><td align="left" valign="middle">
			<a class="newbutton" href="list_edit.jsp?typeID=<%= listTypeID %>">
			&nbsp;New </a>
		</td>	
	<%
	if (listTypeID.equals("2") && canSpecTest)
	{
		%>
		<td align="left" valign="middle">
			<a class="newbutton" href="list_edit.jsp?typeID=5">
			&nbsp;New Specified</a>
		</td>	
		
		<td align="left" valign="middle">
			<a class="newbutton" href="list_edit.jsp?typeID=7">
			&nbsp;New Dynamic Content</a>
		</td>
		<%
	}
	else if (listTypeID.equals("3"))
	{
		%>
		<td align="left" valign="middle">
			<a class="newbutton" href="list_import.jsp?typeID=<%=listTypeID%>">
			&nbsp;Import List</a>
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
<table cellspacing="0" cellpadding="0" width="100%" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<table class="list_table" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th align="left" nowrap><%= listType %>&nbsp;</TH>
				</tr>
			</table>
			<table class="list_table" id="example"  width="100%" cellpadding="2" cellspacing="0">
				<thead>
					<th><input type="checkbox" id="checkboxall"></th>
					<th></th>
					<th nowrap width="50%">List Name</th>
					<%=((listTypeID.equals("2") || listTypeID.equals("4"))?"<th nowrap width=\"50%\">List Type</th>":"")%>
				</thead>
				<tbody>
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
					sClassAppend = "_other";
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
					<td nowrap class="list_row<%= sClassAppend %>"><input type="checkbox" class="check_me" name="check1"></td>
					<td nowrap class="list_row<%= sClassAppend %>"><img src="../../images/icon_report_18_18.png" border="0" alt=""></td>
					<td nowrap class="list_row<%= sClassAppend %>"><A HREF="list_edit.jsp?listID=<%=id%>" TARGET="_self"><%=name%></A></td>
					<%=((listTypeID.equals("2") || listTypeID.equals("4"))?"<td nowrap class=\"list_row" + sClassAppend + "\">"+typeName+"</td>":"")%>
				</tr>
				<%
			}
			rs.close();
				
			if (i == 0)
			{
				%>
				<tr>
					<td nowrap class="listItem_Data" colspan="2">There are currently no <%= listType %>s</td>
				</tr>
				<%
			}
			%>
			</tbody>
			</table>
		</td>
	</tr>
</table>
</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>
</div>
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
