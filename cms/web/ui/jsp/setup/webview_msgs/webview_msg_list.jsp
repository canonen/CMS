<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.net.*,java.sql.*,
			java.util.*,java.io.*,
			org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
	
	if(!can.bRead)
	{
		response.sendRedirect("../../access_denied.jsp");
		return;
	}
			
	String scurPage = request.getParameter("curPage");

	int	curPage	= 1;
	int contCount = 0;

	curPage	= (scurPage	== null) ? 1 : Integer.parseInt(scurPage);

	String samount = request.getParameter("amount");
	int amount = 0;
	
	if (samount == null) samount = ui.getSessionProperty("webview_msgs_list_page_size");
	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("webview_msgs_list_page_size", samount);
	
	String htmlContentRow = "";
	String htmlContent = "";
	
	ConnectionPool cp	= null;
	Connection 	conn	= null;
	Statement 	stmt	= null;			
	ResultSet 	rs		= null;
	
	try
	{

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("webview_msg_list");
		stmt = conn.createStatement();		
		
		String sSql =
			"SELECT u.msg_id, u.msg_name " +
			" FROM ccps_webview_msg u" +
			" WHERE cust_id=" + cust.s_cust_id +
			" ORDER BY msg_name";
			
		rs = stmt.executeQuery(sSql);
		
		String sMsgId = null;
		String sMsgName = null;
		int iCount = 0;
		String sClassAppend = "";
		byte[] b = null;
		while(rs.next())
		{
			if (iCount % 2 != 0) sClassAppend = "_Alt";
			else sClassAppend = "";
		
			++iCount;
		
			sMsgId = rs.getString(1);
			b = rs.getBytes(2);
			sMsgName = (b==null)?null:new String(b, "UTF-8");
						
			htmlContentRow += "<tr><td class=\"listItem_Title" + sClassAppend + "\"><a href=\"webview_msg_edit.jsp?msg_id=" + sMsgId + "\">" + sMsgName + "</a>&nbsp;</td></tr>";
			htmlContent += htmlContentRow;
			htmlContentRow = "";
		}
		rs.close();
		if (iCount == 0)
		{
			htmlContent += "<tr><td colspan=\"5\" class=\"listItem_Data\">There are currently no Webview Messages</td></tr>\n";
		}		
		contCount = iCount;
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try
		{
			if (stmt!=null) stmt.close();
		}
		catch (SQLException ignore) {}		
		if (conn!=null) cp.free(conn);
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

<head>
<title>Webview Message List</title>
<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
	function goToEdit(cont_id, type_id)
	{
		var sURL = "";		
		sURL = "webview_msg_edit.jsp?msg_id=" + msg_id;
		location.href = sURL;
	}

</script>
</head>

<body onLoad="innerFramOnLoad();">
<table cellpadding="3" cellspacing="0" border="0" width="95%">
	<tr>
		<% if (can.bWrite) { %>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="webview_msg_edit.jsp"><fmt:message key="web_view"/></a>&nbsp;&nbsp;&nbsp;
		</td>
		<% } %>
		<td nowrap valign="middle" align="right" width="100%">
			<table class="filterList" cellspacing="1" cellpadding="0" border="0">
				<tr>
					<td align="right" valign="middle" nowrap><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
					<td align="right" valign="middle" nowrap>&nbsp;Records / Page: <span id="rec_1"></span>&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<div id="filterBox" style="display:none;">
	<FORM  METHOD="GET" NAME="FT" ID="FT" ACTION="webview_msg_list.jsp" style="display:inline;">
	<INPUT TYPE="hidden" NAME="pageCount" VALUE="">
	<INPUT TYPE="hidden" NAME="curPage" VALUE="<%= curPage %>">
	<table class="listTable" cellspacing="0" cellpadding="2" border="0">
		<tr>
			<th valign="middle" align="left" colspan="2">Filter the Webview Messages</th>
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
			Webview Messages&nbsp;
			<br><br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tbody>
				<tr>
					<th align="left" valign="middle" width="40%" nowrap>&#x20;Name</th>
					<!--th align="left" valign="middle" width="20%" nowrap>&#x20;Type</th>
					<th align="left" valign="middle" width="20%" nowrap>&#x20;Last update</th>
					<th align="left" valign="middle" width="20%" nowrap>&#x20;Status</th-->
				</tr>
				<!-- List of the webview messages -->
				<%= htmlContent %>
				</tbody>
			</table>
		</td>
	</tr>
</table>
<br><br>


<script language="javascript">
<%@ include file="../../../js/scripts.js" %>
function innerFramOnLoad()
{
	var prevPage = document.getElementById("prev_page");
	var firstPage = document.getElementById("first_page");
	var nextPage = document.getElementById("next_page");
	var lastPage = document.getElementById("last_page");

	FT.curPage.value = <%= curPage %>;
	FT.amount.value = <%= amount %>;

	<% if( curPage > 1) { %>
	prevPage.style.display = "";
	firstPage.style.display = "";
	<% } %>

	<% if( contCount > (curPage*amount) ) { %>
	nextPage.style.display = "";
	lastPage.style.display = "";
	<% } %>

	var recCount = new Number("<%= contCount %>");
	var perPage = new Number(FT.amount.value);
	var thisPage = new Number(FT.curPage.value);

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

	document.getElementById("rec_1").innerHTML = perPage;
	document.getElementById("page_1").innerHTML = finalMessage;
}

function GO(parm)
{

	switch( parm )
	{
		case 0:
			FT.curPage.value=1;
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

</script>
</body>
</fmt:bundle>
</html>