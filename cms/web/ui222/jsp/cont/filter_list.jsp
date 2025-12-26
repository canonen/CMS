<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.imc.*,
		com.britemoon.cps.ctl.*,
		java.io.*,java.sql.*,
		java.util.*, java.util.*,
		java.sql.*, org.w3c.dom.*,
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

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;


// ********** KU
String		scurPage	= request.getParameter("curPage");
String		samount		= request.getParameter("amount");

int			curPage			= 1;
int			amount			= 0;

curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);



// ********** KU
String sLogicElemOrderBy = ui.getSessionProperty("logic_element_order_by");
String sOrderBy = request.getParameter("order_by");
if (sOrderBy == null)
{
	if ((null != sLogicElemOrderBy) && ("" != sLogicElemOrderBy)) sOrderBy = sLogicElemOrderBy;
	else sOrderBy = "date";
}
ui.setSessionProperty("logic_element_order_by", sOrderBy);

String sLogicElemPageSize = ui.getSessionProperty("logic_element_page_size");
if (samount == null)
{
	if ((null != sLogicElemPageSize) && ("" != sLogicElemPageSize)) samount = sLogicElemPageSize;
	else samount = "25";
}
amount = (samount==null)? 25 : Integer.parseInt(samount);
ui.setSessionProperty("logic_element_page_size", samount);

ui.setSessionProperty("dynamic_elements_section", "3");

%>
<HTML>
<HEAD>
<title>Logic Elements</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT src="../../js/scripts.js"></SCRIPT>
<script language="javascript">

function PreviewURL(freshurl)
{
	var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,location=no,status=yes,height=600,width=400';
	SmallWin = window.open(freshurl,'FilterPreviewWin',window_features);
}

</script>
</HEAD>
<BODY onLoad="innerFramOnLoad();">
<table cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="SpecialTabOff" width="33%" onclick="location.href = 'logic_block_list.jsp';" valign="center" nowrap align="middle">Logic Blocks</td>
		<td class="SpecialTabOff" width="33%" onclick="location.href = 'cont_block_list.jsp';" valign="center" nowrap align="middle">Content Elements</td>
		<td class="SpecialTabOn" width="34%" onclick="location.href = 'filter_list.jsp';" valign="center" nowrap align="middle">Logic Elements</td>
	</tr>
</table>
<br>
<table cellpadding="3" cellspacing="0" border="0" width="95%">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="../filter/filter_edit.jsp?usage_type_id=<%=FilterUsageType.CONTENT%>">New Logic Element</a>&nbsp;&nbsp;&nbsp;
		</td>
		<td nowrap valign="middle" align="right" width="100%">
			<table class="filterList" cellspacing="1" cellpadding="0" border="0">
				<tr>
					<td align="right" valign="middle" nowrap><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
					<td align="right" valign="middle" nowrap>&nbsp;Category: <span id="cat_1"></span>&nbsp;</td>
					<td align="right" valign="middle" nowrap>&nbsp;Sorted By: <span id="order_1"></span>&nbsp;</td>
					<td align="right" valign="middle" nowrap>&nbsp;Records / Page: <span id="rec_1"></span>&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<div id="filterBox" style="display:none;">
	<FORM  METHOD="GET" NAME="FT" ID="FT" ACTION="filter_list.jsp" style="display:inline;">
	<INPUT TYPE="hidden" NAME="pageCount" VALUE="">
	<INPUT TYPE="hidden" NAME="curPage" VALUE="<%= curPage %>">	
	<table class="listTable" cellspacing="0" cellpadding="2" border="0">
		<tr>
			<th valign="middle" align="left" colspan="2">Filter the Logic Elements</th>
			<th valign="top" align="right" style="cursor:hand;" onclick="filterReveal(30);">&nbsp;<b>X</b>&nbsp;</th>
		</tr>
		<tr<%= !canCat.bRead?" style=\"display:none\"":"" %>>
			<td valign="middle" align="right">Category:&nbsp;</td>
			<td valign="middle" align="left"><%= CategortiesControl.toHtml(cust.s_cust_id, canCat.bExecute, sSelectedCategoryId, "") %></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td valign="middle" align="right">&nbsp;Paging:&nbsp;</td>
			<td valign="middle" align="left">
				<SELECT NAME="amount" SIZE="1">
					<OPTION VALUE=1000>ALL</OPTION>
					<OPTION VALUE=10>10</OPTION>
					<OPTION VALUE=25>25</OPTION>
					<OPTION VALUE=50>50</OPTION>
					<OPTION VALUE=100>100</OPTION>
				</SELECT>
			</td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td valign="middle" align="right">&nbsp;Sort By:&nbsp;</td>
			<td valign="middle" align="left">
				<select name="order_by" id="order_by">
					<option value="name"<%=(sOrderBy.equals("name"))?" selected":""%>>Name</option>
					<option value="date"<%=(sOrderBy.equals("date"))?" selected":""%>>Date</option>
				</select>
			</td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td valign="middle" align="center" colspan="2"><a class="subactionbutton" href="#" onClick="filterReveal(30);GO(0);">Filter</a></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
	</table>
	</FORM>
