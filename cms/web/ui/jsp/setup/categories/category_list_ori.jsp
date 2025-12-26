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
	<link rel="stylesheet" href="../../../css/style2.css" TYPE="text/css">	
	<SCRIPT src="../../../../js/scripts.js"></SCRIPT>
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>	
	<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>
	<SCRIPT src="../../../js/jquery.js"></SCRIPT>
	<SCRIPT src="../../../js/jquery.dataTables.js"></SCRIPT>
	<SCRIPT src="../../../js/disable_forms.js"></SCRIPT>
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
				"aoColumns": [{ "bSortable": false },{ "bSortable": false },null,null,null],
				"aaSorting": [[ 2, "asc" ]]
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
<div class="page_header">Categories</div>
<div class="page_desc">Group your campaigns in categories.</div>
<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent">
			<TABLE class=listTable cellSpacing=0 cellPadding=2 width="100%" style="padding-top: 4px;">
				<TBODY>
					<TR>
						<TD noWrap align=left style="padding-left:10px; width:5%;">
<%
if(can.bWrite)
{
	%>
							<a class="newbutton" href="category_edit.jsp">
							New Category</a>
			
		<%
		if (bCanDefault && (sDefaultCategoryID != null))
		{
			%>
						</td>
						<TD noWrap align=left style="padding-left:10px; width:5%;">
							<a class="newbutton" href="set_default.jsp?category_id=0">
							Clear Default</a>
			<%
		}
		%>

		<%
}
%>
						</TD>
						<TD noWrap align=right style="padding-right:10px;">
							<A class="newbutton" href="category_list.jsp"><img src="../../../images/refresh.png" align="absmiddle">&nbsp;Refresh</A>
						</TD>
					</TR>
				</TBODY>
			</TABLE>
			<table class="list_table" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th align="left" nowrap>Users&nbsp;	</TH>
				</tr>
			</table>
			<table class="list_table" id="example" width="100%" cellpadding="2" cellspacing="0">
				<thead>
					<th><input type="checkbox" id="checkboxall"></th>
					<th></th>
					<th width="10%"  valign="middle" nowrap>Name</th>
					<th width="10%"  valign="middle" nowrap>Description</th>
					<th width="80%"></th>
				</thead>
				<tbody>
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
						sClassAppend = "_other";
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
						<td class="list_row<%= sClassAppend %>"><input type="checkbox" class="check_me" name="check1"></td>
						<td class="list_row<%= sClassAppend %>"><img src="../../../images/icon_report_18_18.png" border="0" alt=""></td>
						<td class="list_row<%= sClassAppend %>">
							<%=(sCategoryId.equals(sDefaultCategoryID))?"* ":""%>
							<a href="category_edit.jsp?category_id=<%=sCategoryId%>" target="_self"><%=sCategoryName%></a>
						</td>
						<td class="list_row<%= sClassAppend %>"><%=sCategoryDescrip%></td>
					<%
					if (bCanDefault)
					{
						%>
						<td class="list_row<%= sClassAppend %>" align="right"><%=(sCategoryId.equals(sDefaultCategoryID))?"Default":
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
						<td class="listItem_Title" colspan="5">There are currently no Categories</td>
					</tr>
					<%
				}
				%>
			</table>
		</td>
	</tr>
</table>
</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>
</div>	
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