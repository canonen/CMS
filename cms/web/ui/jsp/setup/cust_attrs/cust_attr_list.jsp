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
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<link rel="stylesheet" href="/cms/ui/css/demo_table_jui.css" TYPE="text/css">
<link rel="stylesheet" href="/cms/ui/css/jquery-ui-1.7.2.custom.css" TYPE="text/css">
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>	

	<SCRIPT src="../../../js/jquery.js"></SCRIPT>
	<SCRIPT src="/cms/ui/js/jquery.dataTables.min_new.js"></SCRIPT>
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


<div class="page_header"><fmt:message key="header_custom_fields"/></div>
<div class="page_desc"><fmt:message key="header_custom_fields_desc"/></div>
<div id="info">
<div id="xsnazzy">

<div class="xboxcontent">
			<TABLE class=listTable cellSpacing=0 cellPadding=2 width="100%" style="padding-top: 4px;">
				<TBODY>
					<TR>
						<TD noWrap align=left style="padding-left:10px; width:5%;">

<%
if (can.bWrite)
{
	if (nUIType == UIType.ADVANCED)
	{
		%>
							<a class="newbutton" href="cust_attr_edit.jsp">
							<fmt:message key="button_custom_fields"/></a>&nbsp;&nbsp;&nbsp;
		<%
		if( (cust.s_parent_cust_id != null) && (!"0".equals(cust.s_parent_cust_id)) )
		{
			%>
						</TD>
						<TD noWrap align=left style="padding-left:10px; width:5%;"><a class="newbutton" href="cust_attr_inherit.jsp">Inherit from Parent</a>
			<%
		}
	}
	%>
						</TD>
						<TD noWrap align=left style="padding-left:10px; width:5%;"><a class="newbutton" href="cust_attr_recip_view_seq.jsp"><fmt:message key="button_custom_fields_set_view"/></a>
						</TD>
						<TD noWrap align=left style="padding-left:10px; width:5%;"><a class="newbutton" href="cust_attr_seq.jsp"><fmt:message key="button_custom_fields_set_display"/></a>
	<%
}
%>
						</TD>
						<TD noWrap align=right style="padding-right:10px;">
							<A class="newbutton" href="cust_attr_list.jsp"><fmt:message key="button_refresh"/></A>
						</TD>
					</TR>
				</TBODY>
			</TABLE>
			
			
			<div class="list-headers"><fmt:message key="header_custom_fields"/></div>
			
			<table class="listTable" id="example" width="100%" cellpadding="2" cellspacing="0">
				<thead>
					<th><input type="checkbox" id="checkboxall"></th>
					<th></th>
					<th width="30%"  valign="middle" nowrap><fmt:message key="custom_fields_column_name"/></th>
					<th width="30%"  valign="middle" nowrap><fmt:message key="custom_fields_column_attr_name"/></th>
					<th width="25%" valign="middle" nowrap><fmt:message key="custom_fields_column_field_type"/></th>
					<th width="5%" valign="middle" nowrap>Multi-value</th>
					<th width="5%" valign="middle" nowrap>Fingerprint</th>
					<th width="5%" valign="middle" nowrap>Newsletter</th>
				</thead>
				<tbody>					
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
						sClassAppend = "_other";
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
					<td class="list_row<%= sClassAppend %>"><input type="checkbox" class="check_me" name="check1"></td>
					<td class="list_row<%= sClassAppend %>"><img src="../../../images/icon_report_18_18.png" border="0" alt=""></td>
					<td class="list_row<%= sClassAppend %>"><a href="cust_attr_edit.jsp?attr_id=<%=sAttrId%>"><%=sDisplayName%></a></td>
					<td class="list_row<%= sClassAppend %>"><%=sAttrName%></td>
					<td class="list_row<%= sClassAppend %>"><%=sTypeName%></td>
					<td class="list_row<%= sClassAppend %>" align="center"><INPUT type="checkbox" <%=(sValueQty==null)?"":"checked"%> disabled></td>
					<td class="list_row<%= sClassAppend %>" align="center"><INPUT type="checkbox" <%=(sFingerprintSeq==null)?"":"checked"%> disabled></td>
					<td class="list_row<%= sClassAppend %>" align="center"><INPUT type="checkbox" <%=(sNewsletterFlag==null)?"":"checked"%> disabled></td>
				</tr>
				<%
				}
				rs.close();
				
				if (i == 0)
				{
					%>
				<tr>
					<td class="listItem_Title" colspan="8">There are currently no Custom Fields</td>
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
</div>

</div>
</div>			
		</td>
	</tr>
</table>
<br><br>
</body>
</fmt:bundle>
</HTML>
