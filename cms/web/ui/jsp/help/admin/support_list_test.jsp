<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>
<%
String		scurPage	= request.getParameter("curPage");
String		samount		= request.getParameter("amount");

int			curPage			= 1;
int			amount			= 0;

curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

if ((samount == null)||("".equals(samount))) samount = "25";
try { amount = Integer.parseInt(samount); }
catch (Exception ex) { samount = "25"; amount = 25; }
				
int iCount = 0;
%>
<html>
<head>
<title>Support List</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" type="text/css" href="../../css/style.css">
	<script language="javascript">
		
		function filterReveal(width)
		{
			var filterSection = document.all.item("filterBox");
			
			var clickX = window.event.clientX - width;
			var clickY = window.event.clientY + 20;
			
			filterSection.style.left = clickX;
			filterSection.style.top = clickY;
			
			if (filterSection.style.display == "none")
			{
				filterSection.style.display = "";
			}
			else
			{
				filterSection.style.display = "none";
			}
		}
		
		function toggleDetails(ticket_id)
		{
			var oLink = document.getElementById("link_" + ticket_id);
			var oRow = document.getElementById("row_" + ticket_id);
			var oTable = document.getElementById("histTable");
			
			if (oRow.style.display == "")
			{
				oRow.style.display = "none";
				oLink.innerText = "+";
			}
			else
			{
				oRow.style.display = "";
				oLink.innerText = "-";
			
				if (oRow.rowIndex >= 3)
				{
					if (oTable.rows(oRow.rowIndex - 2).style.display == "")
					{
						oTable.rows(oRow.rowIndex - 2).scrollIntoView();
					}
					else
					{
						oTable.rows(oRow.rowIndex - 3).scrollIntoView();
					}
				}
			}
		}
		
		function popTicketDetails(ticket_id)
		{
			var url = "support_ticket_edit.jsp?ticket_id=" + ticket_id;
			
			parent.frames("main_01").location.href = url;
			//var windowName = 'ticket_detail_window';
			//var windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, location=no, height=600, width=700';
			//var MsgWin = window.open(url, windowName, windowFeatures);
		}
		
	</script>
