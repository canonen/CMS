<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="org.apache.log4j.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.net.*"
	import="java.text.DateFormat"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application" />
<%
//Make sure these are gone
session.removeAttribute("pbean");
session.removeAttribute("tbean");

String		scurPage	= request.getParameter("curPage");
String		samount		= request.getParameter("amount");
String		sOrderBy	= request.getParameter("sort_by");
int			curPage			= 1;
int			amount			= 0;

curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

if ((samount == null)||("".equals(samount))) samount = "25";
try { amount = Integer.parseInt(samount); }
catch (Exception ex) 
{ 
	samount = "25"; 
	amount = 25;
}

if ((sOrderBy == null)||("".equals(sOrderBy))) sOrderBy = "mod_date desc";

//Grab this customer's pages from the db
ConnectionPool connPool = null;
Connection conn         = null;
Statement stmt          = null;
ResultSet rs            = null;

connPool = ConnectionPool.getInstance();
conn = connPool.getConnection("index.jsp");
stmt = conn.createStatement();

rs = stmt.executeQuery("" +
	"select distinct content_id, category, p.template_id, p.name, mod_date, t.name as template_name, " +
	"status, mod_by, creation_date, user_name " +
	"from ctm_pages p with(nolock), ctm_templates t with(nolock) " +
	"where p.template_id = t.template_id " +
	"and p.customer_id = " + cust.s_cust_id + " " +
	"and status <> 'deleted' " +
	"order by " + sOrderBy);
	
String isAdmin = (String)session.getAttribute("isAdmin");
if (isAdmin == null || isAdmin.length() == 0) {
    isAdmin = "0";
}

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) {
    isHyatt = "0";
}

String isWizard = (String)session.getAttribute("isWizard");
if (isWizard == null || isWizard.length() == 0) {
    isWizard = "0";
}

String isParent = "0";
if (isAdmin.equals("1") && isHyatt.equals("1")) {
    isParent = "1";
}

%>
<html>
<head>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<body onLoad="innerFramOnLoad();">
<table cellpadding="3" cellspacing="0" border="0" width="100%">
	<tr>
		<td nowrap align="left" valign="middle"><a class="newbutton" href="selecttemplate.jsp">New Template</a>&nbsp;&nbsp;&nbsp;</td>
		<% if ("0".equals(isWizard)) { %>
		<%     if ("1".equals(isAdmin)) { %>
		<td nowrap align="left" valign="middle"><a class="subactionbutton" href="/cms/ui/jsp/ctmadmin/index.jsp<%=(isParent.equals("1")?"?parent=true":"")%>">Master Template Admin</a>&nbsp;&nbsp;&nbsp;</td>
		<%     } %>
		<% } %>
		<td nowrap valign="middle" align="right" width="100%">
			<table class="filterList" cellspacing="1" cellpadding="0" border="0">
				<tr>
					<td align="right" valign="middle" nowrap><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
					<td align="right" valign="middle" nowrap>&nbsp;Sorted By: <span id="sort_1"></span>&nbsp;</td>
					<td align="right" valign="middle" nowrap>&nbsp;Records / Page: <span id="rec_1"></span>&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<div id="filterBox" style="display:none;">
<form method="GET" name="FT" id="FT" action="index.jsp" style="display:inline;">
	<INPUT TYPE="hidden" NAME="pageCount" VALUE="">
	<input type="hidden" name="curPage" value="<%= curPage %>">
	<table class="listTable" cellspacing="0" cellpadding="2" border="0">
		<tr>
			<th valign="middle" align="left" colspan="2">Filter the List</th>
			<th valign="top" align="right" style="cursor:hand;" onclick="filterReveal(30);">&nbsp;<b>X</b>&nbsp;</th>
		</tr>
		<tr>
			<td valign="middle" align="right">&nbsp;Paging:&nbsp;</td>
			<td valign="middle" align="left">
				<select NAME="amount" SIZE="1">
					<option value="1000">ALL</option>
					<option value="10">10</option>
					<option value="25">25</option>
					<option value="50">50</option>
					<option value="100">100</option>
				</select>
			</td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td valign="middle" align="right">&nbsp;Sort By:&nbsp;</td>
			<td valign="middle" align="left">
				<select NAME="sort_by" SIZE="1">
					<option value="p.name asc"<%= ("p.name asc".equals(sOrderBy))?" selected":"" %>>Name</option>
					<option value="t.name asc"<%= ("t.name asc".equals(sOrderBy))?" selected":"" %>>Template</option>
					<option value="status"<%= ("status".equals(sOrderBy))?" selected":"" %>>Status</option>
					<option value="mod_date desc"<%= ("mod_date desc".equals(sOrderBy))?" selected":"" %>>Modified</option>
				</select>
			</td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td valign="middle" align="center" colspan="2"><a class="subactionbutton" href="#" onClick="filterReveal(30);GO(0);">Filter</a></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
	</table>
