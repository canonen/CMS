<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.wfl.*,
			com.britemoon.cps.ctl.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.FILTER);
boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.FILTER);

boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

// === === ===

String sCurPage = request.getParameter("curPage");
int curPage = curPage = (sCurPage == null) ? 1 : Integer.parseInt(sCurPage);

// === === ===

String sTargetGroupOrderBy = ui.getSessionProperty("target_group_order_by");
String sOrderBy = request.getParameter("order_by");
if (sOrderBy == null) sOrderBy = sTargetGroupOrderBy;
if ((sOrderBy == null)||sOrderBy.trim().equals("")) sOrderBy = "date";
ui.setSessionProperty("target_group_order_by", sOrderBy);

// === === ===

String sAmount = request.getParameter("amount");

String sTargetGroupPageSize = ui.getSessionProperty("target_group_page_size");
if (sAmount == null) sAmount = sTargetGroupPageSize;
if ((sAmount == null)||sAmount.trim().equals("")) sAmount = "25";

int amount = 25;
try { amount = Integer.parseInt(sAmount); }
catch(Exception ex) {}

ui.setSessionProperty("target_group_page_size", sAmount);

%>
<HTML>
<HEAD>
	<TITLE></TITLE>
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
				"aoColumns": [{ "bSortable": false },{ "bSortable": false },null,null,null,{ "bSortable": false },{ "bSortable": false },null],
				"aaSorting": [[ 4, "desc" ]]
			});
			oTable2 = $('#example2').dataTable({
				"sDom": "tlrip",
				"aoColumns": [null,null,null,null,null,null,null],
				"aaSorting": [[ 0, "desc" ]]
			});
			
			$('#filter').change( function(){
				filter_string = $('#filter').val();
				oTable.fnFilter( filter_string , 4);
				filter_string = $('#filter').val();
				oTable2.fnFilter( filter_string , 3);
			});
		} );
	</script>
	<script language="javascript">

	function PreviewURL(freshurl)
	{
		var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,location=no,status=yes,height=600,width=400';
		SmallWin = window.open(freshurl,'FilterPreviewWin',window_features);
	}

	</script>
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>	
</HEAD>
<BODY class="paging_body" onLoad="innerFramOnLoad();">
<DIV id=tsnazzy><B class=ttop><B class=tb1></B><B class=tb2></B><B 
class=tb3></B><B class=tb4></B></B>
	<div class="tip tboxcontent">
		<strong>Email marketing tip #5:</strong> To reduce the number of bogus email addresses in your contact list, always use a double opt-in subscription system. <a href="tips">Read more.</a>
	</div>
	<B class=tbottom><B class=tb4></B><B 
class=tb3></B><B class=tb2></B><B class=tb1></B></B></DIV>
<div class="page_header">Segmentation</div>
<div class="page_desc">Create target groups to fit your needs.</div>
<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent">
			<TABLE class=listTable cellSpacing=0 cellPadding=2 width="100%" style="padding-top: 4px;">
				<TBODY>
					<TR>
						<TD noWrap align=left style="padding-left:10px; width:5%;">
							<% if (can.bWrite) { %>
							<a class="newbutton" href="filter_edit.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">		
							&nbsp;
							New Target Group</a>
							<% } %>	
						</TD>
						<TD noWrap align=right style="padding-right:10px;">
							<A class="newbutton" href="filter_list.jsp">&nbsp;Refresh</A>
						</TD>
					</TR>
				</TBODY>
			</TABLE>
			<table class="list_table" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th align="left" nowrap>Target Groups&nbsp;	</TH>
				</tr>
			</table>
			<table class="list_table" id="example" width="100%" cellpadding="2" cellspacing="0">
				<thead>
					<th><input type="checkbox" id="checkboxall"></th>
					<th></th>
				<th valign="middle" nowrap>Name</th>
<%
	boolean bIsPrintEnabled = CustFeature.exists(cust.s_cust_id, Feature.PRINT_ENABLED);
	if(bIsPrintEnabled)
	{
%>
					<th valign="middle" nowrap>Email</th>
					<th  valign="middle" nowrap>Print</th>
<%
	}
	else
	{
%>
					<th valign="middle" nowrap>Records</th>
<%
	}
%>
					<th valign="middle" nowrap>Last update</th>
					<% if (canTGPreview) { %><th valign="middle" nowrap>Preview</th><% } %>
					<th valign="middle" nowrap>Update</th>
					<th valign="middle" nowrap>Update status</th>
				</thead>
				<tbody>
<%
ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;
		