</div>
<br>
<table cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<table class="main" cellspacing="1" cellpadding="2" border="0" align="right">
				<tr>
					<td align="right" valign="middle" nowrap>&nbsp;<span id="page_1"></span></td>
					<td align="center" valign="middle">
						<table class="main" cellspacing="0" cellpadding="5" border="0">
							<tr>
								<td align="right" valign="middle" nowrap id="first_page" style="display:none"><a href="javascript:GO(0)"><< First</a></td>
								<td align="right" valign="middle" nowrap id="prev_page" style="display:none"><a href="javascript:GO(-1)">< Previous</a></td>
								<td align="right" valign="middle" nowrap id="next_page" style="display:none"><a href="javascript:GO(1)">Next ></a></td>
								<td align="right" valign="middle" nowrap id="last_page" style="display:none"><a href="javascript:GO(99)">Last >></a></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			Logic Elements&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th valign="middle" nowrap>Name</th>
					<th valign="middle" nowrap>Last Modified</th>
				</tr>
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
					sSql = "EXEC usp_ctgt_filter_list_get_logic @cust_id=?, @category_id=?, @start_record=?, @page_size=?, @orderby=?";

					pstmt = conn.prepareStatement(sSql);

					pstmt.setString(1, cust.s_cust_id);
					pstmt.setString(2, sSelectedCategoryId);
					pstmt.setString(3, "1");
					pstmt.setString(4, "1");
					pstmt.setString(5, sOrderBy);
					
					rs = pstmt.executeQuery();
					
					String sFilterId = null;
					String sFilterName = null;
					String sModifyDate = null;
					
					String sClassAppend = "";

					while(rs.next())
					{
						if (filterCount % 2 != 0)
						{
							sClassAppend = "_Alt";
						}
						else
						{
							sClassAppend = "";
						}
						
						filterCount++;
						
						//Page logic
						if ((filterCount <= (curPage-1)*amount) || (filterCount > curPage*amount)) continue;
						
						sFilterId = rs.getString(1);
						sFilterName = new String(rs.getBytes(2), "UTF-8");
						sModifyDate = rs.getString(3);
						%>
				<tr>
					<td class="listItem_Data<%= sClassAppend %>"><a href="../filter/filter_edit.jsp?usage_type_id=<%=FilterUsageType.CONTENT%>&filter_id=<%=sFilterId%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>"><%=sFilterName%></a></td>
					<td class="listItem_Title<%= sClassAppend %>" align="left"><%=(sModifyDate==null)?"---":sModifyDate%></td>
				</tr>
						<%
					}
					rs.close();
					
					if (filterCount == 0)
					{
						%>
				<tr>
					<td class="listItem_Title" colspan="6" align="left" valign="middle">There are currently no Logic Elements</td>
				</tr>
						<%
					}
				}
				catch(SQLException sqlex)
				{
					throw sqlex;
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
			</table>
		</td>
	</tr>
</table>
<br><br>
<SCRIPT>

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

	if (pageCount == 0)
	{
		pageCount = 1;
	}
	FT.pageCount.value = pageCount;
	
	var startRec;
	var endRec;

	startRec = ((thisPage - 1) * perPage) + 1;
	endRec = ((thisPage - 1) * perPage) + perPage;

	if (endRec >= recCount)
	{
		endRec = recCount;
	}

	if (perPage == 1000)
	{
		perPage = "ALL";
	}

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

	if (recCount == 0)
	{
		finalMessage = "0 records";
	}
	else
	{
		finalMessage = "Page " + thisPage + " of " + pageCount + " (records " + startRec + " to " + endRec + " of " + recCount + " records)";
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
</BODY>
</HTML>

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
					filter.setStatus(iStatus);
				}
				catch(SQLException sqlex) { throw sqlex; }
				catch(Exception ex)
				{
					logger.error("Exception",ex);
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
