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
%>		
<HTML>

<HEAD>
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
	<link rel="stylesheet" href="../../../css/style2.css" TYPE="text/css">	
	<SCRIPT src="../../../../js/scripts.js"></SCRIPT>
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>	
	<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>
	<SCRIPT src="../../../js/jquery.js"></SCRIPT>
	<SCRIPT src="../../../js/jquery.dataTables.js"></SCRIPT>
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
				"aoColumns": [{ "bSortable": false },{ "bSortable": false },null],
				"aaSorting": [[ 3, "asc" ]]
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
</HEAD>

<BODY class="paging_body">
<DIV id=tsnazzy><B class=ttop><B class=tb1></B><B class=tb2></B><B 
class=tb3></B><B class=tb4></B></B>
	<div class="tip tboxcontent">
		<strong>Email marketing tip #5:</strong> To reduce the number of bogus email addresses in your contact list, always use a double opt-in subscription system. <a href="tips">Read more.</a>
	</div>
	<B class=tbottom><B class=tb4></B><B 
class=tb3></B><B class=tb2></B><B class=tb1></B></B></DIV>
<div class="page_header">From Addresses</div>
<div class="page_desc">Create different from addresses for different campaigns.</div>
<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent">
			<TABLE class=listTable cellSpacing=0 cellPadding=2 width="100%" style="padding-top: 4px;">
				<TBODY>
					<TR>
						<TD noWrap align=left style="padding-left:10px; width:5%;">
							<a class="newbutton" href="from_address_edit.jsp">
							New From Address</a>
						</TD>
						<TD noWrap align=right style="padding-right:10px;">
							<A class="newbutton" href="from_address_list.jsp"><img src="../../../images/refresh.png" align="absmiddle">&nbsp;Refresh</A>
						</TD>
					</TR>
				</TBODY>
			</TABLE>
			<table class="list_table" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th align="left" nowrap>From Addresses&nbsp;	</TH>
				</tr>
			</table>
			<table class="list_table" id="example" width="100%" cellpadding="2" cellspacing="0">
				<thead>
					<th><input type="checkbox" id="checkboxall"></th>
					<th></th>
					<th width="100%"  valign="middle" nowrap>From Address</th>
				</thead>
				<tbody>
		<%

		ConnectionPool cp = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null; 
		String sSQL = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection(this);
			stmt = conn.createStatement();

			sSQL =
				" SELECT from_address_id, prefix, domain" +
				" FROM ccps_from_address" +
				" WHERE cust_id=" + cust.s_cust_id +
				" ORDER BY prefix";

			rs = stmt.executeQuery(sSQL);

			String sFromAddressId = null;
			String sPrefix = null;
			String sDomain = null;
				
			String sClassAppend = "";
			int i = 0;

			while(rs.next())
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
				
				sFromAddressId = rs.getString(1);
				sPrefix = rs.getString(2);
				sDomain = rs.getString(3);
				%>
								
				<tr>
					<td class="list_row<%= sClassAppend %>"><input type="checkbox" class="check_me" name="check1"></td>
					<td class="list_row<%= sClassAppend %>"><img src="../../../images/icon_report_18_18.png" border="0" alt=""></td>
					<td class="list_row<%= sClassAppend %>"><a href="from_address_edit.jsp?from_address_id=<%=sFromAddressId%>"><%=sPrefix%>@<%=sDomain%></a></td>
				</tr>
				<%
			}
			rs.close();
				
			if (i == 0)
			{
				%>
				<tr>
					<td class="list_row" colspan="3">There are currently no From Addresses</td>
				</tr>
				<%
			}
		}
		catch(Exception ex)
		{
			ex.printStackTrace(response.getWriter());
		}
		finally
		{
			if(conn!=null) cp.free(conn);
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
