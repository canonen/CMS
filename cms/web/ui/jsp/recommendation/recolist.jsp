<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			org.json.JSONObject,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

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
	<TITLE>Subscription Forms</TITLE>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<link rel="stylesheet" href="/cms/ui/css/demo_table_jui.css" TYPE="text/css">
<link rel="stylesheet" href="/cms/ui/css/jquery-ui-1.7.2.custom.css" TYPE="text/css">
<link rel="stylesheet" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" type="text/css">
<link rel="stylesheet" href="https://cdn.datatables.net/rowreorder/1.2.6/css/rowReorder.dataTables.min.css" type="text/css">

	<SCRIPT src="../../js/scripts.js"></SCRIPT>
	<!--<SCRIPT src="../../js/jquery.js"></SCRIPT>
	<SCRIPT src="/cms/ui/js/jquery.dataTables.min_new.js"></SCRIPT>
	<SCRIPT src="/cms/ui/js/jquery.dataTables.rowReorder.min.js"></SCRIPT>-->
	<script src="https://code.jquery.com/jquery-3.3.1.js"></script>
	<script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
	<script src="https://cdn.datatables.net/rowreorder/1.2.6/js/dataTables.rowReorder.min.js"></script>
	<script type="text/javascript">
	<%
	Service service = null;
	Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
	service = (Service) services.get(0);
	String rcpUrl = service.getURL().getHost();
%>
	var rcpUrl = '<%=rcpUrl%>';
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
			/*oTable = $('#example').dataTable( {
				"sPaginationType": "full_numbers",
				rowReorder: {
					selector: 'td:first-child'
				}
			} );*/
			
			$("#example thead tr").prepend('<th>#</td>');    
			var count = $("#example tbody tr").length-1;
			$("#example tbody tr").each(function(i, tr) {
				$(tr).attr('id', 'id'+i);
				$(tr).prepend('<td style="cursor:move;">'+parseInt(i+1)+'</td>');     
			});  
			
			$("#example").dataTable( {
				"sPaginationType": "full_numbers",
				rowReorder: {
					selector: 'td:first-child'
				}
			} );
			
			$('#filter').change( function(){
				filter_string = $('#filter').val();
				oTable.fnFilter( filter_string , 2);
				filter_string = $('#filter').val();
				oTable2.fnFilter( filter_string , 3);
			});
			
			
			/*oTable.on( 'row-reorder', function ( e, diff, edit ) {
			        console.log(e,diff,edit);
    			} );*/
			
			
			
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
<BODY class="paging_body">
<div class="page_header">Recommendations</div>
<div class="page_desc">Manage your Recommendations</div>
<div id="info">
<div id="xsnazzy">

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
		%>
							<a id="create_recommendation" class="newbutton">New Recommendation</a>
							<a id="generate_code" class="newbutton" href="#">Generate Code</a>
							<a id="delete_recommendation" class="newbutton" href="#">Delete</a>
		</td>
						</TD>
					</TR>
				</TBODY>
			</TABLE>
			
			<div class="list-headers">Forms</div>
			<table class="listTable" id="example" width="100%" cellpadding="2" cellspacing="0">
				<thead>
					<th></th>
					<th><input type="checkbox" id="checkboxall"></th>
					<th width="26%"  valign="middle" nowrap>Campaign Name</th>
					<th width="20%"  valign="middle" nowrap>Campaign Id</th>
					<th width="4%"  valign="middle" nowrap>Enabled</th>
					<th width="4%"  valign="middle" nowrap>Filter</th>
					<th width="20%"  valign="middle" nowrap>Modify Date</th>
					<th width="20%"  valign="middle" nowrap>Create Date</th>
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
				"	camp_name," +
				"	camp_id," +
				"	modify_date," +
				"	create_date," +
				"	status," +
				"	filter_id" +
				" FROM c_recommendation_config" +
				" WHERE status <> 90 AND " +
				"	cust_id=" + cust.s_cust_id;
				
			ResultSet rs = stmt.executeQuery(sSql);
			
			boolean noConfig = true;
			int counter = 0;
			while (rs.next())
			{
				Long enabled = rs.getLong(5);
				Integer filterId = rs.getInt(6);
				
				noConfig = false;
				%>
		
				<tr id="tr_id_<%=counter%>">
					<td style="cursor:move;" class="list_row"><img src="../../images/icon_report_18_18.png" border="0" alt=""></td>
					<td class="list_row" nowrap><input type="checkbox" class="check_me selected_config" name="check1" value="<%=rs.getString(2)%>"></td>
					<td class="list_row" nowrap><a href="/cms/ui/recommendation/newui/main.jsp?cust_id=<%=cust.s_cust_id%>&camp_id=<%=rs.getString(2)%>"><%=rs.getString(1)%></a></td>
					<td class="list_row" nowrap><%=rs.getString(2)%></td>
					<td class="list_row" nowrap><%=enabled == 1 ? "true" : "false"%></td>
					<td class="list_row" nowrap><%=(filterId == null || filterId <=0) ? "false" : "true"%></td>
					<td class="list_row" nowrap><%= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(3)) %></td>
					<td class="list_row" nowrap><%= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(4)) %></td>
				</tr>

				<%
				counter++;
			}
			if (noConfig)
			{
				%>
				<tr>
					<td class="listItem_Title" colspan="7">There are currently no Recommendations</td>
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
</div>
</div>			
		</td>
	</tr>
</table>
<br><br>
<script>

   	var custName = '<%=cust.s_login_name%>';
	var customerId = '<%=cust.s_cust_id%>';
	var popupList;
	document.getElementById('create_recommendation').href = "/cms/ui/recommendation/newui/main.jsp?cust_id=<%=cust.s_cust_id%>";
	document.getElementById('generate_code').addEventListener('click',function() {
			var width = 500;
		    var height = 300;
		    var left = (screen.width/2)-(width/2);
		    var top = (screen.height/2)-(height/2);
           		window.open("../../recommendation/generated.html", "Javascript Code", "height="+height+",width="+width+",left="+left+",top="+top);
	});
	document.getElementById('delete_recommendation').addEventListener('click',function(){
			if(document.querySelectorAll(".selected_config:checked").length === 0) {
				alert("No configuration selected!");
				return;
			}
			var confirmDelete = confirm("Are you sure you want to delete selected recommendation configurations");
			if(!confirmDelete)
				return;
			var selectedConfigs = [];
			Array.from(document.querySelectorAll(".selected_config:checked")).forEach(function(element) {
				selectedConfigs.push(element.value);
			});
			fetch('http://cms.revotas.com/cms/ui/recommendation/delete_recommendation_config.jsp?cust_id=<%=cust.s_cust_id%>&config_idlist=' + selectedConfigs.join(','))
			.then(function() {
				fetch('http://f.revotas.com/frm/recommendation/delete_recommendation_config.jsp?cust_id=<%=cust.s_cust_id%>&config_idlist=' + selectedConfigs.join(','))
				.then(function() {
					fetch('http://'+rcpUrl+'/rrcp/imc/recommendation/delete_recommendation_config.jsp?cust_id=<%=cust.s_cust_id%>&config_idlist=' + selectedConfigs.join(','))
					.then(function() {
						window.location = "recolist.jsp";
					})
				})
			});
	});
</script>
</body>
</fmt:bundle>
</HTML>