</form>
</div>
<br>
<table cellspacing="0" cellpadding="0" width="100%" border="0">
	<tr>
		<td class="listHeading" width="100%" valign="center" nowrap align="left">
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
			Templates
			<br><br>			
			<table class="listTable" width="100%" cellspacing="0" cellpadding="2">
				<tr>
					<th align="left" nowrap>Name</th>
					<th align="left" nowrap>Template</th>
					<th align="left" nowrap>Status</th>
					<th align="left" nowrap>Last Modified</th>
					<% if ("0".equals(isWizard)) { %>
					<th align="left" nowrap colspan="4">Actions</th>
					<% } %>
				</tr>
		<%
		int templateID, contentID;
		String pageName, templateName, status;
		Timestamp modDate;

		int iCount = 0;
		String sClassAppend = null;

		while (rs.next())
		{
			contentID = rs.getInt(1);
			if (iCount % 2 != 0) {
				sClassAppend = "_Alt";
			} else {
				sClassAppend = "";
			}
			
			++iCount;
			
			templateID = rs.getInt(3);
			pageName = rs.getString(4);
			modDate = rs.getTimestamp(5);

			templateName = rs.getString(6);
			status = rs.getString(7);
			
			//Page logic
			if ((iCount <= (curPage-1)*amount) || (iCount > curPage*amount)) continue;
			%>
			<tr>
				<td class="listItem_Data<%=sClassAppend%>"><a href="pageedit.jsp?isEdit=true&contentID=<%= contentID %>&templateID=<%= templateID %>"><%= pageName %></a></td>
				<td class="listItem_Data<%=sClassAppend%>" align=left><%= templateName %></td>
				<td class="listItem_Data<%=sClassAppend%>" align=left><%= status %></td>
				<td class="listItem_Data<%=sClassAppend%>" align=left><%= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(modDate) %></td>
				<% if ("0".equals(isWizard)) { %>
				<td class="listItem_Data<%=sClassAppend%>" align=center><a class="resourcebutton" href="pageedit.jsp?isEdit=false&contentID=<%= contentID %>&templateID=<%= templateID %>">Preview</a></td>
				<td class="listItem_Data<%=sClassAppend%>" align=center>
				<%=(!status.equals("locked"))?("<a class=\"deletebutton\" href=\"\" onClick=\"if( confirm('Are you sure?') ) href='pagedelete.jsp?contentID="+contentID+"'\">Delete</a>"):("&nbsp;")%>
				</td>
				<% if ("0".equals(isHyatt)) { %>
				<td class="listItem_Data<%=sClassAppend%>" align=center>
				<%	if (!status.equals("locked")) {
					if (status.equals("draft")) { %>
					<a class="subactionbutton" href="commit.jsp?contentID=<%= contentID %>&templateID=<%= templateID %>">Commit</a>
				<% 	} else { %>
					<a class="subactionbutton" href="uncommit.jsp?contentID=<%= contentID %>&templateID=<%= templateID %>">UnCommit</a>
				<% 	}
					} else { %>
				&nbsp;
				<%	} %>
				</td>
				<% } %>
				<td class="listItem_Data<%=sClassAppend%>" align=center><a class="subactionbutton" href="pageedit.jsp?clone=true&contentID=<%= contentID %>&templateID=<%= templateID %>">Clone</a></td>
				<% } %>
			</tr>
			<%
		}
		//Free the db connection
		rs.close();
		stmt.close();
		if (conn != null) connPool.free(conn);
		
		if (iCount == 0)
		{
			%>
			<tr>
				<td class="listItem_Data" colspan="8" align="left" valign="middle">There are currently no templates.</td>
			</tr>
			<%
		}
		%>
			</table>
		</td>
	</tr>
</table>
<br><br>
<SCRIPT>

<%@ include file="../../js/scripts.js" %>

function innerFramOnLoad()
{

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
	var sBy = FT.sort_by[FT.sort_by.selectedIndex].text;

	var pageCount = new Number(Math.ceil(recCount / perPage));

	if (pageCount == 0) pageCount = 1;
	FT.pageCount.value = pageCount;

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

	sort_1.innerHTML = sBy;
	rec_1.innerHTML = perPage;
	page_1.innerHTML = finalMessage;
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
</body>
</html>

