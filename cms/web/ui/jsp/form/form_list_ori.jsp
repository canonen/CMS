<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<HTML>
<HEAD>
	<TITLE>Subscription Forms</TITLE>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<link rel="stylesheet" href="../../css/style2.css" TYPE="text/css">	
	<SCRIPT src="../../js/scripts.js"></SCRIPT>
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
				"aoColumns": [{ "bSortable": false },{ "bSortable": false },null,null,null,null,null],
				"aaSorting": [[ 7, "asc" ]]
			});
			oTable2 = $('#example2').dataTable({
				"sDom": "tlrip",
				"aoColumns": [null,null,null,null,null,null,null],
				"aaSorting": [[ 0, "desc" ]]
			});
			
			$('#filter').change( function(){
				filter_string = $('#filter').val();
				oTable.fnFilter( filter_string , 2);
				filter_string = $('#filter').val();
				oTable2.fnFilter( filter_string , 3);
			});
		} );
	</script>

<script language="javascript">
function PreviewForm(freshurl)
{
	var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,height=500,width=650';
	SmallWin = window.open(freshurl,'Filter',window_features);
}
function PreviewURL(freshurl)
{
	var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,height=250,width=650';
	SmallWin = window.open(freshurl,'Filter',window_features);
}
</script>	
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>
	
</HEAD>
<BODY class="paging_body"><DIV id=tsnazzy><B class=ttop><B class=tb1></B><B class=tb2></B><B 
class=tb3></B><B class=tb4></B></B>
	<div class="tip tboxcontent">
		<strong>Email marketing tip #5:</strong> To reduce the number of bogus email addresses in your contact list, always use a double opt-in subscription system. <a href="tips">Read more.</a>
	</div>
	<B class=tbottom><B class=tb4></B><B 
class=tb3></B><B class=tb2></B><B class=tb1></B></B></DIV>
<div class="page_header">Forms</div>
<div class="page_desc">Manage your forms.</div>
<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent">
			<TABLE class=listTable cellSpacing=0 cellPadding=2 width="100%" style="padding-top: 4px;">
				<TBODY>
					<TR>
						<TD noWrap align=left style="padding-left:10px; width:5%;">
	<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	String admin = request.getParameter("admin");
	if (admin != null && admin.equals("1"))
	{
		%>
							<a class="newbutton" href="form_edit.jsp">
							<img border="0" src="../../images/refresh.png" align="absmiddle">&nbsp;New Form</a>&nbsp;&nbsp;&nbsp;
		</td>
		<%
	}
	%>
						</TD>
						<TD noWrap align=right style="padding-right:10px;">
							<A class="newbutton" href="form_list.jsp">&nbsp;Refresh</A>
						</TD>
					</TR>
				</TBODY>
			</TABLE>
			<table class="list_table" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th align="left" nowrap>Forms&nbsp;	</TH>
				</tr>
			</table>
			<table class="list_table" id="example" width="100%" cellpadding="2" cellspacing="0">
				<thead>
					<th><input type="checkbox" id="checkboxall"></th>
					<th></th>
					<th width="10%"  valign="middle" nowrap>Form Name</th>
					<th width="10%"  valign="middle" nowrap>ID</th>
					<th width="10%" valign="middle" nowrap>Form URL / Preview</th>
					<th width="10%" valign="middle" nowrap>Modify Date</th>
					<th width="60%" valign="middle" nowrap>Create Date</th>
				</thead>
				<tbody>
		<%
		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt =null;
			
		try
		{
			cp = ConnectionPool.getInstance();			
			conn = cp.getConnection(this);
			
			stmt = conn.createStatement();

			String sSql =
				" SELECT" +
				"	f.form_id," +
				"	f.form_name," +
				"	f.form_url," +
				"	fei.modify_date," +
				"	fei.create_date" +
				" FROM csbs_form f, csbs_form_edit_info fei" +
				" WHERE" +
				"	f.cust_id=" + cust.s_cust_id + " AND" +
				"	fei.form_id = f.form_id" +
				" ORDER BY fei.modify_date desc";
				
			ResultSet rs = stmt.executeQuery(sSql);

			int i;
			boolean oneForm = false;	
			String formName, cpsFormID, formURL, formURLStripped = "";
			
			String sClassAppend = "";
			int formCount = 0;
			
			byte[] b = null;
			while (rs.next())
			{
				if (formCount % 2 != 0)
				{
					sClassAppend = "_other";
				}
				else
				{
					sClassAppend = "";
				}
				formCount++;
				
				oneForm = true;
				cpsFormID = rs.getString(1);
				b = rs.getBytes(2);
				formName = (b==null)?null:new String(b, "UTF-8");
				b = rs.getBytes(3);			
				formURL = (b==null)?null:new String(b, "UTF-8");
				if (formURL == null)
				{
					formURLStripped = "";
					formURL = "";
				}
				else
				{
					i = formURL.indexOf('&');
					if (i != -1)
						formURLStripped = formURL.substring(0,i);
					else
						formURLStripped = formURL;
				}
				%>
		
				<tr>
					<td class="list_row<%= sClassAppend %>"><input type="checkbox" class="check_me" name="check1"></td>
					<td class="list_row<%= sClassAppend %>"><img src="../../images/icon_report_18_18.png" border="0" alt=""></td>
					<% if (admin != null && admin.equals("1")) { %>
					<td class="list_row<%= sClassAppend %>" nowrap><A HREF="form_edit.jsp?form_id=<%= cpsFormID %>"><%= formName %></A></td>
					<% } else { %>
					<td class="list_row<%= sClassAppend %>" nowrap><%= formName %></td>
					<% } %>
					<td class="list_row<%= sClassAppend %>" nowrap><%=cpsFormID%></td>
					<td class="list_row<%= sClassAppend %>" nowrap><a href="javascript:PreviewForm('<%= formURLStripped %>')"><%= formURL %></a></td>
					<td class="list_row<%= sClassAppend %>" nowrap><%= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(4)) %></td>
					<td class="list_row<%= sClassAppend %>" nowrap><%= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(5)) %></td>
				</tr>

				<%
			}
			if (!oneForm)
			{
				%>
				<tr>
					<td class="listItem_Title" colspan="7">There are currently no Forms</td>
				</tr>
				<%
			}
			rs.close();
		}
		catch(Exception ex)
		{
			throw ex;
		}
		finally
		{
			if (stmt!=null) stmt.close();
			if (conn!=null) cp.free(conn);
		}
		%>
			</table>
</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>
</div>			
		</td>
	</tr>
</table>
<br><br>
</BODY>
</HTML>