</head>
<body>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
	<tr height="30">
		<td nowrap valign="middle" align="right" width="100%">
			<table class="filterList" cellspacing="1" cellpadding="0" border="0">
				<tr>
					<td align="right" valign="middle" nowrap><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
						<td align="right" valign="middle" nowrap>&nbsp;Records / Page: <span id="rec_1"></span>&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="40">
		<td>
			<table class="main" cellspacing="1" cellpadding="2" border="0" align="right">
				<tr>
					<td align="right" valign="middle" nowrap>&nbsp;<span id="page_1"></span></td>
					<td align="center" valign="middle">
						<table class="main" cellspacing="0" cellpadding="2" border="0">
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
		</td>
	</tr>
	<tr>
		<td>
			<table cellspacing="0" cellpadding="0" border="0" class="listTable layout" style="width:100%; height:100%;">
				<tr height="21">
					<td valign="bottom" align="center" style="padding:0px;">
						<table class="layout" cellspacing="0" cellpadding="2" style="width:100%; height:100%;">
							<col width="25">
							<col>
							<col width="130">
							<col width="146">
							<tr height="21">
								<th>&nbsp;</th>
								<th><nobr>Ticket #</nobr></th>
								<th><nobr>Subject</nobr></th>
								<th><nobr>Ticket Date</nobr></th>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td valign="top" align="center" style="padding:0px;">
						<div style="width:100%; height:100%; overflow-y:scroll;">
						<table class="layout" cellspacing="0" cellpadding="2" style="width:100%;" id="histTable">
							<col width="25">
							<col>
							<col width="130">
							<col width="130">
					<%
					ConnectionPool cp = null;
					Connection conn = null;
					Statement	stmt = null;
					ResultSet	rs = null; 
					String sSQL = null;

					try
					{
						cp = ConnectionPool.getInstance();
						conn = cp.getConnection("support_list.jsp");
						stmt = conn.createStatement();

						sSQL =
							" select s.ticket_id, isNull(s.cust_id, '0'), isNull(c.cust_name, 'Invalid Customer'), " + 
							" s.user_id, isNull(u.user_name + ' ' + u.last_name, 'Invalid User') as 'user_name', " + 
							" isNull(s.subject, 'None Selected'), s.create_date, CONVERT(varchar(100), isNull(s.create_date, GETDATE()), 100) as 'create_date_txt' " + 
							" from shlp_support_ticket s with(nolock) " + 
							" left outer join sadm_customer c with(nolock) on s.cust_id = c.cust_id " + 
							" left outer join scps_user u with(nolock) on s.user_id = u.user_id " + 
							" where s.origin_ticket_id = 0 " + 
							" order by s.ticket_id + '-' + s.cust_id";

					 	rs = stmt.executeQuery(sSQL);
						
						String sTicketId = null;
						String sCustId = null;
						String sCustName = null;
						String sUserId = null;
						String sUserName = null;
						String sCreateDate = null;
						String sSubject = null;
						String sClassAppend = "";

						while(rs.next())
						{
							if (iCount % 2 != 0) sClassAppend = "_Alt";
							else sClassAppend = "";
							
							++iCount;
							
							sTicketId = rs.getString(1);
							sCustId = rs.getString(2);
							sCustName = new String(rs.getBytes(3),"UTF-8");
							sUserId = rs.getString(4);
							sUserName = new String(rs.getBytes(5),"UTF-8");
							sSubject = new String(rs.getBytes(6),"UTF-8");
							sCreateDate = new String(rs.getBytes(8),"UTF-8");
							
							//Page logic
							if ((iCount <= (curPage-1)*amount) || (iCount > curPage*amount)) continue;
							%>
							<tr>
								<td class="listItem_Data<%= sClassAppend %>" align="center" valign="middle"><nobr><a href="javascript:toggleDetails('<%= sTicketId %>');" id="link_<%= sTicketId %>" class="resourcebutton" style="width:15px; text-align:center;">+</a></nobr></td>
								<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><nobr><a href="javascript:popTicketDetails('<%= sTicketId %>');"><b><%= sCustId %>-<%= sTicketId %></b></a></nobr></td>
								<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><nobr><%= sSubject %></nobr></td>
								<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><nobr><%= sCreateDate %></nobr></td>
							</tr>
							<tr id="row_<%= sTicketId %>" style="display:none;">
								<td class="listItem_Data<%= sClassAppend %>">&nbsp;</td>
								<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" colspan="3" style="padding:0px;">
									<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%;">
										<col width="100">
										<col>
										<tr>
											<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle"><b>Customer</b></td>
											<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle"><%= sCustName %></td>
										</tr>
										<tr>
											<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle"><b>User</b></td>
											<td class="listItem_Data<%= ("_Alt".equals(sClassAppend))?"":"_Alt" %>" valign="middle"><%= sUserName %></td>
										</tr>
									</table>
									<br>
								</td>
							</tr>
							<%
						}
						rs.close();
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
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<div id="filterBox" style="display:none;">
<FORM METHOD="GET" NAME="FT" ACTION="support_list.jsp" style="display:inline;">
	<INPUT TYPE="hidden" NAME="curPage" VALUE="<%= curPage %>">
	<table class="listTable" cellspacing="0" cellpadding="2" border="0">
		<tr>
			<th valign="middle" align="left" colspan="2">Filter the List</th>
			<th valign="top" align="right" style="cursor:hand;" onclick="filterReveal(30);">&nbsp;<b>X</b>&nbsp;</th>
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
			<td valign="middle" align="center" colspan="2"><a class="subactionbutton" href="#" onClick="filterReveal(30);GO(0);" TARGET="_self">Filter</a></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
	</table>
</FORM>
</div>
<SCRIPT>

FT.curPage.value = <%= curPage %>;
FT.amount.value = <%= amount %>;

// === === ===

<% if( curPage > 1) { %>
prev_page.style.display = "";
first_page.style.display = "";
<% } %>

<% if( iCount > (curPage*amount) ) { %>
next_page.style.display = "";
last_page.style.display = "";
<% } %>

var recCount = new Number("<%= iCount %>");
var perPage = new Number(FT.amount.value);
var thisPage = new Number(FT.curPage.value);

var pageCount = new Number(Math.ceil(recCount / perPage));

if (pageCount == 0) pageCount = 1;

var startRec = ((thisPage - 1) * perPage) + 1;
var endRec = ((thisPage - 1) * perPage) + perPage;

if (endRec >= recCount) endRec = recCount;
if (perPage == 1000) perPage = "ALL";

if (thisPage == 1)
{
	first_page.style.display = "none";
	prev_page.style.display = "none";
}

if (thisPage >= pageCount)
{
	last_page.style.display = "none";
	next_page.style.display = "none";
}

var finalMessage = "";

if (recCount == 0) finalMessage = "0 records";
else
{
	finalMessage =
		"Page " + thisPage + " of " + pageCount +
		" (records " + startRec + " to " + endRec + " of " + recCount + " records)";
}

rec_1.innerHTML = perPage;
page_1.innerHTML = finalMessage;

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
				FT.curPage.value = pageCount;
				break;
	}
	FT.submit();
}

</SCRIPT>
</body>
</html>
