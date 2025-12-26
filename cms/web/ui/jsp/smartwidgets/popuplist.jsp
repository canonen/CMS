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
<div class="page_header">Popups</div>
<div class="page_desc">Manage your Popups</div>
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
							<a id="create_popup" class="newbutton">New Popup</a>
							<a id="generate_code" class="newbutton" href="#">Generate Code</a>
							<a id="delete_popup" class="newbutton" href="#">Delete</a>
		</td>
						</TD>
						<TD noWrap align=right style="padding-right:10px;">
							<A id="save_order" class="newbutton" href="#">Save Order</A>
							<A class="newbutton" href="popuplist.jsp">&nbsp;<fmt:message key="button_refresh"/></A>
						</TD>
					</TR>
				</TBODY>
			</TABLE>
			
			<div class="list-headers">Forms</div>
			<table class="listTable" id="example" width="100%" cellpadding="2" cellspacing="0">
				<thead>
					<th></th>
					<th><input type="checkbox" id="checkboxall"></th>
					<th width="26%"  valign="middle" nowrap>Popup Name</th>
					<th width="20%"  valign="middle" nowrap>Popup Id</th>
					<th width="8%"  valign="middle" nowrap>Enabled</th>
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
				"	popup_name," +
				"	popup_id," +
				"	modify_date," +
				"	create_date," +
				"	config_param" +
				" FROM c_smart_widget_config" +
				" WHERE status <> 90 AND " +
				"	cust_id=" + cust.s_cust_id +
				" ORDER BY order_number asc";
				
			ResultSet rs = stmt.executeQuery(sSql);


			boolean noPopup = true;
			int counter = 0;
			while (rs.next())
			{
				JSONObject configParam = new JSONObject(rs.getString(5));
				boolean enabled = configParam.getBoolean("enabled");
				noPopup = false;
				%>
		
				<tr id="tr_id_<%=counter%>">
					<td style="cursor:move;" class="list_row"><img src="../../images/icon_report_18_18.png" border="0" alt=""></td>
					<td class="list_row" nowrap><input type="checkbox" class="check_me selected_popup" name="check1" value="<%=rs.getString(2)%>" widgetStatus="<%=enabled%>"></td>
					<td class="list_row" style="position:relative;" nowrap>
						<a href="/cms/ui/smartwidgets/newui/main.jsp?popup_id=<%=rs.getString(2)%>"><%=rs.getString(1)%></a>
						<a class="newbutton" onclick="copyPopup('<%=rs.getString(2)%>',`<%=rs.getString(1)%>`)" style="display:none;position: absolute;right: 0;">Copy</a>
					</td>
					<td class="list_row" nowrap><%=rs.getString(2)%></td>
					<td class="list_row" nowrap><%=enabled%></td>
					<td class="list_row" nowrap><%= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(3)) %></td>
					<td class="list_row" nowrap><%= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(4)) %></td>
				</tr>

				<%
				counter++;
			}
			if (noPopup)
			{
				%>
				<tr>
					<td class="listItem_Title" colspan="7">There are currently no Popups</td>
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

<%
Service service = null;
	Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
	service = (Service) services.get(0);
   String rcpUrl = service.getURL().getHost();
%>
	var rcp_url = '<%=rcpUrl%>';
   	var custName = '<%=cust.s_login_name%>';
	var customerId = '<%=cust.s_cust_id%>';
	var popupList;
	document.getElementById('create_popup').href = "/cms/ui/smartwidgets/newui/main.jsp";
	document.getElementById('generate_code').addEventListener('click',function() {
			var width = 500;
		    var height = 300;
		    var left = (screen.width/2)-(width/2);
		    var top = (screen.height/2)-(height/2);
           		window.open("../../smartwidgets/generated.html", "Javascript Code", "height="+height+",width="+width+",left="+left+",top="+top);
	});
	document.getElementById('delete_popup').addEventListener('click',function(){
			if(document.querySelectorAll(".selected_popup:checked").length === 0) {
				alert("No configuration selected!");
				return;
			}
			var selectedPopups = [];
			var enabledWidgets = false;
			Array.from(document.querySelectorAll(".selected_popup:checked")).forEach(function(element) {
				if(enabledWidgets)return;
				selectedPopups.push(element.value);
				if(element.getAttribute('widgetStatus')=='true') {
					alert('Enabled widgets cannot be deleted');
					enabledWidgets = true;
					return;
				}
			});
			if(enabledWidgets)return;
			var confirmDelete = confirm("Are you sure you want to delete selected popup configurations");
			if(!confirmDelete)
				return;
			fetch('https://cms.revotas.com/cms/ui/smartwidgets/delete_smartwidget_config.jsp?cust_id=<%=cust.s_cust_id%>&popup_idlist=' + selectedPopups.join(','))
			.then(function() {
				fetch('https://f.revotas.com/frm/smartwidgets/delete_smartwidget_config.jsp?cust_id=<%=cust.s_cust_id%>&popup_idlist=' + selectedPopups.join(','))
				.then(function() {
					fetch('https://'+rcp_url+'/rrcp/imc/smartwidgets/delete_smartwidget_config.jsp?cust_id=<%=cust.s_cust_id%>&popup_idlist=' + selectedPopups.join(','))
					.then(function() {
						window.location = "popuplist.jsp";
					})
				})
			});
	});
	document.getElementById('save_order').addEventListener('click',function() {
		var popupList = [];
		Array.from(document.getElementById('example').querySelectorAll('tbody > tr')).forEach(function(tr) {
			popupList.push(tr.children[4].innerText);
		});
		var popupString = popupList.join(',');
		fetch('https://cms.revotas.com/cms/ui/smartwidgets/save_smartwidget_config.jsp?is_order=1&order_string=' + popupString)
			.then(function() {
				fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_config.jsp?is_order=1&order_string=' + popupString)
				.then(function() {
					fetch('https://'+rcp_url+'/rrcp/imc/smartwidgets/save_smartwidget_config.jsp?cust_id=<%=cust.s_cust_id%>&is_order=1&order_string=' + popupString)
					.then(function() {
						alert('Order saved successfully');
					})
				})
			});
	});
	
	function copyPopup(popupId,popupName) {
		var answer = confirm('Are you sure you want to copy?');
		if(!answer)
			return;
	    fetch('https://f.revotas.com/frm/smartwidgets/get_smartwidget_config.jsp?cust_id=<%=cust.s_cust_id%>')
	    .then(function(resp) {return resp.json();})
	    .then(function(resp) {
	        resp=resp.filter(function(element) {
	            if(element.popupId==popupId)
	                return true;
	            return false;
	        });
	        if(resp.length==1)
	            resp=resp[0];
	        resp.object.enabled = false;
	
	        var form_id = resp.formId;
	        var popup_id = [...Array(30)].map(i=>(~~(Math.random()*36)).toString(36)).join('');
	    	var popup_name = popupName + ' Copy';
			fetch('https://cms.revotas.com/cms/ui/smartwidgets/save_smartwidget_config.jsp?enabled=0&popup_name='+popup_name+'&form_id='+form_id+'&cust_id=<%=cust.s_cust_id%>&popup_id='+popup_id,{	
				method: 'POST',
				headers: {
					'Content-Type':'application/json'
				},
				body: JSON.stringify(resp.object)
			}).then(function() {
	                fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_config.jsp?enabled=0&popup_name='+popup_name+'&form_id='+form_id+'&cust_id=<%=cust.s_cust_id%>&popup_id='+popup_id,{	
	                    method: 'POST',
	                    headers: {
	                        'Content-Type':'application/json'
	                    },
	                    body: JSON.stringify(resp.object)
	            }).then(function() {
	                    fetch('https://'+rcp_url+'/rrcp/imc/smartwidgets/save_smartwidget_config.jsp?enabled=0&popup_name='+popup_name+'&form_id='+form_id+'&cust_id=<%=cust.s_cust_id%>&popup_id='+popup_id,{	
	                        method: 'POST',
	                        headers: {
	                            'Content-Type':'application/json'
	                        },
	                        body: JSON.stringify(resp.object)
	                  }).then(function() {
	                        window.location = "popuplist.jsp";
	                    });
	            });
			
			});
	
	
	    })
}
	
	
</script>
</body>
</fmt:bundle>
</HTML>
