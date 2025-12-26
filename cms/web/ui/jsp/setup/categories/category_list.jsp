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
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<link rel="stylesheet" href="/cms/ui/css/demo_table_jui.css" TYPE="text/css">
	<link rel="stylesheet" href="/cms/ui/css/jquery-ui-1.7.2.custom.css" TYPE="text/css">
	<SCRIPT src="../../../../js/scripts.js"></SCRIPT>
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>	
	<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>
	<SCRIPT src="../../../js/jquery.js"></SCRIPT>
	<SCRIPT src="/cms/ui/js/jquery.dataTables.min_new.js"></SCRIPT>
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
			oTable = $('#example').dataTable( {
																				"bJQueryUI": true,
																				"sPaginationType": "full_numbers"
				} );
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

<div class="page_header"><fmt:message key="header_categories"/></div>
<div class="page_desc"><fmt:message key="header_categories_desc"/></div>
<div id="info">
<div id="xsnazzy">

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
							<fmt:message key="button_categories"/></a>
			
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
							<A class="newbutton" href="category_list.jsp"><fmt:message key="button_refresh"/></A>
						</TD>
					</TR>
				</TBODY>
			</TABLE>
			
			<div class="list-headers"></div>
			<table class="listTable" id="example" width="100%" cellpadding="2" cellspacing="0">
				<thead>
					<th><input type="checkbox" id="checkboxall"></th>
					<th></th>
					<th width="10%"  valign="middle" nowrap><fmt:message key="categories_column_name"/></th>
					<th width="10%"  valign="middle" nowrap><fmt:message key="categories_column_desc"/></th>
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
</body>
</fmt:bundle>
</HTML>