<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="wvalidator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead) {
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

ConnectionPool	cp			= null;
Connection		conn		= null;
Statement		stmt		= null;
ResultSet		rs			= null; 

boolean isDisable = false;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("wizard/wizard_list.jsp 1");
	stmt = conn.createStatement();
	
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) {
		sSelectedCategoryId = ui.s_category_id;
	}
	if (sSelectedCategoryId == null) sSelectedCategoryId = "0";

	String		scurPage	= request.getParameter("curPage");
	String		samount		= request.getParameter("amount");

	int		curPage		= 1;
	int		amount		= 0;

	curPage		= (scurPage	== null) ? 1 : Integer.parseInt(scurPage);
	
	// ********** KU
	
	if (samount == null) samount = ui.getSessionProperty("wizard_list_page_size");
	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("wizard_list_page_size", samount);
		
	// ********** KU

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY onLoad="innerFramOnLoad()">

<table cellpadding="3" cellspacing="0" border="0" width="100%">
	<tr>
		<td nowrap align="left" valign="middle">
		<%
		if (can.bWrite)
		{
			%>
			<a class="newbutton" href="wizard.jsp?<%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">New Wizard</a>&nbsp;&nbsp;&nbsp;
			<%
		}
		%>
		</td>
		<td nowrap valign="middle" align="right" width="100%">
			<table class="filterList" cellspacing="1" cellpadding="0" border="0">
				<tr>
					<td align="right" valign="middle" nowrap><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
					<td align="right" valign="middle" nowrap>&nbsp;Category: <span id="cat_1"></span>&nbsp;</td>
					<td align="right" valign="middle" nowrap>&nbsp;Records / Page: <span id="rec_1"></span>&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<div id="filterBox" style="display:none;">
<FORM METHOD="GET" NAME="FT" ID="FT" ACTION="wizard_list.jsp" style="display:inline;">
	<INPUT TYPE="hidden" NAME="curPage" VALUE="<%= curPage %>">
	<table class="listTable" cellspacing="0" cellpadding="2" border="0">
		<tr>
			<th valign="middle" align="left" colspan="2">Filter the Campaigns</th>
			<th valign="top" align="right" style="cursor:hand;" onclick="filterReveal(30);">&nbsp;<b>X</b>&nbsp;</th>
		</tr>
		<tr<%=(!canCat.bRead)?" style=\"display:none\"":""%>>
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
			<td valign="middle" align="center" colspan="2"><a class="subactionbutton" href="#" onClick="filterReveal(30);GO(0);">Filter</a></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
	</table>
</FORM>
</div>
<br>

<table cellspacing="0" cellpadding="0" width="100%" border="0">
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
			Quick Campaigns
			<br><br>
			<table class="listTable" width="100%" cellspacing="0" cellpadding="2">
				<tr>
					<th align="left" nowrap>Status</th>
					<th width="50%" align="left" nowrap>Campaign</th>
					<th width="50%" align="left" nowrap>Modify Date</th>
					<th width="50%" align="left" nowrap>Reporting</th>
				</tr>
			<%
			String sSql = "usp_cque_wizard_camp_list_get " + cust.s_cust_id + "," + sSelectedCategoryId;
			rs = stmt.executeQuery(sSql);

			String sCampId = null;
			String sCampName = null;
			String sDisplayName = null;
			String sModifyDate = null;
			int campCount = 0;
			String s_status_id;

			String sClassAppend = "";

			while( rs.next() )
			{
				if (campCount % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";
				
				sCampId = rs.getString(1);
				sCampName = new String(rs.getBytes(2), "ISO-8859-1");
				sDisplayName = rs.getString(3);
				sModifyDate = rs.getString(4);
				s_status_id = rs.getString(5);

				//Page logic
				campCount++;
				if ((campCount <= (curPage-1)*amount) || (campCount > curPage*amount)) continue;
				%>
				<tr>
					<td class="listItem_Data<%= sClassAppend %>" nowrap><%=sDisplayName%></td>
					<td class="listItem_Data<%= sClassAppend %>"><a href="wizard.jsp?camp_id=<%=sCampId%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>"><%=sCampName%></a></td>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><%=sModifyDate%></td>
					<td class="listItem_Title<%= sClassAppend %>" nowrap>
					<% 	if ((Integer.parseInt(s_status_id) == 60)) { %>
					<a href="../report/report_object.jsp?act=VIEW&id=<%=sCampId%>">view report</a>
					<% 	} else {  %>
					Not sent yet
					<% } %>
					</td>
				</tr>
				<%
			}
			rs.close();
			%>
			</table>
		</td>
	</tr>
</table>
<br>
</BODY>

<SCRIPT>
<%@ include file="../../js/scripts.js" %>

function innerFramOnLoad()
{

	var prevPage = document.getElementById("prev_page");
	var firstPage = document.getElementById("first_page");
	var nextPage = document.getElementById("next_page");
	var lastPage = document.getElementById("last_page");


	FT.curPage.value = <%= curPage %>;
	FT.amount.value = <%= amount %>;

	// === === ===

	<% if( curPage > 1) { %>
	prevPage.style.display = "";
	firstPage.style.display = "";
	<% } %>

	<% if( campCount > (curPage*amount) ) { %>
	nextPage.style.display = "";
	lastPage.style.display = "";
	<% } %>

	//camp_count.innerHTML = <%= campCount %>;

	var recCount = new Number("<%= campCount %>");
	var perPage = new Number(FT.amount.value);
	var thisPage = new Number(FT.curPage.value);
	var catName = FT.category_id[FT.category_id.selectedIndex].text;

	var pageCount = new Number(Math.ceil(recCount / perPage));

	if (pageCount == 0) pageCount = 1;

	var startRec = ((thisPage - 1) * perPage) + 1;
	var endRec = ((thisPage - 1) * perPage) + perPage;

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
				FT.curPage.value = pageCount;
				break;
	}
	FT.submit();
}

</SCRIPT>
<%
	if (stmt != null) stmt.close();
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex,"wizard_list.jsp",out,1);	
}
finally
{
	if (conn != null) cp.free(conn);
}
%>