int filterCount = 0;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);

	getStatistics(cust);
	
	try
	{
		sSql =
			" EXEC usp_ctgt_filter_list_get_orderby" +
			" @cust_id=?, @category_id=?, @start_record=?, @page_size=?, @orderby=?";

		pstmt = conn.prepareStatement(sSql);

		pstmt.setString(1, cust.s_cust_id);
		pstmt.setString(2, sSelectedCategoryId);
		pstmt.setString(3, "1");
		pstmt.setString(4, "1");
		pstmt.setString(5, sOrderBy);
		
		rs = pstmt.executeQuery();
		
		String sFilterId = null;
		String sFilterName = null;
		String sFinishDate = null;
		String sRecipQty = null;
		String sPrintRecipQty = null;		
		int iStatusId = -1;
		String sStatusName = null;
		String sAprvlStatusFlag = null;
		
		String sClassAppend = "";

		while(rs.next())
		{
			if (filterCount % 2 != 0) sClassAppend = "_other";
			else sClassAppend = "";

			filterCount++;
			
			//Page logic
			if ((filterCount <= (curPage-1)*amount) || (filterCount > curPage*amount)) continue;
			
			sFilterId = rs.getString(1);
			sFilterName = new String(rs.getBytes(2), "UTF-8");
			sFinishDate = rs.getString(3);
			sRecipQty = rs.getString(4);
			sPrintRecipQty = rs.getString(5);
			iStatusId = rs.getInt(6);			
			sStatusName = rs.getString(7);
			sAprvlStatusFlag = rs.getString(8);
%>
				
				<tr>
					<td class="list_row<%= sClassAppend %>"><input type="checkbox" class="check_me" name="check1"></td>
					<td class="list_row<%= sClassAppend %>"><img src="../../images/icon_report_18_18.png" border="0" alt=""></td>
					<td class='<%=(sOrderBy.equals("name"))?"listItem_Title":"list_row"%><%= sClassAppend %>'>
						<a href="filter_edit.jsp?filter_id=<%=sFilterId%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>" target="_self"><%=sFilterName%></a>
					</td>
					<td class='<%=(sOrderBy.equals("records"))?"listItem_Title":"list_row"%><%= sClassAppend %>'>
						<%=(sRecipQty==null)?"&nbsp;":sRecipQty%>
					</td>
<% if(bIsPrintEnabled) { %>
					<td class='<%=(sOrderBy.equals("records"))?"listItem_Title":"list_row"%><%= sClassAppend %>'>
						<%=(sPrintRecipQty==null)?"&nbsp;":sPrintRecipQty%>
					</td>
<% } %>
					<td class='<%=(sOrderBy.equals("date"))?"list_row":"list_row"%><%= sClassAppend %>' align='left'>
						<%=(sFinishDate==null)?"---":sFinishDate%>
					</td>
<%
			if (canTGPreview)
			{
				if((sRecipQty != null ) && (Integer.parseInt(sRecipQty) > 0))
				{
%>
					<td class="list_row<%= sClassAppend %>" align="left"><a href="javascript:PreviewURL('filter_preview.jsp?filter_id=<%=sFilterId%>');">Preview</a></td>
<%
				}
				else
				{
%>
					<td class="list_row<%= sClassAppend %>" align="left">---</A></td>
<%
				}
			}
%>
					<td class="list_row<%= sClassAppend %>" align="left">
<%
			if((iStatusId != FilterStatus.QUEUED_FOR_PROCESSING) && (iStatusId != FilterStatus.PROCESSING)) 
			{
%>
						<a href="filter_update.jsp?filter_id=<%=sFilterId%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">Update</a>
<%
			}
			else if (iStatusId != FilterStatus.PROCESSING_ERROR)
			{
%>
						Update
<%
			}
			else
			{
%>
						---
<%
			}
%>
					</td>
					<td class="list_row<%= sClassAppend %>" align="left"><%=sStatusName%>
<%
			if ("0".equals(sAprvlStatusFlag))
			{
%>
						(unapproved)
<%
		 	}
			else if ("-1".equals(sAprvlStatusFlag))
			{
%>
						(pending campaign approval)
<%
		 	}
%>
					</td>
				</tr>
<%
		}
		rs.close();
					
		if (filterCount == 0)
		{
%>
				<tr>
					<td class="listItem_Title" colspan="6" align="left" valign="middle">There are currently no Target Groups</td>
				</tr>
				
<%
		}
	}
	catch(Exception sqlex) { throw sqlex; }
	finally { if(pstmt != null) pstmt.close(); }
}
catch(Exception ex) { throw ex; }
finally { if(conn != null) cp.free(conn); }
%>
			</tbody>
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


<SCRIPT language="JavaScript">

