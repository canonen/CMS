<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.imc.*,
		java.sql.*, java.util.Vector,
		org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

	ConnectionPool connectionPool = null;
	Connection srvConnection = null;
	Statement sqlStatement =null;			
	ResultSet rs=null;

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	String scurPage = request.getParameter("curPage");
	String samount = request.getParameter("amount");

	int	curPage	= 1;
	int amount = 0;
	int contCount = 0;

	curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);
	//amount		= (samount		== null) ? 25: Integer.parseInt(samount); //moved down to new section
	
	// ********** KU
	String sLogicBlockListPageSize = ui.getSessionProperty("logic_block_list_page_size");
	if (samount == null)
	{
		if ((null != sLogicBlockListPageSize) && ("" != sLogicBlockListPageSize))
		{
			samount = sLogicBlockListPageSize;
		}
		else
		{
			samount = "25";
		}
	}

	amount = (samount==null)? 25 : Integer.parseInt(samount);

	ui.setSessionProperty("logic_block_list_page_size", samount);
	
	ui.setSessionProperty("dynamic_elements_section", "1");
	// ********** KU
	
	String strStatusId = null;
	String htmlContentList = "";
	String htmlContent = "";

	try
	{
		String strSQL = "EXEC usp_ccnt_list_get @type_id = 25, @CustomerId="+cust.s_cust_id;

//		c.cont_id as ContentId,
//		c.cont_name as ContentName,
//		cei.wizard_id as WizardId,
//		c.type_id, 
//		ct.display_name,
//		Convert(Varchar, cei.modify_date,100) as 'ModifyDate',
//		c.status_id as StatusId,
//		s.status_name as Status,
//		u.user_name + ' ' + u.last_name as 'Editor',
//		cei.modify_date

// --- Work with parameters ---

		if (sSelectedCategoryId != null) strSQL += ",@category_id="+sSelectedCategoryId;

		connectionPool = ConnectionPool.getInstance();
		srvConnection = connectionPool.getConnection(this);
		sqlStatement = srvConnection.createStatement();

		String logicID=null, wizardString;

		rs = sqlStatement.executeQuery(strSQL);	
		
		String sClassAppend = "";
			
		while (rs.next())
		{
			if (contCount % 2 != 0) sClassAppend = "_Alt";
			else sClassAppend = "";
			
			++contCount;

			//Page logic
			if (contCount <= (curPage-1)*amount) continue;
			else if (contCount > curPage*amount) continue;

			htmlContentList = "<tr>\n";
			logicID = rs.getString(1);

			htmlContentList += "<td class=\"listItem_Data" + sClassAppend + "\"><a href=logic_block_edit.jsp?logic_id="+logicID+((sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:"")+">"+new String(rs.getBytes(2),"ISO-8859-1")+"</a></td>\n";

			htmlContentList += "<td class=\"listItem_Title" + sClassAppend + "\">"+rs.getString(6)+"</td>\n";
			htmlContentList += "<td class=\"listItem_Data" + sClassAppend + "\">"+rs.getString(9)+"</td>\n";

			htmlContentList += "</tr>\n";
			
			htmlContent += htmlContentList;
		}
		if (htmlContent.equals(""))
			htmlContent = "<tr><td colspan=3 class=\"listItem_Data\">There are currently no Logic Blocks</td></tr>\n";
	}
	catch(Exception ex)
	{
		ErrLog.put(this,ex,"logic_block_list.jsp",out,1);
		return;
	}
	finally
	{
		if (sqlStatement!=null) sqlStatement.close();
		if (srvConnection!=null) connectionPool.free(srvConnection);
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
<title>Logic Block List</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<body onLoad="innerFramOnLoad();">

<div class="page_header"><fmt:message key="header_dyn_cont"/></div>
<div class="page_desc"><fmt:message key="header_dyn_cont_desc"/></div>

<h2 class="inner-nav-h2" style="">
<a class="inner-nav active" onclick="location.href = 'logic_block_list.jsp';" href="#">Logic Blocks</a>
<a class="inner-nav " onclick="location.href = 'cont_block_list.jsp';" href="#">Content Elements</a>
<a class="inner-nav " onclick="location.href = 'filter_list.jsp';" href="#">Logic Elements</a>
<div style="clear:both;"></div>
</h2>

<br>
<table cellpadding="3" cellspacing="0" border="0" width="95%">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<% if (can.bWrite) { %>
			<a class="newbutton" href="logic_block_edit.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>"><fmt:message key="button_new_logic"/></a>&nbsp;&nbsp;&nbsp;
			<% } %>
		</td>
		<td nowrap valign="middle" align="right" width="100%">
			<table class="filterList" cellspacing="1" cellpadding="0" border="0">
				<tr>
					<td align="right" valign="middle" nowrap><a class="filterHeading" href="#" onclick="filterReveal(30,event);">Filter:</a></td>
					<td align="right" valign="middle" nowrap>&nbsp;Category: <span id="cat_1"></span>&nbsp;</td>
					<td align="right" valign="middle" nowrap>&nbsp;Records / Page: <span id="rec_1"></span>&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<div id="filterBox" style="display:none;">
	<FORM  METHOD="GET" NAME="FT" ID="FT" ACTION="logic_block_list.jsp" style="display:inline;">
	<INPUT TYPE="hidden" NAME="pageCount" VALUE="">
	<INPUT TYPE="hidden" NAME="curPage" VALUE="<%= curPage %>">
	<table class="listTable" cellspacing="0" cellpadding="2" border="0">
		<tr>
			<th valign="middle" align="left" colspan="2">Filter the Logic Blocks</th>
			<th valign="top" align="right" style="cursor:pointer;" onclick="filterReveal(30,event);">&nbsp;<b>X</b>&nbsp;</th>
		</tr>
		<tr<%= !canCat.bRead?" style=\"display:none\"":"" %>>
			<td valign="middle" align="right">Category:&nbsp;</td>
			<td valign="middle" align="left"><%= CategortiesControl.toHtml(cust.s_cust_id, canCat.bExecute, sSelectedCategoryId,"") %></td>
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
			<td valign="middle" align="center" colspan="2"><a class="subactionbutton" href="#" onClick="filterReveal(30,event);GO(0);">Filter</a></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
	</table>
	</FORM>
</div>
<br>
<table cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<table class="listTable" cellspacing="0" cellpadding="0" border="0" align="right">
				<tr>
					<td align="right" valign="middle" nowrap>&nbsp;<span id="page_1"></span></td>
					<td align="center" valign="middle">
						<table class="" cellspacing="0" cellpadding="5" border="0">
							<tr>
								<td align="right" valign="middle" nowrap id="first_page" style="display:none"><a href="javascript:GO(0)">&laquo; First</a></td>
								<td align="right" valign="middle" nowrap id="prev_page" style="display:none"><a href="javascript:GO(-1)">&laquo; Previous</a></td>
								<td align="right" valign="middle" nowrap id="next_page" style="display:none"><a href="javascript:GO(1)">Next &raquo;</a></td>
								<td align="right" valign="middle" nowrap id="last_page" style="display:none"><a href="javascript:GO(99)">Last &raquo;</a></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<div class="list-headers">Logic Blocks</div>
			
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th align="left" valign="middle" nowrap>&#x20;<fmt:message key="logic_lb_column_name"/></th>
					<th align="left" valign="middle" nowrap>&#x20;<fmt:message key="logic_lb_column_lastupd"/></th>
					<!--<th align="left" valign="middle" nowrap>&#x20;Action</th>//-->
					<th align="left" valign="middle" nowrap>&#x20;<fmt:message key="logic_lb_column_mod"/></th>
				</tr>
				<!-- List of the contents -->
				<%= htmlContent %>
			</table>
		</td>
	</tr>
</table>
<br><br>

<script language="javascript">
<%@ include file="../../js/scripts.js" %>

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
	var catName = FT.category_id[FT.category_id.selectedIndex].text;

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

</script>
</body>
</fmt:bundle>


</html>