function innerFramOnLoad()
{

	FT.curPage.value = <%= curPage %>;
	FT.amount.value = <%= amount %>;

	var prevPage = document.getElementById("prev_page");
	var firstPage = document.getElementById("first_page");
	var nextPage = document.getElementById("next_page");
	var lastPage = document.getElementById("last_page");

	<%
	if( curPage > 1)
	{
	%>
		prevPage.style.display = "";
		firstPage.style.display = "";
	<%
	}

	if( filterCount > (curPage*amount) )
	{
	%>
		nextPage.style.display = "";
		lastPage.style.display = "";
	<%
	}
	%>

	var recCount = new Number("<%= filterCount %>");
	var perPage = new Number(FT.amount.value);
	var thisPage = new Number(FT.curPage.value);
	var catName = FT.category_id[FT.category_id.selectedIndex].text;
	var orderbyName = FT.order_by[FT.order_by.selectedIndex].text;

	var pageCount = new Number(Math.ceil(recCount / perPage));

	if (pageCount == 0) pageCount = 1;
	FT.pageCount.value = pageCount;
	
	var startRec;
	var endRec;

	startRec = ((thisPage - 1) * perPage) + 1;
	endRec = ((thisPage - 1) * perPage) + perPage;

	if (endRec >= recCount) endRec = recCount;
	if (perPage == 1000) perPage = "ALL";

	if (thisPage == 1)
	{
		firstPage.style.display = "none";
		prevPage.style.display = "none";
	}

	if (thisPage >= pageCount)
	{
		lastPage.style.display = "none";
		nextPage.style.display = "none";
	}

	var finalMessage = "";

	if (recCount == 0) finalMessage = "0 records";
	else
	{
		finalMessage =
			"Page " + thisPage + " of " + pageCount +
			" (records " + startRec + " to " + endRec + " of " + recCount + " records)";
	}

	document.getElementById("cat_1").innerHTML = catName;
	document.getElementById("order_1").innerHTML = orderbyName;
	document.getElementById("rec_1").innerHTML = perPage;
	document.getElementById("page_1").innerHTML = finalMessage;
}

function GO(parm)
{
	switch( parm )
	{
		case 0:
			FT.curPage.value = 1;
			break;
		case 1:
			FT.curPage.value = <%= curPage + 1 %>;
			break;
		case 2:
			break;
		case 3:
			FT.curPage.value = <%= curPage %>;
			break;
		case -1:
			FT.curPage.value = <%= curPage - 1 %>;
			break;
		case 99:
			FT.curPage.value = FT.pageCount.value;
			break;
	}
	
	FT.submit();
}

</SCRIPT>

<%!
private void getStatistics(Customer cust) throws Exception
{
	Vector services = Services.getByCust(ServiceType.RRCP_FILTER_STATISTIC_GET, cust.s_cust_id);
	Service service = (Service) services.get(0);

	ConnectionPool cp = null;
	Connection conn = null;

	try
	{

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		PreparedStatement pstmt = null;
		try
		{
			String sSql =
				" SELECT f.filter_id" +
				" FROM ctgt_filter f WITH(NOLOCK)" +
				" WHERE f.origin_filter_id IS NULL" +
				" AND f.type_id = " + FilterType.MULTIPART +
				" AND f.cust_id = " + cust.s_cust_id +
				" AND f.status_id IN (" + 
					FilterStatus.QUEUED_FOR_PROCESSING +", " +
					FilterStatus.PROCESSING +")";

			pstmt = conn.prepareStatement(sSql);
			ResultSet rs = pstmt.executeQuery();
			
			String sFilterId = null;

			String sFilterXml = null;			
			Element eFilter = null;
						
			com.britemoon.cps.tgt.Filter filter = null;
			
			int iStatus = 0;
			
			while (rs.next())
			{
				sFilterId = rs.getString(1);
				filter = new com.britemoon.cps.tgt.Filter(sFilterId);

				try
				{
					sFilterXml = filter.toXml();
					sFilterXml = service.communicate(sFilterXml);
					eFilter = XmlUtil.getRootElement(sFilterXml);
					filter = new com.britemoon.cps.tgt.Filter(eFilter);
					if( filter.m_FilterStatistic != null ) filter.m_FilterStatistic.save();

					iStatus = Integer.parseInt(filter.s_status_id);
					if (iStatus != FilterStatus.PENDING_APPROVAL)
					{
						filter.setStatus(iStatus);
					}
				}
				catch(SQLException sqlex) { throw sqlex; }
				catch(Exception ex)
				{
					logger.error("Exception: ",ex);
					filter.setStatus(FilterStatus.PROCESSING_ERROR);
				}
			}
		}
		catch(SQLException sqlex) { throw sqlex; }
		finally { if(pstmt != null) pstmt.close(); }
	}
	catch(Exception ex) { throw ex; }
	finally	{ if(conn != null) cp.free(conn); }
}
%>
</HTML>